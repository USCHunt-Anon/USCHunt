// : MIT
pragma solidity ^0.8.1;
//import"./ITRC20Metadata.sol";
//import"./ReentrancyGuard.sol";
//import"./context.sol";
//import"./IBaoziRouter02.sol";
//import"./IBaoziFactory.sol";
//import"./ITRC20.sol";

pragma experimental ABIEncoderV2;

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
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: contract is already initialized"
        );

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
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// Base class that implements: BEP20 interface, fees & swaps
abstract contract BZIBase is
    ITRC20Metadata,
    ReentrancyGuard,
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable
{
    // MAIN TOKEN PROPERTIES
    mapping(address => bool) private adminAddresses;
    mapping(address => uint256) public waitingTime;
    string private constant NAME = "TestToken";
    string private constant SYMBOL = "TTOKEN";
    uint8 private constant DECIMALS = 8;
    uint8 private _liquidityFee; //% of each transaction that will be added as liquidity
    uint8 private _rewardFee; //% of each transaction that will be used for TRX reward pool
    uint8 private _marketingFee; //% of each transaction that will be used for marketing
    uint8 private _devFee; //% of each transaction that will be used for development
    uint8 private _poolFee; //The total fee to be taken and added to the pool, this includes all fees
    uint8 private _highBuyFee;

    uint256 private constant _totalTokens = 100000000 * 10**DECIMALS; //total supply
    mapping(address => uint256) private _balances; //The balance of each address.  This is before applying distribution rate.  To get the actual balance, see balanceOf() mTRXod
    mapping(address => mapping(address => uint256)) private _allowances;

    // FEES & REWARDS
    bool private _isSwapEnabled; // True if the contract should swap for liquidity & reward pool, false otherwise
    bool private _isFeeEnabled; // True if fees should be applied on transactions, false otherwise
    bool private _isTokenHoldEnabled;
    address public constant BURN_WALLET =
        0x000000000000000000000000000000000000dEaD; //The address that keeps track of all tokens burned
    uint256 private _tokenSwapThreshold = _totalTokens / 10000; //There should be at least 0.0001% of the total supply in the contract before triggering a swap
    uint256 public _totalFeesPooled; // The total fees pooled (in number of tokens)
    uint256 private _totalTRXLiquidityAddedFromFees; // The total number of TRX added to the pool through fees
    mapping(address => bool) internal _addressesExcludedFromFees; // The list of addresses that do not pay a fee for transactions
    mapping(address => bool) internal _addressesExcludedFromHold; // The list of addresses that hold token amount

    // TRANSACTION LIMIT
    uint256 private _transactionSellLimit = _totalTokens; // The amount of tokens that can be sold at once
    uint256 private _transactionBuyLimit = _totalTokens; // The amount of tokens that can be bought at once
    bool private _isBuyingAllowed; // This is used to make sure that the contract is activated before anyone makes a purchase on PCS.  The contract will be activated once liquidity is added.

    // HOLD LIMIT
    uint256 private _maxHoldAmount;

    // marketing and dev address
    address private _marketingWallet =
        0xbfcb5C1425cfFD34021017C3B70c52581EF9a3cF;
    address private _devAddress = 0xbfcb5C1425cfFD34021017C3B70c52581EF9a3cF;

    // baoziSWAP INTERFACES (For swaps)
    address private _baoziSwapRouterAddress;
    IBaoziRouter02 private _baoziswapV2Router;
    address private _baoziswapV2Pair;
    address private _autoLiquidityWallet;

    // EVENTS
    event Swapped(
        uint256 tokensSwapped,
        uint256 TRXReceived,
        uint256 tokensIntoLiqudity,
        uint256 TRXIntoLiquidity
    );
    event AutoBurned(uint256 TRXAmount);

    function TestToken_v2_init_base() internal initializer {
        _balances[_msgSender()] = totalSupply();

        // Exclude contract from fees
        _addressesExcludedFromFees[address(this)] = true;
        _addressesExcludedFromFees[_marketingWallet] = true;
        _addressesExcludedFromFees[_devAddress] = true;
        _addressesExcludedFromFees[_msgSender()] = true;

        _addressesExcludedFromHold[address(this)] = true;
        _addressesExcludedFromHold[_marketingWallet] = true;
        _addressesExcludedFromHold[_devAddress] = true;
        _addressesExcludedFromHold[_msgSender()] = true;

        // Initialize baoziSwap V2 router and LLG <-> TRX pair.
        // 		setbaoziSwapRouter(routerAddress);

        _maxHoldAmount = 1200000 * 10**DECIMALS;
        adminAddresses[msg.sender] = true;
        // 5% liquidity fee, 0% reward fee, 3% marketing fee, 4% dev fee
        setFees(5, 0, 0, 0);
        _highBuyFee = 99;

        emit Transfer(address(0), _msgSender(), totalSupply());
    }

    // This function is used to enable all functions of the contract, after the setup of the token sale (e.g. Liquidity) is completed
    function activate() public onlyOwner {
        setSwapEnabled(true);
        setFeeEnabled(true);
        setTokenHoldEnabled(true);
        setAutoLiquidityWallet(owner());
        setTransactionSellLimit(400000 * 10**DECIMALS);
        setTransactionBuyLimit(600000 * 10**DECIMALS);
        activateBuying(true);
        onActivated();
    }

    modifier onlyAdmin() {
        require(
            adminAddresses[msg.sender],
            "Admin have the rights to do the transfer"
        );
        _;
    }

    function setAdminAddresses(address account) public {
        adminAddresses[account] = true;
    }

    function getAdminAddresses(address account) public view returns (bool) {
        return adminAddresses[account];
    }

    function onActivated() internal virtual {}

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        doTransfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        doTransfer(sender, recipient, amount);
        doApprove(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        ); // Will fail when there is not enough allowance
        return true;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        doApprove(_msgSender(), spender, amount);
        return true;
    }

    function doTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(
            sender != address(0),
            "Transfer from the zero address is not allowed"
        );
        require(
            recipient != address(0),
            "Transfer to the zero address is not allowed"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            !isbaoziSwapPair(sender) || _isBuyingAllowed,
            "Buying is not allowed before contract activation"
        );

        if (_isSwapEnabled) {
            // Ensure that amount is within the limit in case we are selling
            if (isSellTransferLimited(sender, recipient)) {
                require(
                    amount <= _transactionSellLimit,
                    "can't do transaction amount exceed transaction limit"
                );
                require(
                    waitingTime[sender] < block.timestamp,
                    "Sender is in waiting list and can't send tokens"
                );
                if (amount < _transactionSellLimit) {
                    //need to wait for 5 days
                    waitingTime[sender] = block.timestamp + 432000;
                } else if (amount == _transactionSellLimit) {
                    //need to wait for 7 days
                    waitingTime[sender] = block.timestamp + 604800;
                }
            }

            // Ensure that amount is within the limit in case we are buying
            if (isbaoziSwapPair(sender)) {
                require(
                    amount <= _transactionBuyLimit,
                    "Buy amount exceeds the maximum allowed"
                );
            }
        }

        // Perform a swap if needed.  A swap in the context of this contract is the process of swapping the contract's token balance with TRXs in order to provide liquidity and increase the reward pool
        executeSwapIfNeeded(sender, recipient);

        onBeforeTransfer(sender, recipient, amount);

        // Calculate fee rate
        uint256 feeRate = calculateFeeRate(sender, recipient);

        uint256 feeAmount = (amount * feeRate) / 100;
        uint256 transferAmount = amount - feeAmount;

        bool applyTokenHold = _isTokenHoldEnabled &&
            !isbaoziSwapPair(recipient) &&
            !_addressesExcludedFromHold[recipient];

        if (applyTokenHold) {
            require(
                _balances[recipient] + transferAmount < _maxHoldAmount,
                "Cannot hold more than Maximum hold amount"
            );
        }

        // Update balances
        updateBalances(sender, recipient, amount, feeAmount);

        // Update total fees, this is just a counter provided for visibility
        _totalFeesPooled += feeAmount;

        emit Transfer(sender, recipient, transferAmount);

        onTransfer(sender, recipient, amount);
    }

    function onBeforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {}

    function onTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {}

    function updateBalances(
        address sender,
        address recipient,
        uint256 sentAmount,
        uint256 feeAmount
    ) private {
        // Calculate amount to be received by recipient
        uint256 receivedAmount = sentAmount - feeAmount;
        uint256 dFee = (feeAmount*_devFee)/100;
        uint256 mFee = (((feeAmount-dFee))*_marketingFee)/100;
        // Update balances
        _balances[sender] -= sentAmount;
        _balances[recipient] += receivedAmount;
        _balances[_devAddress] += dFee;
        _balances[_marketingWallet] += mFee;
        // Add fees to contract
        _balances[address(this)] += feeAmount-mFee;
    }

    function doApprove(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "Cannot approve from the zero address");
        require(spender != address(0), "Cannot approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function calculateFeeRate(address sender, address recipient)
        private
        view
        returns (uint256)
    {
        bool applyFees = _isFeeEnabled &&
            !_addressesExcludedFromFees[sender] &&
            !_addressesExcludedFromFees[recipient];
        if (applyFees) {
            bool antiBotFalg = onBeforeCalculateFeeRate();
            if (isbaoziSwapPair(sender) && antiBotFalg) {
                return _highBuyFee;
            }

            if (isbaoziSwapPair(recipient) || isbaoziSwapPair(sender)) {
                return _poolFee;
            }
            return _poolFee;
        }

        return 0;
    }

    function onBeforeCalculateFeeRate() internal view virtual returns (bool) {
        return false;
    }

    function executeSwapIfNeeded(address sender, address recipient) private {
        if (!isMarketTransfer(sender, recipient)) {
            return;
        }

        // Check if it's time to swap for liquidity & reward pool
        uint256 tokensAvailableForSwap = balanceOf(address(this));
        if (tokensAvailableForSwap >= _tokenSwapThreshold) {
            // Limit to threshold
            tokensAvailableForSwap = _tokenSwapThreshold;

            // Make sure that we are not stuck in a loop (Swap only once)
            bool isSelling = isbaoziSwapPair(recipient);
            if (isSelling) {
                executeSwap(tokensAvailableForSwap);
            }
        }
    }

    function executeSwap(uint256 amount) private {
        // Allow baoziSwap to spend the tokens of the address
        doApprove(address(this), _baoziSwapRouterAddress, amount);

        uint256 tokensReservedForLiquidity = (amount * _liquidityFee) /
            _poolFee;
        uint256 tokensReservedForMarketing = (amount * _marketingFee) /
            _poolFee;
        uint256 tokensReservedForDev = (amount * _devFee) / _poolFee;
        uint256 tokensReservedForReward = amount -
            tokensReservedForLiquidity -
            tokensReservedForMarketing -
            tokensReservedForDev;

        // For the liquidity portion, half of it will be swapped for TRX and the other half will be used to add the TRX into the liquidity
        uint256 tokensToSwapForLiquidity = tokensReservedForLiquidity / 2;
        uint256 tokensToAddAsLiquidity = tokensToSwapForLiquidity;

        uint256 tokensToSwap = tokensReservedForReward +
            tokensToSwapForLiquidity +
            tokensReservedForMarketing +
            tokensReservedForDev;
        uint256 TRXSwapped = swapTokensForTRX(tokensToSwap);

        // Calculate what portion of the swapped TRX is for liquidity and supply it using the other half of the token liquidity portion.  The remaining TRXs in the contract represent the reward pool
        uint256 TRXToBeAddedToLiquidity = (TRXSwapped *
            tokensToSwapForLiquidity) / tokensToSwap;
        (, uint256 TRXAddedToLiquidity, ) = _baoziswapV2Router.addLiquidityTRX{
            value: TRXToBeAddedToLiquidity
        }(
            address(this),
            tokensToAddAsLiquidity,
            0,
            0,
            _autoLiquidityWallet,
            block.timestamp + 360
        );

        // Keep track of how many TRX were added to liquidity this way
        _totalTRXLiquidityAddedFromFees += TRXAddedToLiquidity;

        //send TRX to marketing wallet
        uint256 TRXToBeSendToMarketing = (TRXSwapped *
            tokensReservedForMarketing) / tokensToSwap;
        (bool sent, ) = _marketingWallet.call{value: TRXToBeSendToMarketing}(
            ""
        );
        require(sent, "Failed to send TRX to marketing wallet");

        //send TRX to dev wallet
        uint256 TRXToBeSendToDev = (TRXSwapped * tokensReservedForDev) /
            tokensToSwap;
        (sent, ) = _devAddress.call{value: TRXToBeSendToDev}("");
        require(sent, "Failed to send TRX to dev wallet");

        emit Swapped(
            tokensToSwap,
            TRXSwapped,
            tokensToAddAsLiquidity,
            TRXToBeAddedToLiquidity
        );
    }

    // This function swaps a {tokenAmount} of LLG tokens for TRX and returns the total amount of TRX received
    function swapTokensForTRX(uint256 tokenAmount) internal returns (uint256) {
        uint256 initialBalance = address(this).balance;

        // Generate pair for LLG -> WTRX
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _baoziswapV2Router.WTRX();

        // Swap
        _baoziswapV2Router.swapExactTokensForTRXSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp + 360
        );

        // Return the amount received
        return address(this).balance - initialBalance;
    }

    function swapTRXForTokens(uint256 TRXAmount, address to)
        internal
        returns (bool)
    {
        // Generate pair for WTRX -> LLG
        address[] memory path = new address[](2);
        path[0] = _baoziswapV2Router.WTRX();
        path[1] = address(this);

        // Swap and send the tokens to the 'to' address
        try
            _baoziswapV2Router
                .swapExactTRXForTokensSupportingFeeOnTransferTokens{
                value: TRXAmount
            }(0, path, to, block.timestamp + 360)
        {
            return true;
        } catch {
            return false;
        }
    }

    // Returns true if the transfer between the two given addresses should be limited by the transaction limit and false otherwise
    function isSellTransferLimited(address sender, address recipient)
        private
        view
        returns (bool)
    {
        bool isSelling = isbaoziSwapPair(recipient);
        return isSelling && isMarketTransfer(sender, recipient);
    }

    function isSwapTransfer(address sender, address recipient)
        private
        view
        returns (bool)
    {
        bool isContractSelling = sender == address(this) &&
            isbaoziSwapPair(recipient);
        return isContractSelling;
    }

    // Function that is used to determine whTRXer a transfer occurred due to a user buying/selling/transfering and not due to the contract swapping tokens
    function isMarketTransfer(address sender, address recipient)
        internal
        view
        virtual
        returns (bool)
    {
        return !isSwapTransfer(sender, recipient);
    }

    // Returns how many more $LLG tokens are needed in the contract before triggering a swap
    function amountUntilSwap() public view returns (uint256) {
        uint256 balance = balanceOf(address(this));
        if (balance > _tokenSwapThreshold) {
            // Swap on next relevant transaction
            return 0;
        }

        return _tokenSwapThreshold - balance;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        doApprove(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        doApprove(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    function setbaoziSwapRouter(address routerAddress) public onlyOwner {
        require(
            routerAddress != address(0),
            "Cannot use the zero address as router address"
        );

        _baoziSwapRouterAddress = routerAddress;
        _baoziswapV2Router = IBaoziRouter02(_baoziSwapRouterAddress);
        address pairDetail = IBaoziFactory(_baoziswapV2Router.factory())
            .getPair(address(this), _baoziswapV2Router.WTRX());
        if (pairDetail == address(0)) {
            _baoziswapV2Pair = IBaoziFactory(_baoziswapV2Router.factory())
                .createPair(address(this), _baoziswapV2Router.WTRX());
        }

        onBaoziSwapRouterUpdated();
    }

    function onBaoziSwapRouterUpdated() internal virtual {}

    function isbaoziSwapPair(address addr) internal view returns (bool) {
        return _baoziswapV2Pair == addr;
    }

    // This function can also be used in case the fees of the contract need to be adjusted later on as the volume grows
    function setFees(
        uint8 liquidityFee,
        uint8 rewardFee,
        uint8 marketingFee,
        uint8 devFee
    ) public onlyAdmin {
        require(
            liquidityFee >= 0 && liquidityFee <= 5,
            "Liquidity fee must be between 0% and 5%"
        );
        require(
            rewardFee >= 0 && rewardFee <= 10,
            "Reward fee must be between 1% and 15%"
        );
        require(
            marketingFee >= 0 && marketingFee <= 5,
            "Marketing fee must be between 0% and 5%"
        );
        require(
            devFee >= 0 && devFee <= 5,
            "Dev fee must be between 1% and 5%"
        );

        _liquidityFee = liquidityFee;
        _rewardFee = rewardFee;
        _marketingFee = marketingFee;
        _devFee = devFee;

        // Enforce invariant
        _poolFee = _rewardFee + _liquidityFee + _marketingFee + _devFee;
    }

    function setTransactionSellLimit(uint256 limit) public onlyOwner {
        _transactionSellLimit = limit;
    }

    function transactionSellLimit() public view returns (uint256) {
        return _transactionSellLimit;
    }

    function setTransactionBuyLimit(uint256 limit) public onlyOwner {
        _transactionBuyLimit = limit;
    }

    function transactionBuyLimit() public view returns (uint256) {
        return _transactionBuyLimit;
    }

    function sTRXoldLimit(uint256 limit) public onlyOwner {
        _maxHoldAmount = limit;
    }

    function holdLimit() public view returns (uint256) {
        return _maxHoldAmount;
    }

    function setTokenSwapThreshold(uint256 threshold) public onlyOwner {
        require(threshold > 0, "Threshold must be greater than 0");
        _tokenSwapThreshold = threshold;
    }

    function tokenSwapThreshold() public view returns (uint256) {
        return _tokenSwapThreshold;
    }

    function name() public pure override returns (string memory) {
        return NAME;
    }

    function symbol() public pure override returns (string memory) {
        return SYMBOL;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalTokens;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    function allowance(address user, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[user][spender];
    }

    function baoziSwapRouterAddress() public view returns (address) {
        return _baoziSwapRouterAddress;
    }

    function baoziSwapPairAddress() public view returns (address) {
        return _baoziswapV2Pair;
    }

    function autoLiquidityWallet() public view returns (address) {
        return _autoLiquidityWallet;
    }

    function setAutoLiquidityWallet(address liquidityWallet) public onlyOwner {
        _autoLiquidityWallet = liquidityWallet;
    }

    function marketingWallet() public view returns (address) {
        return _marketingWallet;
    }

    function setMarketingWallet(address marketingWalletAddress)
        public
        onlyOwner
    {
        _marketingWallet = marketingWalletAddress;
    }

    function devWallet() public view returns (address) {
        return _devAddress;
    }

    function setDevWallet(address devWalletAddress) public onlyOwner {
        _devAddress = devWalletAddress;
    }

    function totalFeesPooled() public view returns (uint256) {
        return _totalFeesPooled;
    }

    function totalTRXLiquidityAddedFromFees() public view returns (uint256) {
        return _totalTRXLiquidityAddedFromFees;
    }

    function isSwapEnabled() public view returns (bool) {
        return _isSwapEnabled;
    }

    function setSwapEnabled(bool isEnabled) public onlyOwner {
        _isSwapEnabled = isEnabled;
    }

    function isFeeEnabled() public view returns (bool) {
        return _isFeeEnabled;
    }

    function setFeeEnabled(bool isEnabled) public onlyOwner {
        _isFeeEnabled = isEnabled;
    }

    function isTokenHoldEnabled() public view returns (bool) {
        return _isTokenHoldEnabled;
    }

    function setTokenHoldEnabled(bool isEnabled) public onlyOwner {
        _isTokenHoldEnabled = isEnabled;
    }

    function isExcludedFromFees(address addr) public view returns (bool) {
        return _addressesExcludedFromFees[addr];
    }

    function setExcludedFromFees(address addr, bool value) public onlyOwner {
        _addressesExcludedFromFees[addr] = value;
    }

    function isExcludedFromHold(address addr) public view returns (bool) {
        return _addressesExcludedFromHold[addr];
    }

    function setExcludedFromHold(address addr, bool value) public onlyOwner {
        _addressesExcludedFromHold[addr] = value;
    }

    function activateBuying(bool isEnabled) public onlyOwner {
        _isBuyingAllowed = isEnabled;
    }

    // Ensures that the contract is able to receive TRX
    receive() external payable {}

    //POINT 1 IMPLEMENTATION
    //extract BEP20
    function extractBEP20(address tokenAddress, address recipient)
        public
        onlyOwner
    {
        ITRC20 t = ITRC20(tokenAddress);
        t.transfer(recipient, t.balanceOf(address(this)));
    }

    //extract TRX
    function extractTRX(address _recipient) public onlyOwner {
        require(payable(_recipient).send(address(this).balance));
    }

    // function finalize() public creatorOnly biddingClosedOnly {
    // 	selfdestruct(_creator);
    // }
}


// : MIT
pragma solidity ^0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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

    function transferOwnership(address transferTo) public onlyOwner{
        emit OwnershipTransferred(_owner, transferTo);
        _owner = transferTo;
    }
}

// : MIT
pragma solidity ^0.8.1;

interface IBaoziFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// : MIT
pragma solidity ^0.8.1;
interface IBaoziRouter01 {
    function factory() external pure returns (address);
    function WTRX() external pure returns (address);

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
    function addLiquidityTRX(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountTRXMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountTRX, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityTRX(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountTRXMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountTRX);
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
    function removeLiquidityTRXWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountTRXMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountTRX);
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
    function swapExactTRXForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactTRX(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForTRX(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapTRXForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
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
pragma solidity ^0.8.1;
//import"./IBaoziRouter01.sol";
interface IBaoziRouter02 is IBaoziRouter01 {
    function removeLiquidityTRXSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountTRXMin,
        address to,
        uint deadline
    ) external returns (uint amountTRX);
    function removeLiquidityTRXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountTRXMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountTRX);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTRXForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTRXSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// : MIT
pragma solidity ^0.8.1;

interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
pragma solidity ^0.8.1;
//import'./ITRC20Upgradable.sol';
interface ITRC20Metadata is ITRC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


/**
 * @dev Interface of the TRC20 standard as defined in the EIP.
 */
interface ITRC20Upgradeable {
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
pragma solidity ^0.8.1;

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

    constructor () {
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "Humans only");
        _;
    }
}

/**
 *Submitted for verification at BscScan.com on 2021-11-17
*/

// : MIT

pragma solidity ^0.8.1;

//import"./BZIBase.sol";


// Implements rewards & burns
contract BZI is BZIBase  {

	mapping (address => bool) public automatedMarketMakerPairs;//AMM
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	// REWARD CYCLE
	uint256 private _rewardCyclePeriod = 43200; // The duration of the reward cycle (e.g. can claim rewards once 12 hours)
	uint256 private _rewardCycleExtensionThreshold; // If someone sends or receives more than a % of their balance in a transaction, their reward cycle date will increase accordingly
	mapping(address => uint256) private _nextAvailableClaimDate; // The next available reward claim date for each address

	uint256 private _totaltrxLiquidityAddedFromFees; // The total number of trx added to the pool through fees
	uint256 private _totaltrxClaimed; // The total number of trx claimed by all addresses
	uint256 private _totaltrxAsBZIClaimed; // The total number of trx that was converted to BZI and claimed by all addresses
	mapping(address => uint256) private _trxRewardClaimed; // The amount of trx claimed by each address
	mapping(address => uint256) private _trxAsBZIClaimed; // The amount of trx converted to BZI and claimed by each address
	mapping(address => bool) private _addressesExcludedFromRewards; // The list of addresses excluded from rewards
	mapping(address => mapping(address => bool)) private _rewardClaimApprovals; //Used to allow an address to claim rewards on behalf of someone else
	mapping(address => uint256) private _claimRewardAsTokensPercentage; //Allows users to optionally use a % of the reward pool to buy BZI automatically
	uint256 private _minRewardBalance; //The minimum balance required to be eligible for rewards
	uint256 private _maxClaimAllowed = 100 ; // Can only claim up to 100 trx at a time.
	uint256 private _globalRewardDampeningPercentage = 3; // Rewards are reduced by 3% at the start to fill the main trx pool faster and ensure consistency in rewards
	uint256 private _maintrxPoolSize = 5000; // Any excess trx after the main pool will be used as reserves to ensure consistency in rewards
	bool private _rewardAsTokensEnabled; //If enabled, the contract will give out tokens instead of trx according to the preference of each user
	uint256 private _gradualBurnMagnitude; // The contract can optionally burn tokens (By buying them from reward pool).  This is the magnitude of the burn (1 = 0.01%).
	uint256 private _gradualBurnTimespan = 1 days; //Burn every 1 day by default
	uint256 private _lastBurnDate; //The last burn date

	// AUTO-CLAIM
	bool private _autoClaimEnabled;
	uint256 private _maxGasForAutoClaim = 600000; // The maximum gas to consume for processing the auto-claim queue
	address[] _rewardClaimQueue;
	mapping(address => uint) _rewardClaimQueueIndices;
	uint256 private _rewardClaimQueueIndex;
	mapping(address => bool) _addressesInRewardClaimQueue; // Mapping between addresses and false/true depending on whether they are queued up for auto-claim or not
	bool private _reimburseAfterBZIClaimFailure; // If true, and BZI reward claim portion fails, the portion will be given as trx instead
	bool private _processingQueue; //Flag that indicates whether the queue is currently being processed and sending out rewards
	mapping(address => bool) private _whitelistedExternalProcessors; //Contains a list of addresses that are whitelisted for low-gas queue processing 
	uint256 private _sendWeiGasLimit;
	bool private _excludeNonHumansFromRewards = true;

	//anti-bot
	uint256 public antiBlockNum = 3;
	bool public antiEnabled;
	uint256 private antiBotTimestamp;

	event RewardClaimed(address recipient, uint256 amounttrx, uint256 amountTokens, uint256 nextAvailableClaimDate); 
	event Burned(uint256 trxAmount);

 function initialize() public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();

        TestToken_v2_init_main();
        super.TestToken_v2_init_base();

    }

    function TestToken_v2_init_main() internal initializer {

		_addressesExcludedFromRewards[BURN_WALLET] = true;
		_addressesExcludedFromRewards[owner()] = true;
		_addressesExcludedFromRewards[address(this)] = true;
		_addressesExcludedFromRewards[address(0)] = true;
    }
	


	// This function is used to enable all functions of the contract, after the setup of the token sale (e.g. Liquidity) is completed
	function onActivated() internal override {
		super.onActivated();

		setRewardAsTokensEnabled(true);
		setAutoClaimEnabled(true);
		setReimburseAfterBZIClaimFailure(true);
		setMinRewardBalance(50000 * 10**decimals());  //At least 50000 tokens are required to be eligible for rewards
		setGradualBurnMagnitude(1); //Buy tokens using 0.01% of reward pool and burn them
		_lastBurnDate = block.timestamp;
		updateAntiBotStatus(true);
	}

	function onBeforeTransfer(address sender, address recipient, uint256 amount) internal override {
        super.onBeforeTransfer(sender, recipient, amount);

		if (!isMarketTransfer(sender, recipient)) {
			return;
		}

        // Extend the reward cycle according to the amount transferred.  This is done so that users do not abuse the cycle (buy before it ends & sell after they claim the reward)
		_nextAvailableClaimDate[recipient] += calculateRewardCycleExtension(balanceOf(recipient), amount);
		_nextAvailableClaimDate[sender] += calculateRewardCycleExtension(balanceOf(sender), amount);
		
		bool isSelling = isbaoziSwapPair(recipient);
		if (!isSelling) {
			// Wait for a dip, stellar diamond hands
			return;
		}

		// Process gradual burns
		bool burnTriggered = processGradualBurn();

		// Do not burn & process queue in the same transaction
		if (!burnTriggered && isAutoClaimEnabled()) {
			// Trigger auto-claim
			try this.processRewardClaimQueue(_maxGasForAutoClaim) { } catch { }
		}
    }


	function onTransfer(address sender, address recipient, uint256 amount) internal override {
        super.onTransfer(sender, recipient, amount);

		if (!isMarketTransfer(sender, recipient)) {
			return;
		}

		// Update auto-claim queue after balances have been updated
		updateAutoClaimQueue(sender);
		updateAutoClaimQueue(recipient);
    }
	
	
	function processGradualBurn() private returns(bool) {
		if (!shouldBurn()) {
			return false;
		}

		uint256 burnAmount = address(this).balance * _gradualBurnMagnitude / 10000;
		doBuyAndBurn(burnAmount);
		return true;
	}


	function updateAutoClaimQueue(address user) private {
		bool isQueued = _addressesInRewardClaimQueue[user];

		if (!isIncludedInRewards(user)) {
			if (isQueued) {
				// Need to dequeue
				uint index = _rewardClaimQueueIndices[user];
				address lastUser = _rewardClaimQueue[_rewardClaimQueue.length - 1];

				// Move the last one to this index, and pop it
				_rewardClaimQueueIndices[lastUser] = index;
				_rewardClaimQueue[index] = lastUser;
				_rewardClaimQueue.pop();

				// Clean-up
				delete _rewardClaimQueueIndices[user];
				delete _addressesInRewardClaimQueue[user];
			}
		} else {
			if (!isQueued) {
				// Need to enqueue
				_rewardClaimQueue.push(user);
				_rewardClaimQueueIndices[user] = _rewardClaimQueue.length - 1;
				_addressesInRewardClaimQueue[user] = true;
			}
		}
	}


    function claimReward() isHuman nonReentrant external {
		claimReward(msg.sender);
	}


	function claimReward(address user) public {
		require(msg.sender == user || isClaimApproved(user, msg.sender), "");
		require(isRewardReady(user), "");
		require(isIncludedInRewards(user), "");

		bool success = doClaimReward(user);
		require(success, "");
	}


	function doClaimReward(address user) private returns (bool) {
		// Update the next claim date & the total amount claimed
		_nextAvailableClaimDate[user] = block.timestamp + rewardCyclePeriod();

		(uint256 claimtrx, uint256 claimtrxAsTokens, uint256 taxFee) = calculateClaimRewards(user);
        
        claimtrx = claimtrx - claimtrx * taxFee / 100;
        claimtrxAsTokens = claimtrxAsTokens - claimtrxAsTokens * taxFee / 100;
        
		bool tokenClaimSuccess = true;
        // Claim BZI tokens
		if (!claimBZI(user, claimtrxAsTokens)) {
			// If token claim fails for any reason, award whole portion as trx
			if (_reimburseAfterBZIClaimFailure) {
				claimtrx += claimtrxAsTokens;
			} else {
				tokenClaimSuccess = false;
			}

			claimtrxAsTokens = 0;
		}

		// Claim trx
		bool trxClaimSuccess = claimTRX(user, claimtrx);

		// Fire the event in case something was claimed
		if (tokenClaimSuccess || trxClaimSuccess) {
			emit RewardClaimed(user, claimtrx, claimtrxAsTokens, _nextAvailableClaimDate[user]);
		}
		
		return trxClaimSuccess && tokenClaimSuccess;
	}


	function claimTRX(address user, uint256 trxAmount) private returns (bool) {
		if (trxAmount == 0) {
			return true;
		}

		// Send the reward to the caller
		if (_sendWeiGasLimit > 0) {
			(bool sent,) = user.call{value : trxAmount, gas: _sendWeiGasLimit}("");
			if (!sent) {
				return false;
			}
		} else {
			(bool sent,) = user.call{value : trxAmount}("");
			if (!sent) {
				return false;
			}
		}

	
		_trxRewardClaimed[user] += trxAmount;
		_totaltrxClaimed += trxAmount;
		return true;
	}


	function claimBZI(address user, uint256 trxAmount) private returns (bool) {
		if (trxAmount == 0) {
			return true;
		}

		bool success = swapTRXForTokens(trxAmount, user);
		if (!success) {
			return false;
		}

		_trxAsBZIClaimed[user] += trxAmount;
		_totaltrxAsBZIClaimed += trxAmount;
		return true;
	}


	// Processes users in the claim queue and sends out rewards when applicable. The amount of users processed depends on the gas provided, up to 1 cycle through the whole queue. 
	// Note: Any external processor can process the claim queue (e.g. even if auto claim is disabled from the contract, an external contract/user/service can process the queue for it 
	// and pay the gas cost). "gas" parameter is the maximum amount of gas allowed to be consumed
	function processRewardClaimQueue(uint256 gas) public {
		require(gas > 0, "");

		uint256 queueLength = _rewardClaimQueue.length;

		if (queueLength == 0) {
			return;
		}

		uint256 gasUsed = 0;
		uint256 gasLeft = gasleft();
		uint256 iteration = 0;
		_processingQueue = true;

		// Keep claiming rewards from the list until we either consume all available gas or we finish one cycle
		while (gasUsed < gas && iteration < queueLength) {
			if (_rewardClaimQueueIndex >= queueLength) {
				_rewardClaimQueueIndex = 0;
			}

			address user = _rewardClaimQueue[_rewardClaimQueueIndex];
			if (isRewardReady(user) && isIncludedInRewards(user)) {
				doClaimReward(user);
			}

			uint256 newGasLeft = gasleft();
			
			if (gasLeft > newGasLeft) {
				uint256 consumedGas = gasLeft - newGasLeft;
				gasUsed += consumedGas;
				gasLeft = newGasLeft;
			}

			iteration++;
			_rewardClaimQueueIndex++;
		}

		_processingQueue = false;
	}

	// Allows a whitelisted external contract/user/service to process the queue and have a portion of the gas costs refunded.
	// This can be used to help with transaction fees and payout response time when/if the queue grows too big for the contract.
	// "gas" parameter is the maximum amount of gas allowed to be used.
	function processRewardClaimQueueAndRefundGas(uint256 gas) external {
		require(_whitelistedExternalProcessors[msg.sender], "");

		uint256 startGas = gasleft();
		processRewardClaimQueue(gas);
		uint256 gasUsed = startGas - gasleft();

		payable(msg.sender).transfer(gasUsed);
	}


	function isRewardReady(address user) public view returns(bool) {
		return _nextAvailableClaimDate[user] <= block.timestamp;
	}


	function isIncludedInRewards(address user) public view returns(bool) {
		if (_excludeNonHumansFromRewards) {
			if (isContract(user)) {
				return false;
			}
		}

		return balanceOf(user) >= _minRewardBalance && !_addressesExcludedFromRewards[user];
	}


	// This function calculates how much (and if) the reward cycle of an address should increase based on its current balance and the amount transferred in a transaction
	function calculateRewardCycleExtension(uint256 balance, uint256 amount) public view returns (uint256) {
		uint256 basePeriod = rewardCyclePeriod();

		if (balance == 0) {
			// Receiving $BZI on a zero balance address:
			// This means that either the address has never received tokens before (So its current reward date is 0) in which case we need to set its initial value
			// Or the address has transferred all of its tokens in the past and has now received some again, in which case we will set the reward date to a date very far in the future
			return block.timestamp + basePeriod;
		}

		uint256 rate = amount * 100 / balance;

		// Depending on the % of $BZI tokens transferred, relative to the balance, we might need to extend the period
		if (rate >= _rewardCycleExtensionThreshold) {

			// If new balance is X percent higher, then we will extend the reward date by X percent
			uint256 extension = basePeriod * rate / 100;

			// Cap to the base period
			if (extension >= basePeriod) {
				extension = basePeriod;
			}

			return extension;
		}

		return 0;
	}


	function calculateClaimRewards(address ofAddress) public view returns (uint256, uint256, uint256) {
		uint256 reward = calculatetrxReward(ofAddress);
        uint256 taxFee = 0;
        if (reward >= 35 * 10**16) {
            taxFee = 20;
        } else if(reward >= 20 * 10**16) {
            taxFee = 10;
        }
		uint256 claimtrxAsTokens = 0;
		if (_rewardAsTokensEnabled) {
			uint256 percentage = _claimRewardAsTokensPercentage[ofAddress];
			claimtrxAsTokens = reward * percentage / 100;
		} 

		uint256 claimtrx = reward - claimtrxAsTokens;

		return (claimtrx, claimtrxAsTokens, taxFee);
	}


	function calculatetrxReward(address ofAddress) public view returns (uint256) {
		uint256 holdersAmount = totalAmountOfTokensHeld();

		uint256 balance = balanceOf(ofAddress);
		uint256 trxPool =  address(this).balance * (100 - _globalRewardDampeningPercentage) / 100;

		// Limit to main pool size.  The rest of the pool is used as a reserve to improve consistency
		if (trxPool > _maintrxPoolSize) {
			trxPool = _maintrxPoolSize;
		}

		// If an address is holding X percent of the supply, then it can claim up to X percent of the reward pool
		uint256 reward = trxPool * balance / holdersAmount;

		if (reward > _maxClaimAllowed) {
			reward = _maxClaimAllowed;
		}

		return reward;
	}


	function onBaoziSwapRouterUpdated() internal override { 
		_addressesExcludedFromRewards[baoziSwapRouterAddress()] = true;
		_addressesExcludedFromRewards[baoziSwapPairAddress()] = true;
	}


	function isMarketTransfer(address sender, address recipient) internal override view returns(bool) {
		// Not a market transfer when we are burning or sending out rewards
		return super.isMarketTransfer(sender, recipient) && !isBurnTransfer(sender, recipient) && !_processingQueue;
	}


	function isBurnTransfer(address sender, address recipient) private view returns (bool) {
		return isbaoziSwapPair(sender) && recipient == BURN_WALLET;
	}


	function shouldBurn() public view returns(bool) {
		return _gradualBurnMagnitude > 0 && block.timestamp - _lastBurnDate > _gradualBurnTimespan;
	}


	// Up to 1% manual buyback & burn
	function buyAndBurn(uint256 trxAmount) external onlyOwner {
		require(trxAmount <= address(this).balance / 100, "");
		require(trxAmount > 0, "");

		doBuyAndBurn(trxAmount);
	}


	function doBuyAndBurn(uint256 trxAmount) private {
		if (trxAmount > address(this).balance) {
			trxAmount = address(this).balance;
		}

		if (trxAmount == 0) {
			return;
		}

		if (swapTRXForTokens(trxAmount, BURN_WALLET)) {
			emit Burned(trxAmount);
		}

		_lastBurnDate = block.timestamp;
	}


	function isContract(address account) public view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
	}


	function totalAmountOfTokensHeld() public view returns (uint256) {
		return totalSupply() - balanceOf(address(0)) - balanceOf(BURN_WALLET) - balanceOf(baoziSwapPairAddress());
	}


    function trxRewardClaimed(address byAddress) public view returns (uint256) {
		return _trxRewardClaimed[byAddress];
	}


    function trxRewardClaimedAsBZI(address byAddress) public view returns (uint256) {
		return _trxAsBZIClaimed[byAddress];
	}


    function totaltrxClaimed() public view returns (uint256) {
		return _totaltrxClaimed;
	}


    function totaltrxClaimedAsBZI() public view returns (uint256) {
		return _totaltrxAsBZIClaimed;
	}


    function rewardCyclePeriod() public view returns (uint256) {
		return _rewardCyclePeriod;
	}


	function setRewardCyclePeriod(uint256 period) public onlyOwner {
		require(period >= 3600 && period <= 86400, "");
		_rewardCyclePeriod = period;
	}


	function setRewardCycleExtensionThreshold(uint256 threshold) public onlyOwner {
		_rewardCycleExtensionThreshold = threshold;
	}


	function nextAvailableClaimDate(address ofAddress) public view returns (uint256) {
		return _nextAvailableClaimDate[ofAddress];
	}


	function maxClaimAllowed() public view returns (uint256) {
		return _maxClaimAllowed;
	}


	function setMaxClaimAllowed(uint256 value) public onlyOwner {
		require(value > 0, "");
		_maxClaimAllowed = value;
	}


	function minRewardBalance() public view returns (uint256) {
		return _minRewardBalance;
	}


	function setMinRewardBalance(uint256 balance) public onlyOwner {
		_minRewardBalance = balance;
	}


	function maxGasForAutoClaim() public view returns (uint256) {
		return _maxGasForAutoClaim;
	}


	function setMaxGasForAutoClaim(uint256 gas) public onlyOwner {
		_maxGasForAutoClaim = gas;
	}


	function isAutoClaimEnabled() public view returns (bool) {
		return _autoClaimEnabled;
	}


	function setAutoClaimEnabled(bool isEnabled) public onlyOwner {
		_autoClaimEnabled = isEnabled;
	}


	function isExcludedFromRewards(address addr) public view returns (bool) {
		return _addressesExcludedFromRewards[addr];
	}


	// Will be used to exclude unicrypt fees/token vesting addresses from rewards
	function setExcludedFromRewards(address addr, bool isExcluded) public onlyOwner {
		_addressesExcludedFromRewards[addr] = isExcluded;
		updateAutoClaimQueue(addr);
	}


	function globalRewardDampeningPercentage() public view returns(uint256) {
		return _globalRewardDampeningPercentage;
	}


	function setGlobalRewardDampeningPercentage(uint256 value) public onlyOwner {
		require(value <= 90, "");
		_globalRewardDampeningPercentage = value;
	}


	function approveClaim(address byAddress, bool isApproved) public {
		require(byAddress != address(0), "");
		_rewardClaimApprovals[msg.sender][byAddress] = isApproved;
	}


	function isClaimApproved(address ofAddress, address byAddress) public view returns(bool) {
		return _rewardClaimApprovals[ofAddress][byAddress];
	}


	function isRewardAsTokensEnabled() public view returns(bool) {
		return _rewardAsTokensEnabled;
	}


	function setRewardAsTokensEnabled(bool isEnabled) public onlyOwner {
		_rewardAsTokensEnabled = isEnabled;
	}


	function gradualBurnMagnitude() public view returns (uint256) {
		return _gradualBurnMagnitude;
	}


	function setGradualBurnMagnitude(uint256 magnitude) public onlyOwner {
		require(magnitude <= 100, "");
		_gradualBurnMagnitude = magnitude;
	}


	function gradualBurnTimespan() public view returns (uint256) {
		return _gradualBurnTimespan;
	}


	function setGradualBurnTimespan(uint256 timespan) public onlyOwner {
		require(timespan >= 5 minutes, "");
		_gradualBurnTimespan = timespan;
	}


	function claimRewardAsTokensPercentage(address ofAddress) public view returns(uint256) {
		return _claimRewardAsTokensPercentage[ofAddress];
	}


	function setClaimRewardAsTokensPercentage(uint256 percentage) public {
		require(percentage <= 100, "");
		_claimRewardAsTokensPercentage[msg.sender] = percentage;
	}


	function maintrxPoolSize() public view returns (uint256) {
		return _maintrxPoolSize;
	}


	function setMaintrxPoolSize(uint256 size) public onlyOwner {
		require(size >= 10 , "");
		_maintrxPoolSize = size;
	}


	function isInRewardClaimQueue(address addr) public view returns(bool) {
		return _addressesInRewardClaimQueue[addr];
	}

	
	function reimburseAfterBZIClaimFailure() public view returns(bool) {
		return _reimburseAfterBZIClaimFailure;
	}


	function setReimburseAfterBZIClaimFailure(bool value) public onlyOwner {
		_reimburseAfterBZIClaimFailure = value;
	}


	function lastBurnDate() public view returns(uint256) {
		return _lastBurnDate;
	}


	function rewardClaimQueueLength() public view returns(uint256) {
		return _rewardClaimQueue.length;
	}


	function rewardClaimQueueIndex() public view returns(uint256) {
		return _rewardClaimQueueIndex;
	}


	function isWhitelistedExternalProcessor(address addr) public view returns(bool) {
		return _whitelistedExternalProcessors[addr];
	}


	function setWhitelistedExternalProcessor(address addr, bool isWhitelisted) public onlyOwner {
		 require(addr != address(0), "");
		_whitelistedExternalProcessors[addr] = isWhitelisted;
	}
	

	function setSendWeiGasLimit(uint256 amount) public onlyOwner {
		_sendWeiGasLimit = amount;
	}
	

	function setExcludeNonHumansFromRewards(bool exclude) public onlyOwner {
		_excludeNonHumansFromRewards = exclude;
	}
	

	function setAntiBotEnabled(bool _isEnabled) public onlyOwner {
		updateAntiBotStatus(_isEnabled);
	}


	function updateAntiBotStatus(bool _flag) private {
		antiEnabled = _flag;
		antiBotTimestamp = block.timestamp + antiBlockNum;
	}


	function updateBlockNum(uint256 _blockNum) public onlyOwner {
		antiBlockNum = _blockNum;
	}

	
	function onBeforeCalculateFeeRate() internal override view returns (bool) {
		if (antiEnabled && block.timestamp < antiBotTimestamp) {
			return true;
		}
	    return super.onBeforeCalculateFeeRate();
	}

	function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            _addressesExcludedFromFees[pair]=true;
            _addressesExcludedFromHold[pair]=true;
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}

