



// ////-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    fallback () external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable {
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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

//import "./Proxy.sol";
//import "../utils/Address.sol";

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












// ////-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

//import "./UpgradeableProxy.sol";

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


// : MIT
pragma solidity 0.6.12;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {_setPendingOwner} and {_acceptOwner}.
 */
contract Ownable {
    /**
     * @dev Returns the address of the current owner.
     */
    address payable public owner;

    /**
     * @dev Returns the address of the current pending owner.
     */
    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal {
        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    /**
     * @dev Transfer contract control to a new owner. The newPendingOwner must call `_acceptOwner` to finish the transfer.
     * @param newPendingOwner New pending owner.
     *
     * TODO: Maybe the new pending owenr should not be the current owner at the same time.
     */
    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {
        require(
            newPendingOwner != address(0),
            "_setPendingOwner: New owenr can not be zero address!"
        );
        require(
            newPendingOwner != pendingOwner,
            "_setPendingOwner: This owner has been set!"
        );

        // Gets current owner.
        address oldPendingOwner = pendingOwner;

        // Sets new pending owner.
        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    /**
     * @dev Accepts the admin rights, but only for pendingOwenr.
     */
    function _acceptOwner() external {
        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        // Gets current values for events.
        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        // Set the new contract owner.
        owner = pendingOwner;

        // Clear the pendingOwner.
        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y > 0, "ds-math-div-overflow");
        z = x / y;
    }
}

library SafeRatioMath {
    using SafeMath for uint256;

    uint256 private constant BASE = 10**18;

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x.mul(y).div(BASE);
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x.mul(BASE).div(y);
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 base
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
                case 0 {
                    switch n
                        case 0 {
                            z := base
                        }
                        default {
                            z := 0
                        }
                }
                default {
                    switch mod(n, 2)
                        case 0 {
                            z := base
                        }
                        default {
                            z := x
                        }
                    let half := div(base, 2) // for rounding.

                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if iszero(eq(div(xx, x), x)) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, base)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(
                                iszero(iszero(x)),
                                iszero(eq(div(zx, x), z))
                            ) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, base)
                        }
                    }
                }
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external;

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external;

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // This function is not a standard ERC20 interface, just for compitable with market.
    function decimals() external view returns (uint8);
}

interface IInterestRateModel {
    function blocksPerYear() external view returns (uint256);
}

interface IPriceOracle {
    /**
     * @notice Get the underlying price of a iToken asset
     * @param _iToken The iToken to get the underlying price of
     * @return The underlying asset price mantissa (scaled by 1e18).
     *  Zero means the price is unavailable.
     */
    function getUnderlyingPrice(IiToken _iToken)
        external
        view
        returns (uint256);

    /**
     * @notice Get the price of a underlying asset
     * @param _iToken The iToken to get the underlying price of
     * @return The underlying asset price mantissa (scaled by 1e18).
     *  Zero means the price is unavailable and whether the price is valid.
     */
    function getUnderlyingPriceAndStatus(IiToken _iToken)
        external
        view
        returns (uint256, bool);
    function getAssetPriceStatus(IiToken _iToken) external view returns (bool);
}

interface IRewardDistributor {
    function updateDistributionState(IiToken _iToken, bool _isBorrow) external;

    function updateReward(
        IiToken _iToken,
        address _account,
        bool _isBorrow
    ) external;

    function updateRewardBatch(
        address[] memory _holders,
        IiToken[] memory _iTokens
    ) external;

    function reward(address _account) external view returns (uint256);
}

interface IController {
    function getAlliTokens() external view returns (IiToken[] memory);

    function getEnteredMarkets(address _account)
        external
        view
        returns (IiToken[] memory);
    
    function getBorrowedAssets(address _account) external view returns (IiToken[] memory);

    function hasEnteredMarket(address _account, IiToken _iToken)
        external
        view
        returns (bool);

    function hasBorrowed(address _account, IiToken _iToken)
        external
        view
        returns (bool);

    function priceOracle() external view returns (IPriceOracle);

    function markets(IiToken _asset)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool,
            bool
        );

    function calcAccountEquity(address _account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function beforeRedeem(
        address iToken,
        address redeemer,
        uint256 redeemAmount
    ) external returns (bool);

    function closeFactorMantissa() external view returns (uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function rewardDistributor() external view returns (address);
}

interface IiToken {
    function decimals() external view returns (uint8);

    function balanceOf(address _account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function isSupported() external view returns (bool);
    
    function isiToken() external view returns (bool);

    function underlying() external view returns (IERC20);

    function getCash() external view returns (uint256);

    function supplyRatePerBlock() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function balanceOfUnderlying(address _account) external returns (uint256);

    function borrowBalanceStored(address _account)
        external
        view
        returns (uint256);

    function borrowBalanceCurrent(address _account) external returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function totalBorrows() external view returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function updateInterest() external returns (bool);

    function interestRateModel() external view returns (IInterestRateModel);
}

contract LendingDataV2 is Ownable {
    using SafeMath for uint256;
    using SafeRatioMath for uint256;
    bool private initialized;

    uint256 constant BASE = 1e18;

    uint256 public blocksPerYear;
    uint256 constant daysPerYear = 365;

    IController public controller;
    IiToken public priceToken;

    IiToken[] public tokens;
    uint256[] public amounts;
    uint8[] public decimals;

    constructor(
        address _controller,
        IiToken _priceToken
    ) public {
        initialize(_controller, _priceToken);
    }

    function initialize(
        address _controller,
        IiToken _priceToken
    ) public {
        require(!initialized, "initialize: Already initialized!");
        __Ownable_init();
        controller = IController(_controller);
        priceToken = _priceToken;
        initialized = true;
    }

    function setController(IController _newController) external onlyOwner {
        // Sets to new controller.
        controller = _newController;
    }

    function setPriceToken(IiToken _newAsset) external onlyOwner {
        priceToken = _newAsset;
    }

    struct totalValueLocalVars {
        IiToken[] iTokens;
        IController controller;
        IPriceOracle priceOracle;
        uint256 assetPrice;
        uint256 collateralFactor;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 supplyValue;
        uint256 collateralVaule;
        uint256 borrowValue;
    }

    function getAccountTotalValue(address _account)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        totalValueLocalVars memory _var;
        _var.controller = controller;
        _var.iTokens = _var.controller.getAlliTokens();
        _var.priceOracle = _var.controller.priceOracle();
        for (uint256 i = 0; i < _var.iTokens.length; i++) {
            _var.assetPrice = _var.priceOracle.getUnderlyingPrice(
                _var.iTokens[i]
            );
            _var.supplyValue = _var.supplyValue.add(
                _var.iTokens[i].balanceOfUnderlying(_account).mul(
                    _var.assetPrice
                )
            );
            (_var.collateralFactor, , , , , , ) = controller.markets(_var.iTokens[i]);
            if (
                _var.controller.hasEnteredMarket(_account, _var.iTokens[i]) &&
                _var.collateralFactor > 0
            )
                _var.collateralVaule = _var.collateralVaule.add(
                    _var.iTokens[i].balanceOfUnderlying(_account).mul(
                        _var.assetPrice
                    )
                );

            if (_var.controller.hasBorrowed(_account, _var.iTokens[i]))
                _var.borrowValue = _var.borrowValue.add(
                    _var.iTokens[i].borrowBalanceCurrent(_account).mul(
                        _var.assetPrice
                    )
                );
        }
        _var.assetPrice = getAssetUSDPrice(priceToken);
        if (_var.assetPrice == 0) return (0, 0, 0, 0);

        _var.supplyValue = _var.supplyValue.div(_var.assetPrice);
        _var.collateralVaule = _var.collateralVaule.div(_var.assetPrice);
        _var.borrowValue = _var.borrowValue.div(_var.assetPrice);
        (, , _var.sumCollateral, _var.sumBorrowed) = calcAccountEquity(_account);
        return (
            _var.supplyValue,
            _var.collateralVaule,
            _var.borrowValue,
            _var.sumBorrowed == 0 ? 0 : _var.sumCollateral.rdiv(_var.sumBorrowed)
        );
    }

    function getAccountAssetStatus(IiToken _asset, address _account, uint256 _type) internal returns (bool, uint256) {
        uint256 _balance;
        if (_type == 0) {
            _balance = _asset.balanceOfUnderlying(_account);
            return ( _balance == 0 ? false : true, _balance);
        }

        bool _isiToken = _asset.isiToken();
        if ((_type & 1 > 0 && _isiToken) || (_type & 2 > 0 && !_isiToken))
            _balance = _asset.borrowBalanceCurrent(_account);

        return ( _balance == 0 ? false : true, _balance);
    }

    function getAccountAssets(address _account, uint256 _type)
        internal
        returns (
            IiToken[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        delete tokens;
        delete amounts;
        delete decimals;
        uint256 _balance;
        bool _status;
        IiToken[] memory _iTokens = controller.getAlliTokens();
        for (uint256 i = 0; i < _iTokens.length; i++) {
            (_status, _balance) = getAccountAssetStatus(_iTokens[i], _account, _type);
            if (_status) {
                tokens.push(_iTokens[i]);
                amounts.push(_balance);
                decimals.push(_iTokens[i].decimals());
            }
        }

        return (tokens, amounts, decimals);
    }

    
    function getAccountSupplyTokens(address _account)
        public
        returns (
            IiToken[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        return getAccountAssets(_account, 0);
    }

    function getAccountBorrowTokens(address _account)
        public
        returns (
            IiToken[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        return getAccountAssets(_account, 1);
    }

    function getAccountMSDTokens(address _account)
        public
        returns (
            IiToken[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        return getAccountAssets(_account, 2);
    }

    function getAccountTokens(address _account)
        external
        returns (
            IiToken[] memory _supplyTokens,
            uint256[] memory _supplyAmounts,
            uint8[] memory _supplyDecimals,
            IiToken[] memory _borrowTokens,
            uint256[] memory _borrowAmounts,
            uint8[] memory _borrowDecimals
        )
    {
        (
            _supplyTokens,
            _supplyAmounts,
            _supplyDecimals
        ) = getAccountAssets(_account, 0);
        (
            _borrowTokens,
            _borrowAmounts,
            _borrowDecimals
        ) = getAccountAssets(_account, 3);
    }

    function getAssetUSDPrice(IiToken _asset) public view returns (uint256) {
        uint256 _USDPrice = controller.priceOracle().getUnderlyingPrice(
                priceToken
            );
        if (_USDPrice == 0) return 0;

        uint256 _assetUSDPrice = controller.priceOracle()
                .getUnderlyingPrice(_asset)
                .rdiv(_USDPrice);
        uint8 _assetDecimals = _asset.decimals();
        uint8 _priceTokenDecimals = priceToken.decimals();

        return
            _assetDecimals > _priceTokenDecimals
                ? _assetUSDPrice.mul(
                    10**(uint256(_assetDecimals - _priceTokenDecimals))
                )
                : _assetUSDPrice.div(
                    10**(uint256(_priceTokenDecimals - _assetDecimals))
                );
    }

    function getSupplyTokenData(IiToken _asset)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 _collateralFactor, , , , , , ) = controller.markets(_asset);
        if (_asset.isiToken()) {
            uint256 _blocksPerDay = _asset.supplyRatePerBlock() * _asset.interestRateModel().blocksPerYear() / daysPerYear;
            return (
                (_blocksPerDay + BASE).rpow(
                    daysPerYear,
                    BASE
                ) - BASE,
                _collateralFactor,
                getAssetUSDPrice(_asset)
            );
        }
        return (0, _collateralFactor, getAssetUSDPrice(_asset));
    }

    function getAccountSupplyInfo(
        IiToken _asset,
        address _account,
        uint256 _safeMaxFactor
    )
        public
        returns (
            uint256 _assetPrice,
            bool _asCollateral,
            bool _executed,
            bool _accountAvailable
        )
    {
        _asCollateral = controller.hasEnteredMarket(_account, _asset);
        if (!_asCollateral) {
            (uint256 _collateralFactor, , , , , , ) = controller.markets(_asset);
            _executed = _collateralFactor > 0 ? true : false;
            _accountAvailable = true;
        } else {
            _executed = canAccountRemoveFromCollateral(
                _asset,
                _account,
                _safeMaxFactor
            );
            _accountAvailable = getAccountAvailable(_account);
        }
        
        uint256 _USDPrice = controller.priceOracle().getUnderlyingPrice(priceToken);
        _assetPrice = _USDPrice == 0 ? 0 : getBalance(_asset, _account).mul(controller.priceOracle().getUnderlyingPrice(_asset)).div(_USDPrice);
    }

    struct removeFromCollateralLocalVars {
        uint256 assetPrice;
        uint256 collateralFactor;
        uint256 accountEquity;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 safeAvailableToken;
    }

    function canAccountRemoveFromCollateral(
        IiToken _asset,
        address _account,
        uint256 _safeMaxFactor
    ) public returns (bool) {
        if (getAccountBorrowStatus(_account)) {
            removeFromCollateralLocalVars memory _var;

            (_var.collateralFactor, , , , , , ) = controller.markets(_asset);
            (
                _var.accountEquity,
                ,
                _var.sumCollateral,
                _var.sumBorrowed
            ) = calcAccountEquity(_account);
            if (_var.collateralFactor == 0 && _var.accountEquity > 0)
                return true;

            _var.assetPrice = controller.priceOracle()
                .getUnderlyingPrice(_asset);
            if (
                _var.assetPrice == 0 ||
                _var.collateralFactor == 0 ||
                _var.accountEquity == 0
            ) return false;

            _var.safeAvailableToken = _var.sumCollateral >
                _var.sumBorrowed.rdiv(_safeMaxFactor)
                ? _var.sumCollateral.sub(_var.sumBorrowed.rdiv(_safeMaxFactor))
                : 0;
            _var.safeAvailableToken = _var
                .safeAvailableToken
                .div(_var.assetPrice)
                .rdiv(_var.collateralFactor);

            return
                _var.safeAvailableToken >=
                IiToken(_asset).balanceOfUnderlying(_account);
        }

        return true;
    }

    struct supplyLocalVars {
        uint256 cash;
        uint256 assetPrice;
        uint256 collateralFactor;
        uint256 supplyCapacity;
        uint256 totalUnderlying;
        uint256 accountEquity;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 availableToken;
        uint256 safeAvailableToken;
        uint256 suppliedBalance;
        uint256 accountBalance;
        uint256 maxMintAmount;
        uint256 availableToWithdraw;
        uint256 safeAvailableToWithdraw;
        uint256 iTokenBalance;
        uint8 decimals;
    }

    function getAccountSupplyData(
        IiToken _asset,
        address _account,
        uint256 _safeMaxFactor
    )
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint8
        )
    {
        supplyLocalVars memory _var;
        _var.suppliedBalance = _asset.balanceOfUnderlying(_account);
        _var.accountBalance = getBalance(_asset, _account);
        _var.iTokenBalance = _asset.balanceOf(_account);
        _var.decimals = _asset.decimals();

        _var.maxMintAmount = 0;
        (_var.collateralFactor, , , _var.supplyCapacity, , ,) = controller.markets(
            _asset
        );
        _var.totalUnderlying = _asset.totalSupply().rmul(
            _asset.exchangeRateStored()
        );
        if (_var.supplyCapacity > _var.totalUnderlying) {
            _var.maxMintAmount = _var.supplyCapacity.sub(_var.totalUnderlying);
            _var.maxMintAmount = _var.maxMintAmount > _var.accountBalance
                ? _var.accountBalance
                : _var.maxMintAmount;
        }

        if (_asset.isiToken()) {
            _var.cash = _asset.getCash();
            _var.availableToWithdraw = _var.cash > _var.suppliedBalance
                ? _var.suppliedBalance
                : _var.cash;
        }
        _var.safeAvailableToWithdraw = _var.availableToWithdraw;

        if (
            controller.hasEnteredMarket(_account, _asset) &&
            getAccountBorrowStatus(_account)
        ) {
            (
                _var.accountEquity,
                ,
                _var.sumCollateral,
                _var.sumBorrowed
            ) = calcAccountEquity(_account);
            if (_var.collateralFactor == 0 && _var.accountEquity > 0)
                return (
                    _var.suppliedBalance,
                    _var.accountBalance,
                    _var.maxMintAmount,
                    _var.availableToWithdraw,
                    _var.safeAvailableToWithdraw,
                    _var.iTokenBalance,
                    _var.decimals
                );

            _var.assetPrice = controller.priceOracle()
                .getUnderlyingPrice(_asset);
            if (
                _var.assetPrice == 0 ||
                _var.collateralFactor == 0 ||
                _var.accountEquity == 0
            )
                return (
                    _var.suppliedBalance,
                    _var.accountBalance,
                    _var.maxMintAmount,
                    0,
                    0,
                    0,
                    _var.decimals
                );

            _var.availableToken = _var.accountEquity.div(_var.assetPrice).rdiv(
                _var.collateralFactor
            );
            _var.availableToWithdraw = _var.availableToWithdraw >
                _var.availableToken
                ? _var.availableToken
                : _var.availableToWithdraw;

            _var.safeAvailableToken = _var.sumCollateral >
                _var.sumBorrowed.rdiv(_safeMaxFactor)
                ? _var.sumCollateral.sub(_var.sumBorrowed.rdiv(_safeMaxFactor))
                : 0;
            _var.safeAvailableToken = _var
                .safeAvailableToken
                .div(_var.assetPrice)
                .rdiv(_var.collateralFactor);
            _var.safeAvailableToWithdraw = _var.safeAvailableToWithdraw >
                _var.safeAvailableToken
                ? _var.safeAvailableToken
                : _var.safeAvailableToWithdraw;

            _var.safeAvailableToWithdraw = _var.safeAvailableToWithdraw >
                _var.availableToWithdraw
                ? _var.availableToWithdraw
                : _var.safeAvailableToWithdraw;
        }

        return (
            _var.suppliedBalance,
            _var.accountBalance,
            _var.maxMintAmount,
            _var.availableToWithdraw,
            _var.safeAvailableToWithdraw,
            _var.iTokenBalance,
            _var.decimals
        );
    }

    function getAccountBorrowValue(address _account) public returns (uint256 _borrowValue) {
        IiToken[] memory _iTokens = controller.getAlliTokens();
        IPriceOracle _priceOracle = controller.priceOracle();
        for (uint256 i = 0; i < _iTokens.length; i++) {
            if (controller.hasBorrowed(_account, _iTokens[i]))
                _borrowValue = _borrowValue.add(
                    _iTokens[i].borrowBalanceCurrent(_account).mul(_priceOracle.getUnderlyingPrice(_iTokens[i]))
                );
        }
        return _borrowValue;
    }

    function getAccountBorrowStatus(address _account)
        public
        view
        returns (bool)
    {
        IiToken[] memory _iTokens = controller.getAlliTokens();
        for (uint256 i = 0; i < _iTokens.length; i++)
            if (_iTokens[i].borrowBalanceStored(_account) > 0)
                return true;

        return false;
    }

    function getBorrowTokenData(IiToken _asset)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (_asset.isSupported()) {
            (, uint256 _borrowFactor, , , , , ) = controller.markets(_asset);
            return (
                _asset.getCash(),
                _borrowFactor,
                (_asset.borrowRatePerBlock() * _asset.interestRateModel().blocksPerYear() / daysPerYear + BASE).rpow(
                    daysPerYear,
                    BASE
                ) - BASE,
                getAssetUSDPrice(_asset)
            );
        }
        return (0, 0, 0, 0);
    }

    struct borrowInfoLocalVars {
        IPriceOracle oracle;
        uint256 assetPrice;
        uint256 USDPrice;
        uint256 accountEquity;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 borrowFactor;
        uint256 maxBorrowValue;
        uint256 safeBorrowValue;
        bool accountAvailable;
    }

    function getAccountBorrowInfo(
        IiToken _asset,
        address _account,
        uint256 _safeMaxFactor
    )
        public
        returns (
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        borrowInfoLocalVars memory _var;
        _var.oracle = controller.priceOracle();
        _var.USDPrice = _var.oracle.getUnderlyingPrice(priceToken);
        if (_var.oracle.getAssetPriceStatus(_asset))
            _var.accountAvailable = getAccountAvailable(_account);

        if (_var.USDPrice == 0) return (0, 0, 0, _var.accountAvailable);

        IiToken(_asset).updateInterest();
        (
            _var.accountEquity,
            ,
            _var.sumCollateral,
            _var.sumBorrowed
        ) = calcAccountEquity(_account);
        (, _var.borrowFactor, , , , , ) = controller.markets(_asset);

        _var.maxBorrowValue = _var.accountEquity.rmul(_var.borrowFactor).div(
            _var.USDPrice
        );
        _var.safeBorrowValue = _var.sumCollateral.rmul(_safeMaxFactor) >
            _var.sumBorrowed
            ? _var.sumCollateral.rmul(_safeMaxFactor).sub(_var.sumBorrowed)
            : 0;
        _var.safeBorrowValue = _var.safeBorrowValue.rmul(_var.borrowFactor).div(
            _var.USDPrice
        );

        _var.assetPrice = _var.oracle.getUnderlyingPrice(_asset);
        return (
            _var.maxBorrowValue,
            _var.safeBorrowValue,
            getBalance(_asset, _account).mul(_var.assetPrice).div(_var.USDPrice),
            _var.accountAvailable
        );
    }

    struct borrowLocalVars {
        uint256 cash;
        uint256 assetPrice;
        uint256 borrowCapacity;
        uint256 accountEquity;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 borrowFactor;
        uint256 totalBorrows;
        uint256 canBorrows;
        uint256 borrowedBalance;
        uint256 availableToBorrow;
        uint256 safeAvailableToBorrow;
        uint256 accountBalance;
        uint256 maxRepay;
    }

    function getAccountBorrowData(
        IiToken _asset,
        address _account,
        uint256 _safeMaxFactor
    )
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint8
        )
    {
        borrowLocalVars memory _var;
        _var.borrowedBalance = _asset.borrowBalanceCurrent(_account);
        _var.accountBalance = getBalance(_asset, _account);
        _var.maxRepay = _var.borrowedBalance > _var.accountBalance
            ? _var.accountBalance
            : _var.borrowedBalance;

        _var.assetPrice = controller.priceOracle()
            .getUnderlyingPrice(_asset);
        (, _var.borrowFactor, _var.borrowCapacity, , , , ) = controller.markets(
            _asset
        );
        if (
            _var.assetPrice == 0 ||
            _var.borrowCapacity == 0 ||
            _var.borrowFactor == 0
        )
            return (
                _var.borrowedBalance,
                0,
                0,
                _var.accountBalance,
                _var.maxRepay,
                _asset.decimals()
            );

        (
            _var.accountEquity,
            ,
            _var.sumCollateral,
            _var.sumBorrowed
        ) = calcAccountEquity(_account);
        _var.availableToBorrow = _var.accountEquity.rmul(_var.borrowFactor).div(
            _var.assetPrice
        );

        _var.safeAvailableToBorrow = _var.sumCollateral.rmul(_safeMaxFactor) >
            _var.sumBorrowed
            ? _var.sumCollateral.rmul(_safeMaxFactor).sub(_var.sumBorrowed)
            : 0;
        _var.safeAvailableToBorrow = _var
            .safeAvailableToBorrow
            .rmul(_var.borrowFactor)
            .div(_var.assetPrice);

        if (_asset.isiToken()) {
            _var.cash = _asset.getCash();
            _var.availableToBorrow = _var.availableToBorrow > _var.cash
                ? _var.cash
                : _var.availableToBorrow;

            _var.safeAvailableToBorrow = _var.safeAvailableToBorrow > _var.cash
                ? _var.cash
                : _var.safeAvailableToBorrow;
        }

        _var.totalBorrows = _asset.totalBorrowsCurrent();
        _var.canBorrows = _var.totalBorrows >= _var.borrowCapacity
            ? 0
            : _var.borrowCapacity.sub(_var.totalBorrows);

        _var.availableToBorrow = _var.availableToBorrow > _var.canBorrows
            ? _var.canBorrows
            : _var.availableToBorrow;

        _var.safeAvailableToBorrow = _var.safeAvailableToBorrow >
            _var.canBorrows
            ? _var.canBorrows
            : _var.safeAvailableToBorrow;

        return (
            _var.borrowedBalance,
            _var.canBorrows,
            _var.safeAvailableToBorrow,
            _var.accountBalance,
            _var.maxRepay,
            _asset.decimals()
        );
    }

    struct availableToBorrowLocalVars {
        uint256 borrowFactor;
        uint256 accountEquity;
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 availableToBorrow;
        uint256 safeAvailableToBorrow;
    }

    function getBalance(IiToken _asset, address _account)
        public
        view
        returns (uint256)
    {
        return
            _asset.underlying() == IERC20(0)
                ? _account.balance
                : _asset.underlying().balanceOf(_account);
    }

    struct liquidateLocalVars {
        IPriceOracle oracle;
        uint256 priceBorrowed;
        uint256 priceCollateral;
        uint256 liquidatorBalance;
        uint256 borrowerCollateralBalance;
        uint256 shortfall;
        uint256 exchangeRateCollateral;
        uint256 maxRepay;
        uint256 maxSeizediToken;
        uint256 maxRepayByCollateral;
        bool available;
    }

    function getLiquidationInfo(
        address _borrower,
        address _liquidator,
        IiToken _assetBorrowed,
        IiToken _assetCollateral
    )
        public
        returns (
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        liquidateLocalVars memory _var;

        _var.oracle = controller.priceOracle();
        if (_var.oracle.getAssetPriceStatus(_assetCollateral))
            _var.available = getAccountAvailable(_borrower);

        _var.maxRepay = _assetBorrowed.borrowBalanceCurrent(_borrower)
            .rmul(controller.closeFactorMantissa());
        _var.exchangeRateCollateral = _assetCollateral.exchangeRateCurrent();

        _var.liquidatorBalance = getBalance(_assetBorrowed, _liquidator);
        (, _var.shortfall, , ) = calcAccountEquity(_borrower);
        if (_var.shortfall == 0 || _borrower == _liquidator)
            return (0, 0, _var.liquidatorBalance, _var.available);

        _var.priceBorrowed = _var.oracle.getUnderlyingPrice(_assetBorrowed);
        _var.priceCollateral = _var.oracle.getUnderlyingPrice(_assetCollateral);

        _var.maxSeizediToken = _var
            .maxRepay
            .mul(_var.priceBorrowed)
            .rmul(controller.liquidationIncentiveMantissa())
            .rdiv(_var.exchangeRateCollateral)
            .div(_var.priceCollateral);
        _var.borrowerCollateralBalance = _assetCollateral.balanceOf(
            _borrower
        );
        if (_var.maxSeizediToken < _var.borrowerCollateralBalance)
            return (
                _var.maxRepay,
                _var.maxRepay,
                _var.liquidatorBalance,
                _var.available
            );

        _var.maxRepayByCollateral = _var
            .borrowerCollateralBalance
            .rmul(_var.exchangeRateCollateral)
            .mul(_var.priceCollateral)
            .div(_var.priceBorrowed)
            .rdiv(controller.liquidationIncentiveMantissa());
        return (
            _var.maxRepay,
            _var.maxRepayByCollateral,
            _var.liquidatorBalance,
            _var.available
        );
    }

    function getAccountRewardAmount(address _account) external returns (uint256) {

        IRewardDistributor _rewardDistributor = IRewardDistributor(controller.rewardDistributor());
        address[] memory _accounts = new address[](1);
        _accounts[0] = _account;
        _rewardDistributor.updateRewardBatch(_accounts ,controller.getAlliTokens());
        return _rewardDistributor.reward(_account);
    }

    struct AccountEquityLocalVars {
        IiToken[] collateralITokens;
        IiToken[] borrowedITokens;
        uint256 collateralFactor;
        uint256 borrowFactor;
        uint256 sumCollateral;
        uint256 sumBorrowed;
    }

    function calcAccountEquity(address _account) public view returns (uint256, uint256, uint256, uint256) {
        AccountEquityLocalVars memory _var;
        _var.collateralITokens = controller.getEnteredMarkets(_account);
        for (uint256 i = 0; i < _var.collateralITokens.length; i++) {
            (_var.collateralFactor, , , , , , ) = controller.markets(_var.collateralITokens[i]);
            _var.sumCollateral = _var.sumCollateral.add(
                _var.collateralITokens[i].balanceOf(_account)
                .mul(controller.priceOracle().getUnderlyingPrice(_var.collateralITokens[i]))
                .rmul(_var.collateralITokens[i].exchangeRateStored())
                .rmul(_var.collateralFactor)
            );
        }
        _var.borrowedITokens = controller.getBorrowedAssets(_account);
        for (uint256 i = 0; i < _var.borrowedITokens.length; i++) {
            (, _var.borrowFactor, , , , , ) = controller.markets(_var.borrowedITokens[i]);
            _var.sumBorrowed = _var.sumBorrowed.add(
                _var.borrowedITokens[i].borrowBalanceStored(_account)
                .mul(controller.priceOracle().getUnderlyingPrice(_var.borrowedITokens[i]))
                .rdiv(_var.borrowFactor)
            );
        }
        return
            _var.sumCollateral > _var.sumBorrowed
                ? (
                    _var.sumCollateral - _var.sumBorrowed,
                    uint256(0),
                    _var.sumCollateral,
                    _var.sumBorrowed
                )
                : (
                    uint256(0),
                    _var.sumBorrowed - _var.sumCollateral,
                    _var.sumCollateral,
                    _var.sumBorrowed
                );
    }

    function getAccountAvailable(address _account) public view returns (bool) {
        
        IiToken[] memory _collateralITokens = controller.getEnteredMarkets(_account);
        for (uint256 i = 0; i < _collateralITokens.length; i++) {
            if (!controller.priceOracle().getAssetPriceStatus(_collateralITokens[i]))
                return false;
        }
        IiToken[] memory _borrowedITokens = controller.getBorrowedAssets(_account);
        for (uint256 i = 0; i < _borrowedITokens.length; i++) {
            if (!controller.priceOracle().getAssetPriceStatus(_borrowedITokens[i]))
                return false;
        }
        return true;
    }
}