// ////-License-Identifier: MIT
pragma solidity ^0.7.6;

interface AccountImplementations {
    function getImplementation(bytes4 _sig) external view returns (address);
}

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`.
 */
contract StakeAllAccountV2 {
    AccountImplementations public immutable implementations;

    constructor(address _implementations) {
        implementations = AccountImplementations(_implementations);
    }

    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

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
     * @dev Delegates the current call to the address returned by Implementations registry.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback(bytes4 _sig) internal {
        address _implementation = implementations.getImplementation(_sig);
        require(
            _implementation != address(0),
            "StakeAllAccountV2: Not able to find _implementation"
        );
        _delegate(_implementation);
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by Implementations registry.
     */
    fallback() external payable {
        _fallback(msg.sig);
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by Implementations registry.
     */
    receive() external payable {
        if (msg.sig != 0x00000000) {
            _fallback(msg.sig);
        }
    }
}

// : UNLICENSED
pragma solidity ^0.7.6;

contract Variables {
    // Auth Module(Address of Auth => bool).
    mapping(address => bool) internal _auth;

    // nonces chainId => nonces
    mapping(uint256 => uint256) internal _nonces;
}


// : UNLICENSED
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

//import{Variables} from "../variables.sol";

interface IndexInterface {
    function list() external view returns (address);
}

interface ListInterface {
    function addAuth(address user) external;

    function removeAuth(address user) external;
}

contract Constants is Variables {
    uint256 public constant implementationVersion = 1;
    // StakeAllIndex Address.
    address public immutable stakeAllIndex;
    // The Account Module Version.
    uint256 public constant version = 2;

    constructor(address _stakeAllIndex) {
        stakeAllIndex = _stakeAllIndex;
    }
}

contract Record is Constants {
    constructor(address _stakeAllIndex) Constants(_stakeAllIndex) {}

    event LogEnableUser(address indexed user);
    event LogDisableUser(address indexed user);

    /**
     * @dev Check for Auth if enabled.
     * @param user address/user/owner.
     */
    function isAuth(address user) public view returns (bool) {
        return _auth[user];
    }

    /**
     * @dev Enable New User.
     * @param user Owner address
     */
    function enable(address user) public {
        require(
            msg.sender == address(this) || msg.sender == stakeAllIndex,
            "not-self-index"
        );
        require(user != address(0), "not-valid");
        require(!_auth[user], "already-enabled");
        _auth[user] = true;
        ListInterface(IndexInterface(stakeAllIndex).list()).addAuth(user);
        emit LogEnableUser(user);
    }

    /**
     * @dev Disable User.
     * @param user Owner address
     */
    function disable(address user) public {
        require(msg.sender == address(this), "not-self");
        require(user != address(0), "not-valid");
        require(_auth[user], "already-disabled");
        delete _auth[user];
        ListInterface(IndexInterface(stakeAllIndex).list()).removeAuth(user);
        emit LogDisableUser(user);
    }
}

contract StakeAllDefaultImplementation is Record {
    constructor(address _stakeAllIndex) public Record(_stakeAllIndex) {}

    receive() external payable {}
}



}
