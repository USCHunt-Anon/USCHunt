/**
 *Submitted for verification at polygonscan.com on 2021-09-28
*/

// ////-License-Identifier: MIT

// File @openzeppelin/contracts/proxy/beacon/[email protected]

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


// File @openzeppelin/contracts/proxy/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/proxy/ERC1967/[email protected]

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


// File @openzeppelin/contracts/proxy/beacon/[email protected]

pragma solidity ^0.8.0;



/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}


// File contracts/library/BeaconProxy.sol
pragma solidity ^0.8.2;

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


// File contracts/Ledger.sol

pragma solidity ^0.8.2;

contract Ledger is Initializable {
  struct CollateralType {
    uint256 normalizedDebt; // Total Normalised Debt     [wad]
    uint256 accumulatedRate; // Accumulated Rates         [ray]
    uint256 safetyPrice; // Price with Safety Margin  [ray]
    uint256 debtCeiling; // Debt Ceiling              [rad]
    uint256 debtFloor; // Position Debt Floor            [rad]
  }
  struct Position {
    uint256 lockedCollateral; // Locked Collateral  [wad]
    uint256 normalizedDebt; // Normalised Debt    [wad]
  }

  mapping(address => uint256) public authorizedAccounts;
  mapping(bytes32 => CollateralType) public collateralTypes;
  mapping(address => mapping(address => uint256)) public allowed;
  mapping(bytes32 => mapping(address => Position)) public positions;
  mapping(bytes32 => mapping(address => uint256)) public collateral; // [wad]
  mapping(address => uint256) public debt; // internal coin balance [rad]
  mapping(address => uint256) public unbackedDebt; // system debt, not belonging to any Position [rad]

  uint256 public totalDebt; // Total Stablecoin Issued    [rad]
  uint256 public totalUnbackedDebt; // Total Unbacked Stablecoin  [rad]
  uint256 public totalDebtCeiling; // Total Debt Ceiling  [rad]
  uint256 public live; // Active Flag

  // --- Events ---
  event GrantAuthorization(address indexed account);
  event RevokeAuthorization(address indexed account);
  event AllowModification(address indexed target, address indexed user);
  event DenyModification(address indexed target, address indexed user);
  event InitializeCollateralType(bytes32 indexed collateralType);
  event UpdateParameter(bytes32 indexed parameter, uint256 data);
  event UpdateParameter(
    bytes32 indexed parameter,
    bytes32 indexed collateralType,
    uint256 data
  );
  event ModifyCollateral(bytes32 collateralType, address user, int256 amount);
  event TransferCollateral(
    bytes32 collateralType,
    address from,
    address to,
    uint256 amount
  );
  event TransferDebt(address from, address to, uint256 amount);
  event ModifyPositionCollateralization(
    bytes32 indexed collateralType,
    address indexed position,
    address collateralSource,
    address debtDestination,
    int256 collateralDelta,
    int256 normalizedDebtDelta,
    uint256 lockedCollateral,
    uint256 normalizedDebt
  );
  event TransferCollateralAndDebt(
    bytes32 indexed collateralType,
    address indexed src,
    address indexed dst,
    int256 collateralDelta,
    int256 normalizedDebtDelta,
    uint256 srcLockedCollateral,
    uint256 srcNormalizedDebt,
    uint256 dstLockedCollateral,
    uint256 dstNormalizedDebt
  );
  event ConfiscateCollateralAndDebt(
    bytes32 indexed collateralType,
    address indexed position,
    address collateralCounterparty,
    address debtCounterparty,
    int256 collateralDelta,
    int256 normalizedDebtDelta
  );
  event SettleUnbackedDebt(address indexed account, uint256 amount);
  event CreateUnbackedDebt(
    address debtDestination,
    address unbackedDebtDestination,
    uint256 amount,
    uint256 debtDestinationBalance,
    uint256 unbackedDebtDestinationBalance
  );
  event UpdateAccumulatedRate(
    bytes32 indexed collateralType,
    address surplusDestination,
    int256 accumulatedRatedelta,
    int256 surplusDelta
  );

  modifier isAuthorized() {
    require(authorizedAccounts[msg.sender] == 1, "Ledger/not-authorized");
    _;
  }

  modifier isLive() {
    require(live == 1, "Ledger/not-live");
    _;
  }

  function initialize() public initializer {
    authorizedAccounts[msg.sender] = 1;
    live = 1;
  }

  // --- Auth ---
  function grantAuthorization(address user) external isAuthorized {
    authorizedAccounts[user] = 1;
    emit GrantAuthorization(user);
  }

  function revokeAuthorization(address user) external isAuthorized {
    authorizedAccounts[user] = 0;
    emit RevokeAuthorization(user);
  }

  // --- Allowance ---
  function allowModification(address user) external {
    allowed[msg.sender][user] = 1;
    emit AllowModification(msg.sender, user);
  }

  function denyModification(address user) external {
    allowed[msg.sender][user] = 0;
    emit DenyModification(msg.sender, user);
  }

  function allowedToModifyDebtOrCollateral(address bit, address user)
    internal
    view
    returns (bool)
  {
    return
      either(
        // Either user is owner, or modification permission is given
        either(bit == user, allowed[bit][user] == 1),
        // Sender is admin
        authorizedAccounts[msg.sender] == 1
      );
  }

  // --- Math ---
  function addInt(uint256 x, int256 y) internal pure returns (uint256 z) {
    unchecked {
      z = x + uint256(y);
    }
    require(y >= 0 || z <= x);
    require(y <= 0 || z >= x);
  }

  function subInt(uint256 x, int256 y) internal pure returns (uint256 z) {
    unchecked {
      z = x - uint256(y);
    }
    require(y <= 0 || z <= x);
    require(y >= 0 || z >= x);
  }

  function mulInt(uint256 x, int256 y) internal pure returns (int256 z) {
    unchecked {
      z = int256(x) * y;
    }
    require(int256(x) >= 0);
    require(y == 0 || z / y == int256(x));
  }

  function either(bool x, bool y) internal pure returns (bool z) {
    assembly {
      z := or(x, y)
    }
  }

  function both(bool x, bool y) internal pure returns (bool z) {
    assembly {
      z := and(x, y)
    }
  }

  // --- Administration ---
  function initializeCollateralType(bytes32 collateralType)
    external
    isAuthorized
  {
    require(
      collateralTypes[collateralType].accumulatedRate == 0,
      "Ledger/collateralType-already-init"
    );
    collateralTypes[collateralType].accumulatedRate = 10**27;
    emit InitializeCollateralType(collateralType);
  }

  function updateTotalDebtCeiling(uint256 data) external isAuthorized isLive {
    totalDebtCeiling = data;
    emit UpdateParameter("totalDebtCeiling", data);
  }

  function updateSafetyPrice(bytes32 collateralType, uint256 data)
    external
    isAuthorized
    isLive
  {
    collateralTypes[collateralType].safetyPrice = data;
    emit UpdateParameter("safetyPrice", data);
  }

  function updateDebtCeiling(bytes32 collateralType, uint256 data)
    external
    isAuthorized
    isLive
  {
    collateralTypes[collateralType].debtCeiling = data;
    emit UpdateParameter("debtCeiling", collateralType, data);
  }

  function updateDebtFloor(bytes32 collateralType, uint256 data)
    external
    isAuthorized
    isLive
  {
    collateralTypes[collateralType].debtFloor = data;
    emit UpdateParameter("debtFloor", collateralType, data);
  }

  function shutdown() external isAuthorized {
    live = 0;
  }

  // --- Fungibility ---
  function modifyCollateral(
    bytes32 collateralType,
    address user,
    int256 wad
  ) external isAuthorized {
    collateral[collateralType][user] = addInt(
      collateral[collateralType][user],
      wad
    );
    emit ModifyCollateral(collateralType, user, wad);
  }

  function transferCollateral(
    bytes32 collateralType,
    address from,
    address to,
    uint256 wad
  ) external {
    require(
      allowedToModifyDebtOrCollateral(from, msg.sender),
      "Ledger/not-allowed"
    );
    collateral[collateralType][from] = collateral[collateralType][from] - wad;
    collateral[collateralType][to] = collateral[collateralType][to] + wad;
    emit TransferCollateral(collateralType, from, to, wad);
  }

  function transferDebt(
    address from,
    address to,
    uint256 rad
  ) external {
    require(
      allowedToModifyDebtOrCollateral(from, msg.sender),
      "Ledger/not-allowed"
    );
    debt[from] = debt[from] - rad;
    debt[to] = debt[to] + rad;
    emit TransferDebt(from, to, rad);
  }

  // --- CDP Manipulation ---
  function modifyPositionCollateralization(
    bytes32 collateralType,
    address position,
    address collateralSource,
    address debtDestination,
    int256 collateralDelta,
    int256 normalizedDebtDelta
  ) external isLive {
    Position memory positionData = positions[collateralType][position];
    CollateralType memory collateralTypeData = collateralTypes[collateralType];
    // collateralType has been initialised
    require(
      collateralTypeData.accumulatedRate != 0,
      "Ledger/collateralType-not-init"
    );

    positionData.lockedCollateral = addInt(
      positionData.lockedCollateral,
      collateralDelta
    );
    positionData.normalizedDebt = addInt(
      positionData.normalizedDebt,
      normalizedDebtDelta
    );
    collateralTypeData.normalizedDebt = addInt(
      collateralTypeData.normalizedDebt,
      normalizedDebtDelta
    );

    int256 adjustedDebtDelta = mulInt(
      collateralTypeData.accumulatedRate,
      normalizedDebtDelta
    );
    uint256 totalDebtOfPosition = collateralTypeData.accumulatedRate *
      positionData.normalizedDebt;
    totalDebt = addInt(totalDebt, adjustedDebtDelta);

    // either totalDebt has decreased, or totalDebtceilings are not exceeded
    require(
      either(
        normalizedDebtDelta <= 0,
        both(
          collateralTypeData.normalizedDebt *
            collateralTypeData.accumulatedRate <=
            collateralTypeData.debtCeiling,
          totalDebt <= totalDebtCeiling
        )
      ),
      "Ledger/ceiling-exceeded"
    );
    // position is either less risky than before, or it is safe
    require(
      either(
        both(normalizedDebtDelta <= 0, collateralDelta >= 0),
        totalDebtOfPosition <=
          positionData.lockedCollateral * collateralTypeData.safetyPrice
      ),
      "Ledger/not-safe"
    );

    // position is either more safe, or the owner consents
    require(
      either(
        both(normalizedDebtDelta <= 0, collateralDelta >= 0),
        allowedToModifyDebtOrCollateral(position, msg.sender)
      ),
      "Ledger/not-allowed-position"
    );
    // collateral src consents
    require(
      either(
        collateralDelta <= 0,
        allowedToModifyDebtOrCollateral(collateralSource, msg.sender)
      ),
      "Ledger/not-allowed-collateral-src"
    );
    // totalDebtdst consents
    require(
      either(
        normalizedDebtDelta >= 0,
        allowedToModifyDebtOrCollateral(debtDestination, msg.sender)
      ),
      "Ledger/not-allowed-debt-dst"
    );

    // position has no debt, or a non-negligible amount
    require(
      either(
        positionData.normalizedDebt == 0,
        totalDebtOfPosition >= collateralTypeData.debtFloor
      ),
      "Ledger/debtFloor"
    );

    collateral[collateralType][collateralSource] = subInt(
      collateral[collateralType][collateralSource],
      collateralDelta
    );
    debt[debtDestination] = addInt(debt[debtDestination], adjustedDebtDelta);

    positions[collateralType][position] = positionData;
    collateralTypes[collateralType] = collateralTypeData;
    emit ModifyPositionCollateralization(
      collateralType,
      position,
      collateralSource,
      debtDestination,
      collateralDelta,
      normalizedDebtDelta,
      positionData.lockedCollateral,
      positionData.normalizedDebt
    );
  }

  // --- CDP Fungibility ---
  function transferCollateralAndDebt(
    bytes32 collateralType,
    address src,
    address dst,
    int256 collateralDelta,
    int256 normalizedDebtDelta
  ) external {
    Position storage sourcePosition = positions[collateralType][src];
    Position storage destinationPosition = positions[collateralType][dst];
    CollateralType storage collateralTypeData = collateralTypes[collateralType];

    sourcePosition.lockedCollateral = subInt(
      sourcePosition.lockedCollateral,
      collateralDelta
    );
    sourcePosition.normalizedDebt = subInt(
      sourcePosition.normalizedDebt,
      normalizedDebtDelta
    );
    destinationPosition.lockedCollateral = addInt(
      destinationPosition.lockedCollateral,
      collateralDelta
    );
    destinationPosition.normalizedDebt = addInt(
      destinationPosition.normalizedDebt,
      normalizedDebtDelta
    );

    uint256 sourceDebt = sourcePosition.normalizedDebt *
      collateralTypeData.accumulatedRate;
    uint256 destinationDebt = destinationPosition.normalizedDebt *
      collateralTypeData.accumulatedRate;

    // both sides consent
    require(
      both(
        allowedToModifyDebtOrCollateral(src, msg.sender),
        allowedToModifyDebtOrCollateral(dst, msg.sender)
      ),
      "Ledger/not-allowed"
    );

    // both sides safe
    require(
      sourceDebt <=
        sourcePosition.lockedCollateral * collateralTypeData.safetyPrice,
      "Ledger/not-safe-src"
    );
    require(
      destinationDebt <=
        destinationPosition.lockedCollateral * collateralTypeData.safetyPrice,
      "Ledger/not-safe-dst"
    );

    // both sides non-negligible
    require(
      either(
        sourceDebt >= collateralTypeData.debtFloor,
        sourcePosition.normalizedDebt == 0
      ),
      "Ledger/debtFloor-src"
    );
    require(
      either(
        destinationDebt >= collateralTypeData.debtFloor,
        destinationPosition.normalizedDebt == 0
      ),
      "Ledger/debtFloor-dst"
    );
    emit TransferCollateralAndDebt(
      collateralType,
      src,
      dst,
      collateralDelta,
      normalizedDebtDelta,
      sourcePosition.lockedCollateral,
      sourcePosition.normalizedDebt,
      destinationPosition.lockedCollateral,
      destinationPosition.normalizedDebt
    );
  }

  // --- CDP Confiscation ---
  function confiscateCollateralAndDebt(
    bytes32 collateralType,
    address user,
    address collateralCounterparty,
    address debtCounterparty,
    int256 collateralDelta,
    int256 normalizedDebtDelta
  ) external isAuthorized {
    Position storage position = positions[collateralType][user];
    CollateralType storage collateralTypeData = collateralTypes[collateralType];

    position.lockedCollateral = addInt(
      position.lockedCollateral,
      collateralDelta
    );
    position.normalizedDebt = addInt(
      position.normalizedDebt,
      normalizedDebtDelta
    );
    collateralTypeData.normalizedDebt = addInt(
      collateralTypeData.normalizedDebt,
      normalizedDebtDelta
    );

    int256 unbackedDebtDelta = mulInt(
      collateralTypeData.accumulatedRate,
      normalizedDebtDelta
    );

    collateral[collateralType][collateralCounterparty] = subInt(
      collateral[collateralType][collateralCounterparty],
      collateralDelta
    );
    unbackedDebt[debtCounterparty] = subInt(
      unbackedDebt[debtCounterparty],
      unbackedDebtDelta
    );
    totalUnbackedDebt = subInt(totalUnbackedDebt, unbackedDebtDelta);
    emit ConfiscateCollateralAndDebt(
      collateralType,
      user,
      collateralCounterparty,
      debtCounterparty,
      collateralDelta,
      normalizedDebtDelta
    );
  }

  // --- Settlement ---
  function settleUnbackedDebt(uint256 rad) external {
    address user = msg.sender;
    unbackedDebt[user] = unbackedDebt[user] - rad;
    debt[user] = debt[user] - rad;
    totalUnbackedDebt = totalUnbackedDebt - rad;
    totalDebt = totalDebt - rad;
    emit SettleUnbackedDebt(user, rad);
  }

  function createUnbackedDebt(
    address unbackedDebtAccount,
    address debtAccount,
    uint256 rad
  ) external isAuthorized {
    unbackedDebt[unbackedDebtAccount] = unbackedDebt[unbackedDebtAccount] + rad;
    debt[debtAccount] = debt[debtAccount] + rad;
    totalUnbackedDebt = totalUnbackedDebt + rad;
    totalDebt = totalDebt + rad;
    emit CreateUnbackedDebt(
      debtAccount,
      unbackedDebtAccount,
      rad,
      debt[debtAccount],
      unbackedDebt[unbackedDebtAccount]
    );
  }

  // --- Rates ---
  function updateAccumulatedRate(
    bytes32 collateralType,
    address debtDestination,
    int256 accumulatedRateDelta
  ) external isAuthorized isLive {
    CollateralType storage collateralTypeData = collateralTypes[collateralType];
    collateralTypeData.accumulatedRate = addInt(
      collateralTypeData.accumulatedRate,
      accumulatedRateDelta
    );
    int256 debtDelta = mulInt(
      collateralTypeData.normalizedDebt,
      accumulatedRateDelta
    );
    debt[debtDestination] = addInt(debt[debtDestination], debtDelta);
    totalDebt = addInt(totalDebt, debtDelta);
    emit UpdateAccumulatedRate(
      collateralType,
      debtDestination,
      accumulatedRateDelta,
      debtDelta
    );
  }
}