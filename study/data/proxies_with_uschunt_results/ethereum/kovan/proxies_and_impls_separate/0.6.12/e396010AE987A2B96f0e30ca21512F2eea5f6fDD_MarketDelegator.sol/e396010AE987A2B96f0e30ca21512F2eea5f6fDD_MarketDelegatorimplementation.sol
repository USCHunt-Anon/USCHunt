// File: contracts/interface/DelegatorInterface.sol

pragma solidity 0.6.12;

contract DelegationStorage {
    /**
     * @notice Implementation address for this contract
     */
    address public implementation;
}

abstract contract DelegatorInterface is DelegationStorage {
    /**
     * @notice Emitted when implementation is changed
     */
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation
     */
    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public virtual;
}

abstract contract DelegateInterface is DelegationStorage {
    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @dev Should revert if any issues arise which make it unfit for delegation
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) public virtual;

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() public virtual;
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// File: contracts/interface/MarketInterfaces.sol

pragma solidity 0.6.12;


contract IShardsMarketStorge {
    address public shardsFactory;
    address public router;
    address public governance;

    address public factory;

    address public dev;

    address public tokenBar;

    address public shardsFarm;

    address public buyoutProposals;

    //The totalSupply of shard in the market
    uint256 public totalSupply = 10000000000000000000000;

    address public WETH;

    //Stake Time limit: 60*60*24*5
    uint256 public deadlineForStake = 432000;
    //Redeem Time limit:60*60*24*7
    uint256 public deadlineForRedeem = 604800;
    //The Proportion of the shardsCreator's shards
    uint256 public shardsCreatorProportion = 5;
    //The Proportion of the platform's shards
    uint256 public platformProportion = 5;

    //The Proportion of shards ownership  to buyout
    uint256 public buyoutProportion = 15;
    //max
    uint256 internal constant max = 100;
    // n times higher than the market price to buyout
    uint256 public buyoutTimes = 1;
    //shardPool count
    uint256 public shardPoolIdCount;
    // all of the shardpoolId
    uint256[] internal allPools;
    // Info of each pool.
    mapping(uint256 => shardPool) public poolInfo;
    //shardPool
    struct shardPool {
        address creator; //shard  creator
        uint256 tokenId; //tokenID of nft
        ShardsState state; //shard state
        uint256 createTime;
        uint256 deadlineForStake;
        uint256 deadlineForRedeem;
        uint256 balanceOfWantToken; // all the stake amount of the wantToken in this pool
        uint256 minWantTokenAmount; //Minimum subscription required by the creator
        address nft; //nft address
        bool isCreatorWithDraw; //Does the creator withdraw wantToken
        address wantToken; // token address Requested by the creator for others to stake
        uint256 openingPrice;
    }

    mapping(uint256 => shard) public shardInfo;
    struct shard {
        string shardName;
        string shardSymbol;
        address shardToken;
        uint256 totalShardSupply;
        uint256 shardForCreator;
        uint256 shardForPlatform;
        uint256 shardForStakers;
        uint256 burnAmount;
    }

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    struct UserInfo {
        uint256 amount;
        bool isWithdrawShard;
    }


    uint256 public profitProportionForDev = 20;

    address public regulator;

    address public shardAdditionProposal;

    enum ShardsState {
        Live,
        Listed,
        ApplyForBuyout,
        Buyout,
        SubscriptionFailed,
        Pending,
        AuditFailed,
        ApplyForAddition
    }
}

abstract contract IShardsMarket is IShardsMarketStorge, IERC721Receiver {
    event ShardCreated(
        uint256 shardPoolId,
        address indexed creator,
        address nft,
        uint256 _tokenId,
        string shardName,
        string shardSymbol,
        uint256 minWantTokenAmount,
        uint256 createTime,
        uint256 totalSupply,
        address wantToken
    );
    event Stake(address indexed sender, uint256 shardPoolId, uint256 amount);
    event Redeem(address indexed sender, uint256 shardPoolId, uint256 amount);
    event SettleSuccess(
        uint256 indexed shardPoolId,
        uint256 platformAmount,
        uint256 shardForStakers,
        uint256 balanceOfWantToken,
        uint256 fee,
        address shardToken
    );
    event SettleFail(uint256 indexed shardPoolId);
    event ApplyForBuyout(
        address indexed sender,
        uint256 indexed proposalId,
        uint256 indexed _shardPoolId,
        uint256 shardAmount,
        uint256 wantTokenAmount,
        uint256 voteDeadline,
        uint256 buyoutTimes,
        uint256 price,
        uint256 blockHeight
    );
    event Vote(
        address indexed sender,
        uint256 indexed proposalId,
        uint256 indexed _shardPoolId,
        bool isAgree,
        uint256 voteAmount
    );
    event VoteResultConfirm(
        uint256 indexed proposalId,
        uint256 indexed _shardPoolId,
        bool isPassed
    );

    function createShard(
        address nft,
        uint256 _tokenId,
        string memory shardName,
        string memory shardSymbol,
        uint256 minWantTokenAmount,
        address wantToken
    ) external virtual returns (uint256 shardPoolId);

    function stakeETH(uint256 _shardPoolId) external payable virtual;

    function stake(uint256 _shardPoolId, uint256 amount) external virtual;

    function redeem(uint256 _shardPoolId, uint256 amount) external virtual;

    function redeemETH(uint256 _shardPoolId, uint256 amount) external virtual;

    function settle(uint256 _shardPoolId) external virtual;

    function redeemInSubscriptionFailed(uint256 _shardPoolId) external virtual;

    function usersWithdrawShardToken(uint256 _shardPoolId) external virtual;

    function creatorWithdrawWantToken(uint256 _shardPoolId) external virtual;

    function applyForBuyout(uint256 _shardPoolId, uint256 wantTokenAmount)
        external
        virtual
        returns (uint256 proposalId);

    function applyForBuyoutETH(uint256 _shardPoolId)
        external
        payable
        virtual
        returns (uint256 proposalId);

    function vote(uint256 _shardPoolId, bool isAgree) external virtual;

    function voteResultConfirm(uint256 _shardPoolId)
        external
        virtual
        returns (bool result);

    function exchangeForWantToken(uint256 _shardPoolId, uint256 shardAmount)
        external
        virtual
        returns (uint256 wantTokenAmount);

    function redeemForBuyoutFailed(uint256 _proposalId)
        external
        virtual
        returns (uint256 shardTokenAmount, uint256 wantTokenAmount);

    function setShardsCreatorProportion(uint256 _shardsCreatorProportion)
        external
        virtual;

    function setPlatformProportion(uint256 _platformProportion)
        external
        virtual;

    function setTotalSupply(uint256 _totalSupply) external virtual;

    function setDeadlineForRedeem(uint256 _deadlineForRedeem) external virtual;

    function setDeadlineForStake(uint256 _deadlineForStake) external virtual;

    function setDev(address _dev) external virtual;

    function setProfitProportionForDev(uint256 _profitProportionForDev)
        external
        virtual;

    function setGovernance(address _governance) external virtual;

    function setTokenBar(address _tokenBar) external virtual;

    function setShardsFarm(address _shardsFarm) external virtual;

    function setRegulator(address _regulator) external virtual;

    function shardAudit(uint256 _shardPoolId, bool isPassed) external virtual {}

    function getPrice(uint256 _shardPoolId)
        public
        view
        virtual
        returns (uint256 currentPrice)
    {}

    function getAllPools()
        external
        view
        virtual
        returns (uint256[] memory _pools)
    {}

}

// File: contracts/interface/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);
}

// File: contracts/interface/IShardToken.sol

pragma solidity 0.6.12;

interface IShardToken {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function burn(address from, uint256 value) external;

    function mint(address to, uint256 value) external;

    function initialize(
        string memory _name,
        string memory _symbol,
        address market
    ) external;

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);
}

// File: contracts/interface/IShardsFactory.sol

pragma solidity 0.6.12;

interface IShardsFactory {
    event ShardTokenCreated(address shardToken);

    function createShardToken(
        uint256 poolId,
        string memory name,
        string memory symbol
    ) external returns (address shardToken);
}

// File: contracts/interface/IShardsFarm.sol

pragma solidity 0.6.12;

interface IShardsFarm {
    function add(
        uint256 poolId,
        address lpToken,
        address ethLpToken
    ) external;
}

// File: contracts/interface/IMarketRegulator.sol

pragma solidity 0.6.12;

interface IMarketRegulator {
    function IsInWhiteList(address wantToken)
        external
        view
        returns (bool inTheList);

    function IsInBlackList(uint256 _shardPoolId)
        external
        view
        returns (bool inTheList);
}

// File: contracts/interface/IBuyoutProposals.sol

pragma solidity 0.6.12;

contract IBuyoutProposalsStorge {
    address public governance;
    address public regulator;
    address public market;

    uint256 public proposolIdCount;

    uint256 public voteLenth = 259200;

    mapping(uint256 => uint256) public proposalIds;

    mapping(uint256 => uint256[]) internal proposalsHistory;

    mapping(uint256 => Proposal) public proposals;

    mapping(uint256 => mapping(address => bool)) public voted;

    uint256 public passNeeded = 75;

    // n times higher than the market price to buyout
    uint256 public buyoutTimes = 100;

    uint256 internal constant max = 100;

    uint256 public buyoutProportion = 15;

    mapping(uint256 => uint256) allVotes;

    struct Proposal {
        uint256 votesReceived;
        uint256 voteTotal;
        bool passed;
        address submitter;
        uint256 voteDeadline;
        uint256 shardAmount;
        uint256 wantTokenAmount;
        uint256 buyoutTimes;
        uint256 price;
        bool isSubmitterWithDraw;
        uint256 shardPoolId;
        bool isFailedConfirmed;
        uint256 blockHeight;
        uint256 createTime;
    }
}

abstract contract IBuyoutProposals is IBuyoutProposalsStorge {
    function createProposal(
        uint256 _shardPoolId,
        uint256 shardBalance,
        uint256 wantTokenAmount,
        uint256 currentPrice,
        uint256 totalShardSupply,
        address submitter
    ) external virtual returns (uint256 proposalId, uint256 buyoutTimes);

    function vote(
        uint256 _shardPoolId,
        bool isAgree,
        address shard,
        address voter
    ) external virtual returns (uint256 proposalId, uint256 balance);

    function voteResultConfirm(uint256 _shardPoolId)
        external
        virtual
        returns (
            uint256 proposalId,
            bool result,
            address submitter,
            uint256 shardAmount,
            uint256 wantTokenAmount
        );

    function exchangeForWantToken(uint256 _shardPoolId, uint256 shardAmount)
        external
        view
        virtual
        returns (uint256 wantTokenAmount);

    function redeemForBuyoutFailed(uint256 _proposalId, address submitter)
        external
        virtual
        returns (
            uint256 _shardPoolId,
            uint256 shardTokenAmount,
            uint256 wantTokenAmount
        );

    function setBuyoutTimes(uint256 _buyoutTimes) external virtual;

    function setVoteLenth(uint256 _voteLenth) external virtual;

    function setPassNeeded(uint256 _passNeeded) external virtual;

    function setBuyoutProportion(uint256 _buyoutProportion) external virtual;

    function setGovernance(address _governance) external virtual;

    function setMarket(address _market) external virtual;

    function getProposalsForExactPool(uint256 _shardPoolId)
        external
        view
        virtual
        returns (uint256[] memory _proposalsHistory);
}

// File: contracts/libraries/TransferHelper.sol

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// File: contracts/interface/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// File: contracts/interface/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/libraries/NFTLibrary.sol

pragma solidity 0.6.12;




library NFTLibrary {
    using SafeMath for uint256;

    function getPrice(
        address tokenA,
        address tokenB,
        address factory
    ) internal view returns (uint256 currentPrice) {
        address lPTokenAddress =
            IUniswapV2Factory(factory).getPair(tokenA, tokenB);

        if (lPTokenAddress == address(0)) {
            return currentPrice;
        }

        (uint112 _reserve0, uint112 _reserve1, ) =
            IUniswapV2Pair(lPTokenAddress).getReserves();

        address token0 = IUniswapV2Pair(lPTokenAddress).token0();

        (uint112 reserve0, uint112 reserve1) =
            token0 == tokenA ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
        currentPrice = quote(1e18, reserve0, reserve1);
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function balanceOf(address user, address lPTokenAddress)
        internal
        view
        returns (uint256 balance)
    {
        balance = IUniswapV2Pair(lPTokenAddress).balanceOf(user);
    }

    function getPair(
        address tokenA,
        address tokenB,
        address factory
    ) internal view returns (address pair) {
        pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    function tokenVerify(string memory tokenName, uint256 lenthLimit)
        internal
        pure
        returns (bool success)
    {
        bytes memory nameBytes = bytes(tokenName);
        uint256 nameLength = nameBytes.length;
        require(0 < nameLength && nameLength <= lenthLimit, "INVALID INPUT");
        success = true;
        bool n7;
        for (uint256 i = 0; i <= nameLength - 1; i++) {
            n7 = (nameBytes[i] & 0x80) == 0x80 ? true : false;
            if (n7) {
                success = false;
                break;
            }
        }
    }
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol



pragma solidity >=0.6.2 <0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: contracts/interface/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
}

// File: contracts/interface/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {}

// File: contracts/ShardsMarket.sol

pragma solidity 0.6.12;













contract ShardsMarket is IShardsMarket {
    using SafeMath for uint256;

    constructor() public {}

    function initialize(
        address _WETH,
        address _factory,
        address _governance,
        address _router,
        address _dev,
        address _tokenBar,
        address _shardsFactory,
        address _regulator,
        address _buyoutProposals
    ) public {
        require(governance == msg.sender, "UNAUTHORIZED");
        require(WETH == address(0), "ALREADY INITIALIZED");
        WETH = _WETH;
        factory = _factory;
        governance = _governance;
        router = _router;
        dev = _dev;
        tokenBar = _tokenBar;
        shardsFactory = _shardsFactory;
        regulator = _regulator;
        buyoutProposals = _buyoutProposals;
    }

    function createShard(
        address nft,
        uint256 _tokenId,
        string memory shardName,
        string memory shardSymbol,
        uint256 minWantTokenAmount,
        address wantToken
    ) external override returns (uint256 shardPoolId) {
        require(IERC721(nft).ownerOf(_tokenId) == msg.sender, "UNAUTHORIZED");
        require(
            NFTLibrary.tokenVerify(shardName, 30) &&
                NFTLibrary.tokenVerify(shardSymbol, 30),
            "INVALID NAME/SYMBOL"
        );

        require(minWantTokenAmount > 0, "INVALID MINAMOUNT INPUT");
        require(
            IMarketRegulator(regulator).IsInWhiteList(wantToken),
            "WANTTOKEN IS NOT ON THE LIST"
        );
        shardPoolId = shardPoolIdCount.add(1);
        poolInfo[shardPoolId] = shardPool({
            creator: msg.sender,
            tokenId: _tokenId,
            state: ShardsState.Live,
            createTime: block.timestamp,
            deadlineForStake: block.timestamp.add(deadlineForStake),
            deadlineForRedeem: block.timestamp.add(deadlineForRedeem),
            balanceOfWantToken: 0,
            minWantTokenAmount: minWantTokenAmount,
            nft: nft,
            isCreatorWithDraw: false,
            wantToken: wantToken,
            openingPrice: 0
        });
        IERC721(nft).safeTransferFrom(msg.sender, address(this), _tokenId);
        uint256 creatorAmount =
            totalSupply.mul(shardsCreatorProportion).div(max);
        uint256 platformAmount = totalSupply.mul(platformProportion).div(max);
        uint256 stakersAmount =
            totalSupply.sub(creatorAmount).sub(platformAmount);
        shardInfo[shardPoolId] = shard({
            shardName: shardName,
            shardSymbol: shardSymbol,
            shardToken: address(0),
            totalShardSupply: totalSupply,
            shardForCreator: creatorAmount,
            shardForPlatform: platformAmount,
            shardForStakers: stakersAmount,
            burnAmount: 0
        });
        allPools.push(shardPoolId);
        shardPoolIdCount = shardPoolId;
        emit ShardCreated(
            shardPoolId,
            msg.sender,
            nft,
            _tokenId,
            shardName,
            shardSymbol,
            minWantTokenAmount,
            block.timestamp,
            totalSupply,
            wantToken
        );
    }

    function stake(uint256 _shardPoolId, uint256 amount) external override {
        require(
            block.timestamp <= poolInfo[_shardPoolId].deadlineForStake,
            "EXPIRED"
        );
        address wantToken = poolInfo[_shardPoolId].wantToken;
        TransferHelper.safeTransferFrom(
            wantToken,
            msg.sender,
            address(this),
            amount
        );
        _stake(_shardPoolId, amount);
    }

    function stakeETH(uint256 _shardPoolId) external payable override {
        require(
            block.timestamp <= poolInfo[_shardPoolId].deadlineForStake,
            "EXPIRED"
        );
        require(poolInfo[_shardPoolId].wantToken == WETH, "UNWANTED");
        IWETH(WETH).deposit{value: msg.value}();
        _stake(_shardPoolId, msg.value);
    }

    function _stake(uint256 _shardPoolId, uint256 amount) private {
        require(amount > 0, "INSUFFIENT INPUT");
        userInfo[_shardPoolId][msg.sender].amount = userInfo[_shardPoolId][
            msg.sender
        ]
            .amount
            .add(amount);
        poolInfo[_shardPoolId].balanceOfWantToken = poolInfo[_shardPoolId]
            .balanceOfWantToken
            .add(amount);
        emit Stake(msg.sender, _shardPoolId, amount);
    }

    function redeem(uint256 _shardPoolId, uint256 amount) external override {
        _redeem(_shardPoolId, amount);
        TransferHelper.safeTransfer(
            poolInfo[_shardPoolId].wantToken,
            msg.sender,
            amount
        );
        emit Redeem(msg.sender, _shardPoolId, amount);
    }

    function redeemETH(uint256 _shardPoolId, uint256 amount) external override {
        require(poolInfo[_shardPoolId].wantToken == WETH, "UNWANTED");
        _redeem(_shardPoolId, amount);
        IWETH(WETH).withdraw(amount);
        TransferHelper.safeTransferETH(msg.sender, amount);
        emit Redeem(msg.sender, _shardPoolId, amount);
    }

    function _redeem(uint256 _shardPoolId, uint256 amount) private {
        require(
            block.timestamp <= poolInfo[_shardPoolId].deadlineForRedeem,
            "EXPIRED"
        );
        require(amount > 0, "INSUFFIENT INPUT");
        userInfo[_shardPoolId][msg.sender].amount = userInfo[_shardPoolId][
            msg.sender
        ]
            .amount
            .sub(amount);
        poolInfo[_shardPoolId].balanceOfWantToken = poolInfo[_shardPoolId]
            .balanceOfWantToken
            .sub(amount);
    }

    function settle(uint256 _shardPoolId) external override {
        require(
            block.timestamp > poolInfo[_shardPoolId].deadlineForRedeem,
            "NOT READY"
        );
        require(
            poolInfo[_shardPoolId].state == ShardsState.Live,
            "LIVE STATE IS REQUIRED"
        );
        if (
            poolInfo[_shardPoolId].balanceOfWantToken <
            poolInfo[_shardPoolId].minWantTokenAmount ||
            IMarketRegulator(regulator).IsInBlackList(_shardPoolId)
        ) {
            poolInfo[_shardPoolId].state = ShardsState.SubscriptionFailed;
            IERC721(poolInfo[_shardPoolId].nft).safeTransferFrom(
                address(this),
                poolInfo[_shardPoolId].creator,
                poolInfo[_shardPoolId].tokenId
            );
            emit SettleFail(_shardPoolId);
        } else {
            _successToSetPrice(_shardPoolId);
        }
    }

    function redeemInSubscriptionFailed(uint256 _shardPoolId)
        external
        override
    {
        require(
            poolInfo[_shardPoolId].state == ShardsState.SubscriptionFailed,
            "WRONG STATE"
        );
        uint256 balance = userInfo[_shardPoolId][msg.sender].amount;
        require(balance > 0, "INSUFFIENT BALANCE");
        userInfo[_shardPoolId][msg.sender].amount = 0;
        poolInfo[_shardPoolId].balanceOfWantToken = poolInfo[_shardPoolId]
            .balanceOfWantToken
            .sub(balance);
        if (poolInfo[_shardPoolId].wantToken == WETH) {
            IWETH(WETH).withdraw(balance);
            TransferHelper.safeTransferETH(msg.sender, balance);
        } else {
            TransferHelper.safeTransfer(
                poolInfo[_shardPoolId].wantToken,
                msg.sender,
                balance
            );
        }

        emit Redeem(msg.sender, _shardPoolId, balance);
    }

    function usersWithdrawShardToken(uint256 _shardPoolId) external override {
        require(
            poolInfo[_shardPoolId].state == ShardsState.Listed ||
                poolInfo[_shardPoolId].state == ShardsState.Buyout ||
                poolInfo[_shardPoolId].state == ShardsState.ApplyForBuyout,
            "WRONG_STATE"
        );
        uint256 userBanlance = userInfo[_shardPoolId][msg.sender].amount;
        bool isWithdrawShard =
            userInfo[_shardPoolId][msg.sender].isWithdrawShard;
        require(userBanlance > 0 && !isWithdrawShard, "INSUFFIENT BALANCE");
        uint256 shardsForUsers = shardInfo[_shardPoolId].shardForStakers;
        uint256 totalBalance = poolInfo[_shardPoolId].balanceOfWantToken;
        // formula:
        // shardAmount/shardsForUsers= userBanlance/totalBalance
        //
        uint256 shardAmount =
            userBanlance.mul(shardsForUsers).div(totalBalance);
        userInfo[_shardPoolId][msg.sender].isWithdrawShard = true;
        IShardToken(shardInfo[_shardPoolId].shardToken).mint(
            msg.sender,
            shardAmount
        );
    }

    function creatorWithdrawWantToken(uint256 _shardPoolId) external override {
        require(msg.sender == poolInfo[_shardPoolId].creator, "UNAUTHORIZED");
        require(
            poolInfo[_shardPoolId].state == ShardsState.Listed ||
                poolInfo[_shardPoolId].state == ShardsState.Buyout ||
                poolInfo[_shardPoolId].state == ShardsState.ApplyForBuyout,
            "WRONG_STATE"
        );

        require(!poolInfo[_shardPoolId].isCreatorWithDraw, "ALREADY WITHDRAW");
        uint256 totalBalance = poolInfo[_shardPoolId].balanceOfWantToken;
        uint256 platformAmount = shardInfo[_shardPoolId].shardForPlatform;
        uint256 fee =
            poolInfo[_shardPoolId].balanceOfWantToken.mul(platformAmount).div(
                shardInfo[_shardPoolId].shardForStakers
            );
        uint256 amount = totalBalance.sub(fee);
        poolInfo[_shardPoolId].isCreatorWithDraw = true;
        if (poolInfo[_shardPoolId].wantToken == WETH) {
            IWETH(WETH).withdraw(amount);
            TransferHelper.safeTransferETH(msg.sender, amount);
        } else {
            TransferHelper.safeTransfer(
                poolInfo[_shardPoolId].wantToken,
                msg.sender,
                amount
            );
        }
        uint256 creatorAmount = shardInfo[_shardPoolId].shardForCreator;
        address shardToken = shardInfo[_shardPoolId].shardToken;
        IShardToken(shardToken).mint(
            poolInfo[_shardPoolId].creator,
            creatorAmount
        );
    }

    function applyForBuyout(uint256 _shardPoolId, uint256 wantTokenAmount)
        external
        override
        returns (uint256 proposalId)
    {
        proposalId = _applyForBuyout(_shardPoolId, wantTokenAmount);
    }

    function applyForBuyoutETH(uint256 _shardPoolId)
        external
        payable
        override
        returns (uint256 proposalId)
    {
        require(poolInfo[_shardPoolId].wantToken == WETH, "UNWANTED");
        proposalId = _applyForBuyout(_shardPoolId, msg.value);
    }

    function _applyForBuyout(uint256 _shardPoolId, uint256 wantTokenAmount)
        private
        returns (uint256 proposalId)
    {
        require(msg.sender == tx.origin, "INVALID SENDER");
        require(
            poolInfo[_shardPoolId].state == ShardsState.Listed,
            "LISTED STATE IS REQUIRED"
        );
        uint256 shardBalance =
            IShardToken(shardInfo[_shardPoolId].shardToken).balanceOf(
                msg.sender
            );
        uint256 totalShardSupply = shardInfo[_shardPoolId].totalShardSupply;

        uint256 currentPrice = getPrice(_shardPoolId);
        uint256 buyoutTimes;
        (proposalId, buyoutTimes) = IBuyoutProposals(buyoutProposals)
            .createProposal(
            _shardPoolId,
            shardBalance,
            wantTokenAmount,
            currentPrice,
            totalShardSupply,
            msg.sender
        );
        if (
            poolInfo[_shardPoolId].wantToken == WETH &&
            msg.value == wantTokenAmount
        ) {
            IWETH(WETH).deposit{value: wantTokenAmount}();
        } else {
            TransferHelper.safeTransferFrom(
                poolInfo[_shardPoolId].wantToken,
                msg.sender,
                address(this),
                wantTokenAmount
            );
        }
        TransferHelper.safeTransferFrom(
            shardInfo[_shardPoolId].shardToken,
            msg.sender,
            address(this),
            shardBalance
        );

        poolInfo[_shardPoolId].state = ShardsState.ApplyForBuyout;

        emit ApplyForBuyout(
            msg.sender,
            proposalId,
            _shardPoolId,
            shardBalance,
            wantTokenAmount,
            block.timestamp,
            buyoutTimes,
            currentPrice,
            block.number
        );
    }

    function vote(uint256 _shardPoolId, bool isAgree) external override {
        require(
            poolInfo[_shardPoolId].state == ShardsState.ApplyForBuyout,
            "WRONG STATE"
        );
        address shard = shardInfo[_shardPoolId].shardToken;

        (uint256 proposalId, uint256 balance) =
            IBuyoutProposals(buyoutProposals).vote(
                _shardPoolId,
                isAgree,
                shard,
                msg.sender
            );
          emit Vote(msg.sender, proposalId, _shardPoolId, isAgree, balance);
    }

    function voteResultConfirm(uint256 _shardPoolId)
        external
        override
        returns (bool)
    {
        (
            uint256 proposalId,
            bool result,
            address submitter,
            uint256 shardAmount,
            uint256 wantTokenAmount
        ) = IBuyoutProposals(buyoutProposals).voteResultConfirm(_shardPoolId);

        if (result) {
            poolInfo[_shardPoolId].state = ShardsState.Buyout;
            IShardToken(shardInfo[_shardPoolId].shardToken).burn(
                address(this),
                shardAmount
            );
            shardInfo[_shardPoolId].burnAmount = shardInfo[_shardPoolId]
                .burnAmount
                .add(shardAmount);
            IERC721(poolInfo[_shardPoolId].nft).safeTransferFrom(
                address(this),
                submitter,
                poolInfo[_shardPoolId].tokenId
            );
            _getProfit(_shardPoolId, wantTokenAmount, shardAmount);
        } else {
            poolInfo[_shardPoolId].state = ShardsState.Listed;
        }

        emit VoteResultConfirm(proposalId, _shardPoolId, result);

        return result;
    }

    function exchangeForWantToken(uint256 _shardPoolId, uint256 shardAmount)
        external
        override
        returns (uint256 wantTokenAmount)
    {
        require(
            poolInfo[_shardPoolId].state == ShardsState.Buyout,
            "WRONG STATE"
        );
        TransferHelper.safeTransferFrom(
            shardInfo[_shardPoolId].shardToken,
            msg.sender,
            address(this),
            shardAmount
        );
        IShardToken(shardInfo[_shardPoolId].shardToken).burn(
            address(this),
            shardAmount
        );
        shardInfo[_shardPoolId].burnAmount = shardInfo[_shardPoolId]
            .burnAmount
            .add(shardAmount);
         
        wantTokenAmount = IBuyoutProposals(buyoutProposals)
            .exchangeForWantToken(_shardPoolId, shardAmount);
        require(wantTokenAmount > 0, "LESS THAN 1 WEI");
        if (poolInfo[_shardPoolId].wantToken == WETH) {
            IWETH(WETH).withdraw(wantTokenAmount);
            TransferHelper.safeTransferETH(msg.sender, wantTokenAmount);
        } else {
            TransferHelper.safeTransfer(
                poolInfo[_shardPoolId].wantToken,
                msg.sender,
                wantTokenAmount
            );
        }
    }

    function redeemForBuyoutFailed(uint256 _proposalId)
        external
        override
        returns (uint256 shardTokenAmount, uint256 wantTokenAmount)
    {
        uint256 shardPoolId;
        (shardPoolId, shardTokenAmount, wantTokenAmount) = IBuyoutProposals(
            buyoutProposals
        )
            .redeemForBuyoutFailed(_proposalId, msg.sender);
        TransferHelper.safeTransfer(
            shardInfo[shardPoolId].shardToken,
            msg.sender,
            shardTokenAmount
        );
        if (poolInfo[shardPoolId].wantToken == WETH) {
            IWETH(WETH).withdraw(wantTokenAmount);
            TransferHelper.safeTransferETH(msg.sender, wantTokenAmount);
        } else {
            TransferHelper.safeTransfer(
                poolInfo[shardPoolId].wantToken,
                msg.sender,
                wantTokenAmount
            );
        }
    }

    function getPrice(uint256 _shardPoolId)
        public
        view
        override
        returns (uint256 currentPrice)
    {
        address tokenA = shardInfo[_shardPoolId].shardToken;
        address tokenB = poolInfo[_shardPoolId].wantToken;
        currentPrice = NFTLibrary.getPrice(tokenA, tokenB, factory);
    }

    function _successToSetPrice(uint256 _shardPoolId) private {
        address shardToken = _deployShardsToken(_shardPoolId);
        poolInfo[_shardPoolId].state = ShardsState.Listed;
        shardInfo[_shardPoolId].shardToken = shardToken;
        address wantToken = poolInfo[_shardPoolId].wantToken;
        uint256 platformAmount = shardInfo[_shardPoolId].shardForPlatform;
        IShardToken(shardToken).mint(address(this), platformAmount);
        uint256 shardPrice =
            poolInfo[_shardPoolId].balanceOfWantToken.mul(1e18).div(
                shardInfo[_shardPoolId].shardForStakers
            );
        //fee= shardPrice * platformAmount =balanceOfWantToken * platformAmount / shardForStakers
        uint256 fee =
            poolInfo[_shardPoolId].balanceOfWantToken.mul(platformAmount).div(
                shardInfo[_shardPoolId].shardForStakers
            );
        poolInfo[_shardPoolId].openingPrice = shardPrice;
        //addLiquidity
        TransferHelper.safeApprove(shardToken, router, platformAmount);
        TransferHelper.safeApprove(wantToken, router, fee);
        IUniswapV2Router02(router).addLiquidity(
            shardToken,
            wantToken,
            platformAmount,
            fee,
            0,
            0,
            address(this),
            now.add(60)
        );

        _addFarmPool(_shardPoolId);

        emit SettleSuccess(
            _shardPoolId,
            platformAmount,
            shardInfo[_shardPoolId].shardForStakers,
            poolInfo[_shardPoolId].balanceOfWantToken,
            fee,
            shardToken
        );
    }

    function _getProfit(
        uint256 _shardPoolId,
        uint256 wantTokenAmount,
        uint256 shardAmount
    ) private {
        address shardToken = shardInfo[_shardPoolId].shardToken;
        address wantToken = poolInfo[_shardPoolId].wantToken;

        address lPTokenAddress =
            NFTLibrary.getPair(shardToken, wantToken, factory);
        uint256 LPTokenBalance =
            NFTLibrary.balanceOf(address(this), lPTokenAddress);
        TransferHelper.safeApprove(lPTokenAddress, router, LPTokenBalance);
        (uint256 amountShardToken, uint256 amountWantToken) =
            IUniswapV2Router02(router).removeLiquidity(
                shardToken,
                wantToken,
                LPTokenBalance,
                0,
                0,
                address(this),
                now.add(60)
            );
        IShardToken(shardInfo[_shardPoolId].shardToken).burn(
            address(this),
            amountShardToken
        );
        shardInfo[_shardPoolId].burnAmount = shardInfo[_shardPoolId]
            .burnAmount
            .add(amountShardToken);
        uint256 supply = shardInfo[_shardPoolId].totalShardSupply;
        uint256 wantTokenAmountForExchange =
            amountShardToken.mul(wantTokenAmount).div(supply.sub(shardAmount));
        uint256 totalProfit = amountWantToken.add(wantTokenAmountForExchange);
        uint256 profitForDev = totalProfit.mul(profitProportionForDev).div(max);
        uint256 profitForTokenBar = totalProfit.sub(profitForDev);
        TransferHelper.safeTransfer(wantToken, dev, profitForDev);
        TransferHelper.safeTransfer(wantToken, tokenBar, profitForTokenBar);
    }

 // admin function
    function setDeadlineForStake(uint256 _deadlineForStake) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        deadlineForStake = _deadlineForStake;
    }

    function setDeadlineForRedeem(uint256 _deadlineForRedeem)
        external
        override
    {
        require(msg.sender == governance, "UNAUTHORIZED");
        deadlineForRedeem = _deadlineForRedeem;
    }

    function setShardsCreatorProportion(uint256 _shardsCreatorProportion)
        external
        override
    {
        require(msg.sender == governance, "UNAUTHORIZED");
        require(_shardsCreatorProportion < max, "INVALID");
        shardsCreatorProportion = _shardsCreatorProportion;
    }

    function setPlatformProportion(uint256 _platformProportion)
        external
        override
    {
        require(msg.sender == governance, "UNAUTHORIZED");
        require(_platformProportion < max, "INVALID");
        platformProportion = _platformProportion;
    }

    function setTotalSupply(uint256 _totalSupply) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        totalSupply = _totalSupply;
    }

    function setDev(address _dev) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        dev = _dev;
    }

    function setProfitProportionForDev(uint256 _profitProportionForDev)
        external
        override
    {
        require(msg.sender == governance, "UNAUTHORIZED");
        profitProportionForDev = _profitProportionForDev;
    }

    function setGovernance(address _governance) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        governance = _governance;
    }

    function setTokenBar(address _tokenBar) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        tokenBar = _tokenBar;
    }

    function setShardsFarm(address _shardsFarm) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        shardsFarm = _shardsFarm;
    }

    function setRegulator(address _regulator) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        regulator = _regulator;
    }

    function shardAudit(uint256 _shardPoolId, bool isPassed) external override {
        require(msg.sender == governance, "UNAUTHORIZED");
        require(
            poolInfo[_shardPoolId].state == ShardsState.Pending,
            "WRONG STATE"
        );
        if (isPassed) {
            poolInfo[_shardPoolId].state = ShardsState.Live;
        } else {
            poolInfo[_shardPoolId].state = ShardsState.AuditFailed;
            IERC721(poolInfo[_shardPoolId].nft).safeTransferFrom(
                address(this),
                poolInfo[_shardPoolId].creator,
                poolInfo[_shardPoolId].tokenId
            );
        }
    }

    function _deployShardsToken(uint256 _shardPoolId)
        private
        returns (address token)
    {
        string memory name = shardInfo[_shardPoolId].shardName;
        string memory symbol = shardInfo[_shardPoolId].shardSymbol;
        token = IShardsFactory(shardsFactory).createShardToken(
            _shardPoolId,
            name,
            symbol
        );
    }

    function _addFarmPool(uint256 _shardPoolId) private {
        address shardToken = shardInfo[_shardPoolId].shardToken;
        address wantToken = poolInfo[_shardPoolId].wantToken;
        address lPTokenSwap =
            NFTLibrary.getPair(shardToken, wantToken, factory);

        address TokenToEthSwap =
            wantToken == WETH
                ? address(0)
                : NFTLibrary.getPair(wantToken, WETH, factory);

        IShardsFarm(shardsFarm).add(
            _shardPoolId,
            lPTokenSwap,
            TokenToEthSwap
        );
    }

    function getAllPools()
        external
        view
        override
        returns (uint256[] memory _pools)
    {
        _pools = allPools;
    }


    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return 0x150b7a02;
    }
}

// File: contracts/MarketDelegate.sol

pragma solidity 0.6.12;



contract MarketDelegate is ShardsMarket, DelegateInterface {
    /**
     * @notice Construct an empty delegate
     */
    constructor() public {}

    /**
     * @notice Called by the delegator on a delegate to initialize it for duty
     * @param data The encoded bytes data for any initialization
     */
    function _becomeImplementation(bytes memory data) public override {
        // Shh -- currently unused
        data;

        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }

        require(
            msg.sender == governance,
            "only the admin may call _becomeImplementation"
        );
    }

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility
     */
    function _resignImplementation() public override {
        // Shh -- we don't ever want this hook to be marked pure
        if (false) {
            implementation = address(0);
        }

        require(
            msg.sender == governance,
            "only the admin may call _resignImplementation"
        );
    }
}