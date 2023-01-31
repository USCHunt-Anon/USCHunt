// : MIT

pragma solidity ^0.8.0;

//import"../utils/ContextUpgradeable.sol";
//import"../proxy/utils/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


// : MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


// : MIT

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

//import"@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

interface IBagSoccer {
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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   */
  function migrate(address account, uint256 amount) external;

  function isMigrationStarted() external view returns (bool);

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

interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

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

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

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

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
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

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

contract BagSoccer is
  IBagSoccer,
  Initializable,
  ContextUpgradeable,
  OwnableUpgradeable
{
  using SafeMathUpgradeable for uint256;
  using AddressUpgradeable for address;

  struct FeeTier {
    uint256 ecoSystemFee;
    uint256 liquidityFee;
    uint256 taxFee;
    uint256 ownerFee;
    uint256 burnFee;
    address ecoSystem;
    address owner;
  }

  struct FeeValues {
    uint256 rAmount;
    uint256 rTransferAmount;
    uint256 rFee;
    uint256 tTransferAmount;
    uint256 tEchoSystem;
    uint256 tLiquidity;
    uint256 tFee;
    uint256 tOwner;
    uint256 tBurn;
  }

  struct tFeeValues {
    uint256 tTransferAmount;
    uint256 tEchoSystem;
    uint256 tLiquidity;
    uint256 tFee;
    uint256 tOwner;
    uint256 tBurn;
  }

  mapping(address => uint256) private _rOwned;
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;
  mapping(address => bool) private _isExcludedFromFee;
  mapping(address => bool) private _isExcluded;
  mapping(address => bool) private _isBlacklisted;
  mapping(address => uint256) private _accountsTier;

  address[] private _excluded;

  uint256 private constant MAX = ~uint256(0);
  uint256 private _tTotal;
  uint256 private _rTotal;
  uint256 private _tFeeTotal;
  uint256 private _maxFee;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  FeeTier public _defaultFees;
  FeeTier private _previousFees;
  FeeTier private _emptyFees;

  FeeTier[] private feeTiers;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;
  address public WBNB;
  address private migration;
  address private _initializerAccount;
  address public _burnAddress;

  bool inSwapAndLiquify;
  bool public swapAndLiquifyEnabled;

  uint256 public _maxTxAmount;
  uint256 private numTokensSellToAddToLiquidity;

  bool private _upgraded;

  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 bnbReceived,
    uint256 tokensIntoLiquidity
  );

  modifier lockTheSwap() {
    inSwapAndLiquify = true;
    _;
    inSwapAndLiquify = false;
  }

  modifier lockUpgrade() {
    require(!_upgraded, "BagSoccer: Already upgraded");
    _;
    _upgraded = true;
  }

  modifier checkTierIndex(uint256 _index) {
    require(feeTiers.length > _index, "BagSoccer: Invalid tier index");
    _;
  }

  modifier preventBlacklisted(address _account, string memory errorMsg) {
    require(!_isBlacklisted[_account], errorMsg);
    _;
  }

  modifier isRouter(address _sender) {
    {
      uint32 size;
      assembly {
        size := extcodesize(_sender)
      }
      if (size > 0) {
        uint256 senderTier = _accountsTier[_sender];
        if (senderTier == 0) {
          IUniswapV2Router02 _routerCheck = IUniswapV2Router02(_sender);
          try _routerCheck.factory() returns (address factory) {
            _accountsTier[_sender] = 1;
          } catch {}
        }
      }
    }

    _;
  }

  function initialize(address _router) public initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
    __BagSoccer_v2_init_unchained(_router);
  }

  function __BagSoccer_v2_init_unchained(address _router) internal initializer {
    _name = "BagSoccer";
    _symbol = "BAG";
    _decimals = 18;

    _tTotal = 10000000 * 10**18;
    _rTotal = (MAX - (MAX % _tTotal));
    _maxFee = 1000;

    swapAndLiquifyEnabled = true;

    _maxTxAmount = 50000 * 10**18;
    numTokensSellToAddToLiquidity = 500 * 10**18;

    _burnAddress = 0x0000000000000000000000000000000000000000;
    _initializerAccount = _msgSender();

    _rOwned[_initializerAccount] = _rTotal;

    uniswapV2Router = IUniswapV2Router02(_router);
    WBNB = uniswapV2Router.WETH();
    // Create a uniswap pair for this new token
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
      address(this),
      WBNB
    );

    //exclude owner and this contract from fee
    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    //set default
    _defaultFees = _addTier(0, 500, 500, 0, 0, address(0), address(0));

    emit Transfer(address(0), _msgSender(), _tTotal);
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view override returns (uint256) {
    return _tTotal;
  }

  function balanceOf(address account) public view override returns (uint256) {
    if (_isExcluded[account]) return _tOwned[account];
    return tokenFromReflection(_rOwned[account]);
  }

  function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "BEP20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "BEP20: decreased allowance below zero"
      )
    );
    return true;
  }

  function isExcludedFromReward(address account) public view returns (bool) {
    return _isExcluded[account];
  }

  function totalFees() public view returns (uint256) {
    return _tFeeTotal;
  }

  function reflectionFromTokenInTiers(
    uint256 tAmount,
    uint256 _tierIndex,
    bool deductTransferFee
  ) public view returns (uint256) {
    require(tAmount <= _tTotal, "Amount must be less than supply");
    if (!deductTransferFee) {
      FeeValues memory _values = _getValues(tAmount, _tierIndex);
      return _values.rAmount;
    } else {
      FeeValues memory _values = _getValues(tAmount, _tierIndex);
      return _values.rTransferAmount;
    }
  }

  function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
    public
    view
    returns (uint256)
  {
    return reflectionFromTokenInTiers(tAmount, 0, deductTransferFee);
  }

  function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
    require(rAmount <= _rTotal, "Amount must be less than total reflections");
    uint256 currentRate = _getRate();
    return rAmount.div(currentRate);
  }

  function excludeFromReward(address account) public onlyOwner {
    require(!_isExcluded[account], "Account is already excluded");
    if (_rOwned[account] > 0) {
      _tOwned[account] = tokenFromReflection(_rOwned[account]);
    }
    _isExcluded[account] = true;
    _excluded.push(account);
  }

  function includeInReward(address account) external onlyOwner {
    require(_isExcluded[account], "Account is already included");
    for (uint256 i = 0; i < _excluded.length; i++) {
      if (_excluded[i] == account) {
        _excluded[i] = _excluded[_excluded.length - 1];
        _tOwned[account] = 0;
        _isExcluded[account] = false;
        _excluded.pop();
        break;
      }
    }
  }

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function whitelistAddress(address _account, uint256 _tierIndex)
    public
    onlyOwner
    checkTierIndex(_tierIndex)
    preventBlacklisted(_account, "BagSoccer: Selected account is in blacklist")
  {
    require(_account != address(0), "BagSoccer: Invalid address");
    _accountsTier[_account] = _tierIndex;
  }

  function excludeWhitelistedAddress(address _account) public onlyOwner {
    require(_account != address(0), "BagSoccer: Invalid address");
    require(
      _accountsTier[_account] > 0,
      "BagSoccer: Account is not in whitelist"
    );
    _accountsTier[_account] = 0;
  }

  function accountTier(address _account) public view returns (FeeTier memory) {
    return feeTiers[_accountsTier[_account]];
  }

  function isWhitelisted(address _account) public view returns (bool) {
    return _accountsTier[_account] > 0;
  }

  function checkFees(FeeTier memory _tier)
    internal
    view
    returns (FeeTier memory)
  {
    uint256 _fees = _tier
      .ecoSystemFee
      .add(_tier.liquidityFee)
      .add(_tier.taxFee)
      .add(_tier.ownerFee)
      .add(_tier.burnFee);
    require(_fees <= _maxFee, "BagSoccer: Fees exceeded max limitation");

    return _tier;
  }

  function checkFeesChanged(
    FeeTier memory _tier,
    uint256 _oldFee,
    uint256 _newFee
  ) internal view {
    uint256 _fees = _tier
      .ecoSystemFee
      .add(_tier.liquidityFee)
      .add(_tier.taxFee)
      .add(_tier.ownerFee)
      .add(_tier.burnFee)
      .sub(_oldFee)
      .add(_newFee);

    require(_fees <= _maxFee, "BagSoccer: Fees exceeded max limitation");
  }

  function setEcoSystemFeePercent(uint256 _tierIndex, uint256 _ecoSystemFee)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    checkFeesChanged(tier, tier.ecoSystemFee, _ecoSystemFee);
    feeTiers[_tierIndex].ecoSystemFee = _ecoSystemFee;
    if (_tierIndex == 0) {
      _defaultFees.ecoSystemFee = _ecoSystemFee;
    }
  }

  function setLiquidityFeePercent(uint256 _tierIndex, uint256 _liquidityFee)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    checkFeesChanged(tier, tier.liquidityFee, _liquidityFee);
    feeTiers[_tierIndex].liquidityFee = _liquidityFee;
    if (_tierIndex == 0) {
      _defaultFees.liquidityFee = _liquidityFee;
    }
  }

  function setTaxFeePercent(uint256 _tierIndex, uint256 _taxFee)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    checkFeesChanged(tier, tier.taxFee, _taxFee);
    feeTiers[_tierIndex].taxFee = _taxFee;
    if (_tierIndex == 0) {
      _defaultFees.taxFee = _taxFee;
    }
  }

  function setOwnerFeePercent(uint256 _tierIndex, uint256 _ownerFee)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    checkFeesChanged(tier, tier.ownerFee, _ownerFee);
    feeTiers[_tierIndex].ownerFee = _ownerFee;
    if (_tierIndex == 0) {
      _defaultFees.ownerFee = _ownerFee;
    }
  }

  function setBurnFeePercent(uint256 _tierIndex, uint256 _burnFee)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    checkFeesChanged(tier, tier.burnFee, _burnFee);
    feeTiers[_tierIndex].burnFee = _burnFee;
    if (_tierIndex == 0) {
      _defaultFees.burnFee = _burnFee;
    }
  }

  function setEcoSystemFeeAddress(uint256 _tierIndex, address _ecoSystem)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    require(_ecoSystem != address(0), "BagSoccer: Address Zero is not allowed");
    if (!_isExcluded[_ecoSystem]) {
      excludeFromReward(_ecoSystem);
    }

    feeTiers[_tierIndex].ecoSystem = _ecoSystem;
    if (_tierIndex == 0) {
      _defaultFees.ecoSystem = _ecoSystem;
    }
  }

  function setOwnerFeeAddress(uint256 _tierIndex, address _owner)
    external
    onlyOwner
    checkTierIndex(_tierIndex)
  {
    require(_owner != address(0), "BagSoccer: Address Zero is not allowed");
    if (!_isExcluded[_owner]) {
      excludeFromReward(_owner);
    }
    feeTiers[_tierIndex].owner = _owner;
    if (_tierIndex == 0) {
      _defaultFees.owner = _owner;
    }
  }

  function addTier(
    uint256 _ecoSystemFee,
    uint256 _liquidityFee,
    uint256 _taxFee,
    uint256 _ownerFee,
    uint256 _burnFee,
    address _ecoSystem,
    address _owner
  ) public onlyOwner {
    _addTier(
      _ecoSystemFee,
      _liquidityFee,
      _taxFee,
      _ownerFee,
      _burnFee,
      _ecoSystem,
      _owner
    );
  }

  function _addTier(
    uint256 _ecoSystemFee,
    uint256 _liquidityFee,
    uint256 _taxFee,
    uint256 _ownerFee,
    uint256 _burnFee,
    address _ecoSystem,
    address _owner
  ) internal returns (FeeTier memory) {
    FeeTier memory _newTier = checkFees(
      FeeTier(
        _ecoSystemFee,
        _liquidityFee,
        _taxFee,
        _ownerFee,
        _burnFee,
        _ecoSystem,
        _owner
      )
    );
    if (!_isExcluded[_ecoSystem]) {
      excludeFromReward(_ecoSystem);
    }
    if (!_isExcluded[_owner]) {
      excludeFromReward(_owner);
    }
    feeTiers.push(_newTier);

    return _newTier;
  }

  function feeTier(uint256 _tierIndex)
    public
    view
    checkTierIndex(_tierIndex)
    returns (FeeTier memory)
  {
    return feeTiers[_tierIndex];
  }

  function blacklistAddress(address account) public onlyOwner {
    _isBlacklisted[account] = true;
    _accountsTier[account] = 0;
  }

  function unBlacklistAddress(address account) public onlyOwner {
    _isBlacklisted[account] = false;
  }

  function updateRouterAndPair(address _uniswapV2Router, address _uniswapV2Pair)
    public
    onlyOwner
  {
    uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
    uniswapV2Pair = _uniswapV2Pair;
    WBNB = uniswapV2Router.WETH();
  }

  function setDefaultSettings() external onlyOwner {
    swapAndLiquifyEnabled = true;
  }

  function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
    _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**4);
  }

  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    swapAndLiquifyEnabled = _enabled;
    emit SwapAndLiquifyEnabledUpdated(_enabled);
  }

  //to receive BNB from uniswapV2Router when swapping
  receive() external payable {}

  function _reflectFee(uint256 rFee, uint256 tFee) private {
    _rTotal = _rTotal.sub(rFee);
    _tFeeTotal = _tFeeTotal.add(tFee);
  }

  function _getValues(uint256 tAmount, uint256 _tierIndex)
    private
    view
    returns (FeeValues memory)
  {
    tFeeValues memory tValues = _getTValues(tAmount, _tierIndex);
    uint256 tTransferFee = tValues
      .tLiquidity
      .add(tValues.tEchoSystem)
      .add(tValues.tOwner)
      .add(tValues.tBurn);
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
      tAmount,
      tValues.tFee,
      tTransferFee,
      _getRate()
    );
    return
      FeeValues(
        rAmount,
        rTransferAmount,
        rFee,
        tValues.tTransferAmount,
        tValues.tEchoSystem,
        tValues.tLiquidity,
        tValues.tFee,
        tValues.tOwner,
        tValues.tBurn
      );
  }

  function _getTValues(uint256 tAmount, uint256 _tierIndex)
    private
    view
    returns (tFeeValues memory)
  {
    FeeTier memory tier = feeTiers[_tierIndex];
    tFeeValues memory tValues = tFeeValues(
      0,
      calculateFee(tAmount, tier.ecoSystemFee),
      calculateFee(tAmount, tier.liquidityFee),
      calculateFee(tAmount, tier.taxFee),
      calculateFee(tAmount, tier.ownerFee),
      calculateFee(tAmount, tier.burnFee)
    );

    tValues.tTransferAmount = tAmount
      .sub(tValues.tEchoSystem)
      .sub(tValues.tFee)
      .sub(tValues.tLiquidity)
      .sub(tValues.tOwner)
      .sub(tValues.tBurn);
    return tValues;
  }

  function _getRValues(
    uint256 tAmount,
    uint256 tFee,
    uint256 tTransferFee,
    uint256 currentRate
  )
    private
    pure
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 rAmount = tAmount.mul(currentRate);
    uint256 rFee = tFee.mul(currentRate);
    uint256 rTransferFee = tTransferFee.mul(currentRate);
    uint256 rTransferAmount = rAmount.sub(rFee).sub(rTransferFee);
    return (rAmount, rTransferAmount, rFee);
  }

  function _getRate() private view returns (uint256) {
    (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
    return rSupply.div(tSupply);
  }

  function _getCurrentSupply() private view returns (uint256, uint256) {
    uint256 rSupply = _rTotal;
    uint256 tSupply = _tTotal;
    for (uint256 i = 0; i < _excluded.length; i++) {
      if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
        return (_rTotal, _tTotal);
      rSupply = rSupply.sub(_rOwned[_excluded[i]]);
      tSupply = tSupply.sub(_tOwned[_excluded[i]]);
    }
    if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
    return (rSupply, tSupply);
  }

  function calculateFee(uint256 _amount, uint256 _fee)
    private
    pure
    returns (uint256)
  {
    if (_fee == 0) return 0;
    return _amount.mul(_fee).div(10**4); //this line, takes 10.000 as base and calculates the fee doing the following division: i.e liquidity fee its 500, fee = 500 / 10.000
  }

  function removeAllFee() private {
    _previousFees = feeTiers[0];
    feeTiers[0] = _emptyFees;
  }

  function restoreAllFee() private {
    feeTiers[0] = _previousFees;
  }

  function isExcludedFromFee(address account) public view returns (bool) {
    return _isExcludedFromFee[account];
  }

  function isBlacklisted(address account) public view returns (bool) {
    return _isBlacklisted[account];
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  )
    private
    preventBlacklisted(owner, "BagSoccer: Owner address is blacklisted")
    preventBlacklisted(spender, "BagSoccer: Spender address is blacklisted")
  {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  )
    private
    preventBlacklisted(_msgSender(), "BagSoccer: Address is blacklisted")
    preventBlacklisted(from, "BagSoccer: From address is blacklisted")
    preventBlacklisted(to, "BagSoccer: To address is blacklisted")
    isRouter(_msgSender())
  {
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");

    if (from != owner() && to != owner())
      require(
        amount <= _maxTxAmount,
        "Transfer amount exceeds the maxTxAmount."
      );

    // is the token balance of this contract address over the min number of
    // tokens that we need to initiate a swap + liquidity lock?
    // also, don't get caught in a circular liquidity event.
    // also, don't swap & liquify if sender is uniswap pair.
    uint256 contractTokenBalance = balanceOf(address(this));

    if (contractTokenBalance >= _maxTxAmount) {
      contractTokenBalance = _maxTxAmount;
    }

    bool overMinTokenBalance = contractTokenBalance >=
      numTokensSellToAddToLiquidity;
    if (
      overMinTokenBalance &&
      !inSwapAndLiquify &&
      from != uniswapV2Pair &&
      swapAndLiquifyEnabled
    ) {
      contractTokenBalance = numTokensSellToAddToLiquidity;
      //add liquidity
      swapAndLiquify(contractTokenBalance);
    }

    //indicates if fee should be deducted from transfer
    bool takeFee = true;

    //if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
      takeFee = false;
    }

    uint256 tierIndex = 0;

    if (takeFee) {
      tierIndex = _accountsTier[from];

      if (_msgSender() != from) {
        tierIndex = _accountsTier[_msgSender()];
      }
    }

    //transfer amount, it will take tax, burn, liquidity fee
    _tokenTransfer(from, to, amount, tierIndex, takeFee);
  }

  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    // split the contract balance into halves
    uint256 half = contractTokenBalance.div(2);
    uint256 otherHalf = contractTokenBalance.sub(half);

    // capture the contract's current BNB balance.
    // this is so that we can capture exactly the amount of BNB that the
    // swap creates, and not make the liquidity event include any BNB that
    // has been manually sent to the contract
    uint256 initialBalance = address(this).balance;

    // swap tokens for BNB
    swapTokensForBnb(half);

    // how much BNB did we just swap into?
    uint256 newBalance = address(this).balance.sub(initialBalance);

    // add liquidity to uniswap
    addLiquidity(otherHalf, newBalance);

    emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  function swapTokensForBnb(uint256 tokenAmount) private {
    // generate the uniswap pair path of token -> wbnb
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // make the swap
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of BNB
      path,
      address(this),
      block.timestamp
    );
  }

  function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
    // approve token transfer to cover all possible scenarios
    _approve(address(this), address(uniswapV2Router), tokenAmount);

    // add the liquidity
    uniswapV2Router.addLiquidityETH{value: bnbAmount}(
      address(this),
      tokenAmount,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      owner(),
      block.timestamp
    );
  }

  //this method is responsible for taking all fee, if takeFee is true
  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 amount,
    uint256 tierIndex,
    bool takeFee
  ) private {
    if (!takeFee) removeAllFee();

    if (_isExcluded[sender] && !_isExcluded[recipient]) {
      _transferFromExcluded(sender, recipient, amount, tierIndex);
    } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
      _transferToExcluded(sender, recipient, amount, tierIndex);
    } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
      _transferStandard(sender, recipient, amount, tierIndex);
    } else if (_isExcluded[sender] && _isExcluded[recipient]) {
      _transferBothExcluded(sender, recipient, amount, tierIndex);
    } else {
      _transferStandard(sender, recipient, amount, tierIndex);
    }

    if (!takeFee) restoreAllFee();
  }

  function _transferBothExcluded(
    address sender,
    address recipient,
    uint256 tAmount,
    uint256 tierIndex
  ) private {
    FeeValues memory _values = _getValues(tAmount, tierIndex);
    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
    _takeFees(sender, _values, tierIndex);
    _reflectFee(_values.rFee, _values.tFee);
    emit Transfer(sender, recipient, _values.tTransferAmount);
  }

  function _transferStandard(
    address sender,
    address recipient,
    uint256 tAmount,
    uint256 tierIndex
  ) private {
    FeeValues memory _values = _getValues(tAmount, tierIndex);
    _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
    _takeFees(sender, _values, tierIndex);
    _reflectFee(_values.rFee, _values.tFee);
    emit Transfer(sender, recipient, _values.tTransferAmount);
  }

  function _transferToExcluded(
    address sender,
    address recipient,
    uint256 tAmount,
    uint256 tierIndex
  ) private {
    FeeValues memory _values = _getValues(tAmount, tierIndex);
    _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(_values.tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
    _takeFees(sender, _values, tierIndex);
    _reflectFee(_values.rFee, _values.tFee);
    emit Transfer(sender, recipient, _values.tTransferAmount);
  }

  function _transferFromExcluded(
    address sender,
    address recipient,
    uint256 tAmount,
    uint256 tierIndex
  ) private {
    FeeValues memory _values = _getValues(tAmount, tierIndex);
    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(_values.rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(_values.rTransferAmount);
    _takeFees(sender, _values, tierIndex);
    _reflectFee(_values.rFee, _values.tFee);
    emit Transfer(sender, recipient, _values.tTransferAmount);
  }

  function _takeFees(
    address sender,
    FeeValues memory values,
    uint256 tierIndex
  ) private {
    _takeFee(sender, values.tLiquidity, address(this));
    _takeFee(sender, values.tEchoSystem, feeTiers[tierIndex].ecoSystem);
    _takeFee(sender, values.tOwner, feeTiers[tierIndex].owner);
    _takeBurn(sender, values.tBurn);
  }

  function _takeFee(
    address sender,
    uint256 tAmount,
    address recipient
  ) private {
    if (recipient == address(0)) return;
    if (tAmount == 0) return;

    uint256 currentRate = _getRate();
    uint256 rAmount = tAmount.mul(currentRate);
    _rOwned[recipient] = _rOwned[recipient].add(rAmount);
    if (_isExcluded[recipient])
      _tOwned[recipient] = _tOwned[recipient].add(tAmount);

    emit Transfer(sender, recipient, tAmount);
  }

  function _takeBurn(address sender, uint256 _amount) private {
    if (_amount == 0) return;
    _tOwned[_burnAddress] = _tOwned[_burnAddress].add(_amount);

    emit Transfer(sender, _burnAddress, _amount);
  }

  function setMigrationAddress(address _migration) public onlyOwner {
    migration = _migration;
  }

  function isMigrationStarted() external view override returns (bool) {
    return migration != address(0);
  }

  function migrate(address account, uint256 amount)
    external
    override
    preventBlacklisted(account, "BagSoccer: Migrated account is blacklisted")
  {
    require(migration != address(0), "BagSoccer: Migration is not started");
    require(_msgSender() == migration, "BagSoccer: Not Allowed");
    _migrate(account, amount);
  }

  function _migrate(address account, uint256 amount) private {
    require(account != address(0), "BEP20: mint to the zero address");

    _tokenTransfer(_initializerAccount, account, amount, 0, false);
  }

  function feeTiersLength() public view returns (uint256) {
    return feeTiers.length;
  }

  function updateBurnAddress(address _newBurnAddress) external onlyOwner {
    _burnAddress = _newBurnAddress;
    if (!_isExcluded[_newBurnAddress]) {
      excludeFromReward(_newBurnAddress);
    }
  }
}


