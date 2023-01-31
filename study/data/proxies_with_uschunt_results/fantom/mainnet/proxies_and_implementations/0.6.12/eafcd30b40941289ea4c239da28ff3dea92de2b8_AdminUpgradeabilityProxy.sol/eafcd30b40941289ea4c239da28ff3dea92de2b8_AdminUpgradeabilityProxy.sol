/**
 *Submitted for verification at FtmScan.com on 2022-03-31
*/

// File: Badge/AdminUpgradeabilityProxy.sol

/**
 *Submitted for verification at Etherscan.io on 2020-10-09
 */


pragma solidity 0.6.12;

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
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Receive function.
     * Implemented entirely in `_fallback`.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @return The Address of the implementation.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * @param implementation Address to delegate.
     */
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev Function that is run as the first thing in the fallback function.
     * Can be redefined in derived contracts to add functionality.
     * Redefinitions must call super._willFallback().
     */
    function _willFallback() internal virtual {}

    /**
     * @dev fallback implementation.
     * Extracted to enable manual triggering.
     */
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is Proxy {
    /**
     * @dev Contract constructor.
     * @param _logic Address of the initial implementation.
     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
     */
    constructor(address _logic, bytes memory _data) public payable {
        assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     * @param implementation Address of the new implementation.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation.
     * @return impl Address of the current implementation
     */
    function _implementation() internal view override returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     * @param newImplementation Address of the new implementation.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation address of the proxy.
     * @param newImplementation Address of the new implementation.
     */
    function _setImplementation(address newImplementation) internal {
        require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
    /**
     * Contract constructor.
     * @param _logic address of the initial implementation.
     * @param _admin Address of the proxy administrator.
     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
     */
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) public payable UpgradeabilityProxy(_logic, _data) {
        assert(ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
    }

    /**
     * @dev Emitted when the administration has been transferred.
     * @param previousAdmin Address of the previous admin.
     * @param newAdmin Address of the new admin.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */

    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier to check whether the `msg.sender` is the admin.
     * If it is, it will run the function. Otherwise, it will delegate the call
     * to the implementation.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @return The address of the proxy admin.
     */
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

    /**
     * @return The address of the implementation.
     */
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     * Only the current admin can call this function.
     * @param newAdmin Address to transfer proxy administration to.
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the backing implementation of the proxy.
     * Only the admin can call this function.
     * @param newImplementation Address of the new implementation.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the backing implementation of the proxy and call a function
     * on the new implementation.
     * This is useful to initialize the proxied contract.
     * @param newImplementation Address of the new implementation.
     * @param data Data to send as msg.data in the low level call.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeTo(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success);
    }

    /**
     * @return adm The admin slot.
     */
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Sets the address of the proxy admin.
     * @param newAdmin Address of the new proxy admin.
     */
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
     * @dev Only fall back when the sender is not the admin.
     */
    function _willFallback() internal virtual override {
        require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
        super._willFallback();
    }
}

// : MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        // code size of the address account
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


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
                // mload is to load a word (32 bytes) starting from the address returndata
                // add(32, returedata): the address of returndata+32,
                // which is the start address of return message
                // revert(p, s): means return mem[p,..., p+s)
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

library SafeMathUpgradeable {
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


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }


    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }


    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


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


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IComptroller {
    function claimComp(address holder, address[] calldata _iTokens) external;

    function claimComp(address holder) external;

    function enterMarkets(address[] memory _iTokens) external;

    function pendingComptrollerImplementation()
        external
        view
        returns (address implementation);
}

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


interface IVToken is IERC20Upgradeable {
    function underlying() external returns (address);
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function balanceOfUnderlying(address owner) external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function comptroller() external returns (address);
}


interface IVault {
    function rewards() external view returns (address);

    function report(
        uint256 _harvestedAmount
    ) external;

    function reportAdditionalToken(address _token) external;

    // Fees
    function performanceFeeGovernance() external view returns (uint256);

    function performanceFeeStrategist() external view returns (uint256);

    function withdrawalFee() external view returns (uint256);

    function managementFee() external view returns (uint256);

    // Actors
    function governance() external view returns (address);

    function keeper() external view returns (address);

    function guardian() external view returns (address);

    function strategist() external view returns (address);
}

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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
     * just initialize once
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    /**
     * just initialize once
     */

    function __Pausable_init_unchained() internal initializer {
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
     * set pause status by msg.sender, and emit the event
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

    uint256[49] private __gap;
}

contract SettAccessControl is Initializable {
    address public governance;
    address public strategist;
    address public keeper;

    // ===== MODIFIERS =====
    function _onlyGovernance() internal view {
        require(msg.sender == governance, "onlyGovernance");
    }

    function _onlyGovernanceOrStrategist() internal view {
        require(msg.sender == strategist || msg.sender == governance, "onlyGovernanceOrStrategist");
    }

    function _onlyAuthorizedActors() internal view {
        require(msg.sender == keeper || msg.sender == governance, "onlyAuthorizedActors");
    }

    // ===== PERMISSIONED ACTIONS =====

    /// @notice Change strategist address
    /// @notice Can only be changed by governance itself
    function setStrategist(address _strategist) external {
        _onlyGovernance();
        strategist = _strategist;
    }

    /// @notice Change keeper address
    /// @notice Can only be changed by governance itself
    function setKeeper(address _keeper) external {
        _onlyGovernance();
        keeper = _keeper;
    }

    /// @notice Change governance address
    /// @notice Can only be changed by governance itself
    function setGovernance(address _governance) public {
        _onlyGovernance();
        governance = _governance;
    }

    uint256[50] private __gap;
}


abstract contract BaseStrategy is PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    uint256 public constant MAX = 10_000; // MAX in terms of BPS = 100%

    address public want; // Token used for deposits
    address public vault; // address of the vault the strategy is connected to
    uint256 public withdrawalMaxDeviationThreshold; // max allowed slippage when withdrawing

    /// @notice percentage of rewards converted to want
    /// @dev converting of rewards to want during harvest should take place in this ratio
    /// @dev change this ratio if rewards are converted in a different percentage
    /// value ranges from 0 to 10_000
    /// 0: keeping 100% harvest in reward tokens
    /// 10_000: converting all rewards tokens to want token
    uint256 public autoCompoundRatio = 10_000; // NOTE: Since this is upgradeable this won't be set

    
    
    // Return value for harvest, tend and balanceOfRewards
    //** this is used to record extra token reward
    struct TokenAmount {
        address token;
        uint256 amount;
    }
    /// @dev Initializer for the BaseStrategy
    /// @notice Make sure to call it from your specific Strategy  
    function __BaseStrategy_init(address _vault)
        public
        initializer
        whenNotPaused
    {
        require(_vault != address(0), "Address 0");
        __Pausable_init();

        vault = _vault;

        withdrawalMaxDeviationThreshold = 50; // BPS
    }

    // ===== Modifiers =====
    /// @dev For functions that only the governance should be able to call
    /// @notice most of the time setting setters, or to rescue / sweep funds
    function _onlyGovernance() internal view {
        require(msg.sender == governance(), "onlyGovernance");
    }

    /// @dev For functions that only known bening entities should call
    function _onlyGovernanceOrStrategist() internal view {
        require(
            msg.sender == strategist() || msg.sender == governance(),
            "onlyGovernanceOrStrategist"
        );
    }

   /// @dev For functions that only known bening entities should call
    function _onlyAuthorizedActors() internal view {
        require(
            msg.sender == keeper() || msg.sender == governance(),
            "onlyAuthorizedActors"
        );
    }

    /// @dev For functions that only the vault should use
    function _onlyVault() internal view {
        require(msg.sender == vault, "onlyVault");
    }

    /// @dev Modifier used to check if the function is being called by a bening entity
    function _onlyAuthorizedActorsOrVault() internal view {
        require(
            msg.sender == keeper() ||
            msg.sender == governance() ||
            msg.sender == vault, 
            "onlyAuthorizedActorsOrVault"
        );
    }

    /// @dev Modifier used exclusively for pausing
    function _onlyAuthorizedPausers() internal view {
        require(
            msg.sender == guardian() || msg.sender == governance(),
            "onlyPausers"
        );
    }

    /// ===== View Functions =====
    /// @dev Returns the version of the BaseStrategy
    function baseStrategyVersion() public pure returns (string memory) {
        return "1.5";
    }

    /// @notice Get the balance of want held idle in the Strategy
    /// @notice public because used internally for accounting
    function balanceOfWant() public view returns (uint256) {
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    /// @notice Get the total balance of want realized in the strategy, whether idle or active in Strategy positions.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    /// @dev Returns the boolean that tells whether this strategy is supposed to be tended or not
    /// @notice This is basically a constant, the harvest bots checks if this is true and in that case will call `tend`
    function isTendable() public pure returns (bool) {
        return _isTendable();
    }

    //** add new function
    function _isTendable() internal pure virtual returns (bool);
    
    /// @dev Used to verify if a token can be transfered / sweeped (as it's not part of the strategy)
    function isProtectedToken(address token) public view returns (bool) {
        require(token != address(0), "Address 0");
        address[] memory protectedTokens = getProtectedTokens();
        for (uint256 i = 0; i < protectedTokens.length; i++) {
            if (token == protectedTokens[i]) {
                return true;
            }
        }
        return false;
    }

    /// @dev gets the governance
    function governance() public view returns (address) {
        return IVault(vault).governance();
    }

    /// @dev gets the strategist
    function strategist() public view returns (address) {
        return IVault(vault).strategist();
    }

    /// @dev gets the keeper
    function keeper() public view returns (address) {
        return IVault(vault).keeper();
    }

    /// @dev gets the guardian
    function guardian() public view returns (address) {
        return IVault(vault).guardian();
    }

    /// ===== Permissioned Actions: Governance =====

    //** delete setVault 
    // function setVault(address _vault) external {
    //     // I think we'll remove this
    //     // Make strat unable to change vault so that it can't be used to swap / rug
    //     _onlyGovernance();
    //     vault = _vault;
    // }

    /// @dev Allows to change withdrawalMaxDeviationThreshold
    /// @notice Anytime a withdrawal is done, the vault uses the current assets `vault.balance()` to calculate the value of each share
    /// @notice When the strategy calls `_withdraw` it uses this variable as a slippage check against the actual funds withdrawn
    //**  add emit event
    function setWithdrawalMaxDeviationThreshold(uint256 _threshold) external {
        _onlyGovernance();
        require(_threshold <= MAX, "Withdraw Deviation threshold should be <= MAX_BPS");
        withdrawalMaxDeviationThreshold = _threshold;
    }

    /// @dev Calls deposit, see below
    function earn() public whenNotPaused {
        deposit();
    }

    /// @dev Causes the strategy to `_deposit` the idle want sitting in the strategy
    /// @notice Is basically the same as tend, except without custom code for it
    /// deposit to Vault in token want, need to overwrite _deposit
    function deposit() public whenNotPaused {
        _onlyAuthorizedActorsOrVault();
        uint256 _amount = IERC20Upgradeable(want).balanceOf(address(this));
        if (_amount > 0) {
            _deposit(_amount);
        }
    }

    // ===== Permissioned Actions: Vault =====

    /// @notice Vault-only function to Withdraw partial funds, normally used with a vault withdrawal
    /// @notice This can be called even when paused, and strategist can trigger this
    /// @notice the idea is that this can allow recovery of funds back to the strategy faster
    /// @notice the risk is that if _withdrawAll causes a loss this can be triggered
    /// @notice however the loss could only be triggered once (just like if governance called)
    /// @notice as pausing the strats would prevent earning again
    //** need to overwrite _withdrawAll */
    function withdrawToVault() external whenNotPaused returns (uint256 balance) {
        _onlyVault();

        _withdrawAll();

        balance = IERC20Upgradeable(want).balanceOf(address(this));
        _transferToVault(balance);

        return balance;
    }

    /// @notice Withdraw partial funds from the strategy, unrolling from strategy positions as necessary
    /// @dev If it fails to recover sufficient funds (defined by withdrawalMaxDeviationThreshold), the withdrawal should fail so that this unexpected behavior can be investigated
    // function withdraw(uint256 _amount) external whenNotPaused {
    //     _onlyVault();
    //     require(_amount != 0, "Amount 0");

    //     // Withdraw from strategy positions, typically taking from any idle want first.
    //     _withdrawSome(_amount);
    //     uint256 _postWithdraw = IERC20Upgradeable(want).balanceOf(address(this));

    //     // Sanity check: Ensure we were able to retrieve sufficent want from strategy positions
    //     // If we end up with less than the amount requested, make sure it does not deviate beyond a maximum threshold
    //     if (_postWithdraw < _amount) {
    //         uint256 diff = _diff(_amount, _postWithdraw);

    //         // Require that difference between expected and actual values is less than the deviation threshold percentage
    //         require(
    //             diff <=
    //                 _amount.mul(withdrawalMaxDeviationThreshold).div(MAX), 
    //             "withdraw-exceed-max-deviation-threshold"
    //         );
    //     }

    //     // Return the amount actually withdrawn if less than amount requested
    //     uint256 _toWithdraw = MathUpgradeable.min(_postWithdraw, _amount);

    //     // Transfer remaining to Vault to handle withdrawal
    //     _transferToVault(_toWithdraw);
    // }

    /// @notice withdraw functions in BaseStrategy is not suited for leverage strategy. Overwrite the function.
    /// @notice leverage strategy should consider reserve, so than you can withdraw all want token balance
    /// @notice This function is called by vault.

    /// ## Badge Mix
    function withdraw(uint256 _amount) external whenNotPaused {
        _onlyVault();
        require(_amount != 0, "Amount 0");

        _withdrawSome(_amount);
    }
    /// ## Badge Mix

    // NOTE: must exclude any tokens used in the yield
    // Vault role - withdraw should return to Vault
    /// @return balance - balance of asset withdrawn
    function withdrawOther(address _asset) external whenNotPaused returns (uint256 balance) {
        _onlyVault();
        _onlyNotProtectedTokens(_asset);
        balance = IERC20Upgradeable(_asset).balanceOf(address(this));
        IERC20Upgradeable(_asset).safeTransfer(vault, balance);
        IVault(vault).reportAdditionalToken(_asset);
        return balance;
    }

    /// ===== Permissioned Actions: Authoized Contract Pausers =====

    /// @dev Pause the contract
    /// @notice Check the `onlyWhenPaused` modifier for functionality that is blocked when pausing
    function pause() external {
        _onlyAuthorizedPausers();
        _pause();
    }

    /// @dev Unpause the contract
    /// @notice while a guardian can also pause, only governance (multisig with timelock) can unpause
    function unpause() external {
        _onlyGovernance();
        _unpause();
    }

    /// ===== Internal Helper Functions =====

    /// @dev function to transfer specific amount of want to vault from strategy
    /// @notice strategy should have idle funds >= _amount for this to happen
    /// @param _amount: the amount of want token to transfer to vault
    function _transferToVault(uint256 _amount) internal {
        if (_amount > 0) {
            IERC20Upgradeable(want).safeTransfer(vault, _amount);
        }
    }

    /// @dev function to report harvest to vault
    /// @param _harvestedAmount: amount of want token autocompounded during harvest
    //** to call vault.report, internal function will be called in Mystrategy
    function _reportToVault(
        uint256 _harvestedAmount
    ) internal {
        IERC20Upgradeable(want).safeTransfer(vault, _harvestedAmount);
        IVault(vault).report(_harvestedAmount);
    }

    /// @dev Report additional token income to the Vault, handles fees and sends directly to tree
    /// @notice This is how you emit tokens in V1.5
    /// @notice After calling this function, the tokens are gone, sent to fee receivers and badgerTree
    /// @notice This is a rug vector as it allows to move funds to the tree
    /// @notice for this reason I highly recommend you verify the tree is the badgerTree from the registry
    /// @notice also check for this to be used exclusively on harvest, exclusively on protectedTokens
    //**  change
    function _processExtraToken(address _token, uint256 _amount) internal {
        require(_token != want, "Not want, use _reportToVault");
        require(_token != address(0), "Address 0");
        require(_amount != 0, "Amount 0");

        IERC20Upgradeable(_token).safeTransfer(vault, _amount);
        IVault(vault).reportAdditionalToken(_token);
    }

    /// @notice Utility function to diff two numbers, expects higher value in first position
    function _diff(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Expected higher number in first position");
        return a.sub(b);
    }

    // function setAutoCompoundRatio(uint256 _ratio) internal {
    //     require(_ratio <= MAX, "base-strategy/excessive-auto-compound-ratio");
    //     autoCompoundRatio = _ratio;
    // }

    // ===== Abstract Functions: To be implemented by specific Strategies =====

    /// @dev Internal deposit logic to be implemented by Stratgies
    /// @param _want: the amount of want token to be deposited into the strategy
    //** realise in mystrategy
    function _deposit(uint256 _want) internal virtual;

    /// @notice Specify tokens used in yield process, should not be available to withdraw via withdrawOther()
    /// @param _asset: address of asset
    function _onlyNotProtectedTokens(address _asset) internal view {
        require(!isProtectedToken(_asset), "_onlyNotProtectedTokens");
    }

    /// @dev Gives the list of protected tokens
    /// @return array of protected tokens
    //* need to overwrite
    function getProtectedTokens() public view virtual returns (address[] memory);

    /// @dev Internal logic for strategy migration. Should exit positions as efficiently as possible
    function _withdrawAll() internal virtual;

    /// @dev Internal logic for partial withdrawals. Should exit positions as efficiently as possible.
    /// @dev The withdraw() function shell automatically uses idle want in the strategy before attempting to withdraw more using this
    /// @param _amount: the amount of want token to be withdrawm from the strategy
    /// @return withdrawn amount from the strategy
    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);

    /// @dev Realize returns from positions
    /// @dev Returns can be reinvested into positions, or distributed in another fashion
    /// @return harvested : total amount harvested
    // function harvest() external virtual returns (uint256 harvested);
    //** return change and add _harvest() and tend()
        function harvest()
        external
        whenNotPaused
        returns (TokenAmount[] memory harvested)
    {
        _onlyAuthorizedActors();
        return _harvest();
    }

    function _harvest() internal virtual returns (TokenAmount[] memory harvested);

    function tend()
        external
        whenNotPaused
        returns (TokenAmount[] memory tended)
    {
        _onlyAuthorizedActors();

        return _tend();
    }

    function _tend() internal virtual returns (TokenAmount[] memory tended);

    /// @dev User-friendly name for this strategy for purposes of convenient reading
    /// @return Name of the strategy
    function getName() external pure virtual returns (string memory);

    /// @dev Balance of want currently held in strategy positions
    /// @return balance of want held in strategy positions
    function balanceOfPool() public view virtual returns (uint256);

    /// @dev Calculate the total amount of rewards accured.
    /// @notice if there are multiple reward tokens this function should take all of them into account
    /// @return rewards - the TokenAmount of rewards accured
    //** return rewards change
    function balanceOfRewards() public view virtual returns (TokenAmount[] memory rewards);

    uint256[49] private __gap;
}


contract MyStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    // constant SCREAM address
    address public constant comptroller = 0x260E596DAbE3AFc463e75B6CC05d8c46aCAcFB09;  //Scream unitroller address
    address public constant iToken = 0x4565DC3Ef685E4775cdF920129111DdF43B9d882;      //iToken address scWBtc
    address public constant screamToken = 0xe0654C8e6fd4D733349ac7E09f6f23DA256bF475; //claimComp Token address; SCREAM token
    address public constant wftmToken = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;    //wFtm Token address
    address[] public markets;       //Scream Markets, here is just scWBtc

    // constant swap address using Spooky Swap
    address public constant unirouter = 0xF491e7B69E4244ad4002BC14e878a34207E38c29;   //Spooky Swap address
    address[] public swapToWantRoute;     //Scream -> WFtm -> WBtc, three address

    // variables to configure the risk and leverage
    uint256 public borrowRate;                     // the % percentage of collateral per leverage level
    uint256 public borrowRateMax;                  // a limit for collateral rate per leverage level; Scream official limit is 75%
    uint256 public borrowDepth;                    // the number of leverage levels we will stake and borrow  
    uint256 public minLeverage;                    // the minimum amount of balance to leverage
    uint256 public constant BORROW_DEPTH_MAX = 10; // the maximum number of leverage levels we will stake and borrow      
    uint256 public reserves;                       // need some amount of underlying token (here WBtc) reserve to deleverage 
    uint256 public balanceInPool;                  // overall balance of this strategy in iToken (here scWBtc) 


    // event
    event DepositMoreThanAvailable(uint256 depositAmount, uint256 availableAmount);
    event BorrowConfigureRenew(uint256 borrowRate, uint256 borrowDepth);
    event ComptrollerNotWorking(address comptroller);

    //Emitted when claimComp harvest 
    event ClaimCompHarvest(
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    ); 

    //Emitted when withdraw less than want 
    event WithdrawLessThanWant(
        address indexed token,
        uint256 amount,
        uint256 indexed blockNumber,
        uint256 timestamp
    );

    event claimComGain(uint256 _claimCompGain);


    /// @dev Initialize the Strategy with security settings as well as tokens
    /// @notice Proxies will set any non constant variable you declare as default value
    /// @dev add any extra changeable variable at end of initializer as shown
    function initialize(address _vault, address[1] memory _wantConfig) public initializer {
        __BaseStrategy_init(_vault);
        /// @dev Add config here
        want = _wantConfig[0];

        /// @dev set the default value
        borrowRate = 60;   // 60%
        borrowRateMax = 75;   // 75%
        borrowDepth = 5;   // 5
        minLeverage = 1;   // 1

        ///@dev set allownance
        _setAllowances();

        ///@dev swap to want path
        swapToWantRoute = new address[](3);
        swapToWantRoute[0] = screamToken;
        swapToWantRoute[1] = wftmToken;
        swapToWantRoute[2] = want;

        ///@dev enter markets to stake and borrow in Scream
        markets.push(iToken);                             // add the iToken market address
        IComptroller(comptroller).enterMarkets(markets);  // enter scWbtc market for this strategy
    }
    
    /// @dev Return the name of the strategy
    function getName() external pure override returns (string memory) {
        return "StrategyBadger-ScreamWBtc";
    }

    /// @dev Return a list of protected tokens
    /// @notice It's very important all tokens that are meant to be in the strategy to be marked as protected
    /// @notice this provides security guarantees to the depositors they can't be sweeped away
    function getProtectedTokens() public view virtual override returns (address[] memory) {
        address[] memory protectedTokens = new address[](4);
        protectedTokens[0] = want;
        protectedTokens[1] = iToken;
        protectedTokens[2] = wftmToken;
        protectedTokens[3] = screamToken;
        return protectedTokens;
    }

    /// @dev Deposit `_amount` of want, investing it to earn yield
    function _deposit(uint256 _amount) internal override {
        // Add code here to invest `_amount` of want to earn yield 
        uint256 wantBal = availableWant();
        if (_amount > wantBal) {
            emit DepositMoreThanAvailable(_amount, wantBal);            
            _amount = wantBal;
        }
        if (_amount > minLeverage) {
            _leverage(_amount);
        }
    }

    /// @dev Withdraw all funds, this is used for migrations, most of the time for emergency reasons
    /// @notice deleverage all, and send all underlying tokes to vault
    function _withdrawAll() internal override {
        
        _deleverage();
        uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        IERC20Upgradeable(want).safeTransfer(vault, wantBal);

    }

    /// @dev Withdraw `_amount` of want, so that it can be sent to the vault
    /// @param _amount amount of want to withdraw
    /// @return wantBal amount actually withdrawn
    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        
        uint256 wantBal = availableWant();

        if (wantBal < _amount) {
            _deleverage();
            wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        IERC20Upgradeable(want).safeTransfer(vault, wantBal);

        //@dev if withdraw less than want, need to emit event, but not revert
        if (wantBal < _amount) {
            uint256 diff = _diff(_amount, wantBal).mul(10_000).div(_amount);
            // uint256 diff = _diff(_amount, wantBal);
            if (diff >= withdrawalMaxDeviationThreshold) {
                emit WithdrawLessThanWant(
                    address(want),
                    diff,
                    block.number,
                    block.timestamp
                );
            } 
        }
        uint256 _avlWantBl = availableWant();
        if ( _avlWantBl > minLeverage) {
            _leverage(_avlWantBl);
        } 

        return wantBal;
    }


    /// @dev Does this function require `tend` to be called?
    function _isTendable() internal override pure returns (bool) {
        return true; // Change to true if the strategy should be tended
    }

    /**
     * @dev harvest the SCREAM token
     * @notice core internal function to harvest
    */
    function _harvest() internal override returns (TokenAmount[] memory harvested) {
        
        // get balance before operation
        uint256 _before = IERC20Upgradeable(want).balanceOf(address(this));

        harvested = new TokenAmount[](1);

        if (IComptroller(comptroller).pendingComptrollerImplementation() == address(0)) 
        {
            // Get the SCREAM Token Reward
            IComptroller(comptroller).claimComp(address(this), markets);
            uint256 outputBal = IERC20Upgradeable(screamToken).balanceOf(address(this));
            harvested[0] = TokenAmount(screamToken, outputBal);
            // Swap from scream token to want token
            IUniswapV2Router02(unirouter).swapExactTokensForTokens(
                outputBal,
                0,
                swapToWantRoute,
                address(this),
                now
            );
            // for calculating the amount harvested
            uint256 _after = IERC20Upgradeable(want).balanceOf(address(this));
            uint256 _claimCompGain = _after.sub(_before);


            /// @notice report the amount of want harvested to the sett and calculate the fee
            /// @notice If consider borrow and supply balance in iToken, the amout is higher than the whole estimated profit.
            // But borrow and supply balance is not leveraged and converted to underlying token, the whole estimated profict
            // is an estimate, not the real profit. There is no need to deleverage and leverage all tokens just to
            // get the real profit.
            emit ClaimCompHarvest(
                    address(want),
                    _claimCompGain,
                    block.number,
                    block.timestamp
            );
            _reportToVault(_claimCompGain);

            // Leverage the underlying token to earn again
            uint256 wantBal = availableWant();
            if (wantBal > minLeverage) {
                _leverage(wantBal);
            }    

        } else {
            //scream is not working, pause now
            _pause();
            _deleverage();
            _removeAllowances();
            harvested[0] = TokenAmount(screamToken, 0);

            emit ComptrollerNotWorking(comptroller);
        }
        return harvested;
    }


    /// @dev Leverage any left want token
    function _tend() internal override returns (TokenAmount[] memory tended){
        // Nothing tended
        uint256 wantBal = availableWant();
        tended = new TokenAmount[](1);

        if(wantBal > minLeverage) {
            _leverage(wantBal);
            tended[0] = TokenAmount(want, wantBal);
        } else {
            tended[0] = TokenAmount(want, 0);
        }
        return tended;
    }

    /// @dev Return the balance (in want) that the strategy has invested somewhere
    function balanceOfPool() public view override returns (uint256) {
        return balanceInPool;
    }

    /// @dev Return the balance of rewards that the strategy has accrued
    /// @notice Used for offChain APY and Harvest Health monitoring
    function balanceOfRewards() public view override returns (TokenAmount[] memory rewards) {
        rewards = new TokenAmount[](1);
        rewards[0] = TokenAmount(screamToken, IERC20Upgradeable(screamToken).balanceOf(address(this)));
        return rewards;
    }

    /*********************************************************************************/
    /*********************************  New Function *********************************/
    /*********************************************************************************/

    /// @dev set allowance
    function _setAllowances() internal {
        IERC20Upgradeable(want).safeApprove(iToken, uint256(-1));
        IERC20Upgradeable(screamToken).safeApprove(unirouter, uint256(-1));
    }

    /// @dev remove allowance
    function _removeAllowances() internal {
        IERC20Upgradeable(want).safeApprove(iToken, 0);
        IERC20Upgradeable(screamToken).safeApprove(unirouter, 0);
    }

    /// @dev get the want token balance minus the reserves
    function availableWant() public view returns (uint256) {
        uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        return wantBal.sub(reserves);
    }

    /**
     * @dev Repeat to leverage given the _amount, borrowDepth times 
     * @param _amount amount of want to leverage
     * @notice core internal function to leverage
    */
    function _leverage(uint256 _amount) internal {

        require(_amount > minLeverage, "Leverage amount is little!");

        for (uint256 i = 0; i < borrowDepth; i++) {
            //callrout: scWbtc -> implementation -> doTransferIn -> transferFrom
            IVToken(iToken).mint(_amount);
            _amount = _amount.mul(borrowRate).div(100);
            //callrout: scWbtc -> implementation -> doTransferOut -> transfer
            IVToken(iToken).borrow(_amount);
        }

        // reserves + _amount, there is still _amount do not use.
        // to assure have enough reserves to repay the last borrow amount, for the sake of risk
        reserves = reserves.add(_amount);

        updatePoolBalance();
    }

    /**
     * @dev deleverage all
     * @notice core internal function to deleverage
    */
    function _deleverage() internal {

        uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        uint256 borrowBal = IVToken(iToken).borrowBalanceCurrent(address(this));

        while (wantBal < borrowBal) {
            IVToken(iToken).repayBorrow(wantBal);

            borrowBal = IVToken(iToken).borrowBalanceCurrent(address(this));
            uint256 targetSupply = borrowBal.mul(100).div(borrowRate);

            uint256 supplyBal = IVToken(iToken).balanceOfUnderlying(
                address(this)
            );
            IVToken(iToken).redeemUnderlying(supplyBal.sub(targetSupply));
            wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        }

        IVToken(iToken).repayBorrow(uint256(-1));

        // If there is iToken left, redeem iToken to want token 
        uint256 iTokenBal = IERC20Upgradeable(iToken).balanceOf(address(this));
        IVToken(iToken).redeem(iTokenBal);

        // deleverage all, there is no need to reserve
        reserves = 0;

        updatePoolBalance();
    }

    /**
     * @dev _deleverage() unwinds for many times, so the want token balance may not afford the function call
     * in consideration of gascost. If the current borrowRate is less than borrowRateMax, we can raise the 
     * borrowRate a little to get some more underlying tokens back to afford function call cost.  
     * @param _borrowRate configurable borrow rate in case it's required to unwind successfully
     */
    function deleverageOnce(uint256 _borrowRate) external {
        _onlyAuthorizedActors();

        require(_borrowRate <= borrowRateMax, "Borrow rate too high!");

        uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        IVToken(iToken).repayBorrow(wantBal);

        uint256 borrowBal = IVToken(iToken).borrowBalanceCurrent(address(this));
        uint256 targetSupply = borrowBal.mul(100).div(_borrowRate);

        uint256 supplyBal = IVToken(iToken).balanceOfUnderlying(address(this));
        IVToken(iToken).redeemUnderlying(supplyBal.sub(targetSupply));

        wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        reserves = wantBal;

        updatePoolBalance();
    }

    /**
     * @dev Updates the risk profile and rebalances the vault funds accordingly.
     * @param _borrowRate percent to borrow on each leverage level.
     * @param _borrowDepth how many levels to leverage the funds.
     */
    function rebalance(uint256 _borrowRate, uint256 _borrowDepth) external
    {
        _onlyAuthorizedActors();

        require(_borrowRate <= borrowRateMax, "Borrow rate too high!");
        require(_borrowDepth <= BORROW_DEPTH_MAX, "Borrow depth too more!");

        _deleverage();
        borrowRate = _borrowRate;
        borrowDepth = _borrowDepth;

        uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        _leverage(wantBal);

        emit BorrowConfigureRenew(borrowRate, borrowDepth);
    }

    /// @dev update the iToken pool balance based on the supplyBal and borrowBal
    function updatePoolBalance() public {
        uint256 supplyBal = IVToken(iToken).balanceOfUnderlying(address(this));
        uint256 borrowBal = IVToken(iToken).borrowBalanceCurrent(address(this));
        balanceInPool = supplyBal.sub(borrowBal);
    }

    /// @dev pause the strategy from governance or keeper
    function pauseStrategy() external {
        _onlyAuthorizedActors();

        _pause();
        _deleverage();
        _removeAllowances();
    }
 
    /// @dev unpause the strategy from governance or keeper
    function unpauseStrategy() external {
        _onlyAuthorizedActors();
        
        _unpause();
        _setAllowances();
        uint256 wantBal = availableWant();
        if (wantBal > minLeverage) {
            _leverage(wantBal);
        }
    }

}