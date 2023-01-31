// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"@openzeppelin/contracts/access/Ownable.sol";
//import"@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//import"@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import"./IStakingPool.sol";
//import"@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


contract Upgradable1155 is Ownable, ERC1155Holder {
    address public trustPayAddress;
    uint256 public taxFee;
    uint256 public totalPoolCreated; // Total pool created by admin
    uint256 public totalUserStaked; // Total user staked to pools
    // uint256 constant ONE_DAY_IN_SECONDS = 86400;
    uint256 constant ONE_DAY_IN_SECONDS = 86400;
    uint256 constant ONE_YEAR_IN_SECONDS = 31536000;
    mapping(string => PoolInfo) public poolInfo; // Pools info
    mapping(address => uint256) public totalAmountStaked; //  tokenAddress => totalAmountStaked: balance of token staked to the pools
    mapping(address => uint256) public totalRewardClaimed; // tokenAddress => totalRewardClaimed: total reward user has claimed
    mapping(address => uint256) public totalRewardFund; // tokenAddress => rewardFund: total pools reward fund
    mapping(address => uint256) public totalStakedBalancePerUser; // total value users staked to the pool
    mapping(address => mapping(address => uint256)) public totalRewardClaimedPerUser; // tokenAddress => userAddress => amount: total reward users claimed
    mapping(string => mapping(address => uint256)) public stakedBalancePerUser; // poolId => userAddress => balance: total value each user staked to the pool
    mapping(string => mapping(address => uint256)) public rewardClaimedPerUser; // poolId => userAddress => balance: reward each user has claimed
    address public controller;
    // uint256 totalSuperAdmin; // total Super Admin
    uint256 public totalUserStakeNFT1155;
    mapping(address => uint256) public totalStakedNFT1155BalancePerUser;
    mapping(address => mapping(address => uint256)) public totalStakedNFT1155BalanceByNFT; //NFTAddress => user address => amount
    mapping(string => mapping(uint256 => mapping(address => uint256))) public stakeNFT1155ByUser; // poolId => tokenId => userAddress => amount
    mapping(address => mapping(uint256 => uint256)) public totalAmountNFT1155Staked; //  NFTaddress => tokenId => totalAmountStaked: balance of token staked to the pools
    mapping(string => mapping(address => mapping(uint256=>mapping(string=>StakingData1155)))) public stakingDatas1155; //pool -> user -> tokenId -> internalTxid -> StakingData
    uint256 public totalNFT1155Staked; // total amount stake of all token
    uint256 public totalNFT1155Staking; //total token stake in contract at the momment
    
    
    /*================================ MODIFIERS ================================*/
    
    modifier onlyAdmins() {
        require(IStakingPool(trustPayAddress).isAdmin(msg.sender) || IStakingPool(trustPayAddress).isSuperAdmin(msg.sender) || msg.sender == controller, "Only admins or super admins or controller");
        _;
    }
    
    modifier poolExist(string memory poolId) {
        require(poolInfo[poolId].initialFund != 0, "Pool is not exist");
        require(poolInfo[poolId].active == 1, "Pool has been disabled");
        _;
    }
    
    modifier notBlocked() {
        require(!IStakingPool(trustPayAddress).isBlackList(msg.sender), "Caller has been blocked");
        _;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only controller");
        _;
    }

    modifier onlySuperAdmin() {
        require(IStakingPool(trustPayAddress).isSuperAdmin(msg.sender) || msg.sender == controller, "Only super admins or controller");
        _;
    }
    
    /*================================ EVENTS ================================*/
    
    event StakingEvent( 
        uint256 amount,
        address indexed account,
        string poolId,
        string internalTxID
    );
    
    event PoolUpdated(
        uint256 rewardFund,
        address indexed creator,
        string poolId,
        string internalTxID
    );

    event AdminSet(
        address indexed admin,
        bool isSet,
        string typeAdmin
    );

    event FeeRecipientSet(
        address indexed setter,
        address indexed recipient
    );

    event TaxFeeSet(
        address indexed setter,
        uint256 fee
    );

    event BlacklistSet(
        address indexed user,
        bool isSet
    );

    event PoolActivationSet(
        address indexed admin,
        string poolId,
        uint256 isActive
    );

     event StakeNFT1155(
        address indexed tokenAddress,
        address indexed from,
        address indexed to,
        uint256[] tokenIds,
        uint256[] amounts,
        string[] strs
    );
    
    /*================================ STRUCTS ================================*/

    struct StakingData1155 {
        uint256 amount;  // amount of copies/editions 
        uint256 stakedTime; 
        uint256 unstakedTime;
        uint256 lastUpdateTime;
        uint256 claimedReward;
        uint256 claimableReward;
        uint256 rewardPerTokenPaid;
    }
    
    struct PoolInfo {
        address stakingToken; // staking token of the pool
        address rewardToken; // reward token of the pool
        uint256 stakedBalance; // total balance staked the pool
        uint256 totalRewardClaimed; // total reward user has claimed
        uint256 rewardFund; // reward token available
        uint256 initialFund; // initial reward fund
        uint256 apr; // annual percentage rate
        uint256 totalUserStaked; // total user staked
        uint256 rewardRatio; // ratio of reward amount user can claim, 0 < fixedTimeRate < 100
        uint256 stakingLimit; // maximum amount of token users can stake to the pool
        uint256 active; // pool activation status, 0: disable, 1: active
        uint256 poolType; // flexible: 0, fixedTime: 1, monthly: 2, 3: monthly with unstake period
        uint256[] flexData; // lastUpdateTime(0), rewardPerTokenPaid(1)
        uint256[] configs; // startDate(0), endDate(1), duration(2), endStakeDate(3), exchangeRateRewardToStaking(4), poolNFT(5)
        // uint256 poolNFT; // 1: pool Token, 2: pool 721, 3: pool 1155
    }
}


// : MIT
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

//import"../utils/Context.sol";

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165.sol";

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165.sol";

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


// : MIT

pragma solidity ^0.8.0;

interface IStakingPool {
    function isAdmin(address _address) external view returns(bool);

    function controller() external view returns(address);

    function isSuperAdmin(address _address) external view returns(bool);

    function taxFee() external view returns(uint256);

    function feeRecipientAddress() external view returns(address);

    function isBlackList(address _address) external view returns(bool);
}

// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

//import"./ERC1155Receiver.sol";

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


// : MIT
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


// : MIT
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


// : MIT
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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

//import"../IERC1155Receiver.sol";
//import"../../../utils/introspection/ERC165.sol";

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165.sol";

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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

//import"./IERC165.sol";

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


// : MIT
pragma solidity ^0.8.0;

//import"./Upgradable.sol"; 

contract StakingNFT1155 is Upgradable1155 {
    using SafeERC20 for IERC20;
    constructor() {
        controller = msg.sender;
    }
    /**
     * @dev Stake NFT1155 to a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param tokenIds: id of token 
     * @param amounts: amount of token
    */
    function stakeNFT1155(string[] memory strs, uint256[] memory tokenIds, uint256[] memory amounts) external poolExist(strs[0]) notBlocked payable{
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];

        //check pool can stake NFT1155
        require(pool.configs[5] == 3,"This pool cant stake NFT1155");
        require(msg.value == IStakingPool(trustPayAddress).taxFee(), "Tax fee amount is invalid");
        //check length of tokenIds and amounts
        require(tokenIds.length == amounts.length,"ids and amounts must have the same length");
        //check if valid stake date
        require(block.timestamp <= pool.configs[1] && block.timestamp >= pool.configs[0], "Stake1155: stake time not valid");

        if (totalStakedNFT1155BalancePerUser[msg.sender] == 0) {
            totalUserStakeNFT1155 += 1;
        }
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked += 1;
        }
        for(uint256 i = 0; i < tokenIds.length; i++) {
            uint256 amount = amounts[i] * 1e18;
            //check amount > 0
            require(amount > 0, "Staking amount must be greater than 0");
            //check staking limit
            require(amount <= pool.stakingLimit, "Pool staking limit is exceeded");

            // Flexible pool update 
            if (pool.poolType == 0) {
                pool.flexData[1] = rewardPerToken(poolId);
                pool.flexData[0] = block.timestamp;
            }

            //create staking data 
            StakingData1155 memory data = StakingData1155(
                amount,
                block.timestamp, //stake time
                0, //unstake time
                block.timestamp, //last update time
                0,
                0,
                pool.poolType == 0 ? pool.flexData[1] : 0
            );

            stakeNFT1155ByUser[poolId][tokenIds[i]][msg.sender] = amount;

            totalStakedNFT1155BalancePerUser[msg.sender] += amount;

            // Update user staked balance by token address
            totalStakedNFT1155BalanceByNFT[pool.stakingToken][msg.sender] += amount; 

            // Update user staked balance by pool
            stakedBalancePerUser[poolId][msg.sender] += amount;
            
            // Update pool staked balance
            pool.stakedBalance += amount;

            // Update staking limit
            pool.stakingLimit -= amount;
            
            // Update total staked balance by token address and tokenId
            totalAmountNFT1155Staked[pool.stakingToken][tokenIds[i]] += amount;
            totalNFT1155Staked += amount;
            totalNFT1155Staking += amount;

            stakingDatas1155[poolId][msg.sender][tokenIds[i]][strs[i+1]] = data;
        }
        
        // Transfer user's token to the pool
        // IERC1155(pool.stakingToken).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        IERC1155(pool.stakingToken).safeBatchTransferFrom(msg.sender, address(this), tokenIds, amounts, "");
        
        // Transfer tax fee
        _transferTaxFee();
        emit StakeNFT1155(pool.stakingToken, msg.sender, address(this), tokenIds, amounts, strs);
        
    }

     /**
     * @dev Unstake NFT1155 of a pool  
     * @param strs: poolId(0), internalTxID(1)
     * @param tokenId: token ID
     * @param amount: amout
    */
    function unstakeNFT(string[] memory strs, uint256 tokenId, uint256 amount) external poolExist(strs[0]) notBlocked payable {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        uint256[] memory t = new uint256[](1);
        t[0] = tokenId;
        uint256[] memory a = new uint256[](1);
        a[0] = amount;
        StakingData1155 storage data = stakingDatas1155[poolId][msg.sender][tokenId][strs[1]];
        require(pool.configs[5] == 3,"This pool cant unstake NFT1155");
        require(msg.value == IStakingPool(trustPayAddress).taxFee(), "Tax fee amount is invalid");

        require(amount*1e18 <= data.amount, "1155Unstake: Unstake amount exceed staked balance");

        // If monthly with unstake period pool
        if (pool.poolType == 3) {
            require(data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp, "Need to wait until staking period ended");
        }

        // Flexible pool update
        if (pool.poolType == 0) {
            pool.flexData[1] = rewardPerToken(poolId);
            pool.flexData[0] = block.timestamp;
        }

        // Update reward
        data.claimableReward = earned(msg.sender,tokenId, strs);
        if(pool.poolType == 0) data.rewardPerTokenPaid = pool.flexData[1];
        // Update user stake balance
        totalStakedNFT1155BalancePerUser[msg.sender] -= amount*1e18;
        
        // Update user stake balance by token address 
        totalStakedNFT1155BalanceByNFT[pool.stakingToken][msg.sender] -= amount*1e18;
        if (totalStakedNFT1155BalancePerUser[msg.sender] == 0) {
            totalUserStakeNFT1155 -= 1;
        }
        
        // Update user stake balance by pool
        stakedBalancePerUser[poolId][msg.sender] -= amount*1e18;
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        // Update staked balance
        data.amount -= amount*1e18;
        
        // Update pool staked balance
        pool.stakedBalance -= amount*1e18; 

        // Update Staking Limit
        pool.stakingLimit += amount*1e18;
        
        // Update total staked balance by token address 
        totalAmountNFT1155Staked[pool.stakingToken][tokenId] -= amount*1e18;

        totalNFT1155Staking -= amount * 1e18;

        uint256 reward = 0;
         // If user unstake all token and has reward
         if ((canGetReward(strs,tokenId) && data.claimableReward > 0 && data.amount == 0) 
            || (data.claimableReward > 0 && pool.rewardRatio > 0 && data.amount == 0)) {
            reward = data.claimableReward; 
            require(IERC20(pool.rewardToken).balanceOf(address(this))  > reward, "Not enough balance");
            // If fixed time pool can only get partial amount ratio which was set by admin
            if (pool.poolType == 1 && data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS > block.timestamp) { 
                reward = reward * pool.rewardRatio / 100;
            }
            
            // Update pool total reward claimed and reward fund
            pool.totalRewardClaimed += reward;
            pool.rewardFund -= reward;
            
            // Update total reward user has claimed by token address
            totalRewardClaimed[pool.rewardToken] += reward;
            
            // Update pool reward claimed by user
            rewardClaimedPerUser[poolId][msg.sender] += reward;
            
            // Update pool reward claimed by user and token address
            totalRewardClaimedPerUser[pool.rewardToken][msg.sender] += reward;
            
            // Reset reward
            data.claimableReward = 0;
            
            // Transfer reward
            IERC20(pool.rewardToken).safeTransfer(msg.sender, reward);
        }  
        
        // Transfer staking token back to user
        IERC1155(pool.stakingToken).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        // Transfer tax fee
        _transferTaxFee();
        emit StakeNFT1155(pool.stakingToken,address(this), msg.sender, t, a, strs);
    }


    /**
     * @dev Claim reward when user has staked to the pool for a period of time 
     * @param strs: poolId(0), internalTxID(1)
    */
    function claimRewardNFT1155(string[] memory strs, uint256 tokenId) external poolExist(strs[0]) notBlocked payable { 
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData1155 storage data = stakingDatas1155[poolId][msg.sender][tokenId][strs[1]];
        
        require(msg.value == IStakingPool(trustPayAddress).taxFee(), "Tax fee amount is invalid");
        
        // Flexible pool update
        if (pool.poolType == 0) {
            pool.flexData[1] = rewardPerToken(poolId);
            pool.flexData[0] = block.timestamp;
        }
        
        // Update reward        
        data.claimableReward = earned(msg.sender,tokenId, strs);
        if(pool.poolType == 0) data.rewardPerTokenPaid = pool.flexData[1];
        // Flexible pool update
        if (pool.poolType != 0) {
            data.lastUpdateTime = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
        }
        
        
        uint256 availableAmount = data.claimableReward;
        
        // Fixed time get partial reward
        if (pool.poolType == 1 && data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS > block.timestamp) { 
            availableAmount = availableAmount * pool.rewardRatio / 100;
        }
        
        require(availableAmount > 0, "Reward is 0");
        require(IERC20(pool.rewardToken).balanceOf(address(this)) >= availableAmount, "Pool balance is not enough");
        require(canGetReward(strs, tokenId), "Not enough staking time"); 

        // Reset reward
        data.claimableReward = 0;
        data.claimedReward = availableAmount;
        
        // Update pool claimed amount
        pool.totalRewardClaimed += availableAmount;
        
        // Update pool reward fund
        pool.rewardFund -= availableAmount; 
        
        // Update reward claimed by token address
        totalRewardClaimed[pool.rewardToken] += availableAmount;
        
        // Update pool reward claimed by user
        rewardClaimedPerUser[poolId][msg.sender] += availableAmount;
        
        // Update pool reward claimed by user and token address
        totalRewardClaimedPerUser[pool.rewardToken][msg.sender] += availableAmount;
        
        // Transfer reward
        IERC20(pool.rewardToken).safeTransfer(msg.sender, availableAmount);

        // Transfer tax fee
        _transferTaxFee();
    
        emit StakingEvent(availableAmount, msg.sender, poolId, strs[1]); 
    } 

    function earned(address account,uint256 tokenId, string[] memory strs) 
        public
        view 
        returns(uint256)
    {
        string memory poolId = strs[0];
        string memory internalTxId = strs[1];
        StakingData1155 memory data = stakingDatas1155[poolId][account][tokenId][internalTxId];
        if (data.amount == 0) return 0;
        
        PoolInfo memory pool = poolInfo[poolId];
        uint256 amount = 0;
        // Flexible pool
        if (pool.poolType == 0) {
            amount = data.amount * (rewardPerToken(poolId) - data.rewardPerTokenPaid) / 1e20 + data.claimableReward;
        } else { 
            uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
            // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
            amount = (currentTimestamp - data.lastUpdateTime) * data.amount * pool.configs[4] / 1e18;
        }
        return pool.rewardFund > amount ? amount : pool.rewardFund;
    } 
    
    
    /**
     * @dev Check if enough time to claim reward
     * @param strs: poolId(0), internalTxId(1)
     * @param tokenId: token ID
    */
    function canGetReward(string[] memory strs, uint256 tokenId) public view returns (bool) {
        PoolInfo memory pool = poolInfo[strs[0]];
        StakingData1155 memory data = stakingDatas1155[strs[0]][msg.sender][tokenId][strs[1]];
        
        // Flexible & fixed time pool
        if (pool.poolType == 0) return true;
        
        // Pool with staking period
        return data.stakedTime + pool.configs[2] * ONE_DAY_IN_SECONDS <= block.timestamp;
    }

    function checkERC(address contractAddress) external view returns(bool) {
        return IERC721(contractAddress).supportsInterface(0x80ac58cd);
    }

    /**
     * @dev Return MaxTVL
     * @param poolDuration: endDate - startDate
     * @param totalReward: pool.initialFund
    */
    function getMaxTVL(uint256 poolDuration, uint256 totalReward) internal pure returns(uint256){
        return (totalReward* 1e20)/poolDuration;
    }

    /*================================ ADMINISTRATOR FUNCTIONS ================================*/
    
    /**
     * @dev Create pool
     * @param strs: poolId(0), internalTxID(1)
     * @param addr: stakingToken(0), rewardToken(1)
     * @param data: rewardFund(0), apr(1), rewardRatio(2), stakingLimit(3), poolType(4), poolNFT(5)
     * @param configs: startDate(0), endDate(1), duration(2), endStakedTime(3)
    */
    function createPool(string[] memory strs, address[] memory addr, uint256[] memory data, uint256[] memory configs) external onlyAdmins {
        require(poolInfo[strs[0]].initialFund == 0, "Pool already exists");
        require(data[0] > 0, "Reward fund must be greater than 0");
        require(configs[0] < configs[1], "End date must be greater than start date");
        require(configs[0] < configs[3], "End staking date must be greater than start date");
        
        uint256[] memory flexData = new uint256[](2);
        PoolInfo memory pool;
        if(data[4]!=0){
            pool = PoolInfo(addr[0], addr[1], 0, 0, data[0], data[0], data[1], 0, data[2], data[3] * 1e18, 1, data[4], flexData, configs);
        } else {
            uint256 poolDuration = configs[1] - configs[0];
            uint256 MaxTVL = getMaxTVL(poolDuration,data[0]);
            pool = PoolInfo(addr[0], addr[1], 0, 0, data[0], data[0], data[1], 0, data[2], MaxTVL, 1, data[4], flexData, configs);
        }
        
        if (isAdmin(msg.sender)) {
            IERC20(pool.rewardToken).safeTransferFrom(msg.sender, address(this), data[0]);
        }
        poolInfo[strs[0]] = pool;
        totalPoolCreated += 1;
        totalRewardFund[pool.rewardToken] += data[0];
        
        poolInfo[strs[0]].configs.push(data[5]);
        
        emit PoolUpdated(data[0], msg.sender, strs[0], strs[1]); 
    }
   

    /**
     * @dev Return configs of a pool
     * @param poolId: Pool id
    */
    function showConfigs(string memory poolId) external view returns(uint256[] memory) {
        PoolInfo memory pool = poolInfo[poolId];
        return pool.configs;
    }

    
    /**
     * @dev Return annual percentage rate of a pool
     * @param poolId: Pool id
    */
    function apr(string memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // If not flexible pool
        if (pool.poolType != 0) return pool.apr; 
        
        // Flexible pool
        uint256 poolDuration = pool.configs[1] - pool.configs[0];
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        return (ONE_YEAR_IN_SECONDS * pool.rewardFund / poolDuration) * 100 / pool.stakedBalance; 
    }
    
    /**
     * @dev Return amount of reward token distibuted per second
     * @param poolId: Pool id
    */
    function rewardPerToken(string memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        require(pool.poolType == 0, "Only flexible pool");
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0]; 
        
        // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
        uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
        // If stakeBalance = 0 or poolDuration = 0
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        
        // If the pool has ended then stop calculate reward per token
        if (currentTimestamp <= pool.flexData[0]) return pool.flexData[1];
        
        // result = result * 1e8 for zero prevention
        uint256 rewardPool = pool.initialFund * (currentTimestamp - pool.flexData[0]) * 1e20;
        
        // newRewardPerToken = rewardPerToken(newPeriod) + lastRewardPertoken          
        return rewardPool / (poolDuration * pool.stakedBalance) + pool.flexData[1];
    }
    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _tokenAddress: the token contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param _amount: the amount contract owner want to withdraw
    */
    function withdrawFund(address _tokenAddress, address _account, uint256 _amount) external onlyController {
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Pool not has enough balance");
        
        // Transfer fund back to account
        IERC20(_tokenAddress).safeTransfer(_account, _amount);
    }

    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param contractAddress: the NFT contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param tokenId: token ID
     * @param amount: amount
    */
    function withdrawNFT1155(address contractAddress, address _account, uint256 tokenId, uint256 amount) external onlyController {
        require(IERC1155(contractAddress).balanceOf(address(this), tokenId) >= amount, "Pool not has enough token");
        // Transfer fund back to account
        IERC1155(contractAddress).safeTransferFrom(address(this), _account, tokenId, amount, "");
    }
    
    /**
     * @dev Transfer tax fee 
    */
    function _transferTaxFee() internal {
        // If recipientAddress and taxFee are set
        if (IStakingPool(trustPayAddress).feeRecipientAddress() != address(0) && IStakingPool(trustPayAddress).taxFee() > 0) {
            payable(IStakingPool(trustPayAddress).feeRecipientAddress()).transfer(IStakingPool(trustPayAddress).taxFee());
        }
    }

    function setTotalNFT1155Staking(uint256 amount) public onlyController {
        totalNFT1155Staking = amount;
    }

    function viewTotalNFT1155Staked() external view returns(uint256) {
        return totalNFT1155Staked;
    }

    function viewTotalNFT1155Staking() external view returns(uint256) {
        return totalNFT1155Staking;
    }

    /**
     * @dev Check if a wallet address is admin or not
     * @param _address: wallet address of the user
    */
    function isAdmin(address _address) public view returns (bool) {
        return IStakingPool(trustPayAddress).isAdmin(_address);
    }

    /**
     * @dev Check if a wallet address is super admin or not
     * @param _address: wallet address of the user
    */
    function isSuperAdmin(address _address) external view returns (bool) {
        return IStakingPool(trustPayAddress).isSuperAdmin(_address);
    }
    
    /**
     * @dev Check if a user has been blocked
     * @param _address: user wallet 
    */
    function isBlackList(address _address) external view returns (bool) {
        return IStakingPool(trustPayAddress).isBlackList(_address);
    }
    
    /**
     * @dev Set pool active/deactive
     * @param _poolId: the pool id
     * @param _value: true/false
    */
    function setPoolActive(string memory _poolId, uint256 _value) external onlyAdmins {
        poolInfo[_poolId].active = _value;
        
        emit PoolActivationSet(msg.sender, _poolId, _value);
    }

    function initialize(address contractTrustPay) external {
        if(controller != address(0)) {
            require(msg.sender == controller,"Not controller");
        }
        require(contractTrustPay != address(0),"Contract address cant be address 0");
        trustPayAddress = contractTrustPay;
        taxFee = IStakingPool(trustPayAddress).taxFee();
        controller = IStakingPool(trustPayAddress).controller();
    }
}

