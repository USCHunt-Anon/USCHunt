pragma solidity ^0.7.0;

contract matiliao123456 {
    uint256 public a = 123;

    function kill(address payable addr) public payable {
        selfdestruct(addr);
    }

   receive() external payable {

    }
}