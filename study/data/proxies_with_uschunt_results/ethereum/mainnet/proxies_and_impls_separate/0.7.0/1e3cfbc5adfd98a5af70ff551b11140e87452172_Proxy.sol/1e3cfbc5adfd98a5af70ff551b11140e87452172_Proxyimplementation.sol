pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    /// @dev Address of lock flag variable.
    /// @dev Flag is placed at random memory location to not interfere with Storage contract.
    uint256 private constant LOCK_FLAG_ADDRESS = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf4; // keccak256("ReentrancyGuard") - 1;

    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/566a774222707e424896c0c390a84dc3c13bdcb2/contracts/security/ReentrancyGuard.sol
    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    function initializeReentrancyGuard() internal {
        uint256 lockSlotOldValue;

        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange every call to nonReentrant
        // will be cheaper.
        assembly {
            lockSlotOldValue := sload(LOCK_FLAG_ADDRESS)
            sstore(LOCK_FLAG_ADDRESS, _NOT_ENTERED)
        }

        // Check that storage slot for reentrancy guard is empty to rule out possibility of slot conflict
        require(lockSlotOldValue == 0, "1B");
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        uint256 _status;
        assembly {
            _status := sload(LOCK_FLAG_ADDRESS)
        }

        // On the first call to nonReentrant, _notEntered will be true
        require(_status == _NOT_ENTERED);

        // Any calls to nonReentrant after this point will fail
        assembly {
            sstore(LOCK_FLAG_ADDRESS, _ENTERED)
        }

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        assembly {
            sstore(LOCK_FLAG_ADDRESS, _NOT_ENTERED)
        }
    }
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "14");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "v");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "15");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "x");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "y");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUInt128 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "12");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        return sub(a, b, "aa");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint128 a, uint128 b) internal pure returns (uint128) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "13");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        return div(a, b, "ac");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint128 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint128 a, uint128 b) internal pure returns (uint128) {
        return mod(a, b, "ad");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/**
 * @dev Wrappers over Solidity's uintXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and then downcasting.
 *
 * _Available since v2.5.0._
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "16");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "17");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "18");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "19");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "1a");
        return uint8(value);
    }
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



//import"./IERC20.sol";
//import"./Bytes.sol";

library Utils {
    /// @notice Returns lesser of two values
    function minU32(uint32 a, uint32 b) internal pure returns (uint32) {
        return a < b ? a : b;
    }

    /// @notice Returns lesser of two values
    function minU64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    /// @notice Sends tokens
    /// @dev NOTE: this function handles tokens that have transfer function not strictly compatible with ERC20 standard
    /// @dev NOTE: call `transfer` to this token may return (bool) or nothing
    /// @param _token Token address
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @return bool flag indicating that transfer is successful
    function sendERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        (bool callSuccess, bytes memory callReturnValueEncoded) =
        address(_token).call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
        // `transfer` method may return (bool) or nothing.
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    /// @notice Transfers token from one address to another
    /// @dev NOTE: this function handles tokens that have transfer function not strictly compatible with ERC20 standard
    /// @dev NOTE: call `transferFrom` to this token may return (bool) or nothing
    /// @param _token Token address
    /// @param _from Address of sender
    /// @param _to Address of recipient
    /// @param _amount Amount of tokens to transfer
    /// @return bool flag indicating that transfer is successful
    function transferFromERC20(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        (bool callSuccess, bytes memory callReturnValueEncoded) =
        address(_token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _amount));
        // `transferFrom` method may return (bool) or nothing.
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    /// @notice Recovers signer's address from ethereum signature for given message
    /// @param _signature 65 bytes concatenated. R (32) + S (32) + V (1)
    /// @param _messageHash signed message hash.
    /// @return address of the signer
    function recoverAddressFromEthSignature(bytes memory _signature, bytes32 _messageHash)
    internal
    pure
    returns (address)
    {
        require(_signature.length == 65, "P"); // incorrect signature length

        bytes32 signR;
        bytes32 signS;
        uint8 signV;
        assembly {
            signR := mload(add(_signature, 32))
            signS := mload(add(_signature, 64))
            signV := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_messageHash, signV, signR, signS);
    }

    /// @notice Returns new_hash = hash(old_hash + bytes)
    function concatHash(bytes32 _hash, bytes memory _bytes) internal pure returns (bytes32) {
        bytes32 result;
        assembly {
            let bytesLen := add(mload(_bytes), 32)
            mstore(_bytes, _hash)
            result := keccak256(_bytes, bytesLen)
            mstore(_bytes, sub(bytesLen, 32))
        }
        return result;
    }

    function hashBytesToBytes20(bytes memory _bytes) internal pure returns (bytes20) {
        return bytes20(uint160(uint256(keccak256(_bytes))));
    }
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0





//import"./IERC20.sol";

//import"./Governance.sol";
//import"./Verifier.sol";
//import"./VerifierExit.sol";
//import"./Operations.sol";
//import"./uniswap/UniswapV2Factory.sol";

/// @title zkSync storage contract
/// @author Matter Labs
contract Storage {
    /// @dev Flag indicates that upgrade preparation status is active
    /// @dev Will store false in case of not active upgrade mode
    bool internal upgradePreparationActive;

    /// @dev Upgrade preparation activation timestamp (as seconds since unix epoch)
    /// @dev Will be equal to zero in case of not active upgrade mode
    uint256 internal upgradePreparationActivationTime;

    /// @dev Verifier contract. Used to verify block proof
    Verifier public verifier;

    /// @dev Verifier contract. Used to verify exit proof
    VerifierExit public verifier_exit;

    /// @dev Governance contract. Contains the governor (the owner) of whole system, validators list, possible tokens list
    Governance public governance;

    // NEW ADD
    UniswapV2Factory internal pairmanager;

    uint8 internal constant FILLED_GAS_RESERVE_VALUE = 0xff; // we use it to set gas revert value so slot will not be emptied with 0 balance
    struct PendingBalance {
        uint128 balanceToWithdraw;
        uint8 gasReserveValue; // gives user opportunity to fill storage slot with nonzero value
    }

    /// @dev Root-chain balances (per owner and token id, see packAddressAndTokenId) to withdraw
    mapping(bytes22 => PendingBalance) public pendingBalances;

    /// @notice Total number of executed blocks i.e. blocks[totalBlocksExecuted] points at the latest executed block (block 0 is genesis)
    uint32 public totalBlocksExecuted;

    /// @notice Total number of committed blocks i.e. blocks[totalBlocksCommitted] points at the latest committed block
    uint32 public totalBlocksCommitted;

    /// @notice Flag indicates that a user has exited in the exodus mode certain token balance (per account id and tokenId)
    mapping(uint32 => mapping(uint16 => bool)) public performedExodus;

    /// @notice Flag indicates that exodus (mass exit) mode is triggered
    /// @notice Once it was raised, it can not be cleared again, and all users must exit
    bool public exodusMode;

    /// @notice First open priority request id
    uint64 public firstPriorityRequestId;

    /// @notice Total number of requests
    uint64 public totalOpenPriorityRequests;

    /// @notice Total number of committed requests.
    /// @dev Used in checks: if the request matches the operation on Rollup contract and if provided number of requests is not too big
    uint64 public totalCommittedPriorityRequests;

    /// @notice Packs address and token id into single word to use as a key in balances mapping
    function packAddressAndTokenId(address _address, uint16 _tokenId) internal pure returns (bytes22) {
        return bytes22((uint176(_address) | (uint176(_tokenId) << 160)));
    }

    /// @Rollup block stored data
    /// @member blockNumber Rollup block number
    /// @member priorityOperations Number of priority operations processed
    /// @member pendingOnchainOperationsHash Hash of all operations that must be processed after verify
    /// @member timestamp Rollup block timestamp, have the same format as Ethereum block constant
    /// @member stateHash Root hash of the rollup state
    /// @member commitment Verified input for the zkSync circuit
    struct StoredBlockInfo {
        uint32 blockNumber;
        uint64 priorityOperations;
        bytes32 pendingOnchainOperationsHash;
        uint256 timestamp;
        bytes32 stateHash;
        bytes32 commitment;
    }

    /// @notice Returns the keccak hash of the ABI-encoded StoredBlockInfo
    function hashStoredBlockInfo(StoredBlockInfo memory _storedBlockInfo) public pure returns (bytes32) {
        return keccak256(abi.encode(_storedBlockInfo));
    }

    /// @dev Stored hashed StoredBlockInfo for some block number
    mapping(uint32 => bytes32) public storedBlockHashes;

    /// @notice Total blocks proven.
    uint32 public totalBlocksProven;

    /// @notice Priority Operation container
    /// @member hashedPubData Hashed priority operation public data
    /// @member expirationBlock Expiration block number (ETH block) for this request (must be satisfied before)
    /// @member opType Priority operation type
    struct PriorityOperation {
        bytes20 hashedPubData;
        uint64 expirationBlock;
        Operations.OpType opType;
    }

    /// @dev Priority Requests mapping (request id - operation)
    /// @dev Contains op type, pubdata and expiration block of unsatisfied requests.
    /// @dev Numbers are in order of requests receiving
    // requestId -> PriorityOperation
    mapping(uint64 => PriorityOperation) public priorityRequests;

    // NEW ADD
    address public zkSyncCommitBlockAddress;
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/// @title zkSync configuration constants
/// @author Matter Labs
/// @author Stars Labs
contract Config {
    /// @dev ERC20 tokens and ETH withdrawals gas limit, used only for complete withdrawals
    uint256 constant WITHDRAWAL_GAS_LIMIT = 100000;

    /// @dev Bytes in one chunk
    uint8 constant CHUNK_BYTES = 9;

    /// @dev zkSync address length
    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    /// @dev Public key bytes length
    uint8 constant PUBKEY_BYTES = 32;

    /// @dev Ethereum signature r/s bytes length
    uint8 constant ETH_SIGN_RS_BYTES = 32;

    /// @dev Success flag bytes length
    uint8 constant SUCCESS_FLAG_BYTES = 1;

    /// @dev Max amount of tokens registered in the network (excluding ETH, which is hardcoded as tokenId = 0)
    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 511;

    /// @dev Max account id that could be registered in the network
    uint32 internal constant MAX_ACCOUNT_ID = 16777215;

    /// @dev Max deposit of ERC20 token that is possible to deposit
    uint128 internal constant MAX_DEPOSIT_AMOUNT = 20282409603651670423947251286015;

    /// @dev Max ERC20 token balance that is possible to deposit, suppose ((2**126) - 1)
    uint128 internal constant MAX_ERC20_TOKEN_BALANCE = (2**126) - 1;

    /// @dev Expected average period of block creation
    uint256 constant BLOCK_PERIOD = 15 seconds;

    /// @dev ETH blocks verification expectation
    /// @dev Blocks can be reverted if they are not verified for at least EXPECT_VERIFICATION_IN.
    /// @dev If set to 0 validator can revert blocks at any time.
    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant WITHDRAW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant FORCED_EXIT_BYTES = 6 * CHUNK_BYTES;
    // NEW ADD
    uint256 constant CREATE_PAIR_BYTES = 4 * CHUNK_BYTES;

    /// @dev Full exit operation length
    uint256 constant FULL_EXIT_BYTES = 6 * CHUNK_BYTES;

    /// @dev ChangePubKey operation length
    uint256 constant CHANGE_PUBKEY_BYTES = 6 * CHUNK_BYTES;

    /// @dev Expiration delta for priority request to be satisfied (in seconds)
    /// @dev NOTE: Priority expiration should be > (EXPECT_VERIFICATION_IN * BLOCK_PERIOD)
    /// @dev otherwise incorrect block with priority op could not be reverted.
    uint256 constant PRIORITY_EXPIRATION_PERIOD = 14 days;

    /// @dev Expiration delta for priority request to be satisfied (in ETH blocks)
    uint256 constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    /// @dev Maximum number of priority request to clear during verifying the block
    /// @dev Cause deleting storage slots cost 5k gas per each slot it's unprofitable to clear too many slots
    /// @dev Value based on the assumption of ~750k gas cost of verifying and 5 used storage slots per PriorityOperation structure
    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    /// @dev Reserved time for users to send full exit priority operation in case of an upgrade (in seconds)
    uint256 constant MASS_FULL_EXIT_PERIOD = 9 days;

    /// @dev Reserved time for users to withdraw funds from full exit priority operation in case of an upgrade (in seconds)
    uint256 constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    /// @dev Notice period before activation preparation status of upgrade mode (in seconds)
    /// @dev NOTE: we must reserve for users enough time to send full exit operation, wait maximum time for processing this operation and withdraw funds from it.
    uint256 constant UPGRADE_NOTICE_PERIOD = 0 days;

    /// @dev Timestamp - seconds since unix epoch
    uint256 constant COMMIT_TIMESTAMP_NOT_OLDER = 168 hours;

    /// @dev Maximum available error between real commit block timestamp and analog used in the verifier (in seconds)
    /// @dev Must be used cause miner's `block.timestamp` value can differ on some small value (as we know - 15 seconds)
    uint256 constant COMMIT_TIMESTAMP_APPROXIMATION_DELTA = 15 minutes;

    /// @dev Bit mask to apply for verifier public input before verifying.
    uint256 constant INPUT_MASK = (~uint256(0) >> 3);
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



//import"./Upgradeable.sol";
//import"./Operations.sol";

/// @title zkSync events
/// @author Matter Labs
/// @author Stars Labs
interface Events {
    /// @notice Event emitted when a block is committed
    event BlockCommit(uint32 indexed blockNumber);
    event BlockVerification(uint32 indexed blockNumber);

    /// @notice Event emitted when user funds are withdrawn from the zkSync contract
    event Withdrawal(uint16 indexed tokenId, uint128 amount);

    event OnchainWithdrawal(
        address indexed owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    /// @notice Event emitted when user send a transaction to deposit her funds
    event OnchainDeposit(
        address indexed sender,
        uint16 indexed tokenId,
        uint128 amount,
        address indexed owner
    );

    event OnchainCreatePair(
        uint16 indexed tokenAId,
        uint16 indexed tokenBId,
        uint16 indexed pairId,
        address pair
    );

    /// @notice Event emitted when blocks are reverted
    event BlocksRevert(uint32 totalBlocksVerified, uint32 totalBlocksCommitted);

    /// @notice Exodus mode entered event
    event ExodusMode();

    /// @notice New priority request event. Emitted when a request is placed into mapping
    event NewPriorityRequest(
        address sender,
        uint64 serialId,
        Operations.OpType opType,
        bytes pubData,
        uint256 expirationBlock
    );

    /// @notice Deposit committed event.
    event DepositCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        address owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    /// @notice Full exit committed event.
    event FullExitCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        address owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    event CreatePairCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        uint16 tokenAId,
        uint16 tokenBId,
        uint16 indexed tokenPairId,
        address pair
    );

    /// @notice Notice period changed
    event NoticePeriodChange(uint256 newNoticePeriod);
}

/// @title Upgrade events
/// @author Matter Labs
interface UpgradeEvents {
    /// @notice Event emitted when new upgradeable contract is added to upgrade gatekeeper's list of managed contracts
    event NewUpgradable(uint256 indexed versionId, address indexed upgradeable);

    /// @notice Upgrade mode enter event
    event NoticePeriodStart(
        uint256 indexed versionId,
        address[] newTargets,
        uint256 noticePeriod // notice period (in seconds)
    );

    /// @notice Upgrade mode cancel event
    event UpgradeCancel(uint256 indexed versionId);

    /// @notice Upgrade mode preparation status event
    event PreparationStart(uint256 indexed versionId);

    /// @notice Upgrade mode complete event
    event UpgradeComplete(uint256 indexed versionId, address[] newTargets);
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



// Functions named bytesToX, except bytesToBytes20, where X is some type of size N < 32 (size of one word)
// implements the following algorithm:
// f(bytes memory input, uint offset) -> X out
// where byte representation of out is N bytes from input at the given offset
// 1) We compute memory location of the word W such that last N bytes of W is input[offset..offset+N]
// W_address = input + 32 (skip stored length of bytes) + offset - (32 - N) == input + offset + N
// 2) We load W from memory into out, last N bytes of W are placed into out

library Bytes {
    function toBytesFromUInt16(uint16 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 2);
    }

    function toBytesFromUInt24(uint24 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 3);
    }

    function toBytesFromUInt32(uint32 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 4);
    }

    function toBytesFromUInt128(uint128 self) internal pure returns (bytes memory _bts) {
        return toBytesFromUIntTruncated(uint256(self), 16);
    }

    // Copies 'len' lower bytes from 'self' into a new 'bytes memory'.
    // Returns the newly created 'bytes memory'. The returned bytes will be of length 'len'.
    function toBytesFromUIntTruncated(uint256 self, uint8 byteLength) private pure returns (bytes memory bts) {
        require(byteLength <= 32, "Q");
        bts = new bytes(byteLength);
        // Even though the bytes will allocate a full word, we don't want
        // any potential garbage bytes in there.
        uint256 data = self << ((32 - byteLength) * 8);
        assembly {
            mstore(
            add(bts, 32), // BYTES_HEADER_SIZE
            data
            )
        }
    }

    // Copies 'self' into a new 'bytes memory'.
    // Returns the newly created 'bytes memory'. The returned bytes will be of length '20'.
    function toBytesFromAddress(address self) internal pure returns (bytes memory bts) {
        bts = toBytesFromUIntTruncated(uint256(self), 20);
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 20)
    function bytesToAddress(bytes memory self, uint256 _start) internal pure returns (address addr) {
        uint256 offset = _start + 20;
        require(self.length >= offset, "R");
        assembly {
            addr := mload(add(self, offset))
        }
    }

    // Reasoning about why this function works is similar to that of other similar functions, except NOTE below.
    // NOTE: that bytes1..32 is stored in the beginning of the word unlike other primitive types
    // NOTE: theoretically possible overflow of (_start + 20)
    function bytesToBytes20(bytes memory self, uint256 _start) internal pure returns (bytes20 r) {
        require(self.length >= (_start + 20), "S");
        assembly {
            r := mload(add(add(self, 0x20), _start))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x2)
    function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {
        uint256 offset = _start + 0x2;
        require(_bytes.length >= offset, "T");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x3)
    function bytesToUInt24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 r) {
        uint256 offset = _start + 0x3;
        require(_bytes.length >= offset, "U");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x4)
    function bytesToUInt32(bytes memory _bytes, uint256 _start) internal pure returns (uint32 r) {
        uint256 offset = _start + 0x4;
        require(_bytes.length >= offset, "V");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x10)
    function bytesToUInt128(bytes memory _bytes, uint256 _start) internal pure returns (uint128 r) {
        uint256 offset = _start + 0x10;
        require(_bytes.length >= offset, "W");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // See comment at the top of this file for explanation of how this function works.
    // NOTE: theoretically possible overflow of (_start + 0x14)
    function bytesToUInt160(bytes memory _bytes, uint256 _start) internal pure returns (uint160 r) {
        uint256 offset = _start + 0x14;
        require(_bytes.length >= offset, "X");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // NOTE: theoretically possible overflow of (_start + 0x20)
    function bytesToBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32 r) {
        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "Y");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    // Original source code: https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol#L228
    // Get slice from bytes arrays
    // Returns the newly created 'bytes memory'
    // NOTE: theoretically possible overflow of (_start + _length)
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {
        require(_bytes.length >= (_start + _length), "Z"); // bytes length is less then start byte + length bytes

        bytes memory tempBytes = new bytes(_length);

        if (_length != 0) {
            assembly {
                let slice_curr := add(tempBytes, 0x20)
                let slice_end := add(slice_curr, _length)

                for {
                    let array_current := add(_bytes, add(_start, 0x20))
                } lt(slice_curr, slice_end) {
                    slice_curr := add(slice_curr, 0x20)
                    array_current := add(array_current, 0x20)
                } {
                    mstore(slice_curr, mload(array_current))
                }
            }
        }

        return tempBytes;
    }

    /// Reads byte stream
    /// @return new_offset - offset + amount of bytes read
    /// @return data - actually read data
    // NOTE: theoretically possible overflow of (_offset + _length)
    function read(
        bytes memory _data,
        uint256 _offset,
        uint256 _length
    ) internal pure returns (uint256 new_offset, bytes memory data) {
        data = slice(_data, _offset, _length);
        new_offset = _offset + _length;
    }

    // NOTE: theoretically possible overflow of (_offset + 1)
    function readBool(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bool r) {
        new_offset = _offset + 1;
        r = uint8(_data[_offset]) != 0;
    }

    // NOTE: theoretically possible overflow of (_offset + 1)
    function readUint8(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint8 r) {
        new_offset = _offset + 1;
        r = uint8(_data[_offset]);
    }

    // NOTE: theoretically possible overflow of (_offset + 2)
    function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint16 r) {
        new_offset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 3)
    function readUInt24(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint24 r) {
        new_offset = _offset + 3;
        r = bytesToUInt24(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 4)
    function readUInt32(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint32 r) {
        new_offset = _offset + 4;
        r = bytesToUInt32(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 16)
    function readUInt128(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint128 r) {
        new_offset = _offset + 16;
        r = bytesToUInt128(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readUInt160(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint160 r) {
        new_offset = _offset + 20;
        r = bytesToUInt160(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readAddress(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, address r) {
        new_offset = _offset + 20;
        r = bytesToAddress(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 20)
    function readBytes20(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bytes20 r) {
        new_offset = _offset + 20;
        r = bytesToBytes20(_data, _offset);
    }

    // NOTE: theoretically possible overflow of (_offset + 32)
    function readBytes32(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bytes32 r) {
        new_offset = _offset + 32;
        r = bytesToBytes32(_data, _offset);
    }

    /// Trim bytes into single word
    function trim(bytes memory _data, uint256 _new_length) internal pure returns (uint256 r) {
        require(_new_length <= 0x20, "10"); // new_length is longer than word
        require(_data.length >= _new_length, "11"); // data is to short

        uint256 a;
        assembly {
            a := mload(add(_data, 0x20)) // load bytes into uint256
        }

        return a >> ((0x20 - _new_length) * 8);
    }

    // Helper function for hex conversion.
    function halfByteToHex(bytes1 _byte) internal pure returns (bytes1 _hexByte) {
        require(uint8(_byte) < 0x10, "hbh11"); // half byte's value is out of 0..15 range.

        // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
        return bytes1(uint8(0x66656463626139383736353433323130 >> (uint8(_byte) * 8)));
    }

    // Convert bytes to ASCII hex representation
    function bytesToHexASCIIBytes(bytes memory _input) internal pure returns (bytes memory _output) {
        bytes memory outStringBytes = new bytes(_input.length * 2);

        // code in `assembly` construction is equivalent of the next code:
        // for (uint i = 0; i < _input.length; ++i) {
        //     outStringBytes[i*2] = halfByteToHex(_input[i] >> 4);
        //     outStringBytes[i*2+1] = halfByteToHex(_input[i] & 0x0f);
        // }
        assembly {
            let input_curr := add(_input, 0x20)
            let input_end := add(input_curr, mload(_input))

            for {
                let out_curr := add(outStringBytes, 0x20)
            } lt(input_curr, input_end) {
                input_curr := add(input_curr, 0x01)
                out_curr := add(out_curr, 0x02)
            } {
                let curr_input_byte := shr(0xf8, mload(input_curr))
            // here outStringByte from each half of input byte calculates by the next:
            //
            // "FEDCBA9876543210" ASCII-encoded, shifted and automatically truncated.
            // outStringByte = byte (uint8 (0x66656463626139383736353433323130 >> (uint8 (_byteHalf) * 8)))
                mstore(
                out_curr,
                shl(0xf8, shr(mul(shr(0x04, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
                mstore(
                add(out_curr, 0x01),
                shl(0xf8, shr(mul(and(0x0f, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
            }
        }
        return outStringBytes;
    }
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0





//import"./Bytes.sol";
//import"./Utils.sol";

/// @title zkSync operations tools
/// @author Matter Labs
/// @author Stars Labs
library Operations {
    /// @notice zkSync circuit operation type
    enum OpType {
        Noop,    //0
        Deposit,
        TransferToNew,
        Withdraw,
        Transfer,
        FullExit, //5
        ChangePubKey,
        MiningMaintenance,
        ClaimBonus,
        CreatePair,
        AddLiquidity,//10
        RemoveLiquidity,
        Swap
    }

    // Byte lengths
    uint8 constant OP_TYPE_BYTES = 1;
    uint8 constant TOKEN_BYTES = 2;
    uint8 constant PUBKEY_BYTES = 32;
    uint8 constant NONCE_BYTES = 4;
    uint8 constant PUBKEY_HASH_BYTES = 20;
    uint8 constant ADDRESS_BYTES = 20;
    /// @dev Packed fee bytes lengths
    uint8 constant FEE_BYTES = 2;
    /// @dev zkSync account id bytes lengths
    uint8 constant ACCOUNT_ID_BYTES = 4;
    uint8 constant AMOUNT_BYTES = 16;
    /// @dev Signature (for example full exit signature) bytes length
    uint8 constant SIGNATURE_BYTES = 64;

    // Deposit pubdata
    struct Deposit {
        // uint8 opType
        uint32 accountId;
        uint16 tokenId;
        uint128 amount;
        address owner;
        uint32 pairAccountId;
    }

    // NEW ADD ACCOUNT_ID_BYTES
    uint256 public constant PACKED_DEPOSIT_PUBDATA_BYTES =
        OP_TYPE_BYTES + ACCOUNT_ID_BYTES + TOKEN_BYTES + AMOUNT_BYTES + ADDRESS_BYTES + ACCOUNT_ID_BYTES;

    /// Deserialize deposit pubdata
    function readDepositPubdata(bytes memory _data) internal pure returns (Deposit memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        (offset, parsed.pairAccountId) = Bytes.readUInt32(_data, offset); // pairAccountId
        require(offset == PACKED_DEPOSIT_PUBDATA_BYTES, "N"); // reading invalid deposit pubdata size
    }

    /// Serialize deposit pubdata
    // NEW ADD pairAccountId
    function writeDepositPubdataForPriorityQueue(Deposit memory op) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(OpType.Deposit),
            bytes4(0), // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenId, // tokenId
            op.amount, // amount
            op.owner, // owner
            bytes4(0) // pairAccountId
        );
    }

    /// @notice Write deposit pubdata for priority queue check.
    function checkDepositInPriorityQueue(Deposit memory op, bytes20 hashedPubdata) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeDepositPubdataForPriorityQueue(op)) == hashedPubdata;
    }

    // FullExit pubdata
    struct FullExit {
        // uint8 opType
        uint32 accountId;
        address owner;
        uint16 tokenId;
        uint128 amount;
        uint32 pairAccountId;
    }

    // NEW ADD ACCOUNT_ID_BYTES
    uint256 public constant PACKED_FULL_EXIT_PUBDATA_BYTES =
        OP_TYPE_BYTES + ACCOUNT_ID_BYTES + ADDRESS_BYTES + TOKEN_BYTES + AMOUNT_BYTES + ACCOUNT_ID_BYTES;

    function readFullExitPubdata(bytes memory _data) internal pure returns (FullExit memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        // NEW ADD pairAccountId
        (offset, parsed.pairAccountId) = Bytes.readUInt32(_data, offset); // pairAccountId
        require(offset == PACKED_FULL_EXIT_PUBDATA_BYTES, "O"); // reading invalid full exit pubdata size
    }

    function writeFullExitPubdataForPriorityQueue(FullExit memory op) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(OpType.FullExit),
            op.accountId, // accountId
            op.owner, // owner
            op.tokenId, // tokenId
            uint128(0), // amount -- ignored
            // NEW ADD pairAccountId
            uint32(0) // pairAccountId -- ignored
        );
    }

    function checkFullExitInPriorityQueue(FullExit memory op, bytes20 hashedPubdata) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeFullExitPubdataForPriorityQueue(op)) == hashedPubdata;
    }

    // Withdraw pubdata
    struct Withdraw {
        //uint8 opType; -- present in pubdata, ignored at serialization
        // NEW ADD
        uint32 accountId;
        uint16 tokenId;
        uint128 amount;
        //uint16 fee; -- present in pubdata, ignored at serialization
        address owner;
        // NEW ADD
        uint32 pairAccountId;
    }

    function readWithdrawPubdata(bytes memory _data) internal pure returns (Withdraw memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        // CHANGE uint256 offset = OP_TYPE_BYTES + ACCOUNT_ID_BYTES;
        uint256 offset = OP_TYPE_BYTES; // opType
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        offset += FEE_BYTES; // fee (ignored)
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        // NEW ADD
        (offset, parsed.pairAccountId) = Bytes.readUInt32(_data, offset); // pairAccountId
    }

    // ForcedExit pubdata
    struct ForcedExit {
        //uint8 opType; -- present in pubdata, ignored at serialization
        //uint32 initiatorAccountId; -- present in pubdata, ignored at serialization
        //uint32 targetAccountId; -- present in pubdata, ignored at serialization
        uint16 tokenId;
        uint128 amount;
        //uint16 fee; -- present in pubdata, ignored at serialization
        address target;
    }

    function readForcedExitPubdata(bytes memory _data) internal pure returns (ForcedExit memory parsed) {
        // NOTE: there is no check that variable sizes are same as constants (i.e. TOKEN_BYTES), fix if possible.
        uint256 offset = OP_TYPE_BYTES + ACCOUNT_ID_BYTES * 2; // opType + initiatorAccountId + targetAccountId (ignored)
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        offset += FEE_BYTES; // fee (ignored)
        (offset, parsed.target) = Bytes.readAddress(_data, offset); // target
    }

    // ChangePubKey
    enum ChangePubkeyType {ECRECOVER, CREATE2, OldECRECOVER}

    struct ChangePubKey {
        // uint8 opType; -- present in pubdata, ignored at serialization
        uint32 accountId;
        bytes20 pubKeyHash;
        address owner;
        uint32 nonce;
        //uint16 tokenId; -- present in pubdata, ignored at serialization
        //uint16 fee; -- present in pubdata, ignored at serialization
    }

    function readChangePubKeyPubdata(bytes memory _data) internal pure returns (ChangePubKey memory parsed) {
        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.pubKeyHash) = Bytes.readBytes20(_data, offset); // pubKeyHash
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        (offset, parsed.nonce) = Bytes.readUInt32(_data, offset); // nonce
    }

    // CreatePair pubdata
    // NEW ADD
    struct CreatePair {
        // uint8 opType; -- present in pubdata, ignored at serialization
        uint32 accountId;
        uint16 tokenA;
        uint16 tokenB;
        uint16 tokenPair;
        address pair;
    }
    // NEW ADD
    uint256 public constant PACKED_CREATE_PAIR_PUBDATA_BYTES =
        OP_TYPE_BYTES + ACCOUNT_ID_BYTES + TOKEN_BYTES + TOKEN_BYTES + TOKEN_BYTES + ADDRESS_BYTES;

    // NEW ADD
    function readCreatePairPubdata(bytes memory _data) internal pure returns (CreatePair memory parsed)
    {
        uint256 offset = OP_TYPE_BYTES; // opType
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenA) = Bytes.readUInt16(_data, offset); // tokenAId
        (offset, parsed.tokenB) = Bytes.readUInt16(_data, offset); // tokenBId
        (offset, parsed.tokenPair) = Bytes.readUInt16(_data, offset); // pairId
        (offset, parsed.pair) = Bytes.readAddress(_data, offset); // pairId
        require(offset == PACKED_CREATE_PAIR_PUBDATA_BYTES, "rcp10"); // reading invalid create pair pubdata size
    }

    // NEW ADD
    function writeCreatePairPubdata(CreatePair memory op) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            OpType.CreatePair,
            bytes4(0),      // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenA,      // tokenAId
            op.tokenB,      // tokenBId
            op.tokenPair,   // pairId
            op.pair         // pair account
        );
    }

    function checkCreatePairInPriorityQueue(CreatePair memory op, bytes20 hashedPubdata) internal pure returns (bool) {
        return Utils.hashBytesToBytes20(writeCreatePairPubdata(op)) == hashedPubdata;
    }

}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/// @title Interface of the upgradeable master contract (defines notice period duration and allows finish upgrade during preparation of it)
/// @author Matter Labs
interface UpgradeableMaster {
    /// @notice Notice period before activation preparation status of upgrade mode
    function getNoticePeriod() external returns (uint256);

    /// @notice Notifies contract that notice period started
    function upgradeNoticePeriodStarted() external;

    /// @notice Notifies contract that upgrade preparation status is activated
    function upgradePreparationStarted() external;

    /// @notice Notifies contract that upgrade canceled
    function upgradeCanceled() external;

    /// @notice Notifies contract that upgrade finishes
    function upgradeFinishes() external;

    /// @notice Checks that contract is ready for upgrade
    /// @return bool flag indicating that contract is ready for upgrade
    function isReadyForUpgrade() external returns (bool);
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



contract PairTokenManager {
    /// @dev Max amount of pair tokens registered in the network.
    /// This is computed by: 2048 - 512 = 1536
    uint16 constant MAX_AMOUNT_OF_PAIR_TOKENS = 1536;
    uint16 constant PAIR_TOKEN_START_ID = 512;

    /// @dev Total number of pair tokens registered in the network
    uint16 public totalPairTokens;

    /// @dev List of registered tokens by tokenId
    mapping(uint16 => address) public tokenAddresses;

    /// @dev List of registered tokens by address
    mapping(address => uint16) public tokenIds;
    
    /// @dev Token added to Franklin net
    event NewToken(
        address indexed token,
        uint16 indexed tokenId
    );

    function addPairToken(address _token) internal {
        require(tokenIds[_token] == 0, "pan1"); // token exists
        require(totalPairTokens < MAX_AMOUNT_OF_PAIR_TOKENS, "pan2"); // no free identifiers for tokens
        uint16 newPairTokenId = PAIR_TOKEN_START_ID + totalPairTokens;
        totalPairTokens++;

        // tokenId -> token
        tokenAddresses[newPairTokenId] = _token;
        // token -> tokenId
        tokenIds[_token] = newPairTokenId;
        emit NewToken(_token, newPairTokenId);
    }

    /// @dev Validate pair token address
    /// @param _tokenAddr Token address
    /// @return tokens id
    function validatePairTokenAddress(address _tokenAddr) public view returns (uint16) {
        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "pms3");
        require(tokenId < (PAIR_TOKEN_START_ID + MAX_AMOUNT_OF_PAIR_TOKENS), "pms4");
        require(tokenId >= PAIR_TOKEN_START_ID, "pms5");
        return tokenId;
    }
}


pragma solidity ^0.7.0;

// : UNLICENSED


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {

    function symbol() external pure returns (string memory);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



//import"./Config.sol";

/// @title Governance Contract
/// @author Matter Labs
/// @author ZKSwap L2 Labs
/// @author Stars Labs
contract Governance is Config {
    /// @notice Token added to Franklin net
    event NewToken(address indexed token, uint16 indexed tokenId);

    /// @notice Governor changed
    event NewGovernor(address newGovernor);

    /// @notice Validator's status changed
    event ValidatorStatusUpdate(address indexed validatorAddress, bool isActive);

    event TokenPausedUpdate(address indexed token, bool paused);

    /// @notice Address which will exercise governance over the network i.e. add tokens, change validator set, conduct upgrades
    address public networkGovernor;

    /// @notice Total number of ERC20 tokens registered in the network (excluding ETH, which is hardcoded as tokenId = 0)
    uint16 public totalTokens;

    /// @notice List of registered tokens by tokenId
    mapping(uint16 => address) public tokenAddresses;

    /// @notice List of registered tokens by address
    mapping(address => uint16) public tokenIds;

    /// @notice List of permitted validators
    mapping(address => bool) public validators;

    /// @notice Paused tokens list, deposits are impossible to create for paused tokens
    mapping(uint16 => bool) public pausedTokens;

    /// @notice Governance contract initialization. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param initializationParameters Encoded representation of initialization parameters:
    ///     _networkGovernor The address of network governor
    function initialize(bytes calldata initializationParameters) external {
        address _networkGovernor = abi.decode(initializationParameters, (address));

        networkGovernor = _networkGovernor;
    }

    /// @notice Governance contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external {}

    /// @notice Change current governor
    /// @param _newGovernor Address of the new governor
    function changeGovernor(address _newGovernor) external {
        requireGovernor(msg.sender);
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    /// @notice Add token to the list of networks tokens
    /// @param _token Token address
    function addToken(address _token) external {
        requireGovernor(msg.sender);
        require(_token != address(0), "1e0");
        require(tokenIds[_token] == 0, "1e"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "1f"); // no free identifiers for tokens

        totalTokens++;
        uint16 newTokenId = totalTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        // tokenId -> token
        tokenAddresses[newTokenId] = _token;
        // token -> tokenId
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    /// @notice Pause token deposits for the given token
    /// @param _tokenAddr Token address
    /// @param _tokenPaused Token paused status
    function setTokenPaused(address _tokenAddr, bool _tokenPaused) external {
        requireGovernor(msg.sender);

        uint16 tokenId = this.validateTokenAddress(_tokenAddr);
        if (pausedTokens[tokenId] != _tokenPaused) {
            pausedTokens[tokenId] = _tokenPaused;
            emit TokenPausedUpdate(_tokenAddr, _tokenPaused);
        }
    }

    /// @notice Change validator status (active or not active)
    /// @param _validator Validator address
    /// @param _active Active flag
    function setValidator(address _validator, bool _active) external {
        requireGovernor(msg.sender);
        if (validators[_validator] != _active) {
            validators[_validator] = _active;
            emit ValidatorStatusUpdate(_validator, _active);
        }
    }

    /// @notice Check if specified address is is governor
    /// @param _address Address to check
    function requireGovernor(address _address) public view {
        require(_address == networkGovernor, "1g"); // only by governor
    }

    /// @notice Checks if validator is active
    /// @param _address Validator address
    function requireActiveValidator(address _address) external view {
        require(validators[_address], "1h"); // validator is not active
    }

    /// @notice Validate token id (must be less than or equal to total tokens amount)
    /// @param _tokenId Token id
    /// @return bool flag that indicates if token id is less than or equal to total tokens amount
    function isValidTokenId(uint16 _tokenId) external view returns (bool) {
        return _tokenId <= totalTokens;
    }

    /// @notice Validate token address
    /// @param _tokenAddr Token address
    /// @return tokens id
    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {
        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "1i"); // 0 is not a valid token
        return tokenId;
    }
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0




//import"./KeysWithPlonkVerifier.sol";
//import"./Config.sol";

// Hardcoded constants to avoid accessing store
contract Verifier is KeysWithPlonkVerifier, Config {
    function initialize(bytes calldata) external {}

    /// @notice Verifier contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external {}

    function verifyAggregatedBlockProof(
        uint256[] memory _recursiveInput,
        uint256[] memory _proof,
        uint8[] memory _vkIndexes,
        uint256[] memory _individual_vks_inputs,
        uint256[16] memory _subproofs_limbs
    ) external view returns (bool) {
        for (uint256 i = 0; i < _individual_vks_inputs.length; ++i) {
            uint256 commitment = _individual_vks_inputs[i];
            _individual_vks_inputs[i] = commitment & INPUT_MASK;
        }
        VerificationKey memory vk = getVkAggregated(uint32(_vkIndexes.length));

        return
        verify_serialized_proof_with_recursion(
            _recursiveInput,
            _proof,
            VK_TREE_ROOT,
            VK_MAX_INDEX,
            _vkIndexes,
            _individual_vks_inputs,
            _subproofs_limbs,
            vk
        );
    }
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0




//import"./KeysWithPlonkVerifier.sol";
//import"./Config.sol";

// Hardcoded constants to avoid accessing store
contract VerifierExit is KeysWithPlonkVerifierOld, Config {
    function initialize(bytes calldata) external {}

    /// @notice Verifier contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external {}

    function verifyExitProof(
        bytes32 _rootHash,
        uint32 _accountId,
        address _owner,
        uint16 _tokenId,
        uint128 _amount,
        uint256[] calldata _proof
    ) external view returns (bool) {
        bytes32 commitment =
        sha256(abi.encodePacked(uint256(_rootHash) , _accountId, _owner, _tokenId, _amount));

        uint256[] memory inputs = new uint256[](1);
        inputs[0] = uint256(commitment) & INPUT_MASK;
        ProofOld memory proof = deserialize_proof_old(inputs, _proof);
        VerificationKeyOld memory vk = getVkExit();
        require(vk.num_inputs == inputs.length);
        return verify_old(proof, vk);
    }

    function concatBytes(bytes memory param1, bytes memory param2) public pure returns (bytes memory) {
        bytes memory merged = new bytes(param1.length + param2.length);

        uint k = 0;
        for (uint i = 0; i < param1.length; i++) {
            merged[k] = param1[i];
            k++;
        }

        for (uint i = 0; i < param2.length; i++) {
            merged[k] = param2[i];
            k++;
        }
        return merged;
    }

    function verifyLpExitProof(
        bytes calldata _account_data,
        bytes calldata _token_data,
        uint256[] calldata _proof
    ) external view returns (bool) {
        bytes memory commit_data = concatBytes(_account_data, _token_data);
        bytes32 commitment = sha256(commit_data);

        uint256[] memory inputs = new uint256[](1);

        inputs[0] = uint256(commitment) & INPUT_MASK;
        ProofOld memory proof = deserialize_proof_old(inputs, _proof);
        VerificationKeyOld memory vk = getVkExitLp();
        require(vk.num_inputs == inputs.length);
        return verify_old(proof, vk);
    }
}


pragma solidity ^0.7.0;



//import'./UniswapV2Pair.sol';
//import"../IERC20.sol";

/// @author ZKSwap L2 Labs
/// @author Stars Labs
contract UniswapV2Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address public zkSyncAddress;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor() {}

    function initialize(bytes calldata data) external {}

    function setZkSyncAddress(address _zksyncAddress) external {
        require(zkSyncAddress == address(0), "szsa1");
        zkSyncAddress = _zksyncAddress;
    }

    /// @notice PairManager contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external {}

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address tokenA, address tokenB, bytes32 _salt) external view returns (address pair) {
        require(msg.sender == zkSyncAddress, 'fcp2');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, _salt));

        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                address(this),
                salt,
                keccak256(bytecode)
            ))));
    }

    function createPair(address tokenA, address tokenB, bytes32 _salt) external returns (address pair) {
        require(msg.sender == zkSyncAddress, 'fcp1');
        require(tokenA != tokenB ||
                keccak256(abi.encodePacked(IERC20(tokenA).symbol())) == keccak256(abi.encodePacked("EGS")),
                'UniswapV2: IDENTICAL_ADDRESSES');

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, _salt));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        require(zkSyncAddress != address(0), 'wzk');
        UniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function mint(address pair, address to, uint256 amount) external {
        require(msg.sender == zkSyncAddress, 'fmt1');
        UniswapV2Pair(pair).mint(to, amount);
    }

    function burn(address pair, address to, uint256 amount) external {
        require(msg.sender == zkSyncAddress, 'fbr1');
        UniswapV2Pair(pair).burn(to, amount);
    }
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0





//import"./PlonkCore.sol";

// Hardcoded constants to avoid accessing store
contract KeysWithPlonkVerifier is VerifierWithDeserialize {

    uint256 constant VK_TREE_ROOT = 0x108678a23c44e8c0b590d3204fa7b710b4e74e590722c4d1f42cd1e6744bf4d3;
    uint8 constant VK_MAX_INDEX = 3;

    function getVkAggregated(uint32 _proofs) internal pure returns (VerificationKey memory vk) {
        if (_proofs == uint32(1)) { return getVkAggregated1(); }
        else if (_proofs == uint32(4)) { return getVkAggregated4(); }
        else if (_proofs == uint32(8)) { return getVkAggregated8(); }
        else if (_proofs == uint32(18)) { return getVkAggregated18(); }
    }


    function getVkAggregated1() internal pure returns(VerificationKey memory vk) {
        vk.domain_size = 4194304;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x18c95f1ae6514e11a1b30fd7923947c5ffcec5347f16e91b4dd654168326bede);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x19fbd6706b4cbde524865701eae0ae6a270608a09c3afdab7760b685c1c6c41b,
            0x25082a191f0690c175cc9af1106c6c323b5b5de4e24dc23be1e965e1851bca48
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x16c02d9ca95023d1812a58d16407d1ea065073f02c916290e39242303a8a1d8e,
            0x230338b422ce8533e27cd50086c28cb160cf05a7ae34ecd5899dbdf449dc7ce0
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x1db0d133243750e1ea692050bbf6068a49dc9f6bae1f11960b6ce9e10adae0f5,
            0x12a453ed0121ae05de60848b4374d54ae4b7127cb307372e14e8daf5097c5123
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x1062ed5e86781fd34f78938e5950c2481a79f132085d2bc7566351ddff9fa3b7,
            0x2fd7aac30f645293cc99883ab57d8c99a518d5b4ab40913808045e8653497346
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x062755048bb95739f845e8659795813127283bf799443d62fea600ae23e7f263,
            0x2af86098beaa241281c78a454c5d1aa6e9eedc818c96cd1e6518e1ac2d26aa39
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x0994e25148bbd25be655034f81062d1ebf0a1c2b41e0971434beab1ae8101474,
            0x27cc8cfb1fafd13068aeee0e08a272577d89f8aa0fb8507aabbc62f37587b98f
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x044edf69ce10cfb6206795f92c3be2b0d26ab9afd3977b789840ee58c7dbe927,
            0x2a8aa20c106f8dc7e849bc9698064dcfa9ed0a4050d794a1db0f13b0ee3def37
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x136967f1a2696db05583a58dbf8971c5d9d1dc5f5c97e88f3b4822aa52fefa1c,
            0x127b41299ea5c840c3b12dbe7b172380f432b7b63ce3b004750d6abb9e7b3b7a
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x02fd5638bf3cc2901395ad1124b951e474271770a337147a2167e9797ab9d951,
            0x0fcb2e56b077c8461c36911c9252008286d782e96030769bf279024fc81d412a
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x1865c60ecad86f81c6c952445707203c9c7fdace3740232ceb704aefd5bd45b3,
            0x2f35e29b39ec8bb054e2cff33c0299dd13f8c78ea24a07622128a7444aba3f26
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x2a86ec9c6c1f903650b5abbf0337be556b03f79aecc4d917e90c7db94518dde6,
            0x15b1b6be641336eebd58e7991be2991debbbd780e70c32b49225aa98d10b7016
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x213e42fcec5297b8e01a602684fcd412208d15bdac6b6331a8819d478ba46899,
            0x03223485f4e808a3b2496ae1a3c0dfbcbf4391cffc57ee01e8fca114636ead18
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x2e9b02f8cf605ad1a36e99e990a07d435de06716448ad53053c7a7a5341f71e1,
            0x2d6fdf0bc8bd89112387b1894d6f24b45dcb122c09c84344b6fc77a619dd1d59
        );
        vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
            0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
            0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }

    function getVkAggregated4() internal pure returns(VerificationKey memory vk) {
        vk.domain_size = 8388608;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x1283ba6f4b7b1a76ba2008fe823128bea4adb9269cbfd7c41c223be65bc60863);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x2988e24b15bce9a1e3a4d1d9a8f7c7a65db6c29fd4c6f4afe1a3fbd954d4b4b6,
            0x0bdb6e5ba27a22e03270c7c71399b866b28d7cec504d30e665d67be58e306e12
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x20f3d30d3a91a7419d658f8c035e42a811c9f75eac2617e65729033286d36089,
            0x07ac91e8194eb78a9db537e9459dd6ca26bef8770dde54ac3dd396450b1d4cfe
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x0311872bab6df6e9095a9afe40b12e2ed58f00cc88835442e6b4cf73fb3e147d,
            0x2cdfc5b5e73737809b54644b2f96494f8fcc1dd0fb440f64f44930b432c4542d
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x28fd545b1e960d2eff3142271affa4096ef724212031fdabe22dd4738f36472b,
            0x2c743150ee9894ff3965d8f1129399a3b89a1a9289d4cfa904b0a648d3a8a9fa
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x2c283ce950eee1173b78657e57c80658a8398e7970a9a45b20cd39aff16ad61a,
            0x081c003cbd09f7c3e0d723d6ebbaf432421c188d5759f5ee8ff1ee1dc357d4a8
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x2eb50a2dd293a71a0c038e958c5237bd7f50b2f0c9ee6385895a553de1517d43,
            0x15fdc2b5b28fc351f987b98aa6caec7552cefbafa14e6651061eec4f41993b65
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x17a9403e5c846c1ca5e767c89250113aa156fdb1f026aa0b4db59c09d06816ec,
            0x2512241972ca3ee4839ac72a4cab39ddb413a7553556abd7909284b34ee73f6b
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x09edd69c8baa7928b16615e993e3032bc8cbf9f42bfa3cf28caba1078d371edb,
            0x12e5c39148af860a87b14ae938f33eafa91deeb548cda4cc23ed9ba3e6e496b8
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x0e25c0027706ca3fd3daae849f7c50ec88d4d030da02452001dec7b554cc71b4,
            0x2421da0ca385ff7ba9e5ae68890655669248c8c8187e67d12b2a7ae97e2cff8b
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x151536359fe184567bce57379833f6fae485e5cc9bc27423d83d281aaf2701df,
            0x116beb145bc27faae5a8ae30c28040d3baafb3ea47360e528227b94adb9e4f26
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x23ee338093db23364a6e44acfb60d810a4c4bd6565b185374f7840152d3ae82c,
            0x0f6714f3ee113b9dfb6b653f04bf497602588b16b96ac682d9a5dd880a0aa601
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x05860b0ea3c6f22150812aee304bf35e1a95cfa569a8da52b42dba44a122378a,
            0x19e5a9f3097289272e65e842968752c5355d1cdb2d3d737050e4dfe32ebe1e41
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x3046881fcbe369ac6f99fea8b9505de85ded3de3bc445060be4bc6ef651fa352,
            0x06fe14c1dd6c2f2b48aebeb6fd525573d276b2e148ad25e75c57a58588f755ec
        );
        vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
            0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
            0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }

    function getVkAggregated8() internal pure returns(VerificationKey memory vk) {
        vk.domain_size = 16777216;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x1951441010b2b95a6e47a6075066a50a036f5ba978c050f2821df86636c0facb);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x218bdb295b7207114aeea948e2d3baef158d4057812f94005d8ff54341b6ce6f,
            0x1398585c039ba3cf336687301e95fbbf6b0638d31c64b1d815bb49091d0c1aad
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x2e40b8a98e688c9e00f607a64520a850d35f277dc0b645628494337bb75870e8,
            0x2da4ef753cc4869e53cff171009dbffea9166b8ffbafd17783d712278a79f13e
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x1b638de3c6cc2e0badc48305ee3533678a45f52edf30277303551128772303a2,
            0x2794c375cbebb7c28379e8abf42d529a1c291319020099935550c83796ba14ac
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x189cd01d67b44cf2c1e10765c69adaafd6a5929952cf55732e312ecf00166956,
            0x15976c99ef2c911bd3a72c9613b7fe9e66b03dd8963bfed705c96e3e88fdb1af
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x0745a77052dc66afc61163ec3737651e5b846ca7ec7fae1853515d0f10a51bd9,
            0x2bd27ecf4fb7f5053cc6de3ddb7a969fac5150a6fb5555ca917d16a7836e4c0a
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x2787aea173d07508083893b02ea962be71c3b628d1da7d7c4db0def49f73ad8f,
            0x22fdc951a97dc2ac7d8292a6c263898022f4623c643a56b9265b33c72e628886
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x0aafe35c49634858e44e9af259cac47a6f8402eb870f9f95217dcb8a33a73e64,
            0x1b47a7641a7c918784e84fc2494bfd8014ebc77069b94650d25cb5e25fbb7003
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x11cfc3fe28dfd5d663d53ceacc5ec620da85ae5aa971f0f003f57e75cd05bf9f,
            0x28b325f30984634fc46c6750f402026d4ff43e5325cbe34d35bf8ac4fc9cc533
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x2ada816636b9447def36e35dd3ab0e3f7a8bbe3ae32a5a4904dee3fc26e58015,
            0x2cd12d1a50aaadef4e19e1b1955c932e992e688c2883da862bd7fad17aae66f6
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x20cc506f273be4d114cbf2807c14a769d03169168892e2855cdfa78c3095c89d,
            0x08f99d338aee985d780d036473c624de9fd7960b2a4a7ad361c8c125cf11899e
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x01260265d3b1167eac1030f3d04326f08a1f2bb1e026e54afec844e3729386e2,
            0x16d75b53ec2552c63e84ea5f4bfe1507c3198045875457c1d9295d6699f39d56
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x1f4d73c63d163c3f5ef1b5caa41988cacbdbca38334e8f54d7ee9bbbb622e200,
            0x2f48f5f93d9845526ef0348f1c3def63cfc009645eb2a95d1746c7941e888a78
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x1dbd386fe258366222becc570a7f6405b25ff52818b93bdd54eaa20a6b22025a,
            0x2b2b4e978ac457d752f50b02609bd7d2054286b963821b2ec7cd3dd1507479fa
        );
        vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
            0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
            0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }

    function getVkAggregated18() internal pure returns(VerificationKey memory vk) {
        vk.domain_size = 33554432;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0d94d63997367c97a8ed16c17adaae39262b9af83acb9e003f94c217303dd160);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x0eab7c0217fbc357eb9e2622da6e5df9a99e5fa8dbaaf6b45a7136bbc49704c0,
            0x00199f1c9e2ef5efbec5e3792cb6db0d6211e2da57e2e5a7cf91fb4037bd0013
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x020c5ecdbb37b9f99b131cdfd0fec8c5565985599093db03d85a9bcd75a8a186,
            0x0be3b767834382739f1309adedb540ce5261b7038c168d32619a6e6333974b1b
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x092fc8636803f28250ac33b8ea688b37cf0718f83c82a1ce7bca70e7c8643b93,
            0x10c907fcb34fb6e9d4e334428e8226ba84e5977a7dc1ada2509cc6cf445123ca
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x1f66b77eaae034cf3646e0c32418a1dfecb3bf090cc271aad0d64ba327758b29,
            0x2b8766fbe83c45b39e274998a000cf59e7332800025e7af711368c6b7ea11cd9
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x017336a15f6e61def3ec02f139a0972c4272e126ac40d49ed10d447db6857643,
            0x22cc7cb62310a031acd86dd1a9ea18ee55e1b6a4fbf1c2d64ca9a7cc6458ed7a
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x057992ff5d056557b795ab7e6964fab546fdcd8b5c1d3718e4f619e1091ef9a0,
            0x026916de04486781c504fb054e0b3755dd4836b610973e0ca092b35810ed3698
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x252a53377145970214c9af5cd95c5fdd72e4d890b96d5ab31ef7736b2280aaa3,
            0x2a1ccbea423d1a58325c4d0e5aa01a6a2a7c7fbaa61fb8f3669f720dfb4dfd4d
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x17da1e8102c91916c778e89d737bdc8a14f4dfcf14fc89896f921dfc81e98556,
            0x1b9571239471b65bc5d4bcc3b1b3831bcc6986ad4d1417292dc3067ae632b796
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x242b5b8848746eb790629cf0853e256249d83cad8e189d474ed3a5c56b5a92be,
            0x2ca4e4882f0d7408ba134458945a2dd7cbced64e735fd42c9204eaf8608c58cc
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x281ccb20cea7001ae0d3ef5deedc46db687f1493cd77631dc2c16275b96f677a,
            0x24bede6b53ee4762939dbabb5947023d3ab31b00a1d14bcb6a5da69d7ce0d67e
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x1e72df4c2223fb15e72862350f51994b7f381a829a00b21535b04e8c342c15e7,
            0x22b7bb45c2e3b957952824beee1145bfcb5d2c575636266ad44032c1ae24e1ea
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x0059ea736670b355b3b6479db53d9b19727aa128514dee7d6c6788e80233452f,
            0x24718998fb0ff667c66457f6558ff028352b2d55cb86a07a0c11fc3c2753df38
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x0bee5ac3770c7603b2ccbc9e10a0ceafa231e77dde3fd6b9d514958ae7c200e8,
            0x11339336bbdafda32635c143b7bd0c4cdb7b7948489d75240c89ca2a440ef39c
        );
        vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
            0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
            0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }


}

// Hardcoded constants to avoid accessing store
contract KeysWithPlonkVerifierOld is VerifierWithDeserializeOld {


    function getVkExit() internal pure returns(VerificationKeyOld memory vk) {
        vk.domain_size = 262144;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0f60c8fe0414cb9379b2d39267945f6bd60d06a05216231b26a9fcf88ddbfebe);
        vk.selector_commitments[0] = PairingsBn254.new_g1(
            0x1775efa56023e26c6298b2775481c0add1d64120dd242eb7e66cfebe43a8689d,
            0x0adc370e09dc4bfcd73bf48ac1735363d2801dc50b903b950c2259cfec908422
        );
        vk.selector_commitments[1] = PairingsBn254.new_g1(
            0x1af5b8c0863df35aa93be8f75480bb8c4ad103993c05408856365dce2151cf72,
            0x2aa95351d73b68ca33f9a8451cafeca8d9b66b9a5253b1196714d2d55f18c74e
        );
        vk.selector_commitments[2] = PairingsBn254.new_g1(
            0x1a83514953af1d12f597ae8e159a69efdb4a19bc448f9bc3c100a5d27ab66467,
            0x2e739d3240d665dba7ba612ca8548a2817ef3b26a5e31afd66121179860fb367
        );
        vk.selector_commitments[3] = PairingsBn254.new_g1(
            0x10fdde5088f9df8c2af09166c3e1d2aaf5bedaaf14095a81680285a7ea9a3207,
            0x03cb4d015d2c8ab50e6e15c59aaeb0cc6f9dba3731c06513df9c3f77dcc7a75b
        );
        vk.selector_commitments[4] = PairingsBn254.new_g1(
            0x2e5f67efb618542c634c0cfef443d3ae7d57621fcc487e643d9174b1982ca106,
            0x2a7761839026029cb215da80cfe536a4d6f7e993a749e21a0c430a455a6f6477
        );
        vk.selector_commitments[5] = PairingsBn254.new_g1(
            0x14ee91feb802eea1204e0b4faf96bd000d03e03a253e68f5e44e46880327eaa3,
            0x1adfa909fe1008687d3867162b18aa895eed7a5dd10eeeee8d93876f9972f794
        );

        // we only have access to value of the d(x) witness polynomial on the next
        // trace step, so we only need one element here and deal with it in other places
        // by having this in mind
        vk.next_step_selector_commitments[0] = PairingsBn254.new_g1(
            0x218b439287375a3f3cc2cad85805b47be7a0c5e8dd43c8c42305f7cb3d153fea,
            0x1f94bb4131aee078b207615def18b0f2e94a966ce230fb1837df244657b06b60
        );

        vk.permutation_commitments[0] = PairingsBn254.new_g1(
            0x0dc7db7aea2ef0f5d3b072faeaaee44bb1a79715e977bf87321d210140f4b443,
            0x2ceb58346301f008a7553fe2851524e613d8060f309def3239494c2ac4722b99
        );
        vk.permutation_commitments[1] = PairingsBn254.new_g1(
            0x1d4ee99264d715b08b84286e6c979c47446b2cab86f6bb06d937e1d64814a322,
            0x2cf40326362bbc1531e3d32e844e2986484ad74fac2b7e5c10bc5375f39dd271
        );
        vk.permutation_commitments[2] = PairingsBn254.new_g1(
            0x20ffb570ec9e40ec87c2df09ec417e301d44db21323e2440134844a0d6aa18cf,
            0x2d45d5f1e6fcfed9239d8f464c02a815498261b9a3edec9f4e1cd2058425aa96
        );
        vk.permutation_commitments[3] = PairingsBn254.new_g1(
            0x28f43e5e320de920d29b0eabd68b6b93ea8beb12f35310b96b63ece18b8d99d3,
            0x206324d60731845d125e4869c90ae15be2d160886b91bf3c316ac59af0688b6e
        );

        vk.permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1, 0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4, 0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }



    function getVkExitLp() internal pure returns(VerificationKeyOld memory vk) {
        vk.domain_size = 262144;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0f60c8fe0414cb9379b2d39267945f6bd60d06a05216231b26a9fcf88ddbfebe);
        vk.selector_commitments[0] = PairingsBn254.new_g1(
            0x15a418864253e30d92e0af8f44c45679ab52bb172c65bd1ca649bd352c55eb2f,
            0x25d9ce8e852566a5a460653a634708f768f61da8bd3b986ac022cff0067011c2
        );
        vk.selector_commitments[1] = PairingsBn254.new_g1(
            0x2a7b4444d1b2eaad9dbd93c6bbae7d133fbaf0f71e3e769d35a379e63be37a97,
            0x1420d2079a52ce83ee6b498e8a3fa498ec3bd48b92894a17996dfd23fbab90e3
        );
        vk.selector_commitments[2] = PairingsBn254.new_g1(
            0x17ad336a0139401277e75660ef40b0f07347f6d72d6b143e485953fc896cce9a,
            0x227fcdd90c6dfc955c796e544e8bf0ea243e2ce0022e563716a5153260ceea6d
        );
        vk.selector_commitments[3] = PairingsBn254.new_g1(
            0x2c115c4700fc64f25ac77ba471b1dd5128c439163555331e1078cd6ee5627ba0,
            0x2066980b107e6f2fa8160aaa88cb90113d2fd94ad62cd3366848c6746afa6acf
        );
        vk.selector_commitments[4] = PairingsBn254.new_g1(
            0x256677a67eca0e07a491e652e8e529e9d61e8833a7f90e8c2f1cdb6872260115,
            0x0d1f62a5228c35e872a1146944c383d2d2d16dca4e8875bbf70f4d4b8834b6f5
        );
        vk.selector_commitments[5] = PairingsBn254.new_g1(
            0x1b041e5c782b57147cdfc17aad8b5881ebf895b75cf9d97f45c592f4dcfe640d,
            0x01fbc948fd4701103a10bd5fee07fae81481e4f9ca90e36bd12c2ecfb1768b71
        );

        // we only have access to value of the d(x) witness polynomial on the next
        // trace step, so we only need one element here and deal with it in other places
        // by having this in mind
        vk.next_step_selector_commitments[0] = PairingsBn254.new_g1(
            0x24d84ac5c820acc4ee6b6062092adc108c640a5750d837b28e5044bf992b45ef,
            0x1faacb531160847bb4712202ee2b15a102084c24a2a8da1b687df5de8b2b6dd1
        );

        vk.permutation_commitments[0] = PairingsBn254.new_g1(
            0x28b25ca568d481180c47ff7f7beb6fa426c033c201a140c71cc5bbd090a69474,
            0x0bc1b33a8d4a834cdb5b40ba275e2b33089120239abf4f9ffce983d1cfc9a85a
        );
        vk.permutation_commitments[1] = PairingsBn254.new_g1(
            0x11012d815b96d6f9c95a50dd658f45d443472ee0432045f980f2c2745e4c3847,
            0x235e2e22940391f97fcedda2690f3265ec813a964f95475f282c0f16602c1fb4
        );
        vk.permutation_commitments[2] = PairingsBn254.new_g1(
            0x2d7bb392ede616e3832f054a5ef35562522585563f1e978cbd3732069bcf4a24,
            0x2b97bf5dd09f2765a35f1eeb2936767c20095d03666c1a5948544a74289a51df
        );
        vk.permutation_commitments[3] = PairingsBn254.new_g1(
            0x0c3808600cf3d62ade4d2bb6cb856117f717ccd2a5cd2d549cdae1ad86bbb12b,
            0x20827819d88e1dac7cd8f7cd1abce9eff8e9c936dbd305c364f0337298daa5b9
        );

        vk.permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1, 0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4, 0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }

}


pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0




library PairingsBn254 {
    uint256 constant q_mod = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 constant r_mod = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant bn254_b_coeff = 3;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct Fr {
        uint256 value;
    }

    function new_fr(uint256 fr) internal pure returns (Fr memory) {
        require(fr < r_mod);
        return Fr({value: fr});
    }

    function copy(Fr memory self) internal pure returns (Fr memory n) {
        n.value = self.value;
    }

    function assign(Fr memory self, Fr memory other) internal pure {
        self.value = other.value;
    }

    function inverse(Fr memory fr) internal view returns (Fr memory) {
        require(fr.value != 0);
        return pow(fr, r_mod - 2);
    }

    function add_assign(Fr memory self, Fr memory other) internal pure {
        self.value = addmod(self.value, other.value, r_mod);
    }

    function sub_assign(Fr memory self, Fr memory other) internal pure {
        self.value = addmod(self.value, r_mod - other.value, r_mod);
    }

    function mul_assign(Fr memory self, Fr memory other) internal pure {
        self.value = mulmod(self.value, other.value, r_mod);
    }

    function pow(Fr memory self, uint256 power) internal view returns (Fr memory) {
        uint256[6] memory input = [32, 32, 32, self.value, power, r_mod];
        uint256[1] memory result;
        bool success;
        assembly {
            success := staticcall(gas(), 0x05, input, 0xc0, result, 0x20)
        }
        require(success);
        return Fr({value: result[0]});
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    function new_g1(uint256 x, uint256 y) internal pure returns (G1Point memory) {
        return G1Point(x, y);
    }

    function new_g1_checked(uint256 x, uint256 y) internal pure returns (G1Point memory) {
        if (x == 0 && y == 0) {
            // point of infinity is (0,0)
            return G1Point(x, y);
        }

        // check encoding
        require(x < q_mod);
        require(y < q_mod);
        // check on curve
        uint256 lhs = mulmod(y, y, q_mod); // y^2
        uint256 rhs = mulmod(x, x, q_mod); // x^2
        rhs = mulmod(rhs, x, q_mod); // x^3
        rhs = addmod(rhs, bn254_b_coeff, q_mod); // x^3 + b
        require(lhs == rhs);

        return G1Point(x, y);
    }

    function new_g2(uint256[2] memory x, uint256[2] memory y) internal pure returns (G2Point memory) {
        return G2Point(x, y);
    }

    function copy_g1(G1Point memory self) internal pure returns (G1Point memory result) {
        result.X = self.X;
        result.Y = self.Y;
    }

    function P2() internal pure returns (G2Point memory) {
        // for some reason ethereum expects to have c1*v + c0 form

        return
        G2Point(
            [
            0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2,
            0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed
            ],
            [
            0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b,
            0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa
            ]
        );
    }

    function negate(G1Point memory self) internal pure {
        // The prime q in the base field F_q for G1
        if (self.Y == 0) {
            require(self.X == 0);
            return;
        }

        self.Y = q_mod - self.Y;
    }

    function point_add(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        point_add_into_dest(p1, p2, r);
        return r;
    }

    function point_add_assign(G1Point memory p1, G1Point memory p2) internal view {
        point_add_into_dest(p1, p2, p1);
    }

    function point_add_into_dest(
        G1Point memory p1,
        G1Point memory p2,
        G1Point memory dest
    ) internal view {
        if (p2.X == 0 && p2.Y == 0) {
            // we add zero, nothing happens
            dest.X = p1.X;
            dest.Y = p1.Y;
            return;
        } else if (p1.X == 0 && p1.Y == 0) {
            // we add into zero, and we add non-zero point
            dest.X = p2.X;
            dest.Y = p2.Y;
            return;
        } else {
            uint256[4] memory input;

            input[0] = p1.X;
            input[1] = p1.Y;
            input[2] = p2.X;
            input[3] = p2.Y;

            bool success = false;
            assembly {
                success := staticcall(gas(), 6, input, 0x80, dest, 0x40)
            }
            require(success);
        }
    }

    function point_sub_assign(G1Point memory p1, G1Point memory p2) internal view {
        point_sub_into_dest(p1, p2, p1);
    }

    function point_sub_into_dest(
        G1Point memory p1,
        G1Point memory p2,
        G1Point memory dest
    ) internal view {
        if (p2.X == 0 && p2.Y == 0) {
            // we subtracted zero, nothing happens
            dest.X = p1.X;
            dest.Y = p1.Y;
            return;
        } else if (p1.X == 0 && p1.Y == 0) {
            // we subtract from zero, and we subtract non-zero point
            dest.X = p2.X;
            dest.Y = q_mod - p2.Y;
            return;
        } else {
            uint256[4] memory input;

            input[0] = p1.X;
            input[1] = p1.Y;
            input[2] = p2.X;
            input[3] = q_mod - p2.Y;

            bool success = false;
            assembly {
                success := staticcall(gas(), 6, input, 0x80, dest, 0x40)
            }
            require(success);
        }
    }

    function point_mul(G1Point memory p, Fr memory s) internal view returns (G1Point memory r) {
        point_mul_into_dest(p, s, r);
        return r;
    }

    function point_mul_assign(G1Point memory p, Fr memory s) internal view {
        point_mul_into_dest(p, s, p);
    }

    function point_mul_into_dest(
        G1Point memory p,
        Fr memory s,
        G1Point memory dest
    ) internal view {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s.value;
        bool success;
        assembly {
            success := staticcall(gas(), 7, input, 0x60, dest, 0x40)
        }
        require(success);
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        }
        require(success);
        return out[0] != 0;
    }

    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
}

library TranscriptLibrary {
    // flip                    0xe000000000000000000000000000000000000000000000000000000000000000;
    uint256 constant FR_MASK = 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint32 constant DST_0 = 0;
    uint32 constant DST_1 = 1;
    uint32 constant DST_CHALLENGE = 2;

    struct Transcript {
        bytes32 state_0;
        bytes32 state_1;
        uint32 challenge_counter;
    }

    function new_transcript() internal pure returns (Transcript memory t) {
        t.state_0 = bytes32(0);
        t.state_1 = bytes32(0);
        t.challenge_counter = 0;
    }

    function update_with_u256(Transcript memory self, uint256 value) internal pure {
        bytes32 old_state_0 = self.state_0;
        self.state_0 = keccak256(abi.encodePacked(DST_0, old_state_0, self.state_1, value));
        self.state_1 = keccak256(abi.encodePacked(DST_1, old_state_0, self.state_1, value));
    }

    function update_with_fr(Transcript memory self, PairingsBn254.Fr memory value) internal pure {
        update_with_u256(self, value.value);
    }

    function update_with_g1(Transcript memory self, PairingsBn254.G1Point memory p) internal pure {
        update_with_u256(self, p.X);
        update_with_u256(self, p.Y);
    }

    function get_challenge(Transcript memory self) internal pure returns (PairingsBn254.Fr memory challenge) {
        bytes32 query = keccak256(abi.encodePacked(DST_CHALLENGE, self.state_0, self.state_1, self.challenge_counter));
        self.challenge_counter += 1;
        challenge = PairingsBn254.Fr({value: uint256(query) & FR_MASK});
    }
}

contract Plonk4VerifierWithAccessToDNext {
    uint256 constant r_mod = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    using PairingsBn254 for PairingsBn254.G1Point;
    using PairingsBn254 for PairingsBn254.G2Point;
    using PairingsBn254 for PairingsBn254.Fr;

    using TranscriptLibrary for TranscriptLibrary.Transcript;

    uint256 constant ZERO = 0;
    uint256 constant ONE = 1;
    uint256 constant TWO = 2;
    uint256 constant THREE = 3;
    uint256 constant FOUR = 4;

    uint256 constant STATE_WIDTH = 4;
    uint256 constant NUM_DIFFERENT_GATES = 2;
    uint256 constant NUM_SETUP_POLYS_FOR_MAIN_GATE = 7;
    uint256 constant NUM_SETUP_POLYS_RANGE_CHECK_GATE = 0;
    uint256 constant ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP = 1;
    uint256 constant NUM_GATE_SELECTORS_OPENED_EXPLICITLY = 1;

    uint256 constant RECURSIVE_CIRCUIT_INPUT_COMMITMENT_MASK =
    0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant LIMB_WIDTH = 68;

    struct VerificationKey {
        uint256 domain_size;
        uint256 num_inputs;
        PairingsBn254.Fr omega;
        PairingsBn254.G1Point[NUM_SETUP_POLYS_FOR_MAIN_GATE + NUM_SETUP_POLYS_RANGE_CHECK_GATE] gate_setup_commitments;
        PairingsBn254.G1Point[NUM_DIFFERENT_GATES] gate_selector_commitments;
        PairingsBn254.G1Point[STATE_WIDTH] copy_permutation_commitments;
        PairingsBn254.Fr[STATE_WIDTH - 1] copy_permutation_non_residues;
        PairingsBn254.G2Point g2_x;
    }

    struct Proof {
        uint256[] input_values;
        PairingsBn254.G1Point[STATE_WIDTH] wire_commitments;
        PairingsBn254.G1Point copy_permutation_grand_product_commitment;
        PairingsBn254.G1Point[STATE_WIDTH] quotient_poly_commitments;
        PairingsBn254.Fr[STATE_WIDTH] wire_values_at_z;
        PairingsBn254.Fr[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP] wire_values_at_z_omega;
        PairingsBn254.Fr[NUM_GATE_SELECTORS_OPENED_EXPLICITLY] gate_selector_values_at_z;
        PairingsBn254.Fr copy_grand_product_at_z_omega;
        PairingsBn254.Fr quotient_polynomial_at_z;
        PairingsBn254.Fr linearization_polynomial_at_z;
        PairingsBn254.Fr[STATE_WIDTH - 1] permutation_polynomials_at_z;
        PairingsBn254.G1Point opening_at_z_proof;
        PairingsBn254.G1Point opening_at_z_omega_proof;
    }

    struct PartialVerifierState {
        PairingsBn254.Fr alpha;
        PairingsBn254.Fr beta;
        PairingsBn254.Fr gamma;
        PairingsBn254.Fr v;
        PairingsBn254.Fr u;
        PairingsBn254.Fr z;
        PairingsBn254.Fr[] cached_lagrange_evals;
    }

    function evaluate_lagrange_poly_out_of_domain(
        uint256 poly_num,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {
        require(poly_num < domain_size);
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory omega_power = omega.pow(poly_num);
        res = at.pow(domain_size);
        res.sub_assign(one);
        require(res.value != 0); // Vanishing polynomial can not be zero at point `at`
        res.mul_assign(omega_power);

        PairingsBn254.Fr memory den = PairingsBn254.copy(at);
        den.sub_assign(omega_power);
        den.mul_assign(PairingsBn254.new_fr(domain_size));

        den = den.inverse();

        res.mul_assign(den);
    }

    function batch_evaluate_lagrange_poly_out_of_domain(
        uint256[] memory poly_nums,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr[] memory res) {
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory tmp_1 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory tmp_2 = PairingsBn254.new_fr(domain_size);
        PairingsBn254.Fr memory vanishing_at_z = at.pow(domain_size);
        vanishing_at_z.sub_assign(one);
        // we can not have random point z be in domain
        require(vanishing_at_z.value != 0);
        PairingsBn254.Fr[] memory nums = new PairingsBn254.Fr[](poly_nums.length);
        PairingsBn254.Fr[] memory dens = new PairingsBn254.Fr[](poly_nums.length);
        // numerators in a form omega^i * (z^n - 1)
        // denoms in a form (z - omega^i) * N
        for (uint256 i = 0; i < poly_nums.length; i++) {
            tmp_1 = omega.pow(poly_nums[i]); // power of omega
            nums[i].assign(vanishing_at_z);
            nums[i].mul_assign(tmp_1);

            dens[i].assign(at); // (X - omega^i) * N
            dens[i].sub_assign(tmp_1);
            dens[i].mul_assign(tmp_2); // mul by domain size
        }

        PairingsBn254.Fr[] memory partial_products = new PairingsBn254.Fr[](poly_nums.length);
        partial_products[0].assign(PairingsBn254.new_fr(1));
        for (uint256 i = 1; i < dens.length ; i++) {
            partial_products[i].assign(dens[i - 1]);
            partial_products[i].mul_assign(partial_products[i-1]);
        }

        tmp_2.assign(partial_products[partial_products.length - 1]);
        tmp_2.mul_assign(dens[dens.length - 1]);
        tmp_2 = tmp_2.inverse(); // tmp_2 contains a^-1 * b^-1 (with! the last one)

        for (uint256 i = dens.length - 1; i < dens.length; i--) {
            tmp_1.assign(tmp_2); // all inversed
            tmp_1.mul_assign(partial_products[i]); // clear lowest terms
            tmp_2.mul_assign(dens[i]);
            dens[i].assign(tmp_1);
        }

        for (uint256 i = 0; i < nums.length; i++) {
            nums[i].mul_assign(dens[i]);
        }

        return nums;
    }

    function evaluate_vanishing(uint256 domain_size, PairingsBn254.Fr memory at)
    internal
    view
    returns (PairingsBn254.Fr memory res)
    {
        res = at.pow(domain_size);
        res.sub_assign(PairingsBn254.new_fr(1));
    }

    function verify_at_z(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {
        PairingsBn254.Fr memory lhs = evaluate_vanishing(vk.domain_size, state.z);
        require(lhs.value != 0); // we can not check a polynomial relationship if point `z` is in the domain
        lhs.mul_assign(proof.quotient_polynomial_at_z);

        PairingsBn254.Fr memory quotient_challenge = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory rhs = PairingsBn254.copy(proof.linearization_polynomial_at_z);

        // public inputs
        PairingsBn254.Fr memory tmp = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory inputs_term = PairingsBn254.new_fr(0);
        for (uint256 i = 0; i < proof.input_values.length; i++) {
            tmp.assign(state.cached_lagrange_evals[i]);
            tmp.mul_assign(PairingsBn254.new_fr(proof.input_values[i]));
            inputs_term.add_assign(tmp);
        }

        inputs_term.mul_assign(proof.gate_selector_values_at_z[0]);
        rhs.add_assign(inputs_term);

        // now we need 5th power
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);

        PairingsBn254.Fr memory z_part = PairingsBn254.copy(proof.copy_grand_product_at_z_omega);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp.assign(proof.permutation_polynomials_at_z[i]);
            tmp.mul_assign(state.beta);
            tmp.add_assign(state.gamma);
            tmp.add_assign(proof.wire_values_at_z[i]);

            z_part.mul_assign(tmp);
        }

        tmp.assign(state.gamma);
        // we need a wire value of the last polynomial in enumeration
        tmp.add_assign(proof.wire_values_at_z[STATE_WIDTH - 1]);

        z_part.mul_assign(tmp);
        z_part.mul_assign(quotient_challenge);

        rhs.sub_assign(z_part);

        quotient_challenge.mul_assign(state.alpha);

        tmp.assign(state.cached_lagrange_evals[0]);
        tmp.mul_assign(quotient_challenge);

        rhs.sub_assign(tmp);

        return lhs.value == rhs.value;
    }

    function add_contribution_from_range_constraint_gates(
        PartialVerifierState memory state,
        Proof memory proof,
        PairingsBn254.Fr memory current_alpha
    ) internal pure returns (PairingsBn254.Fr memory res) {
        // now add contribution from range constraint gate
        // we multiply selector commitment by all the factors (alpha*(c - 4d)(c - 4d - 1)(..-2)(..-3) + alpha^2 * (4b - c)()()() + {} + {})

        PairingsBn254.Fr memory one_fr = PairingsBn254.new_fr(ONE);
        PairingsBn254.Fr memory two_fr = PairingsBn254.new_fr(TWO);
        PairingsBn254.Fr memory three_fr = PairingsBn254.new_fr(THREE);
        PairingsBn254.Fr memory four_fr = PairingsBn254.new_fr(FOUR);

        res = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t0 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t1 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t2 = PairingsBn254.new_fr(0);

        for (uint256 i = 0; i < 3; i++) {
            current_alpha.mul_assign(state.alpha);

            // high - 4*low

            // this is 4*low
            t0 = PairingsBn254.copy(proof.wire_values_at_z[3 - i]);
            t0.mul_assign(four_fr);

            // high
            t1 = PairingsBn254.copy(proof.wire_values_at_z[2 - i]);
            t1.sub_assign(t0);

            // t0 is now t1 - {0,1,2,3}

            // first unroll manually for -0;
            t2 = PairingsBn254.copy(t1);

            // -1
            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(one_fr);
            t2.mul_assign(t0);

            // -2
            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(two_fr);
            t2.mul_assign(t0);

            // -3
            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(three_fr);
            t2.mul_assign(t0);

            t2.mul_assign(current_alpha);

            res.add_assign(t2);
        }

        // now also d_next - 4a

        current_alpha.mul_assign(state.alpha);

        // high - 4*low

        // this is 4*low
        t0 = PairingsBn254.copy(proof.wire_values_at_z[0]);
        t0.mul_assign(four_fr);

        // high
        t1 = PairingsBn254.copy(proof.wire_values_at_z_omega[0]);
        t1.sub_assign(t0);

        // t0 is now t1 - {0,1,2,3}

        // first unroll manually for -0;
        t2 = PairingsBn254.copy(t1);

        // -1
        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(one_fr);
        t2.mul_assign(t0);

        // -2
        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(two_fr);
        t2.mul_assign(t0);

        // -3
        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(three_fr);
        t2.mul_assign(t0);

        t2.mul_assign(current_alpha);

        res.add_assign(t2);

        return res;
    }

    function reconstruct_linearization_commitment(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (PairingsBn254.G1Point memory res) {
        // we compute what power of v is used as a delinearization factor in batch opening of
        // commitments. Let's label W(x) = 1 / (x - z) *
        // [
        // t_0(x) + z^n * t_1(x) + z^2n * t_2(x) + z^3n * t_3(x) - t(z)
        // + v (r(x) - r(z))
        // + v^{2..5} * (witness(x) - witness(z))
        // + v^{6} * (selector(x) - selector(z))
        // + v^{7..9} * (permutation(x) - permutation(z))
        // ]
        // W'(x) = 1 / (x - z*omega) *
        // [
        // + v^10 (z(x) - z(z*omega)) <- we need this power
        // + v^11 * (d(x) - d(z*omega))
        // ]
        //

        // we reconstruct linearization polynomial virtual selector
        // for that purpose we first linearize over main gate (over all it's selectors)
        // and multiply them by value(!) of the corresponding main gate selector
        res = PairingsBn254.copy_g1(vk.gate_setup_commitments[STATE_WIDTH + 1]); // index of q_const(x)

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(0);

        // addition gates
        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            tmp_g1 = vk.gate_setup_commitments[i].point_mul(proof.wire_values_at_z[i]);
            res.point_add_assign(tmp_g1);
        }

        // multiplication gate
        tmp_fr.assign(proof.wire_values_at_z[0]);
        tmp_fr.mul_assign(proof.wire_values_at_z[1]);
        tmp_g1 = vk.gate_setup_commitments[STATE_WIDTH].point_mul(tmp_fr);
        res.point_add_assign(tmp_g1);

        // d_next
        tmp_g1 = vk.gate_setup_commitments[STATE_WIDTH + 2].point_mul(proof.wire_values_at_z_omega[0]); // index of q_d_next(x)
        res.point_add_assign(tmp_g1);

        // multiply by main gate selector(z)
        res.point_mul_assign(proof.gate_selector_values_at_z[0]); // these is only one explicitly opened selector

        PairingsBn254.Fr memory current_alpha = PairingsBn254.new_fr(ONE);

        // calculate scalar contribution from the range check gate
        tmp_fr = add_contribution_from_range_constraint_gates(state, proof, current_alpha);
        tmp_g1 = vk.gate_selector_commitments[1].point_mul(tmp_fr); // selector commitment for range constraint gate * scalar
        res.point_add_assign(tmp_g1);

        // proceed as normal to copy permutation
        current_alpha.mul_assign(state.alpha); // alpha^5

        PairingsBn254.Fr memory alpha_for_grand_product = PairingsBn254.copy(current_alpha);

        // z * non_res * beta + gamma + a
        PairingsBn254.Fr memory grand_product_part_at_z = PairingsBn254.copy(state.z);
        grand_product_part_at_z.mul_assign(state.beta);
        grand_product_part_at_z.add_assign(proof.wire_values_at_z[0]);
        grand_product_part_at_z.add_assign(state.gamma);
        for (uint256 i = 0; i < vk.copy_permutation_non_residues.length; i++) {
            tmp_fr.assign(state.z);
            tmp_fr.mul_assign(vk.copy_permutation_non_residues[i]);
            tmp_fr.mul_assign(state.beta);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i + 1]);

            grand_product_part_at_z.mul_assign(tmp_fr);
        }

        grand_product_part_at_z.mul_assign(alpha_for_grand_product);

        // alpha^n & L_{0}(z), and we bump current_alpha
        current_alpha.mul_assign(state.alpha);

        tmp_fr.assign(state.cached_lagrange_evals[0]);
        tmp_fr.mul_assign(current_alpha);

        grand_product_part_at_z.add_assign(tmp_fr);

        // prefactor for grand_product(x) is complete

        // add to the linearization a part from the term
        // - (a(z) + beta*perm_a + gamma)*()*()*z(z*omega) * beta * perm_d(X)
        PairingsBn254.Fr memory last_permutation_part_at_z = PairingsBn254.new_fr(1);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp_fr.assign(state.beta);
            tmp_fr.mul_assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i]);

            last_permutation_part_at_z.mul_assign(tmp_fr);
        }

        last_permutation_part_at_z.mul_assign(state.beta);
        last_permutation_part_at_z.mul_assign(proof.copy_grand_product_at_z_omega);
        last_permutation_part_at_z.mul_assign(alpha_for_grand_product); // we multiply by the power of alpha from the argument

        // actually multiply prefactors by z(x) and perm_d(x) and combine them
        tmp_g1 = proof.copy_permutation_grand_product_commitment.point_mul(grand_product_part_at_z);
        tmp_g1.point_sub_assign(vk.copy_permutation_commitments[STATE_WIDTH - 1].point_mul(last_permutation_part_at_z));

        res.point_add_assign(tmp_g1);
        // multiply them by v immedately as linearization has a factor of v^1
        res.point_mul_assign(state.v);
        // res now contains contribution from the gates linearization and
        // copy permutation part

        // now we need to add a part that is the rest
        // for z(x*omega):
        // - (a(z) + beta*perm_a + gamma)*()*()*(d(z) + gamma) * z(x*omega)
    }

    function aggregate_commitments(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (PairingsBn254.G1Point[2] memory res) {
        PairingsBn254.G1Point memory d = reconstruct_linearization_commitment(state, proof, vk);

        PairingsBn254.Fr memory z_in_domain_size = state.z.pow(vk.domain_size);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();

        PairingsBn254.Fr memory aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.G1Point memory commitment_aggregation = PairingsBn254.copy_g1(proof.quotient_poly_commitments[0]);
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(1);
        for (uint256 i = 1; i < proof.quotient_poly_commitments.length; i++) {
            tmp_fr.mul_assign(z_in_domain_size);
            tmp_g1 = proof.quotient_poly_commitments[i].point_mul(tmp_fr);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        commitment_aggregation.point_add_assign(d);

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = proof.wire_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint256 i = 0; i < NUM_GATE_SELECTORS_OPENED_EXPLICITLY; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.gate_selector_commitments[0].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint256 i = 0; i < vk.copy_permutation_commitments.length - 1; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.copy_permutation_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        // now do prefactor for grand_product(x*omega)
        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        commitment_aggregation.point_add_assign(proof.copy_permutation_grand_product_commitment.point_mul(tmp_fr));

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        tmp_g1 = proof.wire_commitments[STATE_WIDTH - 1].point_mul(tmp_fr);
        commitment_aggregation.point_add_assign(tmp_g1);

        // collect opening values
        aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.Fr memory aggregated_value = PairingsBn254.copy(proof.quotient_polynomial_at_z);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.linearization_polynomial_at_z);
        tmp_fr.mul_assign(aggregation_challenge);
        aggregated_value.add_assign(tmp_fr);

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.wire_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint256 i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_fr.assign(proof.gate_selector_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.copy_grand_product_at_z_omega);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.wire_values_at_z_omega[0]);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        commitment_aggregation.point_sub_assign(PairingsBn254.P1().point_mul(aggregated_value));

        PairingsBn254.G1Point memory pair_with_generator = commitment_aggregation;
        pair_with_generator.point_add_assign(proof.opening_at_z_proof.point_mul(state.z));

        tmp_fr.assign(state.z);
        tmp_fr.mul_assign(vk.omega);
        tmp_fr.mul_assign(state.u);
        pair_with_generator.point_add_assign(proof.opening_at_z_omega_proof.point_mul(tmp_fr));

        PairingsBn254.G1Point memory pair_with_x = proof.opening_at_z_omega_proof.point_mul(state.u);
        pair_with_x.point_add_assign(proof.opening_at_z_proof);
        pair_with_x.negate();

        res[0] = pair_with_generator;
        res[1] = pair_with_x;

        return res;
    }

    function verify_initial(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {
        require(proof.input_values.length == vk.num_inputs);
        require(vk.num_inputs >= 1);
        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        for (uint256 i = 0; i < vk.num_inputs; i++) {
            transcript.update_with_u256(proof.input_values[i]);
        }

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            transcript.update_with_g1(proof.wire_commitments[i]);
        }

        state.beta = transcript.get_challenge();
        state.gamma = transcript.get_challenge();

        transcript.update_with_g1(proof.copy_permutation_grand_product_commitment);
        state.alpha = transcript.get_challenge();

        for (uint256 i = 0; i < proof.quotient_poly_commitments.length; i++) {
            transcript.update_with_g1(proof.quotient_poly_commitments[i]);
        }

        state.z = transcript.get_challenge();

        uint256[] memory lagrange_poly_numbers = new uint256[](vk.num_inputs);
        for (uint256 i = 0; i < lagrange_poly_numbers.length; i++) {
            lagrange_poly_numbers[i] = i;
        }

        state.cached_lagrange_evals = batch_evaluate_lagrange_poly_out_of_domain(
            lagrange_poly_numbers,
            vk.domain_size,
            vk.omega,
            state.z
        );

        bool valid = verify_at_z(state, proof, vk);

        if (valid == false) {
            return false;
        }

        transcript.update_with_fr(proof.quotient_polynomial_at_z);

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z[i]);
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z_omega[i]);
        }

        transcript.update_with_fr(proof.gate_selector_values_at_z[0]);

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            transcript.update_with_fr(proof.permutation_polynomials_at_z[i]);
        }

        transcript.update_with_fr(proof.copy_grand_product_at_z_omega);
        transcript.update_with_fr(proof.linearization_polynomial_at_z);

        state.v = transcript.get_challenge();
        transcript.update_with_g1(proof.opening_at_z_proof);
        transcript.update_with_g1(proof.opening_at_z_omega_proof);
        state.u = transcript.get_challenge();

        return true;
    }

    // This verifier is for a PLONK with a state width 4
    // and main gate equation
    // q_a(X) * a(X) +
    // q_b(X) * b(X) +
    // q_c(X) * c(X) +
    // q_d(X) * d(X) +
    // q_m(X) * a(X) * b(X) +
    // q_constants(X)+
    // q_d_next(X) * d(X*omega)
    // where q_{}(X) are selectors a, b, c, d - state (witness) polynomials
    // q_d_next(X) "peeks" into the next row of the trace, so it takes
    // the same d(X) polynomial, but shifted

    function aggregate_for_verification(Proof memory proof, VerificationKey memory vk)
    internal
    view
    returns (bool valid, PairingsBn254.G1Point[2] memory part)
    {
        PartialVerifierState memory state;

        valid = verify_initial(state, proof, vk);

        if (valid == false) {
            return (valid, part);
        }

        part = aggregate_commitments(state, proof, vk);

        (valid, part);
    }

    function verify(Proof memory proof, VerificationKey memory vk) internal view returns (bool) {
        (bool valid, PairingsBn254.G1Point[2] memory recursive_proof_part) = aggregate_for_verification(proof, vk);
        if (valid == false) {
            return false;
        }

        valid = PairingsBn254.pairingProd2(
            recursive_proof_part[0],
            PairingsBn254.P2(),
            recursive_proof_part[1],
            vk.g2_x
        );

        return valid;
    }

    function verify_recursive(
        Proof memory proof,
        VerificationKey memory vk,
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[16] memory subproofs_limbs
    ) internal view returns (bool) {
        (uint256 recursive_input, PairingsBn254.G1Point[2] memory aggregated_g1s) =
        reconstruct_recursive_public_input(
            recursive_vks_root,
            max_valid_index,
            recursive_vks_indexes,
            individual_vks_inputs,
            subproofs_limbs
        );

        assert(recursive_input == proof.input_values[0]);

        (bool valid, PairingsBn254.G1Point[2] memory recursive_proof_part) = aggregate_for_verification(proof, vk);
        if (valid == false) {
            return false;
        }

        // aggregated_g1s = inner
        // recursive_proof_part = outer
        PairingsBn254.G1Point[2] memory combined = combine_inner_and_outer(aggregated_g1s, recursive_proof_part);

        valid = PairingsBn254.pairingProd2(combined[0], PairingsBn254.P2(), combined[1], vk.g2_x);

        return valid;
    }

    function combine_inner_and_outer(PairingsBn254.G1Point[2] memory inner, PairingsBn254.G1Point[2] memory outer)
    internal
    view
    returns (PairingsBn254.G1Point[2] memory result)
    {
        // reuse the transcript primitive
        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        transcript.update_with_g1(inner[0]);
        transcript.update_with_g1(inner[1]);
        transcript.update_with_g1(outer[0]);
        transcript.update_with_g1(outer[1]);
        PairingsBn254.Fr memory challenge = transcript.get_challenge();
        // 1 * inner + challenge * outer
        result[0] = PairingsBn254.copy_g1(inner[0]);
        result[1] = PairingsBn254.copy_g1(inner[1]);
        PairingsBn254.G1Point memory tmp = outer[0].point_mul(challenge);
        result[0].point_add_assign(tmp);
        tmp = outer[1].point_mul(challenge);
        result[1].point_add_assign(tmp);

        return result;
    }

    function reconstruct_recursive_public_input(
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[16] memory subproofs_aggregated
    ) internal pure returns (uint256 recursive_input, PairingsBn254.G1Point[2] memory reconstructed_g1s) {
        assert(recursive_vks_indexes.length == individual_vks_inputs.length);
        bytes memory concatenated = abi.encodePacked(recursive_vks_root);
        uint8 index;
        for (uint256 i = 0; i < recursive_vks_indexes.length; i++) {
            index = recursive_vks_indexes[i];
            assert(index <= max_valid_index);
            concatenated = abi.encodePacked(concatenated, index);
        }
        uint256 input;
        for (uint256 i = 0; i < recursive_vks_indexes.length; i++) {
            input = individual_vks_inputs[i];
            assert(input < r_mod);
            concatenated = abi.encodePacked(concatenated, input);
        }

        concatenated = abi.encodePacked(concatenated, subproofs_aggregated);

        bytes32 commitment = sha256(concatenated);
        recursive_input = uint256(commitment) & RECURSIVE_CIRCUIT_INPUT_COMMITMENT_MASK;

        reconstructed_g1s[0] = PairingsBn254.new_g1_checked(
            subproofs_aggregated[0] +
            (subproofs_aggregated[1] << LIMB_WIDTH) +
            (subproofs_aggregated[2] << (2 * LIMB_WIDTH)) +
            (subproofs_aggregated[3] << (3 * LIMB_WIDTH)),
            subproofs_aggregated[4] +
            (subproofs_aggregated[5] << LIMB_WIDTH) +
            (subproofs_aggregated[6] << (2 * LIMB_WIDTH)) +
            (subproofs_aggregated[7] << (3 * LIMB_WIDTH))
        );

        reconstructed_g1s[1] = PairingsBn254.new_g1_checked(
            subproofs_aggregated[8] +
            (subproofs_aggregated[9] << LIMB_WIDTH) +
            (subproofs_aggregated[10] << (2 * LIMB_WIDTH)) +
            (subproofs_aggregated[11] << (3 * LIMB_WIDTH)),
            subproofs_aggregated[12] +
            (subproofs_aggregated[13] << LIMB_WIDTH) +
            (subproofs_aggregated[14] << (2 * LIMB_WIDTH)) +
            (subproofs_aggregated[15] << (3 * LIMB_WIDTH))
        );

        return (recursive_input, reconstructed_g1s);
    }
}

contract VerifierWithDeserialize is Plonk4VerifierWithAccessToDNext {
    uint256 constant SERIALIZED_PROOF_LENGTH = 34;

    function deserialize_proof(uint256[] memory public_inputs, uint256[] memory serialized_proof)
    internal
    pure
    returns (Proof memory proof)
    {
        require(serialized_proof.length == SERIALIZED_PROOF_LENGTH);
        proof.input_values = new uint256[](public_inputs.length);
        for (uint256 i = 0; i < public_inputs.length; i++) {
            proof.input_values[i] = public_inputs[i];
        }

        uint256 j = 0;
        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_commitments[i] = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);

            j += 2;
        }

        proof.copy_permutation_grand_product_commitment = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j + 1]
        );
        j += 2;

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.quotient_poly_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j + 1]
            );

            j += 2;
        }

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_values_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            proof.wire_values_at_z_omega[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            proof.gate_selector_values_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            proof.permutation_polynomials_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        proof.copy_grand_product_at_z_omega = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.quotient_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.linearization_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.opening_at_z_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
        j += 2;

        proof.opening_at_z_omega_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
    }

    function verify_serialized_proof(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof,
        VerificationKey memory vk
    ) public view returns (bool) {
        require(vk.num_inputs == public_inputs.length);

        Proof memory proof = deserialize_proof(public_inputs, serialized_proof);

        bool valid = verify(proof, vk);

        return valid;
    }

    function verify_serialized_proof_with_recursion(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof,
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[16] memory subproofs_limbs,
        VerificationKey memory vk
    ) public view returns (bool) {
        require(vk.num_inputs == public_inputs.length);

        Proof memory proof = deserialize_proof(public_inputs, serialized_proof);

        bool valid =
        verify_recursive(
            proof,
            vk,
            recursive_vks_root,
            max_valid_index,
            recursive_vks_indexes,
            individual_vks_inputs,
            subproofs_limbs
        );

        return valid;
    }
}

contract Plonk4VerifierWithAccessToDNextOld {
    using PairingsBn254 for PairingsBn254.G1Point;
    using PairingsBn254 for PairingsBn254.G2Point;
    using PairingsBn254 for PairingsBn254.Fr;

    using TranscriptLibrary for TranscriptLibrary.Transcript;

    uint256 constant STATE_WIDTH_OLD = 4;
    uint256 constant ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP_OLD = 1;

    struct VerificationKeyOld {
        uint256 domain_size;
        uint256 num_inputs;
        PairingsBn254.Fr omega;
        PairingsBn254.G1Point[STATE_WIDTH_OLD + 2] selector_commitments; // STATE_WIDTH for witness + multiplication + constant
        PairingsBn254.G1Point[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP_OLD] next_step_selector_commitments;
        PairingsBn254.G1Point[STATE_WIDTH_OLD] permutation_commitments;
        PairingsBn254.Fr[STATE_WIDTH_OLD - 1] permutation_non_residues;
        PairingsBn254.G2Point g2_x;
    }

    struct ProofOld {
        uint256[] input_values;
        PairingsBn254.G1Point[STATE_WIDTH_OLD] wire_commitments;
        PairingsBn254.G1Point grand_product_commitment;
        PairingsBn254.G1Point[STATE_WIDTH_OLD] quotient_poly_commitments;
        PairingsBn254.Fr[STATE_WIDTH_OLD] wire_values_at_z;
        PairingsBn254.Fr[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP_OLD] wire_values_at_z_omega;
        PairingsBn254.Fr grand_product_at_z_omega;
        PairingsBn254.Fr quotient_polynomial_at_z;
        PairingsBn254.Fr linearization_polynomial_at_z;
        PairingsBn254.Fr[STATE_WIDTH_OLD - 1] permutation_polynomials_at_z;
        PairingsBn254.G1Point opening_at_z_proof;
        PairingsBn254.G1Point opening_at_z_omega_proof;
    }

    struct PartialVerifierStateOld {
        PairingsBn254.Fr alpha;
        PairingsBn254.Fr beta;
        PairingsBn254.Fr gamma;
        PairingsBn254.Fr v;
        PairingsBn254.Fr u;
        PairingsBn254.Fr z;
        PairingsBn254.Fr[] cached_lagrange_evals;
    }

    function evaluate_lagrange_poly_out_of_domain_old(
        uint256 poly_num,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {
        require(poly_num < domain_size);
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory omega_power = omega.pow(poly_num);
        res = at.pow(domain_size);
        res.sub_assign(one);
        require(res.value != 0); // Vanishing polynomial can not be zero at point `at`
        res.mul_assign(omega_power);

        PairingsBn254.Fr memory den = PairingsBn254.copy(at);
        den.sub_assign(omega_power);
        den.mul_assign(PairingsBn254.new_fr(domain_size));

        den = den.inverse();

        res.mul_assign(den);
    }

    function batch_evaluate_lagrange_poly_out_of_domain_old(
        uint256[] memory poly_nums,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr[] memory res) {
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory tmp_1 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory tmp_2 = PairingsBn254.new_fr(domain_size);
        PairingsBn254.Fr memory vanishing_at_z = at.pow(domain_size);
        vanishing_at_z.sub_assign(one);
        // we can not have random point z be in domain
        require(vanishing_at_z.value != 0);
        PairingsBn254.Fr[] memory nums = new PairingsBn254.Fr[](poly_nums.length);
        PairingsBn254.Fr[] memory dens = new PairingsBn254.Fr[](poly_nums.length);
        // numerators in a form omega^i * (z^n - 1)
        // denoms in a form (z - omega^i) * N
        for (uint256 i = 0; i < poly_nums.length; i++) {
            tmp_1 = omega.pow(poly_nums[i]); // power of omega
            nums[i].assign(vanishing_at_z);
            nums[i].mul_assign(tmp_1);

            dens[i].assign(at); // (X - omega^i) * N
            dens[i].sub_assign(tmp_1);
            dens[i].mul_assign(tmp_2); // mul by domain size
        }

        PairingsBn254.Fr[] memory partial_products = new PairingsBn254.Fr[](poly_nums.length);
        partial_products[0].assign(PairingsBn254.new_fr(1));
        for (uint256 i = 1; i < dens.length ; i++) {
            partial_products[i].assign(dens[i - 1]);
            partial_products[i].mul_assign(partial_products[i-1]);
        }

        tmp_2.assign(partial_products[partial_products.length - 1]);
        tmp_2.mul_assign(dens[dens.length - 1]);
        tmp_2 = tmp_2.inverse(); // tmp_2 contains a^-1 * b^-1 (with! the last one)

        for (uint256 i = dens.length - 1; i < dens.length; i--) {
            tmp_1.assign(tmp_2); // all inversed
            tmp_1.mul_assign(partial_products[i]); // clear lowest terms
            tmp_2.mul_assign(dens[i]);
            dens[i].assign(tmp_1);
        }

        for (uint256 i = 0; i < nums.length; i++) {
            nums[i].mul_assign(dens[i]);
        }

        return nums;
    }

    function evaluate_vanishing_old(uint256 domain_size, PairingsBn254.Fr memory at)
    internal
    view
    returns (PairingsBn254.Fr memory res)
    {
        res = at.pow(domain_size);
        res.sub_assign(PairingsBn254.new_fr(1));
    }

    function verify_at_z(
        PartialVerifierStateOld memory state,
        ProofOld memory proof,
        VerificationKeyOld memory vk
    ) internal view returns (bool) {
        PairingsBn254.Fr memory lhs = evaluate_vanishing_old(vk.domain_size, state.z);
        require(lhs.value != 0); // we can not check a polynomial relationship if point `z` is in the domain
        lhs.mul_assign(proof.quotient_polynomial_at_z);

        PairingsBn254.Fr memory quotient_challenge = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory rhs = PairingsBn254.copy(proof.linearization_polynomial_at_z);

        // public inputs
        PairingsBn254.Fr memory tmp = PairingsBn254.new_fr(0);
        for (uint256 i = 0; i < proof.input_values.length; i++) {
            tmp.assign(state.cached_lagrange_evals[i]);
            tmp.mul_assign(PairingsBn254.new_fr(proof.input_values[i]));
            rhs.add_assign(tmp);
        }

        quotient_challenge.mul_assign(state.alpha);

        PairingsBn254.Fr memory z_part = PairingsBn254.copy(proof.grand_product_at_z_omega);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp.assign(proof.permutation_polynomials_at_z[i]);
            tmp.mul_assign(state.beta);
            tmp.add_assign(state.gamma);
            tmp.add_assign(proof.wire_values_at_z[i]);

            z_part.mul_assign(tmp);
        }

        tmp.assign(state.gamma);
        // we need a wire value of the last polynomial in enumeration
        tmp.add_assign(proof.wire_values_at_z[STATE_WIDTH_OLD - 1]);

        z_part.mul_assign(tmp);
        z_part.mul_assign(quotient_challenge);

        rhs.sub_assign(z_part);

        quotient_challenge.mul_assign(state.alpha);

        tmp.assign(state.cached_lagrange_evals[0]);
        tmp.mul_assign(quotient_challenge);

        rhs.sub_assign(tmp);

        return lhs.value == rhs.value;
    }

    function reconstruct_d(
        PartialVerifierStateOld memory state,
        ProofOld memory proof,
        VerificationKeyOld memory vk
    ) internal view returns (PairingsBn254.G1Point memory res) {
        // we compute what power of v is used as a delinearization factor in batch opening of
        // commitments. Let's label W(x) = 1 / (x - z) *
        // [
        // t_0(x) + z^n * t_1(x) + z^2n * t_2(x) + z^3n * t_3(x) - t(z)
        // + v (r(x) - r(z))
        // + v^{2..5} * (witness(x) - witness(z))
        // + v^(6..8) * (permutation(x) - permutation(z))
        // ]
        // W'(x) = 1 / (x - z*omega) *
        // [
        // + v^9 (z(x) - z(z*omega)) <- we need this power
        // + v^10 * (d(x) - d(z*omega))
        // ]
        //
        // we pay a little for a few arithmetic operations to not introduce another constant
        uint256 power_for_z_omega_opening = 1 + 1 + STATE_WIDTH_OLD + STATE_WIDTH_OLD - 1;
        res = PairingsBn254.copy_g1(vk.selector_commitments[STATE_WIDTH_OLD + 1]);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(0);

        // addition gates
        for (uint256 i = 0; i < STATE_WIDTH_OLD; i++) {
            tmp_g1 = vk.selector_commitments[i].point_mul(proof.wire_values_at_z[i]);
            res.point_add_assign(tmp_g1);
        }

        // multiplication gate
        tmp_fr.assign(proof.wire_values_at_z[0]);
        tmp_fr.mul_assign(proof.wire_values_at_z[1]);
        tmp_g1 = vk.selector_commitments[STATE_WIDTH_OLD].point_mul(tmp_fr);
        res.point_add_assign(tmp_g1);

        // d_next
        tmp_g1 = vk.next_step_selector_commitments[0].point_mul(proof.wire_values_at_z_omega[0]);
        res.point_add_assign(tmp_g1);

        // z * non_res * beta + gamma + a
        PairingsBn254.Fr memory grand_product_part_at_z = PairingsBn254.copy(state.z);
        grand_product_part_at_z.mul_assign(state.beta);
        grand_product_part_at_z.add_assign(proof.wire_values_at_z[0]);
        grand_product_part_at_z.add_assign(state.gamma);
        for (uint256 i = 0; i < vk.permutation_non_residues.length; i++) {
            tmp_fr.assign(state.z);
            tmp_fr.mul_assign(vk.permutation_non_residues[i]);
            tmp_fr.mul_assign(state.beta);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i + 1]);

            grand_product_part_at_z.mul_assign(tmp_fr);
        }

        grand_product_part_at_z.mul_assign(state.alpha);

        tmp_fr.assign(state.cached_lagrange_evals[0]);
        tmp_fr.mul_assign(state.alpha);
        tmp_fr.mul_assign(state.alpha);

        grand_product_part_at_z.add_assign(tmp_fr);

        PairingsBn254.Fr memory grand_product_part_at_z_omega = state.v.pow(power_for_z_omega_opening);
        grand_product_part_at_z_omega.mul_assign(state.u);

        PairingsBn254.Fr memory last_permutation_part_at_z = PairingsBn254.new_fr(1);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp_fr.assign(state.beta);
            tmp_fr.mul_assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i]);

            last_permutation_part_at_z.mul_assign(tmp_fr);
        }

        last_permutation_part_at_z.mul_assign(state.beta);
        last_permutation_part_at_z.mul_assign(proof.grand_product_at_z_omega);
        last_permutation_part_at_z.mul_assign(state.alpha);

        // add to the linearization
        tmp_g1 = proof.grand_product_commitment.point_mul(grand_product_part_at_z);
        tmp_g1.point_sub_assign(vk.permutation_commitments[STATE_WIDTH_OLD - 1].point_mul(last_permutation_part_at_z));

        res.point_add_assign(tmp_g1);
        res.point_mul_assign(state.v);

        res.point_add_assign(proof.grand_product_commitment.point_mul(grand_product_part_at_z_omega));
    }

    function verify_commitments(
        PartialVerifierStateOld memory state,
        ProofOld memory proof,
        VerificationKeyOld memory vk
    ) internal view returns (bool) {
        PairingsBn254.G1Point memory d = reconstruct_d(state, proof, vk);

        PairingsBn254.Fr memory z_in_domain_size = state.z.pow(vk.domain_size);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();

        PairingsBn254.Fr memory aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.G1Point memory commitment_aggregation = PairingsBn254.copy_g1(proof.quotient_poly_commitments[0]);
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(1);
        for (uint256 i = 1; i < proof.quotient_poly_commitments.length; i++) {
            tmp_fr.mul_assign(z_in_domain_size);
            tmp_g1 = proof.quotient_poly_commitments[i].point_mul(tmp_fr);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        commitment_aggregation.point_add_assign(d);

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = proof.wire_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint256 i = 0; i < vk.permutation_commitments.length - 1; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.permutation_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        tmp_g1 = proof.wire_commitments[STATE_WIDTH_OLD - 1].point_mul(tmp_fr);
        commitment_aggregation.point_add_assign(tmp_g1);

        // collect opening values
        aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.Fr memory aggregated_value = PairingsBn254.copy(proof.quotient_polynomial_at_z);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.linearization_polynomial_at_z);
        tmp_fr.mul_assign(aggregation_challenge);
        aggregated_value.add_assign(tmp_fr);

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.wire_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.grand_product_at_z_omega);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.wire_values_at_z_omega[0]);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        commitment_aggregation.point_sub_assign(PairingsBn254.P1().point_mul(aggregated_value));

        PairingsBn254.G1Point memory pair_with_generator = commitment_aggregation;
        pair_with_generator.point_add_assign(proof.opening_at_z_proof.point_mul(state.z));

        tmp_fr.assign(state.z);
        tmp_fr.mul_assign(vk.omega);
        tmp_fr.mul_assign(state.u);
        pair_with_generator.point_add_assign(proof.opening_at_z_omega_proof.point_mul(tmp_fr));

        PairingsBn254.G1Point memory pair_with_x = proof.opening_at_z_omega_proof.point_mul(state.u);
        pair_with_x.point_add_assign(proof.opening_at_z_proof);
        pair_with_x.negate();

        return PairingsBn254.pairingProd2(pair_with_generator, PairingsBn254.P2(), pair_with_x, vk.g2_x);
    }

    function verify_initial(
        PartialVerifierStateOld memory state,
        ProofOld memory proof,
        VerificationKeyOld memory vk
    ) internal view returns (bool) {
        require(proof.input_values.length == vk.num_inputs);
        require(vk.num_inputs >= 1);
        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        for (uint256 i = 0; i < vk.num_inputs; i++) {
            transcript.update_with_u256(proof.input_values[i]);
        }

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            transcript.update_with_g1(proof.wire_commitments[i]);
        }

        state.beta = transcript.get_challenge();
        state.gamma = transcript.get_challenge();

        transcript.update_with_g1(proof.grand_product_commitment);
        state.alpha = transcript.get_challenge();

        for (uint256 i = 0; i < proof.quotient_poly_commitments.length; i++) {
            transcript.update_with_g1(proof.quotient_poly_commitments[i]);
        }

        state.z = transcript.get_challenge();

        uint256[] memory lagrange_poly_numbers = new uint256[](vk.num_inputs);
        for (uint256 i = 0; i < lagrange_poly_numbers.length; i++) {
            lagrange_poly_numbers[i] = i;
        }

        state.cached_lagrange_evals = batch_evaluate_lagrange_poly_out_of_domain_old(
            lagrange_poly_numbers,
            vk.domain_size,
            vk.omega,
            state.z
        );

        bool valid = verify_at_z(state, proof, vk);

        if (valid == false) {
            return false;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z[i]);
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z_omega[i]);
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            transcript.update_with_fr(proof.permutation_polynomials_at_z[i]);
        }

        transcript.update_with_fr(proof.quotient_polynomial_at_z);
        transcript.update_with_fr(proof.linearization_polynomial_at_z);
        transcript.update_with_fr(proof.grand_product_at_z_omega);

        state.v = transcript.get_challenge();
        transcript.update_with_g1(proof.opening_at_z_proof);
        transcript.update_with_g1(proof.opening_at_z_omega_proof);
        state.u = transcript.get_challenge();

        return true;
    }

    // This verifier is for a PLONK with a state width 4
    // and main gate equation
    // q_a(X) * a(X) +
    // q_b(X) * b(X) +
    // q_c(X) * c(X) +
    // q_d(X) * d(X) +
    // q_m(X) * a(X) * b(X) +
    // q_constants(X)+
    // q_d_next(X) * d(X*omega)
    // where q_{}(X) are selectors a, b, c, d - state (witness) polynomials
    // q_d_next(X) "peeks" into the next row of the trace, so it takes
    // the same d(X) polynomial, but shifted

    function verify_old(ProofOld memory proof, VerificationKeyOld memory vk) internal view returns (bool) {
        PartialVerifierStateOld memory state;

        bool valid = verify_initial(state, proof, vk);

        if (valid == false) {
            return false;
        }

        valid = verify_commitments(state, proof, vk);

        return valid;
    }
}

contract VerifierWithDeserializeOld is Plonk4VerifierWithAccessToDNextOld {
    uint256 constant SERIALIZED_PROOF_LENGTH_OLD = 33;

    function deserialize_proof_old(uint256[] memory public_inputs, uint256[] memory serialized_proof)
    internal
    pure
    returns (ProofOld memory proof)
    {
        require(serialized_proof.length == SERIALIZED_PROOF_LENGTH_OLD);
        proof.input_values = new uint256[](public_inputs.length);
        for (uint256 i = 0; i < public_inputs.length; i++) {
            proof.input_values[i] = public_inputs[i];
        }

        uint256 j = 0;
        for (uint256 i = 0; i < STATE_WIDTH_OLD; i++) {
            proof.wire_commitments[i] = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);

            j += 2;
        }

        proof.grand_product_commitment = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
        j += 2;

        for (uint256 i = 0; i < STATE_WIDTH_OLD; i++) {
            proof.quotient_poly_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j + 1]
            );

            j += 2;
        }

        for (uint256 i = 0; i < STATE_WIDTH_OLD; i++) {
            proof.wire_values_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            proof.wire_values_at_z_omega[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        proof.grand_product_at_z_omega = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.quotient_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.linearization_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            proof.permutation_polynomials_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        proof.opening_at_z_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
        j += 2;

        proof.opening_at_z_omega_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
    }
}


pragma solidity ^0.7.0;



//import'./UniswapV2ERC20.sol';
//import'./libraries/Math.sol';
//import'./libraries/UQ112x112.sol';

contract UniswapV2Pair is UniswapV2ERC20 {
    using UniswapSafeMath  for uint;
    using UQ112x112 for uint224;

    address public factory;
    address public token0;
    address public token1;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to, uint256 amount) external lock {
        require(msg.sender == factory, 'mt1');
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external lock {
        require(msg.sender == factory, 'br1');
        _burn(to, amount);
    }
}


pragma solidity ^0.7.0;


//import'./libraries/UniswapSafeMath.sol';

contract UniswapV2ERC20 {
    using UniswapSafeMath for uint;

    string public constant name = 'EdgeSwap V1';
    string public constant symbol = 'Edge-V1';
    uint8 public constant decimals = 18;
    uint256  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
}


pragma solidity ^0.7.0;



// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity ^0.7.0;



// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}


pragma solidity ^0.7.0;



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library UniswapSafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


pragma solidity ^0.7.0;

// : MIT OR Apache-2.0



/// @title Interface of the upgradeable contract
/// @author Matter Labs
interface Upgradeable {
    /// @notice Upgrades target of upgradeable contract
    /// @param newTarget New target
    /// @param newTargetInitializationParameters New target initialization parameters
    function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;
}


pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// : MIT OR Apache-2.0





//import"./ReentrancyGuard.sol";
//import"./SafeMath.sol";
//import"./SafeMathUInt128.sol";
//import"./SafeCast.sol";
//import"./Utils.sol";

//import"./Storage.sol";
//import"./Config.sol";
//import"./Events.sol";

//import"./Bytes.sol";
//import"./Operations.sol";

//import"./UpgradeableMaster.sol";
//import"./PairTokenManager.sol";

/// @title zkSync main contract
/// @author Matter Labs
/// @author ZKSwap L2 Labs
/// @author Stars Labs
contract ZkSync is PairTokenManager, UpgradeableMaster, Storage, Config, Events, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMathUInt128 for uint128;

    bytes32 private constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;


    function pairFor(address tokenA, address tokenB, bytes32 _salt) external view returns (address pair) {
        pair = pairmanager.pairFor(tokenA, tokenB, _salt);
    }

    function createPair(address _tokenA, address _tokenB, bytes32 salt) external {
        require(_tokenA != _tokenB ||
                keccak256(abi.encodePacked(IERC20(_tokenA).symbol())) == keccak256(abi.encodePacked("EGS")),
                "pair same token invalid");

        requireActive();
        governance.requireGovernor(msg.sender);

        //check _tokenA is registered or not
        uint16 tokenAID = governance.validateTokenAddress(_tokenA);
        //check _tokenB is registered or not
        uint16 tokenBID = governance.validateTokenAddress(_tokenB);

        //create pair
        (address token0, address token1, uint16 token0_id, uint16 token1_id) = _tokenA < _tokenB ? (_tokenA, _tokenB, tokenAID, tokenBID) : (_tokenB, _tokenA, tokenBID, tokenAID);

        address pair = pairmanager.createPair(token0, token1, salt);
        require(pair != address(0), "pair is invalid");

	    addPairToken(pair);

        registerCreatePair(
            token0_id,
            token1_id,
		    validatePairTokenAddress(pair),
            pair
        );
    }

    //create pair including ETH
    function createETHPair(address _tokenERC20, bytes32 salt) external {
        requireActive();
        governance.requireGovernor(msg.sender);
        //check _tokenERC20 is registered or not
        uint16 erc20ID = governance.validateTokenAddress(_tokenERC20);

        //create pair
        address pair = pairmanager.createPair(address(0), _tokenERC20, salt);
        require(pair != address(0), "pair is invalid");

	    addPairToken(pair);

        registerCreatePair(
            0,
            erc20ID,
            validatePairTokenAddress(pair),
            pair);
    }

    function registerCreatePair(uint16 _tokenA, uint16 _tokenB, uint16 _tokenPair, address _pair) internal {
        // Priority Queue request
        (uint16 token0, uint16 token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        Operations.CreatePair memory op = Operations.CreatePair({
            accountId: 0,  //unknown at this point
            tokenA: token0,
            tokenB: token1,
            tokenPair: _tokenPair,
            pair: _pair
        });
        // pubData
        bytes memory pubData = Operations.writeCreatePairPubdata(op);

        addPriorityRequest(Operations.OpType.CreatePair, pubData);

        emit OnchainCreatePair(token0, token1, _tokenPair, _pair);
    }

    // Upgrade functional
    /// @notice Notice period before activation preparation status of upgrade mode
    function getNoticePeriod() external pure override returns (uint256) {
        return UPGRADE_NOTICE_PERIOD;
    }

    /// @notice Notification that upgrade notice period started
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeNoticePeriodStarted() external override {}

    /// @notice Notification that upgrade preparation status is activated
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradePreparationStarted() external override {
        upgradePreparationActive = true;
        upgradePreparationActivationTime = block.timestamp;
    }

    /// @notice Notification that upgrade canceled
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeCanceled() external override {
        upgradePreparationActive = false;
        upgradePreparationActivationTime = 0;
    }

    /// @notice Notification that upgrade finishes
    /// @dev Can be external because Proxy contract intercepts illegal calls of this function
    function upgradeFinishes() external override {
        upgradePreparationActive = false;
        upgradePreparationActivationTime = 0;
    }

    /// @notice Checks that contract is ready for upgrade
    /// @return bool flag indicating that contract is ready for upgrade
    function isReadyForUpgrade() external view override returns (bool) {
        return !exodusMode;
    }

    /// @notice zkSync contract initialization. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param initializationParameters Encoded representation of initialization parameters:
    /// @dev _governanceAddress The address of Governance contract
    /// @dev _verifierAddress The address of Verifier contract
    /// @dev _pairManagerAddress the address of UniswapV2Factory contract
    /// @dev _zkSyncCommitBlockAddress the address of ZkSyncCommitBlockAddress contract
    /// @dev _genesisStateHash Genesis blocks (first block) state tree root hash
    function initialize(bytes calldata initializationParameters) external {
        initializeReentrancyGuard();

        (
        address _governanceAddress,
        address _verifierAddress,
        address _verifierExitAddress,
        address _pairManagerAddress,
        address _zkSyncCommitBlockAddress,
        bytes32 _genesisStateHash
        ) = abi.decode(initializationParameters, (address, address, address, address, address, bytes32));

        governance = Governance(_governanceAddress);
        verifier = Verifier(_verifierAddress);
        verifier_exit = VerifierExit(_verifierExitAddress);
        pairmanager = UniswapV2Factory(_pairManagerAddress);
        zkSyncCommitBlockAddress = _zkSyncCommitBlockAddress;

        // We need initial state hash because it is used in the commitment of the next block
        StoredBlockInfo memory storedBlockZero =
        StoredBlockInfo(0, 0, EMPTY_STRING_KECCAK, 0, _genesisStateHash, bytes32(0));

        storedBlockHashes[0] = hashStoredBlockInfo(storedBlockZero);
    }

    // Priority queue
    /// @notice Saves priority request in storage
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _opType Rollup operation type
    /// @param _pubData Operation pubdata
    function addPriorityRequest(
        Operations.OpType _opType,
        bytes memory _pubData
    ) internal {
        // Expiration block is: current block number + priority expiration delta
        uint64 expirationBlock = uint64(block.number + PRIORITY_EXPIRATION);

        uint64 nextPriorityRequestId = firstPriorityRequestId + totalOpenPriorityRequests;

        bytes20 hashedPubData = Utils.hashBytesToBytes20(_pubData);

        priorityRequests[nextPriorityRequestId] = PriorityOperation({
            hashedPubData: hashedPubData,
            expirationBlock: expirationBlock,
            opType: _opType
            });

        emit NewPriorityRequest(msg.sender, nextPriorityRequestId, _opType, _pubData, uint256(expirationBlock));

        totalOpenPriorityRequests++;
    }

    /// @notice zkSync contract upgrade. Can be external because Proxy contract intercepts illegal calls of this function.
    /// @param upgradeParameters Encoded representation of upgrade parameters
    function upgrade(bytes calldata upgradeParameters) external nonReentrant {
        require(totalBlocksCommitted == totalBlocksProven, "wq1"); // All the blocks must be proven
        require(totalBlocksCommitted == totalBlocksExecuted, "w12"); // All the blocks must be executed

        if (upgradeParameters.length != 0) {
            StoredBlockInfo memory lastBlockInfo;
            (lastBlockInfo) = abi.decode(upgradeParameters, (StoredBlockInfo));
            storedBlockHashes[totalBlocksExecuted] = hashStoredBlockInfo(lastBlockInfo);
        }

        zkSyncCommitBlockAddress = address(0xcb4c185cC1bC048742D3b6AB760Efd2D3592c58f);
    }

    /// @notice Checks that current state not is exodus mode
    function requireActive() internal view {
        require(!exodusMode, "L"); // exodus mode activated
    }

    /// @notice Accrues users balances from deposit priority requests in Exodus mode
    /// @dev WARNING: Only for Exodus mode
    /// @dev Canceling may take several separate transactions to be completed
    /// @param _n number of requests to process
    function cancelOutstandingDepositsForExodusMode(uint64 _n, bytes[] memory _depositsPubdata) external nonReentrant {
        require(exodusMode, "8"); // exodus mode not active
        uint64 toProcess = Utils.minU64(totalOpenPriorityRequests, _n);
        require(toProcess == _depositsPubdata.length, "A");
        require(toProcess > 0, "9"); // no deposits to process
        uint64 currentDepositIdx = 0;
        for (uint64 id = firstPriorityRequestId; id < firstPriorityRequestId + toProcess; id++) {
            if (priorityRequests[id].opType == Operations.OpType.Deposit) {
                bytes memory depositPubdata = _depositsPubdata[currentDepositIdx];
                require(Utils.hashBytesToBytes20(depositPubdata) == priorityRequests[id].hashedPubData, "a");
                ++currentDepositIdx;

                Operations.Deposit memory op = Operations.readDepositPubdata(depositPubdata);
                bytes22 packedBalanceKey = packAddressAndTokenId(op.owner, op.tokenId);
                pendingBalances[packedBalanceKey].balanceToWithdraw += op.amount;
            }
            delete priorityRequests[id];
        }
        firstPriorityRequestId += toProcess;
        totalOpenPriorityRequests -= toProcess;
    }

    /// @notice Deposit ETH to Layer 2 - transfer ether from user into contract, validate it, register deposit
    function depositETH() external payable {
        require(msg.value > 0, "1");
        requireActive();
        require(tokenIds[msg.sender] == 0, "da");
        registerDeposit(0, SafeCast.toUint128(msg.value), msg.sender);
    }

    /// @notice Deposit ERC20 token to Layer 2 - transfer ERC20 tokens from user into contract, validate it, register deposit
    /// @param _token Token address
    /// @param _amount Token amount
    function depositERC20(IERC20 _token, uint104 _amount) external nonReentrant {
        requireActive();
        require(tokenIds[msg.sender] == 0, "db");

        // Get token id by its address
        uint16 lpTokenId = tokenIds[address(_token)];
        uint16 tokenId = 0;
        if (lpTokenId == 0) {
            // This means it is not a pair address
            tokenId = governance.validateTokenAddress(address(_token));
            require(!governance.pausedTokens(tokenId), "b"); // token deposits are paused
            require(_token.balanceOf(address(this)) + _amount <= MAX_ERC20_TOKEN_BALANCE, "bgt");
        } else {
            // lpToken
            lpTokenId = validatePairTokenAddress(address(_token));
        }

        uint256 balance_before = 0;
        uint256 balance_after = 0;
        uint128 deposit_amount = 0;
        // lpToken
        if (lpTokenId > 0) {
            // Note: For lp token, main contract always has no money
            balance_before = _token.balanceOf(msg.sender);
            pairmanager.burn(address(_token), msg.sender, SafeCast.toUint128(_amount)); //
            balance_after = _token.balanceOf(msg.sender);
            deposit_amount = SafeCast.toUint128(balance_before.sub(balance_after));
            require(deposit_amount <= MAX_DEPOSIT_AMOUNT, "C1");
            registerDeposit(lpTokenId, deposit_amount, msg.sender);
        } else {
            // token
            balance_before = _token.balanceOf(address(this));
            require(Utils.transferFromERC20(_token, msg.sender, address(this), SafeCast.toUint128(_amount)), "fd012"); // token transfer failed deposit
            balance_after = _token.balanceOf(address(this));
            deposit_amount = SafeCast.toUint128(balance_after.sub(balance_before));
            require(deposit_amount <= MAX_DEPOSIT_AMOUNT, "C2");
            registerDeposit(tokenId, deposit_amount, msg.sender);
        }
    }

    /// @notice Returns amount of tokens that can be withdrawn by `address` from zkSync contract
    /// @param _address Address of the tokens owner
    /// @param _token Address of token, zero address is used for ETH
    function getPendingBalance(address _address, address _token) public view returns (uint128) {
        uint16 tokenId = 0;
        if (_token != address(0)) {
            tokenId = governance.validateTokenAddress(_token);
        }
        return pendingBalances[packAddressAndTokenId(_address, tokenId)].balanceToWithdraw;
    }

    /// @notice Returns amount of tokens that can be withdrawn by `address` from zkSync contract
    /// @param _address Address of the tokens owner
    /// @param _tokenId token id, 0 is used for ETH
    function getBalanceToWithdraw(address _address, uint16 _tokenId) public view returns (uint128) {
        return pendingBalances[packAddressAndTokenId(_address, _tokenId)].balanceToWithdraw;
    }

    /// @notice Register full exit request - pack pubdata, add priority request
    /// @param _accountId Numerical id of the account
    /// @param _token Token address, 0 address for ether
    function requestFullExit(uint32 _accountId, address _token) public nonReentrant {
        requireActive();
        require(_accountId <= MAX_ACCOUNT_ID, "e");

        uint16 tokenId;
        uint16 lpTokenId = tokenIds[_token];
        if (_token == address(0)) {
            tokenId = 0;
        } else if (lpTokenId == 0) {
            // This means it is not a pair address
            // 非lpToken
            tokenId = governance.validateTokenAddress(_token);
            require(!governance.pausedTokens(tokenId), "b"); // token deposits are paused
        } else {
            // lpToken
            tokenId = lpTokenId;
        }

        // Priority Queue request
        Operations.FullExit memory op =
            Operations.FullExit({
                accountId: _accountId,
                owner: msg.sender,
                tokenId: tokenId,
                amount: 0, // unknown at this point
                pairAccountId: 0
            });
        bytes memory pubData = Operations.writeFullExitPubdataForPriorityQueue(op);
        addPriorityRequest(Operations.OpType.FullExit, pubData);

        // User must fill storage slot of balancesToWithdraw(msg.sender, tokenId) with nonzero value
        // In this case operator should just overwrite this slot during confirming withdrawal
        bytes22 packedBalanceKey = packAddressAndTokenId(msg.sender, tokenId);
        pendingBalances[packedBalanceKey].gasReserveValue = FILLED_GAS_RESERVE_VALUE;
    }

   /// @notice Checks if Exodus mode must be entered. If true - enters exodus mode and emits ExodusMode event.
    /// @dev Exodus mode must be entered in case of current ethereum block number is higher than the oldest
    /// @dev of existed priority requests expiration block number.
    /// @return bool flag that is true if the Exodus mode must be entered.
    function activateExodusMode() public returns (bool) {
        bool trigger =
            block.number >= priorityRequests[firstPriorityRequestId].expirationBlock &&
                priorityRequests[firstPriorityRequestId].expirationBlock != 0;
        if (trigger) {
            if (!exodusMode) {
                exodusMode = true;
                emit ExodusMode();
            }
            return true;
        } else {
            return false;
        }
    }

    /// @notice Register deposit request - pack pubdata, add priority request and emit OnchainDeposit event
    /// @param _tokenId Token by id
    /// @param _amount Token amount
    /// @param _owner Receiver
    function registerDeposit(
        uint16 _tokenId,
        uint128 _amount,
        address _owner
    ) internal {
        // Priority Queue request
        Operations.Deposit memory op =
            Operations.Deposit({
                accountId: 0, // unknown at this point
                owner: _owner,
                tokenId: _tokenId,
                amount: _amount,
                pairAccountId: 0
            });
        bytes memory pubData = Operations.writeDepositPubdataForPriorityQueue(op);
        addPriorityRequest(Operations.OpType.Deposit, pubData);

        emit OnchainDeposit(
            msg.sender,
            _tokenId,
            _amount,
            _owner
        );
    }

    // The contract is too large. Break some functions to zkSyncCommitBlockAddress
    fallback() external payable {
        address nextAddress = zkSyncCommitBlockAddress;
        require(nextAddress != address(0), "zkSyncCommitBlockAddress should be set");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), nextAddress, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
}


