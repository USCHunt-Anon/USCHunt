/**
 *Submitted for verification at Arbiscan on 2022-06-22
*/

// ////-License-Identifier: MIT

pragma solidity ^0.8.0;
contract testContractProxy {
    address public a;
  
  function updateImplementation(address implementation1) public {
      a = implementation1;
  }
  
  function implementationT() public view returns (address) {
      return a;
  }

    fallback() external payable {
        delegatedFwd(implementationT(), msg.data);
    }
    
    
    function delegatedFwd(address _dst, bytes memory _calldata) internal {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let result := delegatecall(
                sub(gas(), 10000),
                _dst,
                add(_calldata, 0x20),
                mload(_calldata),
                0,
                0
            )
            let size := returndatasize()
    
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
    
            // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
            // if the call returned error data, forward it
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }
}

// : MIT
pragma solidity ^0.8.0;

contract setNumberContract{
    address reserved;
    uint256 public number;
    
    function setNumber(uint256 _number) public {
        number = _number + 1;
    }
}