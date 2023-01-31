// : MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

//import"../../utils/AddressUpgradeable.sol";

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
        return !AddressUpgradeable.isContract(address(this));
    }
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

//import"../IERC20Upgradeable.sol";
//import"../../../utils/AddressUpgradeable.sol";

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

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
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// : UNLICENSED
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
//import"./interfaces/IDistributor.sol";
//import"./interfaces/IStakingContract.sol";
//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract LPStakingContract is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    // Contract state variables.
    address public protocolToken;
    address public LPToken;
    address public distributor;
    address public DAO;
    address public StakingContract;

    uint256 public constant PERCENTAGE_FACTOR = 10000; // 100% with two decimals
    uint256 public constant TOKEN_UNIT = 1e18; // 18 decimals

    uint256 public tokenRewardsPerSecond; // 1 WTK = 1000000000000000000
    uint256 public bonusTokenRewardsPerSecond;
    uint256 public adjTokenDepositedAmount;
    uint256 public compoundFee;

    struct Deposit {
        uint256 amount;
        uint256 adjAmount;
        uint256 depositTimestamp;
        uint256 rewardLevel;
        uint256 lastTimestampClaimed;
        uint256 timelockTimestamp;
    }

    mapping(address => bool) public autoCompound;

    mapping(address => CountersUpgradeable.Counter) public userDepositId;
    mapping(address => uint256) public userCurrentDeposits; // Amount of active deposits.
    mapping(address => mapping(uint256 => bool)) public userActiveDeposits; // Id of active deposits.
    mapping(address => mapping(uint256 => Deposit)) public userInfo; // Mapping from user to depositId to depositStruct

    mapping(address => bool) public userLocked;
    uint256 public claimingTimelock;
    uint256 public prestakeTimestamp;
    uint256 public bonusRewardTimestamp;
    uint256 public withdrawTimelock;

    uint256[] public milestones;
    uint256[] public rewardAdjustments;
    bool public milestonesSet;

    // Contract events.
    event RewardStructureSet(uint256[] milestones, uint256[] rateChanges);
    event DepositMade(
        address indexed user,
        address indexed recipient,
        uint256 depositId,
        uint256 amount
    );
    event DepositRewardUpdated(
        address indexed user,
        uint256 indexed depositId,
        uint256 newRewardLevel
    );
    event AutoCompoundSet(address user, bool authorized);
    event InterestClaimed(
        address indexed user,
        uint256[] depositIds,
        uint256 totalAmount
    );
    event InterestStaked(
        address indexed user,
        uint256[] depositIds,
        uint256 totalAmount
    );
    event PartialWithdrawal(
        address indexed user,
        uint256 depositId,
        uint256 amount
    );
    event Withdrawal(
        address indexed user,
        uint256[] depositIds,
        uint256 amount
    );

    // Contract constructor.
    function initialize(
        address _protocolToken,
        address _lpToken,
        address _distributor,
        address _DAO,
        address _stakingContract,
        uint256 _initRewards,
        uint256 _claimTimelock,
        uint256 _prestakeTimestamp,
        uint256 _bonusRewardTimestamp,
        uint256 _withdrawTimelock
    ) external initializer {
        require(_protocolToken != address(0), "Should not be the zero address");
        require(_lpToken != address(0), "Should not be the zero address");
        require(_distributor != address(0), "Should not be the zero address");
        require(_DAO != address(0), "Should not be the zero address");
        require(
            _stakingContract != address(0),
            "Should not be the zero address"
        );

        __Ownable_init();
        __ReentrancyGuard_init();

        protocolToken = _protocolToken;
        LPToken = _lpToken;
        distributor = _distributor;
        DAO = _DAO;
        StakingContract = _stakingContract;
        tokenRewardsPerSecond = _initRewards;
        claimingTimelock = _claimTimelock;
        prestakeTimestamp = _prestakeTimestamp;
        bonusRewardTimestamp = _bonusRewardTimestamp;
        withdrawTimelock = _withdrawTimelock;
    }

    // Contract functions.
    // A. Policy functions.
    function setProtocolToken(address _protocolToken) external onlyOwner {
        require(_protocolToken != address(0), "Should not be the zero address");
        protocolToken = _protocolToken;
    }

    function setLPToken(address _lpToken) external onlyOwner {
        require(_lpToken != address(0), "Should not be the zero address");
        LPToken = _lpToken;
    }

    function setDistributor(address _distributor) external onlyOwner {
        require(_distributor != address(0), "Should not be the zero address");
        distributor = _distributor;
    }

    function setDAO(address _DAO) external onlyOwner {
        require(_DAO != address(0), "Should not be the zero address");
        DAO = _DAO;
    }

    function setStakingContract(address _StakingContract) external onlyOwner {
        require(
            _StakingContract != address(0),
            "Should not be the zero address"
        );
        StakingContract = _StakingContract;
    }

    function setTokenRewardsPerSecond(uint256 _tokenRewardsPerSecond)
        external
        onlyOwner
    {
        tokenRewardsPerSecond = _tokenRewardsPerSecond;
    }

    function setBonusRewardsPerSecond(uint256 _bonusTokenRewardsPerSecond)
        external
        onlyOwner
    {
        bonusTokenRewardsPerSecond = _bonusTokenRewardsPerSecond;
    }

    function setRewardStructure(
        uint256[] calldata timestamps,
        uint256[] calldata changes
    ) external onlyOwner {
        // Array of mock milestones: [0, 60, 300, 600, 3600]
        // Array of mock rate changes: [0, 1500, 2500, 3000, 3200]
        require(
            milestonesSet == false,
            "Error: milestones have already been set"
        );
        require(
            timestamps.length == changes.length,
            "Error: arrays with different lengths"
        );

        for (uint256 i = 0; i < timestamps.length; i++) {
            milestones.push(timestamps[i]);
            rewardAdjustments.push(changes[i]);
        }

        milestonesSet = true;
        emit RewardStructureSet(timestamps, changes);
    }

    function setAutoCompoundFee(uint256 amount) external onlyOwner {
        compoundFee = amount;
    }

    function setWithdrawTimelock(uint256 _withdrawTimelock) external onlyOwner {
        withdrawTimelock = _withdrawTimelock;
    }

    function toggleDepositLock(address user) external onlyOwner {
        userLocked[user] = !userLocked[user];
    }

    function setProtocolStakingAllowance(uint256 amount) external onlyOwner {
        IERC20Upgradeable(protocolToken).approve(StakingContract, amount);
    }

    // B. Public functions.
    function getTokenRewardsPerDepositedUnit() public view returns (uint256) {
        require(
            adjTokenDepositedAmount != 0,
            "Error: Calculation not available"
        );

        uint256 unitReward = (tokenRewardsPerSecond * TOKEN_UNIT) /
            adjTokenDepositedAmount;
        return unitReward;
    }

    function getBonusTokenRewardsPerDepositedUnit()
        public
        view
        returns (uint256)
    {
        require(
            adjTokenDepositedAmount != 0,
            "Error: Calculation not available"
        );

        uint256 unitReward = (bonusTokenRewardsPerSecond * TOKEN_UNIT) /
            adjTokenDepositedAmount;
        return unitReward;
    }

    function updateDepositRewardLevel(address depositor, uint256 depositId)
        public
        returns (bool)
    {
        require(
            userActiveDeposits[depositor][depositId] == true,
            "Error: Deposit ID is not active"
        );

        Deposit storage depo = userInfo[depositor][depositId];

        uint256 depoRewardLevel = depo.rewardLevel;
        uint256 depoLifetime = block.timestamp - depo.depositTimestamp;

        // Iterating through milestone rewards structure.
        uint256 newRewardLevel = _getDepositRewardLevel(depoLifetime);

        // Updating depo reward level.
        if (newRewardLevel > depoRewardLevel) {
            // This could run within an internal function _updateUserDepositReward
            depo.rewardLevel = newRewardLevel;

            uint256 depoAdjustment = (depo.amount *
                rewardAdjustments[newRewardLevel]) / PERCENTAGE_FACTOR;

            depo.adjAmount = depo.amount + depoAdjustment;

            updateAdjustedTokenDepositedAmount(depoAdjustment, true);

            emit DepositRewardUpdated(depositor, depositId, newRewardLevel);

            return true;
        } else {
            return false;
        }
    }

    // C. User functions.
    function toggleAutoCompound() external {
        address user = msg.sender;
        autoCompound[user] = !autoCompound[user];

        bool currentStatus = autoCompound[user];

        emit AutoCompoundSet(user, currentStatus);
    }

    function deposit(address recipient, uint256 amount) public {
        address operator = msg.sender;

        require(userLocked[operator] == false, "User cannot deposit");

        uint256 timestamp = block.timestamp;
        userDepositId[recipient].increment();

        if (operator != address(this)) {
            IERC20Upgradeable(LPToken).safeTransferFrom(
                operator,
                address(this),
                amount
            );
        }

        uint256 depositId = userDepositId[recipient]._value;

        uint256 depoTimestamp;
        uint256 lastClaimedTimestamp;
        uint256 depoClaimTimelock;

        if (prestakeTimestamp > timestamp) {
            depoTimestamp = prestakeTimestamp;
            lastClaimedTimestamp = prestakeTimestamp;
            depoClaimTimelock = prestakeTimestamp + claimingTimelock;
        } else {
            depoTimestamp = timestamp;
            lastClaimedTimestamp = timestamp;
            depoClaimTimelock = timestamp + claimingTimelock;
        }

        userInfo[recipient][depositId] = Deposit(
            amount,
            amount,
            depoTimestamp,
            0,
            lastClaimedTimestamp,
            depoClaimTimelock
        );

        userCurrentDeposits[recipient] += 1;
        userActiveDeposits[recipient][depositId] = true;

        updateAdjustedTokenDepositedAmount(amount, true);

        emit DepositMade(operator, recipient, depositId, amount);
    }

    function claimInterest(uint256[] calldata depositIds, bool compound)
        external
        nonReentrant
        returns (uint256)
    {
        address depositor = msg.sender;

        // Claiming for each single deposit.
        uint256 amountClaimed = _claimInterest(depositor, depositIds);

        if (compound == true) {
            IDistributor(distributor).sendTokenAmount(depositor, amountClaimed);

            IStakingContract(StakingContract).deposit(depositor, amountClaimed);
            //deposit(depositor, amountClaimed);

            emit InterestStaked(depositor, depositIds, amountClaimed);
        } else {
            IDistributor(distributor).sendTokenAmount(depositor, amountClaimed);

            emit InterestClaimed(depositor, depositIds, amountClaimed);
        }

        return amountClaimed;
    }

    function autoCompoundInterest(
        address depositor,
        uint256[] calldata depositIds
    ) external onlyOwner {
        require(
            autoCompound[depositor] == true,
            "Error: User has not allowed autoCompound"
        );

        uint256 amountClaimed = _claimInterest(depositor, depositIds);

        // Receiving amountClaimed from distributor.
        IDistributor(distributor).sendTokenAmount(address(this), amountClaimed);

        // Deducing compoundFee.
        uint256 netAmount = amountClaimed - compoundFee;

        IStakingContract(StakingContract).deposit(depositor, netAmount);
        //deposit(depositor, netAmount);

        IERC20Upgradeable(protocolToken).safeTransfer(DAO, compoundFee);

        emit InterestStaked(depositor, depositIds, netAmount);
    }

    function withdraw(uint256[] memory depositIds) public nonReentrant {
        require(
            block.timestamp > withdrawTimelock,
            "not allowed to withdraw yet"
        );

        address depositor = msg.sender;

        uint256 amountPrincipal;
        uint256 amountInterest;

        uint256 adjAmountPrincipal;

        for (uint256 i = 0; i < depositIds.length; i++) {
            require(
                userActiveDeposits[depositor][depositIds[i]] == true,
                "Error: Deposit is not active"
            );

            Deposit storage depo = userInfo[depositor][depositIds[i]];

            // I shall omit the claimTimelock requirement since they are withdrawing.

            uint256 depositLifetime = block.timestamp - depo.depositTimestamp;
            uint256 newRewardLevel = _getDepositRewardLevel(depositLifetime);

            // Updating reward level if needed.
            if (newRewardLevel > depo.rewardLevel) {
                depo.rewardLevel = newRewardLevel;

                uint256 depoAdjustment = (depo.amount *
                    rewardAdjustments[newRewardLevel]) / PERCENTAGE_FACTOR;

                depo.adjAmount = depo.amount + depoAdjustment;

                updateAdjustedTokenDepositedAmount(depoAdjustment, true);

                emit DepositRewardUpdated(
                    depositor,
                    depositIds[i],
                    newRewardLevel
                );
            }

            // Withdrawing process.
            uint256 accruedTime = block.timestamp - depo.lastTimestampClaimed;
            uint256 tokenUnitReward = getTokenRewardsPerDepositedUnit();

            amountInterest +=
                (depo.adjAmount * accruedTime * tokenUnitReward) /
                TOKEN_UNIT;

            uint256 bonusTime;

            if (depo.lastTimestampClaimed < bonusRewardTimestamp) {
                uint256 bonusTokenUnitReward = getBonusTokenRewardsPerDepositedUnit();
                if (block.timestamp > bonusRewardTimestamp) {
                    bonusTime =
                        bonusRewardTimestamp -
                        depo.lastTimestampClaimed;
                } else {
                    bonusTime = block.timestamp - depo.lastTimestampClaimed;
                }
                amountInterest +=
                    (depo.amount * bonusTime * bonusTokenUnitReward) /
                    TOKEN_UNIT;
            }

            amountPrincipal += depo.amount;

            adjAmountPrincipal += depo.adjAmount;

            // Setting deposit state from ACTIVE to FORMER.
            userActiveDeposits[depositor][depositIds[i]] = false;
        }

        IDistributor(distributor).sendTokenAmount(depositor, amountInterest);
        emit InterestClaimed(depositor, depositIds, amountInterest);

        IERC20Upgradeable(LPToken).safeTransfer(depositor, amountPrincipal);
        emit Withdrawal(depositor, depositIds, amountPrincipal);

        updateAdjustedTokenDepositedAmount(adjAmountPrincipal, false);

        userCurrentDeposits[depositor] -= depositIds.length;
    }

    function partialWithdraw(uint256 depositId, uint256 amount)
        public
        nonReentrant
    {
        require(
            block.timestamp > withdrawTimelock,
            "not allowed to withdraw yet"
        );

        address depositor = msg.sender;

        Deposit storage depo = userInfo[depositor][depositId];

        require(
            userActiveDeposits[depositor][depositId] == true,
            "Error: Deposit is not active"
        );
        require(depo.amount > amount, "Error: Not enough funds to withdraw");

        // I shall omit the claimTimelock requirement since they are withdrawing.
        uint256 depositLifetime = block.timestamp - depo.depositTimestamp;
        uint256 newRewardLevel = _getDepositRewardLevel(depositLifetime);

        // Updating reward level if needed.
        if (newRewardLevel > depo.rewardLevel) {
            depo.rewardLevel = newRewardLevel;

            uint256 depoAdjustment = (depo.amount *
                rewardAdjustments[newRewardLevel]) / PERCENTAGE_FACTOR;

            depo.adjAmount = depo.amount + depoAdjustment;

            updateAdjustedTokenDepositedAmount(depoAdjustment, true);

            emit DepositRewardUpdated(depositor, depositId, newRewardLevel);
        }

        // Withdrawing process.
        require(
            block.timestamp >= prestakeTimestamp,
            "Error: Not allowed to withdraw"
        );
        uint256 accruedTime = block.timestamp - depo.lastTimestampClaimed;

        uint256 tokenUnitReward = getTokenRewardsPerDepositedUnit();

        uint256 amountInterest = (depo.adjAmount *
            accruedTime *
            tokenUnitReward) / TOKEN_UNIT;

        uint256 bonusTime;

        if (depo.lastTimestampClaimed < bonusRewardTimestamp) {
            uint256 bonusTokenUnitReward = getBonusTokenRewardsPerDepositedUnit();
            if (block.timestamp > bonusRewardTimestamp) {
                bonusTime = bonusRewardTimestamp - depo.lastTimestampClaimed;
            } else {
                bonusTime = block.timestamp - depo.lastTimestampClaimed;
            }
            amountInterest +=
                (depo.amount * bonusTime * bonusTokenUnitReward) /
                TOKEN_UNIT;
        }

        uint256 amountPrincipal = amount;

        uint256 adjAmountPrincipal = amount +
            (amount * rewardAdjustments[depo.rewardLevel]) /
            PERCENTAGE_FACTOR;

        // Adjusting depo params.
        depo.amount -= amount;
        depo.adjAmount -= adjAmountPrincipal;
        depo.lastTimestampClaimed = block.timestamp;
        depo.timelockTimestamp = block.timestamp + claimingTimelock;

        // Transfering funds to depositor.

        uint256 totalAmount = amountPrincipal + amountInterest;

        IDistributor(distributor).sendTokenAmount(depositor, amountInterest);

        IERC20Upgradeable(LPToken).safeTransfer(depositor, amountPrincipal);

        updateAdjustedTokenDepositedAmount(adjAmountPrincipal, false);

        emit PartialWithdrawal(depositor, depositId, totalAmount);
    }

    function withdrawDeposits(uint256[] memory depositIds, uint256 amount)
        external
    {
        uint256 lastDeposit = depositIds[depositIds.length - 1];

        uint256[] memory depos = new uint256[](depositIds.length - 1);

        // Fully withdraw t-1 deposits.
        for (uint256 i = 0; i < depositIds.length - 1; i++) {
            depos[i] = depositIds[i];
        }

        withdraw(depos);

        // Partial withdraw on last deposit.
        partialWithdraw(lastDeposit, amount);
    }

    // Internal functions.
    function _getDepositRewardLevel(uint256 depositLifetime)
        internal
        view
        returns (uint256)
    {
        uint256 rewardLevel;

        for (uint256 i = 0; i < milestones.length; i++) {
            if (depositLifetime >= milestones[i]) {
                rewardLevel = i;
            } else {
                break;
            }
        }

        return rewardLevel;
    }

    function updateAdjustedTokenDepositedAmount(uint256 amount, bool add)
        internal
    {
        if (add == true) {
            adjTokenDepositedAmount += amount;
        } else {
            adjTokenDepositedAmount -= amount;
        }
    }

    function _claimInterest(address depositor, uint256[] calldata depositIds)
        internal
        returns (uint256)
    {
        uint256 amountClaimed;

        // Claiming for each single deposit.
        for (uint256 i = 0; i < depositIds.length; i++) {
            require(
                userActiveDeposits[depositor][depositIds[i]] == true,
                "Error: Deposit is not active"
            );

            Deposit storage depo = userInfo[depositor][depositIds[i]];

            require(
                block.timestamp >= depo.timelockTimestamp,
                "Error: Not allowed to claim yet"
            );

            uint256 depositLifetime = block.timestamp - depo.depositTimestamp;
            uint256 newRewardLevel = _getDepositRewardLevel(depositLifetime);

            // Updating reward level if needed.
            if (newRewardLevel > depo.rewardLevel) {
                depo.rewardLevel = newRewardLevel;

                uint256 depoAdjustment = (depo.amount *
                    rewardAdjustments[newRewardLevel]) / PERCENTAGE_FACTOR;

                depo.adjAmount = depo.amount + depoAdjustment;

                updateAdjustedTokenDepositedAmount(depoAdjustment, true);

                emit DepositRewardUpdated(
                    depositor,
                    depositIds[i],
                    newRewardLevel
                );
            }

            // Interest claiming process.
            uint256 accruedTime = block.timestamp - depo.lastTimestampClaimed;
            uint256 tokenUnitReward = getTokenRewardsPerDepositedUnit();

            amountClaimed +=
                (depo.adjAmount * accruedTime * tokenUnitReward) /
                TOKEN_UNIT;

            uint256 bonusTime;

            if (depo.lastTimestampClaimed < bonusRewardTimestamp) {
                uint256 bonusTokenUnitReward = getBonusTokenRewardsPerDepositedUnit();
                if (block.timestamp > bonusRewardTimestamp) {
                    bonusTime =
                        bonusRewardTimestamp -
                        depo.lastTimestampClaimed;
                } else {
                    bonusTime = block.timestamp - depo.lastTimestampClaimed;
                }
                amountClaimed +=
                    (depo.amount * bonusTime * bonusTokenUnitReward) /
                    TOKEN_UNIT;
            }

            depo.lastTimestampClaimed = block.timestamp;
            depo.timelockTimestamp = block.timestamp + claimingTimelock;
        }

        return amountClaimed;
    }
}


// : UNLICENSED
pragma solidity ^0.8.0;

interface IDistributor {
    function sendTokenAmount(address recipient, uint256 amount) external;
}


// : UNLICENSED
pragma solidity ^0.8.0;

interface IStakingContract {
    function deposit(address recipient, uint256 amount) external;
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}


