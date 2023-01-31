// : UNLICENSED
pragma solidity 0.8.4;

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions.
 *
 * Roles can be granted and revoked dynamically by accounts with the OWNER_ROLE
 * via the {grantRole} and {revokeRole} functions.
 */
abstract contract AccessControl {
    struct RoleData {
        mapping (address => bool) members;
    }

    bool private _initialized;
    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant NETWORK_CONTRACT_ROLE = keccak256("NETWORK_CONTRACT_ROLE");

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an owner role
     * bearer except when using {initAccessControl}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the owner role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role.
     */
    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "AccessControl: permission denied");
        _;
    }

    /**
     * @dev Initializes access control granting `roles` to the provided `accounts`.
     * The function must be called only once, just after deployment.
     */
    function initAccessControl(bytes32[] calldata roles, address[] calldata accounts)
        external
    {
        require(!_initialized, "AccessControl: already initialized");
        require(roles.length == accounts.length, "AccessControl: parameters length mismatch");

        bool hasAtLeastAnOwner;

        for (uint256 i = 0; i < roles.length; i++) {
            if (roles[i] == OWNER_ROLE) {
                hasAtLeastAnOwner = true;
            }

            _grantRole(roles[i], accounts[i]);
        }

        require(hasAtLeastAnOwner, "AccessControl: no owner provided");

        _initialized = true;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted} event.
     *
     * Requirements:
     *
     * - the caller must have owner role.
     */
    function grantRole(bytes32 role, address account) external onlyRole(OWNER_ROLE) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have owner role.
     */
    function revokeRole(bytes32 role, address account) external onlyRole(OWNER_ROLE) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * Requirements:
     *
     * - the caller must have been granted `role`.
     */
    function renounceRole(bytes32 role) external onlyRole(role) {
        _revokeRole(role, msg.sender);
    }

    /**
     * @dev Returns true if account has been granted role.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     */
    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;

            emit RoleGranted(role, account, msg.sender);
        }
    }

    /**
     * @dev Revokes `role` from `account`..
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     * Note that unlike {revokeRole}, this function doesn't perform any
     * checks on the calling account.
     */
    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, msg.sender);
        }
    }
}


// : UNLICENSED
pragma solidity 0.8.4;

/**
 * @dev The Database contract provides a generic key-value storage that can
 * be extended to fit any need.
 */
abstract contract Database {
    mapping (bytes32 => uint256) private _uintStorage;
    mapping (bytes32 => string) private _stringStorage;
    mapping (bytes32 => address) private _addressStorage;
    mapping (bytes32 => bytes) private _bytesStorage;
    mapping (bytes32 => bool) private _boolStorage;
    mapping (bytes32 => int256) private _intStorage;
    mapping (bytes32 => bytes32) private _bytes32Storage;

    mapping (bytes32 => uint256[]) private _uintArrayStorage;
    mapping (bytes32 => string[]) private _stringArrayStorage;
    mapping (bytes32 => address[]) private _addressArrayStorage;
    mapping (bytes32 => bytes[]) private _bytesArrayStorage;
    mapping (bytes32 => bool[]) private _boolArrayStorage;
    mapping (bytes32 => int256[]) private _intArrayStorage;
    mapping (bytes32 => bytes32[]) private _bytes32ArrayStorage;

    /**
     * @dev Sets a uint `value` on the given `key`.
     */
    function _setUint(bytes32 key, uint256 value) internal {
        _uintStorage[key] = value;
    }

    /**
     * @dev Sets a string `value` on the given `key`.
     */
    function _setString(bytes32 key, string calldata value) internal {
        _stringStorage[key] = value;
    }

    /**
     * @dev Sets an address `value` on the given `key`.
     */
    function _setAddress(bytes32 key, address value) internal {
        _addressStorage[key] = value;
    }

    /**
     * @dev Sets a bytes `value` on the given `key`.
     */
    function _setBytes(bytes32 key, bytes calldata value) internal {
        _bytesStorage[key] = value;
    }

    /**
     * @dev Sets a bool `value` on the given `key`.
     */
    function _setBool(bytes32 key, bool value) internal {
        _boolStorage[key] = value;
    }

    /**
     * @dev Sets an int `value` on the given `key`.
     */
    function _setInt(bytes32 key, int256 value) internal {
        _intStorage[key] = value;
    }

    /**
     * @dev Sets a bytes32 `value` on the given `key`.
     */
    function _setBytes32(bytes32 key, bytes32 value) internal {
        _bytes32Storage[key] = value;
    }

    /**
     * @dev Sets a uint array `value` on the given `key`.
     */
    function _setUintArray(bytes32 key, uint256[] calldata value) internal {
        _uintArrayStorage[key] = value;
    }

    /**
     * @dev Sets a string array `value` on the given `key`.
     */
    function _setStringArray(bytes32 key, string[] calldata value) internal {
        _stringArrayStorage[key] = value;
    }

    /**
     * @dev Sets an address array `value` on the given `key`.
     */
    function _setAddressArray(bytes32 key, address[] calldata value) internal {
        _addressArrayStorage[key] = value;
    }

    /**
     * @dev Sets a bytes array `value` on the given `key`.
     */
    function _setBytesArray(bytes32 key, bytes[] calldata value) internal {
        _bytesArrayStorage[key] = value;
    }

    /**
     * @dev Sets a bool array `value` on the given `key`.
     */
    function _setBoolArray(bytes32 key, bool[] calldata value) internal {
        _boolArrayStorage[key] = value;
    }

    /**
     * @dev Sets an int array `value` on the given `key`.
     */
    function _setIntArray(bytes32 key, int256[] calldata value) internal {
        _intArrayStorage[key] = value;
    }

    /**
     * @dev Sets a bytes32 array `value` on the given `key`.
     */
    function _setBytes32Array(bytes32 key, bytes32[] calldata value) internal {
        _bytes32ArrayStorage[key] = value;
    }

    /**
     * @dev Deletes the uint value stored with the given `key`.
     */
    function _deleteUint(bytes32 key) internal {
        delete _uintStorage[key];
    }

    /**
     * @dev Deletes the string value stored with the given `key`.
     */
    function _deleteString(bytes32 key) internal {
        delete _stringStorage[key];
    }

    /**
     * @dev Deletes the address value stored with the given `key`.
     */
    function _deleteAddress(bytes32 key) internal {
        delete _addressStorage[key];
    }

    /**
     * @dev Deletes the bytes value stored with the given `key`.
     */
    function _deleteBytes(bytes32 key) internal {
        delete _bytesStorage[key];
    }

    /**
     * @dev Deletes the bool value stored with the given `key`.
     */
    function _deleteBool(bytes32 key) internal {
        delete _boolStorage[key];
    }

    /**
     * @dev Deletes the int value stored with the given `key`.
     */
    function _deleteInt(bytes32 key) internal {
        delete _intStorage[key];
    }

    /**
     * @dev Deletes the bytes32 value stored with the given `key`.
     */
    function _deleteBytes32(bytes32 key) internal {
        delete _bytes32Storage[key];
    }

    /**
     * @dev Deletes the uint array value stored with the given `key`.
     */
    function _deleteUintArray(bytes32 key) internal {
        delete _uintArrayStorage[key];
    }

    /**
     * @dev Deletes the string array value stored with the given `key`.
     */
    function _deleteStringArray(bytes32 key) internal {
        delete _stringArrayStorage[key];
    }

    /**
     * @dev Deletes the address array value stored with the given `key`.
     */
    function _deleteAddressArray(bytes32 key) internal {
        delete _addressArrayStorage[key];
    }

    /**
     * @dev Deletes the bytes array value stored with the given `key`.
     */
    function _deleteBytesArray(bytes32 key) internal {
        delete _bytesArrayStorage[key];
    }

    /**
     * @dev Deletes the bool array value stored with the given `key`.
     */
    function _deleteBoolArray(bytes32 key) internal {
        delete _boolArrayStorage[key];
    }

    /**
     * @dev Deletes the int array value stored with the given `key`.
     */
    function _deleteIntArray(bytes32 key) internal {
        delete _intArrayStorage[key];
    }

    /**
     * @dev Deletes the bytes32 array value stored with the given `key`.
     */
    function _deleteBytes32Array(bytes32 key) internal {
        delete _bytes32ArrayStorage[key];
    }

    /**
     * @dev Returns the uint value stored with the given `key`.
     */
    function _getUint(bytes32 key) internal view returns(uint256) {
        return _uintStorage[key];
    }

    /**
     * @dev Returns the string value stored with the given `key`.
     */
    function _getString(bytes32 key) internal view returns(string memory) {
        return _stringStorage[key];
    }

    /**
     * @dev Returns the address value stored with the given `key`.
     */
    function _getAddress(bytes32 key) internal view returns(address) {
        return _addressStorage[key];
    }

    /**
     * @dev Returns the bytes value stored with the given `key`.
     */
    function _getBytes(bytes32 key) internal view returns(bytes memory) {
        return _bytesStorage[key];
    }

    /**
     * @dev Returns the bool value stored with the given `key`.
     */
    function _getBool(bytes32 key) internal view returns(bool) {
        return _boolStorage[key];
    }

    /**
     * @dev Returns the int value stored with the given `key`.
     */
    function _getInt(bytes32 key) internal view returns(int256) {
        return _intStorage[key];
    }

    /**
     * @dev Returns the bytes32 value stored with the given `key`.
     */
    function _getBytes32(bytes32 key) internal view returns(bytes32) {
        return _bytes32Storage[key];
    }

    /**
     * @dev Returns the uint array value stored with the given `key`.
     */
    function _getUintArray(bytes32 key) internal view returns(uint256[] memory) {
        return _uintArrayStorage[key];
    }

    /**
     * @dev Returns the string array value stored with the given `key`.
     */
    function _getStringArray(bytes32 key) internal view returns(string[] memory) {
        return _stringArrayStorage[key];
    }

    /**
     * @dev Returns the address array value stored with the given `key`.
     */
    function _getAddressArray(bytes32 key) internal view returns(address[] memory) {
        return _addressArrayStorage[key];
    }

    /**
     * @dev Returns the bytes array value stored with the given `key`.
     */
    function _getBytesArray(bytes32 key) internal view returns(bytes[] memory) {
        return _bytesArrayStorage[key];
    }

    /**
     * @dev Returns the bool array value stored with the given `key`.
     */
    function _getBoolArray(bytes32 key) internal view returns(bool[] memory) {
        return _boolArrayStorage[key];
    }

    /**
     * @dev Returns the int array value stored with the given `key`.
     */
    function _getIntArray(bytes32 key) internal view returns(int256[] memory) {
        return _intArrayStorage[key];
    }

    /**
     * @dev Returns the bytes32 array value stored with the given `key`.
     */
    function _getBytes32Array(bytes32 key) internal view returns(bytes32[] memory) {
        return _bytes32ArrayStorage[key];
    }
}


// : UNLICENSED
pragma solidity 0.8.4;

interface IFixedRecurringPlansDatabase {
    function setAdmin(bytes32 planId, address admin) external;
    function setPeriod(bytes32 planId, uint256 period) external;
    function setToken(bytes32 planId, address token) external;
    function setReceiver(bytes32 planId, address receiver) external;
    function setAmount(bytes32 planId, uint256 amount) external;

    function setPermission(
        bytes32 planId,
        bytes32 permission,
        address account,
        bool value
    ) external;

    function getAdmin(bytes32 planId) external view returns (address);
    function getPeriod(bytes32 planId) external view returns (uint256);
    function getToken(bytes32 planId) external view returns (address);
    function getReceiver(bytes32 planId) external view returns (address);
    function getAmount(bytes32 planId) external view returns (uint256);

    function hasPermission(bytes32 planId, bytes32 permission, address account)
        external
        view
        returns (bool);
}


// : UNLICENSED
pragma solidity 0.8.4;

//import{ AccessControl } from "../../access/AccessControl.sol";
//import{ Database } from "../../storage/Database.sol";
//import{ IFixedRecurringPlansDatabase } from "../../interfaces/IFixedRecurringPlansDatabase.sol";

/**
 * @dev This contract stores all data related to plans of the fixed recurring billing model.
 */
contract FixedRecurringPlansDatabase is IFixedRecurringPlansDatabase, Database, AccessControl {
    /**
     * @dev Sets the `admin` of the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
     */
    function setAdmin(bytes32 planId, address admin)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setAddress(_getPlanFieldKey(planId, "admin"), admin);
    }

    /**
     * @dev Sets the `period` of the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
     */
    function setPeriod(bytes32 planId, uint256 period)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setUint(_getPlanFieldKey(planId, "period"), period);
    }

    /**
     * @dev Sets the `token` of the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
     */
    function setToken(bytes32 planId, address token)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setAddress(_getPlanFieldKey(planId, "token"), token);
    }

    /**
     * @dev Sets the `receiver` of the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
     */
    function setReceiver(bytes32 planId, address receiver)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setAddress(_getPlanFieldKey(planId, "receiver"), receiver);
    }

    /**
     * @dev Sets the `amount` of the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
     */
    function setAmount(bytes32 planId, uint256 amount)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setUint(_getPlanFieldKey(planId, "amount"), amount);
    }

    /**
     * @dev Sets the `permission` for `account` on the plan.
     *
     * Requirements:
     *
     * - caller must be a network contract.
    */
    function setPermission(bytes32 planId, bytes32 permission, address account, bool value)
        external
        override
        onlyRole(NETWORK_CONTRACT_ROLE)
    {
        _setBool(_getPermissionFieldKey(planId, permission, account), value);
    }

    /**
     * @dev Returns the admin of the plan.
     */
    function getAdmin(bytes32 planId) external override view returns (address) {
        return _getAddress(_getPlanFieldKey(planId, "admin"));
    }

    /**
     * @dev Returns the period of the plan.
     */
    function getPeriod(bytes32 planId) external override view returns (uint256) {
        return _getUint(_getPlanFieldKey(planId, "period"));
    }

    /**
     * @dev Returns the token of the plan.
     */
    function getToken(bytes32 planId) external override view returns (address) {
        return _getAddress(_getPlanFieldKey(planId, "token"));
    }

    /**
     * @dev Returns the receiver of the plan.
     */
    function getReceiver(bytes32 planId) external override view returns (address) {
        return _getAddress(_getPlanFieldKey(planId, "receiver"));
    }

    /**
     * @dev Returns the amount of the plan.
     */
    function getAmount(bytes32 planId) external override view returns (uint256) {
        return _getUint(_getPlanFieldKey(planId, "amount"));
    }

    /**
     * @dev Returns true if the account has the given permission on the plan.
     */
    function hasPermission(bytes32 planId, bytes32 permission, address account)
        external
        override
        view
        returns (bool)
    {
        return _getBool(_getPermissionFieldKey(planId, permission, account));
    }

    /**
     * @dev Returns an hash to be used as key for storing a plan's field.
     */
    function _getPlanFieldKey(bytes32 planId, string memory field)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(planId, field));
    }

    /**
     * @dev Returns an hash to be used as key for storing a permission of an account on a plan.
     */
    function _getPermissionFieldKey(bytes32 planId, bytes32 permission, address account)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(planId, permission, account));
    }
}


