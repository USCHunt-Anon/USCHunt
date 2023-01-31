pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function setRouter(address _router) external;
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function pairCodeHash() external pure returns(bytes32);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
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
    function setRouter02(address _router02) external;
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function swapNoFee(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


// : MIT

pragma solidity <=0.6.6;

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
contract Initializable {
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


pragma solidity =0.6.6;

//import"../core/interfaces/IUniswapV2Factory.sol";
//import"@uniswap/lib/contracts/libraries/TransferHelper.sol";

//import"./interfaces/IUniswapV2Router02.sol";
//import"./libraries/UniswapV2Library.sol";
//import"./libraries/SafeMath.sol";
//import"./interfaces/IERC20.sol";
//import"./interfaces/IWETH.sol";
//import"../libraries/Initializable.sol";

contract UniswapV2Router02 is Initializable, IUniswapV2Router02 {
    using SafeMath for uint256;

    address public override factory;
    address public treasureContract;
    address public override WETH;
    address public override HYBEX;
    uint256 public SYSTEM_FEE = 0.5 ether;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "UniswapV2Router: EXPIRED");
        _;
    }

    function __UniswapV2Router02_init__(address _factory, address _WETH) external initializer {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** CONFIG ****
    function setTreasureContract(address _treasureContract) external {
        require(
            msg.sender == IUniswapV2Factory(factory).feeToSetter(),
            "UniswapV2Router: FORBIDDEN"
        );
        treasureContract = _treasureContract;
    }

    function setHYBEX(address _HYBEX) external {
        require(
            msg.sender == IUniswapV2Factory(factory).feeToSetter(),
            "UniswapV2Router: FORBIDDEN"
        );
        HYBEX = _HYBEX;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IUniswapV2Factory(factory).getPair(tokenA, tokenB) == address(0)) {
            IUniswapV2Factory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = UniswapV2Library.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = UniswapV2Library.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IUniswapV2Pair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IUniswapV2Pair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        IUniswapV2Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IUniswapV2Pair(pair).burn(to);
        (address token0, ) = UniswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
        );
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH)
    {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IUniswapV2Pair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountETH)
    {
        address pair = UniswapV2Library.pairFor(factory, token, WETH);
        uint256 value = approveMax ? uint256(-1) : liquidity;
        IUniswapV2Pair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to,
        LiquidityFeeOptions option
    ) internal virtual {
        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = UniswapV2Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? UniswapV2Library.pairFor(factory, output, path[i + 2])
                : _to;
            if (option == LiquidityFeeOptions.PRINCIPLE) {
                IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output))
                    .swap(amount0Out, amount1Out, to, new bytes(0));
            } else {
                IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output))
                    .swapNoFee(amount0Out, amount1Out, to, new bytes(0));
            }
        }
    }

    function _handleSystemFee(LiquidityFeeOptions _option, address _token)
        private
    {
        if (_option == LiquidityFeeOptions.PRINCIPLE) {
            TransferHelper.safeTransferFrom(
                _token,
                msg.sender,
                treasureContract,
                SYSTEM_FEE
            );
        } else if (_option == LiquidityFeeOptions.EKTA) {
            require(
                address(this).balance >= SYSTEM_FEE,
                "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
            );
            payable(treasureContract).transfer(SYSTEM_FEE);
        } else if (_option == LiquidityFeeOptions.HYBEX) {
            TransferHelper.safeTransferFrom(
                HYBEX,
                msg.sender,
                treasureContract,
                SYSTEM_FEE
            );
        }
    }

    function _handleSystemFeeETH(LiquidityFeeOptions _option) private {
        if (
            _option == LiquidityFeeOptions.PRINCIPLE ||
            _option == LiquidityFeeOptions.EKTA
        ) {
            require(
                address(this).balance >= SYSTEM_FEE,
                "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
            );
            payable(treasureContract).transfer(SYSTEM_FEE);
        } else if (_option == LiquidityFeeOptions.HYBEX) {
            TransferHelper.safeTransferFrom(
                HYBEX,
                msg.sender,
                treasureContract,
                SYSTEM_FEE
            );
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        _handleSystemFee(systemOption, path[0]);

        if (lpOption == LiquidityFeeOptions.PRINCIPLE) {
            amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);

            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );

            _swap(amounts, path, to, lpOption);
        } else {
            amounts = UniswapV2Library.getAmountsOutNoFee(
                factory,
                amountIn,
                path
            );
            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );
            uint256 _fee = amountIn.mul(3) / 1000;

            if (lpOption == LiquidityFeeOptions.HYBEX) {
                TransferHelper.safeTransferFrom(
                    HYBEX,
                    msg.sender,
                    treasureContract,
                    _fee
                );
            } else if (lpOption == LiquidityFeeOptions.EKTA) {
                require(
                    address(this).balance >= _fee,
                    "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
                );
                payable(treasureContract).transfer(_fee);
            }

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );

            _swap(amounts, path, to, lpOption);
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        _handleSystemFee(systemOption, path[0]);

        if (lpOption == LiquidityFeeOptions.PRINCIPLE) {
            amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
            require(
                amounts[0] <= amountInMax,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );
            _swap(amounts, path, to, lpOption);
        } else {
            amounts = UniswapV2Library.getAmountsInNoFee(
                factory,
                amountOut,
                path
            );
            require(
                amounts[0] <= amountInMax,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );

            uint256 _fee = amounts[0].mul(3) / 1000;

            if (lpOption == LiquidityFeeOptions.HYBEX) {
                TransferHelper.safeTransferFrom(
                    HYBEX,
                    msg.sender,
                    treasureContract,
                    _fee
                );
            } else if (lpOption == LiquidityFeeOptions.EKTA) {
                require(
                    address(this).balance >= _fee,
                    "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
                );
                payable(treasureContract).transfer(_fee);
            }

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );
            _swap(amounts, path, to, lpOption);
        }
    }

    function swapExactETHForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");

        if (
            (lpOption == LiquidityFeeOptions.PRINCIPLE ||
                lpOption == LiquidityFeeOptions.EKTA) &&
            (systemOption == LiquidityFeeOptions.PRINCIPLE ||
                systemOption == LiquidityFeeOptions.EKTA)
        ) {
            require(
                msg.value >= amountIn.add(SYSTEM_FEE),
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
        } else {
            require(
                msg.value >= amountIn,
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
        }

        _handleSystemFeeETH(systemOption);

        if (
            lpOption == LiquidityFeeOptions.PRINCIPLE ||
            lpOption == LiquidityFeeOptions.EKTA
        ) {
            require(
                address(this).balance >= amountIn,
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
            amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);

            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );

            IWETH(WETH).deposit{value: amounts[0]}();
            assert(
                IWETH(WETH).transfer(
                    UniswapV2Library.pairFor(factory, path[0], path[1]),
                    amounts[0]
                )
            );
            _swap(amounts, path, to, lpOption);
        } else {
            require(
                address(this).balance >= amountIn,
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
            uint256 _fee = amountIn.mul(3) / 1000;

            amounts = UniswapV2Library.getAmountsOutNoFee(
                factory,
                amountIn,
                path
            );

            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );

            TransferHelper.safeTransferFrom(
                HYBEX,
                msg.sender,
                treasureContract,
                _fee
            );

            IWETH(WETH).deposit{value: amounts[0]}();
            assert(
                IWETH(WETH).transfer(
                    UniswapV2Library.pairFor(factory, path[0], path[1]),
                    amounts[0]
                )
            );
            _swap(amounts, path, to, lpOption);
        }
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");

        _handleSystemFee(systemOption, path[0]);

        if (lpOption == LiquidityFeeOptions.PRINCIPLE) {
            amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
            require(
                amounts[0] <= amountInMax,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );
            _swap(amounts, path, address(this), lpOption);
            IWETH(WETH).withdraw(amounts[amounts.length - 1]);
            TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        } else {
            amounts = UniswapV2Library.getAmountsInNoFee(
                factory,
                amountOut,
                path
            );
            require(
                amounts[0] <= amountInMax,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );
            uint256 _fee = amounts[0].mul(3) / 1000;

            if (lpOption == LiquidityFeeOptions.HYBEX) {
                TransferHelper.safeTransferFrom(
                    HYBEX,
                    msg.sender,
                    treasureContract,
                    _fee
                );
            } else if (lpOption == LiquidityFeeOptions.EKTA) {
                require(
                    address(this).balance >= _fee,
                    "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
                );
                payable(treasureContract).transfer(_fee);
            }

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );
            _swap(amounts, path, address(this), lpOption);
            IWETH(WETH).withdraw(amounts[amounts.length - 1]);
            TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        }
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == WETH, "UniswapV2Router: INVALID_PATH");
        _handleSystemFee(systemOption, path[0]);

        if (lpOption == LiquidityFeeOptions.PRINCIPLE) {
            amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);

            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );

            _swap(amounts, path, address(this), lpOption);
            IWETH(WETH).withdraw(amounts[amounts.length - 1]);
            TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        } else {
            amounts = UniswapV2Library.getAmountsOutNoFee(
                factory,
                amountIn,
                path
            );
            require(
                amounts[amounts.length - 1] >= amountOutMin,
                "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
            );

            uint256 _fee = amountIn.mul(3) / 1000;

            if (lpOption == LiquidityFeeOptions.HYBEX) {
                TransferHelper.safeTransferFrom(
                    HYBEX,
                    msg.sender,
                    treasureContract,
                    _fee
                );
            } else if (lpOption == LiquidityFeeOptions.EKTA) {
                require(
                    address(this).balance >= _fee,
                    "UniswapV2Router: INSUFFICIENT_COIN_AMOUNT"
                );
                payable(treasureContract).transfer(_fee);
            }

            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                UniswapV2Library.pairFor(factory, path[0], path[1]),
                amounts[0]
            );
            _swap(amounts, path, address(this), lpOption);
            IWETH(WETH).withdraw(amounts[amounts.length - 1]);
            TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
        }
    }

    function swapETHForExactTokens(
        uint256 amountIn,
        uint256 amountOut,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "UniswapV2Router: INVALID_PATH");

        if (
            (lpOption == LiquidityFeeOptions.PRINCIPLE ||
                lpOption == LiquidityFeeOptions.EKTA) &&
            (systemOption == LiquidityFeeOptions.PRINCIPLE ||
                systemOption == LiquidityFeeOptions.EKTA)
        ) {
            require(
                msg.value >= amountIn.add(SYSTEM_FEE),
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
        } else {
            require(
                msg.value >= amountIn,
                "UniswapV2Router: INSUFFICIENT_INPUT_AMOUNT"
            );
        }

        _handleSystemFeeETH(systemOption);
        if (
            lpOption == LiquidityFeeOptions.PRINCIPLE ||
            lpOption == LiquidityFeeOptions.EKTA
        ) {
            require(
                address(this).balance >= amountIn,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );
            amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);

            require(
                amounts[0] <= amountIn,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );

            IWETH(WETH).deposit{value: amounts[0]}();
            assert(
                IWETH(WETH).transfer(
                    UniswapV2Library.pairFor(factory, path[0], path[1]),
                    amounts[0]
                )
            );
            _swap(amounts, path, to, lpOption);
        } else {
            require(
                address(this).balance >= amountIn,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );
            amounts = UniswapV2Library.getAmountsInNoFee(
                factory,
                amountOut,
                path
            );
            require(
                amounts[0] <= amountIn,
                "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT"
            );
            uint256 _fee = amounts[0].mul(3) / 1000;

            TransferHelper.safeTransferFrom(
                HYBEX,
                msg.sender,
                treasureContract,
                _fee
            );

            IWETH(WETH).deposit{value: amounts[0]}();
            assert(
                IWETH(WETH).transfer(
                    UniswapV2Library.pairFor(factory, path[0], path[1]),
                    amounts[0]
                )
            );
            _swap(amounts, path, to, lpOption);
        }
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }

    function getAmountOutNoFee(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override returns (uint256 amountOut) {
        return
            UniswapV2Library.getAmountOutNoFee(amountIn, reserveIn, reserveOut);
    }

    function getAmountInNoFee(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override returns (uint256 amountIn) {
        return
            UniswapV2Library.getAmountInNoFee(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOutNoFee(uint256 amountIn, address[] memory path)
        public
        view
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsOutNoFee(factory, amountIn, path);
    }

    function getAmountsInNoFee(uint256 amountOut, address[] memory path)
        public
        view
        override
        returns (uint256[] memory amounts)
    {
        return UniswapV2Library.getAmountsInNoFee(factory, amountOut, path);
    }
}


pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    enum LiquidityFeeOptions {
        PRINCIPLE,
        EKTA,
        HYBEX
    }

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
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        LiquidityFeeOptions lpOption,
        LiquidityFeeOptions systemOption,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, LiquidityFeeOptions lpOption, LiquidityFeeOptions systemOption, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, LiquidityFeeOptions lpOption, LiquidityFeeOptions systemOption, uint deadline)
        external payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, LiquidityFeeOptions lpOption, LiquidityFeeOptions systemOption, uint deadline)
        external payable
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountIn, uint amountOut, address[] calldata path, address to, LiquidityFeeOptions lpOption, LiquidityFeeOptions systemOption, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountOutNoFee(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountInNoFee(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOutNoFee(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsInNoFee(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


pragma solidity >=0.6.2;

//import'./IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function HYBEX() external pure returns (address);
}


pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


pragma solidity >=0.5.0;

//import'../../core/interfaces/IUniswapV2Pair.sol';

//import"./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    enum LiquidityFeeOptions {
        PRINCIPLE,
        EKTA,
        HYBEX
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'a1ef728c5a1af5d9823591a13bcdc5775080bb995e142eb5fb9b9dc72745616e' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset but no 3% fee
    function getAmountOutNoFee(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = amountIn.mul(reserveOut);
        uint denominator = reserveIn.add(amountIn);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset no 3% fee
    function getAmountInNoFee(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut);
        uint denominator = reserveOut.sub(amountOut);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountOut calculations on any number of pairs no 3% fee
    function getAmountsOutNoFee(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOutNoFee(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

     // performs chained getAmountIn calculations on any number of pairs no 3% fee
    function getAmountsInNoFee(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountInNoFee(amounts[i], reserveIn, reserveOut);
        }
    }
}


// : GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}


