// : BUSL-1.1
pragma solidity 0.7.6;


abstract contract LPoolStorage {

    //Guard variable for re-entrancy checks
    bool internal _notEntered;

    /**
     * EIP-20 token name for this token
     */
    string public name;

    /**
     * EIP-20 token symbol for this token
     */
    string public symbol;

    /**
     * EIP-20 token decimals for this token
     */
    uint8 public decimals;

    /**
    * Total number of tokens in circulation
    */
    uint public totalSupply;


    //Official record of token balances for each account
    mapping(address => uint) internal accountTokens;

    //Approved token transfer amounts on behalf of others
    mapping(address => mapping(address => uint)) internal transferAllowances;


    //Maximum borrow rate that can ever be applied (.0005% / block)
    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    /**
    * Maximum fraction of borrower cap(80%)
    */
    uint public  borrowCapFactorMantissa;
    /**
     * Contract which oversees inter-lToken operations
     */
    address public controller;


    // Initial exchange rate used when minting the first lTokens (used when totalSupply = 0)
    uint internal initialExchangeRateMantissa;

    /**
     * Block number that interest was last accrued at
     */
    uint public accrualBlockNumber;

    /**
     * Accumulator of the total earned interest rate since the opening of the market
     */
    uint public borrowIndex;

    /**
     * Total amount of outstanding borrows of the underlying in this market
     */
    uint public totalBorrows;

    //useless
    uint internal totalCash;

    /**
    * @notice Fraction of interest currently set aside for reserves 20%
    */
    uint public reserveFactorMantissa;

    uint public totalReserves;

    address public underlying;

    bool public isWethPool;

    /**
     * Container for borrow balance information
     * principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;

    // Mapping of account addresses to outstanding borrow balances

    mapping(address => BorrowSnapshot) internal accountBorrows;




    /*** Token Events ***/

    /**
    * Event emitted when tokens are minted
    */
    event Mint(address minter, uint mintAmount, uint mintTokens);

    /**
     * EIP20 Transfer event
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * EIP20 Approval event
     */
    event Approval(address indexed owner, address indexed spender, uint amount);

    /*** Market Events ***/

    /**
     * Event emitted when interest is accrued
     */
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    /**
     * Event emitted when tokens are redeemed
     */
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    /**
     * Event emitted when underlying is borrowed
     */
    event Borrow(address borrower, address payee, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    /**
     * Event emitted when a borrow is repaid
     */
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint badDebtsAmount, uint accountBorrows, uint totalBorrows);

    /*** Admin Events ***/

    /**
     * Event emitted when controller is changed
     */
    event NewController(address oldController, address newController);

    /**
     * Event emitted when interestParam is changed
     */
    event NewInterestParam(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

    /**
    * @notice Event emitted when the reserve factor is changed
    */
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    /**
     * @notice Event emitted when the reserves are added
     */
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    /**
     * @notice Event emitted when the reserves are reduced
     */
    event ReservesReduced(address to, uint reduceAmount, uint newTotalReserves);

    event NewBorrowCapFactorMantissa(uint oldBorrowCapFactorMantissa, uint newBorrowCapFactorMantissa);

}

abstract contract LPoolInterface is LPoolStorage {


    /*** User Interface ***/

    function transfer(address dst, uint amount) external virtual returns (bool);

    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);

    function approve(address spender, uint amount) external virtual returns (bool);

    function allowance(address owner, address spender) external virtual view returns (uint);

    function balanceOf(address owner) external virtual view returns (uint);

    function balanceOfUnderlying(address owner) external virtual returns (uint);

    /*** Lender & Borrower Functions ***/

    function mint(uint mintAmount) external virtual;

    function mintTo(address to, uint amount) external payable virtual;

    function mintEth() external payable virtual;

    function redeem(uint redeemTokens) external virtual;

    function redeemUnderlying(uint redeemAmount) external virtual;

    function borrowBehalf(address borrower, uint borrowAmount) external virtual;

    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external virtual;

    function availableForBorrow() external view virtual returns (uint);

    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint);

    function borrowRatePerBlock() external virtual view returns (uint);

    function supplyRatePerBlock() external virtual view returns (uint);

    function totalBorrowsCurrent() external virtual view returns (uint);

    function borrowBalanceCurrent(address account) external virtual view returns (uint);

    function borrowBalanceStored(address account) external virtual view returns (uint);

    function exchangeRateCurrent() public virtual returns (uint);

    function exchangeRateStored() public virtual view returns (uint);

    function getCash() external view virtual returns (uint);

    function accrueInterest() public virtual;

    /*** Admin Functions ***/

    function setController(address newController) external virtual;

    function setBorrowCapFactorMantissa(uint newBorrowCapFactorMantissa) external virtual;

    function setInterestParams(uint baseRatePerBlock_, uint multiplierPerBlock_, uint jumpMultiplierPerBlock_, uint kink_) external virtual;

    function setReserveFactor(uint newReserveFactorMantissa) external virtual;

    function addReserves(uint addAmount) external payable virtual;

    function reduceReserves(address payable to, uint reduceAmount) external virtual;

}


// : BUSL-1.1
pragma solidity 0.7.6;


//import"../Adminable.sol";
//import"../DelegatorInterface.sol";


/**
 * @title Compound's LPoolDelegator Contract
 * LTokens which wrap an EIP-20 underlying and delegate to an implementation
 * @author Compound
 */
contract LPoolDelegator is DelegatorInterface, Adminable {


    constructor() {
        admin = msg.sender;
    }
    function initialize(address underlying_,
        bool isWethPool_,
        address contoller_,
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink_,

        uint initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address payable admin_,
        address implementation_) external onlyAdmin {
        require(implementation == address(0), "initialize once");
        // Creator of the contract is admin during initialization
        // First delegate gets to initialize the delegator (i.e. storage contract)
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,bool,address,uint256,uint256,uint256,uint256,uint256,string,string,uint8)",
            underlying_,
            isWethPool_,
            contoller_,
            baseRatePerYear,
            multiplierPerYear,
            jumpMultiplierPerYear,
            kink_,
            initialExchangeRateMantissa_,
            name_,
            symbol_,
            decimals_));

        implementation = implementation_;

        // Set the proper admin now that initialization is done
        admin = admin_;
    }
    /**
     * Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function setImplementation(address implementation_) public override onlyAdmin {
        address oldImplementation = implementation;
        implementation = implementation_;
        emit NewImplementation(oldImplementation, implementation);
    }


}


// : BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

//import"@openzeppelin/contracts/math/SafeMath.sol";

library Utils{
    using SafeMath for uint;

    uint constant feeRatePrecision = 10**6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        uint denominator = feeRatePrecision.sub(feeRate);
        uint numerator = amount.mul(feeRatePrecision).add(denominator).sub(1);
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        return amount.mul(feeRatePrecision.sub(feeRate)) / feeRatePrecision;
    }

    function minOf(uint a, uint b) internal pure returns (uint){
        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint){
        return a > b ? a : b;
    }
}

// : BUSL-1.1
pragma solidity 0.7.6;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
// //import"@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
 library TransferHelper{
    // using SafeMath for uint;

    function safeTransfer(IERC20 _token, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            // _token.transferFrom(_from, _to, _amount);
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TFF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
        bool success;
        if (_token.allowance(address(this), _spender) != 0){
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");

        return _token.allowance(address(this), _spender);
    }

    // function safeIncreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.add(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }

    // function safeDecreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.sub(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }
}

// : BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

/// @dev DexDataFormat addPair = byte(dexID) + bytes3(feeRate) + bytes(arrayLength) + byte3[arrayLength](trasferFeeRate Lpool <-> openlev) 
/// + byte3[arrayLength](transferFeeRate openLev -> Dex) + byte3[arrayLength](Dex -> transferFeeRate openLev)
/// exp: 0x0100000002011170000000011170000000011170000000
/// DexDataFormat dexdata = byte(dexID）+ bytes3(feeRate) + byte(arrayLength) + path
/// uniV2Path = bytes20[arraylength](address)
/// uniV3Path = bytes20(address)+ bytes20[arraylength-1](address + fee)
library DexData {
    // in byte
    uint constant DEX_INDEX = 0;
    uint constant FEE_INDEX = 1;
    uint constant ARRYLENTH_INDEX = 4;
    uint constant TRANSFERFEE_INDEX = 5;
    uint constant PATH_INDEX = 5;
    uint constant FEE_SIZE = 3;
    uint constant ADDRESS_SIZE = 20;
    uint constant NEXT_OFFSET = ADDRESS_SIZE + FEE_SIZE;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;
    uint8 constant DEX_PANCAKEV1 = 11;
    uint8 constant DEX_BABY = 12;

    struct V3PoolData {
        address tokenA;
        address tokenB;
        uint24 fee;
    }

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= FEE_INDEX, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {
        require(data.length >= ARRYLENTH_INDEX, "DexData: toFee wrong data format");
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, FEE_INDEX)))
        }
        return uint24(temp >> (256 - (ARRYLENTH_INDEX - FEE_INDEX) * 8));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {
        require (data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)){
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, DEX_INDEX)))
            }
            return uint32(temp >> (256 - ((FEE_SIZE + FEE_INDEX) * 8)));
        }
    }

    function toArrayLength(bytes memory data) internal pure returns(uint8 length){
        require(data.length >= TRANSFERFEE_INDEX, "DexData: toArrayLength wrong data format");

        assembly {
            length := byte(0, mload(add(data, add(0x20, ARRYLENTH_INDEX))))
        }
    }

    // only for add pair
    function toTransferFeeRates(bytes memory data) internal pure returns (uint24[] memory transferFeeRates){
        uint8 length = toArrayLength(data) * 3;
        uint start = TRANSFERFEE_INDEX;

        transferFeeRates = new uint24[](length);
        for (uint i = 0; i < length; i++){
            // use default value
            if (data.length <= start){
                transferFeeRates[i] = 0;
                continue;
            }

            // use input value
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, start)))
            }

            transferFeeRates[i] = uint24(temp >> (256 - FEE_SIZE * 8));
            start += FEE_SIZE;
        }
    }

    function toUniV2Path(bytes memory data) internal pure returns (address[] memory path) {
        uint8 length = toArrayLength(data);
        uint end =  PATH_INDEX + ADDRESS_SIZE * length;
        require(data.length >= end, "DexData: toUniV2Path wrong data format");

        uint start = PATH_INDEX;
        path = new address[](length);
        for (uint i = 0; i < length; i++) {
            uint startIndex = start + ADDRESS_SIZE * i;
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, startIndex)))
            }

            path[i] = address(temp >> (256 - ADDRESS_SIZE * 8));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns(bool){
        return toDex(data) != DEX_UNIV3;
    }

    function toUniV3Path(bytes memory data) internal pure returns (V3PoolData[] memory path) {
        uint8 length = toArrayLength(data);
        uint end = PATH_INDEX + (FEE_SIZE  + ADDRESS_SIZE) * length - FEE_SIZE;
        require(data.length >= end, "DexData: toUniV3Path wrong data format");
        require(length > 1, "DexData: toUniV3Path path too short");

        uint temp;
        uint index = PATH_INDEX;
        path = new V3PoolData[](length - 1);

        for (uint i = 0; i < length - 1; i++) {
            V3PoolData memory pool;

            // get tokenA
            if (i == 0) {
                assembly {
                    temp := mload(add(data, add(0x20, index)))
                }
                pool.tokenA = address(temp >> (256 - ADDRESS_SIZE * 8));
                index += ADDRESS_SIZE;
            }else{
                pool.tokenA = path[i-1].tokenB;
                index += NEXT_OFFSET;
            }

            // get TokenB
            assembly {
                temp := mload(add(data, add(0x20, index)))
            }

            uint tokenBAndFee = temp >> (256 - NEXT_OFFSET * 8);
            pool.tokenB = address(tokenBAndFee >> (FEE_SIZE * 8));
            pool.fee = uint24(tokenBAndFee - (tokenBAndFee << (FEE_SIZE * 8)));

            path[i] = pool;
        }
    }
}

// : BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface DexAggregatorInterface {

    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external returns (uint sellAmount);

    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view returns (uint);

    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view returns (uint);

    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);

    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view returns (uint256 price, uint8 decimals, uint256 timestamp);

    //cal current avg price and get history avg price
    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns(bool);

    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external;

    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external;
}


// : BUSL-1.1
pragma solidity 0.7.6;

//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
//import"./dex/DexAggregatorInterface.sol";


contract XOLEStorage {

    // EIP-20 token name for this token
    string public constant name = 'xOLE';

    // EIP-20 token symbol for this token
    string public constant symbol = 'xOLE';

    // EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    // Total number of tokens supply
    uint public totalSupply;

    // Total number of tokens locked
    uint public totalLocked;

    // Official record of token balances for each account
    mapping(address => uint) internal balances;

    mapping(address => LockedBalance) public locked;

    DexAggregatorInterface public dexAgg;

    IERC20 public oleToken;

    struct LockedBalance {
        uint256 amount;
        uint256 end;
    }

    uint constant oneWeekExtraRaise = 208;// 2.08% * 210 = 436% (4 years raise)

    int128 constant DEPOSIT_FOR_TYPE = 0;
    int128 constant CREATE_LOCK_TYPE = 1;
    int128 constant INCREASE_LOCK_AMOUNT = 2;
    int128 constant INCREASE_UNLOCK_TIME = 3;

    uint256 constant WEEK = 7 * 86400;  // all future times are rounded by week
    uint256 constant MAXTIME = 4 * 365 * 86400;  // 4 years
    uint256 constant MULTIPLIER = 10 ** 18;


    // dev team account
    address public dev;

    uint public devFund;

    uint public devFundRatio; // ex. 5000 => 50%

    // user => reward
    mapping(address => uint256) public rewards;

    // useless
    uint public totalStaked;

    // total to shared
    uint public totalRewarded;

    uint public withdrewReward;

    uint public lastUpdateTime;

    uint public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;


    // A record of each accounts delegate
    mapping(address => address) public delegates;

    // A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint votes;
    }

    mapping(uint256 => Checkpoint) public totalSupplyCheckpoints;

    uint256 public totalSupplyNumCheckpoints;

    // A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    // The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    // The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    // The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    // A record of states for signing / validating signatures
    mapping(address => uint) public nonces;

    // An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    // An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    event RewardAdded(address fromToken, uint convertAmount, uint reward);
    event RewardConvert(address fromToken, address toToken, uint convertAmount, uint returnAmount);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Deposit (
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int128 type_,
        uint256 ts
    );

    event Withdraw (
        address indexed provider,
        uint256 value,
        uint256 ts
    );

    event Supply (
        uint256 prevSupply,
        uint256 supply
    );

    event RewardPaid (
        address paidTo,
        uint256 amount
    );

    event FailedDelegateBySig(
        address indexed delegatee,
        uint indexed nonce, 
        uint expiry,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    );
}


interface XOLEInterface {

    function convertToSharingToken(uint amount, uint minBuyAmount, bytes memory data) external;

    function withdrawDevFund() external;

    function earned(address account) external view returns (uint);

    function withdrawReward() external;

    /*** Admin Functions ***/

    function setDevFundRatio(uint newRatio) external;

    function setDev(address newDev) external;

    function setDexAgg(DexAggregatorInterface newDexAgg) external;

    // xOLE functions

    function create_lock(uint256 _value, uint256 _unlock_time) external;

    function increase_amount(uint256 _value) external;

    function increase_unlock_time(uint256 _unlock_time) external;

    function withdraw() external;

    function balanceOf(address addr) external view returns (uint256);

}



// : BUSL-1.1
pragma solidity 0.7.6;

//import"./liquidity/LPoolInterface.sol";
//import"./lib/TransferHelper.sol";

library Types {
    using TransferHelper for IERC20;

    struct Market {// Market info
        LPoolInterface pool0;       // Lending Pool 0
        LPoolInterface pool1;       // Lending Pool 1
        address token0;              // Lending Token 0
        address token1;              // Lending Token 1
        uint16 marginLimit;         // Margin ratio limit for specific trading pair. Two decimal in percentage, ex. 15.32% => 1532
        uint16 feesRate;            // feesRate 30=>0.3%
        uint16 priceDiffientRatio;
        address priceUpdater;
        uint pool0Insurance;        // Insurance balance for token 0
        uint pool1Insurance;        // Insurance balance for token 1
        uint32[] dexs;
    }

    struct Trade {// Trade storage
        uint deposited;             // Balance of deposit token
        uint held;                  // Balance of held position
        bool depositToken;          // Indicate if the deposit token is token 0 or token 1
        uint128 lastBlockNum;       // Block number when the trade was touched last time, to prevent more than one operation within same block
    }

    struct MarketVars {// A variables holder for market info
        LPoolInterface buyPool;     // Lending pool address of the token to buy. It's a calculated field on open or close trade.
        LPoolInterface sellPool;    // Lending pool address of the token to sell. It's a calculated field on open or close trade.
        IERC20 buyToken;            // Token to buy
        IERC20 sellToken;           // Token to sell
        uint reserveBuyToken;
        uint reserveSellToken;
        uint buyPoolInsurance;      // Insurance balance of token to buy
        uint sellPoolInsurance;     // Insurance balance of token to sell
        uint16 marginLimit;         // Margin Ratio Limit for specific trading pair.
        uint16 priceDiffientRatio;
        uint32[] dexs;
    }

    struct TradeVars {// A variables holder for trade info
        uint depositValue;          // Deposit value
        IERC20 depositErc20;        // Deposit Token address
        uint fees;                  // Fees value
        uint depositAfterFees;      // Deposit minus fees
        uint tradeSize;             // Trade amount to be swap on DEX
        uint newHeld;               // Latest held position
        uint borrowValue;
        uint token0Price;
        uint32 dexDetail;
        uint totalHeld;
    }

    struct CloseTradeVars {// A variables holder for close trade info
        uint16 marketId;
        bool longToken;
        bool depositToken;
        uint closeRatio;          // Close ratio
        bool isPartialClose;        // Is partial close
        uint closeAmountAfterFees;  // Close amount sub Fees value
        uint borrowed;
        uint repayAmount;           // Repay to pool value
        uint depositDecrease;       // Deposit decrease
        uint depositReturn;         // Deposit actual returns
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint fees;                  // Fees value
        uint32 dexDetail;
    }


    struct LiquidateVars {// A variable holder for liquidation process
        uint16 marketId;
        bool longToken;
        uint borrowed;              // Total borrowed balance of trade
        uint fees;                  // Fees for liquidation process
        uint penalty;               // Penalty
        uint remainAmountAfterFees;   // Held-fees-penalty
        bool isSellAllHeld;         // Is need sell all held
        uint depositDecrease;       // Deposit decrease
        uint depositReturn;         // Deposit actual returns
        uint sellAmount;
        uint receiveAmount;
        uint token0Price;
        uint outstandingAmount;
        uint finalRepayAmount;
        uint32 dexDetail;
    }

    struct MarginRatioVars {
        address heldToken;
        address sellToken;
        address owner;
        uint held;
        bytes dexData;
        uint16 multiplier;
        uint price;
        uint cAvgPrice;
        uint hAvgPrice; 
        uint8 decimals;
        uint lastUpdateTime;
    }
}


// : BUSL-1.1
pragma solidity 0.7.6;

pragma experimental ABIEncoderV2;

//import"./Types.sol";
//import"./liquidity/LPoolInterface.sol";
//import"./ControllerInterface.sol";
//import"./dex/DexAggregatorInterface.sol";
//import"./OpenLevInterface.sol";
//import"./lib/DexData.sol";
//import"./lib/TransferHelper.sol";
//import"./lib/Utils.sol";

abstract contract OpenLevStorage {
    using SafeMath for uint;
    using TransferHelper for IERC20;

    struct CalculateConfig {
        uint16 defaultFeesRate; // 30 =>0.003
        uint8 insuranceRatio; // 33=>33%
        uint16 defaultMarginLimit; // 3000=>30%
        uint16 priceDiffientRatio; //10=>10%
        uint16 updatePriceDiscount;//25=>25%
        uint16 feesDiscount; // 25=>25%
        uint128 feesDiscountThreshold; //  30 * (10 ** 18) minimal holding of xOLE to enjoy fees discount
        uint16 penaltyRatio;//100=>1%
        uint8 maxLiquidationPriceDiffientRatio;//30=>30%
        uint16 twapDuration;//28=>28s
    }

    struct AddressConfig {
        DexAggregatorInterface dexAggregator;
        address controller;
        address wETH;
        address xOLE;
    }

    // number of markets
    uint16 public numPairs;

    // marketId => Pair
    mapping(uint16 => Types.Market) public markets;

    // owner => marketId => long0(true)/long1(false) => Trades
    mapping(address => mapping(uint16 => mapping(bool => Types.Trade))) public activeTrades;

    //useless
    mapping(address => bool) public allowedDepositTokens;

    CalculateConfig public calculateConfig;

    AddressConfig public addressConfig;

    mapping(uint8 => bool) public supportDexs;

    mapping(address => uint) public totalHelds;

    // map(marketId, tokenAddress, index) => taxRate)
    mapping(uint16 => mapping(address => mapping(uint => uint24))) public taxes;

    event MarginTrade(
        address trader,
        uint16 marketId,
        bool longToken, // 0 => long token 0; 1 => long token 1;
        bool depositToken,
        uint deposited,
        uint borrowed,
        uint held,
        uint fees,
        uint token0Price,
        uint32 dex
    );

    event TradeClosed(
        address owner,
        uint16 marketId,
        bool longToken,
        bool depositToken,
        uint closeAmount,
        uint depositDecrease,
        uint depositReturn,
        uint fees,
        uint token0Price,
        uint32 dex
    );

    event Liquidation(
        address owner,
        uint16 marketId,
        bool longToken,
        bool depositToken,
        uint liquidationAmount,
        uint outstandingAmount,
        address liquidator,
        uint depositDecrease,
        uint depositReturn,
        uint fees,
        uint token0Price,
        uint penalty,
        uint32 dex
    );

    event NewAddressConfig(address controller, address dexAggregator);

    event NewCalculateConfig(
        uint16 defaultFeesRate,
        uint8 insuranceRatio,
        uint16 defaultMarginLimit,
        uint16 priceDiffientRatio,
        uint16 updatePriceDiscount,
        uint16 feesDiscount,
        uint128 feesDiscountThreshold,
        uint16 penaltyRatio,
        uint8 maxLiquidationPriceDiffientRatio,
        uint16 twapDuration);

    event NewMarketConfig(uint16 marketId, uint16 feesRate, uint32 marginLimit, uint16 priceDiffientRatio, uint32[] dexs);

    event ChangeAllowedDepositTokens(address[] token, bool allowed);

}

/**
  * @title OpenLevInterface
  * @author OpenLeverage
  */
interface OpenLevInterface {

    function addMarket(
        LPoolInterface pool0,
        LPoolInterface pool1,
        uint16 marginLimit,
        bytes memory dexData
    ) external returns (uint16);


    function marginTrade(uint16 marketId, bool longToken, bool depositToken, uint deposit, uint borrow, uint minBuyAmount, bytes memory dexData) external payable;

    function closeTrade(uint16 marketId, bool longToken, uint closeAmount, uint minOrMaxAmount, bytes memory dexData) external;

    function liquidate(address owner, uint16 marketId, bool longToken, uint minBuy, uint maxAmount, bytes memory dexData) external;

    function marginRatio(address owner, uint16 marketId, bool longToken, bytes memory dexData) external view returns (uint current, uint cAvg, uint hAvg, uint32 limit);

    function updatePrice(uint16 marketId, bytes memory dexData) external;

    function shouldUpdatePrice(uint16 marketId, bytes memory dexData) external view returns (bool);

    function getMarketSupportDexs(uint16 marketId) external view returns (uint32[] memory);

    // function getCalculateConfig() external view returns (OpenLevStorage.CalculateConfig memory);

    /*** Admin Functions ***/
    function setCalculateConfig(uint16 defaultFeesRate, uint8 insuranceRatio, uint16 defaultMarginLimit, uint16 priceDiffientRatio,
        uint16 updatePriceDiscount, uint16 feesDiscount, uint128 feesDiscountThreshold, uint16 penaltyRatio, uint8 maxLiquidationPriceDiffientRatio, uint16 twapDuration) external;

    function setAddressConfig(address controller, DexAggregatorInterface dexAggregator) external;

    function setMarketConfig(uint16 marketId, uint16 feesRate, uint16 marginLimit, uint16 priceDiffientRatio, uint32[] memory dexs) external;

    function moveInsurance(uint16 marketId, uint8 poolIndex, address to, uint amount) external;

    function setSupportDex(uint8 dex, bool support) external;

    function setTaxRate(uint16 marketId, address token, uint index, uint24 tax) external;

}


// : BUSL-1.1
pragma solidity 0.7.6;


abstract contract DelegatorInterface {
    /**
     * Implementation address for this contract
     */
    address public implementation;

    /**
     * Emitted when implementation is changed
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function setImplementation(address implementation_) public virtual;


    /**
    * Internal method to delegate execution to another contract
    * @dev It returns to the external caller whatever the implementation returns or forwards reverts
    * @param callee The contract to delegatecall
    * @param data The raw data to delegatecall
    * @return The returned bytes from the delegatecall
    */
    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {revert(add(returnData, 0x20), returndatasize())}
        }
        return returnData;
    }

    /**
     * Delegates execution to the implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param data The raw data to delegatecall
     * @return The returned bytes from the delegatecall
     */
    function delegateToImplementation(bytes memory data) public returns (bytes memory) {
        return delegateTo(implementation, data);
    }

    /**
     * Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     *  There are an additional 2 prefix uints from the wrapper returndata, which we ignore since we make an extra hop.
     * @param data The raw data to delegatecall
     * @return The returned bytes from the delegatecall
     */
    function delegateToViewImplementation(bytes memory data) public view returns (bytes memory) {
        (bool success, bytes memory returnData) = address(this).staticcall(abi.encodeWithSignature("delegateToImplementation(bytes)", data));
        assembly {
            if eq(success, 0) {revert(add(returnData, 0x20), returndatasize())}
        }
        return abi.decode(returnData, (bytes));
    }
    /**
    * Delegates execution to an implementation contract
    * @dev It returns to the external caller whatever the implementation returns or forwards reverts
    */
    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() internal {
        // delegate all other functions to current implementation
        if (msg.data.length > 0) {
            (bool success,) = implementation.delegatecall(msg.data);
            assembly {
                let free_mem_ptr := mload(0x40)
                returndatacopy(free_mem_ptr, 0, returndatasize())
                switch success
                case 0 {revert(free_mem_ptr, returndatasize())}
                default {return (free_mem_ptr, returndatasize())}
            }
        }
    }
}


// : BUSL-1.1
pragma solidity 0.7.6;


contract DelegateInterface {
    /**
     * Implementation address for this contract
     */
    address public implementation;

}




// : BUSL-1.1
pragma solidity 0.7.6;

pragma experimental ABIEncoderV2;

//import"./liquidity/LPoolInterface.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"./dex/DexAggregatorInterface.sol";

contract ControllerStorage {

    //lpool-pair
    struct LPoolPair {
        address lpool0;
        address lpool1;
    }
    //lpool-distribution
    struct LPoolDistribution {
        uint64 startTime;
        uint64 endTime;
        uint64 duration;
        uint64 lastUpdateTime;
        uint256 totalRewardAmount;
        uint256 rewardRate;
        uint256 rewardPerTokenStored;
        uint256 extraTotalToken;
    }
    //lpool-rewardByAccount
    struct LPoolRewardByAccount {
        uint rewardPerTokenStored;
        uint rewards;
        uint extraToken;
    }

    struct OLETokenDistribution {
        uint supplyBorrowBalance;
        uint extraBalance;
        uint128 updatePricePer;
        uint128 liquidatorMaxPer;
        uint16 liquidatorOLERatio;//300=>300%
        uint16 xoleRaiseRatio;//150=>150%
        uint128 xoleRaiseMinAmount;
    }

    IERC20 public oleToken;

    address public xoleToken;

    address public wETH;

    address public lpoolImplementation;

    //interest param
    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;

    bytes public oleWethDexData;

    address public openLev;

    DexAggregatorInterface public dexAggregator;

    bool public suspend;

    OLETokenDistribution public oleTokenDistribution;
    //token0=>token1=>pair
    mapping(address => mapping(address => LPoolPair)) public lpoolPairs;
    //marketId=>isDistribution
    mapping(uint => bool) public marketExtraDistribution;
    //marketId=>isSuspend
    mapping(uint => bool) public marketSuspend;
    //pool=>allowed
    mapping(address => bool) public lpoolUnAlloweds;
    //pool=>bool=>distribution(true is borrow,false is supply)
    mapping(LPoolInterface => mapping(bool => LPoolDistribution)) public lpoolDistributions;
    //pool=>bool=>distribution(true is borrow,false is supply)
    mapping(LPoolInterface => mapping(bool => mapping(address => LPoolRewardByAccount))) public lPoolRewardByAccounts;

    bool public suspendAll;

    event LPoolPairCreated(address token0, address pool0, address token1, address pool1, uint16 marketId, uint16 marginLimit, bytes dexData);

    event Distribution2Pool(address pool, uint supplyAmount, uint borrowerAmount, uint64 startTime, uint64 duration, uint newSupplyBorrowBalance);

    event UpdatePriceReward(uint marketId, address updator, uint reward, uint newExtraBalance);

    event LiquidateReward(uint marketId, address liquidator, uint reward, uint newExtraBalance);

    event PoolReward(address pool, address rewarder, bool isBorrow, uint reward);

    event NewOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount);


}
/**
  * @title Controller
  * @author OpenLeverage
  */
interface ControllerInterface {

    function createLPoolPair(address tokenA, address tokenB, uint16 marginLimit, bytes memory dexData) external;

    /*** Policy Hooks ***/

    function mintAllowed(address minter, uint lTokenAmount) external;

    function transferAllowed(address from, address to, uint lTokenAmount) external;

    function redeemAllowed(address redeemer, uint lTokenAmount) external;

    function borrowAllowed(address borrower, address payee, uint borrowAmount) external;

    function repayBorrowAllowed(address payer, address borrower, uint repayAmount, bool isEnd) external;

    function liquidateAllowed(uint marketId, address liquidator, uint liquidateAmount, bytes memory dexData) external;

    function marginTradeAllowed(uint marketId) external view returns (bool);

    function closeTradeAllowed(uint marketId) external view returns (bool);

    function updatePriceAllowed(uint marketId, address to) external;

    /*** Admin Functions ***/

    function setLPoolImplementation(address _lpoolImplementation) external;

    function setOpenLev(address _openlev) external;

    function setDexAggregator(DexAggregatorInterface _dexAggregator) external;

    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external;

    function setLPoolUnAllowed(address lpool, bool unAllowed) external;

    function setSuspend(bool suspend) external;

    function setSuspendAll(bool suspend) external;

    function setMarketSuspend(uint marketId, bool suspend) external;

    function setOleWethDexData(bytes memory _oleWethDexData) external;

    // liquidatorOLERatio: Two decimal in percentage, ex. 300% => 300
    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external;

    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external;

    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external;

    function distributeExtraRewards2Markets(uint[] memory marketIds, bool isDistribution) external;

    /***Distribution Functions ***/

    function earned(LPoolInterface lpool, address account, bool isBorrow) external view returns (uint256);

    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external;

}




// : BUSL-1.1


pragma solidity 0.7.6;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
    constructor () {
        developer = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;
        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;
        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        // Store admin with value pendingAdmin
        admin = pendingAdmin;
        // Clear the pending value
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

}


pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// : MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"./IERC20.sol";
//import"../../math/SafeMath.sol";
//import"../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"../../utils/Context.sol";
//import"./IERC20.sol";
//import"../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


// : MIT

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


// : BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"./ControllerInterface.sol";
//import"./liquidity/LPoolDelegator.sol";
//import"./Adminable.sol";
//import"@openzeppelin/contracts/math/SafeMath.sol";
//import"@openzeppelin/contracts/math/Math.sol";
//import"./DelegateInterface.sol";
//import"./lib/DexData.sol";
//import"@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import"./OpenLevInterface.sol";
//import"./XOLEInterface.sol";

/// @title OpenLeverage Controller Logic
/// @author OpenLeverage
/// @notice You can use this contract for operating trades and find trading intel.
/// @dev Admin of this contract is the address of Timelock. Admin set configs and transfer insurance expected to XOLE.
contract ControllerV1 is DelegateInterface, Adminable, ControllerInterface, ControllerStorage {
    using SafeMath for uint;
    constructor () {}

    /// @notice Initialize proxy contract
    /// @dev This function is not supposed to call multiple times. All configs can be set through other functions.
    /// @param _oleToken Address of OLEToken.
    /// @param _xoleToken address of XOLEToken.
    /// @param _wETH Address of wrapped native coin.
    /// @param _lpoolImplementation Address of lending pool logic contract.
    /// @param _openlev Address of openLev aggregator contract.
    /// @param _dexAggregator Address of DexAggregatorDelegator.
    /// @param _oleWethDexData Index and feeRate of ole/weth pair.
    function initialize(
        IERC20 _oleToken,
        address _xoleToken,
        address _wETH,
        address _lpoolImplementation,
        address _openlev,
        DexAggregatorInterface _dexAggregator,
        bytes memory _oleWethDexData
    ) public {
        require(msg.sender == admin, "not admin");
        oleToken = _oleToken;
        xoleToken = _xoleToken;
        wETH = _wETH;
        lpoolImplementation = _lpoolImplementation;
        openLev = _openlev;
        dexAggregator = _dexAggregator;
        oleWethDexData = _oleWethDexData;
    }

    struct LPoolPairVar {
        address token0;
        address token1;
        uint16 marginLimit;
        bytes dexData;
        string tokenName;
        string tokenSymbol;
    }

    /// @notice Create Lending pools for token0, token1. create market on OpenLev
    /// @param token0 Address of token0
    /// @param token1 Address of token1
    /// @param marginLimit The liquidation trigger ratio of deposited token value to borrowed token value.
    /// @param dexData Pair initiate data including index, feeRate of the Dex and tax rate of the underlying tokens.
    function createLPoolPair(address token0, address token1, uint16 marginLimit, bytes memory dexData) external override {
        require(token0 != token1, 'identical address');
        require(lpoolPairs[token0][token1].lpool0 == address(0) || lpoolPairs[token1][token0].lpool0 == address(0), 'pool pair exists');
        LPoolPairVar memory pairVar = LPoolPairVar(token0, token1, marginLimit, dexData, "OpenLeverage LToken", "LToken");
        LPoolDelegator pool0 = new LPoolDelegator();
        pool0.initialize(pairVar.token0, pairVar.token0 == wETH ? true : false, address(this), baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink, 1e18,
            pairVar.tokenName, pairVar.tokenSymbol, ERC20(pairVar.token0).decimals(), admin, lpoolImplementation);
        LPoolDelegator pool1 = new LPoolDelegator();
        pool1.initialize(pairVar.token1, pairVar.token1 == wETH ? true : false, address(this), baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink, 1e18,
            pairVar.tokenName, pairVar.tokenSymbol, ERC20(pairVar.token1).decimals(), admin, lpoolImplementation);
        lpoolPairs[token0][token1] = LPoolPair(address(pool0), address(pool1));
        lpoolPairs[token1][token0] = LPoolPair(address(pool0), address(pool1));
        uint16 marketId = (OpenLevInterface(openLev)).addMarket(LPoolInterface(address(pool0)), LPoolInterface(address(pool1)), pairVar.marginLimit, pairVar.dexData);
        emit LPoolPairCreated(pairVar.token0, address(pool0), pairVar.token1, address(pool1), marketId, pairVar.marginLimit, pairVar.dexData);
    }


    /*** Policy Hooks ***/
    function mintAllowed(address minter, uint lTokenAmount) external override onlyLPoolAllowed onlyNotSuspended {
        stake(LPoolInterface(msg.sender), minter, lTokenAmount);
    }

    function transferAllowed(address from, address to, uint lTokenAmount) external override {
        withdraw(LPoolInterface(msg.sender), from, lTokenAmount);
        stake(LPoolInterface(msg.sender), to, lTokenAmount);
    }

    function redeemAllowed(address redeemer, uint lTokenAmount) external override onlyNotSuspended {
        if (withdraw(LPoolInterface(msg.sender), redeemer, lTokenAmount)) {
            getRewardInternal(LPoolInterface(msg.sender), redeemer, false);
        }
    }

    function borrowAllowed(address borrower, address payee, uint borrowAmount) external override onlyLPoolAllowed onlyNotSuspended onlyOpenLevOperator(payee) {
        require(LPoolInterface(msg.sender).availableForBorrow() >= borrowAmount, "Borrow out of range");
        updateReward(LPoolInterface(msg.sender), borrower, true);
    }

    function repayBorrowAllowed(address payer, address borrower, uint repayAmount, bool isEnd) external override {
        // Shh - currently unused
        repayAmount;
        if (isEnd) {
            require(openLev == payer, "Operator not openLev");
        }
        if (updateReward(LPoolInterface(msg.sender), borrower, true)) {
            getRewardInternal(LPoolInterface(msg.sender), borrower, true);
        }
    }

    function liquidateAllowed(uint marketId, address liquidator, uint liquidateAmount, bytes memory dexData) external override onlyOpenLevOperator(msg.sender) {
        // Shh - currently unused
        liquidateAmount;
        dexData;
        require(!marketSuspend[marketId], 'Market suspended');
        // market no distribution
        if (marketExtraDistribution[marketId] == false) {
            return;
        }
        // rewards is zero or balance not enough
        if (oleTokenDistribution.liquidatorMaxPer == 0) {
            return;
        }
        //get wETH quote ole price
        (uint256 price, uint8 decimal) = dexAggregator.getPrice(wETH, address(oleToken), oleWethDexData);
        // oleRewards=wETHValue*liquidatorOLERatio
        uint calcLiquidatorRewards = uint(600000)  // needs approximately 600k gas for liquidation
        .mul(50 gwei).mul(price).div(10 ** uint(decimal))
        .mul(oleTokenDistribution.liquidatorOLERatio).div(100);
        // check compare max
        if (calcLiquidatorRewards > oleTokenDistribution.liquidatorMaxPer) {
            calcLiquidatorRewards = oleTokenDistribution.liquidatorMaxPer;
        }
        if (calcLiquidatorRewards > oleTokenDistribution.extraBalance) {
            return;
        }
        if (transferOut(liquidator, calcLiquidatorRewards)) {
            oleTokenDistribution.extraBalance = oleTokenDistribution.extraBalance.sub(calcLiquidatorRewards);
            emit LiquidateReward(marketId, liquidator, calcLiquidatorRewards, oleTokenDistribution.extraBalance);
        }
    }

    function marginTradeAllowed(uint marketId) external view override onlyNotSuspended returns (bool){
        require(!marketSuspend[marketId], 'Market suspended');
        return true;
    }

    function closeTradeAllowed(uint marketId) external view override returns (bool){
        require(!suspendAll, 'Suspended');
        return true;
    }

    function updatePriceAllowed(uint marketId, address payee) external override onlyOpenLevOperator(msg.sender) {
        // Shh - currently unused
        marketId;
        // market no distribution
        if (marketExtraDistribution[marketId] == false) {
            return;
        }
        uint reward = oleTokenDistribution.updatePricePer;
        if (reward > oleTokenDistribution.extraBalance) {
            return;
        }
        if (transferOut(payee, reward)) {
            oleTokenDistribution.extraBalance = oleTokenDistribution.extraBalance.sub(reward);
            emit UpdatePriceReward(marketId, payee, reward, oleTokenDistribution.extraBalance);
        }
    }

    /*** Distribution Functions ***/

    function initDistribution(uint totalAmount, uint64 startTime, uint64 duration) internal pure returns (ControllerStorage.LPoolDistribution memory distribution){
        distribution.startTime = startTime;
        distribution.endTime = startTime + duration;
        require(distribution.endTime >= startTime, 'EndTime is overflow');
        distribution.duration = duration;
        distribution.lastUpdateTime = startTime;
        distribution.totalRewardAmount = totalAmount;
        distribution.rewardRate = totalAmount.div(duration);
    }

    function updateDistribution(ControllerStorage.LPoolDistribution storage distribution, uint addAmount) internal {
        uint256 blockTime = block.timestamp;
        if (blockTime >= distribution.endTime) {
            distribution.rewardRate = addAmount.div(distribution.duration);
        } else {
            uint256 remaining = distribution.endTime - blockTime;
            uint256 leftover = remaining.mul(distribution.rewardRate);
            distribution.rewardRate = addAmount.add(leftover).div(distribution.duration);
        }
        distribution.lastUpdateTime = uint64(blockTime);
        distribution.totalRewardAmount = distribution.totalRewardAmount.add(addAmount);
        distribution.endTime = distribution.duration + uint64(blockTime);
        require(distribution.endTime > blockTime, 'EndTime is overflow');
    }

    function checkStart(LPoolInterface lpool, bool isBorrow) internal view returns (bool){
        return block.timestamp >= lpoolDistributions[lpool][isBorrow].startTime;
    }


    function existRewards(LPoolInterface lpool, bool isBorrow) internal view returns (bool){
        return lpoolDistributions[lpool][isBorrow].totalRewardAmount > 0;
    }

    function lastTimeRewardApplicable(LPoolInterface lpool, bool isBorrow) public view returns (uint256) {
        return Math.min(block.timestamp, lpoolDistributions[lpool][isBorrow].endTime);
    }

    function rewardPerToken(LPoolInterface lpool, bool isBorrow) internal view returns (uint256) {
        LPoolDistribution memory distribution = lpoolDistributions[lpool][isBorrow];
        uint totalAmount = isBorrow ? lpool.totalBorrowsCurrent() : lpool.totalSupply().add(distribution.extraTotalToken);
        if (totalAmount == 0) {
            return distribution.rewardPerTokenStored;
        }
        return
        distribution.rewardPerTokenStored.add(
            lastTimeRewardApplicable(lpool, isBorrow)
            .sub(distribution.lastUpdateTime)
            .mul(distribution.rewardRate)
            .mul(1e18)
            .div(totalAmount)
        );
    }

    function updateReward(LPoolInterface lpool, address account, bool isBorrow) internal returns (bool) {
        if (!existRewards(lpool, isBorrow) || !checkStart(lpool, isBorrow)) {
            return false;
        }
        uint rewardPerTokenStored = rewardPerToken(lpool, isBorrow);
        lpoolDistributions[lpool][isBorrow].rewardPerTokenStored = rewardPerTokenStored;
        lpoolDistributions[lpool][isBorrow].lastUpdateTime = uint64(lastTimeRewardApplicable(lpool, isBorrow));
        if (account != address(0)) {
            lPoolRewardByAccounts[lpool][isBorrow][account].rewards = earnedInternal(lpool, account, isBorrow);
            lPoolRewardByAccounts[lpool][isBorrow][account].rewardPerTokenStored = rewardPerTokenStored;
        }
        return true;
    }

    function stake(LPoolInterface lpool, address account, uint256 amount) internal returns (bool) {
        bool updateSucceed = updateReward(lpool, account, false);
        if (xoleToken == address(0) || XOLEInterface(xoleToken).balanceOf(account) < oleTokenDistribution.xoleRaiseMinAmount) {
            return updateSucceed;
        }
        uint addExtraToken = amount.mul(oleTokenDistribution.xoleRaiseRatio).div(100);
        lPoolRewardByAccounts[lpool][false][account].extraToken = lPoolRewardByAccounts[lpool][false][account].extraToken.add(addExtraToken);
        lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.add(addExtraToken);
        return updateSucceed;
    }

    function withdraw(LPoolInterface lpool, address account, uint256 amount) internal returns (bool)  {
        bool updateSucceed = updateReward(lpool, account, false);
        if (xoleToken == address(0)) {
            return updateSucceed;
        }
        uint extraToken = lPoolRewardByAccounts[lpool][false][account].extraToken;
        if (extraToken == 0) {
            return updateSucceed;
        }
        uint oldBalance = lpool.balanceOf(account);
        //withdraw all
        if (oldBalance == amount) {
            lPoolRewardByAccounts[lpool][false][account].extraToken = 0;
            lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.sub(extraToken);
        } else {
            uint subExtraToken = extraToken.mul(amount).div(oldBalance);
            lPoolRewardByAccounts[lpool][false][account].extraToken = extraToken.sub(subExtraToken);
            lpoolDistributions[lpool][false].extraTotalToken = lpoolDistributions[lpool][false].extraTotalToken.sub(subExtraToken);
        }
        return updateSucceed;
    }


    function earnedInternal(LPoolInterface lpool, address account, bool isBorrow) internal view returns (uint256) {
        LPoolRewardByAccount memory accountReward = lPoolRewardByAccounts[lpool][isBorrow][account];
        uint accountBalance = isBorrow ? lpool.borrowBalanceCurrent(account) : lpool.balanceOf(account).add(accountReward.extraToken);
        return
        accountBalance
        .mul(rewardPerToken(lpool, isBorrow).sub(accountReward.rewardPerTokenStored))
        .div(1e18)
        .add(accountReward.rewards);
    }

    function getRewardInternal(LPoolInterface lpool, address account, bool isBorrow) internal {
        uint256 reward = lPoolRewardByAccounts[lpool][isBorrow][account].rewards;
        if (reward > 0) {
            bool succeed = transferOut(account, reward);
            if (succeed) {
                lPoolRewardByAccounts[lpool][isBorrow][account].rewards = 0;
                emit PoolReward(address(lpool), account, isBorrow, reward);
            }
        }
    }

    function earned(LPoolInterface lpool, address account, bool isBorrow) external override view returns (uint256) {
        if (!existRewards(lpool, isBorrow) || !checkStart(lpool, isBorrow)) {
            return 0;
        }
        return earnedInternal(lpool, account, isBorrow);
    }

    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external override {
        uint rewards;
        for (uint i = 0; i < lpools.length; i++) {
            if (updateReward(lpools[i], account, false)) {
                uint poolRewards = lPoolRewardByAccounts[lpools[i]][false][account].rewards;
                rewards = rewards.add(poolRewards);
                lPoolRewardByAccounts[lpools[i]][false][account].rewards = 0;
                emit PoolReward(address(lpools[i]), account, false, poolRewards);
            }
        }
        require(rewards > 0, 'rewards is zero');
        require(oleToken.balanceOf(address(this)) >= rewards, 'balance<rewards');
        oleToken.transfer(account, rewards);
    }


    function transferOut(address to, uint amount) internal returns (bool){
        if (oleToken.balanceOf(address(this)) < amount) {
            return false;
        }
        oleToken.transfer(to, amount);
        return true;
    }
    /*** Admin Functions ***/

    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external override onlyAdmin {
        uint newSupplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.add(moreSupplyBorrowBalance);
        uint newExtraBalance = oleTokenDistribution.extraBalance.add(moreExtraBalance);
        uint totalAll = newExtraBalance.add(newSupplyBorrowBalance);
        require(oleToken.balanceOf(address(this)) >= totalAll, 'not enough balance');
        oleTokenDistribution.supplyBorrowBalance = newSupplyBorrowBalance;
        oleTokenDistribution.extraBalance = newExtraBalance;
        oleTokenDistribution.updatePricePer = updatePricePer;
        oleTokenDistribution.liquidatorMaxPer = liquidatorMaxPer;
        oleTokenDistribution.liquidatorOLERatio = liquidatorOLERatio;
        oleTokenDistribution.xoleRaiseRatio = xoleRaiseRatio;
        oleTokenDistribution.xoleRaiseMinAmount = xoleRaiseMinAmount;
        emit NewOLETokenDistribution(moreSupplyBorrowBalance, moreExtraBalance, updatePricePer, liquidatorMaxPer, liquidatorOLERatio, xoleRaiseRatio, xoleRaiseMinAmount);
    }

    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external override onlyAdmin {
        require(supplyAmount > 0 || borrowAmount > 0, 'amount is less than 0');
        require(startTime > block.timestamp, 'startTime < blockTime');
        if (supplyAmount > 0) {
            require(lpoolDistributions[LPoolInterface(pool)][false].startTime == 0, 'Distribute only once');
            lpoolDistributions[LPoolInterface(pool)][false] = initDistribution(supplyAmount, startTime, duration);
        }
        if (borrowAmount > 0) {
            require(lpoolDistributions[LPoolInterface(pool)][true].startTime == 0, 'Distribute only once');
            lpoolDistributions[LPoolInterface(pool)][true] = initDistribution(borrowAmount, startTime, duration);
        }
        uint subAmount = supplyAmount.add(borrowAmount);
        oleTokenDistribution.supplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.sub(subAmount);
        emit Distribution2Pool(pool, supplyAmount, borrowAmount, startTime, duration, oleTokenDistribution.supplyBorrowBalance);
    }

    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external override onlyAdmin {
        require(supplyAmount > 0 || borrowAmount > 0, 'amount0 and amount1 is 0');
        if (supplyAmount > 0) {
            updateReward(LPoolInterface(pool), address(0), false);
            updateDistribution(lpoolDistributions[LPoolInterface(pool)][false], supplyAmount);
        }
        if (borrowAmount > 0) {
            updateReward(LPoolInterface(pool), address(0), true);
            updateDistribution(lpoolDistributions[LPoolInterface(pool)][true], borrowAmount);
        }
        bool isBorrowMore = borrowAmount > 0 ? true : false;
        uint subAmount = supplyAmount.add(borrowAmount);
        oleTokenDistribution.supplyBorrowBalance = oleTokenDistribution.supplyBorrowBalance.sub(subAmount);
        emit Distribution2Pool(pool, supplyAmount, borrowAmount, lpoolDistributions[LPoolInterface(pool)][isBorrowMore].startTime,
            lpoolDistributions[LPoolInterface(pool)][isBorrowMore].duration, oleTokenDistribution.supplyBorrowBalance);
    }

    function distributeExtraRewards2Markets(uint[] memory marketIds, bool isDistribution) external override onlyAdminOrDeveloper {
        for (uint i = 0; i < marketIds.length; i++) {
            marketExtraDistribution[marketIds[i]] = isDistribution;
        }
    }

    function setLPoolImplementation(address _lpoolImplementation) external override onlyAdmin {
        require(address(0) != _lpoolImplementation, '0x');
        lpoolImplementation = _lpoolImplementation;
    }

    function setOpenLev(address _openlev) external override onlyAdmin {
        require(address(0) != _openlev, '0x');
        openLev = _openlev;
    }

    function setDexAggregator(DexAggregatorInterface _dexAggregator) external override onlyAdmin {
        require(address(0) != address(_dexAggregator), '0x');
        dexAggregator = _dexAggregator;
    }

    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external override onlyAdmin {
        require(_baseRatePerBlock < 1e13 && _multiplierPerBlock < 1e13 && _jumpMultiplierPerBlock < 1e13 && _kink <= 1e18, 'PRI');
        baseRatePerBlock = _baseRatePerBlock;
        multiplierPerBlock = _multiplierPerBlock;
        jumpMultiplierPerBlock = _jumpMultiplierPerBlock;
        kink = _kink;
    }

    function setLPoolUnAllowed(address lpool, bool unAllowed) external override onlyAdminOrDeveloper {
        lpoolUnAlloweds[lpool] = unAllowed;
    }

    function setSuspend(bool _uspend) external override onlyAdminOrDeveloper {
        suspend = _uspend;
    }

    function setSuspendAll(bool _uspend) external override onlyAdminOrDeveloper {
        suspendAll = _uspend;
    }

    function setMarketSuspend(uint marketId, bool suspend) external override onlyAdminOrDeveloper {
        marketSuspend[marketId] = suspend;
    }

    function setOleWethDexData(bytes memory _oleWethDexData) external override onlyAdminOrDeveloper {
        oleWethDexData = _oleWethDexData;
    }

    modifier onlyLPoolAllowed() {
        require(!lpoolUnAlloweds[msg.sender], "LPool paused");
        _;
    }

    modifier onlyNotSuspended() {
        require(!suspend, 'Suspended');
        require(!suspendAll, 'Suspended all');
        _;
    }
    
    modifier onlyOpenLevOperator(address operator) {
        require(openLev == operator || openLev == address(0), "Operator not openLev");
        _;
    }

}

