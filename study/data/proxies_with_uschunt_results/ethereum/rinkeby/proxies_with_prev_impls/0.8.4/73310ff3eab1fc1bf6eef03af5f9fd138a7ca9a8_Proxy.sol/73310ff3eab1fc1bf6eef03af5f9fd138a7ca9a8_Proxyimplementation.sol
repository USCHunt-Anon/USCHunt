// : MIT
pragma solidity 0.8.4;
contract HelloWorld {
    
   string wellcomeString;
    
    function getData() public view returns (string memory) {
        return wellcomeString;
    }
    
}