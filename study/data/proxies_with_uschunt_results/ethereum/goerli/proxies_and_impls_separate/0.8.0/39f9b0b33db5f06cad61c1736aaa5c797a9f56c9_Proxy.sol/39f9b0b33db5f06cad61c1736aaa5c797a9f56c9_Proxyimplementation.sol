// : UNLICENSED

pragma solidity 0.8.0;

contract Implementation {
    uint256 public value;

    function addToValue(uint256 val) external {
        value += val;
    }
}