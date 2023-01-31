

// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  fallback () payable external {
    _fallback();
  }

  /**
   * @dev Receive function.
   * Implemented entirely in `_fallback`.
   */
  receive () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal virtual view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal virtual {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}




// ////-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

//import './Proxy.sol';
//import '@openzeppelin/contracts/utils/Address.sol';

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is Proxy {
  /**
   * @dev Contract constructor.
   * @param _logic Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  

  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
   * validated in the constructor.
   */
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /**
   * @dev Returns the current implementation.
   * @return impl Address of the current implementation
   */
  function _implementation() internal override view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) internal {
    require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}


// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

//import './UpgradeabilityProxy.sol';

/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }

  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
   * validated in the constructor.
   */

  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  /**
   * @return adm The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  /**
   * @dev Only fall back when the sender is not the admin.
   */
  function _willFallback() internal override virtual {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}


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
