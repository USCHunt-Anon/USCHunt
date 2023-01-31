/**
 *Submitted for verification at BscScan.com on 2021-07-19
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
    function upgradeTo(address newImplementation) external ifAdmin {
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


// File: contracts/bep20/BEP20UpgradeableProxy.sol
// initialize() = 0x8129fc1c
contract ReimbursementUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {

    }
}

// : No License (None)
pragma solidity ^0.8.0;

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
/*  we use proxy, so owner will be set in initialize() function
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
*/
    function initialize() external {
        require(_owner == address(0), "Already initialized");
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

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

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function mint(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
contract TokenVault {
    
    address private _owner;
    address public reimbursementToken;
    address public factory;
    
    
    constructor(address _token) {
        reimbursementToken = _token;
        factory = msg.sender;
    }
    
    function owner() public view returns (address) {
        return Reimbursement(factory).getVaultOwner(address(this));
    }

    function transferToken(address to, uint256 amount) external {
        require(msg.sender == factory,"caller should be factory");
        safeTransfer(reimbursementToken, to, amount);
    }

    // vault owner can withdraw unreserved tokens
    function withdrawTokens(uint256 amount) external {
        require(msg.sender == owner(), "caller should be owner");
        uint256 available = Reimbursement(factory).getAvailableTokens(address(this));
        require(available >= amount, "not enough available tokens");
        safeTransfer(reimbursementToken, msg.sender, amount);
    }

    // allow owner to withdraw third-party tokens from contract address
    function rescueTokens(address someToken) external {
        require(msg.sender == owner(), "caller should be owner");
        require(someToken != reimbursementToken, "Only third-party token");
        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
    }
    
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

}

contract Reimbursement is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Stake {
        uint256 startTime;  // stake start at timestamp
        uint256 amount;     // staked tokens amount
    }

    struct Setting {
        address token;  // reimbursement token
        bool isMintable; // token can be minted by this contract
        address owner;  // owner of reimbursement vault
        uint64 period;  // staking period in seconds (365 days)
        uint32 reimbursementRatio;     // the ratio of deposited amount to reimbursement amount (with 2 decimals)
        IUniswapV2Pair swapPair;   // uniswap compatible pair for token and native coin (ETH, BNB)
        bool isReversOrder; // if `true` then `token1 = token` otherwise `token0 = token`
    }

    mapping(address => Setting) public settings; // vault address (licensee address) => setting
    mapping(address => uint256) public totalReserved;    // vault address (licensee address) => total amount used for reimbursement
    mapping(address => mapping(address => uint256)) public balances;    // vault address => user address => eligible reimbursement balance
    mapping(address => mapping(address => Stake)) public staking;    // vault address => user address => Stake
    mapping(address => EnumerableSet.AddressSet) vaults;   // user address => licensee address list that user mat get reimbursement
    mapping(address => mapping(address => uint256)) licenseeFees;    // vault => contract => fee (with 2 decimals). I.e. 30 means 0.3%
    mapping(address => EnumerableSet.AddressSet) licenseeVaults;    // licensee address => list of vaults

    event StakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event UnstakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event SetLicenseeFee(address indexed vault, address indexed projectContract, uint256 fee);
    event VaultCreated(address indexed vault, address indexed owner, address indexed token);
    event SetVaultOwner(address indexed vault, address indexed oldOwner, address indexed newOwner);
    event ReimbursementAdded(address indexed vault, address indexed user, uint256 amount);

    // set percentage of fee (with 2 decimals) by licensee for selected `projectContract`
    function setLicenseeFee(address vault, address projectContract, uint256 fee) external {
        require(settings[vault].owner == msg.sender, "Only vault owner");
        licenseeFees[vault][projectContract] = fee;
        emit SetLicenseeFee(vault, projectContract, fee);
    }

    // get percentage of fee (with 2 decimals) set by licensee for selected `projectContract`
    function getLicenseeFee(address vault, address projectContract) external view returns(uint256 fee) {
        return licenseeFees[vault][projectContract];
    }

    // get list of licensee vaults addresses belong to licensee
    function getLicenseeVaults(address licensee) external view returns(address[] memory vault) {
        return licenseeVaults[licensee]._values;
    }

    // get list of vault addresses where user has tokens.
    function getVaults(address user) external view returns(address[] memory vault) {
        return vaults[user]._values;
    }

    // get numbers of vault where user has tokens.
    function getVaultsLength(address user) external view returns(uint256) {
        return vaults[user].length();
    }

    // get vault address by index
    function getVault(address user, uint256 index) external view returns(address) {
        return vaults[user].at(index);
    }

    // Get vault owner
    function getVaultOwner(address vault) external view returns(address) {
        return settings[vault].owner;
    }

    // change vault owner. Only current owner can call it.
    function setVaultOwner(address vault, address newOwner) external {
        require(msg.sender == settings[vault].owner, "caller should be owner");
        require(newOwner != address(0), "Wrong new owner address");
        emit SetVaultOwner(vault, settings[vault].owner, newOwner);
        settings[vault].owner = newOwner;
    }

    // get list of vault and balance where user can get reimbursement 
    function getVaultsBalance(address user) external view returns(address[] memory vault, uint256[] memory balance) {
        vault = vaults[user]._values;
        balance = new uint256[](vault.length);
        for (uint i = 0; i < vault.length; i++) {
            balance[i] = balances[vault[i]][user];
        }
    }

    // get available (not reserved) tokens amount in vault
    function getAvailableTokens(address vault) public view returns(uint256 available) {
        available = IBEP20(settings[vault].token).balanceOf(vault) - totalReserved[vault];
    }

    // get staked amount + rewards
    function getStakedAmount(address user, address vault) external view returns(uint256 amount) {
        Stake memory s = staking[vault][user];
        Setting memory set = settings[vault];
        uint256 balance = balances[vault][user];
        if (set.period == 0) {
            if (balance == 0) return 0;
            amount = balance;
        } else {
            if(s.amount == 0) return 0;
            uint256 interval = block.timestamp - s.startTime;
            amount = s.amount * 100 * interval / (set.period * set.reimbursementRatio);
        }
        if (amount > balance) amount = balance;
        amount += s.amount; // total amount: rewards + staking
    }

    // vault owner can withdraw unreserved tokens
    function withdrawTokens(address vault, uint256 amount) external {
        require(msg.sender == settings[vault].owner, "caller should be owner");
        uint256 available = getAvailableTokens(vault);
        require(available >= amount, "not enough available tokens");
        TokenVault(vault).transferToken(msg.sender, amount);
    }

    // Stake `amount` of token to `vault` to receive reimbursement
    function stake(address vault, uint256 amount) external {
        uint256 balance = balances[vault][msg.sender];
        require(balance != 0, "No tokens for reimbursement");
        Stake storage s = staking[vault][msg.sender];
        uint256 currentStake = s.amount;
        safeTransferFrom(settings[vault].token, msg.sender, vault, amount);
        totalReserved[vault] += amount;
        if (currentStake != 0) {
            // recalculate time due new amount: old interval * old amount = new interval * new amount
            uint256 interval = block.timestamp - s.startTime;
            interval = interval * currentStake / (currentStake + amount);
            s.startTime = block.timestamp - interval;
            s.amount = currentStake + amount;
        } else {
            s.startTime = block.timestamp;
            s.amount = amount;
        }
        emit StakeToken(vault, msg.sender, block.timestamp, amount);
    }

    // Withdraw staked tokens + reward from vault.
    function unstake(address vault) external {
        Stake memory s = staking[vault][msg.sender];
        Setting memory set = settings[vault];
        uint256 amount;
        uint256 balance = balances[vault][msg.sender];
        if (set.period == 0) {
            require(balance != 0, "No reimbursement");
            amount = balance;
        } else {
            require(s.amount != 0, "No stake");
            uint256 interval = block.timestamp - s.startTime;
            amount = s.amount * 100 * interval / (set.period * set.reimbursementRatio);
        }
        delete staking[vault][msg.sender];   // remove staking record.
        if (amount > balance) amount = balance;
        balance -= amount;
        balances[vault][msg.sender] = balance;
        if (balance == 0) {
            vaults[msg.sender].remove(vault); // remove vault from vaults list where user has reimbursement tokens
        }
        if (set.isMintable) {
            totalReserved[vault] -= s.amount;
            TokenVault(vault).transferToken(msg.sender, s.amount); // withdraw staked amount
            IBEP20(set.token).mint(msg.sender, amount); // mint reimbursement token
            amount += s.amount; // total amount: rewards + staking
        } else {
            amount += s.amount; // total amount: rewards + staking
            totalReserved[vault] -= amount;
            TokenVault(vault).transferToken(msg.sender, amount); // withdraw staked amount + rewards
        }
        emit UnstakeToken(vault, msg.sender, block.timestamp, amount);
    }

    // Request reimburse to user
    // address user - address of user whp paid the fee
    // uint256 feeAmount - amount of fee in native coin (ETH, BNB)
    // address vault - licensee vault address that licensee get after registration. Use it as Licensee ID.
    // returns address of fee receiver or address(0) if licensee can't receive the fee (should be returns to user)
    function requestReimbursement(address user, uint256 feeAmount, address vault) external returns(address licenseeAddress){
        uint256 licenseeFee = licenseeFees[vault][msg.sender];
        if (licenseeFee == 0) return address(0); // project contract not added to reimbursement
        Setting memory set = settings[vault];
        (uint256 reserve0, uint256 reserve1,) = set.swapPair.getReserves();
        if (set.isReversOrder) (reserve0, reserve1) = (reserve1, reserve0);
        uint256 amount = reserve0 * feeAmount / reserve1;

        if (!set.isMintable) {
            uint256 reserve = totalReserved[vault];
            uint256 available = IBEP20(set.token).balanceOf(vault) - reserve;
            if (available < amount) return address(0);  // not enough reimbursement tokens
            totalReserved[vault] = reserve + amount;
        }

        uint256 balance = balances[vault][user];
        if (balance == 0) vaults[user].add(vault);
        balances[vault][user] = balance + amount;
        emit ReimbursementAdded(vault, user, amount);
        return set.owner;
    }

    function changeVaultSwapPair(address vault, address newPair) external {
        require(msg.sender == settings[vault].owner, "caller should be owner");
        require(newPair != address(0), "Zero address");
        bool isReversOrder;
        address token = settings[vault].token;
        if (IUniswapV2Pair(newPair).token1() == token) {
            isReversOrder == true;
        } else {
            require(IUniswapV2Pair(newPair).token0() == token, "Wrong swap pair");
        }
        settings[vault].isReversOrder = isReversOrder;
        settings[vault].swapPair = IUniswapV2Pair(newPair);
    }

    // create new vault (register Licensee)
    function newVault(
        address token,              // reimbursement token
        bool isMintable,            // token can be minted by this contract
        uint64 period,              // staking period in seconds (365 days)
        uint32 reimbursementRatio,   // the ratio of deposited amount to reimbursement amount (with 2 decimals). 
        address swapPair,           // uniswap compatible pair for token and native coin (ETH, BNB)
        uint32[] memory licenseeFee,         // percentage of Licensee fee (with 2 decimals). I.e. 30 means 0.3%
        address[] memory projectContract     // contract that has right to request reimbursement
    ) 
        external 
        returns(address vault) // vault - is the vault contract address where project has to transfer tokens. A licensee has to use it as Licensee ID.
    {
        if (isMintable) {
            require(msg.sender == owner(), "Only owner may add mintable token");
        }
        bool isReversOrder;
        if (IUniswapV2Pair(swapPair).token1() == token) {
            isReversOrder == true;
        } else {
            require(IUniswapV2Pair(swapPair).token0() == token, "Wrong swap pair");
        }
        vault = address(new TokenVault(token));
        licenseeVaults[msg.sender].add(vault);
        settings[vault] = Setting(token, isMintable, msg.sender, period, reimbursementRatio, IUniswapV2Pair(swapPair), isReversOrder);
        require(licenseeFee.length == projectContract.length, "Wrong length");
        for (uint i = 0; i < projectContract.length; i++) {
            require(licenseeFee[i] <= 10000, "Wrong fee");
            licenseeFees[vault][projectContract[i]] = licenseeFee[i];
            emit SetLicenseeFee(vault, projectContract[i], licenseeFee[i]);
        }
        emit VaultCreated(vault, msg.sender, token);
    }

    // This contract should not received any tokens, but due issue in ERC20 standard we can't disallow someone to do it.
    // If someone accidentally transfer tokens to this contract, the owner will be able to rescue it and refund sender.
    function rescueTokens(address someToken) external onlyOwner {
        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
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

}