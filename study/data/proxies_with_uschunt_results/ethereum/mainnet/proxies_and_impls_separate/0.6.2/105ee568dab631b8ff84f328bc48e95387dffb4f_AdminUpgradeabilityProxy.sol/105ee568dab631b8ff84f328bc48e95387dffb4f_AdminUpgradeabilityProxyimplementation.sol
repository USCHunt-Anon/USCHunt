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

//import"./lib/SafeMath.sol";
//import"./lib/TransferHelper.sol";
//import"./lib/ReentrancyGuard.sol";


//import"./iface/INestMining.sol";
//import"./iface/INToken.sol";
//import"./iface/INestPool.sol";
//import"./iface/INestDAO.sol";
//import"./iface/INestStaking.sol";
//import"./iface/INestQuery.sol";

// //import"hardhat/console.sol";

/// @dev The contract is for redeeming nest token and getting ETH in return
contract NestDAO is INestDAO, ReentrancyGuard {

    using SafeMath for uint256;

    /* ========== STATE ============== */

    uint8 public flag; 

    /// @dev the block height where DAO was started
    uint32  public startedBlock;
    uint32  public lastCollectingBlock;
    uint184 private _reserved;

    uint8 constant DAO_FLAG_UNINITIALIZED    = 0;
    uint8 constant DAO_FLAG_INITIALIZED      = 1;
    uint8 constant DAO_FLAG_ACTIVE           = 2;
    uint8 constant DAO_FLAG_NO_STAKING       = 3;
    uint8 constant DAO_FLAG_PAUSED           = 4;
    uint8 constant DAO_FLAG_SHUTDOWN         = 127;

    struct Ledger {
        uint128 rewardedAmount;
        uint128 redeemedAmount;
        uint128 quotaAmount;
        uint32  lastBlock;
        uint96  _reserved;
    }

    /// @dev Mapping from ntoken => amount (of ntokens owned by DAO)
    mapping(address => Ledger) public ntokenLedger;

    /// @dev Mapping from ntoken => amount (of ethers owned by DAO)
    mapping(address => uint256) public ethLedger;

    /* ========== PARAMETERS ============== */

    uint256 public ntokenRepurchaseThreshold;
    uint256 public collectInterval;

    uint256 constant DAO_REPURCHASE_PRICE_DEVIATION = 5;  // price deviation < 5% 
    uint256 constant DAO_REPURCHASE_NTOKEN_TOTALSUPPLY = 5_000_000;  // total supply > 5 million 

    uint256 constant DAO_COLLECT_INTERVAL = 5_760;  // 24 hour * 60 min * 4 block/min ~= 1 day

    uint256 constant _ethFee = 0.01 ether;

    /* ========== ADDRESSES ============== */

    address public governance;

    address private C_NestPool;
    address private C_NestToken;
    address private C_NestMining;
    address private C_NestStaking;
    address private C_NestQuery;

    /* ========== CONSTRUCTOR ========== */

    receive() external payable {}

    // NOTE: to support open-zeppelin/upgrades, leave it blank
    constructor() public { }

    /// @dev It is called by the proxy (open-zeppelin/upgrades), only ONCE!
    function initialize(address NestPool) external 
    {
        require(flag == DAO_FLAG_UNINITIALIZED, "Nest:DAO:!flag");
        governance = msg.sender;
        flag = DAO_FLAG_INITIALIZED;
        C_NestPool = NestPool;
        ntokenRepurchaseThreshold = DAO_REPURCHASE_NTOKEN_TOTALSUPPLY;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyGovernance() 
    {
        require(msg.sender == governance, "Nest:DAO:!governance");
        _;
    }

    modifier onlyGovOrBy(address _contract) 
    {
        require(msg.sender == governance || msg.sender == _contract, "Nest:DAO:!sender");
        _;
    }

    modifier whenActive() 
    {
        require(flag == DAO_FLAG_ACTIVE, "Nest:DAO:!flag");
        _;
    }

    /* ========== GOVERNANCE ========== */

    /// @dev Ensure that all governance-addresses be consistent with each other
    function loadGovernance() override external 
    { 
        governance = INestPool(C_NestPool).governance();
    }

    /// @dev The function loads all nest-contracts, it is supposed to be called by NestPool
    function loadContracts() override external onlyGovOrBy(C_NestPool)
    {
        C_NestToken = INestPool(C_NestPool).addrOfNestToken();
        C_NestStaking = INestPool(C_NestPool).addrOfNestStaking();
        C_NestQuery = INestPool(C_NestPool).addrOfNestQuery();
        C_NestMining = INestPool(C_NestPool).addrOfNestMining();
    }

    function start() override external onlyGovernance
    {  
        require(flag == DAO_FLAG_INITIALIZED, "Nest:DAO:!flag");
        ERC20(C_NestToken).approve(C_NestStaking, uint(-1));
        startedBlock = uint32(block.number);
        lastCollectingBlock = uint32(block.number);
        flag = DAO_FLAG_ACTIVE;
        collectInterval = DAO_COLLECT_INTERVAL;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_ACTIVE));
    }

    /// @dev Stop service for emergency
    function pause() external onlyGovernance
    {
        require(flag == DAO_FLAG_ACTIVE, "Nest:DAO:!flag");
        flag = DAO_FLAG_PAUSED;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_PAUSED));
    }

    /// @dev Resume service 
    function resume() external onlyGovernance
    {
        require(flag == DAO_FLAG_ACTIVE || flag == DAO_FLAG_PAUSED, "Nest:DAO:!flag");
        flag = DAO_FLAG_ACTIVE;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_ACTIVE));
    }

    function setParams(uint256 _ntokenRepurchaseThreshold, uint256 _collectInterval) external onlyGovernance
    {
        emit ParamsSetup(address(msg.sender), ntokenRepurchaseThreshold, _ntokenRepurchaseThreshold);
        ntokenRepurchaseThreshold = _ntokenRepurchaseThreshold;
        emit ParamsSetup(address(msg.sender), collectInterval, _collectInterval);
        collectInterval = _collectInterval;
    }

    function totalETHRewards(address ntoken)
        external view returns (uint256) 
    {
       return  ethLedger[ntoken];
    }

    /// @notice Migrate ethers to a new NestDAO
    /// @param newDAO_ The address of the new contract
    /// @param ntokenL_ The list of ntokens whose ethers are going to be migrated
    function migrateTo(address newDAO_, address[] memory ntokenL_) external onlyGovernance
    {
        require(flag == DAO_FLAG_PAUSED, "Nest:DAO:!flag");
        uint256 _len = ntokenL_.length;
        for (uint256 i; i < _len; i++) {
            address _ntoken = ntokenL_[i];
            uint256 _blncs = ethLedger[_ntoken];

            INestDAO(newDAO_).addETHReward{value:_blncs}(_ntoken);
            
            ethLedger[_ntoken] = 0;

            uint256 _staked = INestStaking(C_NestStaking).stakedBalanceOf(_ntoken, address(this));
            if (_staked > 0) {
                INestStaking(C_NestStaking).unstake(_ntoken, _staked);
            }

            uint256 _ntokenAmount = ERC20(_ntoken).balanceOf(address(this));

            if (_ntokenAmount > 0) {
                ERC20(_ntoken).transfer(newDAO_, _ntokenAmount);

            }
        }
    }

    /// @dev The function shall be called when ethers are taken from Nestv3.0
    function initEthLedger(address ntoken, uint256 amount) 
        override external
        onlyGovernance 
    {
        require (flag == DAO_FLAG_INITIALIZED, "Nest:DAO:!flag");
        ethLedger[ntoken] = amount;

    }

    /* ========== MAIN ========== */

    /// @notice Pump eth rewards to NestDAO for repurchasing `ntoken`
    /// @param ntoken The address of ntoken in the ether Ledger
    function addETHReward(address ntoken) 
        override
        external
        payable
    {
        ethLedger[ntoken] = ethLedger[ntoken].add(msg.value);
    }

    /// @dev Called by NestMining
    function addNestReward(uint256 amount) 
        override 
        external 
        onlyGovOrBy(C_NestMining)
    {
        Ledger storage it = ntokenLedger[C_NestToken];
        it.rewardedAmount = uint128(uint256(it.rewardedAmount).add(amount));
    }

    /// @dev Collect ethers from NestPool
    function collectNestReward() public returns(uint256)
    {
        // withdraw NEST from NestPool (mined by miners)
        uint256 nestAmount = INestPool(C_NestPool).balanceOfTokenInPool(address(this), C_NestToken);
        if (nestAmount == 0) {
            return 0;
        }

        INestPool(C_NestPool).withdrawNest(address(this), nestAmount);

        return nestAmount;
    }


    /// @dev Collect ethers from NestStaking
    function collectETHReward(address ntoken) public returns (uint256)
    {
        // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        uint256 ntokenAmount = ERC20(ntoken).balanceOf(address(this));

        // if (ntokenAmount == 0) {
        //     return 0;
        // }
        // // stake new NEST/NTOKENs into StakingPool
        // INestStaking(C_NestStaking).stake(ntoken, ntokenAmount);

        if (ntokenAmount != 0) {
            // stake new NEST/NTOKENs into StakingPool
            INestStaking(C_NestStaking).stake(ntoken, ntokenAmount);
        }

        // claim rewards from StakingPool 
        uint256 _rewards = INestStaking(C_NestStaking).claim(ntoken);
        ethLedger[ntoken] = ethLedger[ntoken].add(_rewards);

        return _rewards;
    }

    function _collect(address ntoken) internal
    {
        if (block.number < uint256(lastCollectingBlock).add(collectInterval)) {
            return;
        }

        uint256 ethAmount = collectETHReward(ntoken);
        
        uint256 nestAmount = collectNestReward();
        
        lastCollectingBlock = uint32(block.number);
        emit AssetsCollected(address(msg.sender), ethAmount, nestAmount);
    }

    /// @dev Redeem ntokens for ethers
    function redeem(address ntoken, uint256 amount) 
        external payable nonReentrant whenActive
    {
        // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        require (msg.value >= _ethFee, "Nest:DAO:!ethFee");

        require(INToken(ntoken).totalSupply() >= ntokenRepurchaseThreshold, "Nest:DAO:!total");

        // check if there is sufficient ethers for repurchase
        uint256 bal = ethLedger[ntoken];
        require(bal > 0, "Nest:DAO:!bal");

        // check the repurchasing quota
        uint256 quota = quotaOf(ntoken);

        // check if the price is steady
        uint256 price;
        bool isDeviated;
        
        
        {
            (uint256 ethAmount, uint256 tokenAmount,) = INestMining(C_NestMining).latestPriceOf(ntoken);
            (, uint256 avg, ,) = INestMining(C_NestMining).priceAvgAndSigmaOf(ntoken);
            price = tokenAmount.mul(1e18).div(ethAmount);

            uint256 diff = price > avg? (price - avg) : (avg - price);
            isDeviated = (diff.mul(100) < avg.mul(DAO_REPURCHASE_PRICE_DEVIATION))? false : true;

            if(msg.value > _ethFee){
                TransferHelper.safeTransferETH(msg.sender, msg.value.sub(_ethFee));
            }
            this.addETHReward{value:_ethFee}(address(ntoken));

        }

        require(isDeviated == false, "Nest:DAO:!price");

        // check if there is sufficient quota for repurchase
        require (amount <= quota, "Nest:DAO:!quota");
        // amount.mul(1e18).div(price) < bal
        require (amount.mul(1e18) <= bal.mul(price), "Nest:DAO:!bal2");

        // update the ledger
        Ledger memory it = ntokenLedger[ntoken];

        it.redeemedAmount = uint128(amount.add(it.redeemedAmount));
        it.quotaAmount = uint128(quota.sub(amount));
        it.lastBlock = uint32(block.number);
        ntokenLedger[ntoken] = it;

        // transactions
        ethLedger[ntoken] = ethLedger[ntoken].sub(amount.mul(1e18).div(price));

        ERC20(ntoken).transferFrom(address(msg.sender), address(this), amount);
        TransferHelper.safeTransferETH(msg.sender, amount.mul(1e18).div(price));

        _collect(ntoken); 
    }

    // function _price(address ntoken) internal view 
    //     returns (uint256 price, uint256 avg, bool isDeviated)
    // {
    //     (price, avg, , ) = 
    //         INestQuery(C_NestQuery).queryPriceAvgVola(ntoken, );
    //     uint256 diff = price > avg? (price - avg) : (avg - price);
    //     isDeviated = (diff.mul(100) < avg.mul(DAO_REPURCHASE_PRICE_DEVIATION))? false : true;
    // }

    function _quota(address ntoken) internal view returns (uint256 quota) 
    {
        if (INToken(ntoken).totalSupply() < ntokenRepurchaseThreshold) {
            return 0;
        }

        //  calculate the accumulated amount of NEST/NTOKEN available to repurchasing
        Ledger memory it = ntokenLedger[ntoken];
        uint256 _acc;
        uint256 n;
        if(ntoken == C_NestToken){
             n = 1000;
            uint256 intv = (it.lastBlock == 0) ? 
                (block.number).sub(startedBlock) : (block.number).sub(uint256(it.lastBlock));
            _acc = (n * intv > 300_000)? 300_000 : (n * intv);
        }else{
            n = 10;
            uint256 intv = (it.lastBlock == 0) ? 
                (block.number).sub(startedBlock) : (block.number).sub(uint256(it.lastBlock));
            _acc = (n * intv > 3000)? 3000 : (n * intv);
        }

        uint256 total;
         total = _acc.mul(1e18).add(it.quotaAmount);
        if(ntoken == C_NestToken){
            if(total > uint256(300_000).mul(1e18)){
                quota = uint256(300_000).mul(1e18);
            }else{
                quota = total;
            }   
        }else{
            if(total > uint256(3000).mul(1e18)){
                quota = uint256(3000).mul(1e18);
            }else{
                quota = total;
            }   
        }
        
    }

    /* ========== VIEWS ========== */

    function quotaOf(address ntoken) public view returns (uint256 quota) 
    {
       // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        return _quota(ntoken);
    }
}

