// : MIT 

pragma solidity ^0.7.0;

contract Logic {
    uint256 result;
    
    function add(uint256 a, uint256 b) external {
        result = a+b;
    }
    function getResult() external view returns (uint256) {
        return result;
    }
}