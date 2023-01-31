// : BSD-3-Clause

pragma solidity ^0.8.10;

contract PlanetStorage {
    
    address public gGammaAddress = 0xF701A48e5C751A213b7c540F84B64b5A6109962E;
    address public gammatroller = 0xF54f9e7070A1584532572A6F640F09c606bb9A83;
    address public oracle = 0x29E0ac200dB8CdE15D15356FFcdCb72b13F7bC34;
    
    address public admin;
    
    uint256 public level0Discount = 0;
    uint256 public level1Discount = 500;
    uint256 public level2Discount = 2000;
    uint256 public level3Discount = 5000;
   
    uint256 public level1Min = 100;
    uint256 public level2Min = 500;
    uint256 public level3Min = 1000;
    
    
    /**
     * @notice Total amount of underlying discount given
     */
    mapping(address => uint) public totalDiscountGiven;
    
    mapping(address => bool) public deprecatedMarket;
    
    mapping(address => bool) public isMarketListed;
    
    address[] public deprecatedMarketArr;
    
    /*
     * @notice Array of users which have some supply balnce in market
     */
    mapping(address => address[]) public usersWhoHaveSupply;
    
    
    /*
     * @notice Official record of each user whether the user is present in profitGetters or not
     */
    mapping(address => mapping(address => supplyDiscountSnapshot)) public supplyDiscountSnap;
    
    
    /*
     * @notice Official record of each user whether the user is present in discountGetters or not
     */
    mapping(address => mapping(address => BorrowDiscountSnapshot)) public borrowDiscountSnap;
    
    /**
     * @notice Container for Discount information
     * @member exist (whether user is present in Profit scheme)
     * @member index (user address index in array of usersWhoHaveBorrow)
     * @member lastExchangeRateAtSupply(the last exchange rate at which profit is given to user)
     * @member lastUpdated(timestamp at which it is updated last time)
     */
    struct supplyDiscountSnapshot {
        bool exist;
        uint index;
        uint lastExchangeRateAtSupply;
        uint lastUpdated;
    }
    
    struct ReturnBorrowDiscountLocalVars {
        uint marketTokenSupplied;
    }
    
    mapping(address => address[]) public usersWhoHaveBorrow;

    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    
    /**
     * @notice Container for Discount information
     * @member exist (whether user is present in Discount scheme)
     * @member index (user address index in array of usersWhoHaveBorrow)
     * @member lastRepayAmountDiscountGiven(the last repay amount at which discount is given to user)
     * @member accTotalDiscount(total discount accumulated to the user)
     * @member lastUpdated(timestamp at which it is updated last time)
     */
    struct BorrowDiscountSnapshot {
        bool exist;
        uint index;
        uint lastBorrowAmountDiscountGiven;
        uint accTotalDiscount;
        uint lastUpdated;
    }

    
   /**
    * @notice Event emitted when discount is changed for user
    */
    event SupplyDiscountAccrued(address market,address supplier,uint discountGiven,uint lastUpdated);
    
   /**
    * @notice Event emitted when discount is changed for user
    */
    event BorrowDiscountAccrued(address market,address borrower,uint discountGiven,uint lastUpdated);
     
    event gGammaAddressChange(address prevgGammaAddress,address newgGammaAddress);
    
    event gammatrollerChange(address prevGammatroller,address newGammatroller);
    
    event oracleChanged(address prevOracle,address newOracle);
    
}

contract PlanetStoragev1 is PlanetStorage {

    address public implementation;

    address public infinityVault;

    event InfinityVaultChanged(address oldInfinityVault,address newInfinityVault);

}

contract PlanetDelegationStorage {
    /**
     * @notice Implementation address for this contract
     */
    address public implementation;
}

abstract contract PlanetDelegatorInterface is PlanetDelegationStorage {
    /**
     * @notice Emitted when implementation is changed
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) virtual public;
}

contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

contract CarefulMath {

    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
    * @dev Multiplies two numbers, returns an error on overflow.
    */
    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
    * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
    */
    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
    * @dev Adds two numbers, returns an error on overflow.
    */
    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
    * @dev add a and b and then subtract c
    */
    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

contract Exponential is CarefulMath, ExponentialNoError {
    /**
     * @dev Creates an exponential from numerator and denominator values.
     *      Note: Returns an error if (`num` * 10e18) > MAX_INT,
     *            or if `denom` is zero.
     */
    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    /**
     * @dev Adds two exponentials, returning a new exponential.
     */
    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Subtracts two exponentials, returning a new exponential.
     */
    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    /**
     * @dev Multiply an Exp by a scalar, returning a new Exp.
     */
    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {
        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    /**
     * @dev Divide an Exp by a scalar, returning a new Exp.
     */
    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {
        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    /**
     * @dev Divide a scalar by an Exp, returning a new Exp.
     */
    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {
        /*
          We are doing this as:
          getExp(mulUInt(expScale, scalar), divisor.mantissa)

          How it works:
          Exp = a / b;
          Scalar = s;
          `s / (a / b)` = `b * s / a` and since for an Exp `a = mantissa, b = expScale`
        */
        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    /**
     * @dev Divide a scalar by an Exp, then truncate to return an unsigned integer.
     */
    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {
        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    /**
     * @dev Multiplies two exponentials, returning a new exponential.
     */
    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        // We add half the scale before dividing so that we get rounding instead of truncation.
        //  See "Listing 6" and text above it at https://accu.org/index.php/journals/1717
        // Without this change, a result like 6.6...e-19 will be truncated to 0 instead of being rounded to 1e-18.
        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        // The only error `div` can return is MathError.DIVISION_BY_ZERO but we control `expScale` and it is not zero.
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    /**
     * @dev Multiplies two exponentials given their mantissas, returning a new exponential.
     */
    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {
        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    /**
     * @dev Multiplies three exponentials, returning a new exponential.
     */
    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {
        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    /**
     * @dev Divides two exponentials, returning a new exponential.
     *     (a/scale) / (b/scale) = (a/scale) * (scale/b) = a/b,
     *  which we can scale as an Exp by calling getExp(a.mantissa, b.mantissa)
     */
    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {
        return getExp(a.mantissa, b.mantissa);
    }
}

interface PriceOracle {
    /**
      * @notice Get the underlying price of a gToken asset
      * @param gToken The gToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(GToken gToken) external view returns (uint);
}

interface GammatrollerInterface {
   
    function getAllMarkets() external view returns(GToken[] memory);
}

interface GToken {
    
    function totalReserves() external view returns (uint256);
    
    function totalBorrows() external view returns (uint256);
    
    function borrowIndex() external view returns (uint256);

    /**
     * @notice Get a snapshot of the account's balances, and the cached exchange rate
     * @dev This is used by gammatroller to more efficiently perform liquidity checks.
     * @param account Address of the account to snapshot
     * @return (possible error, token balance, borrow balance, exchange rate mantissa)
     */
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return The calculated balance
     */
    function borrowBalanceStored(address account) external view returns (uint);

    
    /**
     * @notice Return the reserve factor of market based on stored data
     * @dev This function does not accrue interest before returning the reserve factor
     * @return reserve fcator scaled by 1e18
     */
    function reserveFactorMantissa() external view returns (uint);

}

interface InfinityVault {

    function getUserGtokenBal(address user) external view returns(uint);

}

contract PlanetDiscountDelegate is PlanetStoragev1,Exponential{
    
    function changeAddress(address _newgGammaAddress,address _newGammatroller,address _newOracle,address _newInfinityVault) public returns(bool){
        
        require(msg.sender == admin, "only admin can call");
        address _gGammaAddress = gGammaAddress;
        address _gammatroller = gammatroller;
        address _oracle = oracle;
        address _infinityVault = infinityVault;
        
        gGammaAddress = _newgGammaAddress;
        gammatroller = _newGammatroller;
        oracle = _newOracle;
        infinityVault = _newInfinityVault;
        
        emit gGammaAddressChange(_gGammaAddress,_newgGammaAddress);
        emit gammatrollerChange(_gammatroller,_newGammatroller);
        emit oracleChanged(_oracle,_newOracle);
        emit InfinityVaultChanged(_infinityVault,_newInfinityVault);
        return true;
    }
    
    function listMarket(address market) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       require(!isMarketListed[market],"market already listed");
       isMarketListed[market] = true;
       return true;
    }
    
    function listMarkets(address[] memory markets) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       for(uint i = 0 ; i < markets.length ; i++){
        address market = markets[i];
         require(!isMarketListed[market],"market already listed");
         isMarketListed[market] = true;
       }
       return true;
    }

    function deListMarket(address market) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       require(isMarketListed[market],"market already delisted");
       isMarketListed[market] = false;
       return true;
    }
    
    function deListMarkets(address[] memory markets) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       for(uint i = 0 ; i < markets.length ; i++){
        address market = markets[i];
         require(!isMarketListed[market],"market already delisted");
         isMarketListed[market] = false;
       }
       return true;
    }
    
    function returnBorrowerStakedAsset(address borrower,address market) public view returns(uint){
        
        address marketAddress = market;
        ReturnBorrowDiscountLocalVars memory vars;
        
        (,uint gTokenBalance,,uint exchangeRate) = GToken(marketAddress).getAccountSnapshot(borrower);
        
        if(gTokenBalance != 0){
            uint price = PriceOracle(oracle).getUnderlyingPrice(GToken(marketAddress));
        
            (, vars.marketTokenSupplied) = mulScalarTruncate(Exp({mantissa: gTokenBalance}), exchangeRate);
            (, uint256 marketTokenSuppliedInBnb) = mulScalarTruncate(Exp({mantissa: vars.marketTokenSupplied}), price);
        
            return (marketTokenSuppliedInBnb);
        }
        else{
            return 0;
        }
    }
   
    function returnDiscountPercentage(address borrower) public view returns(uint discount){
        
        //scaled upto 2 decimal like if 50% then output is 5000
       
        GToken[] memory userInMarkets = GammatrollerInterface(gammatroller).getAllMarkets();

        (,uint gTokenBalance,,uint exchangeRate) = GToken(gGammaAddress).getAccountSnapshot(borrower);
        uint price = PriceOracle(oracle).getUnderlyingPrice(GToken(gGammaAddress));
        
        gTokenBalance = gTokenBalance + InfinityVault(infinityVault).getUserGtokenBal(borrower);
        
        (,uint256 gammaStaked) = mulScalarTruncate(Exp({mantissa: gTokenBalance}), exchangeRate);
        (,gammaStaked) = mulScalarTruncate(Exp({mantissa: gammaStaked}), price);
        
        uint256 otherStaked = 0; 
        
        for(uint i = 0; i < userInMarkets.length ;i++){
            
            GToken _market = userInMarkets[i];
            
            if(isMarketListed[address(_market)]){
                
                otherStaked = otherStaked + returnBorrowerStakedAsset(borrower,address(_market));
            
            }
            
        }

        
        (, Exp memory _discount) = getExp(gammaStaked,otherStaked);
        (,_discount.mantissa) = mulUInt(_discount.mantissa,100);
        (, uint256 _scaledDiscount) = divUInt(_discount.mantissa,1e16);
        discount = _scaledDiscount;
        
        if(level1Min <= discount && discount < level2Min){
            discount = level1Discount;
        }
        else if(level2Min <= discount && discount < level3Min){
            discount = level2Discount;
        }
        else if(discount >= level3Min){
            discount = level3Discount;
        }
        else{
            discount = level0Discount;
        }
        
    }  
    
    function totalReservesAfterDiscount(address market) external view returns(uint res){
        res = GToken(market).totalReserves() - totalDiscountGiven[market];
    }
    
    /**
     * Borrow side
     */
    
    function changeLastBorrowAmountDiscountGiven(address borrower,uint borrowAmount) external returns(bool) {
        
        address market = msg.sender;
        
        require(isMarketListed[market],"Market not listed");
        
        BorrowDiscountSnapshot storage _borrowDis = borrowDiscountSnap[market][borrower];
        
        (_borrowDis.lastBorrowAmountDiscountGiven) = borrowAmount;
        
        _borrowDis.lastUpdated = block.timestamp;
        
        return true;
    }
    
    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrowsNew;
        uint interest;
        uint newDiscount;
    }
    
    function changeUserBorrowDiscount(address borrower) external returns(uint,uint,uint){
        
        address _market = msg.sender;
        
        require(isMarketListed[_market],"Market not listed");
        
        GToken market = GToken(_market);
        
        BorrowLocalVars memory vars;
        
        BorrowDiscountSnapshot storage _dis = borrowDiscountSnap[_market][borrower];
        
        uint discount = returnDiscountPercentage(borrower); // 5% => 500,20% => 2000 ,50% => 5000
        
        (uint currentBorrowBal) = market.borrowBalanceStored(borrower);
        
        if( _dis.exist && discount > 0) {
            
            //interest on principal
            vars.interest = currentBorrowBal - _dis.lastBorrowAmountDiscountGiven;
            
            //reserve factor of market
            (uint reserveFactor) = GToken(market).reserveFactorMantissa();
            
            //multiply reserve factor with interest borrower have to pay on principal
            (,uint valueOfGivenInterestGoToReserves) = 
             mulScalarTruncate(Exp({mantissa:vars.interest}),reserveFactor);

            //Applying discount percentage
            vars.newDiscount = discount*valueOfGivenInterestGoToReserves;
            
            vars.newDiscount = vars.newDiscount/10000;
            
            //update the borrow amount of borrower
            _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
            
            vars.accountBorrowsNew = currentBorrowBal - vars.newDiscount;
            
            totalDiscountGiven[_market] = totalDiscountGiven[_market] + vars.newDiscount;
         
            _dis.lastUpdated = block.timestamp; 
            
            emit BorrowDiscountAccrued(_market,borrower,vars.newDiscount,_dis.lastUpdated);
            
            return(vars.accountBorrowsNew,market.borrowIndex(),market.totalBorrows());
        }
        else {
            
            if(_dis.exist){
                
                _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
                _dis.lastUpdated = block.timestamp;
                
            }
            else{
                usersWhoHaveBorrow[_market].push(borrower);
                _dis.exist = true;
                _dis.index = usersWhoHaveBorrow[_market].length - 1;
                _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
                _dis.lastUpdated = block.timestamp;
            }
            
            return(currentBorrowBal,market.borrowIndex(),market.totalBorrows());
        }
    }
    
    /**
     * Supply Side
     */
   
    
    function returnBorrowUserArr(address market) external view returns(address [] memory){
        
        return usersWhoHaveBorrow[market];
    
    }

}