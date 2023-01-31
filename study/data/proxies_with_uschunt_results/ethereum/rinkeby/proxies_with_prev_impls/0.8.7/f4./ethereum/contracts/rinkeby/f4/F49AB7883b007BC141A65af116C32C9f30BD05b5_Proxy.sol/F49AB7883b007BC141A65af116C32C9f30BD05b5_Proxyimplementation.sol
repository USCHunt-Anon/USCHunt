// : MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

//import"../IERC20.sol";
//import"../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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


pragma solidity >=0.6.2;

//import'./IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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


// : MIT
pragma solidity 0.8.7;

interface IController {
    function admins(address) external view returns(bool);
    function ttl() external view returns(uint256);
    function lockTime() external view returns(uint256);
    function minCollateralRatio() external view returns(uint16);
    function maxCollateralRatio() external view returns(uint16);
    function calculationDecimal() external pure returns(uint16);
    function discountRates(address) external view returns(uint16);
    function acceptedCollateral(address) external view returns(bool);
    function mintContract() external view returns(address);
    function lockContract() external view returns(address);
    function limitOfferContract() external view returns(address);
    function router() external view returns(address);
    function oracles(address) external view returns(address);
    function pools(address) external view returns(address);
    function collateralForToken(address) external view returns(address);
    function tokenForOracle(address) external view returns(address);
    function royaltyFeeRatio() external view returns(uint256);
    function recieverAddress() external view returns(address);
}

// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
//import{ IController } from "./interfaces/IController.sol";
//import{ Ownable } from "./Ownable.sol";
//import{ Oracle } from "./Oracle.sol";

contract Controller is IController, Ownable, Initializable {
    
    uint16 public override minCollateralRatio;
    uint16 public override maxCollateralRatio;
    uint16 public constant override calculationDecimal = 2;    

    uint256 public override ttl;
    uint256 public override lockTime;

    address public override mintContract;
    address public override lockContract;
    
    address public override router;

    // mapping token address to 
    mapping(address => address) public override oracles;

    // mapping token address to AMM pool address
    mapping(address => address) public override pools;
    
    // mapping listing token to collateral token
    mapping(address => address) public override collateralForToken;

    mapping(address => bool) public override acceptedCollateral;

    mapping(address => address) public tokenOwners;

    mapping(address => uint16) public override discountRates;
    
    mapping(address => bool) public override admins;

    uint256 public override royaltyFeeRatio;
    address public override recieverAddress;
    address public override limitOfferContract;

    mapping(address => address) public override tokenForOracle;

    event ListingToken(address indexed tokenAddress, uint256 timestamp);
    event DelistingToken(address indexed tokenAddress, uint256 timestamp);
    event UpdatePrices(address[] tokenAddresses, uint256[] prices);

    constructor() {
    }
    
    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner(), "Only admin");
        _;
    }

    function initialize(uint16 _minCollateralRatio, uint16 _maxCollateralRatio, uint256 _ttl, address _router) external onlyOwner initializer{
        minCollateralRatio = _minCollateralRatio;
        maxCollateralRatio = _maxCollateralRatio;
        ttl = _ttl;
        router = _router;
    }
    
    function setAdmin(address _addr) public onlyOwner {
        admins[_addr] = true;
    }
    
    function revokeAdmin(address _addr) public onlyOwner {
        admins[_addr] = false;
    }

    function setRoyaltyFeeRatio(uint256 _fee) public onlyOwner {
        royaltyFeeRatio = _fee;
    }

    function setRecieverAddress(address _addr) public onlyOwner {
        recieverAddress = _addr;
    }

    function setMinCollateralRatio(uint16 _minCollateralRatio) external onlyOwner {
        minCollateralRatio = _minCollateralRatio;
    }

    function setMaxCollateralRatio(uint16 _maxCollateralRatio) external onlyOwner {
        maxCollateralRatio = _maxCollateralRatio;
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function setTTL(uint256 _ttl) external onlyOwner {
        ttl = _ttl;
    }

    function setLockTime(uint256 _lockTime) external onlyOwner {
        require(_lockTime >= 300, "Lock time must be at least 5 minutes");
        lockTime = _lockTime;
    }

    function setMintContract(address _mintAddress) external onlyOwner {
        mintContract = _mintAddress;
    }

    function setLockContract(address _lockContract) external onlyOwner {
        lockContract = _lockContract;
    }

    function setLimitOfferContract(address _limitOfferContract) external onlyOwner {
        limitOfferContract = _limitOfferContract;
    }
    
    function setDiscountRate(address _tokenAddress, uint16 _rate) external onlyOwner {
        discountRates[_tokenAddress] = _rate;
    }

    function registerIDOTokens(
        address[] memory tokenAddresses,
        address[] memory oracleAddresses,
        address[] memory poolAddresses,
        address[] memory collateralTokens,
        uint16[] memory discountRate
    ) public onlyAdmin {
        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            registerIDOToken(tokenAddresses[i], oracleAddresses[i], poolAddresses[i], collateralTokens[i], discountRate[i]);
        }
    }

    function registerIDOToken(
        address tokenAddress,
        address oracleAddress,
        address poolAddress,
        address collateralToken,
        uint16 discountRate
    ) public onlyAdmin {
        require(tokenAddress != collateralToken, "Duplicate token addresses");
        require(collateralForToken[tokenAddress] == address(0), "Token is already registered");
        require(acceptedCollateral[collateralToken], "Invalid colateral token");
        collateralForToken[tokenAddress] = collateralToken;
        tokenForOracle[oracleAddress] = tokenAddress;
        address token0 = IUniswapV2Pair(poolAddress).token0();
        address token1 = IUniswapV2Pair(poolAddress).token1();
        require(token0 == tokenAddress || token1 == tokenAddress, "Missing token address");
        require(token0 == collateralToken || token1 == collateralToken, "Missing collateral address");
        pools[tokenAddress] = poolAddress;
        oracles[tokenAddress] = oracleAddress;
        tokenOwners[tokenAddress] = msg.sender;
        discountRates[tokenAddress] = discountRate;
        emit ListingToken(tokenAddress, block.timestamp);
    }

    function unregisterToken(address tokenAddress) public onlyAdmin {
        require(collateralForToken[tokenAddress] != address(0), "Token have not been registered");
        collateralForToken[tokenAddress] = address(0);
        pools[tokenAddress] = address(0);
        oracles[tokenAddress] = address(0);
        tokenOwners[tokenAddress] = address(0);
        emit DelistingToken(tokenAddress, block.timestamp);
    }

    function updateIDOToken(
        address tokenAddress,
        address oracleAddress,
        address poolAddress,
        address collateralToken
    ) public onlyAdmin {
        require(collateralForToken[tokenAddress] != address(0), "Token have not been registered");
        require(acceptedCollateral[collateralToken], "Invalid collateral token");
        pools[tokenAddress] = poolAddress;
        oracles[tokenAddress] = oracleAddress;
        tokenForOracle[oracleAddress] = tokenAddress;
    }

    function registerCollateralAsset(address collateralAsset, bool value) public onlyOwner {
        acceptedCollateral[collateralAsset] = value;
    }
    
    function updatePrices(address[] memory tokenAddresses, uint256[] memory targetPrices) public onlyAdmin {
        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            Oracle(oracles[tokenAddresses[i]]).update(targetPrices[i]);
        }

        emit UpdatePrices(tokenAddresses, targetPrices);
    }

    function getOraclePrices(address[] memory tokenAddresses) public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory targetPrices = new uint256[](tokenAddresses.length);
        uint256[] memory lastUpdated = new uint256[](tokenAddresses.length);
        for(uint256 i = 0; i < tokenAddresses.length; i++) {
            (targetPrices[i], lastUpdated[i]) = Oracle(oracles[tokenAddresses[i]]).getTargetValue();
        }
        return(targetPrices, lastUpdated);
    }
}

// : MIT

pragma solidity 0.8.7;

contract Ownable {
    bytes32 private constant ownerPosition = keccak256("owner.contract:2022");

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(msg.sender == owner(), "Caller not proxy owner");
        _;
    }

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view returns (address _owner) {
        bytes32 position = ownerPosition;
        assembly {
            _owner := sload(position)
        }
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner(), "New owner is the current owner");
        emit OwnershipTransferred(owner(), _newOwner);
        _setOwner(_newOwner);
    }

    function _setOwner(address _newOwner) internal {
        bytes32 position = ownerPosition;
        assembly {
            sstore(position, _newOwner)
        }
    }
}

// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IEURB is IERC20{
    function _feePercentage() external view returns(uint256);
    function decimals() external view returns(uint8);
    function isExcludedFromFee(address) external view returns(bool);
    function isReceiverExcludedFromFee(address) external view returns(bool);
    function isTransactionExcludedFromFee(address,address) external view returns(bool);
    function getTransactionFee(address,address,uint256) external view returns(uint256);
    function mint(address,uint256) external;
    function burn(uint256) external;
}

// : MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// : MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// : MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

//import"../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/access/Ownable.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import{IController} from "./interfaces/IController.sol";
//import"./interfaces/IOracle.sol";

contract Oracle is IOracle, Ownable {
  
    uint256 targetPrice;
    uint256 updatedTime;
    address public controller;

    event UpdatePrice(
        address indexed tokenAddress,
        uint256 targetPrice,
        uint256 updatedTime
    );


    
    /**
     * Network: Rinkeby
     * Oracle:  0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel Node)
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor(address _controller) {
        setController(_controller);
    }

    modifier onlyAdmin() {
        require(IController(controller).admins(msg.sender) || msg.sender == owner() || msg.sender == controller, "Only admin can update price");
        _;
    }
    
    function setController(address _addr) public onlyOwner {
        controller = _addr;
    }

    function update(uint256 _targetPrice) public onlyAdmin {
        address tokenAddress = IController(controller).tokenForOracle(address(this));
        targetPrice = _targetPrice;
        updatedTime = block.timestamp;
        emit UpdatePrice(tokenAddress, targetPrice, updatedTime);
    }

    function getTargetValue() external view override returns(uint256, uint256) {
        return (targetPrice, updatedTime);
    }
}


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.0;

interface IOracle {
    function getTargetValue() external view returns(uint256, uint256);
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
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
//import"@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

//import{IController} from "./interfaces/IController.sol";
//import"./Controller.sol";
//import{Ownable} from "./Ownable.sol";
//import{IEURB} from "./interfaces/IEURB.sol";

contract LimitOffer is Ownable, ReentrancyGuard {
    using SafeERC20 for IEURB;

    address public controllerAddress;

    uint16 public constant royaltyDecimal = 4;

    struct Order {
        uint256 offerCollateralAmount;
        uint256 offerUAssetAmount;
        address uAssetAddress;
        address userAddress;
    }
    mapping(bytes => Order) public orders;     // id -> order
    mapping(bytes => uint256) public offerFee;

    uint256 public amountToClaim;
    

    event Offer(
        address indexed userAddress,
        address indexed uAssetAddress,
        bytes id,
        uint256 uAssetAmount,
        uint256 collateralAmount,
        uint256 timestamp
    );

    event WithDraw(
        address indexed userAddress,
        address indexed uAssetAddress,
        bytes id,
        uint256 uAssetAmount,
        uint256 collateralAmount,
        uint256 timestamp
    );

    event Buy(bytes[] ids);
    event Sell(bytes[] ids);

    constructor() {}
    
    modifier onlyAdmin() {
        require(IController(controllerAddress).admins(msg.sender) || msg.sender == owner(), "Only admin");
        _;
    }

    function setControllerAddress(address _controllerAddress) external onlyOwner {
        controllerAddress = _controllerAddress;
    }

    function offerBuy(address uAssetAddress, uint256 uAssetAmount, uint256 collateralAmount, bytes memory id) external nonReentrant {
        address collateralAddress = IController(controllerAddress).collateralForToken(uAssetAddress);
        {
            uint256 royaltyFee = IController(controllerAddress).royaltyFeeRatio();
            uint256 fee = collateralAmount * royaltyFee / (10 ** royaltyDecimal);
            
            IEURB(collateralAddress).safeTransferFrom(msg.sender, address(this), fee);
            IEURB(collateralAddress).safeTransferFrom(msg.sender, address(this), collateralAmount);
            offerFee[id] = fee - IEURB(collateralAddress).getTransactionFee(msg.sender, address(this), fee);
        }
        
        Order storage order = orders[id];
        require(order.offerCollateralAmount == 0, "Still being offered to buy");
        order.offerCollateralAmount = collateralAmount - IEURB(collateralAddress).getTransactionFee(msg.sender, address(this), collateralAmount);
        
        order.offerUAssetAmount = uAssetAmount;
        order.uAssetAddress = uAssetAddress;
        order.userAddress = msg.sender;

        emit Offer(msg.sender, uAssetAddress, id, uAssetAmount, collateralAmount, block.timestamp);
    }

    function offerSell(address uAssetAddress, uint256 uAssetAmount, uint256 collateralAmount, bytes memory id) external nonReentrant {
        uint256 royaltyFee = IController(controllerAddress).royaltyFeeRatio();
        
        {
            address collateralAddress = IController(controllerAddress).collateralForToken(uAssetAddress);
            uint256 fee = collateralAmount * royaltyFee / (10 ** royaltyDecimal);

            if(IEURB(collateralAddress).isTransactionExcludedFromFee(msg.sender, address(this))) {
                IEURB(collateralAddress).safeTransferFrom(msg.sender, address(this), fee);
                offerFee[id] = fee;
            } else {
                uint256 totalFee = (collateralAmount * royaltyFee / (10 ** royaltyDecimal)) * 1e5 / (1e5 - IEURB(collateralAddress)._feePercentage());
                IEURB(collateralAddress).safeTransferFrom(msg.sender, address(this), totalFee);
                offerFee[id] = totalFee - totalFee * IEURB(collateralAddress)._feePercentage() / 1e5;
            }
            IEURB(uAssetAddress).safeTransferFrom(msg.sender, address(this), uAssetAmount);
        }
        
        Order storage order = orders[id];
        require(order.offerUAssetAmount == 0, "Still being offered to sell");
        order.offerCollateralAmount = collateralAmount;
        order.offerUAssetAmount = uAssetAmount;
        order.uAssetAddress = uAssetAddress;
        order.userAddress = msg.sender;

        emit Offer(msg.sender, uAssetAddress, id, uAssetAmount, collateralAmount, block.timestamp);
    }
    
    function buy(uint256 deadline, uint256[] memory amountOutMin, bytes[] memory ids) external onlyAdmin {
        for(uint256 i = 0; i < ids.length; i++) {
            buyNow(deadline, amountOutMin[i], ids[i]);
        }

        emit Buy(ids);
    }
    
    function sell(uint256 deadline, uint256[] memory amountOutMin, bytes[] memory ids) external onlyAdmin {
        for(uint256 i = 0; i < ids.length; i++) {
            sellNow(deadline, amountOutMin[i], ids[i]);
        }

        emit Sell(ids);
    }

    function buyNow(uint256 deadline, uint256 amountOutMin, bytes memory id) public nonReentrant onlyAdmin {
        Order storage order = orders[id];
        uint256 collateralAmount = order.offerCollateralAmount;
        address uAssetAddress = order.uAssetAddress;
        address user = order.userAddress;
        uint256 amountOut;
        {
            address collateralAddress = IController(controllerAddress).collateralForToken(uAssetAddress);
            address[] memory path = new address[](2);
            uint256 deadline_ = deadline;
            uint256 amountOutMin_ = amountOutMin;
            {
                address poolAddress = IController(controllerAddress).pools(uAssetAddress);
                address token0 = IUniswapV2Pair(poolAddress).token0();
                address token1 = IUniswapV2Pair(poolAddress).token1();
                
                path[0] = collateralAddress;
                path[1] = token1;
                if (token1 == collateralAddress) {
                    path[1] = token0;
                }
            }
            address routerAddress = IController(controllerAddress).router();
            IEURB(collateralAddress).safeApprove(routerAddress, collateralAmount);

            uint256 balanceBefore = IEURB(path[1]).balanceOf(user);
            IUniswapV2Router02(IController(controllerAddress).router()).swapExactTokensForTokensSupportingFeeOnTransferTokens(collateralAmount, amountOutMin_, path, user, deadline_);
            amountOut = IEURB(path[1]).balanceOf(user) - balanceBefore;
        }
        order.offerCollateralAmount = 0;
        order.offerUAssetAmount = 0;
        amountToClaim += offerFee[id];

        emit Offer(msg.sender, uAssetAddress, id, amountOut, collateralAmount, block.timestamp);
    }

    function sellNow(uint256 deadline, uint256 amountOutMin, bytes memory id) public nonReentrant onlyAdmin {
        Order storage order = orders[id];
        uint256 uAssetAmount = order.offerUAssetAmount;
        address uAssetAddress = order.uAssetAddress;
        address user = order.userAddress;
        uint256 deadline_ = deadline;
        uint256 collateralAmount;
        {
            address[] memory path = new address[](2);
            
            {
                address poolAddress = IController(controllerAddress).pools(uAssetAddress);
                address token0 = IUniswapV2Pair(poolAddress).token0();
                address token1 = IUniswapV2Pair(poolAddress).token1();
                
                path[0] = uAssetAddress;
                path[1] = token1;
                if (token1 == uAssetAddress) {
                    path[1] = token0;
                }
            }
            address routerAddress = IController(controllerAddress).router();
            IEURB(uAssetAddress).safeApprove(routerAddress, uAssetAmount);

            uint256 balanceBefore = IEURB(path[1]).balanceOf(user);
            IUniswapV2Router02(IController(controllerAddress).router()).swapExactTokensForTokensSupportingFeeOnTransferTokens(uAssetAmount, amountOutMin, path, user, deadline_);
            collateralAmount = IEURB(path[1]).balanceOf(user) - balanceBefore;
        }
        order.offerCollateralAmount = 0;
        order.offerUAssetAmount = 0;
        amountToClaim += offerFee[id];

        emit Offer(msg.sender, uAssetAddress, id, uAssetAmount, collateralAmount, block.timestamp);
    }

    function withDrawBuy(bytes memory id) external nonReentrant {
        Order storage order = orders[id];
        uint256 collateralAmount = order.offerCollateralAmount;
        uint256 uAssetAmount = order.offerUAssetAmount;
        address uAssetAddress = order.uAssetAddress;
        address user = order.userAddress;
        
        require(msg.sender == user, "Caller is not the one offered");
        require(collateralAmount > 0 && uAssetAmount > 0, "No offer to be withdrawn");
        
        address collateralAddress = IController(controllerAddress).collateralForToken(uAssetAddress);
        IEURB(collateralAddress).safeTransfer(msg.sender, collateralAmount);
        IEURB(collateralAddress).safeTransfer(msg.sender, offerFee[id]);
        order.offerCollateralAmount = 0;
        order.offerUAssetAmount = 0;

        emit WithDraw(msg.sender, uAssetAddress, id, uAssetAmount, collateralAmount, block.timestamp);
    }

    function withDrawSell(bytes memory id) external nonReentrant {
        Order storage order = orders[id];
        uint256 collateralAmount = order.offerCollateralAmount;
        uint256 uAssetAmount = order.offerUAssetAmount;
        address uAssetAddress = order.uAssetAddress;
        address user = order.userAddress;
        address collateralAddress = IController(controllerAddress).collateralForToken(uAssetAddress);
        
        require(msg.sender == user, "Caller is not the one offered");
        require(collateralAmount > 0 && uAssetAmount > 0, "No offer to be withdrawn");

        IEURB(uAssetAddress).safeTransfer(msg.sender, uAssetAmount);
        IEURB(collateralAddress).safeTransfer(msg.sender, offerFee[id]);
        order.offerCollateralAmount = 0;
        order.offerUAssetAmount = 0;

        emit WithDraw(msg.sender, uAssetAddress, id, uAssetAmount, collateralAmount, block.timestamp);
    }

    function claim(address collateralAddress) external onlyOwner {
        IEURB(collateralAddress).safeTransfer(owner(), amountToClaim);
        amountToClaim = 0;
    }

}

