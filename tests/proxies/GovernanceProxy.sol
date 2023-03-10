/**
 *Submitted for verification at celoscan.io on 2022-03-24
*/

pragma solidity ^0.5.3;


library Address {

    function isContract(address account) internal view returns (bool) {



        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }


    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");


        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Proxy {

  bytes32 private constant OWNER_POSITION = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  bytes32 private constant IMPLEMENTATION_POSITION = bytes32(
    uint256(keccak256("eip1967.proxy.implementation")) - 1
  );

  event OwnerSet(address indexed owner);
  event ImplementationSet(address indexed implementation);

  constructor() public {
    _setOwner(msg.sender);
  }


  modifier onlyOwner() {
    require(msg.sender == _getOwner(), "sender was not owner");
    _;
  }


  function() external payable {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;

    address implementationAddress;


    assembly {
      implementationAddress := sload(implementationPosition)
    }



    require(implementationAddress != address(0), "No Implementation set");
    require(Address.isContract(implementationAddress), "Invalid contract address");

    assembly {

      let newCallDataPosition := mload(0x40)
      mstore(0x40, add(newCallDataPosition, calldatasize))
      calldatacopy(newCallDataPosition, 0, calldatasize)



      let delegatecallSuccess := delegatecall(
        gas,
        implementationAddress,
        newCallDataPosition,
        calldatasize,
        0,
        0
      )


      let returnDataSize := returndatasize
      let returnDataPosition := mload(0x40)
      mstore(0x40, add(returnDataPosition, returnDataSize))
      returndatacopy(returnDataPosition, 0, returnDataSize)


      switch delegatecallSuccess
        case 0 {
          revert(returnDataPosition, returnDataSize)
        }
        default {
          return(returnDataPosition, returnDataSize)
        }
    }
  }


  function _transferOwnership(address newOwner) external onlyOwner {
    _setOwner(newOwner);
  }


  function _setAndInitializeImplementation(address implementation, bytes calldata callbackData)
    external
    payable
    onlyOwner
  {
    _setImplementation(implementation);
    bool success;
    bytes memory returnValue;
    (success, returnValue) = implementation.delegatecall(callbackData);
    require(success, "initialization callback failed");
  }


  function _getImplementation() external view returns (address implementation) {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;

    assembly {
      implementation := sload(implementationPosition)
    }
  }


  function _setImplementation(address implementation) public onlyOwner {
    bytes32 implementationPosition = IMPLEMENTATION_POSITION;

    require(Address.isContract(implementation), "Invalid contract address");


    assembly {
      sstore(implementationPosition, implementation)
    }

    emit ImplementationSet(implementation);
  }


  function _getOwner() public view returns (address owner) {
    bytes32 position = OWNER_POSITION;

    assembly {
      owner := sload(position)
    }
  }

  function _setOwner(address newOwner) private {
    require(newOwner != address(0), "owner cannot be 0");
    bytes32 position = OWNER_POSITION;

    assembly {
      sstore(position, newOwner)
    }
    emit OwnerSet(newOwner);
  }
}

contract GovernanceProxy is Proxy {}
