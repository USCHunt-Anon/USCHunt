/**
 *Submitted for verification at Etherscan.io on 2021-07-26
*/

// File: contracts/FarmPoolTwoStorage.sol

pragma solidity ^0.6.0;

contract FarmAdminStorage {
    address public admin;

    address public implementation;
}

contract FarmPoolTwoStorage is FarmAdminStorage {
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; //user Debt for 2 month（continuous Mining）
    }

    // Info of each pool.
    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. MDXs to distribute per block.
        uint256 lastRewardBlock; // Last block number that Gans distribution occurs.
        uint256 accGanPerShare; //PerShare for continuous Mining
        uint256 totalAmount; // Total amount of current pool deposit.
    }

    uint256 public startBlock;
    address public gandalf;

    uint256 public ganPerBlock;

    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when gandalf mining starts.

    // How many blocks are halved
    uint256 public halvingPeriod;

    address farmPoolOne;
}

// File: contracts/FarmPoolTwoDelegator.sol

pragma solidity 0.6.12;


contract FarmPoolTwoDelegator is FarmAdminStorage {
    /**
     * @notice Emitted when pendingComptrollerImplementation is accepted, which means comptroller implementation is updated
     */
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    event NewAdmin(address oldAdmin, address newAdmin);

    constructor(
        address _gan,
        uint256 _ganPerBlock,
        uint256 _halvingPeriod,
        uint256 _startBlock,
        address _implementation
    ) public {
        admin = msg.sender;

        delegateTo(
            _implementation,
            abi.encodeWithSignature(
                "initialize(address,uint256,uint256,uint256)",
                _gan,
                _ganPerBlock,
                _halvingPeriod,
                _startBlock
            )
        );
        _setImplementation(_implementation);
    }

    function _setImplementation(address implementation_) public {
        require(
            msg.sender == admin,
            "_setImplementation: Caller must be admin"
        );

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }

    function _setAdmin(address newAdmin) public {
        require(msg.sender == admin, "UNAUTHORIZED");

        address oldAdmin = admin;

        admin = newAdmin;

        emit NewAdmin(oldAdmin, newAdmin);
    }

    function delegateTo(address callee, bytes memory data)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
        return returnData;
    }

    receive() external payable {}

    /**
     * @notice Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
    //  */
    fallback() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);
        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())
            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
    }
}