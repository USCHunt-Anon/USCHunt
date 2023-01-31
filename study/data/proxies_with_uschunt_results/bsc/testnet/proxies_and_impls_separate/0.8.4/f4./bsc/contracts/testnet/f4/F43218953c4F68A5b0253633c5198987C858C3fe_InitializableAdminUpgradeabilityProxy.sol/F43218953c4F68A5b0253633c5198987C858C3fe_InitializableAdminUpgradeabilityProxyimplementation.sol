//:UNLICENSE
pragma solidity 0.8.4;

contract caller {
    
    function execute(uint amount) public pure returns (uint){
        
        return amount * 80 / 100;
    }
}