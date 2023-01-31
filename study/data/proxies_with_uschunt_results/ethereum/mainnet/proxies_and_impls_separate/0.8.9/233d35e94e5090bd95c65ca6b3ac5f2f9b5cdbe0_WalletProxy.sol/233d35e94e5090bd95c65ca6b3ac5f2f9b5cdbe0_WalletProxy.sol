/**
 *Submitted for verification at Etherscan.io on 2022-01-23
*/

// ////-License-Identifier: MIT

pragma solidity 0.8.9;

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

abstract contract MinimalBeaconProxy is Proxy {

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Sets the `beacon` for this contract.
     */
    constructor(address beacon) {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon);
    }

    /**
     * @dev Returns the `implementation` stored at the beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Returns the `beacon` for beacon proxy pattern.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Sets the new beacon `newBeacon`.
     */
    function _setBeacon(address newBeacon) internal {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}

abstract contract WalletProxyBase is MinimalBeaconProxy {

    bytes32 internal constant _DAO_SLOT = 0x2a6cb721c141aca9a9ad80925a738db49772cafe7da767ae62299908d3d32d1c;
    bytes32 internal constant _MERGE_SLOT = 0x60ab9511b01b1ee756a19d64d798acec49593fec7b00c39ea6c9e8c0b459fa93;
    bytes32 internal constant _MANAGER_SLOT = 0x25b56d42a36e6932800bdf5cc9c56e8775f5792d702c21c4ef9a0c40a93bb009;

    /**
     * @dev Sets `DAO_`, `merge_`, and `manager_`.
     */
    constructor(address DAO_, address merge_, address manager_) {
        assert(_DAO_SLOT == bytes32(uint256(keccak256("eip1967.proxy.dao")) - 1));
        assert(_MERGE_SLOT == bytes32(uint256(keccak256("eip1967.proxy.merge")) - 1));
        assert(_MANAGER_SLOT == bytes32(uint256(keccak256("eip1967.proxy.manager")) - 1));
        _setDAO(DAO_);
        _setMerge(merge_);
        _setManager(manager_);
    }

    /**
     * @dev Sets the new DAO address `newDAO`.
     */
    function _setDAO(address DAO) internal {
        require(Address.isContract(DAO), "ERC1967: DAO is not a multisig wallet");
        StorageSlot.getAddressSlot(_DAO_SLOT).value = DAO;
    }

    /**
     * @dev Returns the DAO address.
     */
    function _getDAO() internal view returns (address) {
        return StorageSlot.getAddressSlot(_DAO_SLOT).value;
    }

    /**
     * @dev Sets the `newMerge` contract address.
     */
    function _setMerge(address merge) internal {
        require(Address.isContract(merge), "ERC1967: merge is not a smart contract.");
        StorageSlot.getAddressSlot(_MERGE_SLOT).value = merge;
    }

    /**
     * @dev Returns the Merge contract address.
     */
    function _getMerge() internal view returns (address) {
        return StorageSlot.getAddressSlot(_MERGE_SLOT).value;
    }

    /**
     * @dev Sets the new manager `manager` address.
     */
    function _setManager(address manager) internal {
        require(Address.isContract(manager), "ERC1967: Manager is not a smart contract.");
        StorageSlot.getAddressSlot(_MANAGER_SLOT).value = manager;
    }

    /**
     * @dev Returns the new manager address.
     */
    function _getManager() internal view returns (address) {
        return StorageSlot.getAddressSlot(_MANAGER_SLOT).value;
    }
}

contract WalletProxy is WalletProxyBase {
    constructor(address beacon, address DAO, address merge, address manager)
        WalletProxyBase(DAO, merge, manager)
        MinimalBeaconProxy(beacon) {}
}

// : MIT

pragma solidity 0.8.9;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IMerge {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function tokenOf(address account) external view returns (uint256);
    function setApprovalForAll(address operator, bool approved) external;
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract WalletImplementation is Ownable {

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
    bytes32 internal constant _DAO_SLOT = 0x2a6cb721c141aca9a9ad80925a738db49772cafe7da767ae62299908d3d32d1c;
    bytes32 internal constant _MERGE_SLOT = 0x60ab9511b01b1ee756a19d64d798acec49593fec7b00c39ea6c9e8c0b459fa93;
    bytes32 internal constant _MANAGER_SLOT = 0x25b56d42a36e6932800bdf5cc9c56e8775f5792d702c21c4ef9a0c40a93bb009;

    /**
     * @dev A modifier that only allows the DAO multisig wallet to access.
     */
    modifier onlyDAO {
        require(_msgSender() == _getDAO(), "onlyDAO is allowed");
        _;
    }

    /**
     * @dev A modifier that only allows the manager contract to access.
     */
    modifier onlyManager {
        require(_msgSender() == _getManager(), "onlyManager is allowed");
        _;
    }

    /**
     * @dev Transfers the token in this wallet to address `to`.
     */
    function transfer(address to) external onlyDAO {
        IMerge(_getMerge()).safeTransferFrom(address(this), to, _getTokenId());
    }

    /**
     * @dev Approves the `manager` contract to transfer NFTs.
     */
    function setApprovalForAll() external onlyManager {
        IMerge(_getMerge()).setApprovalForAll(_getManager(), true);
    }

    /**
     * @dev Retrieves the ERC20 `token` accidentally sent to a wallet.
     */
    function retrieveERC20Tokens(address token) external onlyDAO {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer(_getDAO(), balance);
        }
    }

    /**
     * @dev Retrieves the ERC721 NFT `token` with `tokenId`.
     */
    function retrieveERC721Tokens(address token, uint256 tokenId) external onlyDAO {
        require(token != _getMerge(), "Not allowed to retrieve merge NFTs");
        if (IERC721(token).balanceOf(address(this)) > 0) {
            if (IERC721(token).ownerOf(tokenId) == address(this)) {
                IERC721(token).safeTransferFrom(address(this), _getDAO(), tokenId);
            }
        }
    }

    /**
     * @dev Returns the Beacon address.
     */
    function getBeacon() external view returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the DAO wallet address.
     */
    function getDAO() external view returns (address) {
        return _getDAO();
    }

    /**
     * @dev Returns the Manager contract address.
     */
    function getManager() external view returns (address) {
        return _getManager();
    }

    /**
     * @dev Returns the Merge contract address.
     */
    function getMerge() external view returns (address) {
        return _getMerge();
    }

    /**
     * @dev Returns the selector of `onERC721Received`, required by `safeTransferFrom`
     */
    function onERC721Received(address, address, uint256, bytes memory) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Returns tokenId of the NFT held by this wallet.
     */
    function _getTokenId() private view returns (uint256) {
        return IMerge(_getMerge()).tokenOf(address(this));
    }

    /**
     * @dev Returns the Beacon address.
     */
    function _getBeacon() private view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Returns the DAO address multisig wallet address.
     */
    function _getDAO() private view returns (address) {
        return StorageSlot.getAddressSlot(_DAO_SLOT).value;
    }

    /**
     * @dev Returns the Wallet Proxy Manager smart contract address.
     */
    function _getManager() private view returns (address) {
        return StorageSlot.getAddressSlot(_MANAGER_SLOT).value;
    }

    /**
     * @dev Returns the Merge smart contract address.
     */
    function _getMerge() private view returns (address) {
        return StorageSlot.getAddressSlot(_MERGE_SLOT).value;
    }
}