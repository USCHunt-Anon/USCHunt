// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity >=0.6.0 <0.8.0;




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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: contracts/ControllerStorage.sol

pragma solidity ^0.6.12;


contract ControllerAdminStorage is Ownable {
    address public admin;

    address public implementation;
}

contract ControllerStorage is ControllerAdminStorage {
    struct WithdrawSetting {
        address strategy;
        uint256[] tokenLimit;
    }
    address public WETH;
    address public strategist;
    mapping(address => mapping(address => bool)) public acceptedPools;
    mapping(address => address[]) public poolStrategies; //pool在哪些策略中有资金
    mapping(address => mapping(address => uint256)) public approvedStrategies; //pool ID => strategy合约地址 => 在poolStrategies中的index加一(0表示未使用该策略)
    mapping(address => mapping(address => uint256)) public poolAmountInStrategy; //pool在策略中的资金数量
    mapping(address => WithdrawSetting[]) public withdrawSettings;
    address[] public fixedPools;
    address[] public flexiblePools;
    address[] public strategies; //策略数组
    mapping(address => uint256) public allocatedProfit;
    address public sVaultNetValue;
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

// File: contracts/interfaces/IStrategy.sol

pragma solidity ^0.6.12;

abstract contract IStrategy {
    function earn(address[] memory tokens, uint256[] memory amounts) external virtual;
    function withdraw(address token) external virtual returns (uint256);
    function withdraw(uint256 amount) external virtual returns (address[] memory tokens, uint256[] memory amounts);
    function withdraw(address[] memory tokens, uint256 amount, uint256 _profitAmount) external virtual returns (uint256, uint256, address[] memory, uint256[] memory);
    function getTokenAmounts() external view virtual returns (address[] memory tokens, uint256[] memory amounts);
    function getTokens() external view virtual returns (address[] memory tokens);
    function getProfitTokens() external view virtual returns (address[] memory tokens);
}

// File: contracts/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// File: contracts/interfaces/ISVaultNetValue.sol

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

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

// File: contracts/interfaces/IController.sol

pragma solidity ^0.6.12;


interface IController {
    struct TokenAmount{
        address token;
        uint256 amount;
    }
    function withdraw(uint256 _amount, uint256 _profitAmount) external returns (TokenAmount[] memory);
    function accrueProfit() external returns (ISVaultNetValue.NetValue[] memory netValues);
    function getStrategies() view external returns(address[] memory);
    function getFixedPools() view external returns(address[] memory);
    function getFlexiblePools() view external returns(address[] memory);
    function allocatedProfit(address _pool) view external returns(uint256);
}

// File: contracts/interfaces/IAggregator.sol

pragma solidity ^0.6.12;

interface IAggregator {
    function getLatestStringAnswerByIndex(uint8 _index) external view returns (string memory);
}

// File: contracts/PriceView.sol

pragma solidity ^0.6.12;



contract PriceView {
    using SafeMath for uint256;
    IAggregator arrgregator;

    mapping(address => uint8) public tokenIndexes;

    constructor(IAggregator _aggregator) public {
        arrgregator = _aggregator;
    }

    function setTokenIndex(address token, uint8 index) external{
        tokenIndexes[token] = index;
    }

    function getPrice(address token) view public returns (uint256){
        string memory answer = arrgregator.getLatestStringAnswerByIndex(tokenIndexes[token]);
        return safeParseInt(answer);
    }

    function safeParseInt(string memory _a) internal pure returns (uint256 _parsedInt) {
        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            if ((uint256(uint8(bresult[i])) >= 48) && (uint256(uint8(bresult[i])) <= 57)) {
                mint = mint.mul(10);
                mint = mint.add(uint256(uint8(bresult[i])).sub(48));
            } else if (uint256(uint8(bresult[i])) == 46) {
                break;
            } else {
                revert("Non-numeral character encountered in string!");
            }
        }
        return mint;
    }
}

// File: contracts/SVaultNetValue.sol

pragma solidity ^0.6.12;






contract SVaultNetValue {
    using SafeMath for uint256;
    
   address public controller;
   PriceView public priceView;

   struct PoolWeight{
        address pool;
        address token;
        uint256 amount;
        uint256 amountInUSD;
        uint256 weight;
        uint256 allocatedProfitInUSD;
        uint256 price;
    }

    struct NetValue{
        address pool;
        address token;
        uint256 amount;
        uint256 amountInUSD;
        uint256 totalTokens; //本金加收益
        uint256 totalTokensInUSD; //本金加收益
    }

    struct TokenAmountView{
        TokenAmount[] tokenAmounts;
        uint256 totalAmountInUSD;
    }

    struct TokenAmount{
        address token;
        uint256 price;
        uint256 amount;
        uint256 amountInUSD;
    }

    constructor (address _controller, PriceView _priceView) public {
        controller = _controller;
        priceView = _priceView;
    }

    function getNetValueForTest(address pool) view external returns(NetValue memory netValue, uint256 blockNumber) {
        NetValue[] memory netValues = getNetValues();
        blockNumber = block.number;
        for(uint256 i = 0; i < netValues.length; i++){
            if(netValues[i].pool == pool){
                netValue = netValues[i];
                break;
            }
        }
    }

    function getNetValue(address pool) view external returns(NetValue memory){
        NetValue[] memory netValues = getNetValues();
        for(uint256 i = 0; i < netValues.length; i++){
            if(netValues[i].pool == pool) return netValues[i];
        }
    }

    function getNetValues() view public returns(NetValue[] memory netValues){
        address[] memory fixedPools = IController(controller).getFixedPools();
        address[] memory flexiblePools = IController(controller).getFlexiblePools();
        // get all tokens in pool and strategy, 包括本金加收益
        TokenAmountView memory tokenAmountView = getTokenAmounts(fixedPools, flexiblePools);
        netValues = new NetValue[](fixedPools.length + flexiblePools.length);
        uint256 totalFixedPoolUSD = 0;
        for(uint256 i = 0; i < fixedPools.length; i++){
            netValues[i].pool = fixedPools[i];
            (netValues[i].token, netValues[i].amount, netValues[i].totalTokens) = IFundPool(fixedPools[i]).getTotalTokensByProfitRate();
            uint256 price = priceView.getPrice(netValues[i].token);
            netValues[i].amountInUSD = price.mul(netValues[i].amount);
            netValues[i].totalTokensInUSD = price.mul(netValues[i].totalTokens);
            totalFixedPoolUSD = totalFixedPoolUSD.add(netValues[i].amountInUSD).add(netValues[i].totalTokensInUSD.sub(netValues[i].amountInUSD));
        }
        if(tokenAmountView.totalAmountInUSD < totalFixedPoolUSD) return netValues;
        tokenAmountView.totalAmountInUSD = tokenAmountView.totalAmountInUSD.sub(totalFixedPoolUSD);
        (PoolWeight[] memory poolWeights, uint256 totalWeight, uint256 totalAmountInUSD, uint256 totalAllocatedProfitInUSD) = getPoolWeights(flexiblePools);
        uint256 totalProfitAmountInUSD = 0;
        tokenAmountView.totalAmountInUSD = tokenAmountView.totalAmountInUSD.sub(totalAllocatedProfitInUSD);
        if(tokenAmountView.totalAmountInUSD < totalAmountInUSD){
            totalAmountInUSD = tokenAmountView.totalAmountInUSD;
        }else{
            totalProfitAmountInUSD = tokenAmountView.totalAmountInUSD.sub(totalAmountInUSD);
        }

        for(uint256 i = 0; i < poolWeights.length; i++){
            netValues[fixedPools.length+i].pool = poolWeights[i].pool;
            netValues[fixedPools.length+i].token = poolWeights[i].token;
            netValues[fixedPools.length+i].amountInUSD = totalWeight == 0 ? 0 : totalAmountInUSD.mul(poolWeights[i].weight).div(totalWeight);
            netValues[fixedPools.length+i].totalTokensInUSD = netValues[fixedPools.length+i].amountInUSD.add(totalWeight == 0 ? 0 : totalProfitAmountInUSD.mul(poolWeights[i].weight).div(totalWeight)).add(poolWeights[i].allocatedProfitInUSD);
            netValues[fixedPools.length+i].amount = netValues[fixedPools.length+i].amountInUSD.div(poolWeights[i].price);
            netValues[fixedPools.length+i].totalTokens = netValues[fixedPools.length+i].totalTokensInUSD.div(poolWeights[i].price);
        }
    }

    //TODO 单独写一个合约计算权重
    //获取高风险资金池占比
    function getPoolWeights(address[] memory flexiblePools) view internal returns (PoolWeight[] memory, uint256, uint256, uint256){
        PoolWeight[] memory poolWeights = new PoolWeight[](flexiblePools.length);
        uint256 totalWeight = 0;
        uint256 totalAmountInUSD = 0;
        uint256 totalAllocatedProfitInUSD = 0;
        for(uint256 i = 0; i < flexiblePools.length; i++){
            poolWeights[i].pool = flexiblePools[i];
            (poolWeights[i].token, poolWeights[i].amount) = IFundPool(flexiblePools[i]).getTotalTokenSupply();
            poolWeights[i].price = priceView.getPrice(poolWeights[i].token);
            poolWeights[i].amountInUSD = poolWeights[i].price.mul(poolWeights[i].amount);
            poolWeights[i].weight = poolWeights[i].amountInUSD;
            poolWeights[i].allocatedProfitInUSD = IController(controller).allocatedProfit(poolWeights[i].pool).mul(poolWeights[i].price);
            totalAmountInUSD = totalAmountInUSD.add(poolWeights[i].amountInUSD);
            totalWeight = totalWeight.add(poolWeights[i].weight);
            totalAllocatedProfitInUSD = totalAllocatedProfitInUSD.add(poolWeights[i].allocatedProfitInUSD);
        }
        return (poolWeights,totalWeight,totalAmountInUSD,totalAllocatedProfitInUSD);
    }

    function getTokenAmounts(address[] memory fixedPools, address[] memory flexiblePools) view internal returns(TokenAmountView memory){
        TokenAmountView memory tokenAmountView = TokenAmountView(new TokenAmount[](fixedPools.length + flexiblePools.length), 0);
        for(uint256 i = 0; i < fixedPools.length; i++){
            (address token, uint256 tokenBalance) = IFundPool(fixedPools[i]).getTokenBalance();
            AddTokenAmount(tokenAmountView, token, tokenBalance);
        }
        for(uint256 i = 0; i < flexiblePools.length; i++){
            (address token, uint256 tokenBalance) = IFundPool(flexiblePools[i]).getTokenBalance();
           AddTokenAmount(tokenAmountView, token, tokenBalance);
        }
        address[] memory strategies = IController(controller).getStrategies();
        for(uint256 i = 0; i < strategies.length; i++) {
            (address[] memory tokens, uint256[] memory amounts) = IStrategy(strategies[i]).getTokenAmounts();
            for(uint256 j = 0; j < tokens.length; j++){
                AddTokenAmount(tokenAmountView, tokens[j], amounts[j]);
            }
        }
        return tokenAmountView;
    }

    function getTokenAmount(TokenAmount[] memory tokenAmounts, address token) view internal returns (TokenAmount memory){
        for(uint256 i = 0; i < tokenAmounts.length; i++){
            if(tokenAmounts[i].token == token) return tokenAmounts[i];
        }
    }

    function AddTokenAmount(TokenAmountView memory tokenAmountView, address token, uint256 amount) view internal{
        for(uint256 j = 0; j < tokenAmountView.tokenAmounts.length; j++){
            if(tokenAmountView.tokenAmounts[j].token == address(0)){
                tokenAmountView.tokenAmounts[j].token = token;
                tokenAmountView.tokenAmounts[j].price = priceView.getPrice(token);
                tokenAmountView.tokenAmounts[j].amount = amount;
                tokenAmountView.tokenAmounts[j].amountInUSD = tokenAmountView.tokenAmounts[j].price.mul(amount);
                tokenAmountView.totalAmountInUSD = tokenAmountView.totalAmountInUSD.add(tokenAmountView.tokenAmounts[j].amountInUSD);
                break;
            }
            if(token == tokenAmountView.tokenAmounts[j].token){
                tokenAmountView.tokenAmounts[j].amount = tokenAmountView.tokenAmounts[j].amount.add(amount);
                uint256 amountInUSD = tokenAmountView.tokenAmounts[j].price.mul(amount);
                tokenAmountView.tokenAmounts[j].amountInUSD = tokenAmountView.tokenAmounts[j].amountInUSD.add(amountInUSD);
                tokenAmountView.totalAmountInUSD = tokenAmountView.totalAmountInUSD.add(amountInUSD);
                break;
            }
        }
    }

    
}

// File: contracts/Controller.sol

pragma solidity ^0.6.12;









contract Controller is ControllerStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function initialize(address _WETH) external {
        require(msg.sender == admin, "UNAUTHORIZED");
        require(WETH == address(0), "ALREADY INITIALIZED");
        WETH = _WETH;
        strategist = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "!admin");
        _;
    }

    modifier onlyStrategistAndOwner() {
        require(msg.sender == strategist || msg.sender == owner(), "!strategist");
        _;
    }

    struct PoolAmountInStrategy {
        address strategy; //策略地址
        address token;
        uint256 tokenAmount; //token数量
    }

    struct TokenAmount{
        address token;
        uint256 amount;
    }

    event PoolAccepted(address token, address pool);
    event PoolRevoked(address token, address pool);
    event StrategyAdded(address strategy);
    event StrategyRemoved(address strategy);
    event StrategyApproved(address pool, address strategy);
    event StrategyRevoked(address pool, address strategy);
    event Earn(
        address pool,
        address token,
        uint256 amount,
        address strategy
    );
    event Withdraw(address strategy, address pool, address token, uint256 amount);
    event SetWithdrawSettings(address pool);

    function setStrategist(address _strategist) external onlyOwner{
        strategist = _strategist;
    }

    function setPool(address _token, address _pool) external onlyStrategistAndOwner{
        require(!acceptedPools[_token][_pool], "Pool already exists.");
        require(IFundPool(_pool).token() == _token, "Invalid token");
        //TODO 有收益率的pool加到fixedPools，否则加到flexiblePools
        if(IFundPool(_pool).profitRatePerBlock() > 0 && !hasItem(fixedPools, _pool)) fixedPools.push(_pool);
        else flexiblePools.push(_pool);
        acceptedPools[_token][_pool] = true;
        emit PoolAccepted(_token, _pool);
    }

    function revokePool(address _token, address _pool) external onlyStrategistAndOwner {
        require(acceptedPools[_token][_pool], "Invalid pool");
        delete acceptedPools[_token][_pool];
        // if(IFundPool(_pool).getProfitRatePerBlock() > 0) pop(fixedPools, _pool);
        // else pop(flexiblePools, _pool);
        emit PoolRevoked(_token, _pool);
    }

    function addStrategy(address _strategy) external onlyAdmin{
        require(!hasItem(strategies, _strategy), "Already added");
        strategies.push(_strategy);
        emit StrategyAdded(_strategy);
    }

    function removeStrategy(address _strategy) external onlyOwner{
        require(hasItem(strategies, _strategy), "Strategy doesn't exist");
        pop(strategies, _strategy);
        emit StrategyRemoved(_strategy);
    }

    function setStrategy(address _pool, address _strategy) external onlyAdmin{
        require(
            approvedStrategies[_pool][_strategy] == 0,
            "Strategy was already set"
        );
        require(hasItem(strategies, _strategy), "Strategy doesn't exist");
        address token = IFundPool(_pool).token();
        require(acceptedPools[token][_pool], "Invalid pool");
        require(
            hasItem(IStrategy(_strategy).getTokens(), token),
            "Invalid strategy"
        );
        poolStrategies[_pool].push(_strategy);
        approvedStrategies[_pool][_strategy] = poolStrategies[_pool].length;
        emit StrategyApproved(_pool, _strategy);
    }

    function revokeStrategy(address _pool, address _strategy) external onlyOwner{
        require(approvedStrategies[_pool][_strategy] > 0, "Invalid strategy");
        uint256 index = approvedStrategies[_pool][_strategy];
        address[] memory _strategies = poolStrategies[_pool];
        address lastStrategy = _strategies[_strategies.length - 1];
        approvedStrategies[_pool][lastStrategy] = index;
        poolStrategies[_pool][index - 1] = lastStrategy;
        delete poolStrategies[_pool][_strategies.length - 1];
        delete approvedStrategies[_pool][_strategy];
        emit StrategyRevoked(_pool, _strategy);
    }

    function setWithdrawSettings(
        address _pool,
        WithdrawSetting[] memory _settings
    ) external onlyStrategistAndOwner {
        delete withdrawSettings[_pool];
        uint256 length = _settings[0].tokenLimit.length;
        for (uint256 i = 0; i < _settings.length; i++) {
            //require(approvedStrategies[_pool][_settings[i].strategy] > 0 || poolAmountInStrategy[_pool][_settings[i].strategy] > 0, "Invalid strategy");
            require(_settings[i].tokenLimit.length == length, "Invalid limit length");
            withdrawSettings[_pool].push(_settings[i]);
        }
        emit SetWithdrawSettings(_pool);
    }

    function setSVaultNetValue(address _sVaultNetValue) external onlyAdmin{
        sVaultNetValue = _sVaultNetValue;
    }

    //TODO 赎回本金还是USDT,收益用户选择USDT或者挖到的token

    function earn(
        address[] memory _pools,
        uint256[] memory _amounts,
        address _strategy
    ) onlyStrategistAndOwner external {
        address[] memory tokens = IStrategy(_strategy).getTokens();
        uint256[] memory amounts = new uint256[](tokens.length);
        for(uint256 i = 0; i < _pools.length; i++){
            address token = IFundPool(_pools[i]).token();
            takeTokenFromPool(_pools[i], _strategy, token, _amounts[i]);
            for(uint256 j = 0;j < tokens.length; j++){
                if(token == tokens[j]){
                    amounts[j] = amounts[j].add(_amounts[i]);
                    break;
                } 
            }
            emit Earn(_pools[i], token, _amounts[i], _strategy);
        }
        IStrategy(_strategy).earn(tokens, amounts);
    }

    function withdraw(address _strategy, address _pool) external onlyStrategistAndOwner{
        require(msg.sender == strategist || msg.sender == admin, "!strategist");
        address token = IFundPool(_pool).token();
        uint256 amount = IStrategy(_strategy).withdraw(token);
        if(amount == 0) return;
        //subStrategyPoolAmount(_pool, _strategy, amount);
        IFundPool(_pool).returnToken(amount);
        transferOut(token, _pool, amount);
        emit Withdraw(_strategy, _pool, token, amount);
    }

    function withdraw(
        address _strategy,
        uint256 _amount,
        address[] memory _pools
    ) external onlyStrategistAndOwner {
        (address[] memory tokens, uint256[] memory amounts) = IStrategy(_strategy).withdraw(_amount);
        require(tokens.length == _pools.length, "Invalid pool count");
        for(uint256 i = 0; i < _pools.length; i++){
            address token = IFundPool(_pools[i]).token();
            (bool hasItem, uint256 index) = getIndex(tokens, token);
            require(hasItem, "Wrong pool");
            IFundPool(_pools[i]).returnToken(amounts[index]);
            transferOut(token, _pools[i], amounts[index]);
            emit Withdraw(_strategy, _pools[i], token, amounts[index]);
        }
    }

    function getIndex(address[] memory _array, address _item) internal view returns(bool, uint256){
        for(uint256 i = 0; i < _array.length; i++){
            if(_array[i] == _item) return (true,i);
        }
        return (false, 0);
    }

    function withdraw(uint256 _amount, uint256 _profitAmount) external returns (TokenAmount[] memory){
        address token = IFundPool(msg.sender).token();
        require(acceptedPools[token][msg.sender], "Invalid pool");
        WithdrawSetting[] memory settings = withdrawSettings[msg.sender];
        uint256 length = settings[0].tokenLimit.length;
        uint256 totalAmount = _amount;
        uint256 totalProfitAmount = _profitAmount;
        uint256 count = settings.length.mul(3);
        TokenAmount[] memory tokenAmounts = new TokenAmount[](count);
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = 0; j < settings.length; j++) {
                //withdraw totalAmount if limit is 0
                uint256 withdrawAmount = totalAmount <= settings[j].tokenLimit[i] || settings[j].tokenLimit[i] == 0 ? totalAmount : settings[j].tokenLimit[i];
                address[] memory tokens = new address[](1);
                tokens[0] = token;
                (uint256 amount, uint256 profitAmount, address[] memory withdrawTokens, uint256[] memory amounts) = IStrategy(settings[j].strategy).withdraw(tokens, withdrawAmount, totalProfitAmount);
                //TODO 处理成本净值
                if(amount > 0 ) {
                    totalAmount = totalAmount.sub(amount);
                    //subStrategyPoolAmount(msg.sender, settings[j].strategy, amount);
                    emit Withdraw(settings[j].strategy, msg.sender, tokens[0], amount);
                }
                if(profitAmount > 0){
                    totalProfitAmount = totalProfitAmount.sub(profitAmount);
                } 
                AddTokenAmount(tokenAmounts, withdrawTokens, amounts);
                if(totalAmount == 0 && totalProfitAmount == 0) break;
            }
            if(totalAmount == 0 && totalProfitAmount == 0) break;
        }
        if(totalAmount != 0 || totalProfitAmount != 0){
            for (uint256 j = 0; j < settings.length; j++) {
                address[] memory tokens = IStrategy(settings[j].strategy).getTokens();
                if(tokens.length == 1) continue;
                (tokens[0], tokens[1]) = token == tokens[0] ? (tokens[0], tokens[1]) : (tokens[1], tokens[0]);
                (uint256 amount, uint256 profitAmount, address[] memory withdrawTokens, uint256[] memory amounts) = IStrategy(settings[j].strategy).withdraw(tokens, totalAmount, totalProfitAmount);
                //TODO 处理成本净值
                if(amount > 0 ) {
                    totalAmount = totalAmount.sub(amount);
                    //subStrategyPoolAmount(msg.sender, settings[j].strategy, amount);
                    emit Withdraw(settings[j].strategy, msg.sender, tokens[0], amount);
                }
                if(profitAmount > 0){
                    totalProfitAmount = totalProfitAmount.sub(profitAmount);
                } 
                AddTokenAmount(tokenAmounts, withdrawTokens, amounts);
                if(totalAmount == 0 && totalProfitAmount == 0) break;
            }
        }
        require(totalAmount == 0 && totalProfitAmount == 0, "Insufficient balance");
        for(uint256 i = 0; i < tokenAmounts.length; i++){
            if(tokenAmounts[i].token == address(0)) break;
            transferOut(tokenAmounts[i].token, msg.sender, tokenAmounts[i].amount);
        }
        allocatedProfit[msg.sender] = allocatedProfit[msg.sender].sub(_profitAmount);
        return tokenAmounts;
        //币不够用别的币凑，需要把swap接口留着
    }

    function accrueProfit() external returns (SVaultNetValue.NetValue[] memory netValues){
        netValues = SVaultNetValue(sVaultNetValue).getNetValues();
        for(uint256 i = 0; i < flexiblePools.length; i++){
            SVaultNetValue.NetValue memory netValue = getNetValue(netValues, flexiblePools[i]);
            allocatedProfit[flexiblePools[i]] = netValue.totalTokens > netValue.amount ? netValue.totalTokens.sub(netValue.amount) : 0;
        }
    }

    function getNetValue(SVaultNetValue.NetValue[] memory netValues, address pool) internal returns(SVaultNetValue.NetValue memory){
        for(uint i = 0; i < netValues.length; i++){
            if(netValues[i].pool == pool) return netValues[i];
        }
    }

    function getFixedPools() view external returns(address[] memory){
        return fixedPools;
    }

    function getFlexiblePools() view external returns(address[] memory){
        return flexiblePools;
    }

    function getStrategies() view external returns(address[] memory){
        return strategies;
    }

    function getWithdrawSettings(address _pool)
        external
        view
        returns (WithdrawSetting[] memory)
    {
        return withdrawSettings[_pool];
    }

    function takeTokenFromPool(address pool, address strategy, address token, uint256 amount) internal{
        require(amount > 0, "Invalid amount");
        require(approvedStrategies[pool][strategy] > 0, "Invalid pool or strategy");
        IFundPool(pool).take(amount);
        if (token == WETH) IWETH(WETH).deposit{value: amount}();
        //poolAmountInStrategy[_pool][_strategy] = poolAmountInStrategy[_pool][_strategy].add(_amount);
        IERC20(token).safeApprove(strategy, amount);
    }

    function AddTokenAmount(TokenAmount[] memory tokenAmounts, address[] memory tokens, uint256[] memory amounts) view internal{
        for(uint256 i = 0; i < tokens.length; i ++) {
            for(uint256 j = 0; j < tokenAmounts.length; j++){
                if(tokenAmounts[j].token == address(0)){
                    tokenAmounts[j].token = tokens[i];
                    tokenAmounts[j].amount = amounts[i];
                    break;
                }
                if(tokens[i] == tokenAmounts[j].token){
                    tokenAmounts[j].amount = tokenAmounts[j].amount.add(amounts[i]);
                    break;
                }
            }
        }
    }

    // function subStrategyPoolAmount(
    //     address _pool,
    //     address _strategy,
    //     uint256 _amount
    // ) internal {
    //     require(poolAmountInStrategy[_pool][_strategy] >= _amount, "Invalid amount");
    //     poolAmountInStrategy[_pool][_strategy] = poolAmountInStrategy[_pool][_strategy].sub(_amount);
    // }

    function transferOut(address token , address to, uint256 amount) internal {
        if (token == WETH){
            IWETH(WETH).withdraw(amount);
            payable(to).transfer(amount);
        } 
        else{
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function pop(address[] storage _array, address _item) internal {
        for(uint256 i = 0; i < _array.length; i++){
            if(_array[i] != _item) continue;
            _array[i] = _array[_array.length-1];
            _array.pop();
            break;
        }
    }

    function hasItem(address[] memory _array, address _item) internal view returns (bool){
        for(uint256 i = 0; i < _array.length; i++){
            if(_array[i] == _item) return true;
        }
        return false;
    }
}