



// ////-License-Identifier: MIT

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
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
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
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}















// ////-License-Identifier: MIT

pragma solidity ^0.8.2;

//import "IBeacon.sol";
//import "Address.sol";
//import "StorageSlot.sol";

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
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
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
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}















// ////-License-Identifier: MIT

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















// ////-License-Identifier: MIT

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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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















// ////-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "Proxy.sol";
//import "ERC1967Upgrade.sol";

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















// ////-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "ERC1967Proxy.sol";

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
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
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












// ////-License-Identifier: None
pragma solidity ^0.8.0;

//import "TransparentUpgradeableProxy.sol";

/**
 * @notice This is the proxy address that the clients will use on their contracts. It will be fixed
 * and never change. Only the Seraph implementation itself will be changed if code needs to be
 * upgraded. The storage for Seraph will reside in this contract. To take care of storage layout
 * the SeraphStorage contract exists.
 *
 * @dev Seraph will be executed though a Proxy with a fixed address that all the clients will know
 * and use to interact with Seraph. Transparent Upgradable Proxy will be used so Seraph code can be
 * later upgraded without affecting the fixed interface address. Furthermore, administrative task on
 * the proxy itself (SeraphProxy) will be delegated to a ProxyAdmin contract, owned and administred
 * by Halborn using a Multisig wallet, as suggested on the transparent proxy pattern. More information
 * can be found on https://blog.openzeppelin.com/the-transparent-proxy-pattern/
 */
contract SeraphProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {}

}


// : AGPL-3.0-only
pragma solidity ^0.8.0;

/**
 * @author Halborn - Copyright (C) 2021-Present
 * @notice Seraph storage
 * @dev This contract will be used to keep track of the storage layout when dealing with proxies
 * on Seraph. Any new storage variable should be added at the end of this contract, extending
 * the storage, and solving storage collision as detailed in
 * https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#storage-collisions-between-implementation-versions
 *
 */
contract SeraphStorage {
    /// @notice Used to track if a client, contract or function is tracked and protected by Seraph™
    struct Tracking {
        bool _isProtected;
        bool _isTracked;
    }

    /// @notice Used by getters to represent a client identifier and the protection.
    struct ClientView {
        bytes32 _id;
        bool _isProtected;
    }

    /// @notice Used by getters to represent a contract identifier and the protection.
    struct ContractView {
        address _address;
        bool _isProtected;
    }

    /// @notice Used by getters to represent a function identifier and the protection.
    struct FunctionView {
        bytes4 _functionSelector;
        bool _isProtected;
    }

    /// @notice Used to store all the calls in order that will be executed on the approved
    /// transaction and to verify, during the actual exeuction, the integrity of it.
    struct CallStackState {

        /// @notice Used to store all permits that will be executed on the approved tx
        /// @dev We are not using an array since we only need the total length when verifying the integrity.
        /// Using an array does cost more gas, since the length and permit value should be stored for each
        /// approval. For multi-approvals, writing just the value and then a single store for the count
        /// is cheaper:
        /// (2*SSTORE * approvals) > (SSTORE * approvals + SSTORE)
        mapping(uint256 => bytes32) toExecute;

        /// @notice The total calls that are approved and need to be executed. This is used to verify
        /// that all calls where executed when returning from the first protected call (depth eq 0).
        uint256 toExecuteCount;

        /// @notice Number of already executed calls for this integrity
        uint256 numExecuted;

        /// @notice It holds the call stack depth of protected functions. Used to validate
        /// the integrity when returning from the first call protected by seraph
        uint256 depth;
    }

    //////////////////////
    // Clients
    //////////////////////

    /// @notice Used to get all tracked clients
    bytes32[] internal _clients;

    /// @notice Used to track registered clients on Seraph
    mapping(bytes32 => Tracking) internal _clientTracking;

    /// @notice Used to access all contract addresses for a specific client id
    /// @dev 1 to N: One clientId has many contracts
    mapping(bytes32 => address[]) internal _clientContracts;

    //////////////////////
    // Contracts
    //////////////////////

    /// @notice Used to track registered contracts on Seraph
    /// @dev We don't use a mapping based on client id since only one contract address can cohexist
    /// and two clients can not have the same address.
    /// 1 to 1: One address has one Contract struct.
    mapping(address => Tracking) internal _contractTracking;

    /// @notice used to get the client id for the given address
    mapping(address => bytes32) internal _contractClient;

    /// @notice Used to access all function selectors for a specific contract address.
    /// @dev 1 to N: One contract has many function selectors
    mapping(address => bytes4[]) internal _contractFunctions;

    //////////////////////
    // Functions
    //////////////////////

    /// @notice Used to get a function object based on the contract address and the function selector
    /// @dev Its possible to have the same function signature for two different contracts,
    /// thats why we need to map each contract address with each own selector mapping
    mapping(address => mapping(bytes4 => Tracking)) internal _functionTracking;

    //////////////////////
    // Caller state
    //////////////////////

    /// @notice The integrity object used to validate an approval execution. The mapping key is the tx.orgin
    mapping(address => CallStackState) internal _callStackStates;

    //////////////////////
    // Admin state
    //////////////////////

    /// @notice A whitelist mapping for all addresses allowed to approve tx on Seraph.
    /// A new key will only be whitelisted when a KMS key is generated on the RPC backend.
    mapping(address => bool) internal _approversWhitelist;

    /// @notice Whether Seraph was has been _initialised or not.
    /// @dev This value can only be set using the initializer modifier
    bool internal _initialised;

    /// @notice KMS wallet used for administrative purpose on Seraph. Halborn will not have control of
    /// the private key. Only Lambda code will be allowed to sign with it.
    ///
    /// @dev This wallet will be set during initialization. A setter will exist in case of KMS outage
    /// so the owner can change it and replicate the administration using a mutisig wallet.
    address public admin;

    /// @notice Owner of Seraph, it will be a multisig wallet that is only capable of changing the admin
    /// KMS key
    address public owner;

}

/**
 * @author Halborn - Copyright (C) 2021-Present
 * @notice
 * Seraph ™ is a Blockchain Security Notary, developed by Halborn, who's mission is to bridge the gap between
 * decentralized and centralized smart contract administration to protects both, users and developers.
 *
 * Seraph protects DEVELOPERS/OWNERS by:
 *
 * - Removing the risk of completely revoking contract ownership.
 * - Providing an incident response and notification service to facilitate easy and fast smart contract administration and operations.
 * - Separates the personal risk that comes with single key custody.
 * - Increases community and investor confidence in the security of their funds.
 *
 * Seraph protects smart contract USERS by:
 *
 * - Removing the risk of centralized administration and liquidity access.
 * - Providing third-party security oversight to validate all contract operations are legitimate
 *
 * @dev
 * Seraph does keep the Storage on a separated contract named SeraphStorage for simplicity and upgradability,
 * only code logic is present on Seraph contract
 *
 * On Seraph the initialization is taken care by the {initSeraph} function, this function will be called whenever
 * the proxy links to this logic contract To ensure that the initialize function can only be called once, a
 * simple modifier named `initializer` is used.
 *
 * When the contrat is deployed, no owner or administrative wallets are present. That means, that
 * Seraph is not operable until {initSeraph} is called.
 */
contract Seraph is SeraphStorage {

    event NewAdmin(address _old, address _new);

    event NewApprove(bytes32 _txHash);

    event NewClient(bytes32 indexed _clientId);
    event NewContract(bytes32 indexed _clientId, address _contractAddress);
    event NewFunction(bytes32 indexed _clientId, address indexed _contractAddress, bytes4 _functionSelector);

    event NewClientProtection(bytes32 indexed _clientId, bool _protected);
    event NewContractProtection(address indexed _contractAddress, bool _protected);
    event NewFunctionProtection(address indexed _contractAddress, bytes4 _functionSelector, bool _protected);

    event ApproverAdded(address indexed account);
    event ApproverRemoved(address indexed account);

    event UnprotectedExecuted(bytes32 indexed _clientId, address indexed _contractAddress, bytes4 indexed _functionSelector, bytes _callData, uint256 _value);


    /// @dev Slot used by the simulation to bypass approvals
    bytes32 private constant SIMULATION_SLOT = keccak256("SIMULATION_SLOT");

    /**
     * @notice Function used during Seraph initialisation to transfer ownership to a multisig wallet and
     * KMS administrative permissions.
     *
     * @dev Should only be callable once. The {newOwner} will be the new owner of the contract and
     * {newAdmin} will be the wallet with administrative permission on Seraph. NOTE: When the
     * contrat is deployed, no owner or administrative wallets are present. That means, that Seraph is
     * not operable until {initSeraph} is called.
     *
     * @param newOwner The owner of Seraph. It will only be allowed to change KMS admin wallet
     * @param newAdmin The KMS admin wallet. It will be allowed to administrate Seraph.
     */
    function initSeraph(address newOwner, address newAdmin) external initializer {

        require(newOwner != address(0), "Seraph: owner != 0");
        require(newAdmin != address(0), "Seraph: admin != 0");

        owner = newOwner;
        admin = newAdmin;

        emit NewAdmin(address(0), newAdmin);
    }

    //////////////////////////
    // Permission modifiers //
    //////////////////////////

    /**
     * @notice Modifier used to verify that the sender is the owner of this contract
     * Seraph ownership will be managed using a multisig wallet
     */
    modifier onlyOwner(){
        require(msg.sender == owner, "Seraph: Only owner allowed");
        _;
    }

    /**
     * @notice Modifier used to verify that the sender is the KMS administrative wallet
     */
    modifier onlySeraphAdmin(){
        require(msg.sender == admin, "Seraph: Only Seraph KMS wallet allowed");
        _;
    }

    /**
     * @notice Modifier used to verify that the sender is whitelisted as an approver
     */
    modifier onlyApprover() {
        require(_approversWhitelist[msg.sender], "Seraph: Not an approver");
        _;
    }

    /**
     * @notice Modifier used to verify that a client exists by using its {clientId} identifier.
     *
     * @param clientId The client identifier that will be checked
     */
    modifier clientExists(bytes32 clientId){
        require(_clientTracking[clientId]._isTracked, "Seraph: Client does not exist");
        _;
    }

    /**
     * @notice Modifier used to verify that a contract exists by using its {contractAddress} identifier.
     *
     * @param contractAddress The contract identifier that will be checked
     */
    modifier contractExists(address contractAddress){
        require(_contractTracking[contractAddress]._isTracked, "Seraph: Contract is not tracked");
        _;
    }

    /**
     * @notice Modifier used to verify that a function for a given contract exists by using
     * its {functionSelector} identifier and the key parent {contractAddress} identifier.
     *
     * @param contractAddress The contract where the functionSelector is supposed to live.
     * @param functionSelector The function identifier that will be checked
     */
    modifier functionExists(address contractAddress, bytes4 functionSelector){
        require(_functionTracking[contractAddress][functionSelector]._isTracked, "Seraph: Function is not tracked");
        _;
    }

    /**
     * @notice Modifier used to verify that the contract is not initialised already
     */
    modifier initializer(){
        require(!_initialised, "Seraph: Contract already initialised");
        _;
        _initialised = true;
    }

    ////////////////////////
    // Internal functions //
    ////////////////////////

    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `_isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     * @param addr The actual address to check for being a contract
     */
    function _isContract(address addr) internal view returns (bool){
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return (size > 0);
    }

    /**
     * @notice This function is used to verify if a function is protected or not. It will
     * use the parents protection to verify the full chain. If any of the parents
     * or the element itself is not protected a false is returned.
     *
     * @param contractAddress The contract were the `functionSelector` is from
     * @param functionSelector The function identifier
     * @return It will return false if any of the full chain {_isProtected} is false.
     * Returning true otherwise
     */
    function functionProtected(address contractAddress, bytes4 functionSelector) public view returns(bool){
        return (
            _functionTracking[contractAddress][functionSelector]._isProtected &&
            _contractTracking[contractAddress]._isProtected &&
            _clientTracking[_contractClient[contractAddress]]._isProtected
        );
    }

    /**
     * @notice This function is used to verify if a contract is protected or not. It will
     * use the parents protection to verify the full chain. If any of the parents
     * or the element itself is not protected a false is returned.
     *
     * @param contractAddress The contract were the `functionSelector` is from
     * @return It will return false if any of the full chain {_isProtected} is false.
     * Returning true otherwise
     */
    function contractProtected(address contractAddress) public view returns(bool){
        return (
            _contractTracking[contractAddress]._isProtected &&
            _clientTracking[_contractClient[contractAddress]]._isProtected
        );
    }

    /**
     * @notice This function is used to verify if a client is protected or not.
     *
     * @param clientId The id of the client to check
     * @return It will return true if the client is protected, false otherwise
     */
    function clientProtected(bytes32 clientId) external view returns(bool){
        return _clientTracking[clientId]._isProtected;
    }

    /**
     * @notice This function will add a contract to a given `clientId` for a given `contractAddress`. If the contract
     * already exists, it will verify the ownership using `clientId` and return
     *
     * @param clientId The client owner for this contract. If the contract exists it will be used
     * to verify ownership
     * @param contractAddress The contract address indentifier. Only one address can exist
     */
    function _addContractToClient(bytes32 clientId, address contractAddress) internal {

        require(contractAddress != address(0), "Seraph: contractAddress != 0");
        require(_isContract(contractAddress), "Seraph: not a contract");

        if (!_contractTracking[contractAddress]._isTracked) {

            Tracking storage _contract = _contractTracking[contractAddress];

            // Identifier and parent identifier
            _contract._isProtected = true;
            _contract._isTracked = true;

            _contractClient[contractAddress] = clientId;

            _clientContracts[clientId].push(contractAddress);

            emit NewContract(
                clientId,
                contractAddress);

        } else {
            require(_contractClient[contractAddress] == clientId, "Seraph: Contract is from another client");
        }

    }

    /**
     * @notice This function will add a function to a given {clientId} and {contractAddress}.
     * If the function alreay exists, nothing happens.
     *
     * @dev The function parameters must be checked for being valid or different than zero.
     * If the parameters are valid it will check if the function already exists, after validating
     * the contract, using the {functionSelector} identifier. This function should check that
     * the generated functionSelector is different than zero. Since a function is mapped on a
     * contract address no ownership verification will be performed
     *
     * @param contractAddress The contract address indentifier. Only one address can exist
     * @param functionSelector The function selector.
     */
    function _addFunctionToContract(address contractAddress, bytes4 functionSelector) internal {

        // If the function is not tracked, we will add it. Ignore otherwise
        if (!_functionTracking[contractAddress][functionSelector]._isTracked) {

            Tracking storage _function = _functionTracking[contractAddress][functionSelector];

            // Identifier and parent identifier
            _function._isProtected = true;
            _function._isTracked = true;

            _contractFunctions[contractAddress].push(functionSelector);

            emit NewFunction(
                _contractClient[contractAddress],
                contractAddress,
                functionSelector);
        }

    }


    //////////////////////
    // Getter functions //
    //////////////////////

    /**
     * @notice It will calculate the permit hash used internally to validate the calldata for a given {contractAddress}
     * and {functionSelector}. The returned value is a keccak256 of the packed {contractAddress}, {functionSelector}
     * and {callData}.
     *
     * @param contractAddress The contract address of containing the {functionSelector}
     * @param functionSelector The actual function of the permit
     * @param callData The only valid calldata that will be allowed to trigger the function (abi encoded with function selector).
     */
    function getPermitHash(address callerAddress, address contractAddress, bytes4 functionSelector, bytes memory callData, uint256 value) public pure returns(bytes32){
        return keccak256(abi.encodePacked(callerAddress, contractAddress, functionSelector, callData, value));
    }


    /**
     * @notice When the tx is send to the Seraph RPC it is simulated in order to determine what functions
     * are executed and in which order. If any of the functions do implement Seraph, the simulation would revert
     * due to the approval not being present. In order to skip the approval requiriments and the integrity check
     * validations, a READ ONLY flag under the {SIMULATION_SLOT} slot is present. This slot will be manipulated
     * during simulation to skip the validation checks.
     *
     * @return is_simulation will be set to true if the tx is being simulated
     */
    function _is_simulation() private view returns (bool is_simulation) {
        bytes32 simulation_slot = SIMULATION_SLOT;
        assembly {
            is_simulation := sload(simulation_slot)
        }
    }

    /////////////////////////
    // FE Getter functions //
    /////////////////////////

    /**
     * @notice Getter that returns a list of contracts
     *
     * @param clientId The client identifier to get the contracts from
     * @return All contracts for a given {clientId}
     */
    function getAllClientContracts(bytes32 clientId) external view returns(ContractView[] memory) {
        ContractView[] memory _contracts = new ContractView[](_clientContracts[clientId].length);
        for (uint256 i = 0; i < _clientContracts[clientId].length; i++) {
            _contracts[i]._address = _clientContracts[clientId][i];
            _contracts[i]._isProtected = contractProtected(_clientContracts[clientId][i]);
        }
        return _contracts;
    }

    /**
     * @notice Getter that returns a list of functions
     *
     * @param contractAddress The contract address to get the functions from
     * @return All functions for a given {contractAddress}
     */
    function getAllContractFunctions(address contractAddress) external view returns(FunctionView[] memory) {
        FunctionView[] memory _functions = new FunctionView[](_contractFunctions[contractAddress].length);
        for (uint256 i = 0; i < _contractFunctions[contractAddress].length; i++) {
            _functions[i]._functionSelector = _contractFunctions[contractAddress][i];
            _functions[i]._isProtected = functionProtected(contractAddress, _contractFunctions[contractAddress][i]);
        }
        return _functions;
    }

    /**
     * @notice Getter that returns a list of clients
     *
     * @return All clients on this chain
     */
    function getAllClients() external view returns(ClientView[] memory) {
        ClientView[] memory _clients_view = new ClientView[](_clients.length);
        for (uint256 i = 0; i < _clients.length; i++) {
            _clients_view[i]._id = _clients[i];
            _clients_view[i]._isProtected = _clientTracking[_clients[i]]._isProtected;
        }
        return _clients_view;
    }

    //////////////////////////////
    // Administrative functions //
    //////////////////////////////

    /**
     * @notice This functions adds a new client with a given ID as tracked and protected
     *
     * @param clientId The off-chain ID for this client
     */
    function addClient(bytes32 clientId) external onlySeraphAdmin {

        require(clientId != bytes32(0), "Seraph: Client ID != 0");

        Tracking storage _client = _clientTracking[clientId];
        require(!_client._isTracked, "Seraph: Client already exists");

        _client._isProtected = true;
        _client._isTracked = true;

        _clients.push(clientId);

        emit NewClient(clientId);
    }

    /**
     * @notice This function will add a function to a given {clientId} and {contractAddress}.
     * This is the public interface for {_addContractToClient}, {_addFunctionToContract} and
     * {_addWalletToClient} function were all the parameters are checked. Only seraph KMS admin
     * wallet can call it ({onlySeraphAdmin}).
     *
     * @dev The {clientId} should exist off-chain before calling this function.
     *
     * @param clientId The client owner for this contract. If the contract exists it will be used
     * to verify ownership
     * @param contractAddress The contract address indentifier. Only one address can exist
     * @param functionSelector The function selector.
     */
    function addContractAndFunction(bytes32 clientId, address contractAddress, bytes4 functionSelector) external onlySeraphAdmin clientExists(clientId) {

        _addContractToClient(clientId, contractAddress);

        _addFunctionToContract(contractAddress, functionSelector);

    }

    /**
     * @notice Multicall function used to operate on Seraph
     * It will be mainly used to add multiple clients/contracts/functions into the Seraph contract
     * in a single transaction.
     *
     * @param data List of Seraph functions with the calldata that will be called
     */
    function multiCall(bytes[] calldata data) external onlySeraphAdmin {
        for (uint256 i = 0; i < data.length; i++) {

            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            // functionDelegateCall from OZ
            if (!success) {
                if (result.length > 0) {
                    assembly {
                        let returndata_size := mload(result)
                        revert(add(32, result), returndata_size)
                    }
                } else {
                    revert("Failed delegatecall");
                }
            }
        }
    }

    ///////////////////////////
    // Seraph main functions //
    ///////////////////////////

    /**
     * @notice This function will generate a linked hash list of approved calls, aka permits, and store them into
     * the call stack state object of the tx.origin that generated the transaction.
     * If any of the functions that are being called is not protected, the generation of the approval for that
     * specific call will be skipped.
     *
     * This function is only callable by an approver. The approvers will be added into the system when a
     * new approver KMS key is generated on the backend system for this specific chain.
     * The key will be added using `addApprover`.
     *
     * @param txOrigin The origin of the transaction
     * @param approvalsArray A list containing (callerAddress, contractAddress, functionSelector, callData, value)
     * for each call of the approved transaction
     */
    function approve(address txOrigin, bytes[] calldata approvalsArray) external onlyApprover {

        require(approvalsArray.length > 0, "Seraph: No approvals");

        CallStackState storage _state = _callStackStates[txOrigin];

        _state.numExecuted = 0;
        _state.depth = 0;

        uint256 _toExecuteCount = 0;

        for (uint256 i = 0; i < approvalsArray.length; i++) {

            (address callerAddress, address contractAddress, bytes4 functionSelector, bytes memory callData, uint256 value) = abi.decode(approvalsArray[i], (address, address, bytes4, bytes, uint256));

            /// @dev If it is not protected we don't add an approval
            if (!functionProtected(contractAddress, functionSelector)){
                continue;
            }

            bytes32 _permitHash = getPermitHash(callerAddress, contractAddress, functionSelector, callData, value);
            _state.toExecute[_toExecuteCount] = _permitHash;
            _toExecuteCount++;
        }

        _state.toExecuteCount = _toExecuteCount;

    }

    /**
     * @notice It will verify that the calling contract and given signature is approved
     * by Halborn to be executed. If any of the hierarchy objects is not protected it will
     * return, allowing the execution to continue. This function is part of the modifier
     * that the client will need to use Seraph.
     *
     * @dev  We should be aware of all functions calling {checkEnter} thats why we need
     * to verify that the calling function exists. Verifying that the function exists
     * allows {functionProtected} to not fetch unexisting states (defaulting to false).
     * We are not checking contractExists to save some gas. functionExists does use the
     * contract address, and should exist anyway.
     *
     * @param callerAddress The address calling the protected function.
     * @param functionSelector The function identifier that will be checked. This parameter
     * is send using {msg.sig} by the Seraph modifier that the client will implement
     * @param callData The only valid calldata that will be allowed to trigger the function (abi encoded with function selector)
     * @param value The msg.value of the function call
     */
    function checkEnter(address callerAddress, bytes4 functionSelector, bytes calldata callData, uint256 value) external functionExists(msg.sender, functionSelector) {

        if (!functionProtected(msg.sender, functionSelector)){
            emit UnprotectedExecuted(
                _contractClient[msg.sender],
                msg.sender,
                functionSelector,
                callData,
                value
                );
            return;
        }

        CallStackState storage _state = _callStackStates[tx.origin];

        bytes32 _permitHash = getPermitHash(callerAddress, msg.sender, functionSelector, callData, value);

        require(_state.toExecute[_state.numExecuted] == _permitHash || _is_simulation(), "Seraph: Transaction not approved");

        /// @dev On simulation this should already be 0, we need to add ~5000 per approval when estimating gas
        /// for the NetSstoreCleanGas operation that will happen on none-simulated scenario
	    /// NetSstoreCleanGas uint64 = 5000  // Once per SSTORE operation from clean non-zero.
        _state.toExecute[_state.numExecuted] = 0;

        _state.depth++;
        _state.numExecuted++;

    }

    /**
     * @notice If any of the hierarchy objects is not protected it will
     * return, allowing the execution to continue. This is the function that will be
     * executed when retruning from an approved function call. If the function was protected
     * it will verify that the integrity for the tx.origin does mantain, and the
     * last executed call is the one present on the call stack. Furthermore, if the last call is
     * returned from, it will verify that the full call trace was executed.
     *
     * This function is part of the modifier that the client will need to use Seraph.
     *
     * @param functionSelector The function identifier that will be checked. This parameter
     * is send using {msg.sig} by the Seraph modifier that the client will implement. This is
     * only used to skip integrity checks on un-protected functions.
     */
    function checkLeave(bytes4 functionSelector) external {

        if (!functionProtected(msg.sender, functionSelector)){
            return;
        }

        CallStackState storage _state = _callStackStates[tx.origin];

        _state.depth--;

        if (_state.depth == 0) {
            require(_state.toExecuteCount == _state.numExecuted || _is_simulation(), "Seraph: Integrity check");
            /// @dev On simulation this should already be 0, we need to add ~5000 per tx when estimating gas
            /// for the NetSstoreCleanGas operation that will happen on none-simulated scenario
            /// NetSstoreCleanGas uint64 = 5000  // Once per SSTORE operation from clean non-zero.
            _state.toExecuteCount = 0;
        }

    }

    ////////////////////////////
    // Admin setter functions //
    ////////////////////////////

    /**
     * @notice It will add an approver address to the approvers whitelist
     *
     * @dev This will only be callable when creating an approver KMS key
     *
     * @param _address The address to whitelist
     */
    function addApprover(address _address) external onlySeraphAdmin {
        _approversWhitelist[_address] = true;
        emit ApproverAdded(_address);
    }

    /**
     * @notice It will remove an approver address from the approvers whitelist
     *
     * @param _address The address to remove from the whitelist
     */
    function removeApprover(address _address) external onlySeraphAdmin {
        _approversWhitelist[_address] = false;
        emit ApproverRemoved(_address);
    }

    /**
     * @notice It will change the protection state for the given {clientId} and set it
     * to {value}. Only seraph KMS admin wallet can call it ({onlySeraphAdmin}).
     * @dev Client should exist in order to change the {_isProtected} value
     *
     * @param clientId The client identifier that the protection will be changed
     * @param value The new protect state
     */
    function setClientProtected(bytes32 clientId, bool value) external onlySeraphAdmin {
        _clientTracking[clientId]._isProtected = value;
        emit NewClientProtection(clientId, value);
    }

    /**
     * @notice It will change the protection state for the given {contractAddress} and set it
     * to {value}. Only seraph KMS admin wallet can call it ({onlySeraphAdmin}).
     * @dev Contract should exist in order to change the {_isProtected} value
     *
     * @param contractAddress The contract address that the protection will be changed
     * @param value The new protect state
     */
    function setContractProtected(address contractAddress, bool value) external onlySeraphAdmin contractExists(contractAddress) {
        _contractTracking[contractAddress]._isProtected = value;
        emit NewContractProtection(contractAddress, value);
    }

    /**
     * @notice It will change the protection state for the given contract/function
     * and set it to {value}. Only seraph KMS admin wallet can call it ({onlySeraphAdmin}).
     * @dev Function should exist in order to change the {_isProtected} value
     *
     * @param contractAddress The contract address that the protection will be changed
     * @param functionSelector The function identifier that the protection will be changed
     * @param value The new protect state
     */
    function setFunctionProtected(address contractAddress, bytes4 functionSelector, bool value) external onlySeraphAdmin contractExists(contractAddress) functionExists(contractAddress, functionSelector) {
        _functionTracking[contractAddress][functionSelector]._isProtected = value;
        emit NewFunctionProtection(contractAddress, functionSelector, value);
    }

    ////////////////////////////
    // Owner setter functions //
    ////////////////////////////

    /**
     * @notice Function present in case of AWS KMS failure or migration. This allows the owner (multisig)
     * to set a new KMS admin wallet that will have privileges to add clients, contracts and functions and
     * update them.
     *
     * @param newWallet The new wallet used for administrative purpose on Seraph. Only KMS wallets should be
     * given here unless AWS KMS failure occurs.
     */
    function setAdmin(address newWallet) external onlyOwner {
        require(newWallet != address(0), "Seraph: != 0");
        emit NewAdmin(admin, newWallet);

        admin = newWallet;
    }

}



}
