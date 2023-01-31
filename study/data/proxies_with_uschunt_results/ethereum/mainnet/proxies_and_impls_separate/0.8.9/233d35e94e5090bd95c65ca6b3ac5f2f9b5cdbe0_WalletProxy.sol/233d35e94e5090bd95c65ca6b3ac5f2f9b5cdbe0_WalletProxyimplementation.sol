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