pragma solidity ^0.7.0;

contract matiliao {
        
    function kill(address payable addr) public payable {
        selfdestruct(addr);
    }
}