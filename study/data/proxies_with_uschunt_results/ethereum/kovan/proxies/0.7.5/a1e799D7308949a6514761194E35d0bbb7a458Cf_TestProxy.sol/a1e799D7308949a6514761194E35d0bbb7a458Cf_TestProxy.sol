/**
 *Submitted for verification at Etherscan.io on 2022-05-13
*/

// ////-License-Identifier: MIT
pragma solidity 0.7.5;

contract TestProxy {
    // Made variables public to compare with
    // the finding's metadata
    uint256 public amount;
    address public recipient;
    uint256 public newExchangeRate;

    address public implementation;

    function setArguments(
        uint256 _amount,
        address _recipient,
        uint256 _newExchangeRate
    ) external {
        amount = _amount;
        recipient = _recipient;
        newExchangeRate = _newExchangeRate;
    }

    function setImplementation(address _implementation) external {
        implementation = _implementation;
    }

    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    fallback() external {
        _fallback(implementation);
    }
    
    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * @param _implementation Address to delegate.
     */
    function _delegate(address _implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
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
    
    /**
     * @dev fallback implementation.
     * Extracted to enable manual triggering.
     */
    function _fallback(address _implementation) internal {
        _delegate(_implementation);
    }
}

// : Apache-2.0
pragma solidity 0.7.5;
pragma abicoder v2;

contract TestImplementation {
    uint256 amount;
    address recipient;
    uint256 newExchangeRate;

    event Slashed(uint256 amount, address recipient, uint256 newExchangeRate);

    function emitSlashed() external {
        emit Slashed(amount, recipient, newExchangeRate);
    }
}