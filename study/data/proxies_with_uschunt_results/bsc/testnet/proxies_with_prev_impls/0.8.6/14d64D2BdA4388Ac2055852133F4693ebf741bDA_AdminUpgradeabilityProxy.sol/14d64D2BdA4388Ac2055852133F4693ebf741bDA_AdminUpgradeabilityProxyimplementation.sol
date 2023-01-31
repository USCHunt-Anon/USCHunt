// : MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// : MIT

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


// : MIT

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

pragma solidity ^0.8.4;

//import"../pawn-p2p-v2/PawnLib.sol";

interface IPawn {
    /** General functions */

    function emergencyWithdraw(address _token) external;

    function updateCollateralStatus(
        uint256 _collateralId,
        CollateralStatus _status
    ) external;

    function updateCollateralAmount(uint256 _collateralId, uint256 _amount)
        external;

    function getContractInfoForReview(uint256 _contractId) 
        external
        view
        returns (
            address borrower,
            address lender,
            ContractStatus status
        );
}


// : MIT

pragma solidity ^0.8.4;

interface IReputation {
    
    // Reason for Reputation point adjustment
    /**
    * @dev Reputation points in correspondence with ReasonType 
    * LD_CREATE_PACKAGE         : +3    (0)
    * LD_CANCEL_PACKAGE         : -3    (1)
    * LD_REOPEN_PACKAGE         : +3    (2)
    * LD_GENERATE_CONTRACT      : +1    (3)
    * LD_CREATE_OFFER           : +2    (4)
    * LD_CANCEL_OFFER           : -2    (5)
    * LD_ACCEPT_OFFER           : +1    (6)
    * BR_CREATE_COLLATERAL      : +3    (7)
    * BR_CANCEL_COLLATERAL      : -3    (8)
    * BR_ONTIME_PAYMENT         : +1    (9)
    * BR_LATE_PAYMENT           : -1    (10)
    * BR_ACCEPT_OFFER           : +1    (11)
    * BR_CONTRACT_COMPLETE      : +5    (12)
    * BR_CONTRACT_DEFAULTED     : -5    (13)
    * LD_REVIEWED_BY_BORROWER_1 : +1    (14)
    * LD_REVIEWED_BY_BORROWER_2 : +2    (15)
    * LD_REVIEWED_BY_BORROWER_3 : +3    (16)
    * LD_REVIEWED_BY_BORROWER_4 : +4    (17)
    * LD_REVIEWED_BY_BORROWER_5 : +5    (18)
    * LD_KYC                    : +5    (19)
    * BR_REVIEWED_BY_LENDER_1   : +1    (20)
    * BR_REVIEWED_BY_LENDER_2   : +2    (21)
    * BR_REVIEWED_BY_LENDER_3   : +3    (22)
    * BR_REVIEWED_BY_LENDER_4   : +4    (23)
    * BR_REVIEWED_BY_LENDER_5   : +5    (24)
    * BR_KYC                    : +5    (25)
    */
    
    enum ReasonType {
        LD_CREATE_PACKAGE, 
        LD_CANCEL_PACKAGE,
        LD_REOPEN_PACKAGE,
        LD_GENERATE_CONTRACT,
        LD_CREATE_OFFER,
        LD_CANCEL_OFFER,
        LD_ACCEPT_OFFER,
        BR_CREATE_COLLATERAL,
        BR_CANCEL_COLLATERAL,
        BR_ONTIME_PAYMENT,
        BR_LATE_PAYMENT,
        BR_ACCEPT_OFFER,
        BR_CONTRACT_COMPLETE,
        BR_CONTRACT_DEFAULTED,
        
        LD_REVIEWED_BY_BORROWER_1,
        LD_REVIEWED_BY_BORROWER_2,
        LD_REVIEWED_BY_BORROWER_3,
        LD_REVIEWED_BY_BORROWER_4,
        LD_REVIEWED_BY_BORROWER_5,
        LD_KYC,

        BR_REVIEWED_BY_LENDER_1,
        BR_REVIEWED_BY_LENDER_2,
        BR_REVIEWED_BY_LENDER_3,
        BR_REVIEWED_BY_LENDER_4,
        BR_REVIEWED_BY_LENDER_5,
        BR_KYC
    }
    
    /**
    * @dev Get the reputation score of an account
    */
    function getReputationScore(address _address) external view returns(uint32);

    function adjustReputationScore(address _user, ReasonType _reasonType) external;

}

// : MIT
pragma solidity ^0.8.4;
//import"../pawn-p2p-v2/PawnLib.sol";
//import"@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//import"@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import"@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
//import"../pawn-nft/IPawnNFT.sol";

contract Exchange is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    mapping(address => address) public ListCryptoExchange;

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _authorizeUpgrade(address)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // set dia chi cac token ( crypto) tuong ung voi dia chi chuyen doi ra USD tren chain link
    function setCryptoExchange(
        address _cryptoAddress,
        address _latestPriceAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ListCryptoExchange[_cryptoAddress] = _latestPriceAddress;
    }

    function getLatestRoundData(AggregatorV3Interface getPriceToUSD)
        internal
        view
        returns (uint256, uint256)
    {
        (, int256 _price, , uint256 _timeStamp, ) = getPriceToUSD
            .latestRoundData();

        require(_price > 0, "Negative or zero rate");

        return (uint256(_price), _timeStamp);
    }

    // lay gia cua dong BNB
    function RateBNBwithUSD() internal view returns (uint256 price) {
        AggregatorV3Interface getPriceToUSD = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );

        (price, ) = getLatestRoundData(getPriceToUSD);
    }

    // lay ti gia dong BNB + timestamp
    function RateBNBwithUSDAttimestamp()
        internal
        view
        returns (uint256 price, uint256 timeStamp)
    {
        AggregatorV3Interface getPriceToUSD = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );

        (price, timeStamp) = getLatestRoundData(getPriceToUSD);
    }

    // lay gia cua cac crypto va token khac da duoc them vao ListcryptoExchange
    function getLatesPriceToUSD(address _adcrypto)
        internal
        view
        returns (uint256 price)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            ListCryptoExchange[_adcrypto]
        );

        (price, ) = getLatestRoundData(priceFeed);
    }

    // lay ti gia va timestamp cua cac crypto va token da duoc them vao ListcryptoExchange
    function getRateAndTimestamp(address _adcrypto)
        internal
        view
        returns (uint256 price, uint256 timeStamp)
    {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            ListCryptoExchange[_adcrypto]
        );

        (price, timeStamp) = getLatestRoundData(priceFeed);
    }

    function calculateLoanAmountAndExchangeRate(
        Collateral memory _col,
        PawnShopPackage memory _pkg
    ) external view returns (uint256 loanAmount, uint256 exchangeRate) {
        (loanAmount, exchangeRate, , , ) = calcLoanAmountAndExchangeRate(
            _col.collateralAddress,
            _col.amount,
            _col.loanAsset,
            _pkg.loanToValue,
            _pkg.repaymentAsset
        );
    }

    function calcLoanAmountAndExchangeRate(
        address collateralAddress,
        uint256 amount,
        address loanAsset,
        uint256 loanToValue,
        address repaymentAsset
    )
        public
        view
        returns (
            uint256 loanAmount,
            uint256 exchangeRate,
            uint256 collateralToUSD,
            uint256 rateLoanAsset,
            uint256 rateRepaymentAsset
        )
    {
        if (collateralAddress == address(0)) {
            // If collateral address is address(0), check BNB exchange rate with USD
            // collateralToUSD = (uint256(RateBNBwithUSD()) * loanToValue * amount) / (100 * 10**5);
            (, uint256 ltvAmount) = SafeMathUpgradeable.tryMul(
                loanToValue,
                amount
            );
            (, uint256 collRate) = SafeMathUpgradeable.tryMul(
                ltvAmount,
                uint256(RateBNBwithUSD())
            );
            (, uint256 collToUSD) = SafeMathUpgradeable.tryDiv(
                collRate,
                (100 * 10**5)
            );

            collateralToUSD = collToUSD;
        } else {
            // If collateral address is not BNB, get latest price in USD of collateral crypto
            // collateralToUSD = (uint256(getLatesPriceToUSD(collateralAddress))  * loanToValue * amount) / (100 * 10**5);
            (, uint256 ltvAmount) = SafeMathUpgradeable.tryMul(
                loanToValue,
                amount
            );
            (, uint256 collRate) = SafeMathUpgradeable.tryMul(
                ltvAmount,
                getLatesPriceToUSD(collateralAddress)
            );
            (, uint256 collToUSD) = SafeMathUpgradeable.tryDiv(
                collRate,
                (100 * 10**5)
            );

            collateralToUSD = collToUSD;
        }

        if (loanAsset == address(0)) {
            // get price of BNB in USD
            rateLoanAsset = RateBNBwithUSD();
        } else {
            // get price in USD of crypto as loan asset
            rateLoanAsset = getLatesPriceToUSD(loanAsset);
        }

        (, uint256 lAmount) = SafeMathUpgradeable.tryDiv(
            collateralToUSD,
            rateLoanAsset
        );
        // loanAmount = collateralToUSD / rateLoanAsset;
        uint256 tempLoamAmount = lAmount / 10**13;
        loanAmount = tempLoamAmount * 10**13;

        if (repaymentAsset == address(0)) {
            // get price in USD of BNB as repayment asset
            rateRepaymentAsset = RateBNBwithUSD();
        } else {
            // get latest price in USD of crypto as repayment asset
            rateRepaymentAsset = getLatesPriceToUSD(repaymentAsset);
        }

        // calculate exchange rate
        (, uint256 xchange) = SafeMathUpgradeable.tryDiv(
            rateLoanAsset * 10**5,
            rateRepaymentAsset
        );
        exchangeRate = xchange * 10**13;
    }

    // calculate Rate of LoanAsset with repaymentAsset
    function exchangeRateofOffer(address _adLoanAsset, address _adRepayment)
        external
        view
        returns (uint256 exchangeRateOfOffer)
    {
        //  exchangeRateOffer = loanAsset / repaymentAsset
        if (_adLoanAsset == address(0)) {
            // if LoanAsset is address(0) , check BNB exchange rate with BNB
            (, uint256 exRate) = SafeMathUpgradeable.tryDiv(
                RateBNBwithUSD(),
                getLatesPriceToUSD(_adRepayment)
            );
            exchangeRateOfOffer = exRate;
        } else {
            // all LoanAsset and repaymentAsset are crypto or token is different BNB
            (, uint256 exRate) = SafeMathUpgradeable.tryDiv(
                (getLatesPriceToUSD(_adLoanAsset) * 10**5),
                getLatesPriceToUSD(_adRepayment)
            );
            exchangeRateOfOffer = exRate;
        }
    }

    //===========================================Tinh interest =======================================
    // tinh tien lai cua moi ky: interest = loanAmount * interestByLoanDurationType
    //(interestByLoanDurationType = % lãi * số kì * loại kì / (365*100))

    function calculateInterest(
        uint256 _remainingLoan,
        Contract memory _contract
    ) external view returns (uint256 interest) {
        uint256 _interestToUSD;
        uint256 _repaymentAssetToUSD;
        uint256 _interestByLoanDurationType;

        // tien lai
        if (_contract.terms.loanAsset == address(0)) {
            // neu loanAsset la dong BNB
            // interestToUSD = (uint256(RateBNBwithUSD()) *_contract.terms.loanAmount) * _contract.terms.interest;
            (, uint256 interestToAmount) = SafeMathUpgradeable.tryMul(
                _contract.terms.interest,
                _remainingLoan
            );
            (, uint256 interestRate) = SafeMathUpgradeable.tryMul(
                interestToAmount,
                RateBNBwithUSD()
            );
            (, uint256 itrestRate) = SafeMathUpgradeable.tryDiv(
                interestRate,
                (100 * 10**5)
            );
            _interestToUSD = itrestRate;
        } else {
            // Neu loanAsset la cac dong crypto va token khac BNB
            // interestToUSD = (uint256(getLatesPriceToUSD(_contract.terms.loanAsset)) * _contract.terms.loanAmount) * _contractterms.interest;
            (, uint256 interestToAmount) = SafeMathUpgradeable.tryMul(
                _contract.terms.interest,
                _remainingLoan
            );
            (, uint256 interestRate) = SafeMathUpgradeable.tryMul(
                interestToAmount,
                getLatesPriceToUSD(_contract.terms.loanAsset)
            );
            (, uint256 itrestRate) = SafeMathUpgradeable.tryDiv(
                interestRate,
                (100 * 10**5)
            );
            _interestToUSD = itrestRate;
        }

        // tinh tien lai cho moi ky thanh toan
        if (_contract.terms.repaymentCycleType == LoanDurationType.WEEK) {
            // neu thoi gian vay theo tuan thì L = loanAmount * interest * 7 /365
            (, uint256 _interest) = SafeMathUpgradeable.tryDiv(
                (_interestToUSD * 7),
                365
            );
            _interestByLoanDurationType = _interest;
        } else {
            // thoi gian vay theo thang thi  L = loanAmount * interest * 30 /365
            //  _interestByLoanDurationType =(_contract.terms.interest * 30) / 365);
            (, uint256 _interest) = SafeMathUpgradeable.tryDiv(
                (_interestToUSD * 30),
                365
            );
            _interestByLoanDurationType = _interest;
        }

        // tinh Rate cua dong repayment
        if (_contract.terms.repaymentAsset == address(0)) {
            // neu dong tra la BNB
            _repaymentAssetToUSD = RateBNBwithUSD();
        } else {
            // neu dong tra kha BNB
            _repaymentAssetToUSD = getLatesPriceToUSD(
                _contract.terms.loanAsset
            );
        }

        // tien lai theo moi kỳ tinh ra dong tra
        (, uint256 saInterest) = SafeMathUpgradeable.tryDiv(
            _interestByLoanDurationType,
            _repaymentAssetToUSD
        );
        // uint256 tempInterest = saInterest / 10**13;
        // interest = tempInterest * 10**13;
        interest = DivRound(saInterest);
    }

    //====================  Test tinh interest==================================

    function calculateInterestTest(
        uint256 _interest,
        uint256 _loanAmount,
        address _loanAsset,
        address _repaymentAsset
    )
        external
        view
        returns (
            uint256 interest,
            uint256 _interestToUSD,
            uint256 _repaymentAssetToUSD,
            uint256 _interestByLoanDurationType
        )
    {
        // tien lai
        if (_loanAsset == address(0)) {
            // neu loanAsset la dong BNB
            // interestToUSD = (uint256(RateBNBwithUSD()) *_contract.terms.loanAmount) * _contract.terms.interest;
            (, uint256 interestToAmount) = SafeMathUpgradeable.tryMul(
                _interest,
                _loanAmount
            );
            (, uint256 interestRate) = SafeMathUpgradeable.tryMul(
                interestToAmount,
                RateBNBwithUSD()
            );
            (, uint256 itrestRate) = SafeMathUpgradeable.tryDiv(
                interestRate,
                (100 * 10**5)
            );
            _interestToUSD = itrestRate;
        } else {
            // Neu loanAsset la cac dong crypto va token khac BNB
            // interestToUSD = (uint256(getLatesPriceToUSD(_contract.terms.loanAsset)) * _contract.terms.loanAmount) * _contractterms.interest;
            (, uint256 interestToAmount) = SafeMathUpgradeable.tryMul(
                _interest,
                _loanAmount
            );
            (, uint256 interestRate) = SafeMathUpgradeable.tryMul(
                interestToAmount,
                getLatesPriceToUSD(_loanAsset)
            );
            (, uint256 itrestRate) = SafeMathUpgradeable.tryDiv(
                interestRate,
                (100 * 10**5)
            );
            _interestToUSD = itrestRate;
        }

        // tinh tien lai cho moi ky thanh toan

        // neu thoi gian vay theo tuan thì L = loanAmount * interest * 7 /365
        (, uint256 itrest) = SafeMathUpgradeable.tryDiv(
            _interestToUSD * 7,
            365
        );
        _interestByLoanDurationType = itrest;

        // tinh Rate cua dong repayment
        if (_repaymentAsset == address(0)) {
            // neu dong tra la BNB
            _repaymentAssetToUSD = RateBNBwithUSD();
        } else {
            // neu dong tra kha BNB
            _repaymentAssetToUSD = getLatesPriceToUSD(_loanAsset);
        }

        // tien lai theo moi kỳ tinh ra dong tra
        (, uint256 saInterest) = SafeMathUpgradeable.tryDiv(
            _interestByLoanDurationType,
            _repaymentAssetToUSD
        );
        interest = saInterest;
    }

    //=============================== Tinh penalty =====================================

    //  p = (p(n-1)) + (p(n-1) *(L)) + (L(n-1)*(p))

    function calculatePenalty(
        PaymentRequest memory _paymentrequest,
        Contract memory _contract,
        uint256 _penaltyRate
    ) external pure returns (uint256 valuePenalty) {
        uint256 _interestOfPenalty;
        if (_contract.terms.repaymentCycleType == LoanDurationType.WEEK) {
            // neu ky vay theo tuan thi (L) = interest * 7 /365
            //_interestByLoanDurationType =(_contract.terms.interest * 7) / (100 * 365);
            (, uint256 saInterestByLoanDurationType) = SafeMathUpgradeable
                .tryDiv((_contract.terms.interest * 7), 365);
            (, uint256 saPenaltyOfInterestRate) = SafeMathUpgradeable.tryMul(
                _paymentrequest.remainingPenalty,
                saInterestByLoanDurationType
            );
            (, uint256 saPenaltyOfInterest) = SafeMathUpgradeable.tryDiv(
                saPenaltyOfInterestRate,
                (100 * 10**5)
            );
            _interestOfPenalty = saPenaltyOfInterest;
        } else {
            // _interestByLoanDurationType =(_contract.terms.interest * 30) /(100 * 365);
            (, uint256 saInterestByLoanDurationType) = SafeMathUpgradeable
                .tryDiv(_contract.terms.interest * 30, 365);
            (, uint256 saPenaltyOfInterestRate) = SafeMathUpgradeable.tryMul(
                _paymentrequest.remainingPenalty,
                saInterestByLoanDurationType
            );
            (, uint256 saPenaltyOfInterest) = SafeMathUpgradeable.tryDiv(
                saPenaltyOfInterestRate,
                (100 * 10**5)
            );
            _interestOfPenalty = saPenaltyOfInterest;
        }
        // valuePenalty =(_paymentrequest.remainingPenalty +_paymentrequest.remainingPenalty *_interestByLoanDurationType +_paymentrequest.remainingInterest *_penaltyRate);
        //  uint256 penalty = _paymentrequest.remainingInterest * _penaltyRate;
        (, uint256 penalty) = SafeMathUpgradeable.tryDiv(
            (_paymentrequest.remainingInterest * _penaltyRate),
            (100 * 10**5)
        );
        uint256 _penalty = _paymentrequest.remainingPenalty +
            _interestOfPenalty +
            penalty;
        // uint256 tempPenalty = _penalty / 10**13;
        // valuePenalty = tempPenalty * 10**13;
        valuePenalty = DivRound(_penalty);
    }

    // ============================== test penalty===================================
    function calculatePenaltyTest(
        uint256 _remainingPenalty,
        uint256 _remainingInterest,
        uint256 _interest,
        uint256 _penaltyRate,
        LoanDurationType numLoanDurationType
    ) external pure returns (uint256 valuePenalty, uint256 _penaltyOfInterest) {
        uint256 _interestOfPenalty;
        if (numLoanDurationType == LoanDurationType.WEEK) {
            // neu ky vay theo tuan thi (L) = interest * 7 /365
            //_interestByLoanDurationType =(_contract.terms.interest * 7) / (100 * 365);
            (, uint256 saInterestByLoanDurationType) = SafeMathUpgradeable
                .tryDiv((_interest * 7), 365);
            (, uint256 saPenaltyOfInterestRate) = SafeMathUpgradeable.tryMul(
                _remainingPenalty,
                saInterestByLoanDurationType
            );
            (, uint256 saPenaltyOfInterest) = SafeMathUpgradeable.tryDiv(
                saPenaltyOfInterestRate,
                (100 * 10**5)
            );
            _interestOfPenalty = saPenaltyOfInterest;
        } else {
            // _interestByLoanDurationType =(_contract.terms.interest * 30) /(100 * 365);
            (, uint256 saInterestByLoanDurationType) = SafeMathUpgradeable
                .tryDiv(_interest * 30, 365);
            (, uint256 saPenaltyOfInterestRate) = SafeMathUpgradeable.tryMul(
                _remainingPenalty,
                saInterestByLoanDurationType
            );
            (, uint256 saPenaltyOfInterest) = SafeMathUpgradeable.tryDiv(
                saPenaltyOfInterestRate,
                (100 * 10**5)
            );
            _interestOfPenalty = saPenaltyOfInterest;

            // valuePenalty =(_paymentrequest.remainingPenalty +_paymentrequest.remainingPenalty *_interestByLoanDurationType +_paymentrequest.remainingInterest *_penaltyRate);
            (, uint256 penalty) = SafeMathUpgradeable.tryDiv(
                (_remainingInterest * _penaltyRate),
                (100 * 10**5)
            );
            valuePenalty = _remainingPenalty + _penaltyOfInterest + penalty;
        }
    }

    // lay Rate va thoi gian cap nhat ti gia do
    function RateAndTimestamp(Contract memory _contract)
        external
        view
        returns (
            uint256 _collateralExchangeRate,
            uint256 _loanExchangeRate,
            uint256 _repaymemtExchangeRate,
            uint256 _rateUpdateTime
        )
    {
        // Get exchange rate of collateral token
        if (_contract.terms.collateralAsset == address(0)) {
            (
                _collateralExchangeRate,
                _rateUpdateTime
            ) = RateBNBwithUSDAttimestamp();
        } else {
            (_collateralExchangeRate, _rateUpdateTime) = getRateAndTimestamp(
                _contract.terms.collateralAsset
            );
        }

        // Get exchange rate of loan token
        if (_contract.terms.loanAsset == address(0)) {
            (_loanExchangeRate, _rateUpdateTime) = RateBNBwithUSDAttimestamp();
        } else {
            (_loanExchangeRate, _rateUpdateTime) = getRateAndTimestamp(
                _contract.terms.loanAsset
            );
        }

        // Get exchange rate of repayment token
        if (_contract.terms.repaymentAsset == address(0)) {
            (
                _repaymemtExchangeRate,
                _rateUpdateTime
            ) = RateBNBwithUSDAttimestamp();
        } else {
            (_repaymemtExchangeRate, _rateUpdateTime) = getRateAndTimestamp(
                _contract.terms.repaymentAsset
            );
        }
    }

    // tinh ti gia cua repayment / collateralAsset  va   loanAsset / collateralAsset
    function collateralPerRepaymentAndLoanTokenExchangeRate(
        Contract memory _contract
    )
        external
        view
        returns (
            uint256 _collateralPerRepaymentTokenExchangeRate,
            uint256 _collateralPerLoanAssetExchangeRate
        )
    {
        uint256 priceRepaymentAset;
        uint256 priceLoanAsset;
        uint256 priceCollateralAsset;

        if (_contract.terms.repaymentAsset == address(0)) {
            // neu repaymentAsset la BNB
            priceRepaymentAset = RateBNBwithUSD();
        } else {
            // neu la cac dong khac
            priceRepaymentAset = getLatesPriceToUSD(
                _contract.terms.repaymentAsset
            );
        }

        if (_contract.terms.loanAsset == address(0)) {
            // neu dong loan asset la BNB
            priceLoanAsset = RateBNBwithUSD();
        } else {
            // cac dong khac
            priceLoanAsset = getLatesPriceToUSD(_contract.terms.loanAsset);
        }

        if (_contract.terms.collateralAsset == address(0)) {
            // neu collateralAsset la bnb
            priceCollateralAsset = RateBNBwithUSD();
        } else {
            // la cac dong khac
            priceCollateralAsset = getLatesPriceToUSD(
                _contract.terms.collateralAsset
            );
        }

        bool success;
        // tempCollateralPerRepaymentTokenExchangeRate = priceRepaymentAsset / priceCollateralAsset
        (
            success,
            _collateralPerRepaymentTokenExchangeRate
        ) = SafeMathUpgradeable.tryDiv(
            (priceRepaymentAset * 10**10),
            priceCollateralAsset
        );
        require(success, "Safe math: division by zero");

        // _collateralPerRepaymentTokenExchangeRate = tempCollateralPerRepaymentTokenExchangeRate;

        // tempCollateralPerLoanAssetExchangeRate = priceLoanAsset / priceCollateralAsset
        (success, _collateralPerLoanAssetExchangeRate) = SafeMathUpgradeable
            .tryDiv((priceLoanAsset * 10**10), priceCollateralAsset);

        require(success, "Safe math: division by zero");

        // _collateralPerLoanAssetExchangeRate = tempCollateralPerLoanAssetExchangeRate;
    }

    function DivRound(uint256 a) private pure returns (uint256) {
        // kiem tra so du khi chia 10**13. Neu lon hon 5 *10**12 khi chia xong thi lam tron len(+1) roi nhan lai voi 10**13
        //con nho hon thi giu nguyen va nhan lai voi 10**13

        uint256 tmp = a % 10**13;
        uint256 tm;
        if (tmp < 5 * 10**12) {
            tm = a / 10**13;
        } else {
            tm = a / 10**13 + 1;
        }
        uint256 rouding = tm * 10**13;
        return rouding;
    }
}


// : MIT

pragma solidity ^0.8.4;

//import"./IPawn.sol";

interface ILoan is IPawnV2 {
    function createContract(ContractRawData memory _contractData)
        external
        returns (uint256 _idx);

    function closePaymentRequestAndStartNew(
        int256 _paymentRequestId,
        uint256 _contractId,
        PaymentRequestTypeEnum _paymentRequestType
    ) external;

    function checkLenderAccount(
        address collateralAddress,
        uint256 amount,
        uint256 loanToValue,
        address loanToken,
        address repaymentAsset,
        address owner,
        address spender
    ) external view returns (bool sufficientBalance, bool overAllowance);

    function getContractInfoForReview(uint256 _contractId) 
        external
        view
        returns (
            address borrower,
            address lender,
            ContractStatus status
        );
}


// : MIT

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

pragma solidity ^0.8.4;

//import"@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// //import"./IPawn.sol";

enum LoanDurationType {
    WEEK,
    MONTH
}
enum CollateralStatus {
    OPEN,
    DOING,
    COMPLETED,
    CANCEL
}
struct Collateral {
    address owner;
    uint256 amount;
    address collateralAddress;
    address loanAsset;
    uint256 expectedDurationQty;
    LoanDurationType expectedDurationType;
    CollateralStatus status;
}

enum OfferStatus {
    PENDING,
    ACCEPTED,
    COMPLETED,
    CANCEL
}
struct CollateralOfferList {
    mapping(uint256 => Offer) offerMapping;
    uint256[] offerIdList;
    bool isInit;
}

struct Offer {
    address owner;
    address repaymentAsset;
    uint256 loanAmount;
    uint256 interest;
    uint256 duration;
    OfferStatus status;
    LoanDurationType loanDurationType;
    LoanDurationType repaymentCycleType;
    uint256 liquidityThreshold;
    bool isInit;
}

enum PawnShopPackageStatus {
    ACTIVE,
    INACTIVE
}
enum PawnShopPackageType {
    AUTO,
    SEMI_AUTO
}
struct Range {
    uint256 lowerBound;
    uint256 upperBound;
}

struct PawnShopPackage {
    address owner;
    PawnShopPackageStatus status;
    PawnShopPackageType packageType;
    address loanToken;
    Range loanAmountRange;
    address[] collateralAcceptance;
    uint256 interest;
    uint256 durationType;
    Range durationRange;
    address repaymentAsset;
    LoanDurationType repaymentCycleType;
    uint256 loanToValue;
    uint256 loanToValueLiquidationThreshold;
}

enum LoanRequestStatus {
    PENDING,
    ACCEPTED,
    REJECTED,
    CONTRACTED,
    CANCEL
}
struct LoanRequestStatusStruct {
    bool isInit;
    LoanRequestStatus status;
}
struct CollateralAsLoanRequestListStruct {
    mapping(uint256 => LoanRequestStatusStruct) loanRequestToPawnShopPackageMapping; // Mapping from package to status
    uint256[] pawnShopPackageIdList;
    bool isInit;
}

enum ContractStatus {
    ACTIVE,
    COMPLETED,
    DEFAULT
}
struct ContractTerms {
    address borrower;
    address lender;
    address collateralAsset;
    uint256 collateralAmount;
    address loanAsset;
    uint256 loanAmount;
    address repaymentAsset;
    uint256 interest;
    LoanDurationType repaymentCycleType;
    uint256 liquidityThreshold;
    uint256 contractStartDate;
    uint256 contractEndDate;
    uint256 lateThreshold;
    uint256 systemFeeRate;
    uint256 penaltyRate;
    uint256 prepaidFeeRate;
}
struct Contract {
    uint256 collateralId;
    int256 offerId;
    int256 pawnShopPackageId;
    ContractTerms terms;
    ContractStatus status;
    uint8 lateCount;
}

enum PaymentRequestStatusEnum {
    ACTIVE,
    LATE,
    COMPLETE,
    DEFAULT
}
enum PaymentRequestTypeEnum {
    INTEREST,
    OVERDUE,
    LOAN
}
struct PaymentRequest {
    uint256 requestId;
    PaymentRequestTypeEnum paymentRequestType;
    uint256 remainingLoan;
    uint256 penalty;
    uint256 interest;
    uint256 remainingPenalty;
    uint256 remainingInterest;
    uint256 dueDateTimestamp;
    bool chargePrepaidFee;
    PaymentRequestStatusEnum status;
}

enum ContractLiquidedReasonType {
    LATE,
    RISK,
    UNPAID
}

struct ContractRawData {
    uint256 collateralId;
    address borrower;
    address loanAsset;
    address collateralAsset;
    uint256 collateralAmount;
    int256 packageId;
    int256 offerId;
    uint256 exchangeRate;
    uint256 loanAmount;
    address lender;
    address repaymentAsset;
    uint256 interest;
    LoanDurationType repaymentCycleType;
    uint256 liquidityThreshold;
    uint256 loanDurationQty;
}

struct ContractLiquidationData {
    uint256 contractId;
    uint256 liquidAmount;
    uint256 systemFeeAmount;
    uint256 collateralExchangeRate;
    uint256 loanExchangeRate;
    uint256 repaymentExchangeRate;
    uint256 rateUpdateTime;
    ContractLiquidedReasonType reasonType;
}

library PawnLib {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function safeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (asset == address(0)) {
            require(from.balance >= amount, "0"); // balance
            // Handle BNB
            if (to == address(this)) {
                // Send to this contract
            } else if (from == address(this)) {
                // Send from this contract
                (bool success, ) = to.call{value: amount}("");
                require(success, "1"); //fail-trans-bnb
            } else {
                // Send from other address to another address
                require(false, "2"); //not-allow-transfer
            }
        } else {
            // Handle ERC20
            uint256 prebalance = IERC20Upgradeable(asset).balanceOf(to);
            require(
                IERC20Upgradeable(asset).balanceOf(from) >= amount,
                "3" //not-enough-balance
            );
            if (from == address(this)) {
                // transfer direct to to
                IERC20Upgradeable(asset).safeTransfer(to, amount);
            } else {
                require(
                    IERC20Upgradeable(asset).allowance(from, address(this)) >=
                        amount,
                    "4" //not-allowance
                );
                IERC20Upgradeable(asset).safeTransferFrom(from, to, amount);
            }
            require(
                IERC20Upgradeable(asset).balanceOf(to) - amount == prebalance,
                "5" //not-trans-enough
            );
        }
    }

    function calculateAmount(address _token, address from)
        internal
        view
        returns (uint256 _amount)
    {
        if (_token == address(0)) {
            // BNB
            _amount = from.balance;
        } else {
            // ERC20
            _amount = IERC20Upgradeable(_token).balanceOf(from);
        }
    }

    function calculateSystemFee(
        uint256 amount,
        uint256 feeRate,
        uint256 zoom
    ) internal pure returns (uint256 feeAmount) {
        feeAmount = (amount * feeRate) / (zoom * 100);
    }

    function calculateContractDuration(
        LoanDurationType durationType,
        uint256 duration
    ) internal pure returns (uint256 inSeconds) {
        if (durationType == LoanDurationType.WEEK) {
            // inSeconds = 7 * 24 * 3600 * duration;
            inSeconds = 600 * duration; // test
        } else {
            // inSeconds = 30 * 24 * 3600 * duration;
            inSeconds = 900 * duration; // test
        }
    }

    function isPrepaidChargeRequired(
        LoanDurationType durationType,
        uint256 startDate,
        uint256 endDate
    ) internal pure returns (bool) {
        uint256 week = 600; // define week duration
        uint256 month = 900; // define month duration

        if (durationType == LoanDurationType.WEEK) {
            // if loan contract only lasts one week
            if ((endDate - startDate) <= week) {
                return false;
            } else {
                return true;
            }
        } else {
            // if loan contract only lasts one month
            if ((endDate - startDate) <= month) {
                return false;
            } else {
                return true;
            }
        }
    }

    function calculatedueDateTimestampInterest(LoanDurationType durationType)
        internal
        pure
        returns (uint256 duedateTimestampInterest)
    {
        if (durationType == LoanDurationType.WEEK) {
            // duedateTimestampInterest = 3*24*3600;
            duedateTimestampInterest = 180; // test
        } else {
            // duedateTimestampInterest = 7 * 24 * 3600;
            duedateTimestampInterest = 300; // test
        }
    }

    function calculatedueDateTimestampPenalty(LoanDurationType durationType)
        internal
        pure
        returns (uint256 duedateTimestampInterest)
    {
        if (durationType == LoanDurationType.WEEK) {
            // duedateTimestampInterest = 7 * 24 *3600 - 3 * 24 * 3600;
            duedateTimestampInterest = 600 - 180; // test
        } else {
            //  duedateTimestampInterest = 30 * 24 *3600 - 7 * 24 * 3600;
            duedateTimestampInterest = 900 - 300; // test
        }
    }

    function checkLenderAccount(
        uint256 loanAmount,
        address loanToken,
        address owner,
        address spender
    ) internal view {
        // Check if lender has enough balance and allowance for lending
        uint256 lenderCurrentBalance = IERC20Upgradeable(loanToken).balanceOf(
            owner
        );
        require(lenderCurrentBalance >= loanAmount, "4"); // insufficient balance

        uint256 lenderCurrentAllowance = IERC20Upgradeable(loanToken).allowance(
            owner,
            spender
        );
        require(lenderCurrentAllowance >= loanAmount, "5"); // allowance not enough
    }

    /**
     * @dev Return the absolute value of a signed integer
     * @param _input is any signed integer
     * @return an unsigned integer that is the absolute value of _input
     */
    function abs(int256 _input) internal pure returns (uint256) {
        return _input >= 0 ? uint256(_input) : uint256(_input * -1);
    }
}

library CollateralLib {
    function create(
        Collateral storage self,
        address _collateralAddress,
        uint256 _amount,
        address _loanAsset,
        uint256 _expectedDurationQty,
        LoanDurationType _expectedDurationType
    ) internal {
        self.owner = msg.sender;
        self.amount = _amount;
        self.collateralAddress = _collateralAddress;
        self.loanAsset = _loanAsset;
        self.status = CollateralStatus.OPEN;
        self.expectedDurationQty = _expectedDurationQty;
        self.expectedDurationType = _expectedDurationType;
    }

    function submitToLoanPackage(
        Collateral storage self,
        uint256 _packageId,
        CollateralAsLoanRequestListStruct storage _loanRequestListStruct
    ) internal {
        if (!_loanRequestListStruct.isInit) {
            _loanRequestListStruct.isInit = true;
        }

        LoanRequestStatusStruct storage statusStruct = _loanRequestListStruct
            .loanRequestToPawnShopPackageMapping[_packageId];
        require(statusStruct.isInit == false);
        statusStruct.isInit = true;
        statusStruct.status = LoanRequestStatus.PENDING;

        _loanRequestListStruct.pawnShopPackageIdList.push(_packageId);
    }

    function removeFromLoanPackage(
        Collateral storage self,
        uint256 _packageId,
        CollateralAsLoanRequestListStruct storage _loanRequestListStruct
    ) internal {
        delete _loanRequestListStruct.loanRequestToPawnShopPackageMapping[
            _packageId
        ];

        uint256 lastIndex = _loanRequestListStruct
            .pawnShopPackageIdList
            .length - 1;

        for (uint256 i = 0; i <= lastIndex; i++) {
            if (_loanRequestListStruct.pawnShopPackageIdList[i] == _packageId) {
                _loanRequestListStruct.pawnShopPackageIdList[
                        i
                    ] = _loanRequestListStruct.pawnShopPackageIdList[lastIndex];
                break;
            }
        }
    }

    // function addCollateral(
    //     uint256 _idContract,
    //     uint256 _idCollateral,
    //     uint256 _amount
    // ) internal {

    // }

    function checkCondition(
        Collateral storage self,
        uint256 _packageId,
        PawnShopPackage storage _pawnShopPackage,
        CollateralAsLoanRequestListStruct storage _loanRequestListStruct,
        CollateralStatus _requiredCollateralStatus,
        LoanRequestStatus _requiredLoanRequestStatus
    ) internal view returns (LoanRequestStatusStruct storage _statusStruct) {
        // Check for owner of packageId
        // _pawnShopPackage = pawnShopPackages[_packageId];
        require(_pawnShopPackage.status == PawnShopPackageStatus.ACTIVE, "0"); // pack

        // Check for collateral status is open
        // _collateral = collaterals[_collateralId];
        require(self.status == _requiredCollateralStatus, "1"); // col

        // Check for collateral-package status is PENDING (waiting for accept)
        // _loanRequestListStruct = collateralAsLoanRequestMapping[_collateralId];
        require(_loanRequestListStruct.isInit == true, "2"); // col-loan-req
        _statusStruct = _loanRequestListStruct
            .loanRequestToPawnShopPackageMapping[_packageId];
        require(_statusStruct.isInit == true, "3"); // col-loan-req-pack
        require(_statusStruct.status == _requiredLoanRequestStatus, "4"); // stt
    }
}

library OfferLib {
    function create(
        Offer storage self,
        address _repaymentAsset,
        uint256 _loanAmount,
        uint256 _duration,
        uint256 _interest,
        uint8 _loanDurationType,
        uint8 _repaymentCycleType,
        uint256 _liquidityThreshold
    ) internal {
        self.isInit = true;
        self.owner = msg.sender;
        self.loanAmount = _loanAmount;
        self.interest = _interest;
        self.duration = _duration;
        self.loanDurationType = LoanDurationType(_loanDurationType);
        self.repaymentAsset = _repaymentAsset;
        self.repaymentCycleType = LoanDurationType(_repaymentCycleType);
        self.liquidityThreshold = _liquidityThreshold;
        self.status = OfferStatus.PENDING;
    }

    function cancel(
        Offer storage self,
        uint256 _id,
        address _collateralOwner,
        CollateralOfferList storage _collateralOfferList
    ) internal {
        require(self.isInit == true, "1"); // offer-col
        require(
            self.owner == msg.sender || _collateralOwner == msg.sender,
            "2"
        ); // owner
        require(self.status == OfferStatus.PENDING, "3"); // offer

        delete _collateralOfferList.offerMapping[_id];
        uint256 lastIndex = _collateralOfferList.offerIdList.length - 1;
        for (uint256 i = 0; i <= lastIndex; i++) {
            if (_collateralOfferList.offerIdList[i] == _id) {
                _collateralOfferList.offerIdList[i] = _collateralOfferList
                    .offerIdList[lastIndex];
                break;
            }
        }

        delete _collateralOfferList.offerIdList[lastIndex];
    }
}

library PawnPackageLib {
    function create(
        PawnShopPackage storage self,
        PawnShopPackageType _packageType,
        address _loanToken,
        Range calldata _loanAmountRange,
        address[] calldata _collateralAcceptance,
        uint256 _interest,
        uint256 _durationType,
        Range calldata _durationRange,
        address _repaymentAsset,
        LoanDurationType _repaymentCycleType,
        uint256 _loanToValue,
        uint256 _loanToValueLiquidationThreshold
    ) internal {
        self.owner = msg.sender;
        self.status = PawnShopPackageStatus.ACTIVE;
        self.packageType = _packageType;
        self.loanToken = _loanToken;
        self.loanAmountRange = _loanAmountRange;
        self.collateralAcceptance = _collateralAcceptance;
        self.interest = _interest;
        self.durationType = _durationType;
        self.durationRange = _durationRange;
        self.repaymentAsset = _repaymentAsset;
        self.repaymentCycleType = _repaymentCycleType;
        self.loanToValue = _loanToValue;
        self.loanToValueLiquidationThreshold = _loanToValueLiquidationThreshold;
    }
}


// : MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


// : MIT

pragma solidity ^0.8.0;

//import"./IAccessControlUpgradeable.sol";
//import"../utils/ContextUpgradeable.sol";
//import"../utils/StringsUpgradeable.sol";
//import"../utils/introspection/ERC165Upgradeable.sol";
//import"../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}


// : MIT

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


// : MIT

pragma solidity ^0.8.0;

//import"../ERC1967/ERC1967UpgradeUpgradeable.sol";
//import"./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}


// : MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// : MIT

pragma solidity ^0.8.4;

interface IPawnNFT {
    /** ========================= Collateral ============================= */

    // Enum
    enum LoanDurationType {
        WEEK,
        MONTH
    }
    enum CollateralStatus {
        OPEN,
        DOING,
        COMPLETED,
        CANCEL
    }
    enum OfferStatus {
        PENDING,
        ACCEPTED,
        COMPLETED,
        CANCEL
    }
    enum ContractStatus {
        ACTIVE,
        COMPLETED,
        DEFAULT
    }
    enum PaymentRequestStatusEnum {
        ACTIVE,
        LATE,
        COMPLETE,
        DEFAULT
    }
    enum PaymentRequestTypeEnum {
        INTEREST,
        OVERDUE,
        LOAN
    }
    enum ContractLiquidedReasonType {
        LATE,
        RISK,
        UNPAID
    }

    struct Collateral {
        address owner;
        address nftContract;
        uint256 nftTokenId;
        uint256 loanAmount;
        address loanAsset;
        uint256 nftTokenQuantity;
        uint256 expectedDurationQty;
        LoanDurationType durationType;
        CollateralStatus status;
    }

    /**
     * @dev create collateral function, collateral will be stored in this contract
     * @param _nftContract is address NFT token collection
     * @param _nftTokenId is token id of NFT
     * @param _loanAmount is amount collateral
     * @param _loanAsset is address of loan token
     * @param _nftTokenQuantity is quantity NFT token
     * @param _expectedDurationQty is expected duration
     * @param _durationType is expected duration type
     * @param _UID is UID pass create collateral to event collateral
     */
    function createCollateral(
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _loanAmount,
        address _loanAsset,
        uint256 _nftTokenQuantity,
        uint256 _expectedDurationQty,
        LoanDurationType _durationType,
        uint256 _UID
    ) external;

    /**
     * @dev withdrawCollateral function, collateral will be delete stored in contract
     * @param _nftCollateralId is id of collateral
     */
    function withdrawCollateral(uint256 _nftCollateralId, uint256 _UID)
        external;

    /** ========================= OFFER ============================= */

    struct CollateralOfferList {
        //offerId => Offer
        mapping(uint256 => Offer) offerMapping;
        uint256[] offerIdList;
        bool isInit;
    }

    struct Offer {
        address owner;
        address repaymentAsset;
        uint256 loanToValue;
        uint256 loanAmount;
        uint256 interest;
        uint256 duration;
        OfferStatus status;
        LoanDurationType loanDurationType;
        LoanDurationType repaymentCycleType;
        uint256 liquidityThreshold;
    }

    /**
     * @dev create offer to collateral
     * @param _nftCollateralId is id collateral
     * @param _repaymentAsset is address token repayment
     * @param _loanToValue is LTV token of loan
     * @param _loanAmount is amount token of loan
     * @param _interest is interest of loan
     * @param _duration is duration of loan
     * @param _liquidityThreshold is liquidity threshold of loan
     * @param _loanDurationType is duration type of loan
     * @param _repaymentCycleType is repayment type of loan
     */
    function createOffer(
        uint256 _nftCollateralId,
        address _repaymentAsset,
        uint256 _loanToValue,
        uint256 _loanAmount,
        uint256 _interest,
        uint256 _duration,
        uint256 _liquidityThreshold,
        LoanDurationType _loanDurationType,
        LoanDurationType _repaymentCycleType,
        uint256 _UID
    ) external;

    /**
     * @dev cancel offer
     * @param _offerId is id offer
     * @param _nftCollateralId is id NFT collateral
     */
    function cancelOffer(
        uint256 _offerId,
        uint256 _nftCollateralId,
        uint256 _UID
    ) external;

    /** ========================= ACCEPT OFFER ============================= */

    struct ContractTerms {
        address borrower;
        address lender;
        uint256 nftTokenId;
        address nftCollateralAsset;
        uint256 nftCollateralAmount;
        address loanAsset;
        uint256 loanAmount;
        address repaymentAsset;
        uint256 interest;
        LoanDurationType repaymentCycleType;
        uint256 liquidityThreshold;
        uint256 contractStartDate;
        uint256 contractEndDate;
        uint256 lateThreshold;
        uint256 systemFeeRate;
        uint256 penaltyRate;
        uint256 prepaidFeeRate;
    }

    struct Contract {
        uint256 nftCollateralId;
        uint256 offerId;
        ContractTerms terms;
        ContractStatus status;
        uint8 lateCount;
    }

    function acceptOffer(
        uint256 _nftCollateralId,
        uint256 _offerId,
        uint256 _UID
    ) external;

    /** ========================= REPAYMENT ============================= */

    struct PaymentRequest {
        uint256 requestId;
        PaymentRequestTypeEnum paymentRequestType;
        uint256 remainingLoan;
        uint256 penalty;
        uint256 interest;
        uint256 remainingPenalty;
        uint256 remainingInterest;
        uint256 dueDateTimestamp;
        bool chargePrepaidFee;
        PaymentRequestStatusEnum status;
    }

    /**
     * @dev End lend period settlement and generate invoice for next period
     * @param _contractId is id contract
     * @param _remainingLoan is remaining Loan of borrower
     * @param _nextPhrasePenalty is next Phrase Penalty
     * @param _nextPhraseInterest is token next Phrase Interest
     * @param _dueDateTimestamp is due DateTimestamp
     * @param _paymentRequestType is type of payment request
     * @param _chargePrepaidFee is charge Prepaid Fee
     */
    function closePaymentRequestAndStartNew(
        uint256 _contractId,
        uint256 _remainingLoan,
        uint256 _nextPhrasePenalty,
        uint256 _nextPhraseInterest,
        uint256 _dueDateTimestamp,
        PaymentRequestTypeEnum _paymentRequestType,
        bool _chargePrepaidFee
    ) external;

    /**
     * @dev Borrowers make repayments
     * @param _contractId is id contract
     * @param _paidPenaltyAmount is paid Penalty Amount
     * @param _paidInterestAmount is paid Interest Amount
     * @param _paidLoanAmount is paidLoanAmount
     */
    function repayment(
        uint256 _contractId,
        uint256 _paidPenaltyAmount,
        uint256 _paidInterestAmount,
        uint256 _paidLoanAmount,
        uint256 _UID
    ) external;

    function collateralRiskLiquidationExecution(
        uint256 _contractId,
        uint256 _collateralPerRepaymentTokenExchangeRate,
        uint256 _collateralPerLoanAssetExchangeRate
    ) external;

    function lateLiquidationExecution(uint256 _contractId) external;

    function notPaidFullAtEndContractLiquidation(uint256 _contractId) external;

    function getContractInfoForReview(uint256 _contractId) 
        external
        view
        returns (
            address borrower,
            address lender,
            ContractStatus status
        );
}

// : MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// : MIT

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


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"./IERC165Upgradeable.sol";
//import"../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


// : MIT

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
interface IERC165Upgradeable {
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

pragma solidity ^0.8.2;

//import"../beacon/IBeaconUpgradeable.sol";
//import"../../utils/AddressUpgradeable.sol";
//import"../../utils/StorageSlotUpgradeable.sol";
//import"../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
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
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
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
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            _functionDelegateCall(
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
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}


// : MIT

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
library StorageSlotUpgradeable {
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


// : MIT

pragma solidity ^0.8.4;

//import"./PawnLib.sol";

interface IPawnV2 {

    /** General functions */

    function emergencyWithdraw(address _token) external;
}

// : MIT

pragma solidity ^0.8.4;

//import"@openzeppelin/contracts/access/Ownable.sol";
//import"@openzeppelin/contracts/security/Pausable.sol";
//import"@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import"@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
//import"./IPawn.sol";
//import"../reputation/IReputation.sol";
//import"../exchange/Exchange.sol";
//import"../pawn-p2p-v2/ILoan.sol";

contract PawnContract is IPawn, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CollateralLib for Collateral;
    using OfferLib for Offer;
    using PawnPackageLib for PawnShopPackage;

    mapping(address => uint256) public whitelistCollateral;
    address public operator;
    address public feeWallet = address(this);
    uint256 public penaltyRate;
    uint256 public systemFeeRate;
    uint256 public lateThreshold;
    uint256 public prepaidFeeRate;
    uint256 public ZOOM;
    bool public initialized = false;
    address public admin;

    /**
     * @dev initialize function
     * @param _zoom is coefficient used to represent risk params
     */

    function initialize(uint256 _zoom) external notInitialized {
        ZOOM = _zoom;
        initialized = true;
        admin = address(msg.sender);
    }

    function setOperator(address _newOperator) external onlyAdmin {
        operator = _newOperator;
    }

    function setFeeWallet(address _newFeeWallet) external onlyAdmin {
        feeWallet = _newFeeWallet;
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unPause() external onlyAdmin {
        _unpause();
    }

    /**
     * @dev set fee for each token
     * @param _feeRate is percentage of tokens to pay for the transaction
     */

    function setSystemFeeRate(uint256 _feeRate) external onlyAdmin {
        systemFeeRate = _feeRate;
    }

    /**
     * @dev set fee for each token
     * @param _feeRate is percentage of tokens to pay for the penalty
     */
    function setPenaltyRate(uint256 _feeRate) external onlyAdmin {
        penaltyRate = _feeRate;
    }

    /**
     * @dev set fee for each token
     * @param _threshold is number of time allowed for late repayment
     */
    function setLateThreshold(uint256 _threshold) external onlyAdmin {
        lateThreshold = _threshold;
    }

    function setPrepaidFeeRate(uint256 _feeRate) external onlyAdmin {
        prepaidFeeRate = _feeRate;
    }

    function setWhitelistCollateral(address _token, uint256 _status)
        external
        onlyAdmin
    {
        whitelistCollateral[_token] = _status;
    }

    modifier notInitialized() {
        require(!initialized, "-2"); //initialized
        _;
    }

    modifier isInitialized() {
        require(initialized, "-3"); //not-initialized
        _;
    }

    function _onlyOperator() private view {
        require(operator == msg.sender, "-0"); //operator
    }

    modifier onlyOperator() {
        // require(operator == msg.sender, "operator");
        _onlyOperator();
        _;
    }

    function _onlyAdmin() private view {
        require(admin == msg.sender, "-1"); //admin
    }

    modifier onlyAdmin() {
        // require(admin == msg.sender, "admin");
        _onlyAdmin();
        _;
    }

    function _whenNotPaused() private view {
        require(!paused(), "-4"); //Pausable: paused
    }

    modifier whenContractNotPaused() {
        // require(!paused(), "Pausable: paused");
        _whenNotPaused();
        _;
    }

    function emergencyWithdraw(address _token)
        external
        override
        onlyAdmin
        whenPaused
    {
        PawnLib.safeTransfer(
            _token,
            address(this),
            admin,
            PawnLib.calculateAmount(_token, address(this))
        );
    }

    /** ========================= COLLATERAL FUNCTIONS & STATES ============================= */
    uint256 public numberCollaterals;
    mapping(uint256 => Collateral) public collaterals;

    event CreateCollateralEvent(uint256 collateralId, Collateral data);

    event WithdrawCollateralEvent(
        uint256 collateralId,
        address collateralOwner
    );

    /**
     * @dev create Collateral function, collateral will be stored in this contract
     * @param _collateralAddress is address of collateral
     * @param _packageId is id of pawn shop package
     * @param _amount is amount of token
     * @param _loanAsset is address of loan token
     * @param _expectedDurationQty is expected duration
     * @param _expectedDurationType is expected duration type
     */
    function createCollateral(
        address _collateralAddress,
        int256 _packageId,
        uint256 _amount,
        address _loanAsset,
        uint256 _expectedDurationQty,
        LoanDurationType _expectedDurationType
    ) external payable whenContractNotPaused returns (uint256 _idx) {
        //check whitelist collateral token
        require(whitelistCollateral[_collateralAddress] == 1, "0"); //n-sup-col
        //validate: cannot use BNB as loanAsset
        require(_loanAsset != address(0), "1"); //bnb

        //id of collateral
        _idx = numberCollaterals;

        //create new collateral
        Collateral storage newCollateral = collaterals[_idx];

        newCollateral.create(
            _collateralAddress,
            _amount,
            _loanAsset,
            _expectedDurationQty,
            _expectedDurationType
        );

        ++numberCollaterals;

        emit CreateCollateralEvent(_idx, newCollateral);

        // transfer to this contract
        PawnLib.safeTransfer(
            _collateralAddress,
            msg.sender,
            address(this),
            _amount
        );

        if (_packageId >= 0) {
            //Package must active
            PawnShopPackage storage pawnShopPackage = pawnShopPackages[
                uint256(_packageId)
            ];
            require(
                pawnShopPackage.status == PawnShopPackageStatus.ACTIVE,
                "2"
            ); //pack

            // _submitCollateralToPackage(_idx, uint256(_packageId));

            // Submit collateral to package
            CollateralAsLoanRequestListStruct
                storage loanRequestListStruct = collateralAsLoanRequestMapping[
                    _idx
                ];

            newCollateral.submitToLoanPackage(
                uint256(_packageId),
                loanRequestListStruct
            );

            emit SubmitPawnShopPackage(
                uint256(_packageId),
                _idx,
                LoanRequestStatus.PENDING
            );

            createContractForAutoPawnPackage(
                _idx,
                uint256(_packageId),
                newCollateral,
                pawnShopPackage
            );
        }

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.BR_CREATE_COLLATERAL
        );
    }

    function createContractForAutoPawnPackage(
        uint256 _collateralId,
        uint256 _packageId,
        Collateral storage _collateral,
        PawnShopPackage storage _pawnShopPackage
    ) internal {
        if (_pawnShopPackage.packageType == PawnShopPackageType.AUTO) {
            // Check if lender has enough balance and allowance for lending
            (bool sufficientBalance, ) = pawnLoanContract.checkLenderAccount(
                _collateral.collateralAddress,
                _collateral.amount,
                _pawnShopPackage.loanToValue,
                _pawnShopPackage.loanToken,
                _pawnShopPackage.repaymentAsset,
                _pawnShopPackage.owner,
                address(this)
            );

            // PawnLib.checkLenderAccount(loanAmount, pawnShopPackage.loanToken, pawnShopPackage.owner, address(this));

            // Lender has sufficient balance and allowance => process submitted collateral to contract
            if (sufficientBalance) {
                processLoanRequestToContract(_collateralId, _packageId);
            }
        }
    }

    /**
     * @dev cancel collateral function and return back collateral
     * @param  _collateralId is id of collateral
     */
    function withdrawCollateral(uint256 _collateralId)
        external
        whenContractNotPaused
    {
        Collateral storage collateral = collaterals[_collateralId];
        require(collateral.owner == msg.sender, "0"); //owner
        require(collateral.status == CollateralStatus.OPEN, "1"); //col

        PawnLib.safeTransfer(
            collateral.collateralAddress,
            address(this),
            collateral.owner,
            collateral.amount
        );

        // Remove relation of collateral and offers
        CollateralOfferList
            storage collateralOfferList = collateralOffersMapping[
                _collateralId
            ];
        if (collateralOfferList.isInit == true) {
            for (
                uint256 i = 0;
                i < collateralOfferList.offerIdList.length;
                i++
            ) {
                uint256 offerId = collateralOfferList.offerIdList[i];
                Offer storage offer = collateralOfferList.offerMapping[offerId];
                emit CancelOfferEvent(offerId, _collateralId, offer.owner);
            }
            delete collateralOffersMapping[_collateralId];
        }

        delete collaterals[_collateralId];
        emit WithdrawCollateralEvent(_collateralId, msg.sender);

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.BR_CANCEL_COLLATERAL
        );
    }

    function _isValidCaller() private view {
        require(
            msg.sender == address(pawnLoanContract) ||
                msg.sender == operator ||
                msg.sender == admin,
            "0"
        ); // caller not allowed
    }

    function _validateCollateral(uint256 _collateralId)
        private
        view
        returns (Collateral storage collateral)
    {
        collateral = collaterals[_collateralId];
        require(collateral.status == CollateralStatus.DOING, "1"); // invalid collateral
    }

    function updateCollateralStatus(
        uint256 _collateralId,
        CollateralStatus _status
    ) external override whenContractNotPaused {
        _isValidCaller();
        Collateral storage collateral = _validateCollateral(_collateralId);

        collateral.status = _status;
    }

    function updateCollateralAmount(uint256 _collateralId, uint256 _amount)
        external
        override
        whenContractNotPaused
    {
        _isValidCaller();
        Collateral storage collateral = _validateCollateral(_collateralId);

        collateral.amount += _amount;
    }

    /** ========================= OFFER FUNCTIONS & STATES ============================= */
    uint256 public numberOffers;

    mapping(uint256 => CollateralOfferList) public collateralOffersMapping;

    event CreateOfferEvent(uint256 offerId, uint256 collateralId, Offer data);

    event CancelOfferEvent(
        uint256 offerId,
        uint256 collateralId,
        address offerOwner
    );

    /**
     * @dev create Collateral function, collateral will be stored in this contract
     * @param _collateralId is id of collateral
     * @param _repaymentAsset is address of repayment token
     * @param _duration is duration of this offer
     * @param _loanDurationType is type for calculating loan duration
     * @param _repaymentCycleType is type for calculating repayment cycle
     * @param _liquidityThreshold is ratio of assets to be liquidated
     */
    function createOffer(
        uint256 _collateralId,
        address _repaymentAsset,
        uint256 _loanAmount,
        uint256 _duration,
        uint256 _interest,
        uint8 _loanDurationType,
        uint8 _repaymentCycleType,
        uint256 _liquidityThreshold
    ) external whenContractNotPaused returns (uint256 _idx) {
        Collateral storage collateral = collaterals[_collateralId];

        require(collateral.status == CollateralStatus.OPEN, "0"); // col
        // validate not allow for collateral owner to create offer
        require(collateral.owner != msg.sender, "1"); // owner
        // Validate ower already approve for this contract to withdraw
        require(
            IERC20Upgradeable(collateral.loanAsset).allowance(
                msg.sender,
                address(this)
            ) >= _loanAmount,
            "2"
        ); // not-apr

        // Get offers of collateral
        CollateralOfferList
            storage collateralOfferList = collateralOffersMapping[
                _collateralId
            ];
        if (!collateralOfferList.isInit) {
            collateralOfferList.isInit = true;
        }
        // Create offer id
        _idx = numberOffers;

        // Create offer data
        Offer storage _offer = collateralOfferList.offerMapping[_idx];

        _offer.create(
            _repaymentAsset,
            _loanAmount,
            _duration,
            _interest,
            _loanDurationType,
            _repaymentCycleType,
            _liquidityThreshold
        );

        collateralOfferList.offerIdList.push(_idx);

        ++numberOffers;

        emit CreateOfferEvent(_idx, _collateralId, _offer);

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.LD_CREATE_OFFER
        );
    }

    /**
     * @dev cancel offer function, used for cancel offer
     * @param  _offerId is id of offer
     * @param _collateralId is id of collateral associated with offer
     */
    function cancelOffer(uint256 _offerId, uint256 _collateralId)
        external
        whenContractNotPaused
    {
        CollateralOfferList
            storage collateralOfferList = collateralOffersMapping[
                _collateralId
            ];
        require(collateralOfferList.isInit == true, "0"); // col
        // Lấy thông tin collateral
        // Collateral storage collateral = collaterals[_collateralId];
        Offer storage offer = collateralOfferList.offerMapping[_offerId];

        address offerOwner = offer.owner;

        offer.cancel(_offerId, collaterals[_collateralId].owner, collateralOfferList);

        // kiểm tra người gọi hàm -> rẽ nhánh event
        // neu nguoi goi la owner cua collateral  => reject offer.

        if (msg.sender == collaterals[_collateralId].owner) {
            emit CancelOfferEvent(_offerId, _collateralId, offerOwner);
        }

        // neu nguoi goi la owner cua offer thi canel offer
        if (msg.sender == offerOwner) {
            emit CancelOfferEvent(_offerId, _collateralId, msg.sender);

            // Adjust reputation score
            reputation.adjustReputationScore(
                msg.sender,
                IReputation.ReasonType.LD_CANCEL_OFFER
            );
        }
    }

    /** ========================= PAWNSHOP PACKAGE FUNCTIONS & STATES ============================= */
    uint256 public numberPawnShopPackages;
    mapping(uint256 => PawnShopPackage) public pawnShopPackages;

    event CreatePawnShopPackage(uint256 packageId, PawnShopPackage data);

    event ChangeStatusPawnShopPackage(
        uint256 packageId,
        PawnShopPackageStatus status
    );

    function createPawnShopPackage(
        PawnShopPackageType _packageType,
        address _loanToken,
        Range calldata _loanAmountRange,
        address[] calldata _collateralAcceptance,
        uint256 _interest,
        uint256 _durationType,
        Range calldata _durationRange,
        address _repaymentAsset,
        LoanDurationType _repaymentCycleType,
        uint256 _loanToValue,
        uint256 _loanToValueLiquidationThreshold
    ) external whenContractNotPaused returns (uint256 _idx) {
        _idx = numberPawnShopPackages;

        // Validataion logic: whitelist collateral, ranges must have upper greater than lower, duration type
        for (uint256 i = 0; i < _collateralAcceptance.length; i++) {
            require(whitelistCollateral[_collateralAcceptance[i]] == 1, "0"); // col
        }

        require(_loanAmountRange.lowerBound < _loanAmountRange.upperBound, "1"); // loan-rge
        require(_durationRange.lowerBound < _durationRange.upperBound, "2"); // dur-rge
        require(_durationType < 2, "3"); // dur-type

        require(_loanToken != address(0), "4"); // bnb

        //create new collateral
        PawnShopPackage storage newPackage = pawnShopPackages[_idx];

        newPackage.create(
            _packageType,
            _loanToken,
            _loanAmountRange,
            _collateralAcceptance,
            _interest,
            _durationType,
            _durationRange,
            _repaymentAsset,
            _repaymentCycleType,
            _loanToValue,
            _loanToValueLiquidationThreshold
        );

        ++numberPawnShopPackages;
        emit CreatePawnShopPackage(_idx, newPackage);

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.LD_CREATE_PACKAGE
        );
    }

    function activePawnShopPackage(uint256 _packageId)
        external
        whenContractNotPaused
    {
        PawnShopPackage storage pawnShopPackage = pawnShopPackages[_packageId];
        require(pawnShopPackage.owner == msg.sender, "0"); // owner
        require(pawnShopPackage.status == PawnShopPackageStatus.INACTIVE, "1"); // pack

        pawnShopPackage.status = PawnShopPackageStatus.ACTIVE;
        emit ChangeStatusPawnShopPackage(
            _packageId,
            PawnShopPackageStatus.ACTIVE
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.LD_REOPEN_PACKAGE
        );
    }

    function deactivePawnShopPackage(uint256 _packageId)
        external
        whenContractNotPaused
    {
        PawnShopPackage storage pawnShopPackage = pawnShopPackages[_packageId];

        // Deactivate package
        require(pawnShopPackage.owner == msg.sender, "0"); // owner
        require(pawnShopPackage.status == PawnShopPackageStatus.ACTIVE, "1"); // pack

        pawnShopPackage.status = PawnShopPackageStatus.INACTIVE;
        emit ChangeStatusPawnShopPackage(
            _packageId,
            PawnShopPackageStatus.INACTIVE
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.LD_CANCEL_PACKAGE
        );
    }

    /** ========================= SUBMIT & ACCEPT WORKFLOW OF PAWNSHOP PACKAGE FUNCTIONS & STATES ============================= */

    mapping(uint256 => CollateralAsLoanRequestListStruct)
        public collateralAsLoanRequestMapping; // Map from collateral to loan request
    event SubmitPawnShopPackage(
        uint256 packageId,
        uint256 collateralId,
        LoanRequestStatus status
    );

    /**
     * @dev Submit Collateral to Package function, collateral will be submit to pawnshop package
     * @param _collateralId is id of collateral
     * @param _packageId is id of pawn shop package
     */
    function submitCollateralToPackage(
        uint256 _collateralId,
        uint256 _packageId
    ) external whenContractNotPaused {
        Collateral storage collateral = collaterals[_collateralId];
        require(collateral.owner == msg.sender, "0"); // owner
        require(collateral.status == CollateralStatus.OPEN, "1"); // col

        PawnShopPackage storage pawnShopPackage = pawnShopPackages[_packageId];
        require(pawnShopPackage.status == PawnShopPackageStatus.ACTIVE, "2"); // pack

        // VALIDATE HAVEN'T SUBMIT TO PACKAGE YET
        CollateralAsLoanRequestListStruct
            storage loanRequestListStruct = collateralAsLoanRequestMapping[
                _collateralId
            ];

        if (loanRequestListStruct.isInit == true) {
            LoanRequestStatusStruct storage statusStruct = loanRequestListStruct
                .loanRequestToPawnShopPackageMapping[_packageId];

            require(statusStruct.isInit == false, "3"); // subed
        }

        // Save
        collateral.submitToLoanPackage(_packageId, loanRequestListStruct);
        // _submitCollateralToPackage(_collateralId, _packageId);

        emit SubmitPawnShopPackage(
            _packageId,
            _collateralId,
            LoanRequestStatus.PENDING
        );

        createContractForAutoPawnPackage(
            _collateralId,
            _packageId,
            collateral,
            pawnShopPackage
        );
    }

    function withdrawCollateralFromPackage(
        uint256 _collateralId,
        uint256 _packageId
    ) external whenContractNotPaused {
        // Collateral must OPEN
        Collateral storage collateral = collaterals[_collateralId];
        require(collateral.status == CollateralStatus.OPEN, "0"); // col
        // Sender is collateral owner
        require(collateral.owner == msg.sender, "1"); // owner
        // collateral-package status must pending
        CollateralAsLoanRequestListStruct
            storage loanRequestListStruct = collateralAsLoanRequestMapping[
                _collateralId
            ];
        LoanRequestStatusStruct
            storage loanRequestStatus = loanRequestListStruct
                .loanRequestToPawnShopPackageMapping[_packageId];
        require(loanRequestStatus.status == LoanRequestStatus.PENDING, "2"); // col-pack

        // _removeCollateralFromPackage(_collateralId, _packageId);

        collateral.removeFromLoanPackage(_packageId, loanRequestListStruct);

        emit SubmitPawnShopPackage(
            _packageId,
            _collateralId,
            LoanRequestStatus.CANCEL
        );
    }

    function acceptCollateralOfPackage(
        uint256 _collateralId,
        uint256 _packageId
    ) external whenContractNotPaused {
        PawnShopPackage storage pawnShopPackage = pawnShopPackages[_packageId];

        // Check for owner of packageId
        require(
            pawnShopPackage.owner == msg.sender || msg.sender == operator,
            "0"
        ); // owner-or-oper

        processLoanRequestToContract(_collateralId, _packageId);
    }

    function rejectCollateralOfPackage(
        uint256 _collateralId,
        uint256 _packageId
    ) external whenContractNotPaused {
        (
            Collateral storage collateral,
            PawnShopPackage storage pawnShopPackage,
            CollateralAsLoanRequestListStruct storage loanRequestListStruct,

        ) = verifyCollateralPackageData(
                _collateralId,
                _packageId,
                CollateralStatus.OPEN,
                LoanRequestStatus.PENDING
            );
        require(pawnShopPackage.owner == msg.sender);

        // _removeCollateralFromPackage(_collateralId, _packageId);
        collateral.removeFromLoanPackage(_packageId, loanRequestListStruct);

        emit SubmitPawnShopPackage(
            _packageId,
            _collateralId,
            LoanRequestStatus.REJECTED
        );
    }

    function verifyCollateralPackageData(
        uint256 _collateralId,
        uint256 _packageId,
        CollateralStatus _requiredCollateralStatus,
        LoanRequestStatus _requiredLoanRequestStatus
    )
        internal
        view
        returns (
            Collateral storage collateral,
            PawnShopPackage storage pawnShopPackage,
            CollateralAsLoanRequestListStruct storage loanRequestListStruct,
            LoanRequestStatusStruct storage statusStruct
        )
    {
        collateral = collaterals[_collateralId];
        pawnShopPackage = pawnShopPackages[_packageId];
        loanRequestListStruct = collateralAsLoanRequestMapping[_collateralId];

        statusStruct = collateral.checkCondition(
            _packageId,
            pawnShopPackage,
            loanRequestListStruct,
            _requiredCollateralStatus,
            _requiredLoanRequestStatus
        );
    }

    function processLoanRequestToContract(
        uint256 _collateralId,
        uint256 _packageId
    ) internal whenContractNotPaused {
        (
            Collateral storage collateral,
            PawnShopPackage storage pawnShopPackage,
            CollateralAsLoanRequestListStruct storage loanRequestListStruct,
            LoanRequestStatusStruct storage statusStruct
        ) = verifyCollateralPackageData(
                _collateralId,
                _packageId,
                CollateralStatus.OPEN,
                LoanRequestStatus.PENDING
            );

        // Execute accept => change status of loan request to ACCEPTED, wait for system to generate contract
        // Update status of loan request between _collateralId and _packageId to Accepted
        statusStruct.status = LoanRequestStatus.ACCEPTED;
        collateral.status = CollateralStatus.DOING;

        // Remove status of loan request between _collateralId and other packageId then emit event Cancel
        for (
            uint256 i = 0;
            i < loanRequestListStruct.pawnShopPackageIdList.length;
            i++
        ) {
            uint256 packageId = loanRequestListStruct.pawnShopPackageIdList[i];
            if (packageId != _packageId) {
                // Remove status
                delete loanRequestListStruct
                    .loanRequestToPawnShopPackageMapping[packageId];
                emit SubmitPawnShopPackage(
                    packageId,
                    _collateralId,
                    LoanRequestStatus.CANCEL
                );
            }
        }
        delete loanRequestListStruct.pawnShopPackageIdList;
        loanRequestListStruct.pawnShopPackageIdList.push(_packageId);

        // Remove relation of collateral and offers
        CollateralOfferList
            storage collateralOfferList = collateralOffersMapping[
                _collateralId
            ];
        if (collateralOfferList.isInit == true) {
            for (
                uint256 i = 0;
                i < collateralOfferList.offerIdList.length;
                i++
            ) {
                uint256 offerId = collateralOfferList.offerIdList[i];
                Offer storage offer = collateralOfferList.offerMapping[offerId];
                emit CancelOfferEvent(offerId, _collateralId, offer.owner);
            }
            delete collateralOffersMapping[_collateralId];
        }

        emit SubmitPawnShopPackage(
            _packageId,
            _collateralId,
            LoanRequestStatus.ACCEPTED
        );

        // Generate loan contract
        // generateContractForCollateralAndPackage(_collateralId, _packageId);
        generateContract(
            _collateralId,
            _packageId,
            collateral,
            pawnShopPackage,
            statusStruct
        );
    }

    /** ========================= CONTRACT RELATED FUNCTIONS & STATES ============================= */
    uint256 public numberContracts;
    mapping(uint256 => Contract) public contracts;

    /** ================================ 1. ACCEPT OFFER (FOR P2P WORKFLOWS) ============================= */
    // Old LoanContractCreatedEvent

    event LoanContractCreatedEvent(
        address fromAddress,
        uint256 contractId,
        Contract data
    );

    /**
     * @dev accept offer and create contract between collateral and offer
     * @param  _collateralId is id of collateral
     * @param  _offerId is id of offer
     */
    function acceptOffer(uint256 _collateralId, uint256 _offerId)
        external
        whenContractNotPaused
    {
        Collateral storage collateral = collaterals[_collateralId];
        require(msg.sender == collateral.owner, "0"); // owner
        require(collateral.status == CollateralStatus.OPEN, "1"); // col

        CollateralOfferList
            storage collateralOfferList = collateralOffersMapping[
                _collateralId
            ];
        require(collateralOfferList.isInit == true, "2"); // col-off
        Offer storage offer = collateralOfferList.offerMapping[_offerId];
        require(offer.isInit == true, "3"); // not-sent
        require(offer.status == OfferStatus.PENDING, "4"); // unavail

        // Prepare contract raw data
        uint256 exchangeRate = exchange.exchangeRateofOffer(
            collateral.loanAsset,
            offer.repaymentAsset
        );
        ContractRawData memory contractData = ContractRawData(
            _collateralId,
            collateral.owner,
            collateral.loanAsset,
            collateral.collateralAddress,
            collateral.amount,
            -1,
            int256(_offerId),
            exchangeRate, /* Exchange rate */
            offer.loanAmount,
            offer.owner,
            offer.repaymentAsset,
            offer.interest,
            offer.loanDurationType,
            offer.liquidityThreshold,
            offer.duration
        );

        // Create Contract
        // uint256 contractId = pawnLoanContract.createContract(contractData);
        pawnLoanContract.createContract(contractData);

        // change status of offer and collateral
        offer.status = OfferStatus.ACCEPTED;
        collateral.status = CollateralStatus.DOING;

        // Cancel other offer sent to this collateral
        for (uint256 i = 0; i < collateralOfferList.offerIdList.length; i++) {
            uint256 thisOfferId = collateralOfferList.offerIdList[i];
            if (thisOfferId != _offerId) {
                Offer storage thisOffer = collateralOfferList.offerMapping[
                    thisOfferId
                ];
                emit CancelOfferEvent(i, _collateralId, thisOffer.owner);

                delete collateralOfferList.offerMapping[thisOfferId];
            }
        }
        delete collateralOfferList.offerIdList;
        collateralOfferList.offerIdList.push(_offerId);

        // transfer loan asset to collateral owner
        PawnLib.safeTransfer(
            collateral.loanAsset,
            offer.owner,
            collateral.owner,
            offer.loanAmount
        );

        // transfer collateral to LoanContract
        PawnLib.safeTransfer(
            collateral.collateralAddress,
            address(this),
            address(pawnLoanContract),
            collateral.amount
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            msg.sender,
            IReputation.ReasonType.BR_ACCEPT_OFFER
        );
        reputation.adjustReputationScore(
            offer.owner,
            IReputation.ReasonType.LD_ACCEPT_OFFER
        );
    }

    /** ================================ 2. ACCEPT COLLATERAL (FOR PAWNSHOP PACKAGE WORKFLOWS) ============================= */

    /**
     * @dev create contract between package and collateral
     * @param  _collateralId is id of collateral
     * @param  _packageId is id of package
     * @param  _collateral is the collateral being submitted to pawnshop package for creating loan request
     * @param  _pawnShopPackage is the pawnshop package where the collateral being sent to
     * @param  _statusStruct is the status object of the loan request generated when collateral is submitted to pawnshop package
     */
    function generateContract(
        uint256 _collateralId,
        uint256 _packageId,
        Collateral storage _collateral,
        PawnShopPackage storage _pawnShopPackage,
        LoanRequestStatusStruct storage _statusStruct
    ) internal whenContractNotPaused {
        (
            _collateral,
            _pawnShopPackage,
            ,
            _statusStruct
        ) = verifyCollateralPackageData(
            _collateralId,
            _packageId,
            CollateralStatus.DOING,
            LoanRequestStatus.ACCEPTED
        );

        // function tinh loanAmount va Exchange Rate trong contract Exchange.
        (uint256 loanAmount, uint256 exchangeRate) = exchange
            .calculateLoanAmountAndExchangeRate(_collateral, _pawnShopPackage);

        // Prepare contract raw data
        ContractRawData memory contractData = ContractRawData(
            _collateralId,
            _collateral.owner,
            _collateral.loanAsset,
            _collateral.collateralAddress,
            _collateral.amount,
            int256(_packageId),
            -1,
            exchangeRate,
            loanAmount,
            _pawnShopPackage.owner,
            _pawnShopPackage.repaymentAsset,
            _pawnShopPackage.interest,
            _pawnShopPackage.repaymentCycleType,
            _pawnShopPackage.loanToValueLiquidationThreshold,
            _collateral.expectedDurationQty
        );
        // Create Contract
        // uint256 contractId = pawnLoanContract.createContract(contractData);
        pawnLoanContract.createContract(contractData);

        // Change status of collateral loan request to package to CONTRACTED
        _statusStruct.status == LoanRequestStatus.CONTRACTED;
        emit SubmitPawnShopPackage(
            _packageId,
            _collateralId,
            LoanRequestStatus.CONTRACTED
        );

        // Transfer loan token from lender to borrower
        PawnLib.safeTransfer(
            _collateral.loanAsset,
            _pawnShopPackage.owner,
            _collateral.owner,
            loanAmount
        );

        // transfer collateral to LoanContract
        PawnLib.safeTransfer(
            _collateral.collateralAddress,
            address(this),
            address(pawnLoanContract),
            _collateral.amount
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            _pawnShopPackage.owner,
            IReputation.ReasonType.LD_GENERATE_CONTRACT
        );
    }

    /** ================================ 3. PAYMENT REQUEST & REPAYMENT WORKLOWS ============================= */
    /** ===================================== 3.1. PAYMENT REQUEST ============================= */
    mapping(uint256 => PaymentRequest[]) public contractPaymentRequestMapping;

    // Old PaymentRequestEvent
    event PaymentRequestEvent(uint256 contractId, PaymentRequest data);

    function closePaymentRequestAndStartNew(
        uint256 _contractId,
        uint256 _remainingLoan,
        uint256 _nextPhrasePenalty,
        uint256 _nextPhraseInterest,
        uint256 _dueDateTimestamp,
        PaymentRequestTypeEnum _paymentRequestType,
        bool _chargePrepaidFee
    ) external whenNotPaused onlyOperator {
        Contract storage currentContract = contractMustActive(_contractId);

        // Check if number of requests is 0 => create new requests, if not then update current request as LATE or COMPLETE and create new requests
        PaymentRequest[] storage requests = contractPaymentRequestMapping[
            _contractId
        ];
        if (requests.length > 0) {
            // not first phrase, get previous request
            PaymentRequest storage previousRequest = requests[
                requests.length - 1
            ];

            // Validate: time must over due date of current payment
            require(block.timestamp >= previousRequest.dueDateTimestamp, "0"); // time-not-due

            // Validate: remaining loan must valid
            require(previousRequest.remainingLoan == _remainingLoan, "1"); // remain

            // Validate: Due date timestamp of next payment request must not over contract due date
            require(
                _dueDateTimestamp <= currentContract.terms.contractEndDate,
                "2"
            ); // contr-end
            require(
                _dueDateTimestamp > previousRequest.dueDateTimestamp ||
                    _dueDateTimestamp == 0,
                "3"
            ); // less-th-prev

            // update previous
            // check for remaining penalty and interest, if greater than zero then is Lated, otherwise is completed
            if (
                previousRequest.remainingInterest > 0 ||
                previousRequest.remainingPenalty > 0
            ) {
                previousRequest.status = PaymentRequestStatusEnum.LATE;

                // Adjust reputation score
                reputation.adjustReputationScore(
                    currentContract.terms.borrower,
                    IReputation.ReasonType.BR_LATE_PAYMENT
                );

                // Update late counter of contract
                currentContract.lateCount += 1;

                // Check for late threshold reach
                if (
                    currentContract.terms.lateThreshold <=
                    currentContract.lateCount
                ) {
                    // Execute liquid
                    _liquidationExecution(
                        _contractId,
                        ContractLiquidedReasonType.LATE
                    );
                    return;
                }
            } else {
                previousRequest.status = PaymentRequestStatusEnum.COMPLETE;

                // Adjust reputation score
                reputation.adjustReputationScore(
                    currentContract.terms.borrower,
                    IReputation.ReasonType.BR_ONTIME_PAYMENT
                );
            }

            // Check for last repayment, if last repayment, all paid
            if (block.timestamp > currentContract.terms.contractEndDate) {
                if (
                    previousRequest.remainingInterest +
                        previousRequest.remainingPenalty +
                        previousRequest.remainingLoan >
                    0
                ) {
                    // unpaid => liquid
                    _liquidationExecution(
                        _contractId,
                        ContractLiquidedReasonType.UNPAID
                    );
                    return;
                } else {
                    // paid full => release collateral
                    _returnCollateralToBorrowerAndCloseContract(_contractId);
                    return;
                }
            }

            emit PaymentRequestEvent(_contractId, previousRequest);
        } else {
            // Validate: remaining loan must valid
            require(currentContract.terms.loanAmount == _remainingLoan, "4"); // remain

            // Validate: Due date timestamp of next payment request must not over contract due date
            require(
                _dueDateTimestamp <= currentContract.terms.contractEndDate,
                "5"
            ); // contr-end
            require(
                _dueDateTimestamp > currentContract.terms.contractStartDate ||
                    _dueDateTimestamp == 0,
                "6"
            ); // less-th-prev
            require(
                block.timestamp < _dueDateTimestamp || _dueDateTimestamp == 0,
                "7"
            ); // over

            // Check for last repayment, if last repayment, all paid
            if (block.timestamp > currentContract.terms.contractEndDate) {
                // paid full => release collateral
                _returnCollateralToBorrowerAndCloseContract(_contractId);
                return;
            }
        }

        // Create new payment request and store to contract
        PaymentRequest memory newRequest = PaymentRequest({
            requestId: requests.length,
            paymentRequestType: _paymentRequestType,
            remainingLoan: _remainingLoan,
            penalty: _nextPhrasePenalty,
            interest: _nextPhraseInterest,
            remainingPenalty: _nextPhrasePenalty,
            remainingInterest: _nextPhraseInterest,
            dueDateTimestamp: _dueDateTimestamp,
            status: PaymentRequestStatusEnum.ACTIVE,
            chargePrepaidFee: _chargePrepaidFee
        });
        requests.push(newRequest);
        emit PaymentRequestEvent(_contractId, newRequest);
    }

    /** ===================================== 3.2. REPAYMENT ============================= */

    event RepaymentEvent(
        uint256 contractId,
        uint256 paidPenaltyAmount,
        uint256 paidInterestAmount,
        uint256 paidLoanAmount,
        uint256 paidPenaltyFeeAmount,
        uint256 paidInterestFeeAmount,
        uint256 prepaidAmount,
        uint256 paymentRequestId,
        uint256 UID
    );

    /**
        End lend period settlement and generate invoice for next period
     */
    function repayment(
        uint256 _contractId,
        uint256 _paidPenaltyAmount,
        uint256 _paidInterestAmount,
        uint256 _paidLoanAmount,
        uint256 _UID
    ) external whenNotPaused {
        // Get contract & payment request
        Contract storage _contract = contractMustActive(_contractId);
        PaymentRequest[] storage requests = contractPaymentRequestMapping[
            _contractId
        ];
        require(requests.length > 0, "0");
        PaymentRequest storage _paymentRequest = requests[requests.length - 1];

        // Validation: Contract must not overdue
        require(block.timestamp <= _contract.terms.contractEndDate, "1"); // contr-over

        // Validation: current payment request must active and not over due
        require(_paymentRequest.status == PaymentRequestStatusEnum.ACTIVE, "2"); // not-act
        if (_paidPenaltyAmount + _paidInterestAmount > 0) {
            require(block.timestamp <= _paymentRequest.dueDateTimestamp, "3"); // over-due
        }

        // Calculate paid amount / remaining amount, if greater => get paid amount
        if (_paidPenaltyAmount > _paymentRequest.remainingPenalty) {
            _paidPenaltyAmount = _paymentRequest.remainingPenalty;
        }

        if (_paidInterestAmount > _paymentRequest.remainingInterest) {
            _paidInterestAmount = _paymentRequest.remainingInterest;
        }

        if (_paidLoanAmount > _paymentRequest.remainingLoan) {
            _paidLoanAmount = _paymentRequest.remainingLoan;
        }

        // Calculate fee amount based on paid amount
        uint256 _feePenalty = PawnLib.calculateSystemFee(
            _paidPenaltyAmount,
            _contract.terms.systemFeeRate,
            ZOOM
        );
        uint256 _feeInterest = PawnLib.calculateSystemFee(
            _paidInterestAmount,
            _contract.terms.systemFeeRate,
            ZOOM
        );

        uint256 _prepaidFee = 0;
        if (_paymentRequest.chargePrepaidFee) {
            _prepaidFee = PawnLib.calculateSystemFee(
                _paidLoanAmount,
                _contract.terms.prepaidFeeRate,
                ZOOM
            );
        }

        // Update paid amount on payment request
        _paymentRequest.remainingPenalty -= _paidPenaltyAmount;
        _paymentRequest.remainingInterest -= _paidInterestAmount;
        _paymentRequest.remainingLoan -= _paidLoanAmount;

        // emit event repayment
        emit RepaymentEvent(
            _contractId,
            _paidPenaltyAmount,
            _paidInterestAmount,
            _paidLoanAmount,
            _feePenalty,
            _feeInterest,
            _prepaidFee,
            _paymentRequest.requestId,
            _UID
        );

        // If remaining loan = 0 => paidoff => execute release collateral
        if (
            _paymentRequest.remainingLoan == 0 &&
            _paymentRequest.remainingPenalty == 0 &&
            _paymentRequest.remainingInterest == 0
        ) {
            _returnCollateralToBorrowerAndCloseContract(_contractId);
        }

        if (_paidPenaltyAmount + _paidInterestAmount > 0) {
            // Transfer fee to fee wallet
            PawnLib.safeTransfer(
                _contract.terms.repaymentAsset,
                msg.sender,
                feeWallet,
                _feePenalty + _feeInterest
            );

            // Transfer penalty and interest to lender except fee amount
            uint256 transferAmount = _paidPenaltyAmount +
                _paidInterestAmount -
                _feePenalty -
                _feeInterest;
            PawnLib.safeTransfer(
                _contract.terms.repaymentAsset,
                msg.sender,
                _contract.terms.lender,
                transferAmount
            );
        }

        if (_paidLoanAmount > 0) {
            // Transfer loan amount and prepaid fee to lender
            PawnLib.safeTransfer(
                _contract.terms.loanAsset,
                msg.sender,
                _contract.terms.lender,
                _paidLoanAmount + _prepaidFee
            );
        }
    }

    /** ===================================== 3.3. LIQUIDITY & DEFAULT ============================= */
    // enum ContractLiquidedReasonType { LATE, RISK, UNPAID }
    event ContractLiquidedEvent(
        uint256 contractId,
        uint256 liquidedAmount,
        uint256 feeAmount,
        ContractLiquidedReasonType reasonType
    );
    event LoanContractCompletedEvent(uint256 contractId);

    function collateralRiskLiquidationExecution(
        uint256 _contractId,
        uint256 _collateralPerRepaymentTokenExchangeRate,
        uint256 _collateralPerLoanAssetExchangeRate
    ) external whenNotPaused onlyOperator {
        // Validate: Contract must active
        Contract storage _contract = contractMustActive(_contractId);

        (
            uint256 remainingRepayment,
            uint256 remainingLoan
        ) = calculateRemainingLoanAndRepaymentFromContract(
                _contractId,
                _contract
            );
        uint256 valueOfRemainingRepayment = (_collateralPerRepaymentTokenExchangeRate *
                remainingRepayment) / ZOOM;
        uint256 valueOfRemainingLoan = (_collateralPerLoanAssetExchangeRate *
            remainingLoan) / ZOOM;
        uint256 valueOfCollateralLiquidationThreshold = (_contract
            .terms
            .collateralAmount * _contract.terms.liquidityThreshold) /
            (100 * ZOOM);

        require(
            valueOfRemainingLoan + valueOfRemainingRepayment >=
                valueOfCollateralLiquidationThreshold,
            "0"
        ); // under-thres

        // Execute: call internal liquidation
        _liquidationExecution(_contractId, ContractLiquidedReasonType.RISK);
    }

    function calculateRemainingLoanAndRepaymentFromContract(
        uint256 _contractId,
        Contract storage _contract
    )
        internal
        view
        returns (uint256 remainingRepayment, uint256 remainingLoan)
    {
        // Validate: sum of unpaid interest, penalty and remaining loan in value must reach liquidation threshold of collateral value
        PaymentRequest[] storage requests = contractPaymentRequestMapping[
            _contractId
        ];
        if (requests.length > 0) {
            // Have payment request
            PaymentRequest storage _paymentRequest = requests[
                requests.length - 1
            ];
            remainingRepayment =
                _paymentRequest.remainingInterest +
                _paymentRequest.remainingPenalty;
            remainingLoan = _paymentRequest.remainingLoan;
        } else {
            // Haven't had payment request
            remainingRepayment = 0;
            remainingLoan = _contract.terms.loanAmount;
        }
    }

    function lateLiquidationExecution(uint256 _contractId)
        external
        whenNotPaused
    {
        // Validate: Contract must active
        Contract storage _contract = contractMustActive(_contractId);

        // validate: contract have lateCount == lateThreshold
        require(_contract.lateCount >= _contract.terms.lateThreshold, "0"); // not-reach

        // Execute: call internal liquidation
        _liquidationExecution(_contractId, ContractLiquidedReasonType.LATE);
    }

    function contractMustActive(uint256 _contractId)
        internal
        view
        returns (Contract storage _contract)
    {
        // Validate: Contract must active
        _contract = contracts[_contractId];
        require(_contract.status == ContractStatus.ACTIVE, "0"); // contr-act
    }

    function notPaidFullAtEndContractLiquidation(uint256 _contractId)
        external
        whenNotPaused
    {
        Contract storage _contract = contractMustActive(_contractId);
        // validate: current is over contract end date
        require(block.timestamp >= _contract.terms.contractEndDate, "0"); // due

        // validate: remaining loan, interest, penalty haven't paid in full
        (
            uint256 remainingRepayment,
            uint256 remainingLoan
        ) = calculateRemainingLoanAndRepaymentFromContract(
                _contractId,
                _contract
            );
        require(remainingRepayment + remainingLoan > 0, "1"); // paid

        // Execute: call internal liquidation
        _liquidationExecution(_contractId, ContractLiquidedReasonType.UNPAID);
    }

    function _liquidationExecution(
        uint256 _contractId,
        ContractLiquidedReasonType _reasonType
    ) internal {
        Contract storage _contract = contracts[_contractId];

        // Execute: calculate system fee of collateral and transfer collateral except system fee amount to lender
        uint256 _systemFeeAmount = PawnLib.calculateSystemFee(
            _contract.terms.collateralAmount,
            _contract.terms.systemFeeRate,
            ZOOM
        );
        uint256 _liquidAmount = _contract.terms.collateralAmount -
            _systemFeeAmount;

        // Execute: update status of contract to DEFAULT, collateral to COMPLETE
        _contract.status = ContractStatus.DEFAULT;
        PaymentRequest[]
            storage _paymentRequests = contractPaymentRequestMapping[
                _contractId
            ];
        PaymentRequest storage _lastPaymentRequest = _paymentRequests[
            _paymentRequests.length - 1
        ];
        _lastPaymentRequest.status = PaymentRequestStatusEnum.DEFAULT;
        Collateral storage _collateral = collaterals[_contract.collateralId];
        _collateral.status = CollateralStatus.COMPLETED;

        // Emit Event ContractLiquidedEvent & PaymentRequest event
        emit ContractLiquidedEvent(
            _contractId,
            _liquidAmount,
            _systemFeeAmount,
            _reasonType
        );

        emit PaymentRequestEvent(_contractId, _lastPaymentRequest);

        // Transfer to lender liquid amount
        PawnLib.safeTransfer(
            _contract.terms.collateralAsset,
            address(this),
            _contract.terms.lender,
            _liquidAmount
        );

        // Transfer to system fee wallet fee amount
        PawnLib.safeTransfer(
            _contract.terms.collateralAsset,
            address(this),
            feeWallet,
            _systemFeeAmount
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            _contract.terms.borrower,
            IReputation.ReasonType.BR_LATE_PAYMENT
        );
        reputation.adjustReputationScore(
            _contract.terms.borrower,
            IReputation.ReasonType.BR_CONTRACT_DEFAULTED
        );
    }

    function _returnCollateralToBorrowerAndCloseContract(uint256 _contractId)
        internal
    {
        Contract storage _contract = contracts[_contractId];

        // Execute: Update status of contract to COMPLETE, collateral to COMPLETE
        _contract.status = ContractStatus.COMPLETED;
        PaymentRequest[]
            storage _paymentRequests = contractPaymentRequestMapping[
                _contractId
            ];
        PaymentRequest storage _lastPaymentRequest = _paymentRequests[
            _paymentRequests.length - 1
        ];
        _lastPaymentRequest.status = PaymentRequestStatusEnum.COMPLETE;
        Collateral storage _collateral = collaterals[_contract.collateralId];
        _collateral.status = CollateralStatus.COMPLETED;

        // Emit event ContractCompleted
        emit LoanContractCompletedEvent(_contractId);
        emit PaymentRequestEvent(_contractId, _lastPaymentRequest);

        // Execute: Transfer collateral to borrower
        PawnLib.safeTransfer(
            _contract.terms.collateralAsset,
            address(this),
            _contract.terms.borrower,
            _contract.terms.collateralAmount
        );

        // Adjust reputation score
        reputation.adjustReputationScore(
            _contract.terms.borrower,
            IReputation.ReasonType.BR_ONTIME_PAYMENT
        );
        reputation.adjustReputationScore(
            _contract.terms.borrower,
            IReputation.ReasonType.BR_CONTRACT_COMPLETE
        );
    }

    function releaseTrappedCollateralLockedWithoutContract(
        uint256 _collateralId,
        uint256 _packageId
    ) external onlyAdmin {
        // Validate: Collateral must Doing
        Collateral storage collateral = collaterals[_collateralId];
        require(collateral.status == CollateralStatus.DOING, "0"); // col

        // Check for collateral not being in any contract
        for (uint256 i = 0; i < numberContracts - 1; i++) {
            Contract storage mContract = contracts[i];
            require(mContract.collateralId != _collateralId, "1"); // col-in-cont
        }

        // Check for collateral-package status is ACCEPTED
        CollateralAsLoanRequestListStruct
            storage loanRequestListStruct = collateralAsLoanRequestMapping[
                _collateralId
            ];
        require(loanRequestListStruct.isInit == true, "2"); // col-loan-req
        LoanRequestStatusStruct storage statusStruct = loanRequestListStruct
            .loanRequestToPawnShopPackageMapping[_packageId];
        require(statusStruct.isInit == true, "3"); // col-loan-req-pack
        require(statusStruct.status == LoanRequestStatus.ACCEPTED, "4"); // not-acpt

        // Update status of loan request
        statusStruct.status = LoanRequestStatus.PENDING;
        collateral.status = CollateralStatus.OPEN;
    }

    /** ===================================== CONTRACT ADMIN ============================= */

    event AdminChanged(address _from, address _to);

    function changeAdmin(address newAddress) external onlyAdmin {
        address oldAdmin = admin;
        admin = newAddress;

        emit AdminChanged(oldAdmin, newAddress);
    }

    /** ===================================== REPUTATION FUNCTIONS & STATES ===================================== */

    IReputation public reputation;

    function setReputationContract(address _reputationAddress)
        external
        onlyAdmin
    {
        reputation = IReputation(_reputationAddress);
    }

    /** ==================== Exchange functions & states ==================== */
    Exchange public exchange;

    function setExchangeContract(address _exchangeAddress) external onlyAdmin {
        exchange = Exchange(_exchangeAddress);
    }

    /** ==================== Loan Contract functions & states ==================== */
    ILoan public pawnLoanContract;

    function setPawnLoanContract(address _pawnLoanAddress) external onlyAdmin {
        pawnLoanContract = ILoan(_pawnLoanAddress);
    }

    /** ==================== User-reviews related functions ==================== */
    function getContractInfoForReview(uint256 _contractId) 
        external 
        override
        view
        returns (
            address borrower,
            address lender,
            ContractStatus status
        )
    {
        Contract storage _contract = contracts[_contractId];
        borrower = _contract.terms.borrower;
        lender = _contract.terms.lender;
        status = _contract.status;
    }
}


