// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/access/Ownable.sol


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/IFundPool.sol

pragma solidity ^0.6.12;

abstract contract IFundPool {
    function token() external view virtual returns (address);

    function take(uint256 amount) external virtual;

    function getTotalTokensByProfitRate()
        external
        view
        virtual
        returns (
            address,
            uint256,
            uint256
        );

    function profitRatePerBlock() external view virtual returns (uint256);

    function getTokenBalance() external view virtual returns (address, uint256);

    function getTotalTokenSupply()
        external
        view
        virtual
        returns (address, uint256);

    function returnToken(uint256 amount) external virtual;
}

// File: contracts/FundPoolStorage.sol

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;



contract FundPoolAdminStorage is Ownable {
    address public admin;

    address public implementation;
}

abstract contract FundPoolStorgeV1 is FundPoolAdminStorage, IFundPool {
    address public controller; //controller合约(用于管理员统一处理资金池和策略的合约)
    address public feeTo; //手续费地址 包括申购赎回管理费
    address public override token; //资金池币种
    address public weth; //weth地址
    address public sVaultNetValue; //SVaultNetValue地址

    uint256 public totalShares; //持币凭证总量

    uint256 public totalTokenSupply; //申购总额 总本金
    mapping(address => Share) public shares; //用户持币凭证数量及购买时间

    uint256 public tokenAmountLimit; //总投资限额
    uint256 public managementFeeRate; //基金管理费率(从赎回token里扣除，每次充提更新管理费)
    WithdrawFeeRate[] public withdrawFeeRate; //提币手续费数组(从赎回token里扣除，按照时间偏移量倒叙排列，例如30天 0.3%，15天0.8%，7天0.5%，小于7天1.5%)
    uint256 public depositFeeRate; //申购手续费
    // uint256 public max; //除数(用于费率计算) 1e18

    uint256 public override profitRatePerBlock; //每个块的收益率，0为高风险，非0为最高收益率(复利暂时填万2)

    //低风险时参数
    uint256 public minProfitRate; //最低收益率，
    uint256 public maxProfitRate; //最高收益率，
    uint256 public cumulativeProfit; //累计的收益  与本金相加为totalTokens

    uint256 public blockHeightLast; //上次更新的块高

    uint256 public takeAmount; //controller 提取的数量

    struct Share {
        uint256 shareAmount; //份额
        uint256 timestampForManagement; //上次管理费更新时间
        uint256 timestampForDeposit; //上次抵押更新时间  用于获取赎回费率
        uint256 managementFee; //累计的管理费
        uint256 averageNetWorth; //平均成本净值
    }
    struct WithdrawFeeRate {
        uint256 feeRate; //赎回费率
        uint256 timeOffset; //时间范围差值
    }
}

// File: contracts/FundPoolEvents.sol

pragma solidity ^0.6.12;

contract FundPoolEvents {
    event Deposit(
        address indexed user,
        uint256 amount,
        uint256 shareAmount,
        uint256 fee,
        uint256 totalTokensSupply,
        uint256 totalShares,
        uint256 totalTokens
    );

    event Withdraw(
        address indexed user,
        uint256 shareAmount,
        uint256 amount,
        uint256 withdrawFee,
        uint256 ManagementFee,
        uint256 totalTokensSupply,
        uint256 totalShares,
        uint256 totalTokens
    );

    event TokenAmountLimitChanged(uint256 oldAmount, uint256 newAmount);
    event ManagementFeeRateChanged(uint256 oldFeeRate, uint256 newFeeRate);
    event ProfitRateChanged(uint256 oldProfitRate, uint256 newProfitRate);
    event DepositFeeRateChanged(
        uint256 oldDepositFeeRate,
        uint256 newDepositFeeRate
    );
    event WithdrawFeeRateChanged(uint256 period, uint256 newWithdrawFeeRate);
}

// File: contracts/interfaces/IController.sol

pragma solidity ^0.6.12;

interface IController {
    struct TokenAmount{
        address token;
        uint256 amount;
    }
    function withdraw(uint256 _amount, uint256 _profitAmount) external returns (TokenAmount[] memory);

    function getStrategies() view external returns(address[] memory);
}

// File: contracts/interfaces/ISVaultNetValue.sol

pragma solidity ^0.6.12;

interface ISVaultNetValue {
    function getNetValue(address pool) external view returns (NetValue memory);

    struct NetValue {
        address pool;
        address token;
        uint256 amount;
        uint256 amountInETH;
        uint256 totalTokens; //本金加收益
        uint256 totalTokensInETH; //本金加收益
    }
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
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
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
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
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
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
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

// File: @openzeppelin/contracts/math/SafeMath.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/FundPoolDelegate.sol

pragma solidity ^0.6.12;









contract FundPoolDelegate is FundPoolStorgeV1, FundPoolEvents {
    using SafeMath for uint256;

    /// @notice  use for calculate fee
    uint256 public constant MAX = 1e18;

    //@notice  The number of seconds in a day
    uint256 public constant SECONDS_DAY = 86400;

    ///  @notice  整年的块数  eth:6496 * 365 = 2371040   bsc = 28800 * 365 = 10512000
    uint256 public constant BLOCK_PER_YEAR = 2371040;

    function initialize(
        address _token,
        address _weth,
        address _controller,
        address _sVaultNetValue,
        address _feeTo,
        uint256 _profitRatePerBlock,
        uint256 _tokenAmountLimit,
        uint256 _depositFeeRate
    ) public {
        require(msg.sender == admin, "unautherized");
        token = _token;
        weth = _weth;
        controller = _controller;
        sVaultNetValue = _sVaultNetValue;
        feeTo = _feeTo;
        profitRatePerBlock = _profitRatePerBlock;
        tokenAmountLimit = _tokenAmountLimit;
        depositFeeRate = _depositFeeRate;
    }

    function deposit(uint256 _tokenAmountIn) external {
        require(token != weth, "Invalid token");
        require(_tokenAmountIn > 0, "Insufficient Token");
        IERC20(token).transferFrom(msg.sender, address(this), _tokenAmountIn);

        _deposit(_tokenAmountIn);
    }

    function depositETH() external payable {
        require(token == weth, "Invalid token");
        require(msg.value > 0, "Insufficient Token");
        _deposit(msg.value);
    }

    function _deposit(uint256 _tokenAmountIn) private {
        // deposit fee
        uint256 amountInWithFee =
            _tokenAmountIn.mul(MAX).div(MAX.add(depositFeeRate));
        // uint256 amountInWithFee = _tokenAmountIn;
        uint256 fee = _tokenAmountIn.sub(amountInWithFee);
        if (token == weth) TransferHelper.safeTransferETH(feeTo, fee);
        else TransferHelper.safeTransfer(token, feeTo, fee);

        uint256 shardAmountOut;
        uint256 totalTokens = 0;
        if (totalShares == 0) {
            shardAmountOut = amountInWithFee;
        } else {
            totalTokens = getTotalTokens();
            shardAmountOut = amountInWithFee.mul(totalShares).div(totalTokens);
        }
        totalTokenSupply = totalTokenSupply.add(amountInWithFee);
        require(
            totalTokenSupply <= tokenAmountLimit,
            "overflow the token limit"
        );
        //计算管理费
        calculateManagementFee(shardAmountOut, 0, totalTokens);
        //更新成本净值
        updateAverageNetWorth(amountInWithFee, shardAmountOut);
        shares[msg.sender].shareAmount = shares[msg.sender].shareAmount.add(
            shardAmountOut
        );
        totalShares = totalShares.add(shardAmountOut);
        emit Deposit(
            msg.sender,
            _tokenAmountIn,
            shardAmountOut,
            fee,
            totalTokenSupply,
            totalShares,
            totalTokens
        );
    }

    function withdraw(uint256 _shareAmountIn) external {
        require(_shareAmountIn > 0, "Insufficient Input");
        require(
            _shareAmountIn <= shares[msg.sender].shareAmount,
            "Insufficient Input"
        );

        uint256 totalTokens = getTotalTokens();
        uint256 balance;
        uint256 tokenAmountOut =
            _shareAmountIn.mul(totalTokens).div(totalShares);
        if (token == weth) balance = address(this).balance;
        else balance = IERC20(token).balanceOf(address(this));

        //计算本金部分
        uint256 principal =
            shares[msg.sender].averageNetWorth.mul(_shareAmountIn).div(1e8);
        //需要扣除本金部分  将本金限额增加
        totalTokenSupply = totalTokenSupply.sub(principal);

        //扣除利润部分
        // 需要扣除的利润 tokenAmountOut.sub(principal);
        cumulativeProfit = cumulativeProfit.add(principal).sub(tokenAmountOut);

        //计算赎回费
        uint256 withdrawFee = calculateWithdrawFee(tokenAmountOut);
        //需要扣除管理费
        uint256 managementFee =
            calculateManagementFee(0, _shareAmountIn, totalTokens);

        uint256 totalFee = withdrawFee.add(managementFee);
        uint256 withdrawAmount = tokenAmountOut.sub(totalFee);
        shares[msg.sender].shareAmount = shares[msg.sender].shareAmount.sub(
            _shareAmountIn
        );
        totalShares = totalShares.sub(_shareAmountIn);
        if (balance < tokenAmountOut) {
            uint256 withdrawAmount = tokenAmountOut.sub(balance);
            uint256 withdrawPrincipal =
                principal.mul(withdrawAmount).div(tokenAmountOut);
            takeAmount = takeAmount.sub(withdrawPrincipal);
            uint256 withdrawProfit = withdrawAmount.sub(withdrawPrincipal);

            IController.TokenAmount[] memory tokenInPool;
            tokenInPool[0] = IController.TokenAmount({
                token: token,
                amount: balance
            });
            IController.TokenAmount[] memory tokens =
                IController(controller).withdraw(
                    withdrawPrincipal,
                    withdrawProfit
                );

            distribute(tokenInPool, totalFee, tokenAmountOut);
            distribute(tokens, totalFee, tokenAmountOut);
        } else {
            if (token == weth) {
                TransferHelper.safeTransferETH(feeTo, totalFee);
                TransferHelper.safeTransferETH(msg.sender, withdrawAmount);
            } else {
                TransferHelper.safeTransfer(token, feeTo, totalFee);
                TransferHelper.safeTransfer(token, msg.sender, withdrawAmount);
            }
        }

        emit Withdraw(
            msg.sender,
            _shareAmountIn,
            withdrawAmount,
            withdrawFee,
            managementFee,
            totalTokenSupply,
            totalShares,
            totalTokens
        );
    }

    // private function
    // 管理费 按份额
    function calculateManagementFee(
        uint256 shareAmountIn,
        uint256 shardAmountOut,
        uint256 totalTokens
    ) private returns (uint256) {
        //累计管理费并按照个人份额划分
        uint256 totalManagementFee = getTotalManagementFee();
        if (shareAmountIn > 0) {
            //申购时 只计算并累计 不扣除管理费
            shares[msg.sender].managementFee = totalManagementFee;
            shares[msg.sender].timestampForDeposit = now;
            return 0;
        } else {
            //赎回时 按份额比例计算费用
            uint256 realFee =
                totalManagementFee
                    .mul(shardAmountOut)
                    .mul(totalTokens)
                    .div(totalShares)
                    .div(shares[msg.sender].shareAmount);
            uint256 feeShare =
                totalManagementFee.mul(shardAmountOut).div(
                    shares[msg.sender].shareAmount
                );
            shares[msg.sender].managementFee = totalManagementFee.sub(feeShare);

            return realFee;
        }
    }

    function calculateWithdrawFee(uint256 tokenAmountOut)
        private
        view
        returns (uint256)
    {
        //赎回费
        uint256 feeRate = _getWithdrawFeeRate();
        uint256 withdrawFee = tokenAmountOut.mul(feeRate).div(MAX);
        return withdrawFee;
    }

    //update AverageNetWorth when user deposit
    function updateAverageNetWorth(
        uint256 amountInWithFee,
        uint256 shardAmountOut
    ) private {
        uint256 principal =
            shares[msg.sender]
                .averageNetWorth
                .mul(shares[msg.sender].shareAmount)
                .div(1e8)
                .add(amountInWithFee);
        //总份额
        uint256 share = shares[msg.sender].shareAmount.add(shardAmountOut);
        //平均净值
        uint256 netWorth = principal.mul(1e8).div(share);
        shares[msg.sender].averageNetWorth = netWorth;
    }

    function getTotalManagementFee() private returns (uint256) {
        uint256 timeLast = shares[msg.sender].timestampForManagement;
        uint256 offset = now.sub(timeLast).div(SECONDS_DAY).add(1);
        uint256 share = shares[msg.sender].shareAmount;
        //管理费= 份额*天数*管理费率
        uint256 fee = share.mul(offset).mul(managementFeeRate).div(MAX);
        uint256 managementFeeLast = shares[msg.sender].managementFee;
        uint256 totalManagementFee = managementFeeLast.add(fee);
        shares[msg.sender].timestampForManagement = now;
        return totalManagementFee;
    }

    function _getWithdrawFeeRate() private view returns (uint256 _feeRate) {
        uint256 timeLast = shares[msg.sender].timestampForDeposit;
        require(withdrawFeeRate.length > 0, "WithdrawFeeRate should be set");
        uint256 offset = now.sub(timeLast).div(SECONDS_DAY).add(1);
        for (uint256 i = 0; i < withdrawFeeRate.length; i++) {
            if (offset >= withdrawFeeRate[i].timeOffset) {
                _feeRate = withdrawFeeRate[i].feeRate;
            }
        }
    }

    // distribute tokens when user withdraw
    function distribute(
        IController.TokenAmount[] memory tokens,
        uint256 totalFee,
        uint256 tokenAmountOut
    ) private returns (uint256) {
        for (uint256 i = 0; i <= tokens.length; i++) {
            uint256 fee = tokens[i].amount.mul(totalFee).div(tokenAmountOut);
            uint256 withdrawAmount = tokens[i].amount.sub(fee);
            address token = tokens[i].token;
            if (token == weth) {
                TransferHelper.safeTransferETH(feeTo, fee);
                TransferHelper.safeTransferETH(msg.sender, withdrawAmount);
            } else {
                TransferHelper.safeTransfer(token, feeTo, fee);
                TransferHelper.safeTransfer(token, msg.sender, withdrawAmount);
            }
        }
    }

    // get totalTokens
    function getTotalTokens() internal returns (uint256) {
        //如果为保本 按照块高计算
        if (profitRatePerBlock != 0) {
            if (blockHeightLast == 0) {
                blockHeightLast = block.number;
                return 0;
            }

            uint256 blockOffset = block.number.sub(blockHeightLast);
            uint256 cumulativeProfitRate = blockOffset.mul(profitRatePerBlock);

            uint256 profit =
                totalTokenSupply.mul(cumulativeProfitRate).div(MAX);
            cumulativeProfit = cumulativeProfit.add(profit);

            blockHeightLast = block.number;
            uint256 totalTokens = totalTokenSupply.add(cumulativeProfit);
            return totalTokens;
        } else {
            //从sVaultNetValue里边获取totalTokens
            ISVaultNetValue.NetValue memory netValue =
                ISVaultNetValue(sVaultNetValue).getNetValue(address(this));

            return netValue.totalTokens;
        }
    }

    //admin operation
    function setManagementFeeRate(uint256 _newFeeRate) external {
        require(msg.sender == admin, "unauthorized");
        uint256 oldFeeRate = managementFeeRate;
        managementFeeRate = _newFeeRate;
        emit ManagementFeeRateChanged(oldFeeRate, _newFeeRate);
    }

    function setWithdrawFeeRate(WithdrawFeeRate[] memory _withdrawFeeRates)
        external
    {
        require(msg.sender == admin, "unauthorized");
        uint256 length = withdrawFeeRate.length;
        for (uint256 i = 0; i < length; i++) {
            withdrawFeeRate.pop();
        }
        for (uint256 i = 0; i < _withdrawFeeRates.length; i++) {
            WithdrawFeeRate memory w = _withdrawFeeRates[i];
            withdrawFeeRate.push(w);
            emit WithdrawFeeRateChanged(w.timeOffset, w.feeRate);
        }
    }

    function setDepositFeeRate(uint256 _newFeeRate) external {
        require(msg.sender == admin, "unauthorized");
        uint256 oldDepositFeeRate = depositFeeRate;
        depositFeeRate = _newFeeRate;
        emit DepositFeeRateChanged(oldDepositFeeRate, _newFeeRate);
    }

    function setProfitRateRange(uint256 _minProfitRate, uint256 _maxProfitRate)
        external
    {
        require(msg.sender == admin, "unauthorized");
        minProfitRate = _minProfitRate;
        maxProfitRate = _maxProfitRate;
    }

    function setProfitRatePerBlock(uint256 _profitRatePerBlock) external {
        require(msg.sender == admin, "unauthorized");
        uint256 newProfitRate = _profitRatePerBlock.mul(BLOCK_PER_YEAR);
        require(newProfitRate >= minProfitRate, "Invalid input");
        require(newProfitRate <= maxProfitRate, "Invalid input");
        uint256 oldProfitRate = profitRatePerBlock.mul(BLOCK_PER_YEAR);
        profitRatePerBlock = _profitRatePerBlock;
        emit ProfitRateChanged(oldProfitRate, newProfitRate);
    }

    function setFeeto(address _newFeeto) external {
        require(msg.sender == admin, "unauthorized");
        feeTo = _newFeeto;
    }

    function setTokenAmountLimit(uint256 _newTokenAmountLimit) external {
        require(msg.sender == admin, "unauthorized");
        uint256 oldTokenAmountLimit = tokenAmountLimit;
        tokenAmountLimit = _newTokenAmountLimit;
        emit TokenAmountLimitChanged(oldTokenAmountLimit, _newTokenAmountLimit);
    }

    function setSVaultNetValue(address _newSVaultNetValue) external {
        require(msg.sender == admin, "unauthorized");
        sVaultNetValue = _newSVaultNetValue;
    }

    function setController(address _newController) external {
        require(msg.sender == admin, "unauthorized");
        controller = _newController;
    }

    // controller operation
    function take(uint256 _amount) external override {
        require(msg.sender == controller, "unauthorized");
        takeAmount = takeAmount.add(_amount);
        if (weth == token) {
            TransferHelper.safeTransferETH(msg.sender, _amount);
        } else {
            TransferHelper.safeTransfer(token, msg.sender, _amount);
        }
    }

    function returnToken(uint256 amount) external override {
        require(msg.sender == controller, "unauthorized");
        takeAmount = takeAmount.sub(amount);
    }

    //view function
    function getTokenBalance()
        external
        view
        override
        returns (address, uint256)
    {
        return (token, IERC20(token).balanceOf(address(this)));
    }

    function getTotalTokenSupply()
        external
        view
        override
        returns (address, uint256)
    {
        return (token, totalTokenSupply);
    }

    function getTotalTokensByProfitRate()
        public
        view
        override
        returns (
            address,
            uint256,
            uint256
        )
    {
        //如果为保本 按照块高计算
        require(profitRatePerBlock != 0, "Invalid profitRatePerBlock");
        if (blockHeightLast == 0) {
            return (token, totalTokenSupply, 0);
        }

        uint256 blockOffset = block.number.sub(blockHeightLast);
        uint256 cumulativeProfitRate = blockOffset.mul(profitRatePerBlock);

        uint256 profit = totalTokenSupply.mul(cumulativeProfitRate).div(MAX);
        uint256 totalTokens =
            totalTokenSupply.add(cumulativeProfit.add(profit));
        return (token, totalTokenSupply, totalTokens);
    }

    function getWithdrawFeeRate()
        public
        view
        returns (WithdrawFeeRate[] memory)
    {
        return withdrawFeeRate;
    }
}