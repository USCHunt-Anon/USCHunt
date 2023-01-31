/**
 *Submitted for verification at Etherscan.io on 2022-06-02
*/

//////-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Proxy {
    address public immutable implementation;

    constructor(address _implementation, bytes memory _data) {
        implementation = _implementation;

        (bool success, ) = _implementation.delegatecall(_data);
        require(success == true, "argent/proxy-init-failed");
    }

    fallback() external payable {
        address target = implementation;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}

//: Unlicense
pragma solidity ^0.8.0;

contract ArgentAccount {
    address public signer;
    string public version = "0.1.0";

    modifier onlySigner() {
        require(
            msg.sender == signer || msg.sender == address(this),
            "argent/only-signer"
        );
        _;
    }

    function initialize(address _signer) external {
        require(signer == address(0), "argent/already-init");
        signer = _signer;
    }

    function execute(address to, bytes calldata data) external onlySigner {
        _call(to, data);
    }

    function _call(address to, bytes memory data) internal {
        (bool success, bytes memory result) = to.call(data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                revert(result, add(result, 32))
            }
        }
    }
}