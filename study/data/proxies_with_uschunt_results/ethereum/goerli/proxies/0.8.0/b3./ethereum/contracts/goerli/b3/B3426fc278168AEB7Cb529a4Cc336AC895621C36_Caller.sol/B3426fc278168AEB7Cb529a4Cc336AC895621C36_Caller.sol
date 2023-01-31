//////-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface Flag {
    function mint(address) external;
}

contract Caller {
    address constant calleeAddr = 0x250E71FA3b86366703F0b1a670b7A7B0e0200012;
    address constant flag = 0xf11eA335d39CD791B47C2af7419081662EFC3091;

    mapping(address => bool) switches;

    fallback() external {
        (bool success, ) = calleeAddr.delegatecall(msg.data);
        require(success);

        require(switches[msg.sender], "msg.sender's switch is false");
        Flag(flag).mint(tx.origin);
    }
}

//: Unlicense
pragma solidity ^0.8.0;

contract Callee {
    mapping(address => bool) switches;

    function setSwitch(address x) external {
        switches[x] = true;
    }
}


}
