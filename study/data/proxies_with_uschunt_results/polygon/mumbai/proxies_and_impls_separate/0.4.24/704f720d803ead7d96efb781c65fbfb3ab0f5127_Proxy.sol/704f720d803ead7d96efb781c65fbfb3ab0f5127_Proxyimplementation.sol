pragma solidity ^0.4.24;


contract Proxy_Storage {
    uint256 public value;
}
contract contrac_V2 is Proxy_Storage {
    function setvalue() public {
        value = value+1;
    }
}