// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import"./SignatureUtils.sol"; 

contract Upgradable {
    mapping(address => bool) adminList; // admin list for updating pool
    mapping(address => bool) blackList; // blocked users
    mapping(address => bool) signers; // signers list
    IERC721 public nftCollection; // the collection of minted nfts
    IERC20 public rewardToken; // reward token 
    SignatureUtils public signatureUtils; // used for signature verification
    uint256 constant ONE_YEAR_IN_SECONDS = 31536000;
    uint256 constant ONE_DAY_IN_SECONDS = 86400;
    uint256 public totalAmountStaked; // balance of nft and token staked to the pools
    uint256 public totalRewardClaimed; // total reward user has claimed
    uint256 public totalPoolCreated; // total pool created by admin
    uint256 public totalRewardFund; // total pools reward fund
    uint256 public totalUserStaked; // total user has staked to pools
    mapping(string => PoolInfo) public poolInfo; // poolId => data: pools info
    mapping(address => uint256) public totalStakedBalancePerUser; // userAddr => amount: total value users staked to the pool
    mapping(address => uint256) public totalRewardClaimedPerUser; // userAddr => amount: total reward users claimed
    
    mapping(string => mapping(address => mapping(uint256 => StakingData))) public nftStaked; // poolId => owner => tokenId => data
    mapping(string => mapping(address => uint256)) public stakedBalancePerUser; // poolId => userAddr => amount: total value each user staked to the pool
    mapping(string => mapping(address => uint256)) public rewardClaimedPerUser; // poolId => userAddr => amount: reward each user has claimed
    mapping(string => mapping(address => uint256)) public totalNftStakedInPool; // poolId => userAddr => amount: totalNftStakedInPool by user 
    mapping(address => uint256) public stakedBalancePerToken;

    address[] public stakingTokens;
    string[] public allTokenPools;
    mapping(address => uint256) public tokenToTotalStaked; // stakingToken => totalStaked

    mapping(string => mapping(address => mapping(string=>StakingData))) public tokenStakingData; // poolId => user => internal txId => token staked data
    mapping(string => mapping(address => string[])) public stakingIds; // poolId => user => stakingIds[]
  
    /*================================ MODIFIERS ================================*/
    
    modifier onlyAdmins() {
        require(adminList[msg.sender], "Only admins");
        _;
    }
    
    modifier poolExist(string memory poolId, uint256 poolType) {
        require(poolInfo[poolId].initialFund != 0, "Pool is not exist");
        require(poolInfo[poolId].poolType == poolType, "Pool type is not supported");
        require(poolInfo[poolId].active == 1, "Pool has been disabled");
        _;
    }

    modifier notBlocked() {
        require(!blackList[msg.sender], "Caller has been blocked");
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
    
    event BlacklistStatus(
        address indexed user,
        bool status
    );

    event PoolStatus(
        string indexed poolId,
        uint256 status
    );

    /*================================ STRUCTS ================================*/
     
    struct StakingData {
        uint256 balance; // staked value
        uint256 stakedTime; // staked time
        uint256 unstakedTime; // unstaked time
        uint256 reward; // the total reward
        uint256 rewardPerTokenPaid; // reward per token paid
        address account; // staked account
    }
    
    struct PoolInfo {
        address stakingToken; // nft reward token or token staking of the pool
        uint256 stakedAmount; // amount of nfts staked to the pool
        uint256 stakedBalance; // total balance staked the pool
        uint256 totalRewardClaimed; // total reward user has claimed
        uint256 rewardFund; // pool amount for reward token available
        uint256 initialFund; // initial reward fund
        uint256 lastUpdateTime; // last update time
        uint256 rewardPerTokenStored; // reward distributed
        uint256 totalUserStaked; // total user staked
        uint256 poolType; // 0: nft, 1: token
        uint256 active; // pool activation status, 0: disable, 1: active
        uint256[] configs; // startDate(0), endDate(1), duration(2), endStakeDate(3)
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

contract SignatureUtils {
    function getMessageHash( 
        uint256 tokenId,
        uint256 price,
        uint256 salt,
        address owner,
        address signer
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenId, price, salt, owner, signer));
    } 

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(
        uint256 tokenId,
        uint256 price,
        uint256 salt,
        address owner,
        address signer,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(
            tokenId,
            price,
            salt,
            owner,
            signer
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
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
pragma solidity ^0.8.0;

//import"./Upgradable.sol"; 

contract StakingPool is Upgradable {
    using SafeERC20 for IERC20;

    /**
     * @dev Init pool utility contracts 
     * @param _signatureUtils: address of SignatureUtils contract, for NFTs data verification
     * @param _nftCollection: address of NFT721 Marketplace contract, stake NFTs from this contract
     * @param _rewardToken: address of Z token contract, the token used for reward distribution
    */
    function initPool(address _signatureUtils, address _nftCollection, address _rewardToken) external {
        rewardToken = IERC20(_rewardToken);
        signatureUtils = SignatureUtils(_signatureUtils);
        nftCollection = IERC721(_nftCollection); 
    }

    /*================================ MAIN FUNCTIONS ================================*/
    
    /**
     * @dev Stake NFT to the pool
     * @param strs: poolId(0), internalTxID(1)
     * @param data: tokenId(0), price(1), salt(2)
     * @param addr: signer(0)
     * @param signature: admin's signature
    */
    function stakeNft(
        string[] memory strs,
        uint256[] memory data, 
        address[] memory addr,
        bytes memory signature
    ) external poolExist(strs[0], 0) notBlocked {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
           
        require(block.timestamp >= pool.configs[0], "Staking time has not been started");
        require(block.timestamp <= pool.configs[3], "Staking time has ended"); 
        require(signers[addr[0]], "Only admin's signature");
        require(data[1] > 0, "NFT price must be greater than 0");

        // Verify signature for nft price
        require(
            signatureUtils.verify(
                data[0],
                data[1],
                data[2],
                msg.sender,
                addr[0],
                signature
            ),
            "NFT is invalid"
        );

        // Update pool reward token per second and last update time for reward calculation
        pool.rewardPerTokenStored = rewardPerToken(poolId);
        pool.lastUpdateTime = block.timestamp;
          
        StakingData memory nft = StakingData(
            data[1],
            block.timestamp,
            0,
            0,
            pool.rewardPerTokenStored,
            msg.sender 
        );

        
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked += 1;
        }
        
        // Update balance of token user staked to pools
        totalStakedBalancePerUser[msg.sender] += data[1];
        
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked += 1;
        }
        
        // Update balance of token, number of NFTs user staked to this pool
        totalNftStakedInPool[poolId][msg.sender] += 1;
        stakedBalancePerUser[poolId][msg.sender] += data[1];
    
        // Save nft staking data
        nftStaked[poolId][msg.sender][data[0]] = nft;

        // Update number of NFTs staked to the pool
        pool.stakedAmount += 1;
        
        // Update pool staking balance
        pool.stakedBalance += data[1];
        
        // Update total balance stake to pools
        totalAmountStaked += data[1];

        
        // Transfer user's NFT to the pool contract
        nftCollection.transferFrom(msg.sender, address(this), data[0]);
        
        emit StakingEvent(data[1], msg.sender, poolId, strs[1]);
    }
    
    /**
     * @dev Stake token to a pool
         note: if user stake to a locked pool, he cannot stake using an existed internalTxId 

     * @param strs: poolId(0), internalTxID(1) (staking Id)
     * @param amount: amount of token user want to stake to the pool
    */
    function stakeToken(
        string[] memory strs,
        uint256 amount
    ) external poolExist(strs[0], 1) notBlocked {
        string memory poolId = strs[0];
        string memory stakingId = strs[1];
        PoolInfo storage pool = poolInfo[poolId];
        
        require(block.timestamp >= pool.configs[0], "Staking time has not been started");
        require(block.timestamp <= pool.configs[3], "Staking time has ended"); 
        require(!blackList[msg.sender], "Caller has been blocked");
        require(amount > 0, "Staking amount must be greater than 0");

        // Update reward
        pool.rewardPerTokenStored = rewardPerToken(poolId);
        pool.lastUpdateTime = block.timestamp;

        if (!isLockedPool(poolId)){
            StakingData storage data = tokenStakingData[poolId][msg.sender][stakingId];

            //update reward of old staking data 
            data.reward = earned(poolId, msg.sender, 0, 1, stakingId);
            data.rewardPerTokenPaid = pool.rewardPerTokenStored;

            data.balance += amount;
            
            // Update staking time
            data.stakedTime = block.timestamp;
        }
        else{
            require(!isStakingDataExisted(poolId, msg.sender, stakingId),"Staking: staking id existed");
           
            //create new data by lockedStakingId
            StakingData memory data = StakingData(
                amount,
                block.timestamp,
                0,
                0,
                pool.rewardPerTokenStored,
                msg.sender
            );

            tokenStakingData[poolId][msg.sender][stakingId] = data;
            stakingIds[poolId][msg.sender].push(stakingId);
        }
        
        // Update staked balance
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked += 1;
        }
        
        // Update user's total staked balance 
        totalStakedBalancePerUser[msg.sender] += amount;
        
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked += 1;
        }
        
        // Update user's staked balance to the pool
        stakedBalancePerUser[poolId][msg.sender] += amount;
        
        // Update pool staked balance 
        pool.stakedBalance += amount;
        
        // Update total staked balance to pools
        totalAmountStaked += amount;

        //update total stake per token
        stakedBalancePerToken[pool.stakingToken] += amount;

        //update helper data
        tokenToTotalStaked[pool.stakingToken] += amount;
  
        // Transfer user's token to the contract
        IERC20(pool.stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        
        emit StakingEvent(amount, msg.sender, poolId, strs[1]);
    }
 
   /**
    * @dev Unstake NFT
    * @param strs: poolId(0), internalTxID(1)
    * @param tokenId: NFT tokenId user want to unstake 
   */
    function unstakeNft(string[] memory strs, uint256 tokenId)
        external
        poolExist(strs[0], 0) notBlocked
    {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage nft = nftStaked[poolId][msg.sender][tokenId];
        
        require(nft.unstakedTime == 0, "NFT was unstaked");
        require(nft.account == msg.sender, "Caller is not NFT owner");
        
        // Update reward
        pool.rewardPerTokenStored = rewardPerToken(poolId);
        pool.lastUpdateTime = block.timestamp;
        nft.reward = earned(poolId, msg.sender, tokenId, 0, strs[1]);
        nft.rewardPerTokenPaid = pool.rewardPerTokenStored;
        
        // Update balance user has staked to the pool
        totalStakedBalancePerUser[msg.sender] -= nft.balance;
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked -= 1;
        }
        
        // Update total NFTs user staked to the pool
        totalNftStakedInPool[poolId][msg.sender] -= 1;
        
        // Update user staked balance to the pool
        stakedBalancePerUser[poolId][msg.sender] -= nft.balance;
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        
        // Update number of NFTs staked to the pool
        pool.stakedAmount -= 1;
        
        // Update pool staked balance
        pool.stakedBalance -= nft.balance; 
        
        // Update total staked balance
        totalAmountStaked -= nft.balance;
        
        // Update unstaked time
        nft.unstakedTime = block.timestamp;
        
        uint256 reward = 0;
        
        // If user unstake NFT and has reward
        if (canGetReward(poolId, tokenId, 0, strs[1]) && nft.reward > 0) {
            reward = nft.reward;
            
            // Update pool total reward claimed
            pool.totalRewardClaimed += reward;
            
            // Update pool reward fund
            pool.rewardFund -= reward;
            
            // Update total reward users claimed
            totalRewardClaimed += reward;
            
            // Update user's reward claimed by pool
            rewardClaimedPerUser[poolId][msg.sender] += reward;
            
            // Update reward claimed of user to pools
            totalRewardClaimedPerUser[msg.sender] += reward;
            
            // Reset reward
            nft.reward = 0;
            
            // Transfer reward to user
            IERC20(pool.stakingToken).safeTransfer(msg.sender, reward);
        }
        
        // Transfer NFT back to user
        nftCollection.transferFrom(address(this), msg.sender, tokenId);
        
        emit StakingEvent(reward, msg.sender, poolId, strs[1]);
    } 
    
    /**
     * @dev Unstake token of a pool
     * @param strs: poolId(0), internalTxID(1)
     * @param amount: amount of token user want to unstake
   */
    function unstakeToken(string[] memory strs, uint256 amount)
        external
        poolExist(strs[0], 1) notBlocked
    {
        string memory poolId = strs[0];
        string memory stakingId = strs[1];
        PoolInfo storage pool = poolInfo[poolId];

        StakingData storage data = tokenStakingData[poolId][msg.sender][stakingId];

        require(amount > 0, "Unstake amount must be greater than 0");
        require(data.balance >= amount, "Not enough staking balance");

        if(isLockedPool(poolId)){
            require(data.balance==amount, "Unstake: Amount not valid");
        }
        
        // Update reward
        pool.rewardPerTokenStored = rewardPerToken(poolId);
        pool.lastUpdateTime = block.timestamp;
        data.reward = earned(poolId, msg.sender, 0, 1, stakingId);
        data.rewardPerTokenPaid = pool.rewardPerTokenStored;

        // Update user staked balance
        totalStakedBalancePerUser[msg.sender] -= amount;
        if (totalStakedBalancePerUser[msg.sender] == 0) {
            totalUserStaked -= 1;
        }
        
        // Update user staked balance by pool
        stakedBalancePerUser[poolId][msg.sender] -= amount;
        if (stakedBalancePerUser[poolId][msg.sender] == 0) {
            pool.totalUserStaked -= 1;
        }
        
        // Update staking amount
        data.balance -= amount;

        //note: considering delete staking data if balance get to zero
        
        // Update pool staked balance
        pool.stakedBalance -= amount;
        
        // Update total staked balance user staked to pools
        totalAmountStaked -= amount;

        //update total stake per token
        stakedBalancePerToken[pool.stakingToken] -= amount;
        
        uint256 reward = 0;
        
        // If user unstake all token and has reward
        //note: && data.balance == 0
        if (canGetReward(poolId, 0, 1, stakingId) && data.reward > 0) {
            reward = data.reward; 
            
            // Update pool reward claimed
            pool.totalRewardClaimed += reward;
            
            // Update pool reward fund
            pool.rewardFund -= reward;
            
            // Update total reward claimed
            totalRewardClaimed += reward;
            
            // Update reward user claimed by the pool
            rewardClaimedPerUser[poolId][msg.sender] += reward;
            
            // Update reward user claimed by pools
            totalRewardClaimedPerUser[msg.sender] += reward;
            
            // Reset reward
            data.reward = 0;
            
            // Transfer reward to user
            IERC20(rewardToken).safeTransfer(msg.sender, reward);
        } 
        
        //update helper data
        tokenToTotalStaked[pool.stakingToken] -= amount;
        
        
        // Transfer token back to user
        IERC20(pool.stakingToken).safeTransfer(msg.sender, amount);
       

        emit StakingEvent(reward, msg.sender, poolId, strs[1]);
    } 
    
    /**
     * @dev Claim reward when user has staked to the pool for a period of time 
     * @param strs: poolId(0), internalTxID(1)
     * @param data: poolType(0), tokenId(1)
    */
    function claimReward(string[] memory strs, uint256[] memory data)
        external
        poolExist(strs[0], data[0]) notBlocked
    { 
        string memory poolId = strs[0];
        string memory stakingId = strs[1];
        PoolInfo storage pool = poolInfo[poolId];
        StakingData storage item;
        
        if (data[0] == 0) {
            item = nftStaked[poolId][msg.sender][data[1]];
        } else { 
            item = tokenStakingData[poolId][msg.sender][stakingId];
        }
         
        // Update reward
        pool.rewardPerTokenStored = rewardPerToken(poolId);
        pool.lastUpdateTime = block.timestamp;
        item.reward = earned(poolId, msg.sender, data[1], data[0], stakingId);
        item.rewardPerTokenPaid = pool.rewardPerTokenStored;
        
        uint256 reward = item.reward;
        require(reward > 0, "Reward is 0");
        require(
            //note: old: staking token
            //new => rewardToken
            IERC20(rewardToken).balanceOf(address(this)) >= reward,
            "Pool balance is not enough"
        );
        require(canGetReward(poolId, data[1], data[0], stakingId), "Not enough staking time"); 

        // Reset reward
        item.reward = 0;
        
        // Update reward claimed by the pool
        pool.totalRewardClaimed += reward;
        
        // Update pool reward fund
        pool.rewardFund -= reward; 
        
        // Update total reward claimed
        totalRewardClaimed += reward;
        
        // Update reward user claimed by the pool
        rewardClaimedPerUser[poolId][msg.sender] += reward;
        
        // Update total reward user claimed by pools
        totalRewardClaimedPerUser[msg.sender] += reward;
        
        // Transfer reward to user
        if (data[0] == 0) { // If NFT staking pool
            IERC20(pool.stakingToken).safeTransfer(msg.sender, reward);
        } else { // If token staking pool
            IERC20(rewardToken).safeTransfer(msg.sender, reward);
        }

        emit StakingEvent(reward, msg.sender, poolId, strs[1]); 
    }
    
    /**
     * @dev Check if enough time to claim reward
     * @param poolId: Pool id
     * @param tokenId: NFT token id
     * @param poolType: 0(NFT), 1(Token)
    */
    function canGetReward(string memory poolId, uint256 tokenId, uint256 poolType, string memory stakingId) public view returns (bool) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // If flexible pool
        if (pool.configs[2] == 0) return true;
        
        StakingData memory data;
        if (poolType == 0) {
            data = nftStaked[poolId][msg.sender][tokenId];
        } else {
            data = tokenStakingData[poolId][msg.sender][stakingId];
        }
        
        // Pool with staking period
        return data.stakedTime + pool.configs[2] * 1 seconds <= block.timestamp;
    }

    /**
     * @dev Check amount of reward a user can receive
     * @param poolId: Pool id
     * @param account: wallet address of user
     * @param tokenId: NFT token id
     * @param poolType: Pool type
     * @param stakingId: internal transaction id 
    */
    function earned(string memory poolId, address account, uint256 tokenId, uint256 poolType, string memory stakingId) 
        public
        view
        returns (uint256)
    {
        StakingData memory item = tokenStakingData[poolId][account][stakingId]; 
        
        if (poolType == 0) {
            item = nftStaked[poolId][account][tokenId];
            
            // If NFT was unstaked
            if (item.unstakedTime != 0) return item.reward;
        }
        
        // If staked amount = 0
        if (item.balance == 0) return 0;
        
        PoolInfo memory pool = poolInfo[poolId];
        uint256 amount = item.balance * (rewardPerToken(poolId) - item.rewardPerTokenPaid) / 1e8 + item.reward;
         
        return pool.initialFund > amount ? amount : pool.initialFund;
    }
    
    /**
     * @dev Return amount of reward token distibuted per second
     * @param poolId: Pool id
    */
    function rewardPerToken(string memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0]; 
        
        // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
        uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
        
        // If stakeBalance = 0 or poolDuration = 0
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        // If the pool has ended then stop calculate reward per token
        if (currentTimestamp < pool.lastUpdateTime) return pool.rewardPerTokenStored;
        
        // result = result * 1e8 for zero prevention
        uint256 rewardPool = pool.initialFund * (currentTimestamp - pool.lastUpdateTime) * 1e8;
        
        // newRewardPerToken = rewardPerToken(newPeriod) + lastRewardPertoken    
        return rewardPool / (poolDuration * pool.stakedBalance) + pool.rewardPerTokenStored;
    }
    

    /**
     * @dev REerturn data to calculate apr
     * @return 0: total value of reward in 1 year, 1: total value locked at the time T
     */
    function getPoolAprData(string memory poolId) external view returns(uint256, uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0];
        if (pool.stakedBalance == 0 || poolDuration == 0) return (0,0);

        return ((ONE_YEAR_IN_SECONDS * pool.rewardFund / poolDuration - pool.totalRewardClaimed), pool.stakedBalance);
    }

    /*================================ ADMINISTRATOR FUNCTIONS ================================*/
    
    /**
     * @dev Create pool
     * @param strs: poolId(0), internalTxID(1)
     * @param stakingToken: staking token of token staking pool / reward token of NFT staking pool
     * @param data: rewardFund(0), poolType(1)
     * @param configs: startDate(0), endDate(1), duration(2), endStakedTime(3)
   */
    function createPool(string[] memory strs, address stakingToken, uint256[] memory data, uint256[] memory configs) external onlyAdmins {
        require(poolInfo[strs[0]].initialFund == 0, "Pool already exists");
        require(data[0] > 0, "Reward fund must be greater than 0");
        require(configs[0] < configs[1], "End date must be greater than start date");
        require(configs[0] < configs[3], "End staking date must be greater than start date");
        
        if(data[1] == 1){
            stakingTokens.push(stakingToken);
            allTokenPools.push(strs[0]);
        }

        PoolInfo memory pool = PoolInfo(stakingToken, 0, 0, 0, data[0], data[0], 0, 0, 0, data[1], 1, configs);
        poolInfo[strs[0]] = pool;
        totalPoolCreated += 1;
        totalRewardFund += data[0];
        
        emit PoolUpdated(data[0], msg.sender, strs[0], strs[1]); 
    }
 
    /**
     * @dev Update pool
     * @param strs: poolId(0), internalTxID(1)
     * @param newConfigs: startDate(0), endDate(1), rewardFund(2), endStakingDate(3), poolType(4)
   */
    function updatePool(string[] memory strs, uint256[] memory newConfigs)
        external
        onlyAdmins
        poolExist(strs[0], newConfigs[4])
    {
        string memory poolId = strs[0];
        PoolInfo storage pool = poolInfo[poolId];
        
        if (newConfigs[0] != 0) {
            require(pool.configs[0] > block.timestamp, "Pool is already published");
            pool.configs[0] = newConfigs[0];
        }
        if (newConfigs[1] != 0) {
            require(newConfigs[1] > pool.configs[0], "End date must be greater than start date");
            require(newConfigs[1] >= block.timestamp, "End date must not be the past");
            pool.configs[1] = newConfigs[1];
        }
        if (newConfigs[2] != 0) {
            require(
                newConfigs[2] >= pool.initialFund,
                "New reward fund must be greater than or equals to existing reward fund"
            );
            
            totalRewardFund = totalRewardFund - pool.initialFund + newConfigs[2];
            pool.rewardFund = newConfigs[2];
            pool.initialFund = newConfigs[2];
        }
        if (newConfigs[3] != 0) {
            require(newConfigs[3] > pool.configs[0], "End staking date must be greater than start date");
            require(newConfigs[3] <= pool.configs[1], "End staking date must be less than or equals to end date");
            pool.configs[3] = newConfigs[3];
        }
        
        emit PoolUpdated(pool.initialFund, msg.sender, strs[0], strs[1]);
    }
    
    // /**
    //  * @dev Emercency withdraw staking token, all staked data will be deleted, onlyProxyOwner can execute this function
    //  * @param _poolId: the poolId
    //  * @param _account: the user wallet address want to withdraw token
    // */
    // function emercencyWithdrawToken(string memory _poolId, address _account,string memory _stakingId) external {
    //     PoolInfo memory pool = poolInfo[_poolId];
    //     StakingData memory data = tokenStakingData[_poolId][_account][_stakingId];
    //     require(data.balance > 0, "Staked balance is 0");
        
    //     // Transfer staking token back to user
    //     IERC20(pool.stakingToken).safeTransfer(_account, data.balance);
        
    //     //update status variable 
    //     totalStakedBalancePerUser[_account] -= data.balance;
    //     if (totalStakedBalancePerUser[_account] == 0) {
    //         totalUserStaked -= 1;
    //     }
        
    //     stakedBalancePerUser[_poolId][_account] -= data.balance;
    //     if (stakedBalancePerUser[_poolId][_account] == 0) {
    //         pool.totalUserStaked -= 1;
    //     }

    //     totalAmountStaked -= data.balance;
    //     pool.stakedBalance -= data.balance;

    //     // Delete data
    //     delete tokenStakingData[_poolId][_account][_stakingId];
    // }
    
    // /**
    //  * @dev Emercency withraw NFT, all staked data will be deleted, onlyProxyOwner can execute this function
    //  * @param _poolId: the poolId
    //  * @param _account: the user wallet address want to withdraw NFT
    //  * @param _tokenId: the NFT tokenID user want to withdraw
    // */
    // function emercencyWithdrawNFT(string memory _poolId, address _account, uint256 _tokenId) external {
    //     PoolInfo memory pool = poolInfo[_poolId];
    //     StakingData memory data = nftStaked[_poolId][_account][_tokenId];
    //     require(data.account == _account, "NFT does not belong to this account");
        
    //     // Update balance user has staked to the pool
    //     totalStakedBalancePerUser[_account] -= data.balance;
    //     if (totalStakedBalancePerUser[_account] == 0) {
    //         totalUserStaked -= 1;
    //     }
        
    //     // Update total NFTs user staked to the pool
    //     totalNftStakedInPool[_poolId][_account] -= 1;
        
    //     // Update user staked balance to the pool
    //     stakedBalancePerUser[_poolId][_account] -= data.balance;
    //     if (stakedBalancePerUser[_poolId][_account] == 0) {
    //         pool.totalUserStaked -= 1;
    //     }
        
    //     // Update number of NFTs staked to the pool
    //     pool.stakedAmount -= 1;
        
    //     // Update pool staked balance
    //     pool.stakedBalance -= data.balance; 
        
    //     // Update total staked balance
    //     totalAmountStaked -= data.balance;
        
    //     // Update staked balance of user to the pool
    //     stakedBalancePerUser[_poolId][_account] -= data.balance;

    //     // Transfer NFT back to user
    //     nftCollection.transferFrom(address(this), _account, _tokenId);        

    //     // Delete data
    //     delete nftStaked[_poolId][_account][_tokenId];
    // }
    
    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _tokenAddress: the token contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param _amount: the amount contract owner want to withdraw
    */
    function withdrawFund(address _tokenAddress, address _account, uint256 _amount) external {
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Pool not has enough balance");
        
        // Transfer fund back to account
        IERC20(_tokenAddress).safeTransfer(_account, _amount);
    }
    
    /**
     * @dev Contract owner set admin for execute administrator functions
     * @param _address: wallet address of admin
     * @param _value: true/false
    */
    function setAdmin(address _address, bool _value) external { 
        adminList[_address] = _value;
    } 

    /**
     * @dev Check if a wallet address is admin or not
     * @param _address: wallet address of the user
    */
    function isAdmin(address _address) external view returns (bool) {
        return adminList[_address];
    }

    /**
     * @dev Block users
     * @param _address: wallet address of user
     * @param _value: true/false
    */
    function setBlacklist(address _address, bool _value) external onlyAdmins {
        blackList[_address] = _value;

        emit BlacklistStatus(_address, _value);
    }
    
    /**
     * @dev Check if a user has been blocked
     * @param _address: user wallet 
    */
    function isBlackList(address _address) external view returns (bool) {
        return blackList[_address];
    }
    
    /**
     * @dev Check if a address is signer
     * @param _address: signer wallet 
    */
    function isSigner(address _address) external view returns (bool) {
        return signers[_address];
    }
    
    /**
     * @dev Contract owner set signer for signature creation
     * @param _address: wallet address of signer
     * @param _value: true/false
    */
    function setSigner(address _address, bool _value) external { 
        signers[_address] = _value;
    }
    
    /**
     * @dev Set signature util contract address for signature verification
     * @param _signatureUtils: signature util contract address
    */
    function setSignatureUtilsAddress(address _signatureUtils) external {
        signatureUtils = SignatureUtils(_signatureUtils);
    }
    
    /**
     * @dev Set nft contract address
     * @param _nftCollection: address of NFT721 Marketplace contract, stake NFTs from this contract
    */
    function setNftCollection(address _nftCollection) external {
        nftCollection = IERC721(_nftCollection); 
    }
    
    /**
     * @dev Set reward token contract address
     * @param _rewardToken: address of reward token contract
    */
    function setRewardToken(address _rewardToken) external {
        rewardToken = IERC20(_rewardToken);
    }
    
    /**
     * @dev Set pool active/deactive
     * @param _poolId: the pool id
     * @param _value: true/false
    */
    function setPoolActive(string memory _poolId, uint256 _value) external onlyAdmins {
        poolInfo[_poolId].active = _value;
        emit PoolStatus(_poolId, _value);
    }

    
    /**
     * @dev check if pool is locked
     */
    function isLockedPool(string memory poolId_) public view returns(bool) {
        return poolInfo[poolId_].configs[2] != 0;
    }
    
     /**
     * @dev check if staking data existed
     */
    function isStakingDataExisted(string memory poolId_, address user_, string memory stakingId_) internal view returns(bool){
        return tokenStakingData[poolId_][user_][stakingId_].stakedTime != 0;
    }

    /**
     * @dev get token to total staked (of all stakign token)
     * @return 0: list of staking token address, 1: list of corresponding total staked amount
     */
    function getTokenToTotalStaked() external view returns(address[] memory, uint256[] memory) {
        uint256[] memory totalStaked = new uint256[](stakingTokens.length);

        for(uint16 i=0; i < stakingTokens.length; i ++){
            totalStaked[i] = tokenToTotalStaked[stakingTokens[i]];
        }
        return (stakingTokens, totalStaked);
    } 

    /**
     * @dev get total reward claimed of all  token pools
     * @return  0: total intial reward of all pools, 1: total reward claimed of all pools
     */
    function getTotalInitialAndClaimedReward() external view returns(uint256, uint256) {
        uint256 totalClaimed;
        uint256 totalInitialReward;
        for (uint16 i=0; i< allTokenPools.length; i++){
            totalInitialReward += poolInfo[allTokenPools[i]].initialFund;
            totalClaimed += poolInfo[allTokenPools[i]].totalRewardClaimed;
        }

        return (totalInitialReward, totalClaimed);
    }


    /**
     * @dev get list of total staked balance of user in a list of pools and list of total tvl of each pool
     * @return 0: list of staked balance of user, 1: lsit of total tvl
     */
    function getTotalStakedBalanceByPool(address user_, string[] memory poolIds_) external view returns (uint256[] memory, uint256[] memory ){
        uint256[] memory totalStakedBalanceInPoolByUser = new uint256[](poolIds_.length);
        uint256[] memory totalStakedBalanceOfPool = new uint256[](poolIds_.length);

        for(uint16 i=0; i<poolIds_.length; i++){
            totalStakedBalanceInPoolByUser[i] = stakedBalancePerUser[poolIds_[i]][user_];
            totalStakedBalanceOfPool[i] = poolInfo[poolIds_[i]].stakedBalance;
        }

        return (totalStakedBalanceInPoolByUser, totalStakedBalanceOfPool);
    }

    /**
     * @dev for testing
     */
    function blockTime() external view returns(uint256){
        return block.timestamp;
    }

    function getPoolDuration(string memory poolId_) external view returns(uint256){
        return (poolInfo[poolId_].configs[1] - poolInfo[poolId_].configs[0]);
    }
}  

