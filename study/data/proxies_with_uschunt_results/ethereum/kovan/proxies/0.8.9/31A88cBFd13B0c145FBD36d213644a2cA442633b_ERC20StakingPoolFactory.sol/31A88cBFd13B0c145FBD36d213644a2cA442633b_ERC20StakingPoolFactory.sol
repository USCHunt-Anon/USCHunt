/**
 *Submitted for verification at Etherscan.io on 2022-03-28
*/

// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/proxy/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

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
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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


// File contracts/BaseStakingPool.sol


pragma solidity 0.8.9;





abstract contract BaseStakingPool is Ownable, ReentrancyGuard, Initializable
{
	using SafeERC20 for IERC20;

	struct RewardInfo {
		uint256 index;
		uint256 rewardBalance;
		uint256 rewardPerSec;
		uint256 accRewardPerShare18;
	}

	struct UserRewardInfo {
		uint256 accReward;
		uint256 rewardDebt18;
	}

	struct UserInfo1 {
		uint256 shares;
		mapping(address => UserRewardInfo) userRewardInfo;
	}

	uint256 public constant MAX_REWARD_TOKENS = 10;

	uint256 public totalShares;
	uint256 public lastRewardTimestamp;
	address[] public rewardToken;
	mapping(address => RewardInfo) public rewardInfo;
	mapping(address => UserInfo1) public userInfo1;

	function initialize(address _owner, address _token) public virtual;

	function _initialize(address _owner) internal
	{
		_transferOwnership(_owner);
		lastRewardTimestamp = block.timestamp;
	}

	function rewardTokenCount() external view returns (uint256 _rewardTokenCount)
	{
		return rewardToken.length;
	}

	function userRewardInfo(address _account, address _rewardToken) external view returns (UserRewardInfo memory _userRewardInfo)
	{
		return userInfo1[_account].userRewardInfo[_rewardToken];
	}

	function pendingReward(address _account, address _rewardToken) external view returns (uint256 _pendingReward)
	{
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		uint256 _accRewardPerShare18 = _rewardInfo.accRewardPerShare18;
		if (block.timestamp > lastRewardTimestamp) {
			if (totalShares > 0) {
				uint256 _reward = (block.timestamp - lastRewardTimestamp) * _rewardInfo.rewardPerSec;
				uint256 _maxReward = _freeBalance(_rewardToken);
				if (_reward > _maxReward) _reward = _maxReward;
				if (_reward > 0) {
					_accRewardPerShare18 += _reward * 1e18 / totalShares;
				}
			}
		}
		UserInfo1 storage _userInfo = userInfo1[_account];
		UserRewardInfo storage _userRewardInfo = _userInfo.userRewardInfo[_rewardToken];
		return _userRewardInfo.accReward + (_userInfo.shares * _accRewardPerShare18 - _userRewardInfo.rewardDebt18) / 1e18;
	}

	function harvestAll() external nonReentrant
	{
		UserInfo1 storage _userInfo = userInfo1[msg.sender];
		uint256 _shares = _userInfo.shares;
		if (_shares > 0) {
			_updatePool();
			_updateUserReward(_userInfo, _shares, _shares);
		}
		_harvestAllUserReward(msg.sender, _userInfo);
		emit HarvestAll(msg.sender);
	}

	function harvest(address _rewardToken) external nonReentrant
	{
		UserInfo1 storage _userInfo = userInfo1[msg.sender];
		uint256 _shares = _userInfo.shares;
		if (_shares > 0) {
			_updatePool();
			_updateUserReward(_userInfo, _shares, _shares);
		}
		_harvestUserReward(msg.sender, _userInfo, _rewardToken);
	}

	function addRewardToken(address _rewardToken) external onlyOwner
	{
		_updatePool();
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		require(_rewardInfo.index == 0, "duplicate token");
		uint256 _length = rewardToken.length;
		require(_length < MAX_REWARD_TOKENS, "limit reached");
		rewardToken.push(_rewardToken);
		_rewardInfo.index = _length + 1;
		emit AddRewardToken(_rewardToken);
	}

	function removeRewardToken(address _rewardToken) external onlyOwner
	{
		_updatePool();
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		uint256 _index = _rewardInfo.index;
		require(_index > 0, "unknown token");
		require(_rewardInfo.rewardBalance == 0, "pending reward");
		_rewardInfo.index = 0;
		_rewardInfo.rewardPerSec = 0;
		_rewardInfo.accRewardPerShare18 = 0;
		uint256 _length = rewardToken.length;
		if (_index < _length) {
			address _otherRewardToken = rewardToken[_length - 1];
			rewardInfo[_otherRewardToken].index = _index;
			rewardToken[_index - 1] = _otherRewardToken;
		}
		rewardToken.pop();
		emit RemoveRewardToken(_rewardToken);
	}

	function updateRewardPerSec(address _rewardToken, uint256 _rewardPerSec) external onlyOwner
	{
		_updatePool();
		RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
		require(_rewardInfo.index > 0, "unknown token");
		_rewardInfo.rewardPerSec = _rewardPerSec;
		emit UpdateRewardPerSec(_rewardToken, _rewardPerSec);
	}

	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		_updatePool();
		uint256 _amount = _freeBalance(_token);
		IERC20(_token).safeTransfer(msg.sender, _amount);
		emit RecoverFunds(_token, _amount);
	}

	function _deposit(address _account, uint256 _shares) internal
	{
		if (_shares > 0) {
			UserInfo1 storage _userInfo1 = userInfo1[_account];
			uint256 _oldShares = _userInfo1.shares;
			uint256 _newShares = _oldShares + _shares;
			_updatePool();
			_updateUserReward(_userInfo1, _oldShares, _newShares);
			_userInfo1.shares = _newShares;
			totalShares += _shares;
		}
	}

	function _withdraw(address _account, uint256 _shares) internal
	{
		if (_shares > 0) {
			UserInfo1 storage _userInfo1 = userInfo1[_account];
			uint256 _oldShares = _userInfo1.shares;
			uint256 _newShares = _oldShares - _shares;
			_updatePool();
			_updateUserReward(_userInfo1, _oldShares, _newShares);
			_userInfo1.shares = _newShares;
			totalShares -= _shares;
		}
	}

	function _emergencyWithdraw(address _account) internal
	{
		UserInfo1 storage _userInfo1 = userInfo1[_account];
		uint256 _shares = _userInfo1.shares;
		if (_shares > 0) {
			_discardUserReward(_userInfo1);
			_userInfo1.shares = 0;
			totalShares -= _shares;
		}
	}

	function _exit(address _account) internal
	{
		UserInfo1 storage _userInfo1 = userInfo1[_account];
		uint256 _shares = _userInfo1.shares;
		if (_shares > 0) {
			_updatePool();
			_updateUserReward(_userInfo1, _shares, 0);
			_userInfo1.shares = 0;
			totalShares -= _shares;
		}
		_harvestAllUserReward(_account, _userInfo1);
	}

	function _adjust(address _account, uint256 _negativeShares, uint256 _positiveShares) internal
	{
		if (_negativeShares != _positiveShares) {
			UserInfo1 storage _userInfo1 = userInfo1[_account];
			uint256 _oldShares = _userInfo1.shares;
			uint256 _newShares = _oldShares - _negativeShares + _positiveShares;
			_updatePool();
			_updateUserReward(_userInfo1, _oldShares, _newShares);
			_userInfo1.shares = _newShares;
			totalShares = totalShares - _negativeShares + _positiveShares;
		}
	}

	function _freeBalance(address _token) internal view virtual returns(uint256 _balance)
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		_amount -= rewardInfo[_token].rewardBalance;
		return _amount;
	}

	function _updatePool() internal
	{
		if (block.timestamp > lastRewardTimestamp) {
			if (totalShares > 0) {
				uint256 _ellapsed = block.timestamp - lastRewardTimestamp;
				uint256 _length = rewardToken.length;
				for (uint256 _i = 0; _i < _length; _i++) {
					address _rewardToken = rewardToken[_i];
					RewardInfo storage _rewardInfo = rewardInfo[_rewardToken];
					uint256 _reward = _ellapsed * _rewardInfo.rewardPerSec;
					uint256 _maxReward = _freeBalance(_rewardToken);
					if (_reward > _maxReward) _reward = _maxReward;
					if (_reward > 0) {
						_rewardInfo.rewardBalance += _reward;
						_rewardInfo.accRewardPerShare18 += _reward * 1e18 / totalShares;
					}
				}
			}
			lastRewardTimestamp = block.timestamp;
		}
	}

	function _discardUserReward(UserInfo1 storage _userInfo) private
	{
		uint256 _length = rewardToken.length;
		for (uint256 _i = 0; _i < _length; _i++) {
			_userInfo.userRewardInfo[rewardToken[_i]].rewardDebt18 = 0;
		}
	}

	function _updateUserReward(UserInfo1 storage _userInfo, uint256 _oldShares, uint256 _newShares) private
	{
		uint256 _length = rewardToken.length;
		for (uint256 _i = 0; _i < _length; _i++) {
			address _rewardToken = rewardToken[_i];
			uint256 _accRewardPerShare18 = rewardInfo[_rewardToken].accRewardPerShare18;
			UserRewardInfo storage _userRewardInfo = _userInfo.userRewardInfo[_rewardToken];
			if (_oldShares > 0) {
				_userRewardInfo.accReward += (_oldShares * _accRewardPerShare18 - _userRewardInfo.rewardDebt18) / 1e18;
			}
			_userRewardInfo.rewardDebt18 = _newShares * _accRewardPerShare18;
		}
	}

	function _harvestAllUserReward(address _account, UserInfo1 storage _userInfo) private
	{
		uint256 _length = rewardToken.length;
		for (uint256 _i = 0; _i < _length; _i++) {
			_harvestUserReward(_account, _userInfo, rewardToken[_i]);
		}
	}

	function _harvestUserReward(address _account, UserInfo1 storage _userInfo, address _rewardToken) private
	{
		UserRewardInfo storage _userRewardInfo = _userInfo.userRewardInfo[_rewardToken];
		uint256 _reward = _userRewardInfo.accReward;
		if (_reward > 0) {
			_userRewardInfo.accReward = 0;
			IERC20(_rewardToken).safeTransfer(_account, _reward);
			rewardInfo[_rewardToken].rewardBalance -= _reward;
			emit Harvest(_account, _rewardToken, _reward);
		}
	}

	event AddRewardToken(address indexed _rewardToken);
	event RemoveRewardToken(address indexed _rewardToken);
	event UpdateRewardPerSec(address indexed _rewardToken, uint256 _rewardPerSec);
	event RecoverFunds(address indexed _token, uint256 _amount);
	event HarvestAll(address indexed _account);
	event Harvest(address indexed _account, address indexed _token, uint256 _amount);
}


// File @openzeppelin/contracts/proxy/beacon/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}


// File @openzeppelin/contracts/proxy/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}


// File @openzeppelin/contracts/proxy/ERC1967/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;



/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _upgradeTo(newImplementation);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}


// File @openzeppelin/contracts/proxy/beacon/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;



/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}


// File @openzeppelin/contracts/proxy/beacon/[email protected]


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/UpgradeableBeacon.sol)

pragma solidity ^0.8.0;



/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}


// File contracts/BaseStakingPoolFactory.sol


pragma solidity 0.8.9;



abstract contract BaseStakingPoolFactory is UpgradeableBeacon
{
	bytes32 private immutable hash_;

	constructor() UpgradeableBeacon(_createPoolImpl())
	{
		hash_ = keccak256(abi.encodePacked(type(BeaconProxy).creationCode, abi.encode(address(this), new bytes(0))));
	}

	function _createPoolImpl() internal virtual returns (address _pool);

	function computePoolAddress(address _account, uint96 _index) external view returns (address _pool)
	{
		bytes32 _salt = bytes32(uint256(_index) << 160 | uint256(uint160(_account)));
		return Create2.computeAddress(_salt, hash_);
	}

	function createPool(uint96 _index, address _token) external returns (address _pool)
	{
		bytes32 _salt = bytes32(uint256(_index) << 160 | uint256(uint160(msg.sender)));
		_pool = address(new BeaconProxy{salt: _salt}(address(this), new bytes(0)));
		BaseStakingPool(_pool).initialize(msg.sender, _token);
		emit CreatePool(msg.sender, _index, _pool);
		return _pool;
	}

	event CreatePool(address indexed _account, uint96 indexed _index, address indexed _pool);
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC1155/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC1155/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}


// File contracts/LockCycle.sol


pragma solidity 0.8.9;

abstract contract LockCycle
{
	struct LockInfo {
		uint256 day;
		uint256 cycle;
		uint256 factor;
	}

	uint256 public constant MAX_CYCLE = 365;

	mapping(address => LockInfo) public lockInfo;

	function _adjustLock(address _account, uint256 _newCycle) internal returns (uint256 _oldFactor, uint256 _newFactor)
	{
		uint256 _today = block.timestamp / 1 days;
		LockInfo storage _lockInfo = lockInfo[_account];
		uint256 _oldCycle = _lockInfo.cycle;
		if (_newCycle < _oldCycle) {
			uint256 _day = _lockInfo.day;
			uint256 _base1 = _day % _oldCycle;
			uint256 _base2 = _today % _oldCycle;
			uint256 _days = _base2 > _base1 ? _base2 - _base1 : _base2 < _base1 ? _base2 + _oldCycle - _base1 : _day < _today ? _oldCycle : 0;
			uint256 _minCycle = _oldCycle - _days;
			require(_newCycle >= _minCycle, "below minimum");
		}
		require(_newCycle <= MAX_CYCLE, "above maximum");
		_oldFactor = _lockInfo.factor;
		_newFactor = 1e18 * _newCycle / MAX_CYCLE;
		_lockInfo.day = _today;
		_lockInfo.cycle = _newCycle;
		_lockInfo.factor = _newFactor;
		return (_oldFactor, _newFactor);
	}

	function _checkLock(address _account) internal view returns (uint256 _factor)
	{
		uint256 _today = block.timestamp / 1 days;
		LockInfo storage _lockInfo = lockInfo[_account];
		uint256 _cycle = _lockInfo.cycle;
		if (_cycle > 0) {
			uint256 _day = _lockInfo.day;
			require(_today > _day && _today % _cycle == _day % _cycle, "not available");
		}
		return _lockInfo.factor;
	}

	function _pushLock(address _account) internal returns (uint256 _factor)
	{
		uint256 _today = block.timestamp / 1 days;
		LockInfo storage _lockInfo = lockInfo[_account];
		_lockInfo.day = _today;
		return _lockInfo.factor;
	}
}


// File contracts/ERC1155StakingPool.sol


pragma solidity 0.8.9;





contract ERC1155StakingPool is LockCycle, BaseStakingPool, ERC1155Holder
{
	using SafeERC20 for IERC20;

	struct UserTokenInfo {
		uint256 amount;
	}

	struct UserInfo2 {
		uint256 userTokenCount;
		mapping(uint256 => UserTokenInfo) userTokenInfo;
	}

	struct TokenInfo {
		uint256 amount;
		int256 weight;
	}

	address public collection;
	uint256 public tokenCount;
	mapping(uint256 => TokenInfo) public tokenInfo;
	uint256 public poolMinPerUser;
	uint256 public poolMaxPerUser;

	mapping(address => UserInfo2) public userInfo2;

	constructor(address _owner, address _collection)
	{
		initialize(_owner, _collection);
	}

	function initialize(address _owner, address _collection) public override initializer
	{
		_initialize(_owner);
		collection = _collection;
	}

	function lock(uint256 _cycle) external
	{
		(uint256 _oldFactor, uint256 _newFactor) = _adjustLock(msg.sender, _cycle);
		UserInfo1 storage _userInfo1 = userInfo1[msg.sender];
		uint256 _shares = _userInfo1.shares;
		emit Lock(msg.sender, _cycle);
		if (_shares > 0 && _oldFactor != _newFactor) {
			_adjust(msg.sender, _shares + _shares * _oldFactor / 1e18, _shares + _shares * _newFactor / 1e18);
		}
	}

	function deposit(uint256[] calldata _ids, uint256[] calldata _amounts) external nonReentrant
	{
		uint256 _count = _ids.length;
		require(_amounts.length == _count, "invalid length");
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _userTokenCount = 0;
		for (uint256 _i = 0; _i < _count; _i++) {
			uint256 _id = _ids[_i];
			uint256 _amount = _amounts[_i];
			_userInfo2.userTokenInfo[_id].amount += _amount;
			tokenInfo[_id].amount += _amount;
			_userTokenCount += _amount;
		}
		uint256 _oldAmount = _userInfo2.userTokenCount;
		uint256 _newAmount = _oldAmount + _userTokenCount;
		if (_newAmount > 0) {
			require(poolMinPerUser <= _newAmount && _newAmount <= poolMaxPerUser, "invalid balance");
		}
		if (_userTokenCount > 0) {
			_userInfo2.userTokenCount = _newAmount;
			IERC1155(collection).safeBatchTransferFrom(msg.sender, address(this), _ids, _amounts, new bytes(0));
			tokenCount += _userTokenCount;
		}
		emit Deposit(msg.sender, _ids, _amounts);
		{
			uint256 _factor = _pushLock(msg.sender);
			uint256 _shares = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				_shares += _amounts[_i] * uint256(1e18 + tokenInfo[_ids[_i]].weight);
			}
			_deposit(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function withdraw(uint256[] calldata _ids, uint256[] calldata _amounts) external nonReentrant
	{
		uint256 _factor = _checkLock(msg.sender);
		uint256 _count = _ids.length;
		require(_amounts.length == _count, "invalid length");
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _userTokenCount = 0;
		for (uint256 _i = 0; _i < _count; _i++) {
			uint256 _id = _ids[_i];
			uint256 _amount = _amounts[_i];
			UserTokenInfo storage _userTokenInfo = _userInfo2.userTokenInfo[_id];
			require(_amount <= _userTokenInfo.amount, "insufficient balance");
			_userTokenInfo.amount -= _amount;
			tokenInfo[_id].amount -= _amount;
			_userTokenCount += _amount;
		}
		uint256 _oldAmount = _userInfo2.userTokenCount;
		uint256 _newAmount = _oldAmount - _userTokenCount;
		if (_newAmount > 0) {
			require(poolMinPerUser <= _newAmount && _newAmount <= poolMaxPerUser, "invalid balance");
		}
		if (_userTokenCount > 0) {
			_userInfo2.userTokenCount = _newAmount;
			IERC1155(collection).safeBatchTransferFrom(address(this), msg.sender, _ids, _amounts, new bytes(0));
			tokenCount -= _userTokenCount;
		}
		emit Withdraw(msg.sender, _ids, _amounts);
		{
			uint256 _shares = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				_shares += _amounts[_i] * uint256(1e18 + tokenInfo[_ids[_i]].weight);
			}
			_withdraw(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function emergencyWithdraw(uint256[] calldata _ids) external nonReentrant
	{
		_checkLock(msg.sender);
		uint256 _count = _ids.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _userTokenCount = 0;
		uint256[] memory _amounts = new uint256[](_count);
		for (uint256 _i = 0; _i < _count; _i++) {
			uint256 _id = _ids[_i];
			UserTokenInfo storage _userTokenInfo = _userInfo2.userTokenInfo[_id];
			uint256 _amount = _userTokenInfo.amount;
			_userTokenInfo.amount = 0;
			tokenInfo[_id].amount -= _amount;
			_userTokenCount += _amount;
			_amounts[_i] = _amount;
		}
		uint256 _oldAmount = _userInfo2.userTokenCount;
		require(_userTokenCount == _oldAmount, "incomplete list");
		if (_userTokenCount > 0) {
			_userInfo2.userTokenCount = 0;
			IERC1155(collection).safeBatchTransferFrom(address(this), msg.sender, _ids, _amounts, new bytes(0));
			tokenCount -= _userTokenCount;
		}
		emit EmergencyWithdraw(msg.sender, _ids, _amounts);
		_emergencyWithdraw(msg.sender);
	}

	function exit(uint256[] calldata _ids) external nonReentrant
	{
		_checkLock(msg.sender);
		uint256 _count = _ids.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _userTokenCount = 0;
		uint256[] memory _amounts = new uint256[](_count);
		for (uint256 _i = 0; _i < _count; _i++) {
			uint256 _id = _ids[_i];
			UserTokenInfo storage _userTokenInfo = _userInfo2.userTokenInfo[_id];
			uint256 _amount = _userTokenInfo.amount;
			_userTokenInfo.amount = 0;
			tokenInfo[_id].amount -= _amount;
			_userTokenCount += _amount;
			_amounts[_i] = _amount;
		}
		uint256 _oldAmount = _userInfo2.userTokenCount;
		require(_userTokenCount == _oldAmount, "incomplete list");
		if (_userTokenCount > 0) {
			_userInfo2.userTokenCount = 0;
			IERC1155(collection).safeBatchTransferFrom(address(this), msg.sender, _ids, _amounts, new bytes(0));
			tokenCount -= _userTokenCount;
		}
		emit Exit(msg.sender, _ids, _amounts);
		_exit(msg.sender);
	}

	function updatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser) external onlyOwner
	{
		require(_poolMinPerUser <= _poolMaxPerUser, "invalid limits");
		if (tokenCount > 0) {
			require(_poolMinPerUser <= poolMinPerUser && poolMaxPerUser <= _poolMaxPerUser, "unexpanded limits");
		}
		poolMinPerUser = _poolMinPerUser;
		poolMaxPerUser = _poolMaxPerUser;
		emit UpdatePoolLimitsPerUser(_poolMinPerUser, _poolMaxPerUser);
	}

	function updateItemsWeight(uint256[] calldata _ids, int256 _newWeight, address[][] calldata _accounts) external onlyOwner
	{
		uint256 _count = _ids.length;
		require(_accounts.length == _count, "invalid length");
		require(_newWeight >= -1e18, "invalid weight");
		for (uint256 _i = 0; _i < _count; _i++) {
			uint256 _id = _ids[_i];
			TokenInfo storage _tokenInfo = tokenInfo[_id];
			int256 _oldWeight = _tokenInfo.weight;
			_tokenInfo.weight = _newWeight;
			uint256 _tokenCount = 0;
			uint256 _subcount = _accounts[_i].length;
			for (uint256 _j = 0; _j < _subcount; _j++) {
				address _account = _accounts[_i][_j];
				uint256 _amount = userInfo2[_account].userTokenInfo[_id].amount;
				uint256 _factor = lockInfo[_account].factor;
				uint256 _oldShares = _amount * uint256(1e18 + _oldWeight);
				uint256 _newShares = _amount * uint256(1e18 + _newWeight);
				_adjust(_account, _oldShares + _oldShares * _factor / 1e18, _newShares + _newShares * _factor / 1e18);
				_tokenCount += _amount;
			}
			require(_tokenCount == _tokenInfo.amount, "incomplete list");
		}
		emit UpdateItemsWeight(_ids, _newWeight);
	}

	event Lock(address indexed _account, uint256 _cycle);
	event Deposit(address indexed _account, uint256[] _ids, uint256[] _amounts);
	event Withdraw(address indexed _account, uint256[] _ids, uint256[] _amounts);
	event EmergencyWithdraw(address indexed _account, uint256[] _ids, uint256[] _amounts);
	event Exit(address indexed _account, uint256[] _ids, uint256[] _amounts);
	event UpdatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser);
	event UpdateItemsWeight(uint256[] _ids, int256 _weight);
}


// File contracts/ERC1155StakingPoolFactory.sol


pragma solidity 0.8.9;


contract ERC1155StakingPoolFactory is BaseStakingPoolFactory
{
	function _createPoolImpl() internal override returns (address _pool)
	{
		return address(new ERC1155StakingPool(address(0), address(0)));
	}
}


// File contracts/ERC20StakingPool.sol


pragma solidity 0.8.9;



contract ERC20StakingPool is LockCycle, BaseStakingPool
{
	using SafeERC20 for IERC20;

	struct UserInfo2 {
		uint256 amount;
	}

	address public stakedToken;
	uint256 public stakedBalance;
	uint256 public poolMinPerUser;
	uint256 public poolMaxPerUser;

	mapping(address => UserInfo2) public userInfo2;

	constructor(address _owner, address _stakedToken)
	{
		initialize(_owner, _stakedToken);
	}

	function initialize(address _owner, address _stakedToken) public override initializer
	{
		_initialize(_owner);
		stakedToken = _stakedToken;
	}

	function lock(uint256 _cycle) external
	{
		(uint256 _oldFactor, uint256 _newFactor) = _adjustLock(msg.sender, _cycle);
		UserInfo1 storage _userInfo1 = userInfo1[msg.sender];
		uint256 _shares = _userInfo1.shares;
		emit Lock(msg.sender, _cycle);
		if (_shares > 0 && _oldFactor != _newFactor) {
			_adjust(msg.sender, _shares + _shares * _oldFactor / 1e18, _shares + _shares * _newFactor / 1e18);
		}
	}

	function deposit(uint256 _amount) external nonReentrant
	{
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldAmount = _userInfo2.amount;
		uint256 _newAmount = _oldAmount + _amount;
		if (_newAmount > 0) {
			require(poolMinPerUser <= _newAmount && _newAmount <= poolMaxPerUser, "invalid balance");
		}
		if (_amount > 0) {
			_userInfo2.amount = _newAmount;
			IERC20(stakedToken).safeTransferFrom(msg.sender, address(this), _amount);
			stakedBalance += _amount;
		}
		emit Deposit(msg.sender, _amount);
		{
			uint256 _factor = _pushLock(msg.sender);
			uint256 _shares = _amount;
			_deposit(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function withdraw(uint256 _amount) external nonReentrant
	{
		uint256 _factor = _checkLock(msg.sender);
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldAmount = _userInfo2.amount;
		require(_amount <= _oldAmount, "insufficient balance");
		uint256 _newAmount = _oldAmount - _amount;
		if (_newAmount > 0) {
			require(poolMinPerUser <= _newAmount && _newAmount <= poolMaxPerUser, "invalid balance");
		}
		if (_amount > 0) {
			_userInfo2.amount = _newAmount;
			IERC20(stakedToken).safeTransfer(msg.sender, _amount);
			stakedBalance -= _amount;
		}
		emit Withdraw(msg.sender, _amount);
		{
			uint256 _shares = _amount;
			_withdraw(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function emergencyWithdraw() external nonReentrant
	{
		_checkLock(msg.sender);
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _amount = _userInfo2.amount;
		if (_amount > 0) {
			_userInfo2.amount = 0;
			IERC20(stakedToken).safeTransfer(msg.sender, _amount);
			stakedBalance -= _amount;
		}
		emit EmergencyWithdraw(msg.sender, _amount);
		_emergencyWithdraw(msg.sender);
	}

	function exit() external nonReentrant
	{
		_checkLock(msg.sender);
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _amount = _userInfo2.amount;
		if (_amount > 0) {
			_userInfo2.amount = 0;
			IERC20(stakedToken).safeTransfer(msg.sender, _amount);
			stakedBalance -= _amount;
		}
		emit Exit(msg.sender, _amount);
		_exit(msg.sender);
	}

	function updatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser) external onlyOwner
	{
		require(_poolMinPerUser <= _poolMaxPerUser, "invalid limits");
		if (stakedBalance > 0) {
			require(_poolMinPerUser <= poolMinPerUser && poolMaxPerUser <= _poolMaxPerUser, "unexpanded limits");
		}
		poolMinPerUser = _poolMinPerUser;
		poolMaxPerUser = _poolMaxPerUser;
		emit UpdatePoolLimitsPerUser(_poolMinPerUser, _poolMaxPerUser);
	}

	function _freeBalance(address _token) internal view override returns(uint256 _balance)
	{
		uint256 _amount = super._freeBalance(_token);
		if (_token == stakedToken) _amount -= stakedBalance;
		return _amount;
	}

	event Lock(address indexed _account, uint256 _cycle);
	event Deposit(address indexed _account, uint256 _amount);
	event Withdraw(address indexed _account, uint256 _amount);
	event EmergencyWithdraw(address indexed _account, uint256 _amount);
	event Exit(address indexed _account, uint256 _amount);
	event UpdatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser);
}


// File contracts/ERC20StakingPoolFactory.sol


pragma solidity 0.8.9;


contract ERC20StakingPoolFactory is BaseStakingPoolFactory
{
	function _createPoolImpl() internal override returns (address _pool)
	{
		return address(new ERC20StakingPool(address(0), address(0)));
	}
}


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/token/ERC721/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File contracts/ERC721StakingPool.sol


pragma solidity 0.8.9;





contract ERC721StakingPool is LockCycle, BaseStakingPool, ERC721Holder
{
	using SafeERC20 for IERC20;

	struct UserInfo2 {
		uint256 userTokenCount;
	}

	struct TokenInfo {
		address owner;
		int256 weight;
	}

	uint256 public constant POOL_MAX_PER_USER = 20;

	address public collection;
	uint256 public tokenCount;
	mapping(uint256 => TokenInfo) public tokenInfo;
	uint256 public poolMinPerUser;
	uint256 public poolMaxPerUser;

	mapping(address => UserInfo2) public userInfo2;

	constructor(address _owner, address _collection)
	{
		initialize(_owner, _collection);
	}

	function initialize(address _owner, address _collection) public override initializer
	{
		_initialize(_owner);
		collection = _collection;
	}

	function lock(uint256 _cycle) external
	{
		(uint256 _oldFactor, uint256 _newFactor) = _adjustLock(msg.sender, _cycle);
		UserInfo1 storage _userInfo1 = userInfo1[msg.sender];
		uint256 _shares = _userInfo1.shares;
		emit Lock(msg.sender, _cycle);
		if (_shares > 0 && _oldFactor != _newFactor) {
			_adjust(msg.sender, _shares + _shares * _oldFactor / 1e18, _shares + _shares * _newFactor / 1e18);
		}
	}

	function deposit(uint256[] calldata _tokenIdList) external nonReentrant
	{
		uint256 _count = _tokenIdList.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldCount = _userInfo2.userTokenCount;
		uint256 _newCount = _oldCount + _count;
		if (_newCount > 0) {
			require(poolMinPerUser <= _newCount && _newCount <= poolMaxPerUser, "invalid balance");
		}
		if (_count > 0) {
			_userInfo2.userTokenCount = _newCount;
			for (uint256 _i = 0; _i < _count; _i++) {
				uint256 _tokenId = _tokenIdList[_i];
				TokenInfo storage _tokenInfo = tokenInfo[_tokenId];
				require(_tokenInfo.owner == address(0), "invalid owner");
				IERC721(collection).safeTransferFrom(msg.sender, address(this), _tokenId);
				_tokenInfo.owner = msg.sender;
			}
			tokenCount += _count;
		}
		emit Deposit(msg.sender, _tokenIdList);
		{
			uint256 _factor = _pushLock(msg.sender);
			uint256 _shares = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				_shares += uint256(1e18 + tokenInfo[_tokenIdList[_i]].weight);
			}
			_deposit(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function withdraw(uint256[] calldata _tokenIdList) external nonReentrant
	{
		uint256 _factor = _checkLock(msg.sender);
		uint256 _count = _tokenIdList.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldCount = _userInfo2.userTokenCount;
		require(_count <= _oldCount, "insufficient balance");
		uint256 _newCount = _oldCount - _count;
		if (_newCount > 0) {
			require(poolMinPerUser <= _newCount && _newCount <= poolMaxPerUser, "invalid balance");
		}
		if (_count > 0) {
			_userInfo2.userTokenCount = _newCount;
			for (uint256 _i = 0; _i < _count; _i++) {
				uint256 _tokenId = _tokenIdList[_i];
				TokenInfo storage _tokenInfo = tokenInfo[_tokenId];
				require(_tokenInfo.owner == msg.sender, "invalid owner");
				IERC721(collection).safeTransferFrom(address(this), msg.sender, _tokenId);
				_tokenInfo.owner = address(0);
			}
			tokenCount -= _count;
		}
		emit Withdraw(msg.sender, _tokenIdList);
		{
			uint256 _shares = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				_shares += uint256(1e18 + tokenInfo[_tokenIdList[_i]].weight);
			}
			_withdraw(msg.sender, _shares + _shares * _factor / 1e18);
		}
	}

	function emergencyWithdraw(uint256[] calldata _tokenIdList) external nonReentrant
	{
		_checkLock(msg.sender);
		uint256 _count = _tokenIdList.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldCount = _userInfo2.userTokenCount;
		require(_count == _oldCount, "incomplete list");
		if (_count > 0) {
			_userInfo2.userTokenCount = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				uint256 _tokenId = _tokenIdList[_i];
				TokenInfo storage _tokenInfo = tokenInfo[_tokenId];
				require(_tokenInfo.owner == msg.sender, "invalid owner");
				IERC721(collection).safeTransferFrom(address(this), msg.sender, _tokenId);
				_tokenInfo.owner = address(0);
			}
			tokenCount -= _count;
		}
		emit EmergencyWithdraw(msg.sender, _tokenIdList);
		_emergencyWithdraw(msg.sender);
	}

	function exit(uint256[] calldata _tokenIdList) external nonReentrant
	{
		_checkLock(msg.sender);
		uint256 _count = _tokenIdList.length;
		UserInfo2 storage _userInfo2 = userInfo2[msg.sender];
		uint256 _oldCount = _userInfo2.userTokenCount;
		require(_count == _oldCount, "incomplete list");
		if (_count > 0) {
			_userInfo2.userTokenCount = 0;
			for (uint256 _i = 0; _i < _count; _i++) {
				uint256 _tokenId = _tokenIdList[_i];
				TokenInfo storage _tokenInfo = tokenInfo[_tokenId];
				require(_tokenInfo.owner == msg.sender, "invalid owner");
				IERC721(collection).safeTransferFrom(address(this), msg.sender, _tokenId);
				_tokenInfo.owner = address(0);
			}
			tokenCount -= _count;
		}
		emit Exit(msg.sender, _tokenIdList);
		_exit(msg.sender);
	}

	function updatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser) external onlyOwner
	{
		require(_poolMaxPerUser <= POOL_MAX_PER_USER, "hard limit");
		require(_poolMinPerUser <= _poolMaxPerUser, "invalid limits");
		if (tokenCount > 0) {
			require(_poolMinPerUser <= poolMinPerUser && poolMaxPerUser <= _poolMaxPerUser, "unexpanded limits");
		}
		poolMinPerUser = _poolMinPerUser;
		poolMaxPerUser = _poolMaxPerUser;
		emit UpdatePoolLimitsPerUser(_poolMinPerUser, _poolMaxPerUser);
	}

	function updateItemsWeight(uint256[] calldata _tokenIdList, int256 _newWeight) external onlyOwner
	{
		require(_newWeight >= -1e18, "invalid weight");
		uint256 _count = _tokenIdList.length;
		for (uint256 _i = 0; _i < _count; _i++) {
			TokenInfo storage _tokenInfo = tokenInfo[_tokenIdList[_i]];
			int256 _oldWeight = _tokenInfo.weight;
			_tokenInfo.weight = _newWeight;
			address _account = _tokenInfo.owner;
			if (_account != address(0)) {
				uint256 _factor = lockInfo[_account].factor;
				uint256 _oldShares = uint256(1e18 + _oldWeight);
				uint256 _newShares = uint256(1e18 + _newWeight);
				_adjust(_account, _oldShares + _oldShares * _factor / 1e18, _newShares + _newShares * _factor / 1e18);
			}
		}
		emit UpdateItemsWeight(_tokenIdList, _newWeight);
	}

	event Lock(address indexed _account, uint256 _cycle);
	event Deposit(address indexed _account, uint256[] _tokenIdList);
	event Withdraw(address indexed _account, uint256[] _tokenIdList);
	event EmergencyWithdraw(address indexed _account, uint256[] _tokenIdList);
	event Exit(address indexed _account, uint256[] _tokenIdList);
	event UpdatePoolLimitsPerUser(uint256 _poolMinPerUser, uint256 _poolMaxPerUser);
	event UpdateItemsWeight(uint256[] _tokenIdList, int256 _weight);
}


// File contracts/ERC721StakingPoolFactory.sol

// ////-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;


contract ERC721StakingPoolFactory is BaseStakingPoolFactory
{
	function _createPoolImpl() internal override returns (address _pool)
	{
		return address(new ERC721StakingPool(address(0), address(0)));
	}
}