pragma solidity 0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract IController is Pausable {
    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
    function updateController(bytes32 _id, address _controller) external;
    function getContract(bytes32 _id) public view returns (address);
}

contract IManager {
    event SetController(address controller);
    event ParameterUpdate(string param);

    function setController(address _controller) external;
}

contract Manager is IManager {
    // Controller that contract is registered with
    IController public controller;

    // Check if sender is controller
    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }

    // Check if sender is controller owner
    modifier onlyControllerOwner() {
        require(msg.sender == controller.owner());
        _;
    }

    // Check if controller is not paused
    modifier whenSystemNotPaused() {
        require(!controller.paused());
        _;
    }

    // Check if controller is paused
    modifier whenSystemPaused() {
        require(controller.paused());
        _;
    }

    function Manager(address _controller) public {
        controller = IController(_controller);
    }

    /*
     * @dev Set controller. Only callable by current controller
     * @param _controller Controller contract address
     */
    function setController(address _controller) external onlyController {
        controller = IController(_controller);

        SetController(_controller);
    }
}

/**
 * @title ManagerProxyTarget
 * @dev The base contract that target contracts used by a proxy contract should inherit from
 * Note: Both the target contract and the proxy contract (implemented as ManagerProxy) MUST inherit from ManagerProxyTarget in order to guarantee
 * that both contracts have the same storage layout. Differing storage layouts in a proxy contract and target contract can
 * potentially break the delegate proxy upgradeability mechanism
 */
contract ManagerProxyTarget is Manager {
    // Used to look up target contract address in controller&#39;s registry
    bytes32 public targetContractId;
}

/**
 * @title ManagerProxy
 * @dev A proxy contract that uses delegatecall to execute function calls on a target contract using its own storage context.
 * The target contract is a Manager contract that is registered with the Controller.
 * Note: Both this proxy contract and its target contract MUST inherit from ManagerProxyTarget in order to guarantee
 * that both contracts have the same storage layout. Differing storage layouts in a proxy contract and target contract can
 * potentially break the delegate proxy upgradeability mechanism
 */
contract ManagerProxy is ManagerProxyTarget {
    /**
     * @dev ManagerProxy constructor. Invokes constructor of base Manager contract with provided Controller address.
     * Also, sets the contract ID of the target contract that function calls will be executed on.
     * @param _controller Address of Controller that this contract will be registered with
     * @param _targetContractId contract ID of the target contract
     */
    function ManagerProxy(address _controller, bytes32 _targetContractId) public Manager(_controller) {
        targetContractId = _targetContractId;
    }

    /**
     * @dev Uses delegatecall to execute function calls on this proxy contract&#39;s target contract using its own storage context.
     * This fallback function will look up the address of the target contract using the Controller and the target contract ID.
     * It will then use the calldata for a function call as the data payload for a delegatecall on the target contract. The return value
     * of the executed function call will also be returned
     */
    function() public payable {
        address target = controller.getContract(targetContractId);
        // Target contract must be registered
        require(target > 0);

        assembly {
            // Solidity keeps a free memory pointer at position 0x40 in memory
            let freeMemoryPtrPosition := 0x40
            // Load the free memory pointer
            let calldataMemoryOffset := mload(freeMemoryPtrPosition)
            // Update free memory pointer to after memory space we reserve for calldata
            mstore(freeMemoryPtrPosition, add(calldataMemoryOffset, calldatasize))
            // Copy calldata (method signature and params of the call) to memory
            calldatacopy(calldataMemoryOffset, 0x0, calldatasize)

            // Call method on target contract using calldata which is loaded into memory
            let ret := delegatecall(gas, target, calldataMemoryOffset, calldatasize, 0, 0)

            // Load the free memory pointer
            let returndataMemoryOffset := mload(freeMemoryPtrPosition)
            // Update free memory pointer to after memory space we reserve for returndata
            mstore(freeMemoryPtrPosition, add(returndataMemoryOffset, returndatasize))
            // Copy returndata (result of the method invoked by the delegatecall) to memory
            returndatacopy(returndataMemoryOffset, 0x0, returndatasize)

            switch ret
            case 0 {
                // Method call failed - revert
                // Return any error message stored in mem[returndataMemoryOffset..(returndataMemoryOffset + returndatasize)]
                revert(returndataMemoryOffset, returndatasize)
            } default {
                // Return result of method call stored in mem[returndataMemoryOffset..(returndataMemoryOffset + returndatasize)]
                return(returndataMemoryOffset, returndatasize)
            }
        }
    }
}


/**
 * @title ServiceRegistry
 * @dev Maintains a registry of service metadata associated with service provider addresses (transcoders/orchestrators)
 */
contract ServiceRegistry is ManagerProxyTarget {
    // Store service metadata
    struct Record {
        string serviceURI;   // Service URI endpoint that can be used to send off-chain requests
    }

    // Track records for addresses
    mapping (address => Record) private records;

    // Event fired when a caller updates its service URI endpoint
    event ServiceURIUpdate(address indexed addr, string serviceURI);

    /**
     * @dev ServiceRegistry constructor. Only invokes constructor of base Manager contract with provided Controller address
     * @param _controller Address of a Controller that this contract will be registered with
     */
    function ServiceRegistry(address _controller) public Manager(_controller) {}

    /**
     * @dev Stores service URI endpoint for the caller that can be used to send requests to the caller off-chain 
     * @param _serviceURI Service URI endpoint for the caller
     */
    function setServiceURI(string _serviceURI) external {
        records[msg.sender].serviceURI = _serviceURI;

        ServiceURIUpdate(msg.sender, _serviceURI);
    }

    /**
     * @dev Returns service URI endpoint stored for a given address
     * @param _addr Address for which a service URI endpoint is desired
     */
    function getServiceURI(address _addr) public view returns (string) {
        return records[_addr].serviceURI;
    }
}

contract Controller is Pausable, IController {
    // Track information about a registered contract
    struct ContractInfo {
        address contractAddress;                 // Address of contract
        bytes20 gitCommitHash;                   // SHA1 hash of head Git commit during registration of this contract
    }

    // Track contract ids and contract info
    mapping (bytes32 => ContractInfo) private registry;

    function Controller() public {
        // Start system as paused
        paused = true;
    }

    /*
     * @dev Register contract id and mapped address
     * @param _id Contract id (keccak256 hash of contract name)
     * @param _contract Contract address
     */
    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external onlyOwner {
        registry[_id].contractAddress = _contractAddress;
        registry[_id].gitCommitHash = _gitCommitHash;

        SetContractInfo(_id, _contractAddress, _gitCommitHash);
    }

    /*
     * @dev Update contract's controller
     * @param _id Contract id (keccak256 hash of contract name)
     * @param _controller Controller address
     */
    function updateController(bytes32 _id, address _controller) external onlyOwner {
        return IManager(registry[_id].contractAddress).setController(_controller);
    }

    /*
     * @dev Return contract info for a given contract id
     * @param _id Contract id (keccak256 hash of contract name)
     */
    function getContractInfo(bytes32 _id) public view returns (address, bytes20) {
        return (registry[_id].contractAddress, registry[_id].gitCommitHash);
    }

    /*
     * @dev Get contract address for an id
     * @param _id Contract id
     */
    function getContract(bytes32 _id) public view returns (address) {
        return registry[_id].contractAddress;
    }
}
