// : MIT
pragma solidity 0.8.4;
 
contract Implement2{
    string wellcomeString;
       function setData(string memory newData) public {
        wellcomeString = newData;
    }
     function getData() public view returns (string memory) {
        return wellcomeString;
    }
    
}