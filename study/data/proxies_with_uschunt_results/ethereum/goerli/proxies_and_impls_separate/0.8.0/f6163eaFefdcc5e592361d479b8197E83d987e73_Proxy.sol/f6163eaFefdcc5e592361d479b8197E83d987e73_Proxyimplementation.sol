// : UNLICENSED

pragma solidity 0.8.0;

contract Implementation {
    uint256 public value;
    string public info;

    constructor() {
        info = "Sand Technical Test";
    }

    function addToValue(uint256 val) external {
        value += val;
    }

    function resetValue() external {
        value = 0;
    }
}