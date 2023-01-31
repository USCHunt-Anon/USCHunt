/**
 *Submitted for verification at Etherscan.io on 2021-12-14
*/

/**
 *Submitted for verification at Etherscan.io on 2021-12-11
*/

// ////-License-Identifier: MIT
pragma solidity 0.8.4;
 
contract Ownable {
  address public owner; // slot 0

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require (msg.sender == owner);
      _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

contract Proxy is Ownable {
    
    string wellcomeString = "Hello, world!"; //slot 2
    address payable implementation = payable(0x443bF61B13780bf34692c9e70b02c4fD42368c6f);
    uint256 version = 1;
    
    fallback() payable external {
      (bool sucess, bytes memory _result) = implementation.delegatecall(msg.data);
    }
    
    function changeImplementation(address payable _newImplementation, uint256 _newVersion) public onlyOwner {
        require(_newVersion > version, "New version must be greater then previous");
        implementation = _newImplementation;
    }
    
    uint256[50] private _gap;
}