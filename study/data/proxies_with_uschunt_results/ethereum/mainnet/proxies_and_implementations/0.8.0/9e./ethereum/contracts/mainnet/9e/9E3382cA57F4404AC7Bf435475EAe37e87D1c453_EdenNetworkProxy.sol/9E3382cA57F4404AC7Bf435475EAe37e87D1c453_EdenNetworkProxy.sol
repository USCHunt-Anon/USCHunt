

// ////-License-Identifier: MIT

pragma solidity ^0.8.0;

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


// ////-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "./Proxy.sol";
//import "./Address.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 *
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract ERC1967Proxy is Proxy {
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
        require(Address.isContract(newImplementation), "ERC1967Proxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
}


// ////-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
pragma solidity ^0.8.0;

//import "./lib/ERC1967Proxy.sol";

/**
 * @title EdenNetworkProxy
 * @dev This contract implements a proxy that is upgradeable by an admin, compatible with the OpenZeppelin Upgradeable Transparent Proxy standard.
 */
contract EdenNetworkProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address admin_, bytes memory _data) payable ERC1967Proxy(_logic, _data) {
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
        Address.functionDelegateCall(newImplementation, data);
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
    function _beforeFallback() internal override {
        require(msg.sender != _admin(), "EdenNetworkProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}


// : MIT

pragma solidity ^0.8.0;

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

//import"./IERC20.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external returns (bool);
}


// : MIT
pragma solidity ^0.8.0;

//import"./IERC20Metadata.sol";
//import"./IERC20Mintable.sol";
//import"./IERC20Burnable.sol";
//import"./IERC20Permit.sol";
//import"./IERC20TransferWithAuth.sol";
//import"./IERC20SafeAllowance.sol";

interface IERC20Extended is 
    IERC20Metadata, 
    IERC20Mintable, 
    IERC20Burnable, 
    IERC20Permit,
    IERC20TransferWithAuth,
    IERC20SafeAllowance 
{}
    

// : MIT
pragma solidity ^0.8.0;

//import"./IERC20.sol";

interface IERC20Metadata is IERC20 {
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


// : MIT

pragma solidity ^0.8.0;

//import"./IERC20.sol";

interface IERC20Mintable is IERC20 {
    function mint(address dst, uint256 amount) external returns (bool);
}


// : MIT
pragma solidity ^0.8.0;

//import"./IERC20.sol";

interface IERC20Permit is IERC20 {
    function getDomainSeparator() external view returns (bytes32);
    function DOMAIN_TYPEHASH() external view returns (bytes32);
    function VERSION_HASH() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function nonces(address) external view returns (uint);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// : MIT
pragma solidity ^0.8.0;

//import"./IERC20.sol";

interface IERC20SafeAllowance is IERC20 {
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}

// : MIT
pragma solidity ^0.8.0;

//import"./IERC20.sol";

interface IERC20TransferWithAuth is IERC20 {
    function transferWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;
    function receiveWithAuthorization(address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;
    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);
    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}

// : MIT
pragma solidity ^0.8.0;

interface ILockManager {
    struct LockedStake {
        uint256 amount;
        uint256 votingPower;
    }

    function getAmountStaked(address staker, address stakedToken) external view returns (uint256);
    function getStake(address staker, address stakedToken) external view returns (LockedStake memory);
    function calculateVotingPower(address token, uint256 amount) external view returns (uint256);
    function grantVotingPower(address receiver, address token, uint256 tokenAmount) external returns (uint256 votingPowerGranted);
    function removeVotingPower(address receiver, address token, uint256 tokenAmount) external returns (uint256 votingPowerRemoved);
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

//import"./interfaces/IERC20Extended.sol";
//import"./interfaces/ILockManager.sol";
//import"./lib/Initializable.sol";

/**
 * @title EdenNetwork
 * @dev It is VERY IMPORTANT that modifications to this contract do not change the storage layout of the existing variables.  
 * Be especially careful when importing any external contracts/libraries.
 * If you do not know what any of this means, BACK AWAY FROM THE CODE NOW!!
 */
contract EdenNetwork is Initializable {

    /// @notice Slot bid details
    struct Bid {
        address bidder;
        uint16 taxNumerator;
        uint16 taxDenominator;
        uint64 periodStart;
        uint128 bidAmount;
    }

    /// @notice Expiration timestamp of current bid for specified slot index
    mapping (uint8 => uint64) public slotExpiration;
    
    /// @dev Address to be prioritized for given slot
    mapping (uint8 => address) private _slotDelegate;

    /// @dev Address that owns a given slot and is able to set the slot delegate
    mapping (uint8 => address) private _slotOwner;

    /// @notice Current bid for given slot
    mapping (uint8 => Bid) public slotBid;

    /// @notice Staked balance in contract
    mapping (address => uint128) public stakedBalance;

    /// @notice Balance in contract that was previously used for bid
    mapping (address => uint128) public lockedBalance;

    /// @notice Token used to reserve slot
    IERC20Extended public token;

    /// @notice Lock Manager contract
    ILockManager public lockManager;

    /// @notice Admin that can set the contract tax rate
    address public admin;

    /// @notice Numerator for tax rate
    uint16 public taxNumerator;

    /// @notice Denominator for tax rate
    uint16 public taxDenominator;

    /// @notice Minimum bid to reserve slot
    uint128 public MIN_BID;

    /// @dev Reentrancy var used like bool, but with refunds
    uint256 private _NOT_ENTERED;

    /// @dev Reentrancy var used like bool, but with refunds
    uint256 private _ENTERED;

    /// @dev Reentrancy status
    uint256 private _status;

    /// @notice Only admin can call
    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    /// @notice Only slot owner can call
    modifier onlySlotOwner(uint8 slot) {
        require(msg.sender == slotOwner(slot), "not slot owner");
        _;
    }

    /// @notice Reentrancy prevention
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /// @notice Event emitted when admin is updated
    event AdminUpdated(address indexed newAdmin, address indexed oldAdmin);

    /// @notice Event emitted when the tax rate is updated
    event TaxRateUpdated(uint16 newNumerator, uint16 newDenominator, uint16 oldNumerator, uint16 oldDenominator);

    /// @notice Event emitted when slot is claimed
    event SlotClaimed(uint8 indexed slot, address indexed owner, address indexed delegate, uint128 newBidAmount, uint128 oldBidAmount, uint16 taxNumerator, uint16 taxDenominator);
    
    /// @notice Event emitted when slot delegate is updated
    event SlotDelegateUpdated(uint8 indexed slot, address indexed owner, address indexed newDelegate, address oldDelegate);

    /// @notice Event emitted when a user stakes tokens
    event Stake(address indexed staker, uint256 stakeAmount);

    /// @notice Event emitted when a user unstakes tokens
    event Unstake(address indexed staker, uint256 unstakedAmount);

    /// @notice Event emitted when a user withdraws locked tokens
    event Withdraw(address indexed withdrawer, uint256 withdrawalAmount);

    /**
     * @notice Initialize EdenNetwork contract
     * @param _token Token address
     * @param _lockManager Lock Manager address
     * @param _admin Admin address
     * @param _taxNumerator Numerator for tax rate
     * @param _taxDenominator Denominator for tax rate
     */
    function initialize(
        IERC20Extended _token,
        ILockManager _lockManager,
        address _admin,
        uint16 _taxNumerator,
        uint16 _taxDenominator
    ) public initializer {
        token = _token;
        lockManager = _lockManager;
        admin = _admin;
        emit AdminUpdated(_admin, address(0));

        taxNumerator = _taxNumerator;
        taxDenominator = _taxDenominator;
        emit TaxRateUpdated(_taxNumerator, _taxDenominator, 0, 0);

        MIN_BID = 10000000000000000;
        _NOT_ENTERED = 1;
        _ENTERED = 2;
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Get current owner of slot
     * @param slot Slot index
     * @return Slot owner address
     */
    function slotOwner(uint8 slot) public view returns (address) {
        if(slotForeclosed(slot)) {
            return address(0);
        }
        return _slotOwner[slot];
    }

    /**
     * @notice Get current slot delegate
     * @param slot Slot index
     * @return Slot delegate address
     */
    function slotDelegate(uint8 slot) public view returns (address) {
        if(slotForeclosed(slot)) {
            return address(0);
        }
        return _slotDelegate[slot];
    }

    /**
     * @notice Get current cost to claim slot
     * @param slot Slot index
     * @return Slot cost
     */
    function slotCost(uint8 slot) external view returns (uint128) {
        if(slotForeclosed(slot)) {
            return MIN_BID;
        }

        Bid memory currentBid = slotBid[slot];
        return currentBid.bidAmount * 110 / 100;
    }

    /**
     * @notice Claim slot
     * @param slot Slot index
     * @param bid Bid amount
     * @param delegate Delegate for slot
     */
    function claimSlot(
        uint8 slot, 
        uint128 bid, 
        address delegate
    ) external nonReentrant {
        _claimSlot(slot, bid, delegate);
    }

    /**
     * @notice Claim slot using permit for approval
     * @param slot Slot index
     * @param bid Bid amount
     * @param delegate Delegate for slot
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function claimSlotWithPermit(
        uint8 slot, 
        uint128 bid, 
        address delegate, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {
        token.permit(msg.sender, address(this), bid, deadline, v, r, s);
        _claimSlot(slot, bid, delegate);
    }

    /**
     * @notice Get untaxed balance for current slot bid
     * @param slot Slot index
     * @return balance Slot balance
     */
    function slotBalance(uint8 slot) public view returns (uint128 balance) {
        Bid memory currentBid = slotBid[slot];
        if (currentBid.bidAmount == 0 || slotForeclosed(slot)) {
            return 0;
        } else if (block.timestamp == currentBid.periodStart) {
            return currentBid.bidAmount;
        } else {
            return uint128(uint256(currentBid.bidAmount) - (uint256(currentBid.bidAmount) * (block.timestamp - currentBid.periodStart) * currentBid.taxNumerator / (uint256(currentBid.taxDenominator) * 86400)));
        }
    }

    /**
     * @notice Returns true if a given slot bid has expired
     * @param slot Slot index
     * @return True if slot is foreclosed
     */
    function slotForeclosed(uint8 slot) public view returns (bool) {
        if(slotExpiration[slot] <= block.timestamp) {
            return true;
        }
        return false;
    }

    /**
     * @notice Stake tokens
     * @param amount Amount of tokens to stake
     */
    function stake(uint128 amount) external nonReentrant {
        _stake(msg.sender, amount);
    }

    /**
     * @notice Stake tokens using permit for approval
     * @param amount Amount of tokens to stake
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function stakeWithPermit(
        uint128 amount, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {
        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        _stake(msg.sender, amount);
    }

    /**
     * @notice Stake tokens on behalf of recipient
     * @param recipient Recipient of staked tokens
     * @param amount Amount of tokens to stake
     */
    function stakeFor(address recipient, uint128 amount) external nonReentrant {
        _stake(recipient, amount);
    }

    /**
     * @notice Stake tokens on behalf of recipient using permit for approval
     * @param recipient Recipient of staked tokens
     * @param amount Amount of tokens to stake
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function stakeForWithPermit(
        address recipient,
        uint128 amount, 
        uint256 deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external nonReentrant {
        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        _stake(recipient, amount);
    }

    /**
     * @notice Unstake tokens
     * @param amount Amount of tokens to unstake
     */
    function unstake(uint128 amount) external nonReentrant {
        require(stakedBalance[msg.sender] >= amount, "amount > unlocked balance");
        lockManager.removeVotingPower(msg.sender, address(token), amount);
        stakedBalance[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Unstake(msg.sender, amount);
    }

    /**
     * @notice Withdraw locked tokens
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(uint128 amount) external nonReentrant {
        require(lockedBalance[msg.sender] >= amount, "amount > unlocked balance");
        lockedBalance[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /**
     * @notice Allows slot owners to set a new slot delegate
     * @param slot Slot index
     * @param delegate Delegate address
     */
    function setSlotDelegate(uint8 slot, address delegate) external onlySlotOwner(slot) {
        require(delegate != address(0), "cannot delegate to 0 address");
        emit SlotDelegateUpdated(slot, msg.sender, delegate, slotDelegate(slot));
        _slotDelegate[slot] = delegate;
    }

    /**
     * @notice Set new tax rate
     * @param numerator New tax numerator
     * @param denominator New tax denominator
     */
    function setTaxRate(uint16 numerator, uint16 denominator) external onlyAdmin {
        require(denominator > numerator, "denominator must be > numerator");
        emit TaxRateUpdated(numerator, denominator, taxNumerator, taxDenominator);
        taxNumerator = numerator;
        taxDenominator = denominator;
    }

    /**
     * @notice Set new admin
     * @param newAdmin Nex admin address
     */
    function setAdmin(address newAdmin) external onlyAdmin {
        emit AdminUpdated(newAdmin, admin);
        admin = newAdmin;
    }

    /**
     * @notice Internal implementation of claimSlot
     * @param slot Slot index
     * @param bid Bid amount
     * @param delegate Delegate address
     */
    function _claimSlot(uint8 slot, uint128 bid, address delegate) internal {
        require(delegate != address(0), "cannot delegate to 0 address");
        Bid storage currentBid = slotBid[slot];
        uint128 existingBidAmount = currentBid.bidAmount;
        uint128 existingSlotBalance = slotBalance(slot);
        uint128 taxedBalance = existingBidAmount - existingSlotBalance;
        require((existingSlotBalance == 0 && bid >= MIN_BID) || bid >= existingBidAmount * 110 / 100, "bid too small");

        uint128 bidderLockedBalance = lockedBalance[msg.sender];
        uint128 bidIncrement = currentBid.bidder == msg.sender ? bid - existingSlotBalance : bid;
        if (bidderLockedBalance > 0) {
            if (bidderLockedBalance >= bidIncrement) {
                lockedBalance[msg.sender] -= bidIncrement;
            } else {
                lockedBalance[msg.sender] = 0;
                token.transferFrom(msg.sender, address(this), bidIncrement - bidderLockedBalance);
            }
        } else {
            token.transferFrom(msg.sender, address(this), bidIncrement);
        }

        if (currentBid.bidder != msg.sender) {
            lockedBalance[currentBid.bidder] += existingSlotBalance;
        }
        
        if (taxedBalance > 0) {
            token.burn(taxedBalance);
        }

        _slotOwner[slot] = msg.sender;
        _slotDelegate[slot] = delegate;

        currentBid.bidder = msg.sender;
        currentBid.periodStart = uint64(block.timestamp);
        currentBid.bidAmount = bid;
        currentBid.taxNumerator = taxNumerator;
        currentBid.taxDenominator = taxDenominator;

        slotExpiration[slot] = uint64(block.timestamp + uint256(taxDenominator) * 86400 / uint256(taxNumerator));

        emit SlotClaimed(slot, msg.sender, delegate, bid, existingBidAmount, taxNumerator, taxDenominator);
    }

    /**
     * @notice Internal implementation of stake
     * @param amount Amount of tokens to stake
     */
    function _stake(address recipient, uint128 amount) internal {
        token.transferFrom(msg.sender, address(this), amount);
        lockManager.grantVotingPower(recipient, address(token), amount);
        stakedBalance[recipient] += amount;
        emit Stake(recipient, amount);
    }
}


}
