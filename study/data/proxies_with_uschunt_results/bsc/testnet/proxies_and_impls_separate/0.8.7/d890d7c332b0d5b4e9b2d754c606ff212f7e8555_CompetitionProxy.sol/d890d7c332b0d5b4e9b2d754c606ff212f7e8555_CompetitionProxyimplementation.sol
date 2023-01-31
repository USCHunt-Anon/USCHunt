// : UNLICENSED
pragma solidity 0.8.7;

interface Metadata {
    enum Status {
        Lock,
        Open,
        End,
        Refund,
        Non_Eligible
    }
    enum Player {
        NoPlayer,
        Player1,
        Player2
    }

    enum Mode {
        Team,
        Player
    }
}


// : UNLICENSED
pragma solidity 0.8.7;

library String {
    function append(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function compare(string memory a, string memory b) internal pure returns(bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function toBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}


// : UNLICENSED

pragma solidity ^0.8.0;

interface ISportManager {
    struct Game {
        uint256 id;
        bool active;
        string name;
        ProviderGameData provider;
    }

    struct Attribute {
        uint256 id;
        bool teamOption;
        AttributeSupportFor attributeSupportFor;
        string name;
    }

    enum ProviderGameData {
        GameScoreKeeper,
        SportRadar
    }

    enum AttributeSupportFor {
        None,
        Team,
        Player,
        All
    }

    event AddNewGame(uint256 indexed gameId, string name);
    event DeactiveGame(uint256 indexed gameId);
    event ActiveGame(uint256 indexed gameId);
    event AddNewAttribute(uint256 indexed attributeId, string name);

    function getGameById(uint256 id) external view returns (Game memory);

    function addNewGame(
        string memory name,
        bool active,
        ProviderGameData provider
    ) external returns (uint256 gameId);

    function deactiveGame(uint256 gameId) external;

    function activeGame(uint256 gameId) external;

    function addNewAttribute(Attribute[] calldata attribute) external;

    function setSupportedAttribute(
        uint256 gameId,
        uint256[] memory attributeIds,
        bool isSupported
    ) external;

    function checkSupportedGame(uint256 gameId) external view returns (bool);

    function checkSupportedAttribute(uint256 gameId, uint256 attributeId)
        external
        view
        returns (bool);

    function checkTeamOption(uint256 attributeId) external view returns (bool);

    function getAttributeById(uint256 attributeId)
        external
        view
        returns (Attribute calldata);
}


// : UNLICENSED
pragma solidity ^0.8.0;

//import"../metadata/Metadata.sol";
//import"./ICompetitionContract.sol";

interface IRegularCompetitionContract is Metadata {
    struct Competition {
        string competitionId;
        string team1;
        string team2;
        uint256 sportTypeAlias;
        uint256 winnerReward;
        bool resulted;
    }

    struct BetOption {
        Mode mode;
        uint256 attribute;
        string id;
        uint256[] brackets;
    }

    event PlaceBet(address indexed buyer, uint256[] brackets, uint256 fee);
    event RequestData(
        bytes32 indexed _requestId,
        string _competitionId,
        string _queryString
    );

    function oracle() external view returns (address);

    function setBasic(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _entryFee,
        uint256 _minEntrant,
        uint256 _scheduledStartTime,
        uint256 _minimumBetime
    ) external returns (bool);

    function start() external;

    function setOracle(address _oracle) external;

    function setCompetition(
        string memory _competitionId,
        string memory _team1,
        string memory _team2,
        uint256 _sportTypeAlias,
        address _sportManager
    ) external;

    function setGapvalidationTime(uint256 _gapTime) external;

    function getDataToCheckRefund() external view returns (bytes32, uint256);

    function getTicketSell(uint256[] memory _brackets)
        external
        view
        returns (address[] memory);

    function setBetOptions(BetOption[] memory _betOptions) external;

    function setIsResult() external;
}


// : UNLICENSED

pragma solidity ^0.8.0;

interface ICompetitionPool {
    struct Bet {
        address competionContract;
        uint256[] betIndexs;
    }

    struct Pool {
        Type competitonType;
        bool existed;
    }

    enum Type {
        Regular,
        P2P,
        Guarantee
    }

    function fee() external view returns(uint256);

    function tokenAddress() external view returns(address);

    function refundable(address _betting) external view returns (bool);

    function isCompetitionExisted(address _pool) external returns (bool);

    function getMaxTimeWaitForRefunding() external view returns (uint256);
}


// : UNLICENSED
pragma solidity ^0.8.0;

//import"../metadata/Metadata.sol";

interface ICompetitionContract is Metadata {
    event Ready(
        uint256 timestamp,
        uint256 startTimestamp,
        uint256 endTimestamp
    );
    event Close(uint256 timestamp, uint256 winnerReward);

    function getEntryFee() external view returns (uint256);

    function getFee() external view returns (uint256);

    function placeBet(
        address user,
        uint256[] memory betIndexs
    ) external;

    function distributedReward() external;
}


// : UNLICENSED
pragma solidity ^0.8.0;
//import"../metadata/Metadata.sol";
//import"../interface/IRegularCompetitionContract.sol";

interface IChainLinkOracleSportData {
    function getPayment() external returns (uint256);

    function requestData(
        string memory _matchId,
        uint256 sportId,
        IRegularCompetitionContract.BetOption[] memory _betOptions
    ) external returns (bytes32);

    function getData(bytes32 _id)
        external
        view
        returns (uint256[] memory, address);

    function checkFulfill(bytes32 _requestId) external view returns (bool);
}


// : UNLICENSED
pragma solidity ^0.8.7;

//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import"@openzeppelin/contracts/proxy/utils/Initializable.sol";
//import"../interface/ICompetitionContract.sol";
//import"../interface/ISportManager.sol";

/*
CC01: No betable
CC02: Only owner
CC03: Only creator
CC04: Only Configurator
CC05: Required NOT start
CC06: Required Open
*/
abstract contract CompetitionContract is ICompetitionContract, ReentrancyGuard, Initializable {
    using SafeERC20 for IERC20;

    address private configurator;
    address public owner;
    address public creator;
    ISportManager public sportManager;
    address public tokenAddress;

    uint256 public totalFee;
    uint256 public minEntrant;
    uint256 internal entryFee;
    uint256 internal fee;

    uint256 public startBetTime;
    uint256 public endBetTime;

    bool public stopBet;
    Status public status = Status.Lock;

    mapping(address => bool) public betOrNotYet;
    address[] public listBuyer;

    function initialize(
        address _owner,
        address _creator,
        address _tokenAddress,
        address _configurator,
        uint256 _fee
    ) public initializer {
        owner = _owner;
        creator = _creator;
        tokenAddress = _tokenAddress;
        fee = _fee;
        configurator = _configurator;
    }

    modifier betable(address user) {
        require(!betOrNotYet[user], "CC01");
        require(!stopBet, "CC01");
        require(
            block.timestamp >= startBetTime && block.timestamp <= endBetTime,
            "CC01"
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "CC02");
        _;
    }

    modifier onlyCreator() {
        require(creator == msg.sender, "CC03");
        _;
    }

    modifier onlyConfigurator() {
        require(configurator == msg.sender, "CC04");
        _;
    }

    modifier onlyLock() {
        require(status == Status.Lock, "CC05");
        _;
    }

    modifier onlyOpen() {
        require(status == Status.Open, "CC06");
        _;
    }

    function getEntryFee() external view override returns (uint256) {
        return entryFee;
    }

    function getFee() external view override returns (uint256) {
        return fee;
    }

    function toggleStopBet() external onlyCreator {
        stopBet = !stopBet;
    }

    function getTotalToken(address _token) public view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function _checkEntrantCodition() internal view returns (bool) {
        if (listBuyer.length >= minEntrant) {
            return true;
        } else {
            return false;
        }
    }

    function _sendRewardToWinner(address[] memory winners, uint256 winnerReward)
        internal
    {
        if (winners.length == 0 || winnerReward == 0) return;

        uint256 reward = winnerReward / winners.length;
        for (uint256 i = 0; i < winners.length - 1; i++) {
            IERC20(tokenAddress).safeTransfer(winners[i], reward);
        }

        uint256 remaining = winnerReward - (winners.length - 1) * reward;
        IERC20(tokenAddress).safeTransfer(
            winners[winners.length - 1],
            remaining
        );
    }
}


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

//import"../IERC20.sol";
//import"../../../utils/Address.sol";

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


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

//import"../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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


// : UNLICENSED
pragma solidity ^0.8.7;

//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"../interface/IChainLinkOracleSportData.sol";
//import"../interface/IRegularCompetitionContract.sol";
//import"../interface/ICompetitionPool.sol";
//import"./CompetitionContract.sol";
//import"../library/String.sol";

/*
RCC01: Address 0x00
RCC02: Time is illegal
RCC03: Competition is in the past
RCC04: No bet options
RCC05: Game is not supported
RCC06: Attribute is not supported
RCC07: _betOptions invalid
RCC08: expired
RCC09: Not enough Fee
RCC10: Invalid length
RCC11: Invalid bracket
RCC12: Not enough Fee
RCC13: Only Oracle
RCC14: It's not time yet
RCC15: Had Got Price
RCC16: Not enough entrant
RCC17: Bet time haven't finished yet
RCC18: Waiting for get result
RCC19: Not result
*/

contract RegularCompetitionContract is
    CompetitionContract,
    IRegularCompetitionContract
{
    using SafeERC20 for IERC20;
    using String for string;
    using String for uint256;
    Competition public competition;
    uint256 public gapValidatitionTime; //maximumRefundTime
    uint256 public scheduledStartTime;

    uint256 private decimalOfResult = 10000;

    address public override oracle;

    mapping(bytes32 => address[]) public ticketSell;
    BetOption[] public betOptions;

    bytes32 internal requestID;

    function setOracle(address _oracle) external override onlyConfigurator {
        require(_oracle != address(0), "RCC01");
        oracle = _oracle;
    }

    function setGapvalidationTime(uint256 _gapTime)
        external
        override
        onlyConfigurator
    {
        gapValidatitionTime = _gapTime;
    }

    function getDataToCheckRefund()
        external
        view
        override
        returns (bytes32, uint256)
    {
        return (requestID, endBetTime);
    }

    function getTicketSell(uint256[] memory _brackets)
        external
        view
        override
        returns (address[] memory)
    {
        bytes32 _key = _generateKey(_brackets);
        return ticketSell[_key];
    }

    function getBetOptions() external view returns (BetOption[] memory) {
        return (betOptions);
    }

    function setBasic(
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _entryFee,
        uint256 _minEntrant,
        uint256 _scheduledStartTime,
        uint256 _minimumBetime
    ) external override onlyConfigurator onlyLock returns (bool) {
        require(block.timestamp <= _startTimestamp, "RCC02");
        require(_startTimestamp + _minimumBetime < _endTimestamp, "RCC02");
        //require(_endTimestamp < _scheduledStartTime, "RCC03");
        startBetTime = _startTimestamp;
        endBetTime = _endTimestamp;
        entryFee = _entryFee;
        minEntrant = _minEntrant;
        scheduledStartTime = _scheduledStartTime;
        return true;
    }

    function setCompetition(
        string memory _competitionId,
        string memory _team1,
        string memory _team2,
        uint256 _sportTypeAlias,
        address _sportManager
    ) external override onlyConfigurator onlyLock {
        sportManager = ISportManager(_sportManager);
        competition = Competition(
            _competitionId,
            _team1,
            _team2,
            _sportTypeAlias,
            0,
            false
        );
    }

    function setBetOptions(BetOption[] memory _betOptions)
        external
        override
        onlyConfigurator
        onlyLock
    {
        require(_betOptions.length > 0, "RCC04");
        require(
            sportManager.checkSupportedGame(competition.sportTypeAlias),
            "RCC05"
        );
        for (uint256 i = 0; i < _betOptions.length; i++) {
            require(
                sportManager.checkSupportedAttribute(
                    competition.sportTypeAlias,
                    _betOptions[i].attribute
                ),
                "RCC06"
            );

            require(_checkBetOption(i, _betOptions), "RCC07");
            if (sportManager.checkTeamOption(_betOptions[i].attribute)) {
                uint256[] memory brackets = new uint256[](2);
                brackets[0] = 0;
                brackets[1] = 1;
                betOptions.push(
                    BetOption({
                        mode: Mode.Team,
                        attribute: _betOptions[i].attribute,
                        id: "0",
                        brackets: brackets
                    })
                );
            } else {
                betOptions.push(_betOptions[i]);
            }
        }
    }

    function start() external virtual override onlyOwner onlyLock {
        require(endBetTime >= block.timestamp, "RCC08");
        require(getTotalToken(tokenAddress) >= fee, "RCC09");
        totalFee = fee;
        status = Status.Open;
        emit Ready(block.timestamp, startBetTime, endBetTime);
    }

    function placeBet(address user, uint256[] memory betIndexs)
        external
        virtual
        override
        onlyOpen
        betable(user)
        onlyOwner
    {
        require(betIndexs.length == betOptions.length, "RCC10");
        for (uint256 i = 0; i < betIndexs.length; i++) {
            require(betIndexs[i] <= betOptions[i].brackets.length, "RCC11");
        }
        uint256 totalToken = getTotalToken(tokenAddress);
        uint256 totalEntryFee = listBuyer.length * entryFee;
        require(
            totalToken >= totalEntryFee + totalFee + fee + entryFee,
            "RCC12"
        );
        totalFee += fee;
        betOrNotYet[user] = true;
        listBuyer.push(user);
        bytes32 key = _generateKey(betIndexs);
        ticketSell[key].push(user);
        emit PlaceBet(user, betIndexs, entryFee + fee);
    }

    function _generateKey(uint256[] memory array)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(array));
    }

    function setIsResult() external override {
        require(msg.sender == oracle, "RCC13");
        competition.resulted = true;
    }

    function requestData() external onlyOpen {
        require(
            block.timestamp > scheduledStartTime + gapValidatitionTime,
            "RCC14"
        );
        require(!competition.resulted, "RCC15");
        bool enoughEntrant = _checkEntrantCodition();
        require(enoughEntrant, "RCC16");
        requestID = IChainLinkOracleSportData(oracle).requestData(
            competition.competitionId,
            competition.sportTypeAlias,
            betOptions
        );
    }

    function distributedReward() external virtual override onlyOpen nonReentrant {
        bool enoughEntrant = _checkEntrantCodition();

        address[] memory winners;
        uint256 ownerReward;
        uint256 creatorReward;
        uint256 winnerReward;
        uint256 totalEntryFee = listBuyer.length * entryFee;
        if (!enoughEntrant) {
            require(block.timestamp > endBetTime, "RCC17");
            status = Status.Non_Eligible;
            winners = listBuyer;
            winnerReward = totalEntryFee;
            ownerReward = totalFee;
        } else {
            (bytes32 key, bool success) = _getResult();
            if (!success) {
                uint256 maxTimeForRefunding = ICompetitionPool(owner)
                    .getMaxTimeWaitForRefunding();
                require(
                    block.timestamp > scheduledStartTime + maxTimeForRefunding,
                    "RCC18"
                );
                status = Status.Refund;
                winners = listBuyer;
                winnerReward = totalEntryFee + totalFee - fee;
                ownerReward = 0;
                creatorReward = fee;
            } else {
                status = Status.End;

                if (key != bytes32(0)) {
                    winners = ticketSell[key];
                } else {
                    winners = listBuyer;
                }

                if (winners.length > 0) {
                    winnerReward = totalEntryFee;
                    ownerReward = totalFee;
                } else {
                    ownerReward = totalFee + totalEntryFee;
                }
            }
        }

        competition.winnerReward = winnerReward;

        if (ownerReward > 0) {
            IERC20(tokenAddress).safeTransfer(owner, ownerReward);
        }
        if (creatorReward > 0) {
            IERC20(tokenAddress).safeTransfer(creator, creatorReward);
        }
        if (winnerReward > 0 && winners.length > 0) {
            _sendRewardToWinner(winners, winnerReward);
        }

        uint256 remaining = getTotalToken(tokenAddress);
        if (remaining > 0) {
            IERC20(tokenAddress).safeTransfer(owner, remaining);
        }

        emit Close(block.timestamp, competition.winnerReward);
    }

    function _getResult() internal view returns (bytes32 _key, bool _success) {
        if (ICompetitionPool(owner).refundable(address(this))) {
            return (bytes32(0), false);
        }
        (uint256[] memory result, ) = IChainLinkOracleSportData(oracle).getData(
            requestID
        );
        require(result.length == betOptions.length, "RCC19");

        uint256[] memory betWin = new uint256[](betOptions.length);

        for (uint256 i = 0; i < betOptions.length; i++) {
            BetOption memory betOption = betOptions[i];
            if (sportManager.checkTeamOption(betOptions[i].attribute)) {
                string memory team = String.toString(
                    result[i] / decimalOfResult
                );
                if (team.compare(competition.team1)) {
                    betWin[i] = 0;
                } else if (team.compare(competition.team2)) {
                    betWin[i] = 1;
                } else return (bytes32(0), false);
            } else {
                uint256 winIndex = _getBracketIndex(
                    betOption.brackets,
                    result[i]
                );
                betWin[i] = winIndex;
            }
        }

        return (_generateKey(betWin), true);
    }

    function _getBracketIndex(uint256[] memory brackets, uint256 value)
        internal
        pure
        returns (uint256 index)
    {
        if (value < brackets[0]) {
            return 0;
        }
        if (value >= brackets[brackets.length - 1]) {
            return brackets.length;
        }
        for (uint256 i = 0; i < brackets.length - 1; i++) {
            if (value < brackets[i + 1]) {
                return i + 1;
            }
        }
    }

    function _checkBetOption(uint256 _index, BetOption[] memory _betOptions)
        internal
        view
        returns (bool)
    {
        uint256[] memory brackets = _betOptions[_index].brackets;
        if (brackets[0] == 0) return false;

        ISportManager.Attribute memory attribute = sportManager
            .getAttributeById(_betOptions[_index].attribute);
        if (_betOptions[_index].mode == Mode.Team) {
            if (
                attribute.attributeSupportFor ==
                ISportManager.AttributeSupportFor.None ||
                attribute.attributeSupportFor ==
                ISportManager.AttributeSupportFor.Player
            ) {
                return false;
            }
        } else {
            if (_betOptions[_index].mode == Mode.Player) {
                if (
                    attribute.attributeSupportFor ==
                    ISportManager.AttributeSupportFor.None ||
                    attribute.attributeSupportFor ==
                    ISportManager.AttributeSupportFor.Team
                ) {
                    return false;
                }
            }
        }

        for (uint256 i = 0; i < brackets.length - 1; i++) {
            if (brackets[i] >= brackets[i + 1]) {
                return false;
            }
        }
        // Betoptions is different
        for (uint256 j = _index + 1; j < _betOptions.length; j++) {
            if (
                _betOptions[_index].mode == _betOptions[j].mode &&
                _betOptions[_index].attribute == _betOptions[j].attribute &&
                _betOptions[_index].id.compare(_betOptions[j].id)
            ) {
                return false;
            }
        }

        return true;
    }
}


