/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
      address indexed sender,
      uint amount0In,
      uint amount1In,
      uint amount0Out,
      uint amount1Out,
      address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}



/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

interface ITokenConversionStorage {
  function exchangesInfo(uint256 index) external returns(
    string memory name,
    address router,
    address factory
  );
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;
//////import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//////import"./IUniswapV2Pair.sol";

interface ITokenConversionLibrary {
  function convertTokenToToken(
    address _storageAddress,
    address payable _toWhomToIssue,
    address _fromToken,
    address _toToken,
    uint256 _amount,
    uint256 _minOutputAmount
  ) external returns (uint256);
  function convertArrayOfTokensToToken(
    address _storageAddress,
    address[] memory _tokens,
    address _convertToToken,
    address payable _toWhomToIssue,
    uint256 _minTokensRec
  ) external returns (uint256);
  function estimateTokenToToken(
    address _storageAddress,
    address _fromToken,
    address _toToken,
    uint256 _amount
  ) external view returns (uint256);
  function estimatePoolOutput(
    address _storageAddress,
    IUniswapV2Pair _lpPool,
    address _toToken,
    uint256 _lpAmount
  ) external view returns (uint256 amountOut);
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

interface IStrategy {
  function stake(address, address, uint256, uint256, bytes memory) external;
  function unstake(address, uint256, uint256, bytes memory) external;
  function claimRewards(address, uint256) external;
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

//////import"./ITokenConversionLibrary.sol";
//////import"./ITokenConversionStorage.sol";

interface IFactory {
  struct Exchange{
    string name;
    address inContractAddress;
    address outContractAddress;
  }

  struct RiskLevel {
    uint8 value;
    bool wholePlatform;
  }

  function yieldToken() external returns(address yieldToken);
  function isWhitelisted(address _target) external returns(bool isWhitelisted);
  function assertPoolApproved(address _stakeContract, address _liqudityPool, uint8 _riskLevel) external view;
  function enableApproveAssert() external;
  function claimInNativeSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function claimInYieldSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function getStrategy(uint256 _index) external view returns(address strategy);
  function getYieldStakeSettings() view external returns(
    address yieldStakeContract,
    address yieldStakePair,
    address yieldStakeRouter,
    address yieldStakeFactory,
    uint256 yieldStakeStrategy,
    uint256 yieldStakeLockSeconds,
    address yieldStakeRewardToken
  );
  function getTokenConversion() external view returns(
    ITokenConversionLibrary _library,
    ITokenConversionStorage _storage
  );
  function exchange() external view returns(address);
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
        assembly {
            size := extcodesize(account)
        }
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"../IERC20.sol";
//////import"../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

//////import"@openzeppelin/contracts/token/ERC20/IERC20.sol";

//////import"./../../Interfaces/IFactory.sol";
//////import"./../../Interfaces/IUniswapV2Pair.sol";
//////import"./../../Interfaces/ITokenConversionLibrary.sol";
//////import"./../../Interfaces/ITokenConversionStorage.sol";
//////import"./../../Interfaces/IStrategy.sol";

library PersonalContractLibrary {
  /**
  @notice Estimates current value after claim pending rewards of investment in invetment.token tokens
  @param tokenConversionLibrary library with ITokenConversion interface
  @param tokenConversionStorage store of pathes for exchage
  @param _lpPool pool in which investment currently
  @param _lpAmount expected amount of liquidity pool tokens
  @param _rewards addresses of possible rewards
  @param _toToken pool in which investment currently
  @return estimatedLiquidity estimated output of liquidity pool tokens in invetment.token
  @return estimatedRewards estimated output of rewards in invetment.token
  */
  function estimateInvestment(
    ITokenConversionLibrary tokenConversionLibrary,
    address tokenConversionStorage,
    IUniswapV2Pair _lpPool,
    uint256 _lpAmount,
    address[] calldata _rewards,
    address _toToken
  ) external view returns (
    uint256 estimatedLiquidity,
    uint256 estimatedRewards
  ) {
    for (uint256 i = 0; i < _rewards.length; i++) {
      uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
      estimatedRewards += tokenConversionLibrary.estimateTokenToToken(
        tokenConversionStorage,
        _rewards[i],
        _toToken,
        balance
      );
    }

    estimatedLiquidity = tokenConversionLibrary.estimatePoolOutput(
      tokenConversionStorage,
      _lpPool,
      _toToken,
      _lpAmount
    );
  }

  /**
  @notice Claim rewards from staking pool
  @param _strategy contract with claim rewards logic
  @param _stakeContractAddress address of staking contract
  @param _pid masterchef pid
  */
  function claimRewards(
    IStrategy _strategy,
    address _stakeContractAddress,
    uint256 _pid
  ) internal {
    (bool status, ) = address(_strategy).delegatecall(
      abi.encodeWithSelector(_strategy.claimRewards.selector, _stakeContractAddress, _pid)
    );
    require(status, 'claimRewards call failed');
  }

  /**
  @notice convert any tokens to any tokens.
  @param _toWhomToIssue is address of personal contract for this user
  @param _tokenToExchange address of token witch will be converted
  @param _tokenToConvertTo address of token witch will be returned
  @param _amount how much will be converted
  */
  function convertTokenToToken(
    IFactory _factory,
    address _toWhomToIssue,
    address _tokenToExchange,
    address _tokenToConvertTo,
    uint256 _amount,
    uint256 _minOutputAmount
  ) internal returns (uint256) {       
    (
      ITokenConversionLibrary tokenConversion,
      ITokenConversionStorage conversionStorage
    ) = _factory.getTokenConversion();

    (bool status, bytes memory result) = address(tokenConversion).delegatecall(
      abi.encodeWithSelector(
        tokenConversion.convertTokenToToken.selector,
        conversionStorage,
        _toWhomToIssue,
        _tokenToExchange,
        _tokenToConvertTo,
        _amount,
        _minOutputAmount
      )
    );

    require(status, 'convertTokenToToken call failed');
    return abi.decode(result, (uint256));
  }

  function approve(address _token, address _spender, uint256 _amount) internal {
    // in case SafeERC20: approve from non-zero to non-zero allowance
    IERC20(_token).approve(_spender, 0);
    IERC20(_token).approve(_spender, _amount);
  }
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

interface IExecutable {
  function execute(bytes calldata data) external;
}



/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

//////import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//////import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//////import"./../Interfaces/IFactory.sol";

abstract contract ExecutableParams {
  using SafeERC20 for IERC20;

  struct Investment {
    address token;
    uint256 initialAmount;
  }

  struct StakedReward {
    uint256 amount;
    uint256 createdAt;
    uint256 unlockAt;
  }

  struct Pool {
    address stakeContract;
    address liquidityPool;
  }

  uint256 internal constant percentageDecimals = 10000;

  Investment public investment;
  Pool public currentPool;
  mapping (address => mapping (uint256 => StakedReward[])) public stakedRewards;

  IFactory internal factory;
  address internal investor;
  address internal strategist;
  address internal yieldToken;
  uint8 internal riskLevel;
  bool public compoundEnabled;

  /**
  * @dev Throws if called by any account other than the strategist.
  */
  modifier onlyStrategist() {
      require(msg.sender == strategist, "not allowed");
      _;
  }

  modifier onlyInvestor() {
    require(msg.sender == investor, "not allowed");
    _;
  }

  modifier strategistOrInvestor() {
    require(msg.sender == strategist || msg.sender == investor, "not allowed");
    _;
  }
}




/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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


/** 
 *  SourceUnit: d:\projects\Aplicature\core-smart-contrats-2\contracts\PersonalContract.sol
*/

////// -FLATTEN-SUPPRESS-WARNING: GPLv2
pragma solidity 0.8.9;

//////import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//////import"@openzeppelin/contracts/security/ReentrancyGuard.sol";

//////import"./executable/ExecutableParams.sol";
//////import"./executable/interfaces/IExecutable.sol";
//////import"./Interfaces/IFactory.sol";
//////import"./Interfaces/IUniswapV2Pair.sol";
//////import"./Interfaces/IStrategy.sol";
//////import"./executable/libraries/PersonalContractLibrary.sol";

contract PersonalContract is ExecutableParams, ReentrancyGuard {
  event CompoundChanged(bool status);

  function initialize (
		address _investor, 
		address _strategist,
		uint8 _riskLevel,
    bool _compoundEnabled,
		address _yieldToken,
		address _investmentToken
	) external {
		assert(address(factory) == address(0));
		assert(_investor != address(0));
		assert(_strategist != address(0));

		factory = IFactory(msg.sender);
		investor = _investor;
		strategist = _strategist;
		riskLevel = _riskLevel;
    compoundEnabled = _compoundEnabled;
		yieldToken = _yieldToken;
		investment = Investment(_investmentToken, 0);
  }

  /**
  @notice execute delegatecall to execute method of target contract 
  @param target contract with IExecutable interface
  @param data data for delegatecall
  */
  function execute(IExecutable target, bytes calldata data) external nonReentrant {
		require(factory.isWhitelisted(address(target)), "PL: target is not whitelisted");

    (bool status, ) = address(target).delegatecall(abi.encodeWithSelector(target.execute.selector, data));
    require(status, "PL: call failed");
  }

  function setCompoundEnable(bool status) external onlyInvestor {
    compoundEnabled = status;
    emit CompoundChanged(status);
  }

  /**
  @notice Estimates current value after claim pending rewards of investment in invetment.token tokens
  @param _lpPool pool in which investment currently
  @param _lpAmount expected amount of liquidity pool tokens
  @param _poolTemplate used in claimRewards function
  @param _stakeContractAddress used in claimRewards function
  @param _pid used in claimRewards function
  @param _rewards addresses of possible rewards
  @param _toToken pool in which investment currently
  @return estimatedLiquidity estimated output of liquidity pool tokens in invetment.token
  @return estimatedRewards estimated output of rewards in invetment.token
  */
  function estimatePendingInvestment(
    IUniswapV2Pair _lpPool,
    uint256 _lpAmount,
    uint256 _poolTemplate,
    address _stakeContractAddress,
    uint256 _pid,
    address[] calldata _rewards,
    address _toToken
  ) external returns (
    uint256 estimatedLiquidity,
    uint256 estimatedRewards
  ) {
    PersonalContractLibrary.claimRewards(IStrategy(factory.getStrategy(_poolTemplate)), _stakeContractAddress, _pid);

    (ITokenConversionLibrary tokenConversion, ITokenConversionStorage conversionStorage) = factory.getTokenConversion();
    return PersonalContractLibrary.estimateInvestment(
      tokenConversion,
      address(conversionStorage),
      _lpPool,
      _lpAmount,
      _rewards,
      _toToken
    );
  }

  /**
  @notice Withdraw any IERC20 token to investor
  @param token address of token to withdraw
  @param amount amount of token on contract
  */
  function withdrawToken(IERC20 token, uint256 amount) onlyStrategist external {
    token.transfer(investor, amount);
  }
}