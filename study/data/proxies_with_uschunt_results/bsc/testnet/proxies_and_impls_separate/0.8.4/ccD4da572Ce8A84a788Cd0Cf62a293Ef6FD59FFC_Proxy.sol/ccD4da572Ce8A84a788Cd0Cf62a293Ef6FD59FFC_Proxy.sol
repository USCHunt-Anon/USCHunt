/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.4;

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




// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.4;

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




// Proxy contract makes delegate calls to implementation contract EIP-1967

pragma solidity ^0.8.4;

library StorageSlot {
    function getAddressAt(bytes32 slot) internal view returns (address a) {
        assembly {
            a := sload(slot)
        }
    }

    function setAddressAt(bytes32 slot, address address_) internal {
        assembly {
            sstore(slot, address_)
        }
    }
}

contract Proxy is Ownable {

    event Upgrade(address indexed newImplementation);
    event ImplementationConstructor(bool indexed status, bytes indexed data);

    constructor(address _implementation){
        setImplementation(_implementation);
        emit Upgrade(_implementation);

        (bool success, bytes memory data) = _implementation.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        emit ImplementationConstructor(success, data);

    }

    bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function setImplementation(address implementation_) public onlyOwner{
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation_);
        emit Upgrade(implementation_);
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressAt(_IMPL_SLOT);
    }

    function _delegate(address impl) internal virtual {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    fallback() payable external {
        _delegate(StorageSlot.getAddressAt(_IMPL_SLOT));
    }
}



pragma solidity ^0.8.4;

contract LogicV2 is Ownable{
    bool initialized;
    uint256 magicNumber;
    uint public secondMagicNumber;
    uint public thirdMagicNumber;
    uint public balance;

    function initialize() external {
        require(!initialized, "already initialized");

        magicNumber = 0x42;
        initialized = true;
    }

    function deposit() payable external returns(uint){
        balance = balance + msg.value;
        return address(this).balance;
    }

    function setSecondMagicNumber(uint _num) external{
        secondMagicNumber = _num;
    }

    function setThirdMagicNumber(uint _num) external{
        thirdMagicNumber = _num;
    }

    function setMagicNumber(uint256 newMagicNumber) public onlyOwner{
        magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
        return magicNumber;
    }
}