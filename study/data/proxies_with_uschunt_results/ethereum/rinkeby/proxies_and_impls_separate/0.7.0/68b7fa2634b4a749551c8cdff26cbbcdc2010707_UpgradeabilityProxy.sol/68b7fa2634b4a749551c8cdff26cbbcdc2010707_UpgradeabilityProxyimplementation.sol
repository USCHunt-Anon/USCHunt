// : MIT

pragma solidity ^0.7.0;
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _owner) public {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function setNewOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner cannot be the zero address");
        newOwner = _newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership() public {
        require(msg.sender == newOwner, "Ownable: caller must be new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


pragma solidity 0.7.0;
//import'./Ownable.sol';

contract KYC is Ownable {
    mapping(address => bool) public whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    bool initialized = false;

    constructor (address admin) Ownable(admin) {}

    function initialize(address admin) public {
        require(initialized == false, "OCCStakingImp: contract has already been initialized.");
        owner = admin;
        initialized = true;
    }

    function add(address _address) public onlyOwner {
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function remove(address _address) public onlyOwner {
        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function addBatch(address[] calldata _addresses) public onlyOwner {
        uint arrayLength = _addresses.length;
        for (uint i = 0; i < arrayLength; i++) {
            address _address = _addresses[i];
            whitelist[_address] = true;
            emit AddedToWhitelist(_address);
        }
    }

    function removeBatch(address[] calldata _addresses) public onlyOwner {
        uint arrayLength = _addresses.length;
        for (uint i = 0; i < arrayLength; i++) {
            address _address = _addresses[i];
            whitelist[_address] = false;
            emit RemovedFromWhitelist(_address);
        }
    }

    function isAccepted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}


