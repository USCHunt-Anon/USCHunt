// File: contracts/interfaces/IUniRouter.sol

pragma solidity >=0.6.2;

interface IUniRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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
     * IMPORTANT: because control is transferred to `recipient`, care must be
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

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol


pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


pragma solidity ^0.8.0;


/**
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
        return msg.data;
    }
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// File: contracts/BewSwapImplement.sol

pragma solidity ^0.8.0;








contract BewSwap is Initializable, ContextUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 public constant feePctScale = 1e6;
    uint256 public safeMinGas;

    uint256 private _feePct;

    address private _owner;
    address private _pendingOwner;

    address payable private _feeAccount;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);
    event FeePctUpdated(uint256 indexed previousFeePct, uint256 indexed newFeePct);
    event FeeAccountUpdated(address indexed previousFeeAccount, address indexed newFeeAccount);
    event FeeReceived(address indexed token, uint256 indexed amount);


    constructor() public {
    }



    function initialize(address owner, address payable feeAccount, uint256 feePct) external {
        __BewSwap_init(owner, feeAccount, feePct);
    }

    function __BewSwap_init(address owner, address payable feeAccount, uint256 feePct) internal initializer {
        __Context_init_unchained();
        __ReentrancyGuard_init_unchained();
        __BewSwap_init_unchained(owner, feeAccount, feePct);
    }

    function __BewSwap_init_unchained(address owner, address payable feeAccount, uint256 feePct) internal initializer {
        require(feePct <= feePctScale, "BewSwap: fee pct is larger than fee pct scale");
        require(owner != address(0), "BewSwap: owner is the zero address");
        require(feeAccount != address(0), "BewSwap: fee account is the zero address");

        _owner = owner;
        _feePct = feePct;
        _feeAccount = feeAccount;
        safeMinGas = 2300;

        emit OwnershipTransferred(address(0), owner);
        emit FeePctUpdated(0, feePct);
        emit FeeAccountUpdated(address(0), feeAccount);
    }


    fallback() external payable {}

    function owner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "BewSwap: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "BewSwap: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _pendingOwner = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == _pendingOwner, "BewSwap: invalid new owner");
        emit OwnershipAccepted(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }

    function feePct() external view returns (uint256) {
        return _feePct;
    }

    function updateFeePct(uint256 newFeePct) external onlyOwner {
        require(newFeePct != _feePct, "BewSwap: new fee pct is the same as the current fee pct");
        require(newFeePct <= feePctScale, "BewSwap: new fee pct should larger than fee pct scale");
        emit FeePctUpdated(_feePct, newFeePct);
        _feePct = newFeePct;
    }

    function feeAccount() external view returns (address) {
        return _feeAccount;
    }

    function updateSafeMinGas(uint256 _safeMinGas) external onlyOwner {
        require(2300 <= _safeMinGas, "BewSwap: 2300 <= _safeMinGas");
        safeMinGas = _safeMinGas;
    }

    function updateFeeAccount(address payable newFeeAccount) external onlyOwner {
        require(newFeeAccount != address(0), "BewSwap: new fee account is the zero address");
        require(newFeeAccount != _feeAccount, "BewSwap: new fee account is the same as current fee account");

        emit FeeAccountUpdated(_feeAccount, newFeeAccount);
        _feeAccount = newFeeAccount;
    }

    function swapExactTokensForTokens(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external nonReentrant {
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOutMin, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        // charge fee and transfer balance to to address
        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }
    }

    function swapTokensForExactTokens(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external nonReentrant {
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);

        router.swapTokensForExactTokens(amountOut, amountInMax , path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOut, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        // charge fee and transfer balance to to address
        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer( _feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }

        // return remain from tokens
        uint256 fromTokenBalance = fromToken.balanceOf(address(this));
        if (fromTokenBalance != 0) {
            fromToken.safeTransfer(to, fromTokenBalance);
        }
    }

    function swapExactETHForTokens(
        IUniRouter router,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable nonReentrant {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(amountOutMin, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOutMin, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        // charge fee and transfer balance to to address
        toToken.safeTransfer(to, remainAmount);
        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(toToken), feeAmount);
        }
    }

    function swapTokensForExactETH(
        IUniRouter router,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address payable to, uint deadline
    ) external nonReentrant {
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountInMax);
        fromToken.safeIncreaseAllowance(address(router), amountInMax);

        router.swapTokensForExactETH(amountOut, amountInMax, path, address(this), deadline);

        uint256 ethBalance = address(this).balance;
        require(ethBalance >= amountOut, "BewSwap: get less eth than expected");

        uint256 feeAmount = (ethBalance * _feePct) / feePctScale;
        uint256 remainAmount = ethBalance - feeAmount;

        // charge fee and transfer balance to to address
        _safeTransferETH(to, remainAmount);
        if (feeAmount != 0) {
            _safeTransferETH(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }

        // return remain from tokens
        uint256 fromTokenBalance = fromToken.balanceOf(address(this));
        if (fromTokenBalance != 0) {
            fromToken.safeTransfer(to, fromTokenBalance);
        }
    }

    function swapExactTokensForETH(
        IUniRouter router,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address payable to,
        uint deadline
    ) external nonReentrant {
        IERC20Upgradeable fromToken = IERC20Upgradeable(path[0]);
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        fromToken.safeIncreaseAllowance(address(router), amountIn);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, address(this), deadline);

        uint256 ethBalance = address(this).balance;
        require(ethBalance >= amountOutMin, "BewSwap: get less eth than expected");

        uint256 feeAmount = (ethBalance * _feePct) / feePctScale;
        uint256 remainAmount = ethBalance - feeAmount;

        // charge fee and transfer balance to to address
        _safeTransferETH(to, remainAmount);
        if (feeAmount != 0) {
            _safeTransferETH(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }
    }

    function swapETHForExactTokens(
        IUniRouter router,
        uint amountOut,
        address[] calldata path,
        address payable to,
        uint deadline
    ) external payable nonReentrant {
        router.swapETHForExactTokens{value: msg.value}(amountOut, path, address(this), deadline);

        IERC20Upgradeable toToken = IERC20Upgradeable(path[path.length-1]);
        uint256 toTokenBalance = toToken.balanceOf(address(this));
        require(toTokenBalance >= amountOut, "BewSwap: get less to tokens than expected");

        uint256 feeAmount = (toTokenBalance * _feePct) / feePctScale;
        uint256 remainAmount = toTokenBalance - feeAmount;

        // charge fee and transfer balance to to address
        if (feeAmount != 0) {
            toToken.safeTransfer(_feeAccount, feeAmount);
            emit FeeReceived(address(0), feeAmount);
        }
        toToken.safeTransfer(to, remainAmount);

        // return remain eth
        uint256 ethBalance = address(this).balance;
        if (ethBalance != 0) {
            _safeTransferETH(to, ethBalance);
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: safeMinGas, value: value}("");
        require(success, "BewSwap: transfer eth failed");
    }

    uint256[50] private __gap;
}