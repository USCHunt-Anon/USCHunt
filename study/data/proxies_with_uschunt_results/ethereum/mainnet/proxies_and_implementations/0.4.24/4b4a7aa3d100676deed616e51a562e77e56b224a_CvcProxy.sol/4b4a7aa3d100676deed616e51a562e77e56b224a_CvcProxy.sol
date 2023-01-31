pragma solidity ^0.4.24;

// File: contracts/upgradeability/ImplementationStorage.sol

/**
 * @title ImplementationStorage
 * @dev This contract stores proxy implementation address.
 */
contract ImplementationStorage {

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "cvc.proxy.implementation", and is validated in the constructor.
     */
    bytes32 internal constant IMPLEMENTATION_SLOT = 0xa490aab0d89837371982f93f57ffd20c47991f88066ef92475bc8233036969bb;

    /**
    * @dev Constructor
    */
    constructor() public {
        assert(IMPLEMENTATION_SLOT == keccak256("cvc.proxy.implementation"));
    }

    /**
     * @dev Returns the current implementation.
     * @return Address of the current implementation
     */
    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}

// File: openzeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

// File: contracts/upgradeability/CvcProxy.sol

/**
 * @title CvcProxy
 * @dev Transparent proxy with upgradeability functions and authorization control.
 */
contract CvcProxy is ImplementationStorage {

    /**
     * @dev Emitted when the implementation is upgraded.
     * @param implementation Address of the new implementation.
     */
    event Upgraded(address implementation);

    /**
     * @dev Emitted when the administration has been transferred.
     * @param previousAdmin Address of the previous admin.
     * @param newAdmin Address of the new admin.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "cvc.proxy.admin", and is validated in the constructor.
     */
    bytes32 private constant ADMIN_SLOT = 0x2bbac3e52eee27be250d682577104e2abe776c40160cd3167b24633933100433;

    /**
     * @dev Modifier to check whether the `msg.sender` is the admin.
     * It executes the function if called by admin. Otherwise, it will delegate the call to the implementation.
     */
    modifier ifAdmin() {
        if (msg.sender == currentAdmin()) {
            _;
        } else {
            delegate(implementation());
        }
    }

    /**
     * Contract constructor.
     * It sets the `msg.sender` as the proxy admin.
     */
    constructor() public {
        assert(ADMIN_SLOT == keccak256("cvc.proxy.admin"));
        setAdmin(msg.sender);
    }

    /**
     * @dev Fallback function.
     */
    function() external payable {
        require(msg.sender != currentAdmin(), "Message sender is not contract admin");
        delegate(implementation());
    }

    /**
     * @dev Changes the admin of the proxy.
     * Only the current admin can call this function.
     * @param _newAdmin Address to transfer proxy administration to.
     */
    function changeAdmin(address _newAdmin) external ifAdmin {
        require(_newAdmin != address(0), "Cannot change contract admin to zero address");
        emit AdminChanged(currentAdmin(), _newAdmin);
        setAdmin(_newAdmin);
    }

    /**
     * @dev Allows the proxy owner to upgrade the current version of the proxy.
     * @param _implementation the address of the new implementation to be set.
     */
    function upgradeTo(address _implementation) external ifAdmin {
        upgradeImplementation(_implementation);
    }

    /**
     * @dev Allows the proxy owner to upgrade and call the new implementation
     * to initialize whatever is needed through a low level call.
     * @param _implementation the address of the new implementation to be set.
     * @param _data the msg.data to bet sent in the low level call. This parameter may include the function
     * signature of the implementation to be called with the needed payload.
     */
    function upgradeToAndCall(address _implementation, bytes _data) external payable ifAdmin {
        upgradeImplementation(_implementation);
        //solium-disable-next-line security/no-call-value
        require(address(this).call.value(msg.value)(_data), "Upgrade error: initialization method call failed");
    }

    /**
     * @dev Returns the Address of the proxy admin.
     * @return address
     */
    function admin() external view ifAdmin returns (address) {
        return currentAdmin();
    }

    /**
     * @dev Upgrades the implementation address.
     * @param _newImplementation the address of the new implementation to be set
     */
    function upgradeImplementation(address _newImplementation) private {
        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation, "Upgrade error: proxy contract already uses specified implementation");
        setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * @param _implementation Address to delegate.
     */
    function delegate(address _implementation) private {
        assembly {
            // Copy msg.data.
            calldatacopy(0, 0, calldatasize)

            // Call current implementation passing proxy calldata.
            let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            // Propagate result (delegatecall returns 0 on error).
            switch result
            case 0 {revert(0, returndatasize)}
            default {return (0, returndatasize)}
        }
    }

    /**
     * @return The admin slot.
     */
    function currentAdmin() private view returns (address proxyAdmin) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            proxyAdmin := sload(slot)
        }
    }

    /**
     * @dev Sets the address of the proxy admin.
     * @param _newAdmin Address of the new proxy admin.
     */
    function setAdmin(address _newAdmin) private {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, _newAdmin)
        }
    }

    /**
     * @dev Sets the implementation address of the proxy.
     * @param _newImplementation Address of the new implementation.
     */
    function setImplementation(address _newImplementation) private {
        require(
            AddressUtils.isContract(_newImplementation),
            "Cannot set new implementation: no contract code at contract address"
        );
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _newImplementation)
        }
    }

}

pragma solidity ^0.4.24;

// File: contracts/idv/CvcValidatorRegistryInterface.sol

/**
 * @title CvcValidatorRegistryInterface
 * @dev This contract defines Validator Registry interface.
 */
contract CvcValidatorRegistryInterface {

    /**
    * @dev Adds a new Validator record or updates the existing one.
    * @param _name Validator name.
    * @param _description Validator description.
    */
    function set(address _idv, string _name, string _description) external;

    /**
    * @dev Returns Validator entry.
    * @param _idv Validator address.
    * @return name Validator name.
    * @return description Validator description.
    */
    function get(address _idv) external view returns (string name, string description);

    /**
    * @dev Verifies whether Validator is registered.
    * @param _idv Validator address.
    * @return bool
    */
    function exists(address _idv) external view returns (bool);
}

// File: contracts/upgradeability/EternalStorage.sol

/**
 * @title EternalStorage
 * @dev This contract defines the generic storage structure
 * so that it could be re-used to implement any domain specific storage functionality
 */
contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;
    mapping(bytes32 => bytes32) internal bytes32Storage;

}

// File: contracts/upgradeability/Initializable.sol

/**
 * @title Initializable
 * @dev This contract provides basic initialization control
 */
contract Initializable is EternalStorage, ImplementationStorage {

    /**
    Data structures and storage layout:
    mapping(bytes32 => bool) initialized;
    **/

    /**
     * @dev Throws if called before contract was initialized.
     */
    modifier onlyInitialized() {
        // require(initialized[implementation()]);
        require(boolStorage[keccak256(abi.encodePacked(implementation(), "initialized"))], "Contract is not initialized");
        _;
    }

    /**
     * @dev Controls the initialization state, allowing to call an initialization function only once.
     */
    modifier initializes() {
        address impl = implementation();
        // require(!initialized[implementation()]);
        require(!boolStorage[keccak256(abi.encodePacked(impl, "initialized"))], "Contract is already initialized");
        _;
        // initialized[implementation()] = true;
        boolStorage[keccak256(abi.encodePacked(impl, "initialized"))] = true;
    }
}

// File: contracts/upgradeability/Ownable.sol

/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable is EternalStorage {

    /**
    Data structures and storage layout:
    address owner;
    **/

    /**
     * @dev Event to show ownership has been transferred
     * @param previousOwner representing the address of the previous owner
     * @param newOwner representing the address of the new owner
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner(), "Message sender must be contract admin");
        _;
    }

    /**
     * @dev Tells the address of the owner
     * @return the address of the owner
     */
    function owner() public view returns (address) {
        // return owner;
        return addressStorage[keccak256("owner")];
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner the address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Contract owner cannot be zero address");
        setOwner(newOwner);
    }

    /**
     * @dev Sets a new owner address
     */
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        // owner = newOwner;
        addressStorage[keccak256("owner")] = newOwner;
    }
}

// File: contracts/idv/CvcValidatorRegistry.sol

/**
 * @title CvcValidatorRegistry
 * @dev This contract is a registry for Identity Validators (IDV). It is part of the marketplace access control mechanism.
 * Only registered and authorized Identity Validators can perform certain actions on marketplace.
 */
contract CvcValidatorRegistry is EternalStorage, Initializable, Ownable, CvcValidatorRegistryInterface {

    /**
    Data structures and storage layout:
    struct Validator {
        string name;
        string description;
    }
    mapping(address => Validator) validators;
    **/

    /**
    * @dev Constructor: invokes initialization function
    */
    constructor() public {
        initialize(msg.sender);
    }

    /**
    * @dev Registers a new Validator or updates the existing one.
    * @param _idv Validator address.
    * @param _name Validator name.
    * @param _description Validator description.
    */
    function set(address _idv, string _name, string _description) external onlyInitialized onlyOwner {
        require(_idv != address(0), "Cannot register IDV with zero address");
        require(bytes(_name).length > 0, "Cannot register IDV with empty name");

        setValidatorName(_idv, _name);
        setValidatorDescription(_idv, _description);
    }

    /**
    * @dev Returns Validator data.
    * @param _idv Validator address.
    * @return name Validator name.
    * @return description Validator description.
    */
    function get(address _idv) external view onlyInitialized returns (string name, string description) {
        name = getValidatorName(_idv);
        description = getValidatorDescription(_idv);
    }

    /**
    * @dev Verifies whether Validator is registered.
    * @param _idv Validator address.
    * @return bool
    */
    function exists(address _idv) external view onlyInitialized returns (bool) {
        return bytes(getValidatorName(_idv)).length > 0;
    }

    /**
    * @dev Contract initialization method.
    * @param _owner Owner address
    */
    function initialize(address _owner) public initializes {
        setOwner(_owner);
    }

    /**
    * @dev Returns Validator name.
    * @param _idv Validator address.
    * @return string
    */
    function getValidatorName(address _idv) private view returns (string) {
        // return validators[_idv].name;
        return stringStorage[keccak256(abi.encodePacked("validators.", _idv, ".name"))];
    }

    /**
    * @dev Saves Validator name.
    * @param _idv Validator address.
    * @param _name Validator name.
    */
    function setValidatorName(address _idv, string _name) private {
        // validators[_idv].name = _name;
        stringStorage[keccak256(abi.encodePacked("validators.", _idv, ".name"))] = _name;
    }

    /**
    * @dev Returns Validator description.
    * @param _idv Validator address.
    * @return string
    */
    function getValidatorDescription(address _idv) private view returns (string) {
        // return validators[_idv].description;
        return stringStorage[keccak256(abi.encodePacked("validators.", _idv, ".description"))];
    }

    /**
    * @dev Saves Validator description.
    * @param _idv Validator address.
    * @param _description Validator description.
    */
    function setValidatorDescription(address _idv, string _description) private {
        // validators[_idv].description = _description;
        stringStorage[keccak256(abi.encodePacked("validators.", _idv, ".description"))] = _description;
    }

}