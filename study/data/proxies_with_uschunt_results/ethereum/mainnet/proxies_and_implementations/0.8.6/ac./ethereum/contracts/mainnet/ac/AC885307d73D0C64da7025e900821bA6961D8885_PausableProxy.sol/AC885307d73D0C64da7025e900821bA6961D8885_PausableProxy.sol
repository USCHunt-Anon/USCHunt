



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

//import "../beacon/IBeacon.sol";
//import "../../utils/Address.sol";
//import "../../utils/StorageSlot.sol";

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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

//import "../Proxy.sol";
//import "./ERC1967Upgrade.sol";

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

//import "../ERC1967/ERC1967Proxy.sol";

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












// ////-License-Identifier: MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';

contract PausableProxy is TransparentUpgradeableProxy {
    //
    //                      _              _
    //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
    //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
    // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
    //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
    //

    bytes32 internal constant _PAUSED_SLOT = 0x8dea8703c3cf94703383ce38a9c894669dccd4ca8e65ddb43267aa0248711450;

    //
    //  _       _                        _
    // (_)_ __ | |_ ___ _ __ _ __   __ _| |___
    // | | '_ \| __/ _ \ '__| '_ \ / _` | / __|
    // | | | | | ||  __/ |  | | | | (_| | \__ \
    // |_|_| |_|\__\___|_|  |_| |_|\__,_|_|___/
    //

    function _beforeFallback() internal virtual override {
        // remove the check that prevents admins from using the fallback
    }

    //
    //            _                        _
    //   _____  _| |_ ___ _ __ _ __   __ _| |___
    //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
    // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
    //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
    //

    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) payable TransparentUpgradeableProxy(_logic, _admin, _data) {}

    /// @dev Retrieves Paused state
    /// @return Paused state
    function isPaused() external view returns (bool) {
        return StorageSlot.getBooleanSlot(_PAUSED_SLOT).value;
    }

    /// @dev Pauses system
    function pause() external ifAdmin {
        StorageSlot.getBooleanSlot(_PAUSED_SLOT).value = true;
    }

    /// @dev Unpauses system
    function unpause() external ifAdmin {
        StorageSlot.getBooleanSlot(_PAUSED_SLOT).value = false;
    }
}


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
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


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// : MIT

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}


// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';

abstract contract Adapter {
    //
    //  _       _                        _
    // (_)_ __ | |_ ___ _ __ _ __   __ _| |___
    // | | '_ \| __/ _ \ '__| '_ \ / _` | / __|
    // | | | | | ||  __/ |  | | | | (_| | \__ \
    // |_|_| |_|\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @dev Perform an internal option purchase
    /// @param caller Address purchasing the option
    /// @param currencies List of usable currencies
    /// @param amounts List of usable currencies amounts
    /// @param data Extra data usable by adapter
    /// @return A tuple containing used amounts and output data
    function purchase(
        address caller,
        address[] memory currencies,
        uint256[] memory amounts,
        bytes calldata data
    ) internal virtual returns (uint256[] memory, bytes memory);

    function _preparePayment(address[] memory currencies, uint256[] memory amounts) internal {
        require(currencies.length == amounts.length, 'A2');
        for (uint256 currencyIdx = 0; currencyIdx < currencies.length; ++currencyIdx) {
            if (currencies[currencyIdx] == address(0)) {
                require(msg.value >= amounts[currencyIdx], 'A1');
            } else {
                require(
                    IERC20(currencies[currencyIdx]).transferFrom(msg.sender, address(this), amounts[currencyIdx]),
                    'A2'
                );
            }
        }
    }

    //
    //            _                        _
    //   _____  _| |_ ___ _ __ _ __   __ _| |___
    //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
    // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
    //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @dev Perform an option purchase
    /// @param caller Address purchasing the option
    /// @param currencies List of usable currencies
    /// @param amounts List of usable currencies amounts
    /// @param data Extra data usable by adapter
    /// @return A tuple containing used amounts and output data
    function run(
        address caller,
        address[] memory currencies,
        uint256[] memory amounts,
        bytes calldata data
    ) external payable returns (uint256[] memory, bytes memory) {
        _preparePayment(currencies, amounts);
        return purchase(caller, currencies, amounts, data);
    }

    function name() external view virtual returns (string memory);
}


// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

contract Versioned {
    //
    //      _        _
    //  ___| |_ __ _| |_ ___
    // / __| __/ _` | __/ _ \
    // \__ \ || (_| | ||  __/
    // |___/\__\__,_|\__\___|
    //

    // Stores the current implementation version
    uint256 version;

    // Stores the initializing state for each version
    bool private _initializing;

    //
    //                      _ _  __ _
    //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
    // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
    // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
    // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
    //

    // Allows to be called only if version number is current version + 1
    modifier initVersion(uint256 _version) {
        require(!_initializing, 'V1');
        require(_version == version + 1, 'V2');
        version = _version;

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    //
    //            _                        _
    //   _____  _| |_ ___ _ __ _ __   __ _| |___
    //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
    // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
    //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @dev Retrieves current implementation version
    /// @return Implementatiomn version
    function getVersion() public view returns (uint256) {
        return version;
    }
}


// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/utils/StorageSlot.sol';

contract Pausable {
    //
    //                      _              _
    //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
    //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
    // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
    //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
    //

    // Storage slot for the Paused state
    bytes32 internal constant _PAUSED_SLOT = 0x8dea8703c3cf94703383ce38a9c894669dccd4ca8e65ddb43267aa0248711450;

    //
    //                      _ _  __ _
    //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
    // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
    // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
    // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
    //

    // Allows methods to be called if paused
    modifier whenPaused() {
        require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == true, 'P1');
        _;
    }

    // Allows methods to be called if not paused
    modifier whenNotPaused() {
        require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == false, 'P1');
        _;
    }
}


// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/utils/StorageSlot.sol';

contract Owned {
    //
    //                      _              _
    //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
    //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
    // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
    //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
    //

    // Storage slot for the Admin address
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    //
    //                      _ _  __ _
    //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
    // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
    // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
    // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
    //

    // Modifier allowing only admins to call methods
    modifier isAdmin() {
        require(StorageSlot.getAddressSlot(_ADMIN_SLOT).value == msg.sender, 'O1');
        _;
    }

    //
    //            _                        _
    //   _____  _| |_ ___ _ __ _ __   __ _| |___
    //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
    // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
    //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @dev Retrieves Admin address
    /// @return Admin address
    function getAdmin() public view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }
}


// : MIT

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


// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
//import'@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol';
//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';
//import'@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';

//import'../adapters/Adapter.sol';
//import'../Versioned.sol';
//import'../Pausable.sol';
//import'../Owned.sol';

/// @title GatewayV1
/// @author Iulian Rotaru
/// @notice The Gateway aggregates all adapters and helps users performs multiple actions at the same time.
contract GatewayV1 is Versioned, Pausable, Owned, ReentrancyGuardUpgradeable {
    //
    //                      _              _
    //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
    //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
    // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
    //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
    //

    // Denominator used with fee variable to compute amount kept by the gateway.
    uint256 constant FEE_DENOMINATOR = 1000000;
    //
    //      _        _
    //  ___| |_ __ _| |_ ___
    // / __| __/ _` | __/ _ \
    // \__ \ || (_| | ||  __/
    // |___/\__\__,_|\__\___|
    //

    // Store all adapters. Adapters perform purchasing logics for each supported platforms
    mapping(string => Adapter) public adapters;

    // Store all collected fees.
    mapping(address => uint256) public collectedFees;

    // Fee value.
    uint256 public fee;

    // Fee collector
    address public feeCollector;

    //
    //                       _
    //   _____   _____ _ __ | |_ ___
    //  / _ \ \ / / _ \ '_ \| __/ __|
    // |  __/\ V /  __/ | | | |_\__ \
    //  \___| \_/ \___|_| |_|\__|___/
    //

    // Emitted whenever an adapter is changed
    event AdapterChanged(string indexed actionType, address indexed adapter, address oldAdapter, address admin);

    // Emitted whenever a product is purchased
    event ExecutedAction(
        string indexed actionType,
        address indexed caller,
        address[] currencies,
        uint256[] amounts,
        uint256[] fees,
        bytes data,
        bytes outputData
    );

    //
    //      _                   _
    //  ___| |_ _ __ _   _  ___| |_ ___
    // / __| __| '__| | | |/ __| __/ __|
    // \__ \ |_| |  | |_| | (__| |_\__ \
    // |___/\__|_|   \__,_|\___|\__|___/
    //
    //

    // Input format
    struct Action {
        string actionType;
        address[] currencies;
        uint256[] amounts;
        bytes data;
    }

    //
    //                      _ _  __ _
    //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
    // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
    // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
    // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
    //

    // Check that caller is fee collector
    modifier isFeeCollector() {
        require(msg.sender == feeCollector, 'G9');
        _;
    }

    //
    //  _       _                        _
    // (_)_ __ | |_ ___ _ __ _ __   __ _| |___
    // | | '_ \| __/ _ \ '__| '_ \ / _` | / __|
    // | | | | | ||  __/ |  | | | | (_| | \__ \
    // |_|_| |_|\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @dev Retrieves the available balance for all used currencies.
    ///      Simply computes current effective balance and substract collected fees
    /// @param currencies Address of currencies
    /// @return A tuple with the raw current balances and usable balances
    function _getAvailableBalance(address[] memory currencies)
        internal
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory currentBalances = new uint256[](currencies.length);
        uint256[] memory availableBalances = new uint256[](currencies.length);
        for (uint256 idx = 0; idx < currencies.length; ++idx) {
            uint256 balance = _getBalance(currencies[idx]);
            currentBalances[idx] = balance;
            availableBalances[idx] = balance - collectedFees[currencies[idx]];
        }
        return (currentBalances, availableBalances);
    }

    /// @dev Retrieves the available balance for one currency.
    /// @param currency Address of the currency
    /// @return The current balance of the provided currency
    function _getBalance(address currency) internal view returns (uint256) {
        if (currency == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(currency).balanceOf(address(this));
        }
    }

    /// @dev Prepares adapter call by approving or computing amount of eth to send with call.
    ///      Also computes extracted fee.
    /// @param currencies List of currencies to send/approve
    /// @param amounts Amounts of currencies to send/approve
    /// @param adapter Address of adapter receiving the call
    /// @return A tuple containing the amount of eth to send during call, the amounts without the extracted fee and the extracted fees
    function _transferAndGetAmount(
        address[] memory currencies,
        uint256[] memory amounts,
        Adapter adapter
    )
        internal
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256[] memory amountsWithoutFees = new uint256[](amounts.length);
        uint256[] memory extractedFees = new uint256[](amounts.length);
        uint256 callValue = 0;
        for (uint256 idx; idx < currencies.length; ++idx) {
            amountsWithoutFees[idx] = (amounts[idx] * FEE_DENOMINATOR) / (FEE_DENOMINATOR + fee) + 1;
            extractedFees[idx] = amounts[idx] - amountsWithoutFees[idx];

            collectedFees[currencies[idx]] += extractedFees[idx];

            if (currencies[idx] == address(0)) {
                callValue = amountsWithoutFees[idx];
            } else {
                IERC20(currencies[idx]).approve(address(adapter), amountsWithoutFees[idx]);
            }
        }

        return (callValue, amountsWithoutFees, extractedFees);
    }

    /// @dev Retrieves all currencies for all actions provided on an execute call. If multiple actions, factorizes calls.
    /// @param actions list of received actions
    function _pull(Action[] calldata actions) internal {
        if (actions.length > 1) {
            uint256 totalCurrencies = 0;
            for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
                Action memory action = actions[actionIdx];
                totalCurrencies += action.amounts.length;
                require(action.amounts.length == action.currencies.length, 'G1');
            }
            uint256[] memory totalAmounts = new uint256[](totalCurrencies);
            address[] memory currencies = new address[](totalCurrencies);
            for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
                Action memory action = actions[actionIdx];
                for (uint256 currencyIdx = 0; currencyIdx < action.amounts.length; ++currencyIdx) {
                    if (action.currencies[currencyIdx] == address(0)) {
                        continue;
                    }
                    for (uint256 storedIdx; storedIdx < currencies.length; ++storedIdx) {
                        if (currencies[storedIdx] == action.currencies[currencyIdx]) {
                            totalAmounts[storedIdx] += action.amounts[currencyIdx];
                            break;
                        } else if (currencies[storedIdx] == address(0)) {
                            currencies[storedIdx] = action.currencies[currencyIdx];
                            totalAmounts[storedIdx] += action.amounts[currencyIdx];
                            break;
                        }
                    }
                }
            }
            for (
                uint256 currencyIdx = 0;
                currencyIdx < currencies.length && currencies[currencyIdx] != address(0);
                ++currencyIdx
            ) {
                IERC20(currencies[currencyIdx]).transferFrom(msg.sender, address(this), totalAmounts[currencyIdx]);
            }
        } else {
            require(actions[0].amounts.length == actions[0].currencies.length, 'G2');
            for (uint256 idx = 0; idx < actions[0].currencies.length; ++idx) {
                if (actions[0].currencies[idx] != address(0)) {
                    IERC20(actions[0].currencies[idx]).transferFrom(msg.sender, address(this), actions[0].amounts[idx]);
                }
            }
        }
    }

    //
    //            _                        _
    //   _____  _| |_ ___ _ __ _ __   __ _| |___
    //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
    // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
    //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
    //

    /// @notice Send an array of actions you want to execute from the gateway
    /// @param actions List of actions to execute
    function execute(Action[] calldata actions) external payable nonReentrant whenNotPaused {
        _pull(actions);
        for (uint256 actionIdx = 0; actionIdx < actions.length; ++actionIdx) {
            Action memory action = actions[actionIdx];

            (uint256[] memory preBalances, uint256[] memory availableBalances) = _getAvailableBalance(
                action.currencies
            );

            for (uint256 idx = 0; idx < action.amounts.length; ++idx) {
                require(availableBalances[idx] >= action.amounts[idx], 'G3');
            }

            Adapter adapter = adapters[action.actionType];

            require(address(adapter) != address(0), 'G4');

            (
                uint256 callValue,
                uint256[] memory amountsWithoutFees,
                uint256[] memory extractedFees
            ) = _transferAndGetAmount(action.currencies, action.amounts, adapter);

            (uint256[] memory usedAmount, bytes memory outputData) = adapter.run{value: callValue}(
                msg.sender,
                action.currencies,
                amountsWithoutFees,
                action.data
            );

            for (uint256 idx = 0; idx < action.currencies.length; ++idx) {
                uint256 postBalance = _getBalance(action.currencies[idx]);
                if (postBalance > preBalances[idx] - amountsWithoutFees[idx]) {
                    if (action.currencies[idx] == address(0)) {
                        (bool success, ) = payable(msg.sender).call{
                            value: postBalance - (preBalances[idx] - amountsWithoutFees[idx])
                        }('');
                        require(success, 'G5');
                    } else {
                        IERC20(action.currencies[idx]).transfer(
                            msg.sender,
                            postBalance - (preBalances[idx] - amountsWithoutFees[idx])
                        );
                    }
                }
            }

            emit ExecutedAction(
                action.actionType,
                msg.sender,
                action.currencies,
                usedAmount,
                extractedFees,
                action.data,
                outputData
            );
        }
    }

    /// @notice Register a new address as an adapter
    /// @param actionType Name of the action
    /// @param adapter Address of the new adapter
    function registerAdapter(string calldata actionType, address adapter) external isAdmin {
        require(AddressUpgradeable.isContract(adapter), 'G6');
        require(adapters[actionType] != Adapter(adapter), 'G7');

        emit AdapterChanged(actionType, adapter, address(adapters[actionType]), Owned.getAdmin());

        adapters[actionType] = Adapter(adapter);
    }

    /// @notice Changes the address able to collect fees
    /// @param newFeeCollector Address able to collect fees
    function setFeeCollector(address newFeeCollector) external isAdmin {
        require(newFeeCollector != feeCollector, 'G8');
        feeCollector = newFeeCollector;
    }

    /// @notice Withdraws collected fees by providing currency addresses to withdraw
    /// @param currencies List of currencies to withdraw
    /// @return List of withdrawn amounts
    function withdrawCollectedFees(address[] memory currencies) external isFeeCollector returns (uint256[] memory) {
        uint256[] memory withdrawnFees = new uint256[](currencies.length);
        for (uint256 idx = 0; idx < currencies.length; ++idx) {
            if (currencies[idx] == address(0)) {
                (bool success, ) = feeCollector.call{value: collectedFees[currencies[idx]]}('');
                require(success, 'G10');
            } else {
                IERC20(currencies[idx]).transfer(feeCollector, collectedFees[currencies[idx]]);
            }
            withdrawnFees[idx] = collectedFees[currencies[idx]];
            collectedFees[currencies[idx]] = 0;
        }
        return withdrawnFees;
    }

    //
    //  _       _ _
    // (_)_ __ (_) |_
    // | | '_ \| | __|
    // | | | | | | |_
    // |_|_| |_|_|\__|
    //

    function __GatewayV1__constructor() public initVersion(1) {
        fee = 1000;
        feeCollector = getAdmin();
    }
}



}
