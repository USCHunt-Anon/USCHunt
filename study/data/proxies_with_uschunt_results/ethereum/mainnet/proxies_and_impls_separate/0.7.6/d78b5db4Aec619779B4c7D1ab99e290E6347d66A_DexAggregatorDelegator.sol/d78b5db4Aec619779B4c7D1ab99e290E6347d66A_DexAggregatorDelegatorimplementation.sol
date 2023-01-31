// : BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

//import"@openzeppelin/contracts/math/SafeMath.sol";

library Utils{
    using SafeMath for uint;

    uint constant feeRatePrecision = 10**6;

    function toAmountBeforeTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        uint denominator = feeRatePrecision.sub(feeRate);
        uint numerator = amount.mul(feeRatePrecision).add(denominator).sub(1);
        return numerator / denominator;
    }

    function toAmountAfterTax(uint256 amount, uint24 feeRate) internal pure returns (uint){
        return amount.mul(feeRatePrecision.sub(feeRate)) / feeRatePrecision;
    }

    function minOf(uint a, uint b) internal pure returns (uint){
        return a < b ? a : b;
    }

    function maxOf(uint a, uint b) internal pure returns (uint){
        return a > b ? a : b;
    }
}

// : BUSL-1.1
pragma solidity 0.7.6;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
// //import"@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title TransferHelper
 * @dev Wrappers around ERC20 operations that returns the value received by recipent and the actual allowance of approval.
 * To use this library you can add a `using TransferHelper for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
 library TransferHelper{
    // using SafeMath for uint;

    function safeTransfer(IERC20 _token, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _amount));
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeTransferFrom(IERC20 _token, address _from, address _to, uint _amount) internal returns (uint amountReceived){
        if (_amount > 0){
            uint balanceBefore = _token.balanceOf(_to);
            address(_token).call(abi.encodeWithSelector(_token.transferFrom.selector, _from, _to, _amount));
            // _token.transferFrom(_from, _to, _amount);
            uint balanceAfter = _token.balanceOf(_to);
            require(balanceAfter > balanceBefore, "TFF");
            amountReceived = balanceAfter - balanceBefore;
        }
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
        bool success;
        if (_token.allowance(address(this), _spender) != 0){
            (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, 0));
            require(success, "AF");
        }
        (success, ) = address(_token).call(abi.encodeWithSelector(_token.approve.selector, _spender, _amount));
        require(success, "AF");

        return _token.allowance(address(this), _spender);
    }

    // function safeIncreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.add(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }

    // function safeDecreaseAllowance(IERC20 _token, address _spender, uint256 _amount) internal returns (uint) {
    //     uint256 allowanceBefore = _token.allowance(address(this), _spender);
    //     uint256 allowanceNew = allowanceBefore.sub(_amount);
    //     uint256 allowanceAfter = safeApprove(_token, _spender, allowanceNew);
    //     require(allowanceAfter == allowanceNew, "AF");
    //     return allowanceNew;
    // }
}

// : BUSL-1.1
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

/// @dev DexDataFormat addPair = byte(dexID) + bytes3(feeRate) + bytes(arrayLength) + byte3[arrayLength](trasferFeeRate Lpool <-> openlev) 
/// + byte3[arrayLength](transferFeeRate openLev -> Dex) + byte3[arrayLength](Dex -> transferFeeRate openLev)
/// exp: 0x0100000002011170000000011170000000011170000000
/// DexDataFormat dexdata = byte(dexID）+ bytes3(feeRate) + byte(arrayLength) + path
/// uniV2Path = bytes20[arraylength](address)
/// uniV3Path = bytes20(address)+ bytes20[arraylength-1](address + fee)
library DexData {
    // in byte
    uint constant DEX_INDEX = 0;
    uint constant FEE_INDEX = 1;
    uint constant ARRYLENTH_INDEX = 4;
    uint constant TRANSFERFEE_INDEX = 5;
    uint constant PATH_INDEX = 5;
    uint constant FEE_SIZE = 3;
    uint constant ADDRESS_SIZE = 20;
    uint constant NEXT_OFFSET = ADDRESS_SIZE + FEE_SIZE;

    uint8 constant DEX_UNIV2 = 1;
    uint8 constant DEX_UNIV3 = 2;
    uint8 constant DEX_PANCAKE = 3;
    uint8 constant DEX_SUSHI = 4;
    uint8 constant DEX_MDEX = 5;
    uint8 constant DEX_TRADERJOE = 6;
    uint8 constant DEX_SPOOKY = 7;
    uint8 constant DEX_QUICK = 8;
    uint8 constant DEX_SHIBA = 9;
    uint8 constant DEX_APE = 10;
    uint8 constant DEX_PANCAKEV1 = 11;
    uint8 constant DEX_BABY = 12;

    struct V3PoolData {
        address tokenA;
        address tokenB;
        uint24 fee;
    }

    function toDex(bytes memory data) internal pure returns (uint8) {
        require(data.length >= FEE_INDEX, "DexData: toDex wrong data format");
        uint8 temp;
        assembly {
            temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
        }
        return temp;
    }

    function toFee(bytes memory data) internal pure returns (uint24) {
        require(data.length >= ARRYLENTH_INDEX, "DexData: toFee wrong data format");
        uint temp;
        assembly {
            temp := mload(add(data, add(0x20, FEE_INDEX)))
        }
        return uint24(temp >> (256 - (ARRYLENTH_INDEX - FEE_INDEX) * 8));
    }

    function toDexDetail(bytes memory data) internal pure returns (uint32) {
        require (data.length >= FEE_INDEX, "DexData: toDexDetail wrong data format");
        if (isUniV2Class(data)){
            uint8 temp;
            assembly {
                temp := byte(0, mload(add(data, add(0x20, DEX_INDEX))))
            }
            return uint32(temp);
        } else {
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, DEX_INDEX)))
            }
            return uint32(temp >> (256 - ((FEE_SIZE + FEE_INDEX) * 8)));
        }
    }

    function toArrayLength(bytes memory data) internal pure returns(uint8 length){
        require(data.length >= TRANSFERFEE_INDEX, "DexData: toArrayLength wrong data format");

        assembly {
            length := byte(0, mload(add(data, add(0x20, ARRYLENTH_INDEX))))
        }
    }

    // only for add pair
    function toTransferFeeRates(bytes memory data) internal pure returns (uint24[] memory transferFeeRates){
        uint8 length = toArrayLength(data) * 3;
        uint start = TRANSFERFEE_INDEX;

        transferFeeRates = new uint24[](length);
        for (uint i = 0; i < length; i++){
            // use default value
            if (data.length <= start){
                transferFeeRates[i] = 0;
                continue;
            }

            // use input value
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, start)))
            }

            transferFeeRates[i] = uint24(temp >> (256 - FEE_SIZE * 8));
            start += FEE_SIZE;
        }
    }

    function toUniV2Path(bytes memory data) internal pure returns (address[] memory path) {
        uint8 length = toArrayLength(data);
        uint end =  PATH_INDEX + ADDRESS_SIZE * length;
        require(data.length >= end, "DexData: toUniV2Path wrong data format");

        uint start = PATH_INDEX;
        path = new address[](length);
        for (uint i = 0; i < length; i++) {
            uint startIndex = start + ADDRESS_SIZE * i;
            uint temp;
            assembly {
                temp := mload(add(data, add(0x20, startIndex)))
            }

            path[i] = address(temp >> (256 - ADDRESS_SIZE * 8));
        }
    }

    function isUniV2Class(bytes memory data) internal pure returns(bool){
        return toDex(data) != DEX_UNIV3;
    }

    function toUniV3Path(bytes memory data) internal pure returns (V3PoolData[] memory path) {
        uint8 length = toArrayLength(data);
        uint end = PATH_INDEX + (FEE_SIZE  + ADDRESS_SIZE) * length - FEE_SIZE;
        require(data.length >= end, "DexData: toUniV3Path wrong data format");
        require(length > 1, "DexData: toUniV3Path path too short");

        uint temp;
        uint index = PATH_INDEX;
        path = new V3PoolData[](length - 1);

        for (uint i = 0; i < length - 1; i++) {
            V3PoolData memory pool;

            // get tokenA
            if (i == 0) {
                assembly {
                    temp := mload(add(data, add(0x20, index)))
                }
                pool.tokenA = address(temp >> (256 - ADDRESS_SIZE * 8));
                index += ADDRESS_SIZE;
            }else{
                pool.tokenA = path[i-1].tokenB;
                index += NEXT_OFFSET;
            }

            // get TokenB
            assembly {
                temp := mload(add(data, add(0x20, index)))
            }

            uint tokenBAndFee = temp >> (256 - NEXT_OFFSET * 8);
            pool.tokenB = address(tokenBAndFee >> (FEE_SIZE * 8));
            pool.fee = uint24(tokenBAndFee - (tokenBAndFee << (FEE_SIZE * 8)));

            path[i] = pool;
        }
    }
}

// : BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;

//import"@openzeppelin/contracts/math/SafeMath.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
//import"@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
//import"@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
//import"@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
//import'@uniswap/v3-core/contracts/libraries/SafeCast.sol';
//import'@uniswap/v3-core/contracts/libraries/TickMath.sol';
//import"../../lib/DexData.sol";
//import"../../lib/TransferHelper.sol";

contract UniV3Dex is IUniswapV3SwapCallback {
    using SafeMath for uint;
    using TransferHelper for IERC20;
    using SafeCast for uint256;
    IUniswapV3Factory public  uniV3Factory;
    uint16 private constant observationSize = 12;

    struct SwapCallData {
        IUniswapV3Pool pool;
        address recipient;
        bool zeroForOne;
        int256 amountSpecified;
        uint160 sqrtPriceLimitX96;
    }

    struct SwapCallbackData {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address payer;
    }

    function initializeUniV3(
        IUniswapV3Factory _uniV3Factory
    ) internal {
        uniV3Factory = _uniV3Factory;
    }

    function uniV3Sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, uint24 fee, bool checkPool, address payer, address payee) internal returns (uint amountOut){
        SwapCallbackData memory data = SwapCallbackData({tokenIn : sellToken, tokenOut : buyToken, fee : fee, payer : payer});
        SwapCallData memory callData;
        callData.zeroForOne = data.tokenIn < data.tokenOut;
        callData.recipient = payee;
        callData.amountSpecified = sellAmount.toInt256();
        callData.sqrtPriceLimitX96 = getSqrtPriceLimitX96(callData.zeroForOne);
        callData.pool = getPool(data.tokenIn, data.tokenOut, fee);
        if (checkPool) {
            require(isPoolObservationsEnough(callData.pool), "Pool observations not enough");
        }
        (int256 amount0, int256 amount1) =
        callData.pool.swap(
            callData.recipient,
            callData.zeroForOne,
            callData.amountSpecified,
            callData.sqrtPriceLimitX96,
            abi.encode(data)
        );
        amountOut = uint256(- (callData.zeroForOne ? amount1 : amount0));
        require(amountOut >= minBuyAmount, 'buy amount less than min');
        require(sellAmount == uint256(callData.zeroForOne ? amount0 : amount1), 'Cannot sell all');
    }

    function uniV3SellMul(uint sellAmount, uint minBuyAmount, DexData.V3PoolData[] memory path) internal returns (uint buyAmount){
        for (uint i = 0; i < path.length; i++) {
            DexData.V3PoolData memory poolData = path[i];
            address buyToken = poolData.tokenB;
            address sellToken = poolData.tokenA;
            bool isLast = i == path.length - 1;
            address payer = i == 0 ? msg.sender : address(this);
            address payee = isLast ? msg.sender : address(this);
            buyAmount = uniV3Sell(buyToken, sellToken, sellAmount, 0, poolData.fee, false, payer, payee);
            if (!isLast) {
                sellAmount = buyAmount;
            }
        }
        require(buyAmount >= minBuyAmount, 'buy amount less than min');
    }

        function uniV3Buy(address buyToken, address sellToken, uint buyAmount, uint maxSellAmount, uint24 fee, bool checkPool) internal returns (uint amountIn){
        SwapCallbackData memory data = SwapCallbackData({tokenIn : sellToken, tokenOut : buyToken, fee : fee, payer : msg.sender});
        bool zeroForOne = data.tokenIn < data.tokenOut;
        IUniswapV3Pool pool = getPool(data.tokenIn, data.tokenOut, fee);
        if (checkPool) {
            require(isPoolObservationsEnough(pool), "Pool observations not enough");
        }
        (int256 amount0Delta, int256 amount1Delta) =
        pool.swap(
            data.payer,
            zeroForOne,
            - buyAmount.toInt256(),
            getSqrtPriceLimitX96(zeroForOne),
            abi.encode(data)
        );

        uint256 amountOutReceived;
        (amountIn, amountOutReceived) = zeroForOne
        ? (uint256(amount0Delta), uint256(- amount1Delta))
        : (uint256(amount1Delta), uint256(- amount0Delta));
        require(amountOutReceived == buyAmount, 'Cannot buy enough');
        require(amountIn <= maxSellAmount, 'sell amount not enough');
    }


    function uniV3GetPrice(address desToken, address quoteToken, uint8 decimals, uint24 fee) internal view returns (uint256 price, IUniswapV3Pool pool){
        pool = getPool(desToken, quoteToken, fee);
        (uint160 sqrtPriceX96,,,,,,) = pool.slot0();
        price = getPriceBySqrtPriceX96(desToken, quoteToken, sqrtPriceX96, decimals);
    }

    function uniV3GetAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, uint8 decimals, uint24 fee) internal view returns (uint256 price, uint256 timestamp, IUniswapV3Pool pool){
        require(secondsAgo > 0, "SecondsAgo must >0");
        pool = getPool(desToken, quoteToken, fee);
        price = calcAvgPrice(pool, desToken, quoteToken, secondsAgo, decimals);
        timestamp = block.timestamp.sub(secondsAgo);
    }

    function uniV3GetPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, uint8 decimals, uint24 fee) internal view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint256 timestamp){
        IUniswapV3Pool pool;
        (price, pool) = uniV3GetPrice(desToken, quoteToken, decimals, fee);
        (cAvgPrice, hAvgPrice) = calcAvgPrices(pool, desToken, quoteToken, secondsAgo / 2, secondsAgo, decimals);
        timestamp = block.timestamp.sub(secondsAgo);
    }

    function increaseV3Observation(address desToken, address quoteToken, uint24 fee) internal {
        getPool(desToken, quoteToken, fee).increaseObservationCardinalityNext(observationSize);
    }

    function getPriceBySqrtPriceX96(address desToken, address quoteToken, uint160 sqrtPriceX96, uint8 decimals) internal pure returns (uint256){
        uint priceScale = 10 ** decimals;
        // maximum～2**
        uint token0Price;
        // when sqrtPrice>1  retain 4 decimals
        if (sqrtPriceX96 > (2 ** 96)) {
            token0Price = (uint(sqrtPriceX96) >> (86)).mul((uint(sqrtPriceX96) >> (86))).mul(priceScale) >> (10 * 2);
        } else {
            token0Price = uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(priceScale) >> (96 * 2);
        }
        if (desToken < quoteToken) {
            return token0Price;
        } else {
            return uint(priceScale).mul(priceScale).div(token0Price);
        }
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0);
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        require(msg.sender == address(getPool(data.tokenIn, data.tokenOut, data.fee)), "V3 call back invalid");
        uint256 amountToPay = uint256(amount0Delta > 0 ? amount0Delta : amount1Delta);
        if (data.payer == address(this)) {
            IERC20(data.tokenIn).safeTransfer(msg.sender, amountToPay);
        } else {
            IERC20(data.tokenIn).safeTransferFrom(data.payer, msg.sender, amountToPay);
        }
    }

    function calcAvgPrice(IUniswapV3Pool pool, address desToken, address quoteToken, uint32 secondsAgo, uint8 decimals) internal view returns (uint price){
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = 0;
        secondsAgos[1] = secondsAgo;
        (int56[] memory tickCumulatives1,) = pool.observe(secondsAgos);
        int24 avgTick = int24(((tickCumulatives1[0] - tickCumulatives1[1]) / (secondsAgo)));
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(avgTick);
        price = getPriceBySqrtPriceX96(desToken, quoteToken, sqrtPriceX96, decimals);
    }

    function calcAvgPrices(IUniswapV3Pool pool, address desToken, address quoteToken, uint32 second1, uint32 second2, uint8 decimals) internal view returns (uint price1, uint price2){
        uint32[] memory secondsAgos = new uint32[](3);
        secondsAgos[0] = 0;
        secondsAgos[1] = second1;
        secondsAgos[2] = second2;
        (int56[] memory tickCumulatives,) = pool.observe(secondsAgos);
        int24 avgTick1 = int24(((tickCumulatives[0] - tickCumulatives[1]) / (second1)));
        uint160 sqrtPriceX961 = TickMath.getSqrtRatioAtTick(avgTick1);
        price1 = getPriceBySqrtPriceX96(desToken, quoteToken, sqrtPriceX961, decimals);
        int24 avgTick2 = int24(((tickCumulatives[1] - tickCumulatives[2]) / (second2 - second1)));
        uint160 sqrtPriceX962 = TickMath.getSqrtRatioAtTick(avgTick2);
        price2 = getPriceBySqrtPriceX96(desToken, quoteToken, sqrtPriceX962, decimals);
    }

    function getSqrtPriceLimitX96(bool zeroForOne) internal pure returns (uint160) {
        return zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1;
    }

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool) {
        if (address(uniV3Factory) == 0x1F98431c8aD98523631AE4a59f267346ea31F984) {
            return IUniswapV3Pool(PoolAddress.computeAddress(address(uniV3Factory) , PoolAddress.getPoolKey(tokenA, tokenB, fee)));
        } else {
            return IUniswapV3Pool(uniV3Factory.getPool(tokenA, tokenB, fee));
        }
    }

    function isPoolObservationsEnough(IUniswapV3Pool pool) internal view returns (bool){
        (,,,,uint16 count,,) = pool.slot0();
        return count >= observationSize;
    }

}

// : BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"@openzeppelin/contracts/math/SafeMath.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
//import"../../lib/TransferHelper.sol";
//import"../../lib/DexData.sol";
//import"../../lib/Utils.sol";

contract UniV2Dex {
    using SafeMath for uint;
    using Utils for uint;
    using TransferHelper for IERC20;

    struct V2PriceOracle {
        uint32 blockTimestampLast;  // Last block timestamp when price updated
        uint price0; // recorded price for token0
        uint price1; // recorded price for token1
        uint price0CumulativeLast; // Cumulative TWAP for token0
        uint price1CumulativeLast; // Cumulative TWAP for token1
    }

    struct DexInfo {
        IUniswapV2Factory factory;
        uint16 fees;//30->0.3%
    }

    function uniV2Sell(DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint sellAmount,
        uint minBuyAmount,
        address payer,
        address payee
    ) internal returns (uint buyAmount){
        address pair = getUniV2ClassPair(buyToken, sellToken, dexInfo.factory);
        IUniswapV2Pair(pair).sync();
        sellAmount = transferOut(IERC20(sellToken), payer, pair, sellAmount);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        sellAmount = buyToken < sellToken ? IERC20(sellToken).balanceOf(pair).sub(token1Reserves) : IERC20(sellToken).balanceOf(pair).sub(token0Reserves);

        uint balanceBefore = IERC20(buyToken).balanceOf(payee);
        dexInfo.fees = getPairFees(dexInfo, pair);

        if (buyToken < sellToken) {
            buyAmount = getAmountOut(sellAmount, token1Reserves, token0Reserves, dexInfo.fees);
            IUniswapV2Pair(pair).swap(buyAmount, 0, payee, "");
        } else {
            buyAmount = getAmountOut(sellAmount, token0Reserves, token1Reserves, dexInfo.fees);
            IUniswapV2Pair(pair).swap(0, buyAmount, payee, "");
        }
        buyAmount = IERC20(buyToken).balanceOf(payee).sub(balanceBefore);
        require(buyAmount >= minBuyAmount, 'buy amount less than min');
    }

    function uniV2SellMul(DexInfo memory dexInfo, uint sellAmount, uint minBuyAmount, address[] memory tokens)
    internal returns (uint buyAmount){
        for (uint i = 1; i < tokens.length; i++) {
            address sellToken = tokens[i - 1];
            address buyToken = tokens[i];
            bool isLast = i == tokens.length - 1;
            address payer = i == 1 ? msg.sender : address(this);
            address payee = isLast ? msg.sender : address(this);
            buyAmount = uniV2Sell(dexInfo, buyToken, sellToken, sellAmount, 0, payer, payee);
            if (!isLast) {
                sellAmount = buyAmount;
            }
        }
        require(buyAmount >= minBuyAmount, 'buy amount less than min');
    }

    function uniV2Buy(
        DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint buyAmount,
        uint maxSellAmount,
        uint24 buyTokenFeeRate,
        uint24 sellTokenFeeRate)
    internal returns (uint sellAmount){
        address pair = getUniV2ClassPair(buyToken, sellToken, dexInfo.factory);
        IUniswapV2Pair(pair).sync();
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        uint balanceBefore = IERC20(buyToken).balanceOf(msg.sender);
        dexInfo.fees = getPairFees(dexInfo, pair);
        if (buyToken < sellToken) {
            sellAmount = getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token1Reserves, token0Reserves, dexInfo.fees);
            sellAmount = sellAmount.toAmountBeforeTax(sellTokenFeeRate);
            require(sellAmount <= maxSellAmount, 'sell amount not enough');
            transferOut(IERC20(sellToken), msg.sender, pair, sellAmount);
            IUniswapV2Pair(pair).swap(buyAmount.toAmountBeforeTax(buyTokenFeeRate), 0, msg.sender, "");
        } else {
            sellAmount = getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token0Reserves, token1Reserves, dexInfo.fees);
            sellAmount = sellAmount.toAmountBeforeTax(sellTokenFeeRate);
            require(sellAmount <= maxSellAmount, 'sell amount not enough');
            transferOut(IERC20(sellToken), msg.sender, pair, sellAmount);
            IUniswapV2Pair(pair).swap(0, buyAmount.toAmountBeforeTax(buyTokenFeeRate), msg.sender, "");
        }

        uint balanceAfter = IERC20(buyToken).balanceOf(msg.sender);
        require(buyAmount <= balanceAfter.sub(balanceBefore), "wrong amount bought");
    }

    function uniV2CalBuyAmount(DexInfo memory dexInfo, address buyToken, address sellToken, uint sellAmount) internal view returns (uint) {
        address pair = getUniV2ClassPair(buyToken, sellToken, dexInfo.factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        bool isToken0 = buyToken < sellToken;
        if (isToken0) {
            return getAmountOut(sellAmount, token1Reserves, token0Reserves, getPairFees(dexInfo, pair));
        } else {
            return getAmountOut(sellAmount, token0Reserves, token1Reserves, getPairFees(dexInfo, pair));
        }
    }

    function uniV2CalSellAmount(
        DexInfo memory dexInfo,
        address buyToken,
        address sellToken,
        uint buyAmount,
        uint24 buyTokenFeeRate,
        uint24 sellTokenFeeRate) internal view returns (uint sellAmount) {
        address pair = getUniV2ClassPair(buyToken, sellToken, dexInfo.factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        sellAmount = buyToken < sellToken ?
        getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token1Reserves, token0Reserves, getPairFees(dexInfo, pair)) :
        getAmountIn(buyAmount.toAmountBeforeTax(buyTokenFeeRate), token0Reserves, token1Reserves, getPairFees(dexInfo, pair));

        return sellAmount.toAmountBeforeTax(sellTokenFeeRate);
    }

    function uniV2GetPrice(IUniswapV2Factory factory, address desToken, address quoteToken, uint8 decimals) internal view returns (uint256){
        address pair = getUniV2ClassPair(desToken, quoteToken, factory);
        (uint256 token0Reserves, uint256 token1Reserves,) = IUniswapV2Pair(pair).getReserves();
        return desToken == IUniswapV2Pair(pair).token0() ?
        token1Reserves.mul(10 ** decimals).div(token0Reserves) :
        token0Reserves.mul(10 ** decimals).div(token1Reserves);
    }

    function uniV2GetAvgPrice(address desToken, address quoteToken, V2PriceOracle memory priceOracle) internal pure returns (uint256 price, uint256 timestamp){
        timestamp = priceOracle.blockTimestampLast;
        price = desToken < quoteToken ? uint(priceOracle.price0) : uint(priceOracle.price1);
    }


    function uniV2GetPriceCAvgPriceHAvgPrice(address pair, V2PriceOracle memory priceOracle, address desToken, address quoteToken, uint8 decimals)
    internal view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint256 timestamp){
        bool isToken0 = desToken < quoteToken;
        (uint256 token0Reserves, uint256 token1Reserves, uint32 uniBlockTimeLast) = IUniswapV2Pair(pair).getReserves();
        price = isToken0 ?
        token1Reserves.mul(10 ** decimals).div(token0Reserves) :
        token0Reserves.mul(10 ** decimals).div(token1Reserves);

        hAvgPrice = isToken0 ? uint(priceOracle.price0) : uint(priceOracle.price1);
        timestamp = priceOracle.blockTimestampLast;

        if (uniBlockTimeLast <= priceOracle.blockTimestampLast) {
            cAvgPrice = hAvgPrice;
        } else {
            uint32 timeElapsed = uniBlockTimeLast - priceOracle.blockTimestampLast;
            cAvgPrice = uint256(isToken0 ?
                calTPrice(IUniswapV2Pair(pair).price0CumulativeLast(), priceOracle.price0CumulativeLast, timeElapsed, decimals) :
                calTPrice(IUniswapV2Pair(pair).price1CumulativeLast(), priceOracle.price1CumulativeLast, timeElapsed, decimals));
        }
    }

    function uniV2UpdatePriceOracle(address pair, V2PriceOracle memory priceOracle, uint32 timeWindow, uint8 decimals) internal returns (V2PriceOracle memory, bool updated) {
        uint32 currentBlockTime = toUint32(block.timestamp);
        if (currentBlockTime < (priceOracle.blockTimestampLast + timeWindow)) {
            return (priceOracle, false);
        }
        IUniswapV2Pair(pair).sync();
        uint32 timeElapsed = currentBlockTime - priceOracle.blockTimestampLast;
        uint currentPrice0CumulativeLast = IUniswapV2Pair(pair).price0CumulativeLast();
        uint currentPrice1CumulativeLast = IUniswapV2Pair(pair).price1CumulativeLast();
        if (priceOracle.blockTimestampLast != 0) {
            priceOracle.price0 = calTPrice(currentPrice0CumulativeLast, priceOracle.price0CumulativeLast, timeElapsed, decimals);
            priceOracle.price1 = calTPrice(currentPrice1CumulativeLast, priceOracle.price1CumulativeLast, timeElapsed, decimals);
        }
        priceOracle.price0CumulativeLast = currentPrice0CumulativeLast;
        priceOracle.price1CumulativeLast = currentPrice1CumulativeLast;
        priceOracle.blockTimestampLast = currentBlockTime;
        return (priceOracle, true);
    }

    function calTPrice(uint currentPriceCumulativeLast, uint historyPriceCumulativeLast, uint32 timeElapsed, uint8 decimals)
    internal pure returns (uint){
        return ((currentPriceCumulativeLast.sub(historyPriceCumulativeLast).mul(10 ** decimals)) >> 112).div(timeElapsed);
    }

    function toUint32(uint256 y) internal pure returns (uint32 z) {
        require((z = uint32(y)) == y);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint16 fees) private pure returns (uint amountOut)
    {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(uint(10000).sub(fees));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint16 fees) private pure returns (uint amountIn) {
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(uint(10000).sub(fees));
        amountIn = (numerator / denominator).add(1);
    }

    function transferOut(IERC20 token, address payer, address to, uint amount) private returns (uint256 amountReceived) {
        if (payer == address(this)) {
            amountReceived = token.safeTransfer(to, amount);
        } else {
            amountReceived = token.safeTransferFrom(payer, to, amount);
        }
    }

    function getPairFees(DexInfo memory dexInfo, address pair) private pure returns (uint16){
        pair;
        return dexInfo.fees;
    }

    function getUniV2ClassPair(address tokenA, address tokenB, IUniswapV2Factory factory) internal view returns (address pair){
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (address(factory) == 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f) {
            return address(uint(keccak256(abi.encodePacked(
                    hex'ff',
                    address(factory),
                    keccak256(abi.encodePacked(token0, token1)),
                    hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
                ))));
        } else if (address(factory) == 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac) {
            pair = address(uint(keccak256(abi.encodePacked(
                    hex'ff',
                    factory,
                    keccak256(abi.encodePacked(token0, token1)),
                    hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303' // init code hash
                ))));
        } else {
            return factory.getPair(tokenA, tokenB);
        }
    }
}


// : BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;
//import"@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

interface DexAggregatorInterface {

    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);

    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external returns (uint sellAmount);

    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view returns (uint);

    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view returns (uint);

    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);

    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view returns (uint256 price, uint8 decimals, uint256 timestamp);

    //cal current avg price and get history avg price
    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);

    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns(bool);

    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external;

    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external;
}


// : BUSL-1.1
pragma solidity 0.7.6;


contract DelegateInterface {
    /**
     * Implementation address for this contract
     */
    address public implementation;

}




// : BUSL-1.1


pragma solidity 0.7.6;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
    constructor () {
        developer = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        // Save current value, if any, for inclusion in log
        address oldPendingAdmin = pendingAdmin;
        // Store pendingAdmin with value newPendingAdmin
        pendingAdmin = newPendingAdmin;
        // Emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin)
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        // Save current values for inclusion in log
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        // Store admin with value pendingAdmin
        admin = pendingAdmin;
        // Clear the pending value
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
    }
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

//import'./pool/IUniswapV3PoolImmutables.sol';
//import'./pool/IUniswapV3PoolState.sol';
//import'./pool/IUniswapV3PoolDerivedState.sol';
//import'./pool/IUniswapV3PoolActions.sol';
//import'./pool/IUniswapV3PoolOwnerActions.sol';
//import'./pool/IUniswapV3PoolEvents.sol';

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}


// : GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
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


pragma solidity >=0.5.0;

interface IUniswapV2Factory {
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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


// : BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"./UniV2Dex.sol";
//import"./UniV3Dex.sol";
//import"../DexAggregatorInterface.sol";
//import"../../lib/DexData.sol";
//import"../../lib/Utils.sol";
//import"@openzeppelin/contracts/math/SafeMath.sol";
//import"../../DelegateInterface.sol";
//import"../../Adminable.sol";

/// @title Swap logic on ETH
/// @author OpenLeverage
/// @notice Use this contract to swap tokens.
/// @dev Routers for different swap requests.
contract EthDexAggregatorV1 is DelegateInterface, Adminable, DexAggregatorInterface, UniV2Dex, UniV3Dex {
    using DexData for bytes;
    using SafeMath for uint;

    mapping(IUniswapV2Pair => V2PriceOracle)  public uniV2PriceOracle;
    IUniswapV2Factory public uniV2Factory;
    address public openLev;

    uint8 private constant priceDecimals = 18;

    mapping(uint8 => DexInfo) public dexInfo;

    //v2 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    //v3 0x1f98431c8ad98523631ae4a59f267346ea31f984
    function initialize(
        IUniswapV2Factory _uniV2Factory,
        IUniswapV3Factory _uniV3Factory
    ) public {
        require(msg.sender == admin, "Not admin");
        uniV2Factory = _uniV2Factory;
        initializeUniV3(_uniV3Factory);
        dexInfo[DexData.DEX_UNIV2] = DexInfo(_uniV2Factory, 30);
    }

    /// @notice Save factories of the dex.
    /// @param dexName Index of Dex. find list of dex in contracts/lib/DexData.sol.
    /// @param factoryAddr Factory address of Different dex forked from uniswap.
    /// @param fees Swap fee collects by.
    function setDexInfo(uint8[] memory dexName, IUniswapV2Factory[] memory factoryAddr, uint16[] memory fees) external override onlyAdmin {
        require(dexName.length == factoryAddr.length && dexName.length == fees.length, 'EOR');
        for (uint i = 0; i < dexName.length; i++) {
            dexInfo[dexName[i]] = DexInfo(factoryAddr[i], fees[i]);
        }
    }

    /// @dev SetOpenlev address to update dex price
    function setOpenLev(address _openLev) external onlyAdmin {
        require(address(0) != _openLev, '0x');
        openLev = _openLev;
    }

    /// @notice Sell tokens 
    /// @dev Sell exact amount of token with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param sellAmount Exact amount to sell
    /// @param minBuyAmount minmum amount of token to receive.
    /// @param data Dex to use for swap
    /// @return buyAmount Exact Amount bought
    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external override returns (uint buyAmount){
        address payer = msg.sender;
        if (data.isUniV2Class()) {
            buyAmount = uniV2Sell(dexInfo[data.toDex()], buyToken, sellToken, sellAmount, minBuyAmount, payer, payer);
        }
        else if (data.toDex() == DexData.DEX_UNIV3) {
            buyAmount = uniV3Sell(buyToken, sellToken, sellAmount, minBuyAmount, data.toFee(), true, payer, payer);
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Sell tokens 
    /// @dev Sell exact amount of token through path
    /// @param sellAmount Exact amount to sell
    /// @param minBuyAmount Minmum amount of token to receive.
    /// @param data Dex to use for swap and path of the swap
    /// @return buyAmount Exact amount bought
    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external override returns (uint buyAmount){
        if (data.isUniV2Class()) {
            buyAmount = uniV2SellMul(dexInfo[data.toDex()], sellAmount, minBuyAmount, data.toUniV2Path());
        } else if (data.toDex() == DexData.DEX_UNIV3) {
            buyAmount = uniV3SellMul(sellAmount, minBuyAmount, data.toUniV3Path());
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Buy tokens 
    /// @dev Buy exact amount of token with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by SellToken while transfer into Dex pair
    /// @param buyAmount Exact amount to buy
    /// @param maxSellAmount Maximum amount of token to receive.
    /// @param data Dex to use for swap
    /// @return sellAmount Exact amount sold
    function buy(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, uint maxSellAmount, bytes memory data) external override returns (uint sellAmount){
        if (data.isUniV2Class()) {
            sellAmount = uniV2Buy(dexInfo[data.toDex()], buyToken, sellToken, buyAmount, maxSellAmount, buyTax, sellTax);
        }
        else if (data.toDex() == DexData.DEX_UNIV3) {
            sellAmount = uniV3Buy(buyToken, sellToken, buyAmount, maxSellAmount, data.toFee(), true);
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Calculate amount of token to buy 
    /// @dev Calculate exact amount of token to buy with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by SellToken while transfer into Dex pair
    /// @param sellAmount Exact amount to sell
    /// @param data Dex to use for swap
    /// @return buyAmount Amount of buyToken would bought
    function calBuyAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint sellAmount, bytes memory data) external view override returns (uint buyAmount) {
        if (data.isUniV2Class()) {
            sellAmount = Utils.toAmountAfterTax(sellAmount, sellTax);
            buyAmount = uniV2CalBuyAmount(dexInfo[data.toDex()], buyToken, sellToken, sellAmount);
            buyAmount = Utils.toAmountAfterTax(buyAmount, buyTax);
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Calculate amount of token to sell 
    /// @dev Calculate exact amount of token to sell with tax applied
    /// @param buyToken Address of token transfer from Dex pair
    /// @param sellToken Address of token transfer into Dex pair
    /// @param buyTax Tax applyed by buyToken while transfer from Dex pair
    /// @param sellTax Tax applyed by SellToken while transfer into Dex pair
    /// @param buyAmount Exact amount to buy
    /// @param data Dex to use for swap
    /// @return sellAmount Amount of sellToken would sold
    function calSellAmount(address buyToken, address sellToken, uint24 buyTax, uint24 sellTax, uint buyAmount, bytes memory data) external view override returns (uint sellAmount){
        if (data.isUniV2Class()) {
            sellAmount = uniV2CalSellAmount(dexInfo[data.toDex()], buyToken, sellToken, buyAmount, buyTax, sellTax);
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Get price 
    /// @dev Get current price of desToken / quoteToken
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param data Dex to use for swap
    function getPrice(address desToken, address quoteToken, bytes memory data) external view override returns (uint256 price, uint8 decimals){
        decimals = priceDecimals;
        if (data.isUniV2Class()) {
            price = uniV2GetPrice(dexInfo[data.toDex()].factory, desToken, quoteToken, decimals);
        }
        else if (data.toDex() == DexData.DEX_UNIV3) {
            (price,) = uniV3GetPrice(desToken, quoteToken, decimals, data.toFee());
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @dev Get average price of desToken / quoteToken in the last period of time
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param secondsAgo Time period of the average
    /// @param data Dex to use for swap
    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view override returns (uint256 price, uint8 decimals, uint256 timestamp){
        decimals = priceDecimals;
        if (data.isUniV2Class()) {
            address pair = getUniV2ClassPair(desToken, quoteToken, dexInfo[data.toDex()].factory);
            V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
            (price, timestamp) = uniV2GetAvgPrice(desToken, quoteToken, priceOracle);
        }
        else if (data.toDex() == DexData.DEX_UNIV3) {
            (price, timestamp,) = uniV3GetAvgPrice(desToken, quoteToken, secondsAgo, decimals, data.toFee());
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @notice Get current and history price
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param secondsAgo TWAP length for UniV3
    /// @param data Dex parameters
    /// @return price Real-time price
    /// @return cAvgPrice Current TWAP price
    /// @return hAvgPrice Historical TWAP price
    /// @return decimals Token price decimal
    /// @return timestamp Last TWAP price update timestamp 
    function getPriceCAvgPriceHAvgPrice(
        address desToken,
        address quoteToken,
        uint32 secondsAgo,
        bytes memory data
    ) external view override returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp){
        decimals = priceDecimals;
        if (data.isUniV2Class()) {
            address pair = getUniV2ClassPair(desToken, quoteToken, dexInfo[data.toDex()].factory);
            V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
            (price, cAvgPrice, hAvgPrice, timestamp) = uniV2GetPriceCAvgPriceHAvgPrice(pair, priceOracle, desToken, quoteToken, decimals);
        } else if (data.toDex() == DexData.DEX_UNIV3) {
            (price, cAvgPrice, hAvgPrice, timestamp) = uniV3GetPriceCAvgPriceHAvgPrice(desToken, quoteToken, secondsAgo, decimals, data.toFee());
        }
        else {
            revert('Unsupported dex');
        }
    }

    /// @dev Update Dex price if not updated over time window
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param timeWindow Minmum time gap between two updates
    /// @param data Dex parameters
    /// @return If updated
    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external override returns (bool){
        require(msg.sender == openLev, "Only openLev can update price");
        if (data.isUniV2Class()) {
            address pair = getUniV2ClassPair(desToken, quoteToken, dexInfo[data.toDex()].factory);
            V2PriceOracle memory priceOracle = uniV2PriceOracle[IUniswapV2Pair(pair)];
            (V2PriceOracle memory updatedPriceOracle, bool updated) = uniV2UpdatePriceOracle(pair, priceOracle, timeWindow, priceDecimals);
            if (updated) {
                uniV2PriceOracle[IUniswapV2Pair(pair)] = updatedPriceOracle;
            }
            return updated;
        }
        return false;
    }

    /// @dev Update UniV3 observations
    /// @param desToken Token to be priced
    /// @param quoteToken Token used for pricing
    /// @param data Dex parameters
    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external override {
        if (data.toDex() == DexData.DEX_UNIV3) {
            increaseV3Observation(desToken, quoteToken, data.toFee());
        }
    }
}


