// Sources flattened with hardhat v2.8.2 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.1

// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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


// File @openzeppelin/contracts/utils/Address.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/proxy/beacon/IBeacon.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

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


// File @openzeppelin/contracts/utils/StorageSlot.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

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


// File @openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Upgrade.sol)

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


// File @openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol@v4.4.1


// OpenZeppelin Contracts v4.4.1 (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is ERC1967Upgrade {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
}


// File contracts/upgrade/Owned.sol


pragma solidity ^0.8.0;

// Modified from https://docs.synthetix.io/contracts/source/contracts/owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    /// @dev Change constructor to initialize function for upgradeable contract
    function initializeOwner(address _owner) internal {
        require(owner == address(0), "Already initialized");
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


// File contracts/upgrade/Pausable.sol


pragma solidity ^0.8.0;

// Modified from https://docs.synthetix.io/contracts/source/contracts/pausable
contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    /// @dev Change constructor to initialize function for upgradeable contract
    function initializePausable(address _owner) internal {
        super.initializeOwner(_owner);

        require(owner != address(0), "Owner must be set");
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = block.timestamp;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


// File contracts/upgrade/ReentrancyGuard.sol


pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    /// @dev Change constructor to initialize function for upgradeable contract
    function initializeReentrancyGuard() internal {
        require(_guardCounter == 0, "Already initialized");
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


// File contracts/interfaces/IDepositCompound.sol


pragma solidity >=0.5.0 <0.9.0;

// Curve DepositCompound contract interface
interface IDepositCompound {
    function underlying_coins(int128 arg0) external view returns (address);

    function token() external view returns (address);

    function add_liquidity(uint256[2] calldata uamounts, uint256 min_mint_amount) external;

    function remove_liquidity(uint256 _amount, uint256[2] calldata min_uamounts) external;

    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 min_uamount, bool donate_dust) external;
}


// File contracts/interfaces/IConvexBaseRewardPool.sol

pragma solidity >=0.5.0 <0.9.0;

interface IConvexBaseRewardPool {
    // Views

    function rewards(address account) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function stakingToken() external view returns (address);

    function rewardToken() external view returns (address);

    function totalSupply() external view returns (uint256);

    // Mutative

    function getReward(address _account, bool _claimExtras) external returns (bool);

    function stake(uint256 _amount) external returns (bool);

    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external returns (bool);

    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);

    function withdrawAllAndUnwrap(bool claim) external returns (bool);
}


// File contracts/interfaces/IConvexBooster.sol

pragma solidity >=0.5.0 <0.9.0;

interface IConvexBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }
    function poolInfo(uint256 _pid) view external returns (PoolInfo memory);

    function crv() external view returns (address);

    function minter() external view returns (address);

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);

    function depositAll(uint256 _pid, bool _stake) external returns(bool);
}


// File contracts/interfaces/IPancakePair.sol

pragma solidity >=0.5.0 <0.9.0;

interface IPancakePair {
    function token0() external returns (address);
    function token1() external returns (address);
}


// File contracts/interfaces/IConverterUniV3.sol

pragma solidity >=0.5.0 <0.9.0;

interface IConverterUniV3 {
    function NATIVE_TOKEN() external view returns (address);

    function convert(
        address _inTokenAddress,
        uint256 _amount,
        uint256 _convertPercentage,
        address _outTokenAddress,
        uint256 _minReceiveAmount,
        address _recipient
    ) external;

    function convertAndAddLiquidity(
        address _inTokenAddress,
        uint256 _amount,
        address _outTokenAddress,
        uint256 _minReceiveAmountSwap,
        uint256 _minInTokenAmountAddLiq,
        uint256 _minOutTokenAmountAddLiq,
        address _recipient
    ) external;

    function removeLiquidityAndConvert(
        IPancakePair _lp,
        uint256 _lpAmount,
        uint256 _minToken0Amount,
        uint256 _minToken1Amount,
        uint256 _token0Percentage,
        address _recipient
    ) external;

    function convertUniV3(
        address _inTokenAddress,
        uint256 _amount,
        uint256 _convertPercentage,
        address _outTokenAddress,
        uint256 _minReceiveAmount,
        address _recipient,
        bytes memory _path
    ) external;
}


// File contracts/interfaces/IWeth.sol

pragma solidity >=0.7.0;

interface IWETH {
    function balanceOf(address account) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}


// File contracts/curve_convex_farm/StakeCurveConvex.sol

pragma solidity ^0.8.0;










// Modified from https://docs.synthetix.io/contracts/source/contracts/stakingrewards
/// @title A wrapper contract over Convex Booster and BaseRewardPool contract that allows single asset in/out.
/// 1. User provide token0 or token1
/// 2. contract converts half to the other token and provide liquidity on Curve
/// 3. stake LP token via Convex Booster contract
/// @dev Be aware that staking entry is Convex Booster contract while withdraw/getReward entry is BaseRewardPool contract.
/// @notice Asset tokens are token0 and token1. Staking token is the LP token of token0/token1.
contract StakeCurveConvex is ReentrancyGuard, Pausable, UUPSUpgradeable {
    using SafeERC20 for IERC20;

    struct BalanceDiff {
        uint256 balBefore;
        uint256 balAfter;
        uint256 balDiff;
    }

    /* ========== STATE VARIABLES ========== */

    string public name;
    uint256 public pid; // Pool ID in Convex Booster
    IConverterUniV3 public converter;
    IERC20 public lp;
    IERC20 public token0;
    IERC20 public token1;
    IERC20 public crv;
    IERC20 public cvx;
    IERC20 public BCNT;

    IDepositCompound public curveDepositCompound;
    IConvexBooster public convexBooster;
    IConvexBaseRewardPool public convexBaseRewardPool;

    /// @dev Piggyback on BaseRewardPool' reward accounting
    mapping(address => uint256) internal _userRewardPerTokenPaid;
    mapping(address => uint256) internal _rewards;

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;

    uint256 public bcntRewardAmount;
    address public operator;

    bytes public cvxToBCNTUniV3SwapPath; // e.g., CVX -> WETH -> BCNT
    bytes public crvToBCNTUniV3SwapPath; // e.g., CRV -> WETH -> BCNT

    /* ========== FALLBACKS ========== */

    receive() external payable {}

    /* ========== CONSTRUCTOR ========== */

    function initialize(
        string memory _name,
        uint256 _pid,
        address _owner,
        address _operator,
        IConverterUniV3 _converter,
        address _curveDepositCompound,
        address _convexBooster,
        address _convexBaseRewardPool,
        address _BCNT
    ) external {
        require(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("")), "Already initialized");
        super.initializePausable(_owner);
        super.initializeReentrancyGuard();

        name = _name;
        pid = _pid;
        operator = _operator;
        converter = _converter;
        curveDepositCompound = IDepositCompound(_curveDepositCompound);
        lp = IERC20(curveDepositCompound.token());
        token0 = IERC20(curveDepositCompound.underlying_coins(0));
        token1 = IERC20(curveDepositCompound.underlying_coins(1));
        convexBooster = IConvexBooster(_convexBooster);
        convexBaseRewardPool = IConvexBaseRewardPool(_convexBaseRewardPool);
        crv = IERC20(convexBaseRewardPool.rewardToken());
        require(address(convexBooster.crv()) == address(crv));
        cvx = IERC20(convexBooster.minter());
        BCNT = IERC20(_BCNT);
    }

    /* ========== VIEWS ========== */

    /// @dev Get the implementation contract of this proxy contract.
    /// Only to be used on the proxy contract. Otherwise it would return zero address.
    function implementation() external view returns (address) {
        return _getImplementation();
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /// @notice Get the reward share earned by specified account.
    function _share(address account) public view returns (uint256) {
        uint256 rewardPerToken = convexBaseRewardPool.rewardPerToken();
        return (_balances[account] * (rewardPerToken - _userRewardPerTokenPaid[account]) / (1e18)) + _rewards[account];
    }

    /// @notice Get the total reward share in this contract.
    /// @notice Total reward is tracked with `_rewards[address(this)]` and `_userRewardPerTokenPaid[address(this)]`
    function _shareTotal() public view returns (uint256) {
        uint256 rewardPerToken = convexBaseRewardPool.rewardPerToken();
        return (_totalSupply * (rewardPerToken - _userRewardPerTokenPaid[address(this)]) / (1e18)) + _rewards[address(this)];
    }

    /// @notice Get the compounded LP amount earned by specified account.
    function earned(address account) public view returns (uint256) {
        uint256 rewardsShare;
        if (account == address(this)){
            rewardsShare = _shareTotal();
        } else {
            rewardsShare = _share(account);
        }

        uint256 earnedCompoundedLPAmount;
        if (rewardsShare > 0) {
            uint256 totalShare = _shareTotal();
            // Earned compounded LP amount is proportional to how many rewards this account has
            // among total rewards
            earnedCompoundedLPAmount = bcntRewardAmount * rewardsShare / totalShare;
        }
        return earnedCompoundedLPAmount;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _convertAndAddLiquidity(
        bool isToken0,
        bool shouldTransferFromSender, 
        uint256 amount,
        uint256 minLiqAddedAmount
    ) internal returns (uint256 lpAmount) {
        require(amount > 0, "Cannot stake 0");
        uint256 lpAmountBefore = lp.balanceOf(address(this));
        uint256 token0AmountBefore = token0.balanceOf(address(this));
        uint256 token1AmountBefore = token1.balanceOf(address(this));

        // Add liquidity
        uint256[2] memory uamounts;
        if (isToken0) {
            if (shouldTransferFromSender) {
                token0.safeTransferFrom(msg.sender, address(this), amount);
            }
            uamounts[0] = amount;
            uamounts[1] = 0;
            token0.safeApprove(address(curveDepositCompound), amount);
            curveDepositCompound.add_liquidity(uamounts, minLiqAddedAmount);
        } else {
            if (shouldTransferFromSender) {
                token1.safeTransferFrom(msg.sender, address(this), amount);
            }
            uamounts[0] = 0;
            uamounts[1] = amount;
            token1.safeApprove(address(curveDepositCompound), amount);
            curveDepositCompound.add_liquidity(uamounts, minLiqAddedAmount);
        }

        uint256 lpAmountAfter = lp.balanceOf(address(this));
        uint256 token0AmountAfter = token0.balanceOf(address(this));
        uint256 token1AmountAfter = token1.balanceOf(address(this));

        lpAmount = (lpAmountAfter - lpAmountBefore);

        // Return leftover token to msg.sender
        if (shouldTransferFromSender && (token0AmountAfter - token0AmountBefore) > 0) {
            token0.safeTransfer(msg.sender, (token0AmountAfter - token0AmountBefore));
        }
        if (shouldTransferFromSender && (token1AmountAfter - token1AmountBefore) > 0) {
            token1.safeTransfer(msg.sender, (token1AmountAfter - token1AmountBefore));
        }
    }

    /// @dev Be aware that staking entry is Convex Booster contract while withdraw/getReward entry is BaseRewardPool contract.
    /// This is because staking token for BaseRewardPool is the deposit token that can only minted by Booster.
    /// Booster.deposit() will do some processing and stake into BaseRewardPool for us.
    function _stake(address staker, uint256 lpAmount) internal {
        lp.safeApprove(address(convexBooster), lpAmount);
        convexBooster.deposit(
            pid,
            lpAmount,
            true // True indicate to also stake into BaseRewardPool
        );
        _totalSupply = _totalSupply + lpAmount;
        _balances[staker] = _balances[staker] + lpAmount;
        emit Staked(staker, lpAmount);
    }

    /// @notice Taken token0 or token1 in, provide liquidity in Curve and stake
    /// the LP token into Convex contract. Leftover token0 or token1 will be returned to msg.sender.
    /// @param isToken0 Determine if token0 is the token msg.sender going to use for staking, token1 otherwise
    /// @param amount Amount of token0 or token1 to stake
    /// @param minLiqAddedAmount The minimum amount of LP token received when adding liquidity
    function stake(
        bool isToken0,
        uint256 amount,
        uint256 minLiqAddedAmount
    ) public nonReentrant notPaused updateReward(msg.sender) {
        uint256 lpAmount = _convertAndAddLiquidity(isToken0, true, amount, minLiqAddedAmount);
        _stake(msg.sender, lpAmount);
    }

    /// @notice Take LP tokens and stake into Convex contract.
    /// @param lpAmount Amount of LP tokens to stake
    function stakeWithLP(uint256 lpAmount) public nonReentrant notPaused updateReward(msg.sender) {
        lp.safeTransferFrom(msg.sender, address(this), lpAmount);
        _stake(msg.sender, lpAmount);
    }

    function _removeLP(IERC20 token, bool toToken0, uint256 amount, uint256 minAmountReceived) internal returns (uint256) {
        uint256 balBefore = token.balanceOf(address(this));

        lp.safeApprove(address(curveDepositCompound), amount);
        curveDepositCompound.remove_liquidity_one_coin(
            amount,
            toToken0 ? int128(0) : int128(1),
            minAmountReceived,
            true // Donate dust
        );
        uint256 balAfter = token.balanceOf(address(this));
        return balAfter - balBefore;
    }

    /// @notice Withdraw stake from BaseRewardPool, remove liquidity and convert one asset to another.
    /// @param toToken0 Determine to convert all to token0 or token 1
    /// @param minAmountReceived The minimum amount of token0 or token1 received when removing liquidity
    /// @param amount Amount of stake to withdraw
    function withdraw(
        bool toToken0,
        uint256 minAmountReceived,
        uint256 amount
    ) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");

        // Update records:
        // substract withdrawing LP amount from total LP amount staked
        _totalSupply = (_totalSupply - amount);
        // substract withdrawing LP amount from user's balance
        _balances[msg.sender] = (_balances[msg.sender] - amount);

        // Withdraw and unwrap to LP token
        convexBaseRewardPool.withdrawAndUnwrap(
            amount,
            false // No need to getReward when withdraw
        );

        IERC20 token = toToken0 ? token0 : token1;
        uint256 receivedTokenAmount = _removeLP(token, toToken0, amount, minAmountReceived);
        token.safeTransfer(msg.sender, receivedTokenAmount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Withdraw LP tokens from BaseRewardPool contract and return to user.
    /// @param lpAmount Amount of LP tokens to withdraw
    function withdrawWithLP(uint256 lpAmount) public nonReentrant notPaused updateReward(msg.sender) {
        require(lpAmount > 0, "Cannot withdraw 0");

        // Update records:
        // substract withdrawing LP amount from total LP amount staked
        _totalSupply = (_totalSupply - lpAmount);
        // substract withdrawing LP amount from user's balance
        _balances[msg.sender] = (_balances[msg.sender] - lpAmount);

        // Withdraw and unwrap to LP token
        convexBaseRewardPool.withdrawAndUnwrap(
            lpAmount,
            false // No need to getReward when withdraw
        );
        lp.safeTransfer(msg.sender, lpAmount);

        emit Withdrawn(msg.sender, lpAmount);
    }

    /// @notice Transfer BCNT reward to user.
    function getReward() public updateReward(msg.sender)  {        
        uint256 reward = _rewards[msg.sender];
        uint256 totalReward = _rewards[address(this)];
        if (reward > 0) {
            // userbcntRewardAmount: based on user's reward and totalReward,
            // determine how many BCNT reward can user take away.
            // NOTE: totalReward = _rewards[address(this)];
            uint256 userbcntRewardAmount = bcntRewardAmount * reward / totalReward;

            // Update records:
            // substract user's rewards from totalReward
            _rewards[msg.sender] = 0;
            _rewards[address(this)] = (totalReward - reward);
            // substract userbcntRewardAmount from bcntRewardAmount
            bcntRewardAmount = (bcntRewardAmount - userbcntRewardAmount);

            BCNT.safeTransfer(msg.sender, userbcntRewardAmount);

            emit RewardPaid(msg.sender, userbcntRewardAmount);
        }
    }

    /// @notice Withdraw all stake from BaseRewardPool, remove liquidity, get the reward out and convert one asset to another.
    /// @param toToken0 Determine to convert all to token0 or token 1
    /// @param minAmountReceived The minimum amount of token0 or token1 received when removing liquidity
    function exit(bool toToken0, uint256 minAmountReceived) external {
        withdraw(toToken0, minAmountReceived, _balances[msg.sender]);
        getReward();
    }

    /// @notice Withdraw all stake from BaseRewardPool, get the reward out and convert one asset to another.
    function exitWithLP() external {
        withdrawWithLP(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Get all reward out from BaseRewardPool contract, convert rewards to BCNT.
    /// @param minCrvToBCNTSwap The minimum amount of BCNT received when swapping CRV to BCNT
    /// @param minCvxToBCNTSwap The minimum amount of BCNT received when swapping CVX to BCNT
    function accrueBCNT(
        uint256 minCrvToBCNTSwap,
        uint256 minCvxToBCNTSwap
    ) external nonReentrant updateReward(address(0)) onlyOperator {
        // getReward will get us CRV and CVX
        convexBaseRewardPool.getReward(address(this), true);

        BalanceDiff memory bcntAmountDiff;
        bcntAmountDiff.balBefore = BCNT.balanceOf(address(this));

        // Try convert CRV to BCNT
        uint256 crvBalance = crv.balanceOf(address(this));
        if (crvBalance > 0) {
            crv.approve(address(converter), crvBalance);
            // try converter.convert(address(crv), crvBalance, 100, address(token0), minCrvToBCNTSwap, address(this)) {
            try converter.convertUniV3(address(crv), crvBalance, 100, address(BCNT), minCrvToBCNTSwap, address(this), crvToBCNTUniV3SwapPath) {

            } catch Error(string memory reason) {
                emit ConvertFailed(address(crv), address(BCNT), crvBalance, reason, bytes(""));
            } catch (bytes memory lowLevelData) {
                emit ConvertFailed(address(crv), address(BCNT), crvBalance, "", lowLevelData);
            }
        }
        // Try convert CVX to BCNT
        uint256 cvxBalance = cvx.balanceOf(address(this));
        if (cvxBalance > 0) {
            cvx.approve(address(converter), cvxBalance);
            try converter.convertUniV3(address(cvx), cvxBalance, 100, address(BCNT), minCvxToBCNTSwap, address(this), cvxToBCNTUniV3SwapPath) {

            } catch Error(string memory reason) {
                emit ConvertFailed(address(cvx), address(BCNT), cvxBalance, reason, bytes(""));
            } catch (bytes memory lowLevelData) {
                emit ConvertFailed(address(cvx), address(BCNT), cvxBalance, "", lowLevelData);
            }
        }

        bcntAmountDiff.balAfter = BCNT.balanceOf(address(this));
        bcntAmountDiff.balDiff = (bcntAmountDiff.balAfter - bcntAmountDiff.balBefore);
        bcntRewardAmount = bcntRewardAmount + bcntAmountDiff.balDiff;

        emit Compounded(bcntAmountDiff.balDiff);
    }

    function addBCNTReward(uint256 amount) external onlyOperator {
        BCNT.safeTransferFrom(operator, address(this), amount);
        bcntRewardAmount = bcntRewardAmount + amount;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(lp), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function updateCVXToBCNTUniV3SwapPath(bytes calldata newPath) external onlyOperator {
        cvxToBCNTUniV3SwapPath = newPath;

        emit UpdateCVXToBCNTUniV3SwapPath(newPath);
    }

    function updateCRVToBCNTUniV3SwapPath(bytes calldata newPath) external onlyOperator {
        crvToBCNTUniV3SwapPath = newPath;

        emit UpdateCRVToBCNTUniV3SwapPath(newPath);
    }

    function updateOperator(address newOperator) external onlyOwner {
        operator = newOperator;

        emit UpdateOperator(newOperator);
    }

    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {}

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        uint256 rewardPerTokenStored = convexBaseRewardPool.rewardPerToken();
        if (account != address(0)) {
            _rewards[account] = _share(account);
            _userRewardPerTokenPaid[account] = rewardPerTokenStored;

            // Use _rewards[address(this)] to keep track of rewards earned by all accounts.
            _rewards[address(this)] = _shareTotal();
            _userRewardPerTokenPaid[address(this)] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only the contract operator may perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event UpdateCVXToBCNTUniV3SwapPath(bytes newPath);
    event UpdateCRVToBCNTUniV3SwapPath(bytes newPath);
    event UpdateOperator(address newOperator);
    event Staked(address indexed user, uint256 amount);
    event ConvertFailed(address fromToken, address toToken, uint256 fromAmount, string reason, bytes lowLevelData);
    event Compounded(uint256 bcntAmount);
    event RewardPaid(address indexed user, uint256 rewardLPAmount);
    event Withdrawn(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);
}