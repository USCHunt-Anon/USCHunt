/**
 *Submitted for verification at arbiscan.io on 2021-11-02
*/

// File: @openzeppelin/contracts/proxy/Proxy.sol


// ////-License-Identifier: MPL-2.0
pragma solidity =0.8.9;

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

// File: @openzeppelin/contracts/proxy/beacon/IBeacon.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/utils/StorageSlot.sol


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

// File: @openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol





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

// File: @openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol




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

// File: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol



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

// File: contracts/src/common/proxy/DevProxy.sol



contract DevProxy is TransparentUpgradeableProxy {
	constructor(
		address _logic,
		address _admin,
		bytes memory _data
	) TransparentUpgradeableProxy(_logic, _admin, _data) {}
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// : MPL-2.0
pragma solidity =0.8.9;

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

// File: contracts/interface/IDevBridge.sol



interface IDevBridge {
	function mint(address _account, uint256 _amount) external returns (bool);

	function burn(address _account, uint256 _amount) external returns (bool);

	function renounceMinter() external;

	function renounceBurner() external;
}

// File: contracts/interface/IWithdraw.sol



interface IWithdraw {
	function withdraw(address _property) external;

	function beforeBalanceChange(address _from, address _to) external;

	function calculateRewardAmount(address _property, address _user)
		external
		view
		returns (
			uint256 _amount,
			uint256 _price,
			uint256 _cap,
			uint256 _allReward
		);
}

// File: contracts/interface/ILockup.sol



interface ILockup {
	struct RewardPrices {
		uint256 reward;
		uint256 holders;
		uint256 interest;
		uint256 holdersCap;
	}

	struct LockedupProperty {
		address property;
		uint256 value;
	}

	event Lockedup(
		address indexed _from,
		address indexed _property,
		uint256 _value,
		uint256 _tokenId
	);
	event Withdrew(
		address indexed _from,
		address indexed _property,
		uint256 _value,
		uint256 _reward,
		uint256 _tokenId
	);

	event UpdateCap(uint256 _cap);

	function depositToProperty(address _property, uint256 _amount)
		external
		returns (uint256);

	function depositToPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function getLockedupProperties()
		external
		view
		returns (LockedupProperty[] memory);

	function update() external;

	function withdrawByPosition(uint256 _tokenId, uint256 _amount)
		external
		returns (bool);

	function calculateCumulativeRewardPrices()
		external
		view
		returns (
			uint256 _reward,
			uint256 _holders,
			uint256 _interest,
			uint256 _holdersCap
		);

	function calculateRewardAmount(address _property)
		external
		view
		returns (uint256, uint256);

	function totalLockedForProperty(address _property)
		external
		view
		returns (uint256);

	function totalLocked() external view returns (uint256);

	function calculateWithdrawableInterestAmountByPosition(uint256 _tokenId)
		external
		view
		returns (uint256);

	function cap() external view returns (uint256);

	function updateCap(uint256 _cap) external;
}

// File: contracts/interface/IMetricsFactory.sol



interface IMetricsFactory {
	event Create(
		address indexed _market,
		address indexed _property,
		address _metrics
	);
	event Destroy(
		address indexed _market,
		address indexed _property,
		address _metrics
	);

	function create(address _property) external returns (address);

	function destroy(address _metrics) external;

	function isMetrics(address _addr) external view returns (bool);

	function metricsCount() external view returns (uint256);

	function metricsCountPerProperty(address _addr)
		external
		view
		returns (uint256);

	function metricsOfProperty(address _property)
		external
		view
		returns (address[] memory);

	function hasAssets(address _property) external view returns (bool);

	function authenticatedPropertiesCount() external view returns (uint256);
}

// File: contracts/interface/IPropertyFactory.sol



interface IPropertyFactory {
	event Create(address indexed _from, address _property);

	function create(
		string memory _name,
		string memory _symbol,
		address _author
	) external returns (address);

	function createAndAuthenticate(
		string memory _name,
		string memory _symbol,
		address _market,
		string[] memory _args
	) external returns (bool);

	function isProperty(address _addr) external view returns (bool);
}

// File: contracts/src/common/libs/Decimals.sol



/**
 * Library for emulating calculations involving decimals.
 */
library Decimals {
	uint120 private constant BASIS_VALUE = 1000000000000000000;

	/**
	 * @dev Returns the ratio of the first argument to the second argument.
	 * @param _a Numerator.
	 * @param _b Fraction.
	 * @return result Calculated ratio.
	 */
	function outOf(uint256 _a, uint256 _b)
		internal
		pure
		returns (uint256 result)
	{
		if (_a == 0) {
			return 0;
		}
		uint256 a = _a * BASIS_VALUE;
		if (a < _b) {
			return 0;
		}
		return a / _b;
	}

	/**
	 * @dev Returns multiplied the number by 10^18.
	 * @param _a Numerical value to be multiplied.
	 * @return Multiplied value.
	 */
	function mulBasis(uint256 _a) internal pure returns (uint256) {
		return _a * BASIS_VALUE;
	}

	/**
	 * @dev Returns divisioned the number by 10^18.
	 * This function can use it to restore the number of digits in the result of `outOf`.
	 * @param _a Numerical value to be divisioned.
	 * @return Divisioned value.
	 */
	function divBasis(uint256 _a) internal pure returns (uint256) {
		return _a / BASIS_VALUE;
	}
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


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

// File: contracts/interface/IAddressRegistry.sol



interface IAddressRegistry {
	function setRegistry(string memory _key, address _addr) external;

	function registries(string memory _key) external view returns (address);
}

// File: contracts/src/common/registry/InitializableUsingRegistry.sol





/**
 * Module for using AddressRegistry contracts.
 */
abstract contract InitializableUsingRegistry is Initializable {
	address private _registry;

	/**
	 * Initialize the argument as AddressRegistry address.
	 */
	/* solhint-disable func-name-mixedcase */
	function __UsingRegistry_init(address _addressRegistry)
		internal
		initializer
	{
		_registry = _addressRegistry;
	}

	/**
	 * Returns the latest AddressRegistry instance.
	 */
	function registry() internal view returns (IAddressRegistry) {
		return IAddressRegistry(_registry);
	}

	/**
	 * Returns the AddressRegistry address.
	 */
	function registryAddress() external view returns (address) {
		return _registry;
	}
}

// File: contracts/src/withdraw/Withdraw.sol











/**
 * A contract that manages the withdrawal of holder rewards for Property holders.
 */
contract Withdraw is InitializableUsingRegistry, IWithdraw {
	mapping(address => mapping(address => uint256))
		public lastWithdrawnRewardPrice; // {Property: {User: Value}} // From [get/set]StorageLastWithdrawnReward
	mapping(address => mapping(address => uint256))
		public lastWithdrawnRewardCapPrice; // {Property: {User: Value}} // From [get/set]PendingWithdrawal
	mapping(address => mapping(address => uint256)) public pendingWithdrawal; // {Property: {User: Value}}
	mapping(address => uint256) public cumulativeWithdrawnReward; // {Property: Value} // From [get/set]RewardsAmount

	using Decimals for uint256;

	/**
	 * Initialize the passed address as AddressRegistry address.
	 */
	function initialize(address _registry) external initializer {
		__UsingRegistry_init(_registry);
	}

	/**
	 * Withdraws rewards.
	 */
	function withdraw(address _property) external override {
		/**
		 * Validate
		 * the passed Property address is included the Property address set.
		 */
		require(
			IPropertyFactory(registry().registries("PropertyFactory"))
				.isProperty(_property),
			"this is illegal address"
		);

		/**
		 * Gets the withdrawable rewards amount and the latest cumulative sum of the maximum mint amount.
		 */
		(
			uint256 value,
			uint256 lastPrice,
			uint256 lastPriceCap,

		) = _calculateWithdrawableAmount(_property, msg.sender);

		/**
		 * Validates the result is not 0.
		 */
		require(value != 0, "withdraw value is 0");

		/**
		 * Saves the latest cumulative sum of the holder reward price.
		 * By subtracting this value when calculating the next rewards, always withdrawal the difference from the previous time.
		 */
		lastWithdrawnRewardPrice[_property][msg.sender] = lastPrice;
		lastWithdrawnRewardCapPrice[_property][msg.sender] = lastPriceCap;

		/**
		 * Sets the number of unwithdrawn rewards to 0.
		 */
		pendingWithdrawal[_property][msg.sender] = 0;

		/**
		 * Mints the holder reward.
		 */
		require(
			IDevBridge(registry().registries("DevBridge")).mint(
				msg.sender,
				value
			),
			"dev mint failed"
		);

		/**
		 * Since the total supply of tokens has changed, updates the latest maximum mint amount.
		 */
		ILockup lockup = ILockup(registry().registries("Lockup"));
		lockup.update();

		/**
		 * Adds the reward amount already withdrawn in the passed Property.
		 */
		cumulativeWithdrawnReward[_property] =
			cumulativeWithdrawnReward[_property] +
			value;
	}

	/**
	 * Updates the change in compensation amount due to the change in the ownership ratio of the passed Property.
	 * When the ownership ratio of Property changes, the reward that the Property holder can withdraw will change.
	 * It is necessary to update the status before and after the ownership ratio changes.
	 */
	function beforeBalanceChange(address _from, address _to) external override {
		/**
		 * Validates the sender is Allocator contract.
		 */
		require(
			IPropertyFactory(registry().registries("PropertyFactory"))
				.isProperty(msg.sender),
			"this is illegal address"
		);

		/**
		 * Gets the cumulative sum of the transfer source's "before transfer" withdrawable reward amount and the cumulative sum of the maximum mint amount.
		 */
		(
			uint256 amountFrom,
			uint256 priceFrom,
			uint256 priceCapFrom,

		) = _calculateAmount(msg.sender, _from);

		/**
		 * Gets the cumulative sum of the transfer destination's "before receive" withdrawable reward amount and the cumulative sum of the maximum mint amount.
		 */
		(
			uint256 amountTo,
			uint256 priceTo,
			uint256 priceCapTo,

		) = _calculateAmount(msg.sender, _to);

		/**
		 * Updates the last cumulative sum of the maximum mint amount of the transfer source and destination.
		 */
		lastWithdrawnRewardPrice[msg.sender][_from] = priceFrom;
		lastWithdrawnRewardPrice[msg.sender][_to] = priceTo;
		lastWithdrawnRewardCapPrice[msg.sender][_from] = priceCapFrom;
		lastWithdrawnRewardCapPrice[msg.sender][_to] = priceCapTo;

		/**
		 * Gets the unwithdrawn reward amount of the transfer source and destination.
		 */
		uint256 pendFrom = pendingWithdrawal[msg.sender][_from];
		uint256 pendTo = pendingWithdrawal[msg.sender][_to];

		/**
		 * Adds the undrawn reward amount of the transfer source and destination.
		 */
		pendingWithdrawal[msg.sender][_from] = pendFrom + amountFrom;
		pendingWithdrawal[msg.sender][_to] = pendTo + amountTo;
	}

	/**
	 * Returns the holder reward.
	 */
	function _calculateAmount(address _property, address _user)
		private
		view
		returns (
			uint256 _amount,
			uint256 _price,
			uint256 _cap,
			uint256 _allReward
		)
	{
		ILockup lockup = ILockup(registry().registries("Lockup"));
		/**
		 * Gets the latest reward.
		 */
		(uint256 reward, uint256 cap) = lockup.calculateRewardAmount(_property);

		/**
		 * Gets the cumulative sum of the holder reward price recorded the last time you withdrew.
		 */

		uint256 allReward = _calculateAllReward(_property, _user, reward);
		uint256 capped = _calculateCapped(_property, _user, cap);
		uint256 value = capped == 0 ? allReward : allReward <= capped
			? allReward
			: capped;

		/**
		 * Returns the result after adjusted decimals to 10^18, and the latest cumulative sum of the holder reward price.
		 */
		return (value, reward, cap, allReward);
	}

	/**
	 * Return the reward cap
	 */
	function _calculateCapped(
		address _property,
		address _user,
		uint256 _cap
	) private view returns (uint256) {
		/**
		 * Gets the cumulative sum of the holder reward price recorded the last time you withdrew.
		 */
		uint256 _lastRewardCap = lastWithdrawnRewardCapPrice[_property][_user];
		IERC20 property = IERC20(_property);
		uint256 balance = property.balanceOf(_user);
		uint256 totalSupply = property.totalSupply();
		uint256 unitPriceCap = (_cap - _lastRewardCap) / totalSupply;
		return (unitPriceCap * balance).divBasis();
	}

	/**
	 * Return the reward
	 */
	function _calculateAllReward(
		address _property,
		address _user,
		uint256 _reward
	) private view returns (uint256) {
		/**
		 * Gets the cumulative sum of the holder reward price recorded the last time you withdrew.
		 */
		uint256 _lastReward = lastWithdrawnRewardPrice[_property][_user];
		IERC20 property = IERC20(_property);
		uint256 balance = property.balanceOf(_user);
		uint256 totalSupply = property.totalSupply();
		uint256 unitPrice = ((_reward - _lastReward).mulBasis()) / totalSupply;
		return (unitPrice * balance).divBasis().divBasis();
	}

	/**
	 * Returns the total rewards currently available for withdrawal. (For calling from inside the contract)
	 */
	function _calculateWithdrawableAmount(address _property, address _user)
		private
		view
		returns (
			uint256 _amount,
			uint256 _price,
			uint256 _cap,
			uint256 _allReward
		)
	{
		/**
		 * Gets the latest withdrawal reward amount.
		 */
		(
			uint256 _value,
			uint256 price,
			uint256 cap,
			uint256 allReward
		) = _calculateAmount(_property, _user);

		/**
		 * If the passed Property has not authenticated, returns always 0.
		 */
		if (
			IMetricsFactory(registry().registries("MetricsFactory")).hasAssets(
				_property
			) == false
		) {
			return (0, price, cap, 0);
		}

		/**
		 * Gets the reward amount in saved without withdrawal and returns the sum of all values.
		 */
		uint256 value = _value + pendingWithdrawal[_property][_user];
		return (value, price, cap, allReward);
	}

	/**
	 * Returns the rewards amount
	 */
	function calculateRewardAmount(address _property, address _user)
		external
		view
		override
		returns (
			uint256 _amount,
			uint256 _price,
			uint256 _cap,
			uint256 _allReward
		)
	{
		return _calculateWithdrawableAmount(_property, _user);
	}
}