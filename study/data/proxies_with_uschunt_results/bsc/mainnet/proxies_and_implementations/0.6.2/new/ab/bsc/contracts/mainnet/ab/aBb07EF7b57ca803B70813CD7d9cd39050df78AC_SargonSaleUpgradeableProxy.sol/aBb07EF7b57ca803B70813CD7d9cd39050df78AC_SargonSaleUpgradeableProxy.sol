/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-29
*/

// File: openzeppelin-solidity/contracts/proxy/Proxy.sol

// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

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
    function _delegate(address implementation) internal {
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
    function _implementation() internal virtual view returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () payable external {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () payable external {
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

// File: openzeppelin-solidity/contracts/utils/Address.sol

// ////-License-Identifier: MIT

pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

// File: openzeppelin-solidity/contracts/proxy/UpgradeableProxy.sol

// ////-License-Identifier: MIT

pragma solidity ^0.6.0;



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
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = _logic.delegatecall(_data);
            require(success);
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
    function _implementation() internal override view returns (address impl) {
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
    function _upgradeTo(address newImplementation) internal {
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

// File: openzeppelin-solidity/contracts/proxy/TransparentUpgradeableProxy.sol

// ////-License-Identifier: MIT

pragma solidity ^0.6.0;


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
 * you should think of the `ProxyAdmin` instance as the real administrative inerface of your proxy.
 */
contract TransparentUpgradeableProxy is UpgradeableProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address _admin, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
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
    function admin() external ifAdmin returns (address) {
        return _admin();
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
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     * 
     * Emits an {AdminChanged} event.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeTo(newImplementation);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view returns (address adm) {
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
    function _beforeFallback() internal override virtual {
        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// File: contracts/BEP20UpgradeableProxy.sol

pragma solidity ^0.6.0;


contract SargonSaleUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) public {

    }

}

// : MIT
pragma solidity ^0.8.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}
library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    
    function ethSignedMessage(bytes32 hashedMessage) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", 
                hashedMessage
            )
        );
    }

}
interface IDEXRouter {
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function buyToken(address receiver, uint256 amount, uint256 usd) external ;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract SargonSale is Context, Initializable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using ECDSA for bytes32;
    address routerAddr;
    address public sargonAddr;
    address public busdAddr;
    address public treasuryAddr;
    address public bankAddr;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _owner;
    uint256 public buyFee = 15;
    uint256 public liquidityFee = 2;
    uint256 public treasuryFee = 5;
    uint256 public slippageFee = 3;
    uint256 public bankFee = 2;
    uint256 public lastPrice = 300;
    uint256 public discount = 0;
    uint public curPrice = 1;
    bool public listingFlg = false;
    uint256 public totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
    IDEXRouter router;
    mapping(address => uint) packages;
    mapping(bytes32 => bool) public nonceUsed;
    mapping(address => bool) _isBanned;
    uint256 public  _startDay;
    uint256 public  _startWeek;
    mapping(address => uint256) _dayValues;
    mapping(address => uint256) _weekValues;
    mapping(address => uint256) _lastSellTime;
    modifier unusedNonce(bytes32 nonce) {
        require(!nonceUsed[nonce], "Nonce being used");
        _;
    }

    function initialize(string memory pname, string memory psymbol, uint8 pdecimals) public initializer {
        _name = pname;
        _symbol = psymbol;
        _decimals = pdecimals;
        _owner = msg.sender;
        sargonAddr = 0x97DBCd81cF143139C36Ad6A9eD98c2A1C6993E50;
        busdAddr = 0x55d398326f99059fF775485246999027B3197955;
        treasuryAddr = 0x9de1CB0FFac680a50E175f140B0e0290BeE14CDc;
        bankAddr = 0x45C27A4494bE0fc7e40554f53B3105a46F3f3523;
        buyFee = 15;
        liquidityFee = 2;
        treasuryFee = 5;
        slippageFee = 3;
        bankFee = 2;
        lastPrice = 2;
        discount = 0;
        curPrice = 1;
        listingFlg = false;
        totalBuyFee = buyFee.add(liquidityFee).add(treasuryFee).add(slippageFee).add(bankFee);
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function setRouterAddress(address _rout) public onlyOwner {
        routerAddr = _rout;
        router = IDEXRouter(routerAddr);
    }
    function setFeesReceiver(address _treasury, address _bank) public onlyOwner {
        treasuryAddr = _treasury;
        bankAddr = _bank;
    }
    function setCoinAddress(address _busdAddr, address _sargonAddr) public onlyOwner {
        sargonAddr = _sargonAddr;
        busdAddr = _busdAddr;
    }

    function getPrice() public view returns(uint) {
        if(!listingFlg) {
            return curPrice;
        } 
        address[] memory path = new address[](2);
        path[0] = busdAddr;
        path[1] = sargonAddr;
        uint[] memory amounts = router.getAmountsOut(1, path);
        return amounts[1];
    }
    function getPriceChange() public view returns(int256) {
        uint currPrice = getPrice();
        return int256((lastPrice/currPrice - 1)*100);
    } 
    function updatePrice() external onlyOwner {
        lastPrice = getPrice();
    } 
    function buySargon(uint256 _amount) public {
        uint256 sargonAmount = _amount * getPrice();
        uint256 usd = _amount - _amount.mul(discount).div(100);
        require(_amount <= IERC20(busdAddr).balanceOf(msg.sender), "Not enough balance");
        if (sargonAmount > IERC20(sargonAddr).balanceOf(address(this))) {
            sargonAmount = IERC20(sargonAddr).balanceOf(address(this));
        }
        require(IBEP20(busdAddr).transferFrom(msg.sender, address(this), usd),"Transfer failed!!!");

        IBEP20(sargonAddr).buyToken(msg.sender, sargonAmount, _amount);
    }

    function transferFees() external onlyOwner {
        address pool =  0x6288da7D54AC6fba6A9f5eA0f1139ee5fE354D69;
        address firstFAddress = 0xAF14e5462a138D933661914aBCBC1Fc0E6A25Ac0;
        address secondFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        uint256 poolRate = 20;
        uint256 usd = IBEP20(busdAddr).balanceOf(address(this));
        uint256 bankFees = usd.mul(7).div(100);
        //uint256 treasury = usd.mul(liquidityFee.add(treasuryFee).add(slippageFee)).div(27);
        uint256 poolAmount = usd.mul(poolRate).div(100);
        
        uint256 founderFee = usd.mul(23).div(100);
        uint256 usdKeep = usd.sub(bankFees).sub(poolAmount).sub(founderFee);
        uint256 firstFound = founderFee.mul(60).div(100);
        uint256 secondFound = founderFee.sub(firstFound);
        uint256 dayTime = block.timestamp.div(1 days);
        uint256 weekTime = block.timestamp.div(7 days);
        _startDay = dayTime.mul(1 days);
        _startWeek = weekTime.mul(7 days);
        require(IBEP20(busdAddr).transfer(bankAddr, bankFees),"Transfer bank fee failed!!!");
        //require(IBEP20(busdAddr).transfer(treasuryAddr, treasury),"Transfer treasury failed!!!");
        require(IBEP20(busdAddr).transfer(pool, poolAmount),"Transfer pool failed!!!");
        require(IBEP20(busdAddr).transfer(owner(), usdKeep),"Transfer owner failed!!!");
        require(IBEP20(busdAddr).transfer(firstFAddress, firstFound),"Transfer usd failed!!!");
        require(IBEP20(busdAddr).transfer(secondFAddress, secondFound),"Transfer USD failed!!!");
    }

    function setFees(uint256 _buyFee, uint256 _liquidityFee, uint256 _treasuryFee, uint256 _slippageFee, uint256 _bankFee) public onlyOwner {
        buyFee = _buyFee;
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        slippageFee = _slippageFee;
        bankFee = _bankFee;
    }

    function setDiscount(uint256 _discount) public onlyOwner {
        discount = _discount;
    }

    function setListing(bool _isListing, uint _price) public onlyOwner {
        curPrice = _price;
        listingFlg = _isListing;
    }

    function buyTicket(uint _ticket) external{
        uint256 amount = 0;
        uint256 udecimals = 10**_decimals;
        address pool =  0x6288da7D54AC6fba6A9f5eA0f1139ee5fE354D69;
        address firstFAddress = 0xAF14e5462a138D933661914aBCBC1Fc0E6A25Ac0;
        address secondFAddress = 0x19f54824D8FFc9348aE865e4263768DB6b1e0750;
        uint256 poolRate = 66;
        uint256 poolAmount;
        uint256 remain;
        if (_ticket == 1 && packages[msg.sender] < 1) {
            amount = 100 * udecimals;
        } 
        if (_ticket == 2) {
            if (packages[msg.sender] == 1) {
                amount = 900 * udecimals;
            } 
            if (packages[msg.sender] < 1) {
                amount = 1000 * udecimals;
            }
        }
        require(amount > 0, "wrong _ticket");
        poolAmount = amount.mul(poolRate).div(100);
        remain = amount - poolAmount;
        uint256 founderFee = remain.div(2);
        remain = remain.sub(founderFee);
        uint256 firstFound = founderFee.mul(60).div(100);
        uint256 secondFound = founderFee.sub(firstFound);
        require(IBEP20(busdAddr).balanceOf(msg.sender) >= amount, "Insufficient Balance");
        require(IBEP20(busdAddr).transferFrom(msg.sender, pool, poolAmount),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, owner(), remain),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, firstFAddress, firstFound),"Transfer USD failed!!!");
        require(IBEP20(busdAddr).transferFrom(msg.sender, secondFAddress, secondFound),"Transfer USD failed!!!");
        packages[msg.sender] = _ticket;
        emit BuyPackages(msg.sender, _ticket);
    }

    function ticketOf(address who) external view returns(uint){
        return packages[who];
    }

    function setTicket(address who, uint ticket) external onlyOwner {
        packages[who] = ticket;
    }

    function sellSargon(uint256 _amount) public returns(bool){
        require(!_isBanned[msg.sender], "you was banned");
        if(_lastSellTime[msg.sender] <= _startDay) _dayValues[msg.sender] = 0;
        if(_lastSellTime[msg.sender] <= _startWeek) _weekValues[msg.sender] = 0;
        
        uint256 price =  getPrice();
        address pool =  0x1E950Df2802e02A12e985A4263b00791d918FdDE;
        uint256 fee = _amount.mul(40).div(100);
        uint256 value = _amount - fee;
        uint256 usd = value.div(price);
        require(_dayValues[msg.sender].add(usd) < 300*(10**18), "over day value");
        require(_weekValues[msg.sender].add(usd) < 1000*(10**18), "over day value");
        emit TakeFee(msg.sender, fee);
        _dayValues[msg.sender].add(usd);
        _weekValues[msg.sender].add(usd);
        _lastSellTime[msg.sender] = block.timestamp;
        IBEP20(sargonAddr).transferFrom(msg.sender, address(this), _amount);
        IBEP20(busdAddr).transferFrom(pool, msg.sender, usd);
        emit SellSargon(msg.sender, _amount, usd);
        return true;
    }

    function setName(string memory uName) external onlyOwner {
        _name = uName;
    }

    function setBan(address[] memory banList, bool flg) external onlyOwner {
        require(banList.length < 100, "too much mems");
        if (banList.length < 100)
        for(uint i =0; i< banList.length; i++) {
            _isBanned[banList[i]] = flg;
        }
    }
    
    function isBanned(address who) external view returns(bool) {
        return _isBanned[who];
    }

    function retrieveSargon() public onlyOwner {
        uint256 value = IERC20(sargonAddr).balanceOf(address(this));
        IBEP20(sargonAddr).transfer(owner(), value);
    } 
    
    function retrieveUsd() public onlyOwner {
        uint256 value = IERC20(busdAddr).balanceOf(address(this));
        IBEP20(busdAddr).transfer(owner(), value);
    } 

    function dayValues(address who) external view returns(uint256) {
        return _dayValues[who];
    }

    function weekValues(address who) external view returns(uint256) {
        return _weekValues[who];
    }

    function lastSellTime(address who)external view returns (uint256) {
        return _lastSellTime[who];  
    }
    event BuySargon(address who, uint256 amount);
    event BuyPackages(address who, uint256 amount);
    event Withdraw(bytes32 nonce,
        address receiver,
        uint256 types,
        uint256 value);
    event Logs(uint256 value);
    event TakeFee(address who, uint256 fee);
    event SellSargon(address who, uint256 amount, uint256 value);
}