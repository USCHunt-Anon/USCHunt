/**
 *Submitted for verification at polygonscan.com on 2022-07-02
*/

// ////-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)


pragma solidity ^0.4.24;






contract ProxyStorage {
    address public implementation;
}


contract Proxy is ProxyStorage {

    constructor(address _impl) public {
        // check that its valid before setting the address
        implementation = _impl;
    }

    function setImplementation(address _impl) public {
        implementation = _impl;
    }
    function () public {
        address localImpl = implementation;
         //solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, localImpl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}