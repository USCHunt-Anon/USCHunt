

// ////-License-Identifier: MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.6;

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
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
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
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}




// ////-License-Identifier: MIT

pragma solidity 0.7.6;

//import "@openzeppelin/contracts/utils/Address.sol";

//import "./Proxy.sol";

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
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if (_data.length > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, ) = _logic.delegatecall(_data);
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
    function _implementation() internal view override returns (address impl) {
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

pragma solidity 0.7.6;

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
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) payable UpgradeableProxy(_logic, _data) {
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
        (bool success, ) = newImplementation.delegatecall(data);
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
    function _beforeFallback() internal virtual override {
        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}


pragma solidity >=0.7.0;

interface IPermanentStorage {
    function wethAddr() external view returns (address);

    function getCurvePoolInfo(
        address _makerAddr,
        address _takerAssetAddr,
        address _makerAssetAddr
    )
        external
        view
        returns (
            int128 takerAssetIndex,
            int128 makerAssetIndex,
            uint16 swapMethod,
            bool supportGetDx
        );

    function setCurvePoolInfo(
        address _makerAddr,
        address[] calldata _underlyingCoins,
        address[] calldata _coins,
        bool _supportGetDx
    ) external;

    function isTransactionSeen(bytes32 _transactionHash) external view returns (bool); // Kept for backward compatability. Should be removed from AMM 5.2.1 upward

    function isAMMTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isRFQTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderAllowFillSeen(bytes32 _allowFillHash) external view returns (bool);

    function isL2DepositSeen(bytes32 _l2DepositHash) external view returns (bool);

    function isRelayerValid(address _relayer) external view returns (bool);

    function setTransactionSeen(bytes32 _transactionHash) external; // Kept for backward compatability. Should be removed from AMM 5.2.1 upward

    function setAMMTransactionSeen(bytes32 _transactionHash) external;

    function setRFQTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderAllowFillSeen(bytes32 _allowFillHash) external;

    function setL2DepositSeen(bytes32 _l2DepositHash) external;

    function setRelayersValid(address[] memory _relayers, bool[] memory _isValids) external;
}


pragma solidity ^0.7.6;

library PSStorage {
    bytes32 private constant STORAGE_SLOT = 0x92dd52b981a2dd69af37d8a3febca29ed6a974aede38ae66e4ef773173aba471;

    struct Storage {
        address ammWrapperAddr;
        address pmmAddr;
        address wethAddr;
        address rfqAddr;
        address limitOrderAddr;
        address l2DepositAddr;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.storage.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library AMMWrapperStorage {
    bytes32 private constant STORAGE_SLOT = 0xd38d862c9fa97c2fa857a46e08022d272a3579c114ca4f335f1e5fcb692c045e;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
        // curve pool => underlying token address => underlying token index
        mapping(address => mapping(address => int128)) curveTokenIndexes;
        mapping(address => bool) relayerValid;
        // 5.1.0 appended storage
        // curve pool => wrapped token address => wrapped token index
        mapping(address => mapping(address => int128)) curveWrappedTokenIndexes;
        mapping(address => bool) curveSupportGetDx;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.ammwrapper.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library RFQStorage {
    bytes32 private constant STORAGE_SLOT = 0x9174e76494cfb023ddc1eb0effb6c12e107165382bbd0ecfddbc38ea108bbe52;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.rfq.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library LimitOrderStorage {
    bytes32 private constant STORAGE_SLOT = 0xb1b5d1092eed9d9f9f6bdd5bf9fe04f7537770f37e1d84ac8960cc3acb80615c;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
        mapping(bytes32 => bool) allowFillSeen;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.limitorder.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library L2DepositStorage {
    bytes32 private constant STORAGE_SLOT = 0x6121983e370c77faf77a1d810c45f4d7db2f93a5f689c69a2ac659e2db43e95d;

    struct Storage {
        mapping(bytes32 => bool) l2DepositSeen;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.l2deposit.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}


// : MIT

pragma solidity 0.7.6;

//import"./interfaces/IPermanentStorage.sol";
//import"./utils/lib_storage/PSStorage.sol";

contract PermanentStorage is IPermanentStorage {
    // Constants do not have storage slot.
    bytes32 public constant curveTokenIndexStorageId = 0xf4c750cdce673f6c35898d215e519b86e3846b1f0532fb48b84fe9d80f6de2fc; // keccak256("curveTokenIndex")
    bytes32 public constant transactionSeenStorageId = 0x695d523b8578c6379a2121164fd8de334b9c5b6b36dff5408bd4051a6b1704d0; // keccak256("transactionSeen")
    bytes32 public constant relayerValidStorageId = 0x2c97779b4deaf24e9d46e02ec2699240a957d92782b51165b93878b09dd66f61; // keccak256("relayerValid")
    bytes32 public constant allowFillSeenStorageId = 0x808188d002c47900fbb4e871d29754afff429009f6684806712612d807395dd8; // keccak256("allowFillSeen")
    bytes32 public constant l2DepositSeenStorageId = 0xc41d08c7c3a2b58aaead61a87efcd02fbd96bb90a1d4d815fe378d9d30426444; // keccak256("l2DepositSeen")

    // New supported Curve pools
    address public constant CURVE_renBTC_POOL = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
    address public constant CURVE_sBTC_POOL = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
    address public constant CURVE_hBTC_POOL = 0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F;
    address public constant CURVE_sETH_POOL = 0xc5424B857f758E906013F3555Dad202e4bdB4567;

    // Curve coins
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private constant renBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address private constant wBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant sBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;
    address private constant hBTC = 0x0316EB71485b0Ab14103307bf65a021042c6d380;
    address private constant sETH = 0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb;

    // Below are the variables which consume storage slots.
    address public operator;
    string public version; // Current version of the contract
    mapping(bytes32 => mapping(address => bool)) private permission;

    // Operator events
    event TransferOwnership(address newOperator);
    event SetPermission(bytes32 storageId, address role, bool enabled);
    event UpgradeAMMWrapper(address newAMMWrapper);
    event UpgradePMM(address newPMM);
    event UpgradeRFQ(address newRFQ);
    event UpgradeLimitOrder(address newLimitOrder);
    event UpgradeL2Deposit(address newL2Deposit);
    event UpgradeWETH(address newWETH);
    event SetCurvePoolInfo(address makerAddr, address[] underlyingCoins, address[] coins, bool supportGetD);
    event SetRelayerValid(address relayer, bool valid);

    /************************************************************
     *          Access control and ownership management          *
     *************************************************************/
    modifier onlyOperator() {
        require(operator == msg.sender, "PermanentStorage: not the operator");
        _;
    }

    modifier validRole(bool _enabled, address _role) {
        if (_enabled) {
            require(
                (_role == operator) ||
                    (_role == ammWrapperAddr()) ||
                    (_role == pmmAddr()) ||
                    (_role == rfqAddr()) ||
                    (_role == limitOrderAddr()) ||
                    (_role == l2DepositAddr()),
                "PermanentStorage: not a valid role"
            );
        }
        _;
    }

    modifier isPermitted(bytes32 _storageId, address _role) {
        require(permission[_storageId][_role], "PermanentStorage: has no permission");
        _;
    }

    function transferOwnership(address _newOperator) external onlyOperator {
        require(_newOperator != address(0), "PermanentStorage: operator can not be zero address");
        operator = _newOperator;

        emit TransferOwnership(_newOperator);
    }

    /// @dev Set permission for entity to write certain storage.
    function setPermission(
        bytes32 _storageId,
        address _role,
        bool _enabled
    ) external onlyOperator validRole(_enabled, _role) {
        permission[_storageId][_role] = _enabled;

        emit SetPermission(_storageId, _role, _enabled);
    }

    /************************************************************
     *              Constructor and init functions               *
     *************************************************************/
    /// @dev Replacing constructor and initialize the contract. This function should only be called once.
    function initialize(address _operator) external {
        require(keccak256(abi.encodePacked(version)) == keccak256(abi.encodePacked("")), "PermanentStorage: already initialized");
        version = "5.3.0";
        require(_operator != address(0), "PermanentStorage: operator can not be zero address");
        operator = _operator;
    }

    /************************************************************
     *                     Getter functions                      *
     *************************************************************/
    function hasPermission(bytes32 _storageId, address _role) external view returns (bool) {
        return permission[_storageId][_role];
    }

    function ammWrapperAddr() public view returns (address) {
        return PSStorage.getStorage().ammWrapperAddr;
    }

    function pmmAddr() public view returns (address) {
        return PSStorage.getStorage().pmmAddr;
    }

    function rfqAddr() public view returns (address) {
        return PSStorage.getStorage().rfqAddr;
    }

    function limitOrderAddr() public view returns (address) {
        return PSStorage.getStorage().limitOrderAddr;
    }

    function l2DepositAddr() public view returns (address) {
        return PSStorage.getStorage().l2DepositAddr;
    }

    function wethAddr() external view override returns (address) {
        return PSStorage.getStorage().wethAddr;
    }

    function getCurvePoolInfo(
        address _makerAddr,
        address _takerAssetAddr,
        address _makerAssetAddr
    )
        external
        view
        override
        returns (
            int128 takerAssetIndex,
            int128 makerAssetIndex,
            uint16 swapMethod,
            bool supportGetDx
        )
    {
        // underlying_coins
        int128 i = AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][_takerAssetAddr];
        int128 j = AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][_makerAssetAddr];
        supportGetDx = AMMWrapperStorage.getStorage().curveSupportGetDx[_makerAddr];

        swapMethod = 0;
        if (i != 0 && j != 0) {
            // in underlying_coins list
            takerAssetIndex = i;
            makerAssetIndex = j;
            // exchange_underlying
            swapMethod = 2;
        } else {
            // in coins list
            int128 iWrapped = AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][_takerAssetAddr];
            int128 jWrapped = AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][_makerAssetAddr];
            if (iWrapped != 0 && jWrapped != 0) {
                takerAssetIndex = iWrapped;
                makerAssetIndex = jWrapped;
                // exchange
                swapMethod = 1;
            } else {
                revert("PermanentStorage: invalid pair");
            }
        }
        return (takerAssetIndex, makerAssetIndex, swapMethod, supportGetDx);
    }

    /* 
    NOTE: `isTransactionSeen` is replaced by `isAMMTransactionSeen`. It is kept for backward compatability.
    It should be removed from AMM 5.2.1 upward.
    */
    function isTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isAMMTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isRFQTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return RFQStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isLimitOrderTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return LimitOrderStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isLimitOrderAllowFillSeen(bytes32 _allowFillHash) external view override returns (bool) {
        return LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash];
    }

    function isL2DepositSeen(bytes32 _l2DepositHash) external view override returns (bool) {
        return L2DepositStorage.getStorage().l2DepositSeen[_l2DepositHash];
    }

    function isRelayerValid(address _relayer) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().relayerValid[_relayer];
    }

    /************************************************************
     *           Management functions for Operator               *
     *************************************************************/
    /// @dev Update AMMWrapper contract address.
    function upgradeAMMWrapper(address _newAMMWrapper) external onlyOperator {
        PSStorage.getStorage().ammWrapperAddr = _newAMMWrapper;

        emit UpgradeAMMWrapper(_newAMMWrapper);
    }

    /// @dev Update PMM contract address.
    function upgradePMM(address _newPMM) external onlyOperator {
        PSStorage.getStorage().pmmAddr = _newPMM;

        emit UpgradePMM(_newPMM);
    }

    /// @dev Update RFQ contract address.
    function upgradeRFQ(address _newRFQ) external onlyOperator {
        PSStorage.getStorage().rfqAddr = _newRFQ;

        emit UpgradeRFQ(_newRFQ);
    }

    /// @dev Update Limit Order contract address.
    function upgradeLimitOrder(address _newLimitOrder) external onlyOperator {
        PSStorage.getStorage().limitOrderAddr = _newLimitOrder;

        emit UpgradeLimitOrder(_newLimitOrder);
    }

    /// @dev Update L2 Deposit contract address.
    function upgradeL2Deposit(address _newL2Deposit) external onlyOperator {
        PSStorage.getStorage().l2DepositAddr = _newL2Deposit;

        emit UpgradeL2Deposit(_newL2Deposit);
    }

    /// @dev Update WETH contract address.
    function upgradeWETH(address _newWETH) external onlyOperator {
        PSStorage.getStorage().wethAddr = _newWETH;

        emit UpgradeWETH(_newWETH);
    }

    /************************************************************
     *                   External functions                      *
     *************************************************************/
    function setCurvePoolInfo(
        address _makerAddr,
        address[] calldata _underlyingCoins,
        address[] calldata _coins,
        bool _supportGetDx
    ) external override isPermitted(curveTokenIndexStorageId, msg.sender) {
        int128 underlyingCoinsLength = int128(_underlyingCoins.length);
        for (int128 i = 0; i < underlyingCoinsLength; i++) {
            address assetAddr = _underlyingCoins[uint256(i)];
            // underlying coins for original DAI, USDC, TUSD
            AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][assetAddr] = i + 1; // Start the index from 1
        }

        int128 coinsLength = int128(_coins.length);
        for (int128 i = 0; i < coinsLength; i++) {
            address assetAddr = _coins[uint256(i)];
            // wrapped coins for cDAI, cUSDC, yDAI, yUSDC, yTUSD, yBUSD
            AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][assetAddr] = i + 1; // Start the index from 1
        }

        AMMWrapperStorage.getStorage().curveSupportGetDx[_makerAddr] = _supportGetDx;
        emit SetCurvePoolInfo(_makerAddr, _underlyingCoins, _coins, _supportGetDx);
    }

    /* 
    NOTE: `setTransactionSeen` is replaced by `setAMMTransactionSeen`. It is kept for backward compatability.
    It should be removed from AMM 5.2.1 upward.
    */
    function setTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!AMMWrapperStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        AMMWrapperStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setAMMTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!AMMWrapperStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        AMMWrapperStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setRFQTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!RFQStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        RFQStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setLimitOrderTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!LimitOrderStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        LimitOrderStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setLimitOrderAllowFillSeen(bytes32 _allowFillHash) external override isPermitted(allowFillSeenStorageId, msg.sender) {
        require(!LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash], "PermanentStorage: allow fill seen before");
        LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash] = true;
    }

    function setL2DepositSeen(bytes32 _l2DepositHash) external override isPermitted(l2DepositSeenStorageId, msg.sender) {
        require(!L2DepositStorage.getStorage().l2DepositSeen[_l2DepositHash], "PermanentStorage: L2 deposit seen before");
        L2DepositStorage.getStorage().l2DepositSeen[_l2DepositHash] = true;
    }

    function setRelayersValid(address[] calldata _relayers, bool[] calldata _isValids) external override isPermitted(relayerValidStorageId, msg.sender) {
        require(_relayers.length == _isValids.length, "PermanentStorage: inputs length mismatch");
        for (uint256 i = 0; i < _relayers.length; i++) {
            AMMWrapperStorage.getStorage().relayerValid[_relayers[i]] = _isValids[i];
            emit SetRelayerValid(_relayers[i], _isValids[i]);
        }
    }
}



}
