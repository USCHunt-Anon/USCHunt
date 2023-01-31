// : MIT

pragma solidity 0.8.9;



// Part: IGMAccessControl

/**
    @title User status and roles
    @author Gene A. Tsvigun
  */
interface IGMAccessControl {
    function isTrader(address user) external view returns (bool);

    function isCreator(address user) external view returns (bool);

    function userPermissions(address user) external view returns (bool userIsTrader, bool userIsCreator);

    function isAgent(address user) external view returns (bool);

    function isAgentOf(address agent, address user) external view returns (bool);

    function agentOf(address user) external view returns (address);
}

// Part: IPausable

interface IPausable {
    function pause() external;

    function unpause() external;
}

// Part: IUpgradeable

/**
    @title GreatMasters contract upgradeability interface
    @author Gene A. Tsvigun
  */
interface IUpgradeable {
    function upgrade(address newImplementation) external;
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/AddressUpgradeable

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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/IBeaconUpgradeable

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/Initializable

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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/StorageSlotUpgradeable

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
library StorageSlotUpgradeable {
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

// Part: OpenZeppelin/openzeppelin-contracts@4.3.2/IERC165

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// Part: OpenZeppelin/openzeppelin-contracts@4.3.2/IERC20

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

// Part: OpenZeppelin/openzeppelin-contracts@4.3.2/IERC721Receiver

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// Part: IGMAuction

/**
    @title Auction for GreatMasters NFTs
    @author Gene A. Tsvigun
  */
interface IGMAuction {
    function scheduleAuction(uint256 artId_, uint256 startPrice_) external;

    function scheduleInitialAuction(address beneficiary_, uint256 artId_, uint256 startPrice_) external;

    function setDuration(uint256 duration_) external;

    function setMaxStartPrice(uint256 maxStartPrice_) external;

    function bid(uint256 artId, uint256 amount) external;

    function completeAuction(uint256 artId) external;

    function setMinter(address minter_) external;

    function setUser(IGMAccessControl user_) external;

    function isActive(uint256 artId) external view returns (bool);
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/ContextUpgradeable

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/ERC1967UpgradeUpgradeable

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
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
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
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
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
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
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}

// Part: OpenZeppelin/openzeppelin-contracts@4.3.2/IERC721

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/OwnableUpgradeable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/PausableUpgradeable

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@4.3.2/UUPSUpgradeable

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
abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
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
    uint256[50] private __gap;
}

// Part: GMAgentPaymentProcessor

/**
    @title Agent payment processor
    @author Gene A. Tsvigun
  */
abstract contract GMAgentPaymentProcessor is OwnableUpgradeable {
    IERC20 internal stablecoin;
    IGMAccessControl user;
    address internal treasury;
    uint8 serviceCommissionPercent;
    uint8 agentCommissionPercent;


    function __GMAgentPaymentProcessor_init(
        IERC20 stablecoin_,
        IGMAccessControl user_,
        address treasury_,
        uint8 serviceCommissionPercent_,
        uint8 agentCommissionPercent_
    ) internal initializer {
        __Ownable_init();
        stablecoin = stablecoin_;
        user = user_;
        treasury = treasury_;
        serviceCommissionPercent = serviceCommissionPercent_;
        agentCommissionPercent = agentCommissionPercent_;
    }

    function processPayment(uint256 amount, address beneficiary) internal {
        uint256 serviceCommission = amount * serviceCommissionPercent / 100;
        uint256 paidToBeneficiary = amount - serviceCommission;
        uint256 sentToTreasury = serviceCommission;

        stablecoin.transfer(beneficiary, paidToBeneficiary);
        address agent = user.agentOf(beneficiary);
        if (agent != address(0)) {
            uint256 agentCommission = serviceCommission * agentCommissionPercent / 100;
            sentToTreasury -= agentCommission;
            stablecoin.transfer(agent, agentCommission);
        }
        stablecoin.transfer(treasury, sentToTreasury);
    }

    function setTreasury(address treasury_) public onlyOwner {
        treasury = treasury_;
    }

    function setServiceCommissionPercent(uint8 percent_) external onlyOwner {
        require(percent_ < 100, "GMPaymentProcessor: don't be that greedy");
        serviceCommissionPercent = percent_;
    }

    function setAgentCommissionPercent(uint8 percent_) external onlyOwner {
        require(percent_ <= 100, "GMPaymentProcessor: percent, you know, up to 100");
        agentCommissionPercent = percent_;
    }
}

// File: GMAuction.sol

/**
    @title Auction for GreatMasters NFTs
    @author Gene A. Tsvigun
  */
contract GMAuction is IGMAuction, IERC721Receiver, GMAgentPaymentProcessor, PausableUpgradeable, IPausable, UUPSUpgradeable, IUpgradeable {
    event Bid(uint256 artId, uint256 price, address bidder, uint256 minNextBid);
    event AuctionScheduled(uint256 artId, address beneficiary, uint256 startPrice);
    event AuctionStart(uint256 artId, uint256 startPrice, uint256 startTime, uint256 endTime);
    event AuctionEndTimeChanged(uint256 artId, uint256 endTime);
    event AuctionComplete(uint256 artId, uint256 price, address winner, uint256 endTime);
    event AuctionAcquiredToken(uint256 tokenId);


    uint256 public duration;
    uint256 public maxStartPrice; //USDT has 6 decimals
    uint256 constant MIN_DURATION = 1 hours;
    uint256 constant MAX_DURATION = 30 days;
    uint256 constant DEFAULT_DURATION = 2 days;
    uint256 constant AUCTION_PROLONGATION = 15 minutes;
    uint256 constant BID_STEP_PERCENT_MULTIPLIER = 110;

    IERC721 public nft;
    address public minter;

    struct Auction {
        address beneficiary;
        uint256 startTime;
        uint256 endTime;
        uint256 startPrice;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(uint256 => Auction) public auctions;

    /**
        @notice Same instance for multiple auctions within the same NFT contract using the same stablecoin
        @param nft_ nft contract defining items traded
        @param stablecoin_ address of an ERC20-compliant stablecoin to be used in the auction, BUSD, USDT etc.
      */
    function initialize(
        IERC721 nft_,
        IERC20 stablecoin_,
        IGMAccessControl user_,
        address treasury_,
        uint8 serviceCommissionPercent_,
        uint8 agentCommissionPercent_
    ) public initializer {
        __UUPSUpgradeable_init();
        __Pausable_init();
        __GMAgentPaymentProcessor_init(
            stablecoin_,
            user_,
            treasury_,
            serviceCommissionPercent_,
            agentCommissionPercent_);
        nft = nft_;
        duration = 7 days;
        maxStartPrice = 1000 * 10 ** 6;
    }

    function _authorizeUpgrade(address) internal override onlyOwner whenPaused {}

    function upgrade(address newImplementation) external onlyOwner {
        _upgradeTo(newImplementation);
    }

    /**
        @notice schedule an auction by grabbing the NFT.
        @param artId_ ID of the item sold
        @param startPrice_ starting/reserve price. Zero start price is special value
    */
    function scheduleAuction(
        uint256 artId_,
        uint256 startPrice_
    ) external whenNotScheduled(artId_) whenNotPaused override {
        _checkAuctionParams(
            artId_,
            startPrice_
        );
        address beneficiary = nft.ownerOf(artId_);
        auctions[artId_] = Auction(
            nft.ownerOf(artId_),
            0,
            0,
            startPrice_,
            address(0),
            0
        );
        nft.transferFrom(beneficiary, address(this), artId_);
        _logAuctionScheduled(artId_, auctions[artId_]);
    }

    /**
        @notice schedule an auction by grabbing the NFT
        @param beneficiary_ the address to receive the auction's winning bid for the item sold
        @param artId_ ID of the item sold
        @param startPrice_ starting/reserve price. Zero start price is special value
    */
    function scheduleInitialAuction(
        address beneficiary_,
        uint256 artId_,
        uint256 startPrice_
    ) external whenNotScheduled(artId_) whenNotPaused onlyMinter override {
        _checkAuctionParams(
            artId_,
            startPrice_
        );
        auctions[artId_] = Auction(
            beneficiary_,
            0,
            0,
            startPrice_,
            address(0),
            0
        );
        require(nft.ownerOf(artId_) == address(this));
        _logAuctionScheduled(artId_, auctions[artId_]);
    }

    /**
        @notice Bid on the auction, stablecoin contract approval required, the value refunded on overbid
        @param artId ID of the item sold
        @param amount bid amount - has to be higher than the current highest bid plus bid step
      */
    function bid(uint256 artId, uint256 amount) external onlyTrader whenScheduled(artId) override {//TODO check time
        _startAuction(artId);
        Auction storage a = auctions[artId];
        require(amount >= minimumBid(artId), "GMAuction: bid amount must >= 110% of the current hightest bid");
        require(a.highestBidder != msg.sender, "GMAuction: you're the highest bidder already");

        stablecoin.transferFrom(msg.sender, address(this), amount);
        _refundBid(artId);
        a.highestBidder = msg.sender;
        a.highestBid = amount;
        _adjustAuctionEndTime(artId);
        emit Bid(artId, a.highestBid, msg.sender, minimumBid(artId));
    }

    /**
        @notice duration of all auctions
        @param duration_ must be greater or equal than MIN_DURATION and less or equal than MAX_DURATION
    */
    function setDuration(uint256 duration_) external onlyOwner override {
        require(duration_ >= MIN_DURATION && duration_ <= MAX_DURATION, "GMAuction: Wrong auction duration length");
        duration = duration_;
    }

    /**
        @notice max start price for all auctions
        @param maxStartPrice_ must be greater than zero. Zero is special value
    */
    function setMaxStartPrice(uint256 maxStartPrice_) external onlyOwner override {
        require(maxStartPrice_ > 0, "GMAuction: start price could not be zero");
        maxStartPrice = maxStartPrice_;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /**
        @notice End the auction, send the highest bid to the beneficiary, send NFT to the highest bidder.
        @dev Process auction completion by sending NFT to the highest bidder and stablecoin to its beneficiary
        @param artId ID of the item sold
      */
    function completeAuction(uint256 artId) external whenEnded(artId) override {
        Auction storage a = auctions[artId];

        address highestBidder = auctions[artId].highestBidder;
        uint256 highestBid = auctions[artId].highestBid;

        //TODO consider safeTransferFrom or better - restrict trading, allow only to non-contract senders
        nft.transferFrom(address(this), highestBidder, artId);

        processPayment(highestBid, auctions[artId].beneficiary);

        emit AuctionComplete(artId, highestBid, highestBidder, auctions[artId].endTime);

        _markNotScheduled(artId);
    }

    /**
        @notice Set minter address that is allowed to start initial auctions for freshly minted tokens
        @param minter_ the address set as new minter
      */
    function setMinter(address minter_) public onlyOwner override {
        minter = minter_;
    }


    function setUser(IGMAccessControl user_) external onlyOwner override {
        user = user_;
    }

    modifier onlyTrader {
        require(user.isTrader(msg.sender), "GMAuction: only traders are allowed to bid");
        _;
    }

    modifier onlyMinter {
        require(msg.sender == minter, "GMAuction: action is allowed only to the minter");
        _;
    }

    modifier whenEnded(uint256 artId) {
        require(started(artId), "GMAuction: action is allowed only for auction that actually happened");
        require(_isFinished(artId), "GMAuction: action is allowed after the auction end time");
        _;
    }

    modifier whenActive(uint256 artId) {
        require(_isActive(artId), "GMAuction: action is allowed when the auction for the item is active");
        _;
    }

    modifier whenNotActive(uint256 artId) {
        require(!_isActive(artId), "GMAuction: action is allowed when there is no active auction for the item");
        _;
    }

    modifier whenScheduled(uint256 artId) {
        require(isScheduled(artId), "GMAuction: action is allowed when an auction is scheduled for the item");
        _;
    }

    modifier whenNotScheduled(uint256 artId) {
        require(!isScheduled(artId), "GMAuction: action is allowed when there is no scheduled auction for the item");
        _;
    }

    /**
        @return Whether the auction is active or not
    */
    function isActive(uint256 artId) external view override returns (bool){
        return _isActive(artId);
    }

    function isScheduled(uint256 artId) public view returns (bool){
        return auctions[artId].startPrice != 0;
    }

    function started(uint256 artId) public view returns (bool) {
        return auctions[artId].highestBid != 0;
    }

    function isFinished(uint256 artId) external view returns (bool) {
        return _isFinished(artId);
    }

    function minimumBid(uint256 artId) public view returns (uint256 minBid){
        if (auctions[artId].highestBid != 0) {
            minBid = auctions[artId].highestBid * BID_STEP_PERCENT_MULTIPLIER / 100;
        } else {
            minBid = auctions[artId].startPrice;
        }
    }

    function _checkAuctionParams(
        uint256 artId_,
        uint256 startPrice_
    ) private {
        require(nft.ownerOf(artId_) != address(0), "GMAuction constructor: the token must exist");
        require(startPrice_ <= maxStartPrice, "GMAuction constructor: start price too high");
    }

    function _logAuctionScheduled(uint256 artId, Auction storage a) private {
        emit AuctionScheduled(artId, a.beneficiary, a.startPrice);
    }

    function _refundBid(uint256 artId) private {
        address highestBidder = auctions[artId].highestBidder;
        if (highestBidder != address(0))
            stablecoin.transfer(highestBidder, auctions[artId].highestBid);
    }

    function _adjustAuctionEndTime(uint256 artId) private {
        uint256 adjustedTime = AUCTION_PROLONGATION + block.timestamp;
        if (auctions[artId].endTime < adjustedTime) {
            auctions[artId].endTime = adjustedTime;
            emit AuctionEndTimeChanged(artId, adjustedTime);
        }
    }

    /**
        @dev mark the start of an auction
        @param artId ID of the item sold
    */
    function _startAuction(uint256 artId) private {
        if (!started(artId)) {
            auctions[artId].startTime = block.timestamp;
            auctions[artId].endTime = block.timestamp + duration;
            emit AuctionStart(artId, auctions[artId].startPrice, auctions[artId].startTime, auctions[artId].endTime);
        }
    }

    function _markNotScheduled(uint256 artId) private {
        auctions[artId].startPrice = 0;
    }

    function _isActive(uint256 artId) private view returns (bool){
        uint256 startTime = auctions[artId].startTime;
        return startTime > 0 && startTime <= block.timestamp && auctions[artId].endTime > block.timestamp;
    }

    function _isFinished(uint256 artId) private view returns (bool){
        uint256 startTime = auctions[artId].startTime;
        return startTime > 0 && auctions[artId].endTime < block.timestamp;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4){
        emit AuctionAcquiredToken(tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }

    function setStableCoin(IERC20 stablecoin_) external onlyOwner {
        stablecoin = stablecoin_;
    }
}
