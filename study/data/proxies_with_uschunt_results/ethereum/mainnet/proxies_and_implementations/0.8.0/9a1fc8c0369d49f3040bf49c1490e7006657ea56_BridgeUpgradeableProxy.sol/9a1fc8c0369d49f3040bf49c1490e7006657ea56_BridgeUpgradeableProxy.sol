/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

// ////-License-Identifier: No License (None)

// File: openzeppelin-solidity/contracts/proxy/Proxy.sol
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

// File: openzeppelin-solidity/contracts/utils/Address.sol

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

// File: openzeppelin-solidity/contracts/proxy/UpgradeableProxy.sol

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
    function admin() external view returns (address admin_) {
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
    function implementation() external view returns (address implementation_) {
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
    function upgrade() external ifAdmin {
        address newImplementation = IBridge(address(this)).upgradeTo();
        _upgradeTo(newImplementation);
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
}

interface IBridge {
    function upgradeTo() external view returns(address);
}

// initialize() = 0x8129fc1c
contract BridgeUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {

    }
}

// : No License (None)
pragma solidity ^0.8.0;

interface IBEP20TokenCloned {
    // initialize cloned token just for BEP20TokenCloned
    function initialize(address newOwner, string calldata name, string calldata symbol, uint8 decimals) external;
    function mint(address user, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external returns(bool);
    function burn(uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IContractCaller {
    function callContract(address user, address token, uint256 value, address toContract, bytes memory data) external payable;
}

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {

    struct AddressSet {
        // Storage of set values
        address[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (address => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            address lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns 1-based index of value in the set. O(1).
     */
    function indexOf(AddressSet storage set, address value) internal view returns (uint256) {
        return set._indexes[value];
    }


    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    /* will use initialize instead
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    */
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

}

contract CallistoBridge is Ownable {
    using TransferHelper for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet authorities; // authority has to sign claim transaction (message)

    address constant MAX_NATIVE_COINS = address(31); // addresses from address(1) to MAX_NATIVE_COINS are considered as native coins 
                                            // CLO = address(1)
    struct Token {
        address token;  // foreign token address
        bool isWrapped; // is native token wrapped of foreign
    }

    struct Upgrade {
        address newContract;
        uint64  validFrom;
    }

    uint256 public threshold;   // minimum number of signatures required to approve swap
    address public tokenImplementation;    // implementation of wrapped token
    address public feeTo; // send fee to this address
    bool public frozen; // if frozen - swap will not work
    uint256 public wrapNonce;   // the last nonce used to create wrapped token address begin with 0xCC.... 
    mapping(uint256 => mapping(bytes32 => bool)) public isTxProcessed;    // chainID => txID => isProcessed
    mapping(uint256 => mapping(address => Token)) public tokenPair;       // chainID => native token address => Token struct
    mapping(uint256 => mapping(address => address)) public tokenForeign;  // chainID => foreign token address => native token
    mapping(address => uint256) public tokenDeposits;  // amount of tokens were deposited by users
    mapping(address => bool) public isFreezer;  // addresses that have right to freeze contract 
    uint256 public setupMode;   // time when setup mode will start, 0 if disable
    Upgrade public upgradeData;
    address public founders;
    address public requiredAuthority;   // authority address that MUST sign swap transaction
    address public contractCaller; // intermediate contract that calls third-party contract functions (toContract)
    uint256 public functionMapping;    // bitmap of locked functions (one bit per function)

    event SetAuthority(address authority, bool isEnable);
    event SetFeeTo(address previousFeeTo, address newFeeTo);
    event SetThreshold(uint256 threshold);
    event SetContractCaller(address newContractCaller);
    event Deposit(address indexed token, address indexed sender, uint256 value, uint256 toChainId, address toToken);
    event Claim(address indexed token, address indexed to, uint256 value, bytes32 txId, uint256 fromChainId, address fromToken);
    event Fee(address indexed sender, uint256 fee);
    event CreatePair(address toToken, bool isWrapped, address fromToken, uint256 fromChainId);
    event Frozen(bool status);
    event RescuedERC20(address token, address to, uint256 value);
    event SetFreezer(address freezer, bool isActive);
    event SetupMode(uint time);
    event UpgradeRequest(address newContract, uint256 validFrom);
    event BridgeToContract(address indexed token, address indexed sender, uint256 value, uint256 toChainId, address toToken, address toContract, bytes data);
    event ClaimToContract(address indexed token, address indexed to, uint256 value, bytes32 txId, uint256 fromChainId, address fromToken, address toContract);

    // run only once from proxy
    function initialize(address newOwner, address newFounders, address _tokenImplementation) external {
        require(newOwner != address(0) && newFounders != address(0) && founders == address(0)); // run only once
        _owner = newOwner;
        founders = newFounders;
        emit OwnershipTransferred(address(0), msg.sender);
        require(_tokenImplementation != address(0), "Wrong tokenImplementation");
        tokenImplementation = _tokenImplementation;
        feeTo = msg.sender;
        threshold = 1;
        setupMode = 1; // allow setup after deployment
    }
    /*
    constructor (address _tokenImplementation) {
        require(_tokenImplementation != address(0), "Wrong tokenImplementation");
        tokenImplementation = _tokenImplementation;
        feeTo = msg.sender;
        threshold = 1;
    }
    */
    modifier notFrozen() {
        require(!frozen, "Bridge is frozen");
        _;
    }

    // allowed only in setup mode
    modifier onlySetup() {
        uint256 mode = setupMode; //use local variable to save gas
        require(mode != 0 && mode < block.timestamp, "Not in setup mode");
        _;
    }

    function upgradeTo() external view returns(address newContract) {
        Upgrade memory upg = upgradeData;
        require(upg.validFrom < block.timestamp && upg.newContract != address(0), "Upgrade not allowed");
        newContract = upg.newContract;
    }

    function requestUpgrade(address newContract) external onlyOwner {
        require(newContract != address(0), "Zero address");
        uint256 validFrom = block.timestamp + 3 days;
        upgradeData = Upgrade(newContract, uint64(validFrom));
        emit UpgradeRequest(newContract, validFrom);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */

    function transferOwnership(address newOwner) public {
        require(founders == msg.sender, "Ownable: caller is not the founders");
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function ChangeFounder(address newFounders) public {
        require(founders == msg.sender, "caller is not the founders");
        require(newFounders != address(0), "new owner is the zero address");
        emit OwnershipTransferred(founders, newFounders);
        founders = newFounders;
    }

    // get number of authorities
    function getAuthoritiesNumber() external view returns(uint256) {
        return authorities.length();
    }

    // returns list of authorities addresses
    function getAuthorities() external view returns(address[] memory) {
        return authorities._values;
    }

    // Owner or Authority may freeze bridge in case of anomaly detection
    function freeze() external {
        require(msg.sender == owner() || authorities.contains(msg.sender) || isFreezer[msg.sender]);
        frozen = true;
        emit Frozen(true);
    }

    // Only owner can manually unfreeze contract
    function unfreeze() external onlyOwner onlySetup {
        frozen = false;
        emit Frozen(false);
    }

    function lockFunctions(uint256 _functionMapping) external onlyOwner {
        functionMapping = _functionMapping;
    }

    // add authority
    function setFreezer(address freezer, bool isActive) external onlyOwner {
        require(freezer != address(0), "Zero address");
        isFreezer[freezer] = isActive;
        emit SetFreezer(freezer, isActive);
    }

    // add authority
    function addAuthority(address authority) external onlyOwner onlySetup {
        require(authority != address(0), "Zero address");
        require(authorities.length() < 255, "Too many authorities");
        require(authorities.add(authority), "Authority already added");
        emit SetAuthority(authority, true);
    }

    // remove authority
    function removeAuthority(address authority) external onlyOwner {
        require(authorities.remove(authority), "Authority does not exist");
        emit SetAuthority(authority, false);
    }

    // set authority address that MUST sign claim request
    function setRequiredAuthority(address authority) external onlyOwner onlySetup {
        requiredAuthority = authority;
    }

    // set fee receiver address
    function setFeeTo(address newFeeTo) external onlyOwner onlySetup {
        require(newFeeTo != address(0), "Zero address");
        address previousFeeTo = feeTo;
        feeTo = newFeeTo;
        emit SetFeeTo(previousFeeTo, newFeeTo);
    }

    // set threshold - minimum number of signatures required to approve swap
    function setThreshold(uint256 _threshold) external onlyOwner onlySetup {
        require(threshold != 0 && threshold <= authorities.length(), "Wrong threshold");
        threshold = _threshold;
        emit SetThreshold(threshold);
    }

    // set contractCaller address
    function setContractCaller(address newContractCaller) external onlyOwner onlySetup {
        contractCaller = newContractCaller;
        emit SetContractCaller(newContractCaller);
    }

    function disableSetupMode() external onlyOwner {
        setupMode = 0;
        emit SetupMode(0);
    }

    function enableSetupMode() external onlyOwner {
        setupMode = block.timestamp + 1 days;
        emit SetupMode(setupMode);
    }

    // returns `nonce` to use in `createWrappedToken()` to create address starting with 0xCC.....
    function calculateNonce() external view returns(uint256 nonce, address addr) {
        nonce = wrapNonce;
        address implementation = tokenImplementation;
        while (true) {
            nonce++;
            addr = Clones.predictDeterministicAddress(implementation, bytes32(nonce));
            if (uint160(addr) & uint160(0xfF00000000000000000000000000000000000000) == uint160(0xCc00000000000000000000000000000000000000))
                break;
        }
    }

    function rescueERC20(address token, address to) external onlyOwner {
        uint256 value = IBEP20TokenCloned(token).balanceOf(address(this)) - tokenDeposits[token];
        token.safeTransfer(to, value);
        emit RescuedERC20(token, to, value);
    }

    // Create wrapped token for foreign token
    function createWrappedToken(
        address fromToken,      // foreign token address
        uint256 fromChainId,    // foreign chain ID where token deployed
        string memory name,     // wrapped token name
        string memory symbol,   // wrapped token symbol
        uint8 decimals,         // wrapped token decimals (should be the same as in original token)
        uint256 nonce           // nonce to create wrapped token address begin with 0xCC.... 
    )
        external
        onlyOwner
        onlySetup
    {
        require(fromToken != address(0), "Wrong token address");
        require(tokenForeign[fromChainId][fromToken] == address(0), "This token already wrapped");
        require(nonce > wrapNonce, "Nonce must be higher then wrapNonce");
        wrapNonce = nonce;
        address wrappedToken = Clones.cloneDeterministic(tokenImplementation, bytes32(nonce));
        IBEP20TokenCloned(wrappedToken).initialize(owner(), name, symbol, decimals);
        tokenPair[fromChainId][wrappedToken] = Token(fromToken, true);
        tokenForeign[fromChainId][fromToken] = wrappedToken;
        emit CreatePair(wrappedToken, true, fromToken, fromChainId); //wrappedToken - wrapped token contract address
    }

    /**
     * @dev Create pair between existing tokens on native and foreign chains
     * @param toToken token address on native chain
     * @param fromToken token address on foreign chain
     * @param fromChainId foreign chain ID
     * @param isWrapped `true` if `toToken` is our wrapped token otherwise `false`
     */
    function createPair(address toToken, address fromToken, uint256 fromChainId, bool isWrapped) external onlyOwner onlySetup {
        require(tokenPair[fromChainId][toToken].token == address(0), "Pair already exist");
        tokenPair[fromChainId][toToken] = Token(fromToken, isWrapped);
        tokenForeign[fromChainId][fromToken] = toToken;
        emit CreatePair(toToken, isWrapped, fromToken, fromChainId);
    }

    /**
     * @dev Delete unused pair
     * @param toToken token address on native chain
     * @param fromChainId foreign chain ID
     */
    function deletePair(address toToken, uint256 fromChainId) external onlyOwner onlySetup {
        delete tokenPair[fromChainId][toToken];
    }

    // Move tokens through the bridge and call the contract with 'data' parameters on the destination chain
    function bridgeToContract(
        address receiver,   // address of token receiver on destination chain
        address token,      // token that user send (if token address < 32, then send native coin)
        uint256 value,      // tokens value
        uint256 toChainId,  // destination chain Id where will be claimed tokens
        address toContract, // this contract will be called on destination chain
        bytes memory data   // this data will be passed to contract call (ABI encoded parameters)
    )
        external
        payable
        notFrozen
    {
        require(functionMapping & 2 == 0, "locked");    // check bit 1
        require(receiver != address(0), "Incorrect receiver address");
        address pair_token = _deposit(token, value, toChainId);
        emit BridgeToContract(token, receiver, value, toChainId, pair_token, toContract, data);
    }

    // Claim tokens from the bridge and call the contract with 'data' parameters
    function claimToContract(
        address token,          // token to receive
        bytes32 txId,           // deposit transaction hash on fromChain 
        address to,             // user address
        uint256 value,          // value of tokens
        uint256 fromChainId,    // chain ID where user deposited
        address toContract,     // this contract will be called on destination chain
        bytes memory data,      // this data will be passed to contract call (ABI encoded parameters)
        bytes[] memory sig      // authority signatures
    ) 
        external
        notFrozen
    {
        require(functionMapping & 4 == 0, "locked");    // check bit 2
        require(!isTxProcessed[fromChainId][txId], "Transaction already processed");
        Token memory pair = tokenPair[fromChainId][token];
        require(pair.token != address(0), "There is no pair");
        {
        isTxProcessed[fromChainId][txId] = true;

        // Check signature
        address must = requiredAuthority;
        bytes32 messageHash = keccak256(abi.encodePacked(token, to, value, txId, fromChainId, block.chainid, toContract, data));
        messageHash = prefixed(messageHash);
        uint256 uniqSig;
        uint256 set;    // maximum number of authorities is 255
        for (uint i = 0; i < sig.length; i++) {
            address authority = recoverSigner(messageHash, sig[i]);
            if (authority == must) must = address(0);
            uint256 index = authorities.indexOf(authority);
            uint256 mask = 1 << index;
            if (index != 0 && (set & mask) == 0 ) {
                set |= mask;
                uniqSig++;
            }
        }
        require(threshold <= uniqSig, "Require more signatures");
        require(must == address(0), "The required authority does not sign");
        }
        // Call toContract
        if(isContract(toContract) && toContract != address(this)) {
            if (token <= MAX_NATIVE_COINS) {
                IContractCaller(contractCaller).callContract{value: value}(to, token, value, toContract, data);
            } else {
                if(pair.isWrapped) {
                    IBEP20TokenCloned(token).mint(contractCaller, value);
                } else {
                    tokenDeposits[token] -= value;
                    token.safeTransfer(contractCaller, value);
                }
                IContractCaller(contractCaller).callContract(to, token, value, toContract, data);               
            }
        } else {    // if not contract
            if (token <= MAX_NATIVE_COINS) {
                to.safeTransferETH(value);
            } else {
                if(pair.isWrapped) {
                    IBEP20TokenCloned(token).mint(to, value);
                } else {
                    tokenDeposits[token] -= value;
                    token.safeTransfer(to, value);
                }
            }
        }
        emit ClaimToContract(token, to, value, txId, fromChainId, pair.token, toContract);
    }

    function depositTokens(
        address receiver,   // address of token receiver on destination chain
        address token,      // token that user send (if token address < 32, then send native coin)
        uint256 value,      // tokens value
        uint256 toChainId   // destination chain Id where will be claimed tokens
    ) 
        external
        payable
        notFrozen
    {
        require(functionMapping & 1 == 0, "locked");    // check bit 0
        require(receiver != address(0), "Incorrect receiver address");
        address pair_token = _deposit(token, value, toChainId);
        emit Deposit(token, receiver, value, toChainId, pair_token);
    }
    
    function depositTokens(
        address token,      // token that user send (if token address < 32, then send native coin)
        uint256 value,      // tokens value
        uint256 toChainId   // destination chain Id where will be claimed tokens
    ) 
        external
        payable
        notFrozen
    {
        address pair_token = _deposit(token, value, toChainId);
        emit Deposit(token, msg.sender, value, toChainId, pair_token);
    }
    
    function _deposit(
        address token,      // token that user send (if token address < 32, then send native coin)
        uint256 value,      // tokens value
        uint256 toChainId   // destination chain Id where will be claimed tokens
    ) 
        internal 
        returns (address pair_token) 
    {
        Token memory pair = tokenPair[toChainId][token];
        require(pair.token != address(0), "There is no pair");
        pair_token = pair.token;
        uint256 fee = msg.value;
        if (token <= MAX_NATIVE_COINS) {
            require(value <= msg.value, "Wrong value");
            fee -= value;
        } else {
            if(pair.isWrapped) {
                IBEP20TokenCloned(token).burnFrom(msg.sender, value);
            } else {
                tokenDeposits[token] += value;
                token.safeTransferFrom(msg.sender, address(this), value);
            }
        }
        if (fee != 0) {
            feeTo.safeTransferETH(fee);
            emit Fee(msg.sender, fee);
        }
    }

    // claim
    function claim(
        address token,          // token to receive
        bytes32 txId,           // deposit transaction hash on fromChain 
        address to,             // user address
        uint256 value,          // value of tokens
        uint256 fromChainId,    // chain ID where user deposited
        bytes[] memory sig      // authority signatures
    ) 
        external
        notFrozen
    {
        require(!isTxProcessed[fromChainId][txId], "Transaction already processed");
        Token memory pair = tokenPair[fromChainId][token];
        require(pair.token != address(0), "There is no pair");
        isTxProcessed[fromChainId][txId] = true;
        address must = requiredAuthority;
        bytes32 messageHash = keccak256(abi.encodePacked(token, to, value, txId, fromChainId, block.chainid));
        messageHash = prefixed(messageHash);
        uint256 uniqSig;
        uint256 set;    // maximum number of authorities is 255
        for (uint i = 0; i < sig.length; i++) {
            address authority = recoverSigner(messageHash, sig[i]);
            if (authority == must) must = address(0);
            uint256 index = authorities.indexOf(authority);
            uint256 mask = 1 << index;
            if (index != 0 && (set & mask) == 0 ) {
                set |= mask;
                uniqSig++;
            }
        }
        require(threshold <= uniqSig, "Require more signatures");
        require(must == address(0), "The required authority does not sign");

        if (token <= MAX_NATIVE_COINS) {
            to.safeTransferETH(value);
        } else {
            if(pair.isWrapped) {
                IBEP20TokenCloned(token).mint(to, value);
            } else {
                tokenDeposits[token] -= value;
                token.safeTransfer(to, value);
            }
        }
        emit Claim(token, to, value, txId, fromChainId, pair.token);
    }

    // Signature methods

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}