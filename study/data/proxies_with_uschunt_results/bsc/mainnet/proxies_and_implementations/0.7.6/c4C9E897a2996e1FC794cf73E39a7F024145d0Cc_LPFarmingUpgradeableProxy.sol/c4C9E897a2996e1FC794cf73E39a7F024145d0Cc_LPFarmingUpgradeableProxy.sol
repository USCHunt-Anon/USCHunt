/**
 *Submitted for verification at BscScan.com on 2021-09-08
*/

// ////-License-Identifier: MIT

pragma solidity ^0.7.6;

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
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
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
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

contract UpgradeableProxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal virtual {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
}

contract TransparentUpgradeableProxy is UpgradeableProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
    }

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _admin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external virtual ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable virtual ifAdmin {
        _upgradeTo(newImplementation);
        Address.functionDelegateCall(newImplementation, data);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

contract LPFarmingUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {

    }
}

// : MIT

pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
    }

    function initOwner(address ownerAddr) internal {
        _owner = ownerAddr;
        emit OwnershipTransferred(address(0), ownerAddr);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
    }

    function initGuard() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

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

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

interface IPancakeSwapV2Factory {
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

interface IPancakeSwapV2Pair {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

interface IDexfToken is IERC20 {
    function getDailyStakingReward(
        uint256 day
    ) external view returns (uint256);

    function getDailyStakingRewardAfterEpochInit(
        uint256 day
    ) external returns (uint256);

    function claimStakingReward(
        address recipient,
        uint256 amount
    ) external;
}

contract LPFarming is Context, Ownable, ReentrancyGuard, Initializable {
    using SafeMath for uint256;
    using SafeMath for uint128;

    uint128 constant private BASE_MULTIPLIER = uint128(1 * 10 ** 18);
    uint128 constant private MIN_LOCK_DURATION = uint128(4); // 4 weeks
    uint128 constant private MAX_LOCK_DURATION = uint128(104); // 104 weeks

    // timestamp for the epoch 1
    // everything before that is considered epoch 0 which won't have a reward but allows for the initial stake
    uint256 public _epoch1Start;

    // duration of each epoch
    uint256 public _epochDuration;

    struct Stake {
        uint256 amount;
        uint128 startEpochId;
        uint128 endEpochId;
        uint128 lockWeeks;
        uint256 claimedAmount;
        uint128 lastClaimEpochId;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    // _stakes[user][]
    mapping(address => Stake[]) private _stakes;

    mapping(uint128 => uint256) public totalMultipliers;

    struct Checkpoint {
        uint256 timestamp;
        uint256 multiplier;
    }

    // total multiplier checkpoints
    mapping(uint32 => Checkpoint) public checkpoints;
    uint32 public numCheckpoints;

    // id of last init epoch, for optimization purposes moved from struct to a single id.
    uint128 public lastInitializedEpoch;

    IDexfToken public _dexf;

    IPancakeSwapV2Pair public dexfBNBV2Pair;
    IPancakeSwapV2Router02 private _pancakeswapV2Router;

    mapping (uint256 => uint256) public dailyStakingRewards;
    uint256 public totalRewardDistributed;

    uint16[100] private _multipliers;

    address public stakingVault;

    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event EmergencyWithdraw(address indexed account, uint128 index, uint256 amount);
    event ClaimedReward(address indexed owner, uint256 amount);
    event Received(address sender, uint amount);
    event ManualEpochInit(address indexed caller, uint128 indexed epochId);
    event SwapAndLiquifyFromBNB(address indexed msgSender, uint256 totAmount, uint256 bnbAmount, uint256 amount);

    constructor() {
    }

    function initialize(address dexf, address owner) public initializer {
        _dexf = IDexfToken(dexf);

        _pancakeswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a Pancakeswap pair for dexf
        address pair = IPancakeSwapV2Factory(_pancakeswapV2Router.factory())
            .getPair(address(_dexf), _pancakeswapV2Router.WETH());
        if (pair != address(0)) {
            dexfBNBV2Pair = IPancakeSwapV2Pair(pair);
        } else {
            dexfBNBV2Pair = IPancakeSwapV2Pair(IPancakeSwapV2Factory(_pancakeswapV2Router.factory())
                .createPair(address(_dexf), _pancakeswapV2Router.WETH()));
        }

        _epoch1Start = block.timestamp + 1 weeks;
        _epochDuration = 24 hours;

        initOwner(owner);
        initGuard();
    }

    /**
     * @dev Set multipliers. Call by only owner.
     */
    function setMultipliers(uint16[100] memory multipliers) external onlyOwner {
        _multipliers = multipliers;
    }

    /**
     * @dev Set epoch 1 start time. Call by only owner.
     */
    function setEpoch1Start(uint256 epochStartTime) external onlyOwner {
        _epoch1Start = epochStartTime;
    }

    function setStakingVault(address _stakingVault) external onlyOwner {
        stakingVault = _stakingVault;
    }

    /*
     * Returns the id of the current epoch derived from block.timestamp
     */
    function getCurrentEpoch() public view returns (uint128) {
        if (block.timestamp < _epoch1Start) {
            return 0;
        }

        return uint128((block.timestamp - _epoch1Start) / _epochDuration + 1);
    }

    function getStakes(address account) public view returns (Stake[] memory) {
        return _stakes[account];
    }

    function calcMultiplier(uint256 numOfWeeks) public view returns (uint256) {
        if (numOfWeeks < 4) {
            return 0;
        } else if (numOfWeeks >= 104) {
            return 300;
        } else {
            return _multipliers[numOfWeeks - 4] > 0 ? uint256(_multipliers[numOfWeeks - 4]) : 100;
        }
    }

    function _initEpoch(uint128 epochId) internal {
        require(epochId <= getCurrentEpoch(), "Can't init a future epoch");
        require(epochId > lastInitializedEpoch, "Already initialized");

        for (uint128 i = lastInitializedEpoch + 1; i <= epochId; i++) {
            totalMultipliers[i] = totalMultipliers[i - 1];

            uint256 rewardForDay = _dexf.getDailyStakingRewardAfterEpochInit(i);
            require(rewardForDay > 0, "Farming: invalid reward");
            dailyStakingRewards[i] = rewardForDay;
        }
        lastInitializedEpoch = epochId;
    }

    /*
     * manualEpochInit can be used to initialize an epoch based on the previous one
     * This is only applicable if there was no action (deposit/withdraw) in the current epoch.
     * Any deposit and withdraw will automatically initialize the current epoch.
     */
    function manualEpochInit(uint128 epochId) public {
        _initEpoch(epochId);

        emit ManualEpochInit(msg.sender, epochId);
    }

    function swapBNBForTokens(uint256 bnbAmount) private {
        address[] memory path = new address[](2);
        path[0] = _pancakeswapV2Router.WETH();
        path[1] = address(_dexf);

        // make the swap
        _pancakeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: bnbAmount
        }(0, path, address(this), block.timestamp);
    }

    function addLiquidityBNB(uint256 tokenAmount, uint256 bnbAmount) private {
        _dexf.approve(address(_pancakeswapV2Router), tokenAmount);

        uint256 initialBnbAmount = address(this).balance.sub(bnbAmount);
        uint256 initialTokenAmount = _dexf.balanceOf(address(this)).sub(tokenAmount);

        // add the liquidity
        _pancakeswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(_dexf),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        uint256 bnbBalance = address(this).balance;
        uint256 tokenBalance = _dexf.balanceOf(address(this));
        if (bnbBalance > initialBnbAmount) {
            _msgSender().transfer(bnbBalance.sub(initialBnbAmount));
        }
        if (tokenBalance > initialTokenAmount) {
            _dexf.transfer(_msgSender(), tokenBalance.sub(initialTokenAmount));
        }
    }

    function swapAndLiquifyFromBNB(uint256 amount) private returns (bool) {
        uint256 halfForEth = amount.div(2);
        uint256 otherHalfForDexf = amount.sub(halfForEth);

        uint256 initialBalance = _dexf.balanceOf(address(this));

        // swap BNB for tokens
        swapBNBForTokens(otherHalfForDexf);

        // how much Dexf did we just swap into?
        uint256 newBalance = _dexf.balanceOf(address(this)).sub(initialBalance);

        // add liquidity to pancakeswap
        addLiquidityBNB(newBalance, halfForEth);

        emit SwapAndLiquifyFromBNB(_msgSender(), amount, halfForEth, newBalance);

        return true;
    }

    function swapAndLiquifyFromDexf(uint256 amount) private returns (bool) {
        uint256 halfForEth = amount.div(2);
        uint256 otherHalfForDexf = amount.sub(halfForEth);

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(_dexf);
        path[1] = _pancakeswapV2Router.WETH();

        _dexf.approve(
            address(_pancakeswapV2Router),
            halfForEth
        );

        // swap Dexf for BNB
        _pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            halfForEth,
            0, // accept any amount of pair token
            path,
            address(this),
            block.timestamp
        );

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to pancakeswap
        addLiquidityBNB(otherHalfForDexf, newBalance);

        return true;
    }

    function swapAndLiquifyFromToken(
        address fromTokenAddress,
        uint256 tokenAmount
    ) private returns (bool) {
        address[] memory path = new address[](2);
        path[0] = fromTokenAddress;
        path[1] = _pancakeswapV2Router.WETH();

        IERC20(fromTokenAddress).approve(
            address(_pancakeswapV2Router),
            tokenAmount
        );

        uint256 initialBNBBalance = address(this).balance;

        // make the swap
        _pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of pair token
            path,
            address(this),
            block.timestamp
        );

        uint256 BNBAmount = address(this).balance.sub(initialBNBBalance);

        return swapAndLiquifyFromBNB(BNBAmount);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev Stake BNB
     */
    function stake(uint128 lockWeeks) external payable nonReentrant returns (bool) {
        require(!isContract(_msgSender()), "Farming: Could not be contract.");
        require(lockWeeks >= MIN_LOCK_DURATION && lockWeeks <= MAX_LOCK_DURATION, "Farming: Invalid lock duration");

        // Check Initial Balance
        uint256 initialBalance = dexfBNBV2Pair.balanceOf(address(this));

        require(swapAndLiquifyFromBNB(msg.value), "Farming: Failed to get LP tokens.");

        uint256 newBalance = dexfBNBV2Pair.balanceOf(address(this)).sub(initialBalance);

        uint128 currentEpochId = getCurrentEpoch();

        Stake[] storage stakes = _stakes[_msgSender()];
        stakes.push(Stake(newBalance, currentEpochId, 0, lockWeeks, 0, currentEpochId > 0 ? currentEpochId - 1 : 0, block.timestamp, 0));

        if (lastInitializedEpoch < currentEpochId) {
            _initEpoch(currentEpochId);
        }
        totalMultipliers[currentEpochId] = totalMultipliers[currentEpochId].add(newBalance.mul(calcMultiplier(lockWeeks)));

        if (numCheckpoints == 0) {
            checkpoints[0].timestamp = block.timestamp;
            checkpoints[0].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints = 1;
        } else if (checkpoints[numCheckpoints - 1].timestamp == block.timestamp) {
            checkpoints[numCheckpoints - 1].multiplier = totalMultipliers[currentEpochId];
        } else {
            checkpoints[numCheckpoints].timestamp = block.timestamp;
            checkpoints[numCheckpoints].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints++;
        }

        emit Staked(_msgSender(), newBalance);

        return true;
    }

    /**
     * @dev Stake ERC20 Token
     */
    function stakeToken(
        address fromTokenAddress,
        uint256 tokenAmount,
        uint128 lockWeeks
    ) external nonReentrant returns (bool) {
        require(!isContract(_msgSender()), "Farming: Could not be contract.");
        require(lockWeeks >= MIN_LOCK_DURATION && lockWeeks <= MAX_LOCK_DURATION, "Farming: Invalid lock duration");

        // Transfer token to Contract
        uint256 beforeAmount = IERC20(fromTokenAddress).balanceOf(address(this));
        IERC20(fromTokenAddress).transferFrom(_msgSender(), address(this), tokenAmount);
        uint256 afterAmount = IERC20(fromTokenAddress).balanceOf(address(this));

        // Check Initial Balance
        uint256 initialBalance = dexfBNBV2Pair.balanceOf(address(this));

        require(swapAndLiquifyFromToken(fromTokenAddress, afterAmount.sub(beforeAmount)), "Farming: Failed to get LP tokens.");

        uint256 newBalance = dexfBNBV2Pair.balanceOf(address(this)).sub(initialBalance);

        uint128 currentEpochId = getCurrentEpoch();

        Stake[] storage stakes = _stakes[_msgSender()];
        stakes.push(Stake(newBalance, currentEpochId, 0, lockWeeks, 0, currentEpochId > 0 ? currentEpochId - 1 : 0, block.timestamp, 0));

        if (lastInitializedEpoch < currentEpochId) {
            _initEpoch(currentEpochId);
        }
        totalMultipliers[currentEpochId] = totalMultipliers[currentEpochId].add(newBalance.mul(calcMultiplier(lockWeeks)));

        if (numCheckpoints == 0) {
            checkpoints[0].timestamp = block.timestamp;
            checkpoints[0].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints = 1;
        } else if (checkpoints[numCheckpoints - 1].timestamp == block.timestamp) {
            checkpoints[numCheckpoints - 1].multiplier = totalMultipliers[currentEpochId];
        } else {
            checkpoints[numCheckpoints].timestamp = block.timestamp;
            checkpoints[numCheckpoints].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints++;
        }

        emit Staked(_msgSender(), newBalance);

        return true;
    }

    /**
     * @dev Stake LP Token
     */
    function stakeLPToken(uint256 amount, uint128 lockWeeks) external nonReentrant returns (bool) {
        require(!isContract(_msgSender()), "Farming: Could not be contract.");
        require(lockWeeks >= MIN_LOCK_DURATION && lockWeeks <= MAX_LOCK_DURATION, "Farming: Invalid lock duration");

        // Transfer token to Contract
        dexfBNBV2Pair.transferFrom(_msgSender(), address(this), amount);

        uint128 currentEpochId = getCurrentEpoch();

        Stake[] storage stakes = _stakes[_msgSender()];
        stakes.push(Stake(amount, currentEpochId, 0, lockWeeks, 0, currentEpochId > 0 ? currentEpochId - 1 : 0, block.timestamp, 0));

        if (lastInitializedEpoch < currentEpochId) {
            _initEpoch(currentEpochId);
        }
        totalMultipliers[currentEpochId] = totalMultipliers[currentEpochId].add(amount.mul(calcMultiplier(lockWeeks)));

        if (numCheckpoints == 0) {
            checkpoints[0].timestamp = block.timestamp;
            checkpoints[0].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints = 1;
        } else if (checkpoints[numCheckpoints - 1].timestamp == block.timestamp) {
            checkpoints[numCheckpoints - 1].multiplier = totalMultipliers[currentEpochId];
        } else {
            checkpoints[numCheckpoints].timestamp = block.timestamp;
            checkpoints[numCheckpoints].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints++;
        }

        emit Staked(_msgSender(), amount);

        return true;
    }

    /**
     * @dev Unstake staked Dexf-BNB LP tokens
     */
    function unstake(uint128 index) external returns (bool) {
        require(!isContract(_msgSender()), "Farming: Could not be contract.");

        Stake[] storage stakes = _stakes[_msgSender()];

        require(stakes.length > index && index >= 0, "Farming: Invalid index.");

        uint128 currentEpochId = getCurrentEpoch();

        if (lastInitializedEpoch < currentEpochId) {
            _initEpoch(currentEpochId);
        }
        require(stakes[index].endTimestamp == 0, "Farming: Already unstaked");
        require(currentEpochId > 1 && currentEpochId > stakes[index].startEpochId, "Farming: Invalid unstake.");
        require(currentEpochId > stakes[index].startEpochId + stakes[index].lockWeeks * 7,
            "Farming: Lock is not finished."
        );

        // Transfer token to user
        dexfBNBV2Pair.transfer(_msgSender(), stakes[index].amount);

        stakes[index].endEpochId = currentEpochId - 1;
        stakes[index].endTimestamp = block.timestamp;
        totalMultipliers[currentEpochId] = totalMultipliers[currentEpochId].sub(stakes[index].amount.mul(calcMultiplier(stakes[index].lockWeeks)));

        if (checkpoints[numCheckpoints - 1].timestamp == block.timestamp) {
            checkpoints[numCheckpoints - 1].multiplier = totalMultipliers[currentEpochId];
        } else {
            checkpoints[numCheckpoints].timestamp = block.timestamp;
            checkpoints[numCheckpoints].multiplier = totalMultipliers[currentEpochId];
            numCheckpoints++;
        }

        // Claim reward
        _claimByIndex(index);

        emit Unstaked(_msgSender(), stakes[index].amount);

        return true;
    }

    /**
     * @dev Withdraw without caring about rewards. EMERGENCY ONLY.
     */
    function emergencyWithdraw(uint128 index) external {
        require(!isContract(_msgSender()), "Farming: Could not be contract.");

        Stake[] storage stakes = _stakes[_msgSender()];

        require(stakes.length > index && index >= 0, "Farming: Invalid index.");
        require(stakes[index].endTimestamp == 0, "Farming: Already unstaked");

        // Transfer token to user
        dexfBNBV2Pair.transfer(_msgSender(), stakes[index].amount);

        stakes[index].endEpochId = stakes[index].startEpochId;
        stakes[index].endTimestamp = block.timestamp;
        totalMultipliers[lastInitializedEpoch] = totalMultipliers[lastInitializedEpoch].sub(stakes[index].amount.mul(calcMultiplier(stakes[index].lockWeeks)));

        if (checkpoints[numCheckpoints - 1].timestamp == block.timestamp) {
            checkpoints[numCheckpoints - 1].multiplier = totalMultipliers[lastInitializedEpoch];
        } else {
            checkpoints[numCheckpoints].timestamp = block.timestamp;
            checkpoints[numCheckpoints].multiplier = totalMultipliers[lastInitializedEpoch];
            numCheckpoints++;
        }

        emit EmergencyWithdraw(_msgSender(), index, stakes[index].amount);
    }

    function getTotalClaimAmount(address account) public view returns (uint256) {
        Stake[] storage stakes = _stakes[account];
        uint256 totalAmount;
        for (uint128 i; i < stakes.length; i++) {
            (uint256 amount,) = getClaimAmountByIndex(account, i);
            totalAmount += amount;
        }

        return totalAmount;
    }

    function getClaimAmountByIndex(address account, uint128 index) public view returns (uint256, uint128) {
        uint128 currentEpochId = getCurrentEpoch();
        if (currentEpochId <= 1) {
            return (0, 0);
        }

        Stake[] storage stakes = _stakes[account];

        if (stakes.length <= index || index < 0) {
            return (0, 0);
        }

        uint256 total;
        uint128 lastEpochId = stakes[index].endEpochId > 0 ? stakes[index].endEpochId : currentEpochId - 1;
        for (uint128 i = stakes[index].lastClaimEpochId + 1; i <= lastEpochId; i++) {
            if (totalMultipliers[i] == 0 || dailyStakingRewards[uint256(i)] == 0) {
                lastEpochId = i - 1;
                break;
            }

            total = total.add(
                dailyStakingRewards[uint256(i)].mul(
                    stakes[index].amount.mul(calcMultiplier(stakes[index].lockWeeks))
                ).div(
                    totalMultipliers[i]
                )
            );
        }

        return (total, lastEpochId);
    }

    function _claimByIndex(uint128 index) internal returns (bool) {
        uint128 currentEpochId = getCurrentEpoch();
        if (lastInitializedEpoch < currentEpochId) {
            _initEpoch(currentEpochId);
        }

        (uint256 total, uint128 lastEpochId) = getClaimAmountByIndex(_msgSender() ,index);
        require(total > 0, "Farming: Invalid claim");

        _dexf.transferFrom(stakingVault, _msgSender(), total);
        totalRewardDistributed = totalRewardDistributed.add(total);

        Stake[] storage stakes = _stakes[_msgSender()];
        stakes[index].claimedAmount = stakes[index].claimedAmount + total;
        stakes[index].lastClaimEpochId = lastEpochId;

        emit ClaimedReward(_msgSender(), total);

        return true;
    }

    function getPriorTotalMultiplier(uint256 timestamp) public view returns (uint256) {
        if (numCheckpoints == 0) {
            return 0;
        }
        if (timestamp == 0 || timestamp >= block.timestamp) {
            return checkpoints[numCheckpoints - 1].multiplier;
        }

        // First check most recent multiplier
        if (checkpoints[numCheckpoints - 1].timestamp <= timestamp) {
            return checkpoints[numCheckpoints - 1].multiplier;
        }

        // Next check implicit zero multiplier
        if (checkpoints[0].timestamp > timestamp) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = numCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[center];
            if (cp.timestamp == timestamp) {
                return cp.multiplier;
            } else if (cp.timestamp < timestamp) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[lower].multiplier;
    }

    function getPriorMultiplier(address account, uint256 timestamp) external view returns (uint256, uint256) {
        uint256 checkTime = timestamp;
        if (timestamp == 0) {
            checkTime = block.timestamp;
        }

        Stake[] storage stakes = _stakes[account];
        uint256 multiplier;
        for (uint256 i; i < stakes.length; i++) {
            if (stakes[i].startTimestamp <= checkTime && (stakes[i].endTimestamp == 0 || checkTime < stakes[i].endTimestamp)) {
                multiplier += stakes[i].amount.mul(calcMultiplier(stakes[i].lockWeeks));
            }
        }

        uint256 totalMultiplier = getPriorTotalMultiplier(timestamp);

        return (totalMultiplier, multiplier);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}