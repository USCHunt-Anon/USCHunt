

// ////-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
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
        // _fallback();
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




// ////-License-Identifier: MIT

pragma solidity >=0.6.2;

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




// ////-License-Identifier: MIT

pragma solidity >=0.6.0;

////import "./Proxy.sol";
////import "../utils/Address.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 *
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract UpgradeableProxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) public payable {
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


// ////-License-Identifier: MIT

pragma solidity >=0.6.0;

////import "./UpgradeableProxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is UpgradeableProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
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


// : GPL-2.0-or-later
pragma solidity >=0.6.0;

//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}


//: UNLICENSED
pragma solidity ^0.7.0;

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;

    /**
      * @notice Get the underlying price of a cToken asset
      * @param market The cToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(address market) external virtual view returns (uint);

}


// : GPL-2.0-or-later
pragma solidity ^0.7.0;

//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}


// : GPL-2.0-or-later
pragma solidity ^0.7.0;

interface ISwapper {
  function _swap(
    uint256[] memory amounts,
    address[] memory path,
    address _to
  ) external;

  function getAmountsIn(
    uint256 amountOut,
    address[] memory path
  ) external view returns (uint256[] memory amounts);

  function GetReceiverAddress(
    address[] memory path
  ) external view returns (address);
  
}


//: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
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

//: UNLICENSED
pragma solidity ^0.7.0;

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
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return add(a, b, "SafeMath: addition overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, errorMessage);

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

//: UNLICENSED
pragma solidity ^0.7.0;

contract OwnerConstants {
  uint256 public constant HR48 = 10 minutes;
  address public owner;
  // daily limit contants
  uint256 public constant MAX_LEVEL = 5;
  uint256[] public JulDStakeAmounts = [
    1000 ether,
    2500 ether,
    10000 ether,
    25000 ether,
    100000 ether
  ];
  uint256[] public DailyLimits = [
    100 ether,
    250 ether,
    500 ether,
    2500 ether,
    5000 ether,
    10000 ether
  ];
  uint256[] public CashBackPercents = [10, 200, 300, 400, 500, 600];
  // this is validation period after user change his juld balance for this contract, normally is 30 days. we set 10 mnutes for testing.
  uint256 public levelValidationPeriod;

  // this is reward address for user's withdraw and payment for goods.
  address public treasuryAddress;
  // this address should be deposit juld in his balance and users can get cashback from this address.
  address public financialAddress;
  // master address is used to send USDT tokens when user buy goods.
  address public masterAddress;
  // monthly fee rewarded address
  address public monthlyFeeAddress;
  
  address public pendingTreasuryAddress;
  address public pendingFinancialAddress;
  address public pendingMasterAddress;
  address public pendingMonthlyFeeAddress;
  uint256 public requestTimeOfManagerAddressUpdate;

  // staking contract address, which is used to receive 20% of monthly fee, so staked users can be rewarded from this contract
  address public stakeContractAddress;
  // statking amount of monthly fee
  uint256 public stakePercent = 15 * (100 + 15) ; // 15 %

  // withdraw fee and payment fee should not exeed this amount, 1% is coresponding to 100.
  uint256 public constant MAX_FEE_AMOUNT = 500; // 5%
  // buy fee setting.
  uint256 public buyFeePercent = 100; // 1%
  // withdraw fee setting.
  uint256 public withdrawFeePercent = 10; // 0.1 %
  // unit is usd amount , so decimal is 18
  mapping(address => uint256) public userDailyLimits;
  // Set whether user can use juld as payment asset. normally it is false.
  bool public juldPaymentEnable;
  // Setting for cashback enable or disable
  bool public cashBackEnable;
  // enable or disable for each market
  mapping(address => bool) public _marketEnabled;
  // set monthly fee of user to use card payment, unit is usd amount ( 1e18)
  uint256 public monthlyFeeAmount = 6.99 ether; // 6.99 USD
  // if user pay monthly fee using juld, then he will pay less amount fro this percent. 0% => 0, 100% => 10000
  uint256 public juldMonthlyProfit = 1000; // 10%
  
  bool public emergencyStop;
  
  // events
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );
  event ManagerAddressChanged(
    address owner,
    address treasuryAddress,
    address financialAddress,
    address masterAddress,
    address monthlyFeeAddress
  );
  event BuyFeePercentChanged(
    address owner,
    uint256 newPercent,
    uint256 beforePercent
  );
  event WithdrawFeePercentChanged(
    address owner,
    uint256 newPercent,
    uint256 beforePercent
  );
  event UserDailyLimitChanged(address userAddr, uint256 usdAmount);
  event CashBackEnableChanged(
    address owner,
    bool newEnabled,
    bool beforeEnabled
  );
  event MarketEnableChanged(
    address owner,
    address market,
    bool bEnable,
    bool beforeEnabled
  );
  event JuldPaymentEnabled(
    address owner,
    bool juldPaymentEnable,
    bool bOldEnable
  );
  event MonthlyFeeChanged(
    address owner,
    uint256 monthlyFeeAmount,
    uint256 juldMonthlyProfit
  );
  event LevelValidationPeriodChanged(
    address owner,
    uint256 levelValidationPeriod,
    uint256 beforeValue
  );
  event StakeContractParamChanged(
    address stakeContractAddress,
    uint256 stakePercent
  );
  /// modifier functions
  modifier onlyOwner() {
    require(msg.sender == owner, "oo");
    _;
  }
  modifier noEmergency() {
    require(!emergencyStop, "stopped");
    _;
  }
  constructor() {
    owner = msg.sender;
  }

  /**
   * @notice Get user level from his juld balance
   * @param _juldAmount juld token amount
   * @return user's level, 0~5 , 0 => no level
   */
  // verified
  function getLevel(uint256 _juldAmount) public view returns (uint256) {
    if (_juldAmount < JulDStakeAmounts[0]) return 0;
    if (_juldAmount < JulDStakeAmounts[1]) return 1;
    if (_juldAmount < JulDStakeAmounts[2]) return 2;
    if (_juldAmount < JulDStakeAmounts[3]) return 3;
    if (_juldAmount < JulDStakeAmounts[4]) return 4;
    return 5;
  }

  // verified
  function getDailyLimit(uint256 level) public view returns (uint256) {
    require(level <= 5, "level > 5");
    return DailyLimits[level];
  }

  //verified
  function getCashBackPercent(uint256 level) public view returns (uint256) {
    require(level <= 5, "level > 5");
    return CashBackPercents[level];
  }

  function getMonthlyFeeAmount(bool payFromJulD) public view returns (uint256) {
    uint256 result;
    if (payFromJulD) {
      result =
        monthlyFeeAmount -
        (monthlyFeeAmount * juldMonthlyProfit) /
        10000;
    } else {
      result = monthlyFeeAmount;
    }
    return result;
  }

  // Set functions
  // verified
  function transaferOwnership(address newOwner) public onlyOwner {
    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  // I have to add 48 hours delay in this function
  function setManagerAddresses() public onlyOwner {
    require(block.timestamp > requestTimeOfManagerAddressUpdate + HR48 && requestTimeOfManagerAddressUpdate > 0, "need to wait 48hr");
    treasuryAddress = pendingTreasuryAddress;
    financialAddress = pendingFinancialAddress;
    masterAddress = pendingMasterAddress;
    monthlyFeeAddress = pendingMonthlyFeeAddress;
    requestTimeOfManagerAddressUpdate = 0;
  }
  function requestManagerAddressUpdate(
    address _newTreasuryAddress,
    address _newFinancialAddress,
    address _newMasterAddress,
    address _mothlyFeeAddress
  ) public onlyOwner {
    pendingTreasuryAddress = _newTreasuryAddress;
    pendingFinancialAddress = _newFinancialAddress;
    pendingMasterAddress = _newMasterAddress;
    pendingMonthlyFeeAddress = _mothlyFeeAddress;
    requestTimeOfManagerAddressUpdate = block.timestamp;
  }

  // verified
  function setBuyFeePercent(uint256 newPercent) public onlyOwner {
    require(newPercent <= MAX_FEE_AMOUNT, "buy fee should be less than 5%");
    uint256 beforePercent = buyFeePercent;
    buyFeePercent = newPercent;
    emit BuyFeePercentChanged(owner, newPercent, beforePercent);
  }

  // verified
  function setWithdrawFeePercent(uint256 newPercent) public onlyOwner {
    require(
      newPercent <= MAX_FEE_AMOUNT,
      "withdraw fee should be less than 5%"
    );
    uint256 beforePercent = withdrawFeePercent;
    withdrawFeePercent = newPercent;
    emit WithdrawFeePercentChanged(owner, newPercent, beforePercent);
  }

  // verified
  function setUserDailyLimits(address userAddr, uint256 usdAmount)
    public
    onlyOwner
  {
    userDailyLimits[userAddr] = usdAmount;
    emit UserDailyLimitChanged(userAddr, usdAmount);
  }

  // verified
  function setJulDStakeAmount(uint256 index, uint256 _amount) public onlyOwner {
    require(index < MAX_LEVEL, "level should be less than 5");
    // require(index == 0 || JulDStakeAmounts[index - 1] < _amount, "should be great than low level");
    // require(index == MAX_LEVEL - 1 || JulDStakeAmounts[index + 1] > _amount, "should be less than high level");
    JulDStakeAmounts[index] = _amount;
  }

  // verified
  function setDailyLimit(uint256 index, uint256 _amount) public onlyOwner {
    require(index <= MAX_LEVEL, "level should be equal or less than 5");
    // require(index == 0 || DailyLimits[index - 1] < _amount, "should be great than low level");
    // require(index == MAX_LEVEL || DailyLimits[index + 1] > _amount, "should be less than high level");
    DailyLimits[index] = _amount;
  }

  // verified
  function setCashBackPercent(uint256 index, uint256 _amount) public onlyOwner {
    require(index <= MAX_LEVEL, "level should be equal or less than 5");
    // require(index == 0 || CashBackPercents[index - 1] < _amount, "should be great than low level");
    // require(index == MAX_LEVEL || CashBackPercents[index + 1] > _amount, "should be less than high level");
    CashBackPercents[index] = _amount;
  }

  // verified
  function setCashBackEnable(bool newEnabled) public onlyOwner {
    bool beforeEnabled = cashBackEnable;
    cashBackEnable = newEnabled;
    emit CashBackEnableChanged(owner, newEnabled, beforeEnabled);
  }

  // verified
  function enableMarket(address market, bool bEnable) public onlyOwner {
    bool beforeEnabled = _marketEnabled[market];
    _marketEnabled[market] = bEnable;
    emit MarketEnableChanged(owner, market, bEnable, beforeEnabled);
  }

  // verified
  function setJuldAsPayment(bool bEnable) public onlyOwner {
    bool bOldEnable = juldPaymentEnable;
    juldPaymentEnable = bEnable;
    emit JuldPaymentEnabled(owner, juldPaymentEnable, bOldEnable);
  }

  // verified
  function setMonthlyFee(uint256 usdFeeAmount, uint256 juldProfitPercent)
    public
    onlyOwner
  {
    require(juldProfitPercent <= 10000, "over percent");
    monthlyFeeAmount = usdFeeAmount;
    juldMonthlyProfit = juldProfitPercent;
    emit MonthlyFeeChanged(owner, monthlyFeeAmount, juldMonthlyProfit);
  }

  // verified
  function setLevelValidationPeriod(uint256 _newValue) public onlyOwner {
    uint256 beforeValue = levelValidationPeriod;
    levelValidationPeriod = _newValue;
    emit LevelValidationPeriodChanged(
      owner,
      levelValidationPeriod,
      beforeValue
    );
  }

  function setStakeContractParams(
    address _stakeContractAddress,
    uint256 _stakePercent
  ) public onlyOwner {
    stakeContractAddress = _stakeContractAddress;
    stakePercent = _stakePercent;
    emit StakeContractParamChanged(stakeContractAddress, stakePercent);
  }

  function setEmergencyStop(bool _value) public onlyOwner {
    emergencyStop = _value;
  }


}


//: UNLICENSED
pragma solidity ^0.7.0;
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping(address => bool) bearer;
  }

  /**
   * @dev Give an account access to this role.
   */
  function add(Role storage role, address account) internal {
    require(!has(role, account), "Roles: account already has role");
    role.bearer[account] = true;
  }

  /**
   * @dev Remove an account's access to this role.
   */
  function remove(Role storage role, address account) internal {
    // require(has(role, account), "Roles: account does not have role");
    role.bearer[account] = false;
  }

  /**
   * @dev Check if an account has this role.
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0), "Roles: account is the zero address");
    return role.bearer[account];
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor() {}

  // solhint-disable-previous-line no-empty-blocks

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

abstract contract SignerRole is Context {
  using Roles for Roles.Role;

  event SignerAdded(address indexed account);
  event SignerRemoved(address indexed account);

  Roles.Role private _signers;

  constructor(address _signer) {
    _addSigner(_signer);
  }

  modifier onlySigner() {
    require(
      isSigner(_msgSender()),
      "SignerRole: caller does not have the Signer role"
    );
    _;
  }

  function isSigner(address account) public view returns (bool) {
    return _signers.has(account);
  }

  function _addSigner(address account) internal {
    _signers.add(account);
    emit SignerAdded(account);
  }

  function _removeSigner(address account) internal {
    _signers.remove(account);
    emit SignerRemoved(account);
  }
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


//: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.7.0;
pragma abicoder v2;
// We //importthis library to be able to use console.log
// //import"hardhat/console.sol";
//import"./libraries/TransferHelper.sol";
//import"./interfaces/PriceOracle.sol";
//import"./interfaces/IWETH9.sol";
//import"./interfaces/ISwapper.sol";
//import"./interfaces/ERC20Interface.sol";
//import"./libraries/SafeMath.sol";
//import"./OwnerConstants.sol";
//import"./SignerRole.sol";

// This is the main building block for smart contracts.
contract JulCardV2 is OwnerConstants, SignerRole {
  //  bytes4 public constant PAY_MONTHLY_FEE = bytes4(keccak256(bytes('payMonthlyFee')));
  bytes4 public constant PAY_MONTHLY_FEE = 0x529a8d6c;
  //  bytes4 public constant WITHDRAW = bytes4(keccak256(bytes('withdraw')));
  bytes4 public constant WITHDRAW = 0x855511cc;
  //  bytes4 public constant BUYGOODS = bytes4(keccak256(bytes('buyGoods')));
  bytes4 public constant BUYGOODS = 0xa8fd19f2;
  //  bytes4 public constant SET_USER_MAIN_MARKET = bytes4(keccak256(bytes('setUserMainMarket')));
  bytes4 public constant SET_USER_MAIN_MARKET = 0x4a22142e;
  
  uint256 public constant CARD_VALIDATION_TIME = 10 minutes; // 30 days in prodcution

  using SafeMath for uint256;

  address public immutable WETH;
  // this is main currency for master wallet, master wallet will get always this token. normally we use USDC for this token.
  address public immutable USDT;
  // this is juld token address, which is used for setting of user's daily level and cashback.
  address public immutable juld;
  // default market , which is used when user didn't select any market for his main market
  address public defaultMarket;

  address public swapper;

  // Price oracle address, which is used for verification of swapping assets amount
  address public priceOracle;

  // Governor can set followings:
  address public governorAddress; // Governance address

  /*** Main Actions ***/
  // user's sepnd amount in a day.
  mapping(address => uint256) public usersSpendAmountDay;
  // user's spend date
  // it is needed to calculate how much assets user sold in a day.
  mapping(address => uint256) public usersSpendTime;
  // current user level of each user. 1~5 level enabled.
  mapping(address => uint256) public usersLevel;
  // the time juld amount is updated
  mapping(address => uint256) public usersjuldUpdatedTime;
  // specific user's daily spend limit.
  // this value should be zero in default.
  // if this value is not 0, then return the value and if 0, return limt for user's level.

  // user's deposited balance.
  // user  => ( market => balances)
  mapping(address => mapping(address => uint256)) public usersBalances;

  /// @notice A list of all assets
  address[] public allMarkets;

  // store user's main asset used when user make payment.
  mapping(address => address) public userMainMarket;
  mapping(address => uint256) public userValidTimes;

  //prevent reentrancy attack
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;
  uint256 private _status;
  bool private initialized;
  mapping(uint256 => bool) public _paymentIds;
  struct SignKeys {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }
  struct SignData {
    bytes4 method;
    uint256 id;
    address market;
    address userAddr;
    uint256 amount;
    uint256 validTime;
    address signer;
  }
  // emit event

  event UserBalanceChanged(
    address indexed userAddr,
    address indexed market,
    uint256 amount
  );

  event GovernorAddressChanged(
    address indexed previousGovernor,
    address indexed newGovernor
  );
  event PriceOracleChanged(
    address owner,
    address newOracleAddress,
    address beforePriceOracle
  );
  event SwapperChanged(
    address owner,
    address newSwapper,
    address beforeSwapper
  );
  event MonthlyFeePaid(
    address userAddr,
    uint256 userValidTime,
    uint256 usdAmount
  );
  event UserDeposit(address userAddr, address market, uint256 amount);
  event UserMainMarketChanged(
    uint256 id,
    address userAddr,
    address market,
    address beforeMarket
  );
  event UserWithdraw(
    uint256 id,
    address userAddr,
    address market,
    uint256 amount,
    uint256 remainedBalance
  );
  event UserLevelChanged(address userAddr, uint256 newLevel);
  event SignerBuyGoods(
    uint256 id,
    address relayer,
    address market,
    address userAddr,
    uint256 usdAmount
  );

  // verified
  /**
   * Contract initialization.
   *
   * The `constructor` is executed only once when the contract is created.
   * The `public` modifier makes a function callable from outside the contract.
   */
  constructor(
    address _WETH,
    address _USDT,
    address _juldAddress,
    address _initialSigner
  ) SignerRole(_initialSigner) {
    // The totalSupply is assigned to transaction sender, which is the account
    // that is deploying the contract.
    governorAddress = msg.sender; //initial governor address
    WETH = _WETH;
    juld = _juldAddress;
    USDT = _USDT;

    _status = _NOT_ENTERED;
    initialized = false;
  }

  // verified
  receive() external payable {
    // require(msg.sender == WETH, 'Not WETH9');
  }

  // verified
  function initialize(
    address _priceOracle,
    address _financialAddress,
    address _masterAddress,
    address _treasuryAddress,
    address _governorAddress,
    address _monthlyFeeAddress,
    address _stakeContractAddress,
    address _swapper
  ) public {
    require(!initialized, "already initalized");

    priceOracle = _priceOracle;
    treasuryAddress = _treasuryAddress;
    financialAddress = _financialAddress;
    masterAddress = _masterAddress;
    governorAddress = _governorAddress;
    monthlyFeeAddress = _monthlyFeeAddress;
    stakeContractAddress = _stakeContractAddress;
    swapper = _swapper;
    // levelValidationPeriod = 30 days;
    levelValidationPeriod = 10 minutes; //for testing
    //private variables initialize.
    _status = _NOT_ENTERED;
    initialized = true;
    addMarket(WETH);
    addMarket(USDT);
    addMarket(juld);
    defaultMarket = WETH;
  }

  /// modifier functions
  // verified
  modifier onlyGovernor() {
    require(_msgSender() == governorAddress, "og");
    _;
  }
  // verified
  modifier marketSupported(address market) {
    bool marketExist = false;
    for (uint256 i = 0; i < allMarkets.length; i++) {
      if (allMarkets[i] == market) {
        marketExist = true;
      }
    }
    require(marketExist, "mns");
    _;
  }
  // verified
  modifier marketEnabled(address market) {
    require(_marketEnabled[market], "mdnd");
    _;
  }
  // verified
  modifier noExpired(address userAddr) {
    require(!getUserExpired(userAddr), "user expired");
    _;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  // verified
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, "rc");

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }

  modifier validSignOfSigner(
    SignData calldata sign_data,
    SignKeys calldata sign_key
  ) {
    require(
      isSigner(
        ecrecover(
          toEthSignedMessageHash(
            keccak256(
              abi.encodePacked(
                this,
                sign_data.method,
                sign_data.id,
                sign_data.userAddr,
                sign_data.market,
                sign_data.amount,
                sign_data.validTime
              )
            )
          ),
          sign_key.v,
          sign_key.r,
          sign_key.s
        )
      ),
      "ssst"
    );
    _;
  }
  modifier validSignOfUser(
    SignData calldata sign_data,
    SignKeys calldata sign_key
  ) {
    require(
      sign_data.userAddr ==
        ecrecover(
          toEthSignedMessageHash(
            keccak256(
              abi.encodePacked(
                this,
                sign_data.method,
                sign_data.id,
                sign_data.userAddr,
                sign_data.market,
                sign_data.amount,
                sign_data.validTime
              )
            )
          ),
          sign_key.v,
          sign_key.r,
          sign_key.s
        ),
      "usst"
    );
    _;
  }

  function getUserMainMarket(address userAddr) public view returns (address) {
    if (userMainMarket[userAddr] == address(0)) {
      return defaultMarket; // return default market
    }
    address market = userMainMarket[userAddr];
    if (_marketEnabled[market] == false) {
      return defaultMarket; // return default market
    }
    return market;
  }

  // verified
  function getUserExpired(address _userAddr) public view returns (bool) {
    if (userValidTimes[_userAddr] + 25 days > block.timestamp) {
      return false;
    }
    return true;
  }

  // set Governance address
  function setGovernor(address newGovernor) public onlyGovernor {
    address oldGovernor = governorAddress;
    governorAddress = newGovernor;
    emit GovernorAddressChanged(oldGovernor, newGovernor);
  }

  // verified
  function addMarket(address market) public onlyGovernor {
    _addMarketInternal(market);
  }

  // verified
  function setPriceOracle(address _priceOracle) public onlyGovernor {
    address beforeAddress = priceOracle;
    priceOracle = _priceOracle;
    emit PriceOracleChanged(governorAddress, priceOracle, beforeAddress);
  }

  // verified
  function setSwapper(address _swapper) public onlyGovernor {
    address beforeAddress = _swapper;
    swapper = _swapper;
    emit SwapperChanged(governorAddress, swapper, beforeAddress);
  }

  // verified
  function addSigner(address _signer) public onlyGovernor {
    _addSigner(_signer);
  }

  // verified
  function removeSigner(address _signer) public onlyGovernor {
    _removeSigner(_signer);
  }

  function setDefaultMarket(address market)
    public
    marketEnabled(market)
    marketSupported(market)
    onlyGovernor
  {
    defaultMarket = market;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //returns today's spend amount
  function getSpendAmountToday(address userAddr) public view returns (uint256) {
    uint256 currentDate = block.timestamp / 1 days;
    if (usersSpendTime[userAddr] != currentDate) {
      return 0;
    }
    return usersSpendAmountDay[userAddr];
  }

  function onUpdateUserBalance(
    address userAddr,
    address market,
    uint256 amount,
    uint256 beforeAmount
  ) internal returns (bool) {
    emit UserBalanceChanged(userAddr, market, amount);
    if (market != juld) return true;
    uint256 newLevel = getLevel(usersBalances[userAddr][market]);
    uint256 beforeLevel = getLevel(beforeAmount);
    if (newLevel != beforeLevel)
      usersjuldUpdatedTime[userAddr] = block.timestamp;
    if (newLevel == usersLevel[userAddr]) return true;
    if (newLevel < usersLevel[userAddr]) {
      usersLevel[userAddr] = newLevel;
      emit UserLevelChanged(userAddr, newLevel);
    } else {
      if (
        usersjuldUpdatedTime[userAddr] + levelValidationPeriod < block.timestamp
      ) {
        usersLevel[userAddr] = newLevel;
        emit UserLevelChanged(userAddr, newLevel);
      } else {
        // do somrthing ...
      }
    }
    return false;
  }

  function getUserLevel(address userAddr) public view returns (uint256) {
    uint256 newLevel = getLevel(usersBalances[userAddr][juld]);
    if (newLevel < usersLevel[userAddr]) {
      return newLevel;
    } else {
      if (
        usersjuldUpdatedTime[userAddr] + levelValidationPeriod < block.timestamp
      ) {
        return newLevel;
      } else {
        // do somrthing ...
      }
    }
    return usersLevel[userAddr];
  }

  // decimal of usdAmount is 18
  function withinLimits(address userAddr, uint256 usdAmount)
    public
    view
    returns (bool)
  {
    if (usdAmount <= getUserLimit(userAddr)) return true;
    return false;
  }

  function getUserLimit(address userAddr) public view returns (uint256) {
    uint256 dailyLimit = userDailyLimits[userAddr];
    if (dailyLimit != 0) return dailyLimit;
    uint256 userLevel = getUserLevel(userAddr);
    return getDailyLimit(userLevel);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //verified
  function _addMarketInternal(address assetAddr) internal {
    for (uint256 i = 0; i < allMarkets.length; i++) {
      require(allMarkets[i] != assetAddr, "maa");
    }
    allMarkets.push(assetAddr);
    _marketEnabled[assetAddr] = true;
  }

  // verified
  /**
   * @notice Return all of the markets
   * @dev The automatic getter may be used to access an individual market.
   * @return The list of market addresses
   */
  function getAllMarkets() public view returns (address[] memory) {
    return allMarkets;
  }

  // verified
  function deposit(address market, uint256 amount)
    public
    marketEnabled(market)
    nonReentrant
    noEmergency
  {
    TransferHelper.safeTransferFrom(market, msg.sender, address(this), amount);
    _addUserBalance(market, msg.sender, amount);
    emit UserDeposit(msg.sender, market, amount);
  }

  // verified
  function depositETH() public payable marketEnabled(WETH) nonReentrant {
    IWETH9(WETH).deposit{ value: msg.value }();
    _addUserBalance(WETH, msg.sender, msg.value);
    emit UserDeposit(msg.sender, WETH, msg.value);
  }

  // verified
  function _addUserBalance(
    address market,
    address userAddr,
    uint256 amount
  ) internal marketEnabled(market) {
    uint256 beforeAmount = usersBalances[userAddr][market];
    usersBalances[userAddr][market] += amount;
    onUpdateUserBalance(
      userAddr,
      market,
      usersBalances[userAddr][market],
      beforeAmount
    );
  }

  function setUserMainMarket(
    uint256 id,
    address market,
    uint256 validTime,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    address userAddr = msg.sender;
    if (getUserMainMarket(userAddr) == market) return;
    require(
      isSigner(
        ecrecover(
          toEthSignedMessageHash(
            keccak256(
              abi.encodePacked(
                this,
                SET_USER_MAIN_MARKET,
                id,
                userAddr,
                market,
                uint256(0),
                validTime
              )
            )
          ),
          v,
          r,
          s
        )
      ),
      "summ"
    );
    require(_paymentIds[id] == false, "pru");
    _paymentIds[id] = true;
    require(validTime > block.timestamp, "expired");
    address beforeMarket = getUserMainMarket(userAddr);
    userMainMarket[userAddr] = market;
    emit UserMainMarketChanged(id, userAddr, market, beforeMarket);
  }

  // verified
  function payMonthlyFee(
    SignData calldata _data,
    SignKeys calldata user_key,
    address  market
  ) public nonReentrant
    marketEnabled(market)
    noEmergency
    validSignOfUser(_data, user_key)
    onlySigner
  {
    address userAddr = _data.userAddr;
    require(userValidTimes[userAddr] <= block.timestamp, "e");
    require(monthlyFeeAmount <= _data.amount, "over paid");

    // increase valid period
    uint256 _tempVal;
    // extend user's valid time
    uint256 _monthlyFee = getMonthlyFeeAmount(market == juld);

    userValidTimes[userAddr] = block.timestamp + CARD_VALIDATION_TIME;
    
    if (stakeContractAddress != address(0)) {
      _tempVal = (_monthlyFee * 10000) / (10000 + stakePercent);
    }
    uint256 beforeAmount = usersBalances[userAddr][market];
    calculateAmount(
      market,
      userAddr,
      _tempVal,
      monthlyFeeAddress,
      stakeContractAddress,
      stakePercent
    );
    onUpdateUserBalance(
      userAddr,
      market,
      usersBalances[userAddr][market],
      beforeAmount
    );
    emit MonthlyFeePaid(userAddr, userValidTimes[userAddr], _monthlyFee);
  }

  // verified
  function withdraw(
    uint256 id,
    address market,
    uint256 amount,
    uint256 validTime,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public nonReentrant {
    address userAddr = msg.sender;
    require(
      isSigner(
        ecrecover(
          toEthSignedMessageHash(
            keccak256(
              abi.encodePacked(
                this,
                WITHDRAW,
                id,
                userAddr,
                market,
                amount,
                validTime
              )
            )
          ),
          v,
          r,
          s
        )
      ),
      "ssst"
    );
    require(_paymentIds[id] == false, "pru");
    _paymentIds[id] = true;
    require(validTime > block.timestamp, "expired");
    uint256 beforeAmount = usersBalances[userAddr][market];
    require(beforeAmount >= amount, "ib");
    usersBalances[userAddr][market] = beforeAmount - amount;
    if (market == WETH) {
      IWETH9(WETH).withdraw(amount);
      if (treasuryAddress != address(0)) {
        uint256 feeAmount = (amount * withdrawFeePercent) / 10000;
        if (feeAmount > 0) {
          TransferHelper.safeTransferETH(treasuryAddress, feeAmount);
        }
        TransferHelper.safeTransferETH(msg.sender, amount - feeAmount);
      } else {
        TransferHelper.safeTransferETH(msg.sender, amount);
      }
    } else {
      if (treasuryAddress != address(0)) {
        uint256 feeAmount = (amount * withdrawFeePercent) / 10000;
        if (feeAmount > 0) {
          TransferHelper.safeTransfer(market, treasuryAddress, feeAmount);
        }
        TransferHelper.safeTransfer(market, msg.sender, amount - feeAmount);
      } else {
        TransferHelper.safeTransfer(market, msg.sender, amount);
      }
    }
    onUpdateUserBalance(
      userAddr,
      market,
      usersBalances[userAddr][market],
      beforeAmount
    );
    emit UserWithdraw(
      id,
      userAddr,
      market,
      amount,
      usersBalances[userAddr][market]
    );
  }

  // decimal of usdAmount is 18
  function buyGoods(
    SignData calldata _data,
    SignKeys calldata signer_key
  )
    external
    nonReentrant
    marketEnabled(_data.market)
    noExpired(_data.userAddr)
    noEmergency
    validSignOfSigner(_data, signer_key)
  {
    require(_paymentIds[_data.id] == false, "pru");
    _paymentIds[_data.id] = true;
    if (_data.market == juld) {
      require(juldPaymentEnable, "jsy");
    }
    require(getUserMainMarket(_data.userAddr) == _data.market, "jsy2");
    _makePayment(_data.market, _data.userAddr, _data.amount);
    emit SignerBuyGoods(
      _data.id,
      _data.signer,
      _data.market,
      _data.userAddr,
      _data.amount
    );
  }

  // deduce user assets using usd amount
  // decimal of usdAmount is 18
  // verified
  function _makePayment(
    address market,
    address userAddr,
    uint256 usdAmount
  ) internal {
    uint256 spendAmount = calculateAmount(
      market,
      userAddr,
      usdAmount,
      masterAddress,
      treasuryAddress,
      buyFeePercent
    );

    uint256 currentDate = block.timestamp / 1 days;
    uint256 beforeAmount = usersBalances[userAddr][market];
    uint256 totalSpendAmount;

    if (usersSpendTime[userAddr] != currentDate) {
      usersSpendTime[userAddr] = currentDate;
      totalSpendAmount = spendAmount;
    } else {
      totalSpendAmount = usersSpendAmountDay[userAddr] + spendAmount;
    }

    require(withinLimits(userAddr, totalSpendAmount), "odl");
    cashBack(userAddr, spendAmount);
    usersSpendAmountDay[userAddr] = totalSpendAmount;
    onUpdateUserBalance(
      userAddr,
      market,
      usersBalances[userAddr][market],
      beforeAmount
    );
  }

  // calculate aseet amount from market and required usd amount
  // decimal of usdAmount is 18
  // spendAmount is decimal 18
  function calculateAmount(
    address market,
    address userAddr,
    uint256 usdAmount,
    address targetAddress,
    address feeAddress,
    uint256 feePercent
  ) internal returns (uint256 spendAmount) {
    uint256 addFeeUsdAmount;
    if (feeAddress != address(0)) {
      addFeeUsdAmount = usdAmount + (usdAmount * feePercent) / 10000;
    } else {
      addFeeUsdAmount = usdAmount;
    }
    // change addFeeUsdAmount to USDT asset amounts
    // uint256 assetAmountIn = getAssetAmount(market, addFeeUsdAmount);
    // assetAmountIn = assetAmountIn + assetAmountIn / 10; //price tolerance = 10%
    uint256 usdtTotalAmount = convertUsdAmountToAssetAmount(
      addFeeUsdAmount,
      USDT
    );
    if (market != USDT) {
      // we need to change somehting here, because if there are not pair {market, USDT} , then we have to add another path
      // so please check the path is exist and if no, please add market, weth, usdt to path
      address[] memory path = new address[](2);
      path[0] = market;
      path[1] = USDT;
      uint256[] memory amounts = ISwapper(swapper).getAmountsIn(
        usdtTotalAmount,
        path
      );
      require(amounts[0] <= usersBalances[userAddr][market], "ua");
      usersBalances[userAddr][market] =
        usersBalances[userAddr][market] -
        amounts[0];
      TransferHelper.safeTransfer(
        path[0],
        ISwapper(swapper).GetReceiverAddress(path),
        amounts[0]
      );
      ISwapper(swapper)._swap(amounts, path, address(this));
    } else {
      require(addFeeUsdAmount <= usersBalances[userAddr][market], "uat");
      usersBalances[userAddr][market] =
        usersBalances[userAddr][market] -
        addFeeUsdAmount;
    }
    require(targetAddress != address(0), "mis");
    uint256 usdtAmount = convertUsdAmountToAssetAmount(usdAmount, USDT);
    require(usdtTotalAmount >= usdtAmount, "sp");
    TransferHelper.safeTransfer(USDT, targetAddress, usdtAmount);
    uint256 fee = usdtTotalAmount.sub(usdtAmount);
    if (feeAddress != address(0))
      TransferHelper.safeTransfer(USDT, feeAddress, fee);
    spendAmount = convertAssetAmountToUsdAmount(usdtTotalAmount, USDT);
  }

  function convertUsdAmountToAssetAmount(
    uint256 usdAmount,
    address assetAddress
  ) public view returns (uint256) {
    ERC20Interface token = ERC20Interface(assetAddress);
    uint256 tokenDecimal = uint256(token.decimals());
    uint256 defaultDecimal = 18;
    if (defaultDecimal == tokenDecimal) {
      return usdAmount;
    } else if (defaultDecimal > tokenDecimal) {
      return usdAmount.div(10**(defaultDecimal.sub(tokenDecimal)));
    } else {
      return usdAmount.mul(10**(tokenDecimal.sub(defaultDecimal)));
    }
  }

  function convertAssetAmountToUsdAmount(
    uint256 assetAmount,
    address assetAddress
  ) public view returns (uint256) {
    ERC20Interface token = ERC20Interface(assetAddress);
    uint256 tokenDecimal = uint256(token.decimals());
    uint256 defaultDecimal = 18;
    if (defaultDecimal == tokenDecimal) {
      return assetAmount;
    } else if (defaultDecimal > tokenDecimal) {
      return assetAmount.mul(10**(defaultDecimal.sub(tokenDecimal)));
    } else {
      return assetAmount.div(10**(tokenDecimal.sub(defaultDecimal)));
    }
  }

  function cashBack(address userAddr, uint256 usdAmount) internal {
    if (!cashBackEnable) return;
    uint256 cashBackPercent = getCashBackPercent(getUserLevel(userAddr));
    uint256 juldAmount = getAssetAmount(
      juld,
      (usdAmount * cashBackPercent) / 10000
    );
    // require(ERC20Interface(juld).balanceOf(address(this)) >= juldAmount , "insufficient juld");
    if (usersBalances[financialAddress][juld] > juldAmount) {
      usersBalances[financialAddress][juld] =
        usersBalances[financialAddress][juld] -
        juldAmount;
      //needs extra check that owner deposited how much juld for cashBack
      _addUserBalance(juld, userAddr, juldAmount);
    }
  }

  // verified
  function getUserAssetAmount(address userAddr, address market)
    public
    view
    marketSupported(market)
    returns (uint256)
  {
    return usersBalances[userAddr][market];
  }

  // // verified
  // function getBatchUserAssetAmount(address userAddr)
  //   public
  //   view
  //   returns (uint256[] memory, uint256[] memory)
  // {
  //   uint256[] memory assets = new uint256[](allMarkets.length);
  //   uint256[] memory decimals = new uint256[](allMarkets.length);

  //   for (uint256 i = 0; i < allMarkets.length; i++) {
  //     assets[i] = usersBalances[userAddr][allMarkets[i]];
  //     ERC20Interface token = ERC20Interface(allMarkets[i]);
  //     uint256 tokenDecimal = uint256(token.decimals());
  //     decimals[i] = tokenDecimal;
  //   }
  //   return (assets, decimals);
  // }

  function getUserBalanceInUsd(address userAddr) public view returns (uint256) {
    address market = getUserMainMarket(userAddr);
    uint256 assetAmount = usersBalances[userAddr][market];
    uint256 usdAmount = getUsdAmount(market, assetAmount);
    return usdAmount;
  }

  // verified not
  //usdamount deciaml = 8
  function getUsdAmount(address market, uint256 assetAmount)
    public
    view
    returns (uint256 usdAmount)
  {
    uint256 usdPrice = PriceOracle(priceOracle).getUnderlyingPrice(market);
    require(usdPrice > 0, "usd price error");
    usdAmount = (assetAmount * usdPrice) / (10**8);
  }

  // verified not
  function getAssetAmount(address market, uint256 usdAmount)
    public
    view
    returns (uint256 assetAmount)
  {
    uint256 usdPrice = PriceOracle(priceOracle).getUnderlyingPrice(market);
    require(usdPrice > 0, "usd price error");
    assetAmount = (usdAmount * (10**8)) / usdPrice;
  }

  // verified
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    return
      keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  // verified
  function encodePackedData(
    bytes4 method,
    uint256 id,
    address addr,
    address market,
    uint256 amount,
    uint256 validTime
  ) public view returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(this, method, id, addr, market, amount, validTime)
      );
  }

  // verified
  function getecrecover(
    bytes4 method,
    uint256 id,
    address addr,
    address market,
    uint256 amount,
    uint256 validTime,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public view returns (address) {
    return
      ecrecover(
        toEthSignedMessageHash(
          keccak256(
            abi.encodePacked(this, method, id, addr, market, amount, validTime)
          )
        ),
        v,
        r,
        s
      );
  }

  function getBlockTime() public view returns (uint256) {
    return block.timestamp;
  }

  // test function
  function withdrawTokens(address token, address to) public onlyOwner {
    // bellow line will be uncommented in production version
    // require(!_marketEnabled[market],"me");
    if (token == address(0)) {
      TransferHelper.safeTransferETH(to, address(this).balance);
    } else {
      TransferHelper.safeTransfer(
        token,
        to,
        ERC20Interface(token).balanceOf(address(this))
      );
    }
  }
}
