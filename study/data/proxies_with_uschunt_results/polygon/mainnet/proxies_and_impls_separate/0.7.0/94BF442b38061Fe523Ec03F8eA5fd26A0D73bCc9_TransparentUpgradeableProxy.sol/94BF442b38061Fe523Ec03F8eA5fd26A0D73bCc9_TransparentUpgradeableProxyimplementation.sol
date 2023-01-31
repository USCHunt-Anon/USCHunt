// : MIT

pragma solidity ^0.7.6;

interface IUChildERC20 {
  function withdraw(uint256 amount) external;
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

//import"./Layer1ACRVProxy.sol";
//import"../interfaces/IPolygonRootChainManager.sol";

/// @notice The implementation of Layer1ACRVProxy for Polygon
///   + bridge aCRV using Multichain (Previously Anyswap)
///   + bridge CRV using Polygon Bridge.
/// @dev The address of this contract should be the same as corresponding Layer2Depositor.
contract PolygonACRVProxy is Layer1ACRVProxy {
  using SafeERC20 for IERC20;

  event ExitFromBridge(uint256 _amount);

  /// @dev The address of Polygon (Matic): Bridge in Ethereum.
  address private constant POLYGON_BRIDGE = 0xA0c68C638235ee32657e8f720a23ceC1bFc77C77;

  /// @dev The address of Polygon (Matic): ERC20 Bridge in Ethereum.
  address private constant POLYGON_ERC20_BRIDGE = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;

  /********************************** Mutated Functions **********************************/

  /// @notice Withdraw CRV from Polygon Bridge.
  /// @param _inputData The calldata pass to Polygon Bridge.
  function exitFromBridge(bytes calldata _inputData) external onlyAnyCallProxy {
    uint256 _before = IERC20(CRV).balanceOf(address(this));
    IPolygonRootChainManager(POLYGON_BRIDGE).exit(_inputData);
    uint256 _after = IERC20(CRV).balanceOf(address(this));

    emit ExitFromBridge(_after - _before);
  }

  /********************************** Internal Functions **********************************/

  /// @dev See {CrossChainCallBase-_bridgeCRV}
  function _bridgeCRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    override
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {
    // solhint-disable-next-line reason-string
    require(_recipient == address(this), "PolygonACRVProxy: only bridge to self");

    IERC20(CRV).safeApprove(POLYGON_ERC20_BRIDGE, 0);
    IERC20(CRV).safeApprove(POLYGON_ERC20_BRIDGE, _totalAmount);

    bytes memory _depositData = abi.encode(_totalAmount);
    IPolygonRootChainManager(POLYGON_BRIDGE).depositFor(_recipient, CRV, _depositData);

    _bridgeAmount = _totalAmount;
    _totalFee = 0;
  }
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/proxy/Initializable.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

//import"./Layer2CRVDepositorBase.sol";

//import"../interfaces/IAnyswapRouter.sol";

contract Layer2CRVDepositor is Initializable, Layer2CRVDepositorBase {
  using SafeERC20 for IERC20;

  event UpdateAnyswapRouter(address indexed _anyswapRouter);

  struct CrossChainInfo {
    // The cross chain fee percentage.
    uint32 feePercentage;
    // The minimum amount of token to pay as cross chain fee.
    uint112 minCrossChainFee;
    // The maximum amount of token to pay as cross chain fee.
    uint112 maxCrossChainFee;
    // The minimum amount of token allowed to cross chain.
    uint128 minCrossChainAmount;
    // The maximum amount of token allowed to cross chain.
    uint128 maxCrossChainAmount;
  }

  /// @notice The address of AnyswapRouter.
  address public anyswapRouter;

  /// @notice aCRV cross chain info.
  CrossChainInfo public aCRVCrossChainInfo;

  /// @notice  CRV cross chain info.
  // solhint-disable-next-line var-name-mixedcase
  CrossChainInfo public CRVCrossChainInfo;

  function initialize(
    address _anyCallProxy,
    address _anyswapRouter,
    address _crossChainCallProxy,
    address _owner,
    address _crv,
    address _acrv,
    address _layer1Proxy
  ) external initializer {
    Layer2CRVDepositorBase._initialize(_anyCallProxy, _crossChainCallProxy, _owner, _crv, _acrv, _layer1Proxy);
    // solhint-disable-next-line reason-string
    require(_anyswapRouter != address(0), "Layer2CRVDepositor: zero address");

    anyswapRouter = _anyswapRouter;
  }

  /********************************** Restricted Functions **********************************/

  /// @notice Update CrossChainInfo for ACRV or CRV.
  /// @param _token The address of token to update.
  /// @param _info The CrossChainInfo to update.
  function updateCrossChainInfo(address _token, CrossChainInfo memory _info) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_token == acrv || _token == crv, "Layer2CRVDepositor: invalid token");
    // solhint-disable-next-line reason-string
    require(_info.feePercentage <= FEE_DENOMINATOR, "Layer2CRVDepositor: fee percentage too large");
    // solhint-disable-next-line reason-string
    require(_info.minCrossChainFee <= _info.maxCrossChainFee, "Layer2CRVDepositor: invalid cross chain fee");
    // solhint-disable-next-line reason-string
    require(_info.minCrossChainAmount <= _info.maxCrossChainAmount, "Layer2CRVDepositor: invalid cross chain amount");

    if (_token == acrv) {
      aCRVCrossChainInfo = _info;
    } else {
      CRVCrossChainInfo = _info;
    }
  }

  /// @notice Update AnyswapRouter contract.
  /// @param _anyswapRouter The address to update.
  function updateAnyswapRouter(address _anyswapRouter) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_anyswapRouter != address(0), "Layer2CRVDepositor: zero address");

    anyswapRouter = _anyswapRouter;

    emit UpdateAnyswapRouter(_anyswapRouter);
  }

  /********************************** Internal Functions **********************************/

  /// @dev See {CrossChainCallBase-_bridgeACRV}
  function _bridgeACRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    override
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {
    (_bridgeAmount, _totalFee) = _bridgeWithAnyswapRouter(acrv, _recipient, _totalAmount, aCRVCrossChainInfo);
  }

  /// @dev See {Layer2CRVDepositorBase-_customFallback}
  function _customFallback(address, bytes memory) internal virtual override {
    // no custom fallback is allowed
    // solhint-disable-next-line reason-string
    revert("Layer2CRVDepositor: invalid fallback call");
  }

  /// @dev Internal function to bridge some token to Layer 1.
  /// @param _token The address of the token to bridge.
  /// @param _recipient The address of recipient will receive the token.
  /// @param _totalAmount The total amount of token to bridge.
  /// @return _bridgeAmount The total amount of token bridged, fees are included.
  /// @return _totalFee The total amount of token fee charged by Bridge.
  function _bridgeWithAnyswapRouter(
    address _token,
    address _recipient,
    uint256 _totalAmount,
    CrossChainInfo memory _info
  ) internal returns (uint256 _bridgeAmount, uint256 _totalFee) {
    // solhint-disable-next-line reason-string
    require(_totalAmount >= _info.minCrossChainAmount, "Layer2CRVDepositor: insufficient cross chain amount");

    address _anyswapRouter = anyswapRouter;
    _bridgeAmount = _totalAmount;

    // batch swap in case the amount is too large for single cross chain.
    while (_bridgeAmount > 0 && _bridgeAmount >= _info.minCrossChainAmount) {
      uint256 _amount = _info.maxCrossChainAmount;
      if (_amount > _bridgeAmount) _amount = _bridgeAmount;
      IAnyswapRouter(_anyswapRouter).anySwapOut(_token, _recipient, _amount, 1);

      _totalFee += _computeBridgeFee(_amount, _info); // addition is safe
      _bridgeAmount -= _amount; // subtraction is safe
    }

    _bridgeAmount = _totalAmount - _bridgeAmount; // subtraction is safe
  }

  function _computeBridgeFee(uint256 _amount, CrossChainInfo memory _info) internal view virtual returns (uint256) {
    uint256 _fee = (_amount * _info.feePercentage) / FEE_DENOMINATOR; // multiplication is safe
    if (_fee < _info.minCrossChainFee) _fee = _info.minCrossChainFee;
    if (_fee > _info.maxCrossChainFee) _fee = _info.maxCrossChainFee;
    return _fee;
  }
}


// : MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/proxy/Initializable.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

//import"./Layer1ACRVProxyBase.sol";

//import"../interfaces/IAnyswapRouter.sol";

/// @dev The default implementation of Layer1ACRVProxy,
///      bridge aCRV using Multichain (Previously Anyswap).
contract Layer1ACRVProxy is Initializable, Layer1ACRVProxyBase {
  using SafeERC20 for IERC20;

  event UpdateAnyswapRouter(address indexed _anyswapRouter);

  struct CrossChainInfo {
    // The cross chain fee percentage.
    uint32 feePercentage;
    // The minimum amount of token to pay as cross chain fee.
    uint112 minCrossChainFee;
    // The maximum amount of token to pay as cross chain fee.
    uint112 maxCrossChainFee;
    // The minimum amount of token allowed to cross chain.
    uint128 minCrossChainAmount;
    // The maximum amount of token allowed to cross chain.
    uint128 maxCrossChainAmount;
  }

  /// @notice The address of AnyswapRouter.
  address public anyswapRouter;

  /// @notice aCRV cross chain info.
  CrossChainInfo public aCRVCrossChainInfo;

  /// @notice  CRV cross chain info.
  // solhint-disable-next-line var-name-mixedcase
  CrossChainInfo public CRVCrossChainInfo;

  function initialize(
    uint256 _targetChain,
    address _anyCallProxy,
    address _anyswapRouter,
    address _crossChainCallProxy,
    address _owner
  ) external initializer {
    Layer1ACRVProxyBase._initialize(_targetChain, _anyCallProxy, _crossChainCallProxy, _owner);
    // solhint-disable-next-line reason-string
    require(_anyswapRouter != address(0), "Layer1ACRVProxy: zero address");

    anyswapRouter = _anyswapRouter;
  }

  /********************************** Restricted Functions **********************************/

  /// @notice Update CrossChainInfo for ACRV or CRV.
  /// @param _token The address of token to update.
  /// @param _info The CrossChainInfo to update.
  function updateCrossChainInfo(address _token, CrossChainInfo memory _info) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_token == ACRV || _token == CRV, "Layer1ACRVProxy: invalid token");
    // solhint-disable-next-line reason-string
    require(_info.feePercentage <= FEE_DENOMINATOR, "Layer1ACRVProxy: fee percentage too large");
    // solhint-disable-next-line reason-string
    require(_info.minCrossChainFee <= _info.maxCrossChainFee, "Layer1ACRVProxy: invalid cross chain fee");
    // solhint-disable-next-line reason-string
    require(_info.minCrossChainAmount <= _info.maxCrossChainAmount, "Layer1ACRVProxy: invalid cross chain amount");

    if (_token == ACRV) {
      aCRVCrossChainInfo = _info;
    } else {
      CRVCrossChainInfo = _info;
    }
  }

  /// @notice Update AnyswapRouter contract.
  /// @param _anyswapRouter The address to update.
  function updateAnyswapRouter(address _anyswapRouter) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_anyswapRouter != address(0), "Layer1ACRVProxy: zero address");

    anyswapRouter = _anyswapRouter;

    emit UpdateAnyswapRouter(_anyswapRouter);
  }

  /********************************** Internal Functions **********************************/

  /// @dev See {CrossChainCallBase-_bridgeACRV}
  function _bridgeACRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    override
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {
    (_bridgeAmount, _totalFee) = _bridgeWithAnyswapRouter(ANY_ACRV, ACRV, _recipient, _totalAmount, aCRVCrossChainInfo);
  }

  /// @dev See {CrossChainCallBase-_bridgeCRV}
  function _bridgeCRV(address, uint256) internal virtual override returns (uint256, uint256) {
    revert("bridge CRV unsupported");
  }

  /// @dev Internal function to bridge some token to target chain.
  /// @param _token The address of the token to bridge.
  /// @param _recipient The address of recipient will receive the token.
  /// @param _totalAmount The total amount of token to bridge.
  /// @return _bridgeAmount The total amount of token bridged, fees are included.
  /// @return _totalFee The total amount of token fee charged by Bridge.
  function _bridgeWithAnyswapRouter(
    address _token,
    address _underlying,
    address _recipient,
    uint256 _totalAmount,
    CrossChainInfo memory _info
  ) internal returns (uint256 _bridgeAmount, uint256 _totalFee) {
    // solhint-disable-next-line reason-string
    require(_totalAmount >= _info.minCrossChainAmount, "Layer1ACRVProxy: insufficient cross chain amount");

    address _anyswapRouter = anyswapRouter;
    IERC20(_underlying).safeApprove(_anyswapRouter, 0);
    IERC20(_underlying).safeApprove(_anyswapRouter, _totalAmount);

    uint256 _targetChain = targetChain;
    _bridgeAmount = _totalAmount;
    // batch swap in case the amount is too large for single cross chain.
    while (_bridgeAmount > 0 && _bridgeAmount >= _info.minCrossChainAmount) {
      uint256 _amount = _info.maxCrossChainAmount;
      if (_amount > _bridgeAmount) _amount = _bridgeAmount;
      IAnyswapRouter(_anyswapRouter).anySwapOutUnderlying(_token, _recipient, _amount, _targetChain);

      _totalFee += _computeBridgeFee(_amount, _info); // addition is safe
      _bridgeAmount -= _amount; // subtraction is safe
    }

    _bridgeAmount = _totalAmount - _bridgeAmount; // subtraction is safe
  }

  function _computeBridgeFee(uint256 _amount, CrossChainInfo memory _info) internal view virtual returns (uint256) {
    uint256 _fee = (_amount * _info.feePercentage) / FEE_DENOMINATOR; // multiplication is safe
    if (_fee < _info.minCrossChainFee) _fee = _info.minCrossChainFee;
    if (_fee > _info.maxCrossChainFee) _fee = _info.maxCrossChainFee;
    return _fee;
  }
}


// : MIT

pragma solidity ^0.7.6;

interface IPolygonRootChainManager {
  function depositFor(
    address user,
    address rootToken,
    bytes calldata depositData
  ) external;

  function exit(bytes calldata inputData) external;
}


// : MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

//import"../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

//import"../CrossChainCallBase.sol";
//import"../../misc/Multicall.sol";

//import"../../interfaces/IAladdinCRV.sol";
//import"../interfaces/ICrossChainCallProxy.sol";
//import"../interfaces/ILayer2CRVDepositor.sol";
//import"../interfaces/ILayer1ACRVProxy.sol";

// solhint-disable no-empty-blocks
abstract contract Layer1ACRVProxyBase is CrossChainCallBase, Multicall, ILayer1ACRVProxy {
  using SafeERC20 for IERC20;

  event Deposit(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _crvAmount,
    uint256 _acrvAmount,
    uint256 _acrvFee
  );

  event Redeem(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _acrvAmount,
    uint256 _crvAmount,
    uint256 _crvFee
  );

  /// @dev The denominator used to calculate cross chain fee.
  uint256 internal constant FEE_DENOMINATOR = 1e9;
  /// @dev The address of AladdinCRV contract.
  address internal constant ACRV = 0x2b95A1Dcc3D405535f9ed33c219ab38E8d7e0884;
  /// @dev The address of Anyswap AladdinCRV contract.
  address internal constant ANY_ACRV = 0x85009bcA4cd4C8F554c3C9a1c2f778Ec3Ce7fEb1;
  /// @dev The address of CRV.
  address internal constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

  /// @notice The target chain id to interact.
  uint256 public targetChain;

  function _initialize(
    uint256 _targetChain,
    address _anyCallProxy,
    address _crossChainCallProxy,
    address _owner
  ) internal {
    // solhint-disable-next-line reason-string
    require(_targetChain != _getChainId(), "Layer1ACRVProxy: invalid target chain");

    CrossChainCallBase._initialize(_anyCallProxy, _crossChainCallProxy, _owner);

    targetChain = _targetChain;
  }

  /********************************** Mutated Functions **********************************/

  /// @notice See {ILayer1ACRVProxy-deposit}
  function deposit(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _crvAmount,
    address _callback
  ) external virtual override onlyAnyCallProxy {
    // do nothing, when amount is zero.
    // solhint-disable-next-line reason-string
    require(_crvAmount > 0, "Layer1ACRVProxy: deposit zero amount");
    // solhint-disable-next-line reason-string
    require(_targetChain == targetChain, "Layer1ACRVProxy: target chain mismatch");

    {
      uint256 _balance = IERC20(CRV).balanceOf(address(this));
      // solhint-disable-next-line reason-string
      require(_balance > 0, "Layer1ACRVProxy: insufficient CRV to deposit");
      // in case that the fee calculation in layer2 is wrong.
      if (_balance < _crvAmount) {
        _crvAmount = _balance;
      }
    }

    // 1. deposit CRV to aCRV
    IERC20(CRV).safeApprove(ACRV, 0);
    IERC20(CRV).safeApprove(ACRV, _crvAmount);
    IAladdinCRV(ACRV).depositWithCRV(address(this), _crvAmount);

    // 2. send aCRV to source chain
    (uint256 _bridgeAmount, uint256 _totalFee) = _bridgeACRV(
      _recipient,
      // use aCRV balance, in case some dust aCRV left in last deposit.
      IERC20(ACRV).balanceOf(address(this))
    );

    // 3. cross chain call to notify
    if (_callback != address(0)) {
      bytes memory _data = abi.encodeWithSelector(
        ILayer2CRVDepositor.finalizeDeposit.selector,
        _executionId,
        _crvAmount,
        _bridgeAmount,
        _totalFee
      );
      ICrossChainCallProxy(crossChainCallProxy).crossChainCall(_callback, _data, address(0), _targetChain);
    }

    emit Deposit(_executionId, _targetChain, _recipient, _crvAmount, _bridgeAmount, _totalFee);
  }

  /// @notice See {ILayer1ACRVProxy-redeem}
  function redeem(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _acrvAmount,
    uint256 _minCRVAmount,
    address _callback
  ) external virtual override onlyAnyCallProxy {
    // do nothing, when amount is zero.
    // solhint-disable-next-line reason-string
    require(_acrvAmount > 0, "Layer1ACRVProxy: redeem zero amount");
    // solhint-disable-next-line reason-string
    require(_targetChain == targetChain, "Layer1ACRVProxy: target chain mismatch");

    {
      uint256 _balance = IERC20(ACRV).balanceOf(address(this));
      // solhint-disable-next-line reason-string
      require(_balance > 0, "Layer1ACRVProxy: insufficient aCRV to redeem");
      // in case that the fee calculation in layer2 is wrong.
      if (_balance < _acrvAmount) {
        _acrvAmount = _balance;
      }
    }

    // 1. redeem CRV from aCRV.
    uint256 _totalAmount = IAladdinCRV(ACRV).withdraw(
      address(this),
      _acrvAmount,
      _minCRVAmount,
      IAladdinCRV.WithdrawOption.WithdrawAsCRV
    );

    // 2. bridge CRV to recipient in target chain.
    (uint256 _bridgeAmount, uint256 _totalFee) = _bridgeCRV(_recipient, _totalAmount);

    // 3. cross chain call to notify
    if (_callback != address(0)) {
      bytes memory _data = abi.encodeWithSelector(
        ILayer2CRVDepositor.finalizeRedeem.selector,
        _executionId,
        _acrvAmount,
        _bridgeAmount,
        _totalFee
      );
      ICrossChainCallProxy(crossChainCallProxy).crossChainCall(_callback, _data, address(0), _targetChain);
    }

    emit Redeem(_executionId, _targetChain, _recipient, _acrvAmount, _bridgeAmount, _totalFee);
  }
}


// : MIT

pragma solidity ^0.7.6;

interface IAnyswapRouter {
  // swaps `amount` `token` in `fromChainID` to `to` on this chainID
  // triggered by `anySwapOut`
  function anySwapIn(
    bytes32 txs,
    address token,
    address to,
    uint256 amount,
    uint256 fromChainID
  ) external;

  // swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying`
  function anySwapInUnderlying(
    bytes32 txs,
    address token,
    address to,
    uint256 amount,
    uint256 fromChainID
  ) external;

  // swaps `amount` `token` in `fromChainID` to `to` on this chainID with `to` receiving `underlying` if possible
  function anySwapInAuto(
    bytes32 txs,
    address token,
    address to,
    uint256 amount,
    uint256 fromChainID
  ) external;

  function anySwapIn(
    bytes32[] calldata txs,
    address[] calldata tokens,
    address[] calldata to,
    uint256[] calldata amounts,
    uint256[] calldata fromChainIDs
  ) external;

  // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to`
  function anySwapOut(
    address token,
    address to,
    uint256 amount,
    uint256 toChainID
  ) external;

  // Swaps `amount` `token` from this chain to `toChainID` chain with recipient `to` by minting with `underlying`
  function anySwapOutUnderlying(
    address token,
    address to,
    uint256 amount,
    uint256 toChainID
  ) external;

  function anySwapOut(
    address[] calldata tokens,
    address[] calldata to,
    uint256[] calldata amounts,
    uint256[] calldata toChainIDs
  ) external;

  // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
  function anySwapOutExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 toChainID
  ) external;

  // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
  function anySwapOutExactTokensForTokensUnderlying(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 toChainID
  ) external;

  // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
  function anySwapOutExactTokensForNative(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 toChainID
  ) external;

  // sets up a cross-chain trade from this chain to `toChainID` for `path` trades to `to`
  function anySwapOutExactTokensForNativeUnderlying(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline,
    uint256 toChainID
  ) external;
}


// : MIT

pragma solidity ^0.7.6;

//import"./interfaces/IAnyCallProxy.sol";

abstract contract CrossChainCallBase {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event UpdateCrossChainCallProxy(address indexed _crossChainCallProxy);
  event UpdateAnyCallProxy(address indexed _anyCallProxy);

  /// @notice The owner of the contract.
  address public owner;
  /// @notice The address of AnyCallProxy.
  address public anyCallProxy;
  /// @notice The address of CrossChainCallProxy.
  address public crossChainCallProxy;

  modifier onlyAnyCallProxy() {
    // solhint-disable-next-line reason-string
    require(msg.sender == anyCallProxy, "CrossChainCallBase: only AnyCallProxy");
    _;
  }

  modifier onlyOwner() {
    // solhint-disable-next-line reason-string
    require(msg.sender == owner, "CrossChainCallBase: only owner");
    _;
  }

  modifier SponsorCrossCallFee() {
    // caller sponsor cross chain fee.
    if (msg.value > 0) {
      IAnyCallProxy(anyCallProxy).deposit{ value: msg.value }(crossChainCallProxy);
    }
    _;
  }

  function _initialize(
    address _anyCallProxy,
    address _crossChainCallProxy,
    address _owner
  ) internal {
    // solhint-disable-next-line reason-string
    require(_anyCallProxy != address(0), "CrossChainCallBase: zero address");
    // solhint-disable-next-line reason-string
    require(_crossChainCallProxy != address(0), "CrossChainCallBase: zero address");
    // solhint-disable-next-line reason-string
    require(_owner != address(0), "CrossChainCallBase: zero address");

    anyCallProxy = _anyCallProxy;
    crossChainCallProxy = _crossChainCallProxy;
    owner = _owner;
  }

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  /********************************** Restricted Functions **********************************/

  /// @notice Update AnyCallProxy contract.
  /// @param _anyCallProxy The address to update.
  function updateAnyCallProxy(address _anyCallProxy) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_anyCallProxy != address(0), "CrossChainCallBase: zero address");

    anyCallProxy = _anyCallProxy;

    emit UpdateAnyCallProxy(_anyCallProxy);
  }

  /// @notice Update CrossChainCallProxy contract.
  /// @param _crossChainCallProxy The address to update.
  function updateCrossChainCallProxy(address _crossChainCallProxy) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_crossChainCallProxy != address(0), "CrossChainCallBase: zero address");

    crossChainCallProxy = _crossChainCallProxy;

    emit UpdateCrossChainCallProxy(_crossChainCallProxy);
  }

  /// @notice Transfers ownership of the contract to a new account (`newOwner`).
  /// @dev Can only be called by the current owner.
  /// @param _owner The address of new owner.
  function transferOwnership(address _owner) public onlyOwner {
    // solhint-disable-next-line reason-string
    require(_owner != address(0), "CrossChainCallBase: zero address");

    emit OwnershipTransferred(owner, _owner);

    owner = _owner;
  }

  /// @notice Execute calls on behalf of contract in case of emergency
  /// @param _to The address of contract to call.
  /// @param _value The amount of ETH passing to the contract.
  /// @param _data The data passing to the contract.
  function execute(
    address _to,
    uint256 _value,
    bytes calldata _data
  ) external onlyOwner returns (bool, bytes memory) {
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory result) = _to.call{ value: _value }(_data);
    return (success, result);
  }

  /********************************** Internal Functions **********************************/

  /// @dev Internal function to bridge aCRV to target chain.
  /// @param _recipient The address of recipient will receive the aCRV.
  /// @param _totalAmount The total amount of aCRV to bridge.
  /// @return _bridgeAmount The total amount of aCRV bridged, fees are included.
  /// @return _totalFee The total amount of aCRV fee charged by Bridge.
  function _bridgeACRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {}

  /// @dev Internal function to bridge CRV to target chain.
  /// @param _recipient The address of recipient will receive the CRV.
  /// @param _totalAmount The total amount of CRV to bridge.
  /// @return _bridgeAmount The total amount of CRV bridged, fees are included.
  /// @return _totalFee The total amount of CRV fee charged by Bridge.
  function _bridgeCRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {}

  /// @dev Internal function to get current chain id.
  function _getChainId() internal pure returns (uint256) {
    uint256 _chainId;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      _chainId := chainid()
    }
    return _chainId;
  }
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"../interfaces/IMulticall.sol";

abstract contract Multicall is IMulticall {
  /// @inheritdoc IMulticall
  function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      // solhint-disable-next-line avoid-low-level-calls
      (bool success, bytes memory result) = address(this).delegatecall(data[i]);

      if (!success) {
        // Next 7 lines from https://ethereum.stackexchange.com/a/83577
        // solhint-disable-next-line reason-string
        if (result.length < 68) revert();
        // solhint-disable-next-line no-inline-assembly
        assembly {
          result := add(result, 0x04)
        }
        revert(abi.decode(result, (string)));
      }

      results[i] = result;
    }
  }
}


// : MIT

pragma solidity ^0.7.6;

//import"@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IAladdinCRV is IERC20Upgradeable {
  event Harvest(address indexed _caller, uint256 _amount);
  event Deposit(address indexed _sender, address indexed _recipient, uint256 _amount);
  event Withdraw(
    address indexed _sender,
    address indexed _recipient,
    uint256 _shares,
    IAladdinCRV.WithdrawOption _option
  );

  event UpdateWithdrawalFeePercentage(uint256 _feePercentage);
  event UpdatePlatformFeePercentage(uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);

  enum WithdrawOption {
    Withdraw,
    WithdrawAndStake,
    WithdrawAsCRV,
    WithdrawAsCVX,
    WithdrawAsETH
  }

  /// @dev return the total amount of cvxCRV staked.
  function totalUnderlying() external view returns (uint256);

  /// @dev return the amount of cvxCRV staked for user
  function balanceOfUnderlying(address _user) external view returns (uint256);

  function deposit(address _recipient, uint256 _amount) external returns (uint256);

  function depositAll(address _recipient) external returns (uint256);

  function depositWithCRV(address _recipient, uint256 _amount) external returns (uint256);

  function depositAllWithCRV(address _recipient) external returns (uint256);

  function withdraw(
    address _recipient,
    uint256 _shares,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function withdrawAll(
    address _recipient,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function harvest(address _recipient, uint256 _minimumOut) external returns (uint256);
}


// : MIT

pragma solidity ^0.7.6;

interface ICrossChainCallProxy {
  function crossChainCall(
    address _to,
    bytes memory _data,
    address _fallback,
    uint256 _toChainID
  ) external;
}


// : MIT

pragma solidity ^0.7.6;

interface ILayer2CRVDepositor {
  enum AsyncOperationStatus {
    None,
    Pending,
    OnGoing,
    Failed
  }

  event Deposit(address indexed _sender, uint256 indexed _executionId, uint256 _amount);
  event Redeem(address indexed _sender, uint256 indexed _executionId, uint256 _amount);
  event AbortDeposit(address indexed _sender, uint256 indexed _executionId, uint256 _amount);
  event AbortRedeem(address indexed _sender, uint256 indexed _executionId, uint256 _amount);
  event Claim(address indexed _sender, uint256 _acrvAmount, uint256 _crvAmount);

  event FinalizeDeposit(uint256 indexed _executionId, uint256 _crvAmount, uint256 _acrvAmount, uint256 _acrvFee);
  event FinalizeRedeem(uint256 indexed _executionId, uint256 _acrvAmount, uint256 _crvAmount, uint256 _crvFee);

  event PrepareDeposit(uint256 indexed _executionId, uint256 _amount, uint256 _depositFee, uint256 _bridgeFee);
  event PrepareRedeem(uint256 indexed _executionId, uint256 _amount, uint256 _redeemFee, uint256 _bridgeFee);

  event AsyncDeposit(uint256 indexed _executionId, AsyncOperationStatus _prevStatus);
  event AsyncRedeem(uint256 indexed _executionId, AsyncOperationStatus _prevStatus);

  event AsyncDepositFailed(uint256 indexed _executionId);
  event AsyncRedeemFailed(uint256 indexed _executionId);

  /// @notice Deposit CRV for aCRV asynchronously in this contract.
  /// @param _amount The amount of CRV to deposit.
  function deposit(uint256 _amount) external;

  /// @notice Abort current deposit and take CRV back.
  /// @dev Will revert if the CRV is already bridged to Layer 1.
  /// @param _amount The amount of CRV to abort.
  function abortDeposit(uint256 _amount) external;

  /// @notice Redeem aCRV for CRV asynchronously in this contract.
  /// @param _amount The amount of aCRV to redeem.
  function redeem(uint256 _amount) external;

  /// @notice Abort current redeem and take aCRV back.
  /// @dev Will revert if the aCRV is already bridged to Layer 1.
  /// @param _amount The amount of aCRV to abort.
  function abortRedeem(uint256 _amount) external;

  /// @notice Claim executed aCRV/CRV on asynchronous deposit/redeem.
  function claim() external;

  /// @notice Callback function called on failure in AnyswapCall.
  /// @dev This function can only called by AnyCallProxy.
  /// @param _to The target address in original call.
  /// @param _data The calldata pass to target address in original call.
  function anyFallback(address _to, bytes memory _data) external;

  /// @notice Callback function called on success in `deposit`.
  /// @dev This function can only called by AnyCallProxy.
  /// @param _executionId An unique id to keep track on the deposit operation.
  /// @param _crvAmount The acutal amount of CRV deposited in Layer 1.
  /// @param _acrvAmount The acutal amount of aCRV received in Layer 1.
  /// @param _acrvFee The fee charged on cross chain.
  function finalizeDeposit(
    uint256 _executionId,
    uint256 _crvAmount,
    uint256 _acrvAmount,
    uint256 _acrvFee
  ) external;

  /// @notice Callback function called on success in `redeem`.
  /// @dev This function can only called by AnyCallProxy.
  /// @param _executionId An unique id to keep track on the redeem operation.
  /// @param _acrvAmount The acutal amount of aCRV to redeem in Layer 1.
  /// @param _crvAmount The acutal amount of CRV received in Layer 1.
  /// @param _crvFee The fee charged on cross chain.
  function finalizeRedeem(
    uint256 _executionId,
    uint256 _acrvAmount,
    uint256 _crvAmount,
    uint256 _crvFee
  ) external;
}


// : MIT

pragma solidity ^0.7.6;

interface ILayer1ACRVProxy {
  /// @notice Cross chain deposit CRV to aCRV and cross back to target chain.
  /// @param _executionId An unique id to keep track on the deposit operation on target chain.
  /// @param _targetChain The target chain id.
  /// @param _recipient The address of recipient who will receive the aCRV on target chain.
  /// @param _crvAmount The amount of CRV to deposit.
  /// @param _callback The address who will receive callback on target chain.
  function deposit(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _crvAmount,
    address _callback
  ) external;

  /// @notice Cross chain redeem aCRV to CRV and cross back to target chain.
  /// @param _executionId An unique id to keep track on the redeem operation on target chain.
  /// @param _targetChain The target chain id.
  /// @param _recipient The address of recipient who will receive the aCRV on target chain.
  /// @param _acrvAmount The amount of aCRV to redeem.
  /// @param _minCRVAmount The minimum amount of CRV to receive.
  /// @param _callback The address who will receive callback on target chain.
  function redeem(
    uint256 _executionId,
    uint256 _targetChain,
    address _recipient,
    uint256 _acrvAmount,
    uint256 _minCRVAmount,
    address _callback
  ) external;
}


// : MIT

pragma solidity ^0.7.6;

interface IAnyCallProxy {
  event LogAnyCall(address indexed from, address indexed to, bytes data, address _fallback, uint256 indexed toChainID);

  event LogAnyExec(
    address indexed from,
    address indexed to,
    bytes data,
    bool success,
    bytes result,
    address _fallback,
    uint256 indexed fromChainID
  );

  function setWhitelist(
    address _from,
    address _to,
    uint256 _toChainID,
    bool _flag
  ) external;

  function anyCall(
    address _to,
    bytes calldata _data,
    address _fallback,
    uint256 _toChainID
  ) external;

  function anyExec(
    address _from,
    address _to,
    bytes calldata _data,
    address _fallback,
    uint256 _fromChainID
  ) external;

  function withdraw(uint256 _amount) external;

  function deposit(address _account) external payable;
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

/// @title Multicall interface
/// @notice Enables calling multiple methods in a single call to the contract
interface IMulticall {
  /// @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
  /// @dev The `msg.value` should not be trusted for any method callable from multicall.
  /// @param data The encoded function data for each of the calls to make to this contract
  /// @return results The results from each of the calls passed in via data
  function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}


// : MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
//import"@openzeppelin/contracts/math/SafeMath.sol";

//import"../CrossChainCallBase.sol";

//import"../interfaces/IAnyCallProxy.sol";
//import"../interfaces/ICrossChainCallProxy.sol";
//import"../interfaces/ILayer2CRVDepositor.sol";
//import"../interfaces/ILayer1ACRVProxy.sol";

abstract contract Layer2CRVDepositorBase is CrossChainCallBase, ILayer2CRVDepositor {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  event UpdateWhitelist(address indexed _account, bool _status);
  event UpdateLayer1Proxy(address indexed _layer1Proxy);
  event UpdateFeeData(address indexed _platform, uint32 _depositFeePercentage, uint32 _redeemFeePercentage);

  /// @dev The denominator used to calculate cross chain fee.
  uint256 internal constant FEE_DENOMINATOR = 1e9;
  /// @dev The maximum deposit fee percentage.
  uint256 private constant MAX_DEPOSIT_FEE_PERCENTAGE = 1e8; // 10%
  /// @dev The maximum redeem fee percentage.
  uint256 private constant MAX_WITHDRAW_FEE_PERCENTAGE = 1e8; // 10%

  struct FeeData {
    // The address of platform, used to receive deposit/redeem fee.
    address platform;
    // The deposit fee percentage in $CRV charged on each deposit.
    uint32 depositFeePercentage;
    // The redeem fee percentage in $aCRV charged on each redeem.
    uint32 redeemFeePercentage;
  }

  struct CrossChainOperationData {
    // The amount of CRV/aCRV is waiting for deposit/redeem.
    uint112 pending;
    // The amount of CRV/aCRV is depositing/redeeming.
    uint112 ongoing;
    // The current execution id, will increase after deposit/redeem is finialzed.
    uint32 executionId;
  }

  struct FinalizedOperationState {
    // The amount of CRV/aCRV provided before asynchronous deposit/redeem.
    uint128 providedAmount;
    // The amount of aCRV/CRV received after asynchronous deposit/redeem.
    uint128 executedAmount;
  }

  struct AccountOperation {
    // The current execution id.
    uint32 executionId;
    // The amount of CRV/aCRV provided after fee deduction.
    uint224 amount;
  }

  struct AccountOperationList {
    // Keep track of claimed aCRV/CRV.
    uint256 claimIndex;
    // The list of user operations group by execution id.
    AccountOperation[] operations;
  }

  /// @notice The address of CRV in Layer 2.
  address public crv;
  /// @notice The address of aCRV in Layer 2.
  address public acrv;
  /// @notice The address of Layer1ACRVProxy contract.
  address public layer1Proxy;
  /// @notice Fee data on deposit/redeem.
  FeeData public fees;

  /// @notice The status for async deposit.
  AsyncOperationStatus public asyncDepositStatus;
  /// @notice The data for CRV deposit operation.
  CrossChainOperationData public depositOperation;

  /// @notice The status for async redeem.
  AsyncOperationStatus public asyncRedeemStatus;
  /// @notice The data for aCRV redeem operation.
  CrossChainOperationData public redeemOperation;

  /// @notice Mapping from execution id to finalized deposit state.
  mapping(uint256 => FinalizedOperationState) public finialzedDepositState;
  /// @notice Mapping from execution id to finalized redeem state.
  mapping(uint256 => FinalizedOperationState) public finialzedRedeemState;

  /// @notice Mapping from account address to deposit operations.
  mapping(address => AccountOperationList) public accountDepositOperations;
  /// @notice Mapping from account address to redeem operations.
  mapping(address => AccountOperationList) public accountRedeemOperations;

  /// @notice Keep track of a list of whitelist addresses.
  mapping(address => bool) public whitelist;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;
  uint256 private _enterStatus;

  /// @dev Prevents a contract from calling itself, directly or indirectly.
  /// Calling a `nonReentrant` function from another `nonReentrant`
  /// function is not supported. It is possible to prevent this from happening
  /// by making the `nonReentrant` function external, and make it call a
  /// `private` function that does the actual work.
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_enterStatus != _ENTERED, "ReentrancyGuard: reentrant call");

    // Any calls to nonReentrant after this point will fail
    _enterStatus = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _enterStatus = _NOT_ENTERED;
  }

  modifier onlyWhitelist() {
    // solhint-disable-next-line reason-string
    require(whitelist[msg.sender], "Layer2CRVDepositor: only whitelist");
    _;
  }

  function _initialize(
    address _anyCallProxy,
    address _crossChainCallProxy,
    address _owner,
    address _crv,
    address _acrv,
    address _layer1Proxy
  ) internal {
    // solhint-disable-next-line reason-string
    require(_crv != address(0), "Layer2CRVDepositor: zero address");
    // solhint-disable-next-line reason-string
    require(_acrv != address(0), "Layer2CRVDepositor: zero address");
    // solhint-disable-next-line reason-string
    require(_layer1Proxy != address(0), "Layer2CRVDepositor: zero address");

    CrossChainCallBase._initialize(_anyCallProxy, _crossChainCallProxy, _owner);

    crv = _crv;
    acrv = _acrv;
    layer1Proxy = _layer1Proxy;

    // for ReentrancyGuard
    _enterStatus = _NOT_ENTERED;
  }

  /********************************** View Functions **********************************/

  /// @notice Get the amount of aCRV/CRV claimable.
  /// @param _account The address of account to query.
  function claimable(address _account) external view returns (uint256 _acrvAmount, uint256 _crvAmount) {
    (, _acrvAmount) = _getClaimable(accountDepositOperations[_account], finialzedDepositState);
    (, _crvAmount) = _getClaimable(accountRedeemOperations[_account], finialzedRedeemState);
  }

  /// @notice Get the amount of aCRV/CRV abortable.
  /// @param _account The address of account to query.
  function abortable(address _account) external view returns (uint256 _acrvAmount, uint256 _crvAmount) {
    _acrvAmount = _getAbortable(false, _account);
    _crvAmount = _getAbortable(true, _account);
  }

  /// @notice Get the list of deposit operations.
  /// @param _account The address of account to query.
  function getAccountDepositOperations(address _account) external view returns (AccountOperation[] memory _operations) {
    return accountDepositOperations[_account].operations;
  }

  /// @notice Get the list of redeem operations.
  /// @param _account The address of account to query.
  function getAccountRedeemOperations(address _account) external view returns (AccountOperation[] memory _operations) {
    return accountRedeemOperations[_account].operations;
  }

  /********************************** Mutated Functions **********************************/

  /// @notice See {ILayer2CRVDepositor-deposit}
  function deposit(uint256 _amount) external override nonReentrant {
    // solhint-disable-next-line reason-string
    require(_amount > 0, "Layer2CRVDepositor: deposit zero amount");

    uint256 _executionId = _operateDepositOrRedeem(true, msg.sender, _amount);

    emit Deposit(msg.sender, _executionId, _amount);
  }

  /// @notice See {ILayer2CRVDepositor-abortDeposit}
  function abortDeposit(uint256 _amount) external override nonReentrant {
    // solhint-disable-next-line reason-string
    require(_amount > 0, "Layer2CRVDepositor: abort zero amount");

    uint256 _executionId = _abortDepositOrRedeem(true, msg.sender, _amount);

    emit AbortDeposit(msg.sender, _executionId, _amount);
  }

  /// @notice See {ILayer2CRVDepositor-redeem}
  function redeem(uint256 _amount) external override nonReentrant {
    // solhint-disable-next-line reason-string
    require(_amount > 0, "Layer2CRVDepositor: redeem zero amount");

    uint256 _executionId = _operateDepositOrRedeem(false, msg.sender, _amount);

    emit Redeem(msg.sender, _executionId, _amount);
  }

  /// @notice See {ILayer2CRVDepositor-abortRedeem}
  function abortRedeem(uint256 _amount) external override nonReentrant {
    // solhint-disable-next-line reason-string
    require(_amount > 0, "Layer2CRVDepositor: abort zero amount");

    uint256 _executionId = _abortDepositOrRedeem(false, msg.sender, _amount);

    emit AbortRedeem(msg.sender, _executionId, _amount);
  }

  /// @notice See {ILayer2CRVDepositor-claim}
  function claim() external override nonReentrant {
    uint256 _acrvAmount = _claim(accountDepositOperations[msg.sender], finialzedDepositState);
    IERC20(acrv).safeTransfer(msg.sender, _acrvAmount);

    uint256 _crvAmount = _claim(accountRedeemOperations[msg.sender], finialzedRedeemState);
    IERC20(crv).safeTransfer(msg.sender, _crvAmount);

    emit Claim(msg.sender, _acrvAmount, _crvAmount);
  }

  /// @notice Prepare asyncDeposit, bridge CRV to Layer1.
  /// @dev This function can only called by whitelisted addresses.
  function prepareAsyncDeposit() external virtual onlyWhitelist {
    CrossChainOperationData memory _operation = depositOperation;
    // solhint-disable-next-line reason-string
    require(_operation.ongoing == 0, "Layer2CRVDepositor: has ongoing deposit");
    // solhint-disable-next-line reason-string
    require(_operation.pending > 0, "Layer2CRVDepositor: no pending deposit");

    FeeData memory _fees = fees;
    uint256 _totalAmount = _operation.pending;
    uint256 _depositFee = (_totalAmount * _fees.depositFeePercentage) / FEE_DENOMINATOR;
    _totalAmount -= _depositFee;
    _operation.ongoing = _operation.pending;
    _operation.pending = 0;

    asyncDepositStatus = AsyncOperationStatus.Pending;
    depositOperation = _operation;

    if (_depositFee > 0) {
      IERC20(crv).safeTransfer(_fees.platform, _depositFee);
    }

    (, uint256 _bridgeFee) = _bridgeCRV(layer1Proxy, _totalAmount);

    emit PrepareDeposit(_operation.executionId, _operation.ongoing, _depositFee, _bridgeFee);
  }

  /// @notice Prepare asyncRedeem, bridge aCRV to Layer1.
  /// @dev This function can only called by whitelisted addresses.
  function prepareAsyncRedeem() external virtual onlyWhitelist {
    CrossChainOperationData memory _operation = redeemOperation;
    // solhint-disable-next-line reason-string
    require(_operation.ongoing == 0, "Layer2CRVDepositor: has ongoing redeem");
    // solhint-disable-next-line reason-string
    require(_operation.pending > 0, "Layer2CRVDepositor: no pending redeem");

    FeeData memory _fees = fees;
    uint256 _totalAmount = _operation.pending;
    uint256 _redeemFee = (_totalAmount * _fees.redeemFeePercentage) / FEE_DENOMINATOR;
    _totalAmount -= _redeemFee;
    _operation.ongoing = _operation.pending;
    _operation.pending = 0;

    asyncRedeemStatus = AsyncOperationStatus.Pending;
    redeemOperation = _operation;

    if (_redeemFee > 0) {
      IERC20(acrv).safeTransfer(_fees.platform, _redeemFee);
    }

    (, uint256 _bridgeFee) = _bridgeACRV(layer1Proxy, _totalAmount);

    emit PrepareRedeem(_operation.executionId, _operation.ongoing, _redeemFee, _bridgeFee);
  }

  /// @notice Deposit CRV in this contract to Layer 1 aCRV contract asynchronously.
  /// @dev This function can only called by whitelisted addresses.
  function asyncDeposit() external payable virtual onlyWhitelist SponsorCrossCallFee {
    CrossChainOperationData memory _operation = depositOperation;
    // solhint-disable-next-line reason-string
    require(_operation.ongoing > 0, "Layer2CRVDepositor: no pending deposit");
    AsyncOperationStatus _status = asyncDepositStatus;
    // solhint-disable-next-line reason-string
    require(
      _status == AsyncOperationStatus.Pending || _status == AsyncOperationStatus.Failed,
      "Layer2CRVDepositor: no pending deposit or has ongoing deposit"
    );

    asyncDepositStatus = AsyncOperationStatus.OnGoing;

    // cross chain call deposit
    bytes memory _data = abi.encodeWithSelector(
      ILayer1ACRVProxy.deposit.selector,
      uint256(_operation.executionId),
      uint256(1),
      address(this),
      uint256(_operation.ongoing),
      address(this)
    );
    ICrossChainCallProxy(crossChainCallProxy).crossChainCall(layer1Proxy, _data, address(this), 1);

    emit AsyncDeposit(_operation.executionId, _status);
  }

  /// @notice Redeem aCRV in this contract to Layer 1 aCRV contract asynchronously.
  /// @dev This function can only called by whitelisted addresses.
  function asyncRedeem(uint256 _minCRVAmount) external payable virtual onlyWhitelist SponsorCrossCallFee {
    CrossChainOperationData memory _operation = redeemOperation;
    // solhint-disable-next-line reason-string
    require(_operation.ongoing > 0, "Layer2CRVDepositor: no pending redeem");
    AsyncOperationStatus _status = asyncRedeemStatus;
    // solhint-disable-next-line reason-string
    require(
      _status == AsyncOperationStatus.Pending || _status == AsyncOperationStatus.Failed,
      "Layer2CRVDepositor: no pending redeem or has ongoing redeem"
    );

    asyncRedeemStatus = AsyncOperationStatus.OnGoing;

    // cross chain call redeem
    bytes memory _data = abi.encodeWithSelector(
      ILayer1ACRVProxy.redeem.selector,
      uint256(_operation.executionId),
      uint256(1),
      address(this),
      uint256(_operation.ongoing),
      _minCRVAmount,
      address(this)
    );
    ICrossChainCallProxy(crossChainCallProxy).crossChainCall(layer1Proxy, _data, address(this), 1);

    emit AsyncRedeem(_operation.executionId, _status);
  }

  /// @notice See {ILayer2CRVDepositor-anyFallback}
  function anyFallback(address _to, bytes calldata _data) external virtual override onlyAnyCallProxy {
    bytes4 _selector;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      _selector := calldataload(_data.offset)
    }
    if (_selector == ILayer1ACRVProxy.deposit.selector) {
      (uint256 _executionId, , , , ) = abi.decode(_data[4:], (uint256, uint256, address, uint256, address));
      CrossChainOperationData memory _operation = depositOperation;
      // solhint-disable-next-line reason-string
      require(_operation.executionId == _executionId, "Layer2CRVDepositor: execution id mismatch");
      // solhint-disable-next-line reason-string
      require(asyncDepositStatus == AsyncOperationStatus.OnGoing, "Layer2CRVDepositor: no ongoing deposit");
      asyncDepositStatus = AsyncOperationStatus.Failed;

      emit AsyncDepositFailed(_executionId);
    } else if (_selector == ILayer1ACRVProxy.redeem.selector) {
      (uint256 _executionId, , , , , ) = abi.decode(_data[4:], (uint256, uint256, address, uint256, uint256, address));
      CrossChainOperationData memory _operation = redeemOperation;
      // solhint-disable-next-line reason-string
      require(_operation.executionId == _executionId, "Layer2CRVDepositor: execution id mismatch");
      // solhint-disable-next-line reason-string
      require(asyncRedeemStatus == AsyncOperationStatus.OnGoing, "Layer2CRVDepositor: no ongoing redeem");
      asyncRedeemStatus = AsyncOperationStatus.Failed;

      emit AsyncRedeemFailed(_executionId);
    } else {
      _customFallback(_to, _data);
    }
  }

  /// @notice See {ILayer2CRVDepositor-finalizeDeposit}
  function finalizeDeposit(
    uint256 _executionId,
    uint256 _crvAmount,
    uint256 _acrvAmount,
    uint256 _acrvFee
  ) external virtual override onlyAnyCallProxy {
    // solhint-disable-next-line reason-string
    require(asyncDepositStatus == AsyncOperationStatus.OnGoing, "Layer2CRVDepositor: no ongoing deposit");

    CrossChainOperationData memory _operation = depositOperation;
    // solhint-disable-next-line reason-string
    require(_operation.executionId == _executionId, "Layer2CRVDepositor: execution id mismatch");

    finialzedDepositState[_executionId] = FinalizedOperationState(
      uint128(_operation.ongoing),
      uint128(_acrvAmount - _acrvFee)
    );
    asyncDepositStatus = AsyncOperationStatus.None;
    _operation.ongoing = 0;
    _operation.executionId += 1;
    depositOperation = _operation;

    emit FinalizeDeposit(_executionId, _crvAmount, _acrvAmount, _acrvFee);
  }

  /// @notice See {ILayer2CRVDepositor-finalizeRedeem}
  function finalizeRedeem(
    uint256 _executionId,
    uint256 _acrvAmount,
    uint256 _crvAmount,
    uint256 _crvFee
  ) external virtual override onlyAnyCallProxy {
    // solhint-disable-next-line reason-string
    require(asyncRedeemStatus == AsyncOperationStatus.OnGoing, "Layer2CRVDepositor: no ongoing redeem");

    CrossChainOperationData memory _operation = redeemOperation;
    // solhint-disable-next-line reason-string
    require(_operation.executionId == _executionId, "Layer2CRVDepositor: execution id mismatch");

    finialzedRedeemState[_executionId] = FinalizedOperationState(
      uint128(_operation.ongoing),
      uint128(_crvAmount - _crvFee)
    );
    asyncRedeemStatus = AsyncOperationStatus.None;
    _operation.ongoing = 0;
    _operation.executionId += 1;
    redeemOperation = _operation;

    emit FinalizeRedeem(_executionId, _acrvAmount, _crvAmount, _crvFee);
  }

  /********************************** Restricted Functions **********************************/

  /// @notice Update the address of Layer1ACRVProxy contract.
  /// @param _layer1Proxy The address to update.
  function updateLayer1Proxy(address _layer1Proxy) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_layer1Proxy != address(0), "Layer2CRVDepositor: zero address");

    layer1Proxy = _layer1Proxy;

    emit UpdateLayer1Proxy(_layer1Proxy);
  }

  /// @notice Update whitelist contract can call `crossChainCall`.
  /// @param _whitelist The list of whitelist address to update.
  /// @param _status The status to update.
  function updateWhitelist(address[] memory _whitelist, bool _status) external onlyOwner {
    for (uint256 i = 0; i < _whitelist.length; i++) {
      whitelist[_whitelist[i]] = _status;

      emit UpdateWhitelist(_whitelist[i], _status);
    }
  }

  /// @dev Update fee data
  /// @param _platform The address of platform to update.
  /// @param _depositFeePercentage The deposit fee percentage to update.
  /// @param _redeemFeePercentage The redeem fee percentage to update.
  function updateFeeData(
    address _platform,
    uint32 _depositFeePercentage,
    uint32 _redeemFeePercentage
  ) external onlyOwner {
    // solhint-disable-next-line reason-string
    require(_platform != address(0), "Layer2CRVDepositor: zero address");
    // solhint-disable-next-line reason-string
    require(_depositFeePercentage <= MAX_DEPOSIT_FEE_PERCENTAGE, "Layer2CRVDepositor: fee too large");
    // solhint-disable-next-line reason-string
    require(_redeemFeePercentage <= MAX_WITHDRAW_FEE_PERCENTAGE, "Layer2CRVDepositor: fee too large");

    fees = FeeData(_platform, _depositFeePercentage, _redeemFeePercentage);

    emit UpdateFeeData(_platform, _depositFeePercentage, _redeemFeePercentage);
  }

  /********************************** Internal Functions **********************************/

  /// @dev Internal function to get current aCRV/CRV execution id.
  function _getExecutionId(CrossChainOperationData memory _operation) private pure returns (uint256) {
    if (_operation.ongoing > 0) {
      return _operation.executionId + 1;
    } else {
      return _operation.executionId;
    }
  }

  function _isExecutionOngoing(CrossChainOperationData memory _operation, uint256 _executionId)
    private
    pure
    returns (bool)
  {
    if (_operation.ongoing > 0) {
      return _operation.executionId == _executionId;
    } else {
      return false;
    }
  }

  function _operateDepositOrRedeem(
    bool isDeposit,
    address _account,
    uint256 _amount
  ) private returns (uint256 _executionId) {
    // 1. transfer from msg.sender
    address _token = isDeposit ? crv : acrv;
    IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

    // 2. update global state
    CrossChainOperationData memory _operation = isDeposit ? depositOperation : redeemOperation;
    _executionId = _getExecutionId(_operation);
    {
      uint256 _newPending = _amount.add(_operation.pending);
      require(_newPending <= uint112(-1), "Layer2CRVDepositor: overflow");
      _operation.pending = uint112(_newPending);
      if (isDeposit) {
        depositOperation = _operation;
      } else {
        redeemOperation = _operation;
      }
    }

    // 3. update user state
    AccountOperationList storage _operations = isDeposit
      ? accountDepositOperations[_account]
      : accountRedeemOperations[_account];
    uint256 _length = _operations.operations.length;
    if (_length > 0 && _operations.operations[_length - 1].executionId == _executionId) {
      _operations.operations[_length - 1].amount += uint224(_amount); // addition is safe
    } else {
      _operations.operations.push(AccountOperation(uint32(_executionId), uint224(_amount)));
    }
  }

  function _abortDepositOrRedeem(
    bool isDeposit,
    address _account,
    uint256 _amount
  ) private returns (uint256 _executionId) {
    // 1. check global last operation status
    CrossChainOperationData memory _operation = isDeposit ? depositOperation : redeemOperation;
    _executionId = _getExecutionId(_operation);

    // 2. check and update user last operation
    AccountOperationList storage _operations = isDeposit
      ? accountDepositOperations[_account]
      : accountRedeemOperations[_account];
    uint256 _length = _operations.operations.length;
    if (_length > 0 && _operations.operations[_length - 1].executionId == _executionId) {
      AccountOperation memory _accountOperation = _operations.operations[_length - 1];
      // solhint-disable-next-line reason-string
      require(_accountOperation.amount >= _amount, "Layer2CRVDepositor: insufficient amount to abort");
      _operations.operations[_length - 1].amount -= uint224(_amount);
    } else {
      // solhint-disable-next-line reason-string
      revert("Layer2CRVDepositor: insufficient amount to abort");
    }

    // 3. update last global operation
    _operation.pending -= uint112(_amount);
    if (isDeposit) {
      depositOperation = _operation;
    } else {
      redeemOperation = _operation;
    }

    // transfer token to user
    address _token = isDeposit ? crv : acrv;
    IERC20(_token).safeTransfer(_account, _amount);
  }

  function _claim(
    AccountOperationList storage _operations,
    mapping(uint256 => FinalizedOperationState) storage _finalized
  ) private returns (uint256 _claimable) {
    uint256 _claimIndex;
    (_claimIndex, _claimable) = _getClaimable(_operations, _finalized);

    _operations.claimIndex = _claimIndex;
  }

  function _getClaimable(
    AccountOperationList storage _operations,
    mapping(uint256 => FinalizedOperationState) storage _finalized
  ) private view returns (uint256 _claimIndex, uint256 _claimable) {
    uint256 _length = _operations.operations.length;
    _claimIndex = _operations.claimIndex;
    AccountOperation memory _operation;
    FinalizedOperationState memory _finalizedState;
    while (_claimIndex < _length) {
      _operation = _operations.operations[_claimIndex];
      _finalizedState = _finalized[_operation.executionId];

      if (_finalizedState.providedAmount == 0) break;

      _claimable += (uint256(_operation.amount) * _finalizedState.executedAmount) / _finalizedState.providedAmount;
      _claimIndex += 1;
    }
  }

  function _getAbortable(bool isDeposit, address _account) private view returns (uint256) {
    CrossChainOperationData memory _operation = isDeposit ? depositOperation : redeemOperation;
    uint256 _executionId = _getExecutionId(_operation);
    if (_isExecutionOngoing(_operation, _executionId)) return 0;

    AccountOperationList storage _operations = isDeposit
      ? accountDepositOperations[_account]
      : accountRedeemOperations[_account];
    uint256 _length = _operations.operations.length;
    if (_length > 0 && _operations.operations[_length - 1].executionId == _executionId) {
      AccountOperation memory _accountOperation = _operations.operations[_length - 1];
      return _accountOperation.amount;
    } else {
      return 0;
    }
  }

  /// @dev Internal function to handle failure fallback except deposit and redeem.
  /// @param _to The target address in original call.
  /// @param _data The calldata pass to target address in original call.
  function _customFallback(address _to, bytes memory _data) internal virtual {}
}


// : MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

//import"../interfaces/IUChildERC20.sol";

//import"../layer1/PolygonACRVProxy.sol";
//import"./Layer2CRVDepositor.sol";

/// @notice The implementation of Layer2CRVDepositor for Polygon
///   + bridge aCRV using Multichain (Previously Anyswap)
///   + bridge CRV using Polygon Bridge.
/// @dev The address of this contract should be the same as corresponding Layer1ACRVProxy.
contract PolygonCRVDepositor is Layer2CRVDepositor {
  event AsyncExit(uint256 indexed _executionId);

  function asyncExit(bytes calldata _inputData) external payable onlyWhitelist SponsorCrossCallFee {
    CrossChainOperationData memory _operation = depositOperation;
    AsyncOperationStatus _status = asyncDepositStatus;
    // solhint-disable-next-line reason-string
    require(_status == AsyncOperationStatus.Pending, "PolygonCRVDepositor: no pending deposit");

    // cross chain call deposit
    bytes memory _data = abi.encodeWithSelector(PolygonACRVProxy.exitFromBridge.selector, _inputData);
    ICrossChainCallProxy(crossChainCallProxy).crossChainCall(layer1Proxy, _data, address(0), 1);

    emit AsyncExit(_operation.executionId);
  }

  // @todo add asyncExitAndRedeem

  /********************************** Internal Functions **********************************/

  /// @dev See {Layer2CRVDepositorBase-_customFallback}
  function _customFallback(address, bytes memory) internal virtual override {
    // solhint-disable-next-line reason-string
    revert("Layer2CRVDepositor: invalid fallback call");
  }

  /// @dev See {CrossChainCallBase-_bridgeCRV}
  function _bridgeCRV(address _recipient, uint256 _totalAmount)
    internal
    virtual
    override
    returns (uint256 _bridgeAmount, uint256 _totalFee)
  {
    // solhint-disable-next-line reason-string
    require(_recipient == address(this), "PolygonCRVDepositor: only bridge to self");

    CrossChainInfo memory _info = CRVCrossChainInfo;
    // solhint-disable-next-line reason-string
    require(_totalAmount >= _info.minCrossChainAmount, "PolygonCRVDepositor: insufficient cross chain amount");
    // we don't need to check upper limit here.

    IUChildERC20(crv).withdraw(_totalAmount);

    _bridgeAmount = _totalAmount;
    _totalFee = 0;
  }
}


