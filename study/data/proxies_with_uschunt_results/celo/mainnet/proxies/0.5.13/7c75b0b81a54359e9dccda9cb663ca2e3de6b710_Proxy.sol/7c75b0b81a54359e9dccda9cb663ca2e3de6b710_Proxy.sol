pragma solidity ^0.5.13;
/* solhint-disable no-inline-assembly, no-complex-fallback, avoid-low-level-calls */

//import "openzeppelin-solidity/contracts/utils/Address.sol";

/**
 * @title A Proxy utilizing the Unstructured Storage pattern.
 */
contract Proxy {
  // Used to store the address of the owner.
  bytes32 private constant OWNER_POSITION = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
  // Used to store the address of the implementation contract.
  bytes32 private constant IMPLEMENTATION_POSITION = bytes32(
    uint256(keccak256("eip1967.proxy.implementation")) - 1
  );

  event OwnerSet(address indexed owner);
  event ImplementationSet(address indexed implementation);

  constructor() public {
    _setOwner(msg.sender);
  }

  /**
   * @notice Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == _getOwner(), "sender was not owner");
    _;
  }

  /**
   * @notice Delegates calls to the implementation contract.
   */
  function() external payable {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;

    address implementationAddress;

    // Load the address of the implementation contract from an explicit storage slot.
    assembly {
      implementationAddress := sload(implementationPosition)
    }

    // Avoid checking if address is a contract or executing delegated call when
    // implementation address is 0x0
    require(implementationAddress != address(0), "No Implementation set");
    require(Address.isContract(implementationAddress), "Invalid contract address");

    assembly {
      // Extract the position of the transaction data (i.e. function ID and arguments).
      let newCallDataPosition := mload(0x40)
      mstore(0x40, add(newCallDataPosition, calldatasize))
      calldatacopy(newCallDataPosition, 0, calldatasize)

      // Call the smart contract at `implementationAddress` in the context of the proxy contract,
      // with the same msg.sender and value.
      let delegatecallSuccess := delegatecall(
        gas,
        implementationAddress,
        newCallDataPosition,
        calldatasize,
        0,
        0
      )

      // Copy the return value of the call so it can be returned.
      let returnDataSize := returndatasize
      let returnDataPosition := mload(0x40)
      mstore(0x40, add(returnDataPosition, returnDataSize))
      returndatacopy(returnDataPosition, 0, returnDataSize)

      // Revert or return depending on whether or not the call was successful.
      switch delegatecallSuccess
        case 0 {
          revert(returnDataPosition, returnDataSize)
        }
        default {
          return(returnDataPosition, returnDataSize)
        }
    }
  }

  /**
   * @notice Transfers ownership of Proxy to a new owner.
   * @param newOwner Address of the new owner account.
   */
  function _transferOwnership(address newOwner) external onlyOwner {
    _setOwner(newOwner);
  }

  /**
   * @notice Sets the address of the implementation contract and calls into it.
   * @param implementation Address of the new target contract.
   * @param callbackData The abi-encoded function call to perform in the implementation
   * contract.
   * @dev Throws if the initialization callback fails.
   * @dev If the target contract does not need initialization, use
   * setImplementation instead.
   */
  function _setAndInitializeImplementation(address implementation, bytes calldata callbackData)
    external
    payable
    onlyOwner
  {
    _setImplementation(implementation);
    bool success;
    bytes memory returnValue;
    (success, returnValue) = implementation.delegatecall(callbackData);
    require(success, "initialization callback failed");
  }

  /**
   * @notice Returns the implementation address.
   */
  function _getImplementation() external view returns (address implementation) {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;
    // Load the address of the implementation contract from an explicit storage slot.
    assembly {
      implementation := sload(implementationPosition)
    }
  }

  /**
   * @notice Sets the address of the implementation contract.
   * @param implementation Address of the new target contract.
   * @dev If the target contract needs to be initialized, call
   * setAndInitializeImplementation instead.
   */
  function _setImplementation(address implementation) public onlyOwner {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;

    require(Address.isContract(implementation), "Invalid contract address");

    // Store the address of the implementation contract in an explicit storage slot.
    assembly {
      sstore(implementationPosition, implementation)
    }

    emit ImplementationSet(implementation);
  }

  /**
   * @notice Returns the Proxy owner's address.
   */
  function _getOwner() public view returns (address owner) {
    bytes32 position = OWNER_POSITION;
    // Load the address of the contract owner from an explicit storage slot.
    assembly {
      owner := sload(position)
    }
  }

  function _setOwner(address newOwner) private {
    require(newOwner != address(0), "owner cannot be 0");
    bytes32 position = OWNER_POSITION;
    // Store the address of the contract owner in an explicit storage slot.
    assembly {
      sstore(position, newOwner)
    }
    emit OwnerSet(newOwner);
  }
}


pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following 
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}