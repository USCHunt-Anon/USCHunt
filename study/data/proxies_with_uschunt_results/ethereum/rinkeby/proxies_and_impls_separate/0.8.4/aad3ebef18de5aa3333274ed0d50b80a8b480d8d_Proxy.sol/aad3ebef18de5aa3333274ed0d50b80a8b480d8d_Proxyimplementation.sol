pragma solidity 0.8.4;

contract LogicContract {
    uint256 public test1;
    uint256 public test2;
    uint256 public result;
    
    function setFirstParam(uint256 _test1) public {
        test1 = _test1;
    }
    
    function setSecondParam(uint256 _test2) public {
        test2 = _test2;
    }
    
    function calculateResult() public {
        result = test1 + test2;
    }
}