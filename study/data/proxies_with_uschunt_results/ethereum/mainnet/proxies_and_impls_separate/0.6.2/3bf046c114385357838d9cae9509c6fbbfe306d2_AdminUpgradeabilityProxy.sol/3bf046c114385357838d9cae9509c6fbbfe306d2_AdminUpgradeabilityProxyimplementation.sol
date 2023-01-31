// : GPL-3.0-or-later

pragma solidity ^0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-zero");
        z = x / y;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    }
}

// : GPL-3.0-or-later

pragma solidity 0.6.12;

//import"./Address.sol";
//import"./SafeMath.sol";

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// : MIT

pragma solidity ^0.6.0;

/// @dev The non-empty constructor is conflict with upgrades-openzeppelin. 

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
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.

    // NOTE: _NOT_ENTERED is set to ZERO such that it needn't constructor
    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    uint256 private _status;

    // constructor () internal {
    //     _status = _NOT_ENTERED;
    // }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

//import"../lib/SafeERC20.sol";

interface INestPool {

    // function getNTokenFromToken(address token) view external returns (address);
    // function setNTokenToToken(address token, address ntoken) external; 

    function addNest(address miner, uint256 amount) external;
    function addNToken(address contributor, address ntoken, uint256 amount) external;

    function depositEth(address miner) external payable;
    function depositNToken(address miner,  address from, address ntoken, uint256 amount) external;

    function freezeEth(address miner, uint256 ethAmount) external; 
    function unfreezeEth(address miner, uint256 ethAmount) external;

    function freezeNest(address miner, uint256 nestAmount) external;
    function unfreezeNest(address miner, uint256 nestAmount) external;

    function freezeToken(address miner, address token, uint256 tokenAmount) external; 
    function unfreezeToken(address miner, address token, uint256 tokenAmount) external;

    function freezeEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;
    function unfreezeEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;

    function getNTokenFromToken(address token) external view returns (address); 
    function setNTokenToToken(address token, address ntoken) external; 

    function withdrawEth(address miner, uint256 ethAmount) external;
    function withdrawToken(address miner, address token, uint256 tokenAmount) external;

    function withdrawNest(address miner, uint256 amount) external;
    function withdrawEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;
    // function withdrawNToken(address miner, address ntoken, uint256 amount) external;
    function withdrawNTokenAndTransfer(address miner, address ntoken, uint256 amount, address to) external;


    function balanceOfNestInPool(address miner) external view returns (uint256);
    function balanceOfEthInPool(address miner) external view returns (uint256);
    function balanceOfTokenInPool(address miner, address token)  external view returns (uint256);

    function addrOfNestToken() external view returns (address);
    function addrOfNestMining() external view returns (address);
    function addrOfNTokenController() external view returns (address);
    function addrOfNNRewardPool() external view returns (address);
    function addrOfNNToken() external view returns (address);
    function addrOfNestStaking() external view returns (address);
    function addrOfNestQuery() external view returns (address);
    function addrOfNestDAO() external view returns (address);

    function addressOfBurnedNest() external view returns (address);

    function setGovernance(address _gov) external; 
    function governance() external view returns(address);
    function initNestLedger(uint256 amount) external;
    function drainNest(address to, uint256 amount, address gov) external;

}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;


interface INestStaking {
    // Views

    /// @dev How many stakingToken (XToken) deposited into to this reward pool (staking pool)
    /// @param  ntoken The address of NToken
    /// @return The total amount of XTokens deposited in this staking pool
    function totalStaked(address ntoken) external view returns (uint256);

    /// @dev How many stakingToken (XToken) deposited by the target account
    /// @param  ntoken The address of NToken
    /// @param  account The target account
    /// @return The total amount of XToken deposited in this staking pool
    function stakedBalanceOf(address ntoken, address account) external view returns (uint256);


    // Mutative
    /// @dev Stake/Deposit into the reward pool (staking pool)
    /// @param  ntoken The address of NToken
    /// @param  amount The target amount
    function stake(address ntoken, uint256 amount) external;

    function stakeFromNestPool(address ntoken, uint256 amount) external;

    /// @dev Withdraw from the reward pool (staking pool), get the original tokens back
    /// @param  ntoken The address of NToken
    /// @param  amount The target amount
    function unstake(address ntoken, uint256 amount) external;

    /// @dev Claim the reward the user earned
    /// @param ntoken The address of NToken
    /// @return The amount of ethers as rewards
    function claim(address ntoken) external returns (uint256);

    /// @dev Add ETH reward to the staking pool
    /// @param ntoken The address of NToken
    function addETHReward(address ntoken) external payable;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external; 

    function pause() external;

    function resume() external;

    //function setParams(uint8 dividendShareRate) external;

    /* ========== EVENTS ========== */

    // Events
    event RewardAdded(address ntoken, address sender, uint256 reward);
    event NTokenStaked(address ntoken, address indexed user, uint256 amount);
    event NTokenUnstaked(address ntoken, address indexed user, uint256 amount);
    event SavingWithdrawn(address ntoken, address indexed to, uint256 amount);
    event RewardClaimed(address ntoken, address indexed user, uint256 reward);

    event FlagSet(address gov, uint256 flag);
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

interface INToken {
    // mint ntoken for value
    function mint(uint256 amount, address account) external;

    // the block height where the ntoken was created
    function checkBlockInfo() external view returns(uint256 createBlock, uint256 recentlyUsedBlock);
    // the owner (auction winner) of the ntoken
    function checkBidder() external view returns(address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

/// @title The interface of NestQuery
/// @author Inf Loop - <inf-loop@nestprotocol.org>
/// @author Paradox  - <paradox@nestprotocol.org>
interface INestQuery {

    /// @notice Activate a pay-per-query defi client with NEST tokens
    /// @dev No contract is allowed to call it
    /// @param defi The addres of client (DeFi DApp)
    function activate(address defi) external;

    /// @notice Deactivate a pay-per-query defi client
    /// @param defi The address of a client (DeFi DApp)
    function deactivate(address defi) external;

    /// @notice Query for PPQ (pay-per-query) clients
    /// @dev Consider that if a user call a DeFi that queries NestQuery, DeFi should
    ///     pass the user's wallet address to query() as `payback`.
    /// @param token The address of token contract
    /// @param payback The address of change
    function query(address token, address payback) 
        external payable returns (uint256, uint256, uint256);

    /// @notice Query for PPQ (pay-per-query) clients
    /// @param token The address of token contract
    /// @param payback The address of change
    /// @return ethAmount The amount of ETH in pair (ETH, TOKEN)
    /// @return tokenAmount The amount of TOKEN in pair (ETH, TOKEN)
    /// @return avgPrice The average of last 50 prices 
    /// @return vola The volatility of prices 
    /// @return bn The block number when (ETH, TOKEN) takes into effective
    function queryPriceAvgVola(address token, address payback) 
        external payable returns (uint256, uint256, uint128, int128, uint256);

    /// @notice The main function called by DeFi clients, compatible to Nest Protocol v3.0 
    /// @dev  The payback address is ZERO, so the changes are kept in this contract
    ///         The ABI keeps consist with Nest v3.0
    /// @param tokenAddress The address of token contract address
    /// @return ethAmount The amount of ETH in price pair (ETH, ERC20)
    /// @return erc20Amount The amount of ERC20 in price pair (ETH, ERC20)
    /// @return blockNum The block.number where the price is being in effect
    function updateAndCheckPriceNow(address tokenAddress) 
        external payable returns (uint256, uint256, uint256);

    /// @notice A non-free function for querying price 
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @param payback The address for change
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function queryPriceList(address token, uint8 num, address payback) 
        external payable returns (uint128[] memory);

    /// @notice A view function returning the historical price list from the current block
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function priceList(address token, uint8 num) 
        external view returns (uint128[] memory);

    /// @notice A view function returning the latestPrice
    /// @param token  The address of the token contract
    function latestPrice(address token)
    external view returns (uint256 ethAmount, uint256 tokenAmount, uint128 avgPrice, int128 vola, uint256 bn) ;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external; 


    event ClientActivated(address, uint256, uint256);
    // event ClientRenewed(address, uint256, uint256, uint256);
    event PriceQueried(address client, address token, uint256 ethAmount, uint256 tokenAmount, uint256 bn);
    event PriceAvgVolaQueried(address client, address token, uint256 bn, uint128 avgPrice, int128 vola);

    event PriceListQueried(address client, address token, uint256 bn, uint8 num);

    // governance events
    event ParamsSetup(address gov, uint256 oldParams, uint256 newParams);
    event FlagSet(address gov, uint256 flag);
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

//import"../lib/SafeERC20.sol";


interface INestMining {
    
    struct Params {
        uint8    miningEthUnit;     // = 10;
        uint32   nestStakedNum1k;   // = 1;
        uint8    biteFeeRate;       // = 1; 
        uint8    miningFeeRate;     // = 10;
        uint8    priceDurationBlock; 
        uint8    maxBiteNestedLevel; // = 3;
        uint8    biteInflateFactor;
        uint8    biteNestInflateFactor;
    }

    function priceOf(address token) external view returns(uint256 ethAmount, uint256 tokenAmount, uint256 bn);
    
    function priceListOfToken(address token, uint8 num) external view returns(uint128[] memory data, uint256 bn);

    // function priceOfTokenAtHeight(address token, uint64 atHeight) external view returns(uint256 ethAmount, uint256 tokenAmount, uint64 bn);

    function latestPriceOf(address token) external view returns (uint256 ethAmount, uint256 tokenAmount, uint256 bn);

    function priceAvgAndSigmaOf(address token) 
        external view returns (uint128, uint128, int128, uint32);

    function minedNestAmount() external view returns (uint256);

    /// @dev Only for governance
    function loadContracts() external; 
    
    function loadGovernance() external;

    function upgrade() external;

    function setup(uint32   genesisBlockNumber, uint128  latestMiningHeight, uint128  minedNestTotalAmount, Params calldata initParams) external;

    function setParams1(uint128  latestMiningHeight, uint128  minedNestTotalAmount) external;
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

interface INestDAO {

    function addETHReward(address ntoken) external payable; 

    function addNestReward(uint256 amount) external;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external;
    
    /// @dev Only for governance
    function start() external; 

    function initEthLedger(address ntoken, uint256 amount) external;

    event NTokenRedeemed(address ntoken, address user, uint256 amount);

    event AssetsCollected(address user, uint256 ethAmount, uint256 nestAmount);

    event ParamsSetup(address gov, uint256 oldParam, uint256 newParam);

    event FlagSet(address gov, uint256 flag);

}

// : GPL-3.0-or-later

pragma solidity 0.6.12;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

pragma experimental ABIEncoderV2;

//import"./lib/SafeMath.sol";
//import"./lib/SafeERC20.sol";
//import'./lib/TransferHelper.sol';
//import"./lib/ReentrancyGuard.sol";

//import"./iface/INestPool.sol";
//import"./iface/INestStaking.sol";
//import"./iface/INToken.sol";
//import"./iface/INestQuery.sol";
//import"./iface/INestMining.sol";
//import"./iface/INestDAO.sol";

/// @title NestQuery
/// @author Inf Loop - <inf-loop@nestprotocol.org>
/// @author Paradox  - <paradox@nestprotocol.org>
contract NestQuery is INestQuery, ReentrancyGuard {

    using SafeMath for uint256;

    /* ========== STATE ============== */

    /// @notice The flag is the running status of NestQuery contract
    /// @dev The flag is in {0, 1, 2}
    /// @return The value of flag
    uint8   public flag;
    uint248 private _reserved;

    // flag == 0: the contract needs initialization
    // flag == 1: the contract is active after initialization
    // flag == 2: the contract is shutdown, user interfaces like query() are closed,
    //              while the governor has privileges to rescue
    uint8  constant QUERY_FLAG_UNINITIALIZED = 0;
    uint8  constant QUERY_FLAG_ACTIVE        = 1;
    uint8  constant QUERY_FLAG_PAUSED        = 2;

    struct Client {
        uint64 startTime;
        uint64 endTime;  // endTime==0 for non-monthly clients
        uint32 fee;
        uint32 typ;     // =1: PPQ | =2: PPM (forbidden for the moment)
        uint64 _reserved;
    }

    /// @dev Here we only support pay-per-query clients. 
    ///     The other type (pay-per-month) isn't supported currently.
    uint32 constant CLIENT_TYPE_PAY_PER_QUERY = 1;
    // uint32 constant CLIENT_TYPE_PAY_PER_MONTH = 2;

    mapping(address => uint256) public clientList;
    mapping(address => address) public clientOp;

    /* ========== PARAMETERS ============== */

    /// @dev The four paramters are encoded into a uin256 slot to save GAS. Currently only four
    ///        uint32 pieces are used, leaving sufficient spaces for later upgrading.
    struct Params {
        uint32 singleFeeEthTWei;            // Twei = 1e12
        uint32 activationTime;              // second
        uint32 activationFeeNestNum;        // 1 NEST = 1e18
        uint32 _reserved2;
    }

    uint256 private paramsEncoded;

    /// @dev The default values of parameters. They shall be setup via `setParams()` before 
    ///     the contract starts to rotates.
    uint32  constant CLIENT_QUERY_FEE_ETH_TWEI = (0.01 ether) / 1e12;
    uint32  constant CLIENT_ACTIVATION_NEST_AMOUNT = 0;
    uint32  constant CLIENT_MONTHLY_FEE_NEST_AMOUNT = 0;
    uint32  constant CLIENT_ACTIVATION_DURATION_SECOND = 10;

    /* ========== ADDRESSES ============== */

    /// @dev The contract variables for other contracts' addresses, loaded from NestPool
    address    private C_NestToken;
    address    private C_NestMining;
    address    private C_NestPool;
    address    private C_NestStaking;
    address    private C_NestDAO;

    /// @dev The governor's address, which is loaded from NestPool.
    address public governance;

    /* ========== CONSTRUCTOR ============== */

    receive() external payable { }

    // NOTE: to support open-zeppelin/upgrades, leave it blank
    constructor() public { }

    /// @dev It is supposedly called by the proxy (open-zeppelin/upgrades), only ONCE!
    function initialize(address NestPool) external 
    { 
        require(flag == QUERY_FLAG_UNINITIALIZED, "Nest:Qury:!flag");
        governance = address(msg.sender); 
        C_NestPool = NestPool;
        uint32 _actFee = CLIENT_ACTIVATION_NEST_AMOUNT;
        uint32 _singleFee = CLIENT_QUERY_FEE_ETH_TWEI;
        uint32 _actTime = CLIENT_ACTIVATION_DURATION_SECOND;
        paramsEncoded = encode_4x32_256(_singleFee, _actTime, _actFee, 0);
        flag = QUERY_FLAG_ACTIVE;
    }

    /* ========== MODIFIERS ========== */

    modifier whenActive() 
    {
        require(flag == QUERY_FLAG_ACTIVE, "Nest:Qury:!flag");
        _;
    }

    modifier onlyGovernance() 
    {
        require(msg.sender == governance, "Nest:Qury:!governance");
        _;
    }

    modifier onlyGovOrBy(address _account)
    {
        if (msg.sender != governance) { 
            require(msg.sender == _account,
                "Nest:Qury:!Auth");
        }
        _;
    }
    
    /*
    modifier onlyBy(address _contract)
    {
        require(msg.sender == _contract, "Nest:Qury:!Auth");
        _;
    }*/

    modifier noContract() 
    {
        require(address(msg.sender) == address(tx.origin), "Nest:Qury:BAN(contract)");
        _;
    }

     /* ========== GOVERNANCE ========== */

    /// @dev To ensure that all of governance-addresses be consist with each other, every contract
    ///        besides NestPool must load newest `governance` from NestPool.
    function loadGovernance() override external 
    { 
        governance = INestPool(C_NestPool).governance();
    }

    /// @notice Setup the parameters for queryings, one price for all token
    /// @dev    Parameters can be reset by set time to zero
    function setParams(uint256 single, uint32 time, uint256 nestAmount) 
        public 
        onlyGovernance
    {
        (uint32 _singleFee, uint32 _time, uint32 _actFee, uint32 _res) =  decode_4x32_256(paramsEncoded);

        _singleFee = uint32(single);
        _time = uint32(time);
        _actFee = uint32(nestAmount / 1e18);
    
        uint256 oldParamsEncoded = paramsEncoded;

        paramsEncoded = encode_4x32_256(_singleFee, _time, _actFee, _res);

        emit ParamsSetup(address(msg.sender), oldParamsEncoded, paramsEncoded);
    }

    function params() external view 
        returns(uint256 single, uint64 leadTime, uint256 nestAmount) 
    {
        (uint32 _singleFee, uint32 _time, uint32 _actFee, uint32 _res) =  decode_4x32_256(paramsEncoded);
        single = uint256(_singleFee).mul(1e12);
        leadTime = uint64(_time);
        nestAmount = uint256(_actFee).mul(1e18);

    }

    function loadContracts() override external onlyGovOrBy(C_NestPool)
    {
        C_NestToken = INestPool(C_NestPool).addrOfNestToken();
        C_NestMining = INestPool(C_NestPool).addrOfNestMining();
        C_NestStaking = INestPool(C_NestPool).addrOfNestStaking();
        C_NestDAO = INestPool(C_NestPool).addrOfNestDAO();
    }

    /// @dev Remove a client if something goes wrong
    /// @param defi The address of a client (defi DApp)
    function remove(address defi) 
        external 
        onlyGovernance
    {
        clientList[defi] = encodeClient(0, 0, 0, 0);
        clientOp[defi] = address(0);
    }

    // /// @dev  The balance of NEST
    // /// @return  The amount of NEST tokens for this contract
    // function balanceNest() override external view returns (uint256) 
    // {
    //     return ERC20(C_NestToken).balanceOf(address(this));
    // }

    // /// @dev  The balance of NEST
    // /// @return  The amount of ethers withheld by this contract
    // function balanceEth() override external view returns (uint256) 
    // {
    //     return address(this).balance;
    // }

    /* ========== EMERGENCY ========== */

    /// @dev Stop service for emergency
    function pause() external onlyGovernance
    {
        require(flag == QUERY_FLAG_ACTIVE, "Nest:Qury:!flag");

        flag = QUERY_FLAG_PAUSED;
        emit FlagSet(address(msg.sender), uint256(QUERY_FLAG_PAUSED));
    }

    /// @dev Resume service 
    function resume() external onlyGovernance
    {
        require(flag == QUERY_FLAG_PAUSED, "Nest:Qury:!flag");

        flag = QUERY_FLAG_ACTIVE;
        emit FlagSet(address(msg.sender), uint256(QUERY_FLAG_ACTIVE));
    }

    /* ========== CLIENT ========== */

    /// @notice Activate a pay-per-query defi client with NEST tokens
    /// @dev No contract is allowed to call it
    /// @param defi The addres of client (DeFi DApp)
    function activate(address defi) 
        override external noContract whenActive
    {
        if (defi == address(0)) {
            defi = address(msg.sender);
        }
        Client memory _c = decodeClient(clientList[defi]);
        require (_c.typ == 0, "Nest:Qury:EX(client)");
        (, uint32 _actTime, uint256 _actFee, ) = decode_4x32_256(paramsEncoded);          
        uint256 _nestFee = _actFee.mul(1e18);
        uint256 _start = uint64(block.timestamp.add(_actTime));
        uint256 _end = 0;
        uint256 _mfee = 0;
        clientList[defi] = encodeClient(uint64(_start), uint64(_end), uint32(_mfee), 0x1);
        clientOp[defi] = address(msg.sender);
        emit ClientActivated(defi, _start, _end);
        require(ERC20(C_NestToken).transferFrom(
            address(msg.sender), 
            address(C_NestDAO), 
            _nestFee), "Nest:Qury:!transfer");
    }

    /// @notice Deactivate a pay-per-query defi client
    /// @param defi The address of a client (DeFi DApp)
    function deactivate(address defi) 
        override 
        external 
        whenActive
    {
        if (defi == address(0)) {
            defi = address(msg.sender);
        }
        require(address(msg.sender) == clientOp[defi], "Nest:Qury:!Op");
        clientList[defi] = encodeClient(0, 0, 0, 0);
        clientOp[defi] = address(0);
    }

    /// @notice Query for PPQ (pay-per-query) clients
    /// @dev Consider that if a user call a DeFi that queries NestQuery, DeFi should
    ///     pass the user's wallet address to query() as `payback`.
    /// @param token The address of token contract
    /// @param payback The address of change
    function query(address token, address payback) 
        override 
        public 
        payable 
        whenActive
        nonReentrant
        returns (uint256, uint256, uint256) 
    {
        // check parameters
        Client memory c = decodeClient(clientList[address(msg.sender)]);
        require(c.typ == CLIENT_TYPE_PAY_PER_QUERY, "Nest:Qury:=!(client.typ)");
        require(c.startTime != 0 && uint256(c.startTime) < block.timestamp 
            && uint256(c.endTime) == 0, "Nest:Qury:!(client.time)");

        // lookup the latest effective price
        (uint256 ethAmount, uint256 tokenAmount, uint256 bn) = INestMining(C_NestMining).latestPriceOf(token);
        (uint256 _single, , , ) = decode_4x32_256(paramsEncoded);  

        {
            address _ntoken = INestPool(C_NestPool).getNTokenFromToken(token); 
            uint256 _ethFee = _single.mul(1e12);   // NOTE: the unit of _single is TWei
            INestDAO(C_NestDAO).addETHReward{value:_ethFee}(address(_ntoken));

            // return change
            if (payback != address(0) && msg.value > _ethFee) {
                TransferHelper.safeTransferETH(payback, msg.value.sub(_ethFee));
            }
        }
    
        emit PriceQueried(address(msg.sender), token, ethAmount, tokenAmount, bn);
        return (ethAmount, tokenAmount, uint256(bn));
    }

    /// @notice Query for PPQ (pay-per-query) clients
    /// @param token The address of token contract
    /// @param payback The address of change
    /// @return ethAmount The amount of ETH in pair (ETH, TOKEN)
    /// @return tokenAmount The amount of TOKEN in pair (ETH, TOKEN)
    /// @return avgPrice The average of last 50 prices 
    /// @return vola The volatility of prices 
    /// @return bn The block number when (ETH, TOKEN) takes into effective
    function queryPriceAvgVola(address token, address payback)
        override 
        external 
        payable 
        whenActive
        nonReentrant
        returns (uint256 ethAmount, uint256 tokenAmount, uint128 avgPrice, int128 vola, uint256 bn) 
    {
        // check parameters
        Client memory c = decodeClient(clientList[address(msg.sender)]);
        require (c.typ == CLIENT_TYPE_PAY_PER_QUERY, "Nest:Qury:=!(client.typ)");
        require(c.startTime != 0 && uint256(c.startTime) < block.timestamp 
            && uint256(c.endTime) == 0, "Nest:Qury:!(client.time)");

        (ethAmount, tokenAmount, bn) = INestMining(C_NestMining).latestPriceOf(token);
        (, avgPrice, vola,) = INestMining(C_NestMining).priceAvgAndSigmaOf(token);

        {
            (uint256 _single, , , ) = decode_4x32_256(paramsEncoded);  
            address _ntoken = INestPool(C_NestPool).getNTokenFromToken(token); 
            uint256 _ethFee = _single.mul(1e12);   // NOTE: the unit of _single is TWei
            INestDAO(C_NestDAO).addETHReward{value:_ethFee}(address(_ntoken));

            // charge back
            if (payback != address(0) && msg.value > _ethFee) {
                TransferHelper.safeTransferETH(payback, msg.value.sub(_ethFee));
            }
        }
        emit PriceAvgVolaQueried(address(msg.sender), token, bn, avgPrice, vola);

    }
    
    /// @notice The main function called by DeFi clients, compatible to Nest Protocol v3.0 
    /// @dev  The payback address is ZERO, so the changes are kept in this contract
    ///         The ABI keeps consist with Nest v3.0
    /// @param tokenAddress The address of token contract address
    /// @return ethAmount The amount of ETH in price pair (ETH, ERC20)
    /// @return erc20Amount The amount of ERC20 in price pair (ETH, ERC20)
    /// @return blockNum The block.number where the price is being in effect
    function updateAndCheckPriceNow(
            address tokenAddress
        ) 
        override
        public 
        payable 
        whenActive
        returns(uint256 ethAmount, uint256 erc20Amount, uint256 blockNum) 
    {
        return query(tokenAddress, address(msg.sender));
    }

    /// @notice A non-free function for querying price 
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @param payback The address for change
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function queryPriceList(address token, uint8 num, address payback) 
        override public payable 
        whenActive
        returns (uint128[] memory) 
    {
        // check client 
        Client memory c = decodeClient(clientList[address(msg.sender)]);
        require(c.typ == CLIENT_TYPE_PAY_PER_QUERY, "Nest:Qury:=!(client.typ)");
        require(c.startTime != 0 && uint256(c.startTime) < block.timestamp 
            && uint256(c.endTime) == 0, "Nest:Qury:!(client.time)");

        // retrieve the historical price list
        (uint128[] memory data, uint256 bn) = INestMining(C_NestMining).priceListOfToken(token, num);
        // require(miner != address(0x0), "miner null");

        // get the associated NTOKEN with token
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(token); 

        // calculate the fee rate 
        (uint256 _single, , , ) = decode_4x32_256(paramsEncoded);  
        uint256 _ethFee = _single.mul(1e12);  // NOTE: the unit of _single is TWei

        // transfer fee into NestDAO
        INestDAO(C_NestDAO).addETHReward{value:_ethFee}(address(_ntoken));

        // pay back the change
        if (payback != address(0) && msg.value > _ethFee) {
                TransferHelper.safeTransferETH(payback, msg.value.sub(_ethFee));
        }

        // notify client 
        emit PriceListQueried(address(msg.sender), token, bn, num);
        
        return data;
    }

    /// @notice A view function returning the historical price list from the current block
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function priceList(address token, uint8 num) 
        override public view 
        whenActive
        noContract
        returns (uint128[] memory) 
    {

        // retrieve the historical price list
        (uint128[] memory data, uint256 bn) = INestMining(C_NestMining).priceListOfToken(token, num);

        // // get the associated NTOKEN with token
        // address _ntoken = INestPool(C_NestPool).getNTokenFromToken(token); 
        
        return data;
    }
    
    function latestPrice(address token)
        override 
        public 
        view 
        whenActive
        noContract
        returns (uint256 ethAmount, uint256 tokenAmount, uint128 avgPrice, int128 vola, uint256 bn) 
    {
        (ethAmount, tokenAmount, bn) = INestMining(C_NestMining).latestPriceOf(token);
        (, avgPrice, vola,) = INestMining(C_NestMining).priceAvgAndSigmaOf(token);

    }
  
    /* ========== INTER-CALLS ========== */

    // /// @dev Withdraw NEST only when emergency or governance
    // /// @param to  The address of recipient
    // /// @param amount  The amount of NEST tokens 
    // function withdrawNest(uint256 amount) 
    //     override external onlyBy(C_NestDAO)
    // {
    //     ERC20(C_NestToken).transfer(address(msg.sender), amount);
    // }

    // /// @dev Withdraw ethers only when emergency or governance
    // /// @param to  The address of recipient
    // /// @param amount  The amount of ethers 
    // function withdrawEth(uint256 amount) 
    //     override external onlyBy(C_NestDAO)
    // {
    //    TransferHelper.safeTransferETH(address(msg.sender), amount);
    // }

     /* ========== HELPERS ========== */

    /// @dev For saving GAS
    function encode_4x32_256(uint32 p1, uint32 p2, uint32 p3, uint32 p4) 
        internal 
        pure 
        returns (uint256 enc) 
    {
        assembly {
            mstore(0x20, p1)
            mstore(0x18, p2)
            mstore(0x10, p3)
            mstore(0x8, p4)
            enc := mload(0x20)
        }
    }

    /// @dev For saving GAS
    function decode_4x32_256(uint256 enc) 
        internal 
        pure 
        returns (uint32 p1, uint32 p2, uint32 p3, uint32 p4) 
    {
        assembly {
            p1 := enc
            mstore(0x18, enc)
            p4 := mload(0)
            mstore(0x10, enc)
            p3 := mload(0)
            mstore(0x8, enc)
            p2 := mload(0)
        }
    }

    /// @dev For saving GAS
    function encodeClient(uint64 _start, uint64 _end, uint32 _fee, uint32 _typ) 
        internal pure returns (uint256 enc) 
    {
        assembly {
            let y := 0
            mstore(0x20, 0)
            mstore(0x18, _typ)
            mstore(0x14, _fee)
            mstore(0x10, _end)
            mstore(0x8, _start)
            enc := mload(0x20)
        }
    }

    
    /// @dev For saving GAS
    function decodeClient(uint256 enc) 
        internal pure returns (Client memory client) 
    {
        uint32 _typ;
        uint32 _fee;
        uint64 _start;
        uint64 _end;
        assembly {
            mstore(0x18, enc)
            _start := mload(0)
            mstore(0x10, enc)
            _end := mload(0)
            mstore(0xc, enc)
            _fee := mload(0)
            mstore(0x8, enc)
            _typ := mload(0)
        }
        client = Client(_start, _end, _fee, _typ, 0);
    }
}


