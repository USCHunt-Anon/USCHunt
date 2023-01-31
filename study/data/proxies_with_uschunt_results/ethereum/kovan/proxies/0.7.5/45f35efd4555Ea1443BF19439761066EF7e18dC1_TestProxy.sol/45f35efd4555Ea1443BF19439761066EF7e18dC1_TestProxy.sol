/**
 *Submitted for verification at Etherscan.io on 2022-05-12
*/

// ////-License-Identifier: MIT
pragma solidity 0.7.5;

contract TestProxy {
    // Made variables public to compare with
    // the finding's metadata
    bytes32 public role;
    bytes32 public previousAdminRole;
    bytes32 public newAdminRole;
    address public account;
    address public sender;

    address public implementation;

    function setArguments(
        bytes32 _role,
        bytes32 _previousAdminRole,
        bytes32 _newAdminRole,
        address _account,
        address _sender
    ) external {
        role = _role;
        previousAdminRole = _previousAdminRole;
        newAdminRole = _newAdminRole;
        account = _account;
        sender = _sender;
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
    bytes32 role;
    bytes32 previousAdminRole;
    bytes32 newAdminRole;
    address account;
    address sender;

    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function emitRoleAdminChanged() external {
        emit RoleAdminChanged(role, previousAdminRole, newAdminRole);
    }

    function emitRoleGranted() external {
        emit RoleGranted(role, account, sender);
    }

    function emitRoleRevoked() external {
        emit RoleRevoked(role, account, sender);
    }
}