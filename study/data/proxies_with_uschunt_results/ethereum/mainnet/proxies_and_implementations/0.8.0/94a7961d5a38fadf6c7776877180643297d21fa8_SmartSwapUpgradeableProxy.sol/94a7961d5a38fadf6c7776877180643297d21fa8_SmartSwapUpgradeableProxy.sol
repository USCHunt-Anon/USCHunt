/**
 *Submitted for verification at Etherscan.io on 2022-03-17
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

contract SmartSwapUpgradeableProxy is TransparentUpgradeableProxy {

    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {

    }
}

// : No License (None)
pragma solidity ^0.8.0;

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


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IValidator {
    // returns rate (with 18 decimals) = Token B price / Token A price
    function getRate(address tokenA, address tokenB) external returns (uint256);
    // returns: user balance, native (foreign for us) encoded balance, foreign (native for us) encoded balance
    function checkBalances(address factory, address[] calldata user) external returns(uint256);
    // returns: user balance
    function checkBalance(address factory, address user) external returns(uint256);
    // returns: oracle fee
    function getOracleFee(uint256 req) external returns(uint256);  //req: 1 - cancel, 2 - claim, returns: value
}

interface IReimbursement {
    // returns fee percentage with 2 decimals
    function getLicenseeFee(address vault, address projectContract) external view returns(uint256);
    // returns fee receiver address or address(0) if need to refund fee to user.
    function requestReimbursement(address user, uint256 feeAmount, address vault) external returns(address);
}

interface ISPImplementation {
    function initialize(
        address _owner,     // contract owner
        address _nativeToken, // native token that will be send to SmartSwap
        address _foreignToken, // foreign token that has to be received from SmartSwap (on foreign chain)
        address _nativeTokenReceiver, // address on Binance to deposit native token
        address _foreignTokenReceiver, // address on Binance to deposit foreign token
        uint256 _feeAmountLimit // limit of amount that System withdraw for fee reimbursement
    )   external;
    function owner() external returns(address);
}

interface IAuction {
    function contributeFromSmartSwap(address payable user) external payable returns (bool);
    function contributeFromSmartSwap(address token, uint256 amount, address user) external returns (bool);
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


contract SmartSwap is Ownable {

    struct Cancel {
        uint64 pairID; // pair ID
        address sender; // user who has to receive canceled amount
        uint256 amount; // amount of token user want to cancel from order
        //uint128 foreignBalance; // amount of token already swapped (on other chain)
    }

    struct Claim {
        uint64 pairID;     // pair ID
        address sender;     // address who send tokens to swap
        address receiver;   // address who has to receive swapped amount
        uint64 claimID;     // uniq claim ID
        bool isInvestment;  // is claim to contributeFromSmartSwap
        uint128 amount;     // amount of foreign tokens user want to swap
        uint128 currentRate;
        uint256 foreignBalance;  //[0] foreignBalance, [1] foreignSpent, [2] nativeSpent, [3] nativeRate
    }

    struct Pair {
        address tokenA;
        address tokenB;        
    }

    address constant NATIVE_COINS = 0x0000000000000000000000000000000000000009; // 1 - BNB, 2 - ETH, 3 - BTC
    uint256 constant NOMINATOR = 10**18;
    uint256 constant MAX_AMOUNT = 2**128;

    address public foreignFactory;
    address payable public validator;
    uint256 public rateDiffLimit;   // allowed difference (in percent) between LP provided rate and Oracle rate.
    mapping(address => bool) public isSystem;  // system address mey change fee amount
    address public auction; // auction address
    address public contractSmart;  // the reimbursement contract address
    mapping (address => uint256) licenseeFee;  // NOT USED. the licensee may set personal fee (in percent wih 2 decimals). It have to compensate this fee with own tokens.
    mapping (address => address) licenseeCompensator;    // NOT USED. licensee contract which will compensate fee with tokens
 
    mapping(address => bool) public isExchange;         // is Exchange address
    mapping(address => bool) public isExcludedSender;   // address excluded from receiving SMART token as fee compensation

    // fees
    uint256 public swapGasReimbursement;      // percentage of swap Gas Reimbursement by SMART tokens
    uint256 public companyFeeReimbursement;   // percentage of company Fee Reimbursement by SMART tokens
    uint256 public cancelGasReimbursement;    // percentage of cancel Gas Reimbursement by SMART tokens
    uint256 public companyFee; // the fee (in percent wih 2 decimals) that received by company. 30 - means 0.3%
    uint256 public processingFee; // the fee in base coin, to compensate Gas when back-end call claimTokenBehalf()
    address public feeReceiver; // address which receive the fee (by default is validator)
    uint256 private collectedFees; // amount of collected fee (starts from 1 to avoid additional gas usage)

    mapping(address => uint256) public decimals;   // token address => token decimals
    uint256 public pairIDCounter;
    mapping(uint256 => Pair) public getPairByID;
    mapping(address => mapping(address => uint256)) public getPairID;    // tokenA => tokenB => pair ID or 0 if not exist
    mapping(uint256 => uint256) public totalSupply;    // pairID => totalSupply amount of tokenA on the pair

    // hashAddress = address(keccak256(tokenA, tokenB, sender, receiver))
    mapping(address => uint256) private _balanceOf;       // hashAddress => amount of tokenA
    mapping(address => Cancel) public cancelRequest;    // hashAddress => amount of tokenA to cancel
    mapping(address => Claim) public claimRequest;      // hashAddress => amount of tokenA to swap

    mapping(address => bool) public isLiquidityProvider;    // list of Liquidity Providers
    uint256 claimIdCounter;    // counter of claim requests
    address public reimbursementVault;  //company vault address in reimbursement contract
    address public SPImplementation;  // address of swap provider contract implementation
    uint256 public companySPFee; // the fee (in percent wih 2 decimals) that received by company from Swap provider. 30 - means 0.3%
    uint256 collectedProcessingFee;

// ============================ Events ============================

    event PairAdded(address indexed tokenA, address indexed tokenB, uint256 indexed pairID);
    event PairRemoved(address indexed tokenA, address indexed tokenB, uint256 indexed pairID);
    event SwapRequest(
        address indexed tokenA,
        address indexed tokenB,
        address indexed sender,
        address receiver,
        uint256 amountA,
        bool isInvestment,
        uint128 minimumAmountToClaim,   // do not claim on user behalf less of this amount. Only exception if order fulfilled.
        uint128 limitPice   // Do not match user if token A price less this limit
    );
    event CancelRequest(address indexed hashAddress, uint256 amount);
    event CancelApprove(address indexed hashAddress, uint256 amount);
    event ClaimRequest(address indexed hashAddress, uint64 claimID, uint256 amount, bool isInvestment);
    event ClaimApprove(address indexed hashAddress, uint64 claimID, uint256 nativeAmount, uint256 foreignAmount, bool isInvestment);
    event ExchangeInvestETH(address indexed exchange, address indexed whom, uint256 value);
    event SetSystem(address indexed system, bool active);
    event AddSwapProvider(address swapProvider, address spContract);
    event PartialClaim(uint256 rest, uint256 totalSupply, uint256 nativeAmount);

    /**
    * @dev Throws if called by any account other than the system.
    */
    modifier onlySystem() {
        require(isSystem[msg.sender] || isLiquidityProvider[msg.sender] || owner() == msg.sender, "Caller is not the system");
        _;
    }


    // run only once from proxy
    function initialize(address newOwner) external {
        require(newOwner != address(0) && _owner == address(0)); // run only once
        _owner = newOwner;
        emit OwnershipTransferred(address(0), msg.sender);
        rateDiffLimit = 5;   // allowed difference (in percent) between LP provided rate and Oracle rate.
        swapGasReimbursement = 100;      // percentage of swap Gas Reimbursement by SMART tokens
        companyFeeReimbursement = 100;   // percentage of company Fee Reimbursement by SMART tokens
        cancelGasReimbursement = 100;    // percentage of cancel Gas Reimbursement by SMART tokens
        companyFee = 0; // the fee (in percent wih 2 decimals) that received by company. 30 - means 0.3%
        collectedFees = 1; // amount of collected fee (starts from 1 to avoid additional gas usage)
    }

    // get amount of collected fees that can be claimed
    function getColletedFees() external view returns (uint256) {
        // collectedFees starts from 1 to avoid additional gas usage to initiate storage (when collectedFees = 0)
        return collectedFees - 1;
    }

    // get amount of collected fees that can be claimed
    function getProcessingFees() external view returns (uint256) {
        // collectedFees starts from 1 to avoid additional gas usage to initiate storage (when collectedFees = 0)
        return collectedProcessingFee - 1;
    }

    function claimProcessingFees() external onlySystem returns (uint256 processingFeeAmount) {
        processingFeeAmount = collectedProcessingFee - 1;
        collectedProcessingFee = 1;
        TransferHelper.safeTransferETH(msg.sender, processingFeeAmount);
    }

    // claim fees by feeReceiver
    function claimFee() external returns (uint256 feeAmount)
    {
        require(msg.sender == feeReceiver);
        feeAmount = collectedFees - 1;
        collectedFees = 1;
        TransferHelper.safeTransferETH(msg.sender, feeAmount);
    }

    function balanceOf(address hashAddress) external view returns(uint256) {
        return _balanceOf[hashAddress];
    }

    // return balance for swap
    function getBalance(
        address tokenA,
        address tokenB, 
        address sender,
        address receiver
    )
        external
        view
        returns (uint256)
    {
        return _balanceOf[_getHashAddress(tokenA, tokenB, sender, receiver)];
    }

    function getHashAddress(
        address tokenA,
        address tokenB, 
        address sender,
        address receiver
    )
        external
        pure
        returns (address)
    {
        return _getHashAddress(tokenA, tokenB, sender, receiver);
    }

    //user should approve tokens transfer before calling this function.
    //if no licensee set it to address(0)
    function swap(
        address tokenA, // token that user send to swap ( address(1) for BNB, address(2) for ETH)
        address tokenB, // token that user want to receive ( address(1) for BNB, address(2) for ETH)
        address receiver,   // address that will receive tokens on other chain (user's wallet address)
        uint256 amountA,    // amount of tokens user sends to swap
        address licensee,   // for now, = address(0)
        bool isInvestment,  // for now, = false
        uint128 minimumAmountToClaim,   // do not claim on user behalf less of this amount. Only exception if order fulfilled. For now, = 0
        uint128 limitPice,   // Do not match user if token A price less this limit. For now, = 0
        uint256 fee          // company + licensee fee amount
    )
        external
        payable
        returns (bool)
    {
        _transferFee(tokenA, amountA, fee, msg.sender, licensee);
        _swap(tokenA, tokenB, msg.sender, receiver, amountA, isInvestment, minimumAmountToClaim, limitPice);
        return true;
    }

    function cancel(
        address tokenA,
        address tokenB, 
        address receiver,
        uint256 amountA    //amount of tokenA to cancel
    )
        external
        payable
        returns (bool)
    {
        _cancel(tokenA, tokenB, msg.sender, receiver, amountA);
        return true;
    }

    function cancelBehalf(
        address tokenA,
        address tokenB,
        address sender,
        address receiver,
        uint256 amountA    //amount of tokenA to cancel
    )
        external
        onlySystem
        returns (bool)
    {
        _cancel(tokenA, tokenB, sender, receiver, amountA);
        return true;
    }

    function claimTokenBehalf(
        address tokenA, // foreignToken
        address tokenB, // nativeToken
        address sender,
        address receiver,
        bool isInvestment,
        uint128 amountA,    //amount of tokenA that has to be swapped
        uint128 currentRate,     // rate with 18 decimals: tokenA price / tokenB price
        uint256 foreignBalance  // total tokens amount sent by user to pair on other chain
    )        
        external
        onlySystem
        returns (bool) 
    {
        _claimTokenBehalf(tokenA, tokenB, sender, receiver, isInvestment, amountA, currentRate, foreignBalance);
        return true;
    }

    // add swap provider who will provide liquidity for swap (using centralized exchange)
    function addSwapProvider(
        address _nativeToken, // native token that will be send to SmartSwap
        address _foreignToken, // foreign token that has to be received from SmartSwap (on foreign chain)
        address _nativeTokenReceiver, // address on Binance to deposit native token
        address _foreignTokenReceiver, // address on Binance to deposit foreign token
        uint256 _feeAmountLimit // limit of amount that System may withdraw for fee reimbursement
    )
        external
        returns (address spContract)
    {
        spContract = clone(SPImplementation);
        ISPImplementation(spContract).initialize(
            msg.sender,
            _nativeToken,
            _foreignToken,
            _nativeTokenReceiver,
            _foreignTokenReceiver,
            _feeAmountLimit
        );
        isLiquidityProvider[spContract] = true;
        emit AddSwapProvider(msg.sender, spContract);
    }

    function balanceCallback(address hashAddress, uint256 foreignBalance) external returns(bool) {
        require (validator == msg.sender, "Not validator");
        _cancelApprove(hashAddress, foreignBalance);
        return true;
    }

    function balancesCallback(
        address hashAddress, 
        uint256 foreignBalance, // total user's tokens balance on foreign chain
        uint256 foreignSpent,   // total tokens spent by SmartSwap pair
        uint256 nativeEncoded   // (nativeRate, nativeSpent) = _decode(nativeEncoded)
    ) 
        external 
        returns(bool) 
    {
        require (validator == msg.sender, "Not validator");
        _claimBehalfApprove(hashAddress, foreignBalance, foreignSpent, nativeEncoded);
        return true;
    }

    // get system variables for debugging 
    function getPairVars(uint256 pairID) external view returns (uint256 native, uint256 foreign, uint256 foreignRate) {
        address nativeHash = _getHashAddress(getPairByID[pairID].tokenA, getPairByID[pairID].tokenB, address(0), address(0));
        address foreignHash = _getHashAddress(getPairByID[pairID].tokenB, getPairByID[pairID].tokenA, address(0), address(0));
        // native - amount of native tokens that swapped from available foreign
        native = _balanceOf[nativeHash];
        // foreign = total foreign tokens already swapped
        // foreignRate = rate (native price / foreign price) of available foreign tokens on other chain
        (foreignRate, foreign) = _decode(_balanceOf[foreignHash]);
        // Example: assume system vars = 0, rate of prices ETH/BNB = 2 (or BNB/ETH = 0.5)
        // on ETH chain: 
        // 1. claim ETH for 60 BNB == 60 * 0.5 = 30 ETH, 
        // set: foreign = 60 BNB, foreignRate = 0.5 BNB/ETH prices (already swapped BNB)
        //
        // on BSC chain:
        // 2. claim BNB for 20 ETH, assume new rate of prices ETH/BNB = 4 (or BNB/ETH = 0.25)
        // get from ETH chain foreign(ETH) = 60 BNB, foreignRate(ETH) = 0.5 BNB/ETH prices
        // available amount of already swapped BNB = 60 BNB (foreign from ETH) - 0 BNB (native) = 60 BNB with rate 0.5 BNB/ETH
        // claimed BNB amount = 20 ETH / 0.5 BNB/ETH = 40 BNB (we use rate of already swapped BNB)
        // set: native = 40 BNB (we use BNB that was already swapped on step 1)
        //
        // 3. New claim BNB for 30 ETH, assume new rate of prices ETH/BNB = 4 (or BNB/ETH = 0.25)
        // get from ETH chain foreign(ETH) = 60 BNB, foreignRate(ETH) = 0.5 BNB/ETH prices
        // available amount of already swapped BNB = 60 BNB (foreign from ETH) - 40 BNB (native) = 20 BNB with rate 0.5 BNB/ETH
        // 20 BNB * 0.5 = 10 ETH (we claimed 20 BNB for 10 ETH with already swapped rate)
        // set: native = 40 BNB + 20 BNB = 60 BNB (we use all BNB that was already swapped on step 1)
        // claimed rest BNB amount for (30-10) ETH = 20 ETH / 0.25 BNB/ETH = 80 BNB (we use new rate)
        // set: foreign = 20 ETH, foreignRate = 0.25 BNB/ETH prices (already swapped ETH)
    }
// ================== For Jointer Auction =========================================================================

    // ETH side
    // function for invest ETH from from exchange on user behalf
    function contributeWithEtherBehalf(address payable _whom) external payable returns (bool) {
        require(isExchange[msg.sender], "Not an Exchange address");
        address tokenA = address(2);    // ETH (native coin)
        address tokenB = address(1);    // BNB (foreign coin)
        uint256 amount = msg.value - processingFee; // charge processing fee
        amount = amount * 10000 / (10000 + companyFee); // charge company fee
        uint256 fee = msg.value - (amount + processingFee); // company fee
        emit ExchangeInvestETH(msg.sender, _whom, msg.value);
        _transferFee(tokenA, amount, fee, _whom, address(0));    // no licensee
        _swap(tokenA, tokenB, _whom, auction, amount, true,0,0);
        return true;
    }

    // BSC side
    // tokenB - foreign token address or address(1) for ETH
    // amountB - amount of foreign tokens or ETH
    function claimInvestmentBehalf(
        address tokenB, // foreignToken
        address user, 
        uint128 amountB,    //amount of tokenB that has to be swapped
        uint128 currentRate,     // rate with 18 decimals: tokenB price / Native coin price
        uint256 foreignBalance  // total tokens amount sent by user to pair on other chain
    ) 
        external 
        onlySystem 
        returns (bool) 
    {
        address tokenA = address(1);    // BNB (native coin)
        _claimTokenBehalf(tokenB, tokenA, user, auction, true, amountB, currentRate, foreignBalance);
        return true;
    }
    
    // reimburse user for SP payment
    function reimburse(address user, uint256 amount) external onlySystem {
        address reimbursementContract = contractSmart;
        if (reimbursementContract != address(0) && amount !=0) {
            IReimbursement(reimbursementContract).requestReimbursement(user, amount, reimbursementVault);
        }
    }
// ================= END For Jointer Auction ===========================================================================

// ============================ Restricted functions ============================

    // set processing fee - amount that have to be paid on other chain to claimTokenBehalf.
    // Set in amount of native coins (BNB or ETH)
    function setProcessingFee(uint256 _fee) external onlySystem returns(bool) {
        processingFee = _fee;
        return true;
    }
/*
    // set licensee compensator contract address, if this address is address(0) - remove licensee.
    // compensator contract has to compensate the fee by other tokens.
    // licensee fee in percent with 2 decimals. I.e. 10 = 0.1%
    function setLicensee(address _licensee, address _compensator, uint256 _fee) external onlySystem returns(bool) {
        licenseeCompensator[_licensee] = _compensator;
        require(_fee < 10000, "too big fee");    // fee should be less then 100%
        licenseeFee[_licensee] = _fee;
        emit SetLicensee(_licensee, _compensator);
        return true;
    }

    // set licensee fee in percent with 2 decimals. I.e. 10 = 0.1%
    function setLicenseeFee(uint256 _fee) external returns(bool) {
        require(licenseeCompensator[msg.sender] != address(0), "licensee is not registered");
        require(_fee < 10000, "too big fee");    // fee should be less then 100%
        licenseeFee[msg.sender] = _fee;
        return true;
    }
*/
// ============================ Owner's functions ============================

    //allowed difference in rate between Oracle and provided by company. in percent without decimals (5 = 5%)
    function setRateDiffLimit(uint256 _rateDiffLimit) external onlyOwner returns(bool) {
        require(_rateDiffLimit < 100, "too big limit");    // fee should be less then 100%
        rateDiffLimit = _rateDiffLimit;
        return true;
    }

    //the fee (in percent wih 2 decimals) that received by company. 30 - means 0.3%
    function setCompanyFee(uint256 _fee) external onlyOwner returns(bool) {
        require(_fee < 10000, "too big fee");    // fee should be less then 100%
        companyFee = _fee;
        return true;
    }

    //the fee (in percent wih 2 decimals) that received by company from Swap provider. 30 - means 0.3%
    function setCompanySPFee(uint256 _fee) external onlyOwner returns(bool) {
        require(_fee < 10000, "too big fee");    // fee should be less then 100%
        companySPFee = _fee;
        return true;
    }

    // Reimbursement Percentage without decimals: 100 = 100%
    function setReimbursementPercentage (uint256 id, uint256 _fee) external onlyOwner returns(bool) {
        if (id == 1) swapGasReimbursement = _fee;      // percentage of swap Gas Reimbursement by SMART tokens
        else if (id == 2) cancelGasReimbursement = _fee;    // percentage of cancel Gas Reimbursement by SMART tokens
        else if (id == 3) companyFeeReimbursement = _fee;   // percentage of company Fee Reimbursement by SMART tokens
        return true;
    }

    function setSystem(address _system, bool _active) external onlyOwner returns(bool) {
        isSystem[_system] = _active;
        emit SetSystem(_system, _active);
        return true;
    }

    function setValidator(address payable _validator) external onlyOwner returns(bool) {
        validator = _validator;
        return true;
    }

    function setForeignFactory(address _addr) external onlyOwner returns(bool) {
        foreignFactory = _addr;
        return true;
    }

    function setFeeReceiver(address _addr) external onlyOwner returns(bool) {
        feeReceiver = _addr;
        return true;
    }

    function setReimbursementContractAndVault(address reimbursement, address vault) external onlyOwner returns(bool) {
        contractSmart = reimbursement;
        reimbursementVault = vault;
        return true;
    }

    function setAuction(address _addr) external onlyOwner returns(bool) {
        auction = _addr;
        return true;
    }

    // for ETH side only
    function changeExchangeAddress(address _which,bool _bool) external onlyOwner returns(bool){
        isExchange[_which] = _bool;
        return true;
    }
    
    function changeExcludedAddress(address _which,bool _bool) external onlyOwner returns(bool){
        isExcludedSender[_which] = _bool;
        return true;
    }

    function createPair(address tokenA, uint256 decimalsA, address tokenB, uint256 decimalsB) public onlyOwner returns (uint256) {
        require(getPairID[tokenA][tokenB] == 0, "Pair exist");
        uint256 pairID = ++pairIDCounter;
        getPairID[tokenA][tokenB] = pairID;
        getPairByID[pairID] = Pair(tokenA, tokenB);
        if (decimals[tokenA] == 0) decimals[tokenA] = decimalsA;
        if (decimals[tokenB] == 0) decimals[tokenB] = decimalsB;
        return pairID;
    }

    function setSPImplementation(address _SPImplementation) external onlyOwner {
        require(_SPImplementation != address(0));
        SPImplementation = _SPImplementation;
    }

// ============================ Internal functions ============================
    function _swap(
        address tokenA, // nativeToken
        address tokenB, // foreignToken
        address sender,
        address receiver,
        uint256 amountA,
        bool isInvestment,
        uint128 minimumAmountToClaim,   // do not claim on user behalf less of this amount. Only exception if order fulfilled.
        uint128 limitPice   // Do not match user if token A price less this limit
    )
        internal
    {
        uint256 pairID = getPairID[tokenA][tokenB];
        require(pairID != 0, "Pair not exist");
        if (tokenA > NATIVE_COINS) {
            TransferHelper.safeTransferFrom(tokenA, sender, address(this), amountA);
        }
        // (amount >= msg.value) is checking when pay fee in the function transferFee()
        address hashAddress = _getHashAddress(tokenA, tokenB, sender, receiver);
        _balanceOf[hashAddress] += amountA;
        totalSupply[pairID] += amountA;
        emit SwapRequest(tokenA, tokenB, sender, receiver, amountA, isInvestment, minimumAmountToClaim, limitPice);
    }

    function _cancel(
        address tokenA, // nativeToken
        address tokenB, // foreignToken
        address sender,
        address receiver,
        uint256 amountA    //amount of tokenA to cancel
        //uint128 foreignBalance // amount of tokenA swapped by hashAddress (get by server-side)
    )
        internal
    {
        if(!isSystem[msg.sender]) { // process fee if caller is not System
            require(msg.value >= IValidator(validator).getOracleFee(1), "Insufficient fee");    // check oracle fee for Cancel request
            collectedFees += msg.value;
            if(contractSmart != address(0) && !isExcludedSender[sender]) {
                uint256 feeAmount = (msg.value + 60000*tx.gasprice) * cancelGasReimbursement / 100;
                if (feeAmount != 0)
                    IReimbursement(contractSmart).requestReimbursement(sender, feeAmount, reimbursementVault);
            }
        }

        address hashAddress = _getHashAddress(tokenA, tokenB, sender, receiver);
        uint256 pairID = getPairID[tokenA][tokenB];
        require(pairID != 0, "Pair not exist");
        if (cancelRequest[hashAddress].amount == 0) {  // new cancel request
            uint256 balance = _balanceOf[hashAddress];
            require(balance >= amountA && amountA != 0, "Wrong amount");
            totalSupply[pairID] = totalSupply[pairID] - amountA;
            _balanceOf[hashAddress] = balance - amountA;
        } else {
            revert("There is pending cancel request");
        }
        cancelRequest[hashAddress] = Cancel(uint64(pairID), sender, amountA);
        // request Oracle for fulfilled amount from hashAddress
        IValidator(validator).checkBalance(foreignFactory, hashAddress);
        emit CancelRequest(hashAddress, amountA);
        //emit CancelRequest(tokenA, tokenB, sender, receiver, amountA);
    }

    function _cancelApprove(address hashAddress, uint256 foreignBalance) internal {
        Cancel memory c = cancelRequest[hashAddress];
        delete cancelRequest[hashAddress];
        //require(c.foreignBalance == foreignBalance, "Oracle error");
        uint256 balance = _balanceOf[hashAddress];
        uint256 amount = uint256(c.amount);
        uint256 pairID = uint256(c.pairID);
        if (foreignBalance <= balance) {
            //approved - transfer token to its sender
            _transfer(getPairByID[pairID].tokenA, c.sender, amount);
        } else {
            //disapproved
            balance += amount;
            _balanceOf[hashAddress] = balance;
            totalSupply[pairID] += amount;
            amount = 0;
        }
        emit CancelApprove(hashAddress, amount);
    }

    function _claimTokenBehalf(
        address tokenA, // foreignToken
        address tokenB, // nativeToken
        address sender,
        address receiver,
        bool isInvestment,
        uint128 amountA,    //amount of tokenA that has to be swapped
        uint128 currentRate,     // rate with 18 decimals: tokenA price / tokenB price
        uint256 foreignBalance  // total tokens amount sent bu user to pair on other chain
        // [1] foreignSpent, [2] nativeSpent, [3] nativeRate
    )
        internal
    {
        uint256 pairID = getPairID[tokenB][tokenA]; // getPairID[nativeToken][foreignToken]
        require(pairID != 0, "Pair not exist");
        // check rate
        uint256 diffRate;
        uint256 oracleRate = IValidator(validator).getRate(tokenB, tokenA);
        if (uint256(currentRate) < oracleRate) {
            diffRate = 100 - (uint256(currentRate) * 100 / oracleRate);
        } else {
            diffRate = 100 - (oracleRate * 100 / uint256(currentRate));
        }
        require(diffRate <= rateDiffLimit, "Wrong rate");

        uint64 claimID;
        address hashAddress = _getHashAddress(tokenA, tokenB, sender, receiver);
        if (claimRequest[hashAddress].amount == 0) {  // new claim request
            _balanceOf[hashAddress] += uint256(amountA); // total swapped amount of foreign token
            claimID = uint64(++claimIdCounter);
        } else { // repeat claim request in case oracle issues.
            claimID = claimRequest[hashAddress].claimID;
            if (amountA == 0) {    // cancel claim request
                emit ClaimApprove(hashAddress, claimID, 0, 0, claimRequest[hashAddress].isInvestment);
                _balanceOf[hashAddress] = _balanceOf[hashAddress] - claimRequest[hashAddress].amount;
                delete claimRequest[hashAddress];
                return;
            }
            amountA = claimRequest[hashAddress].amount;
        }
        address[] memory users = new address[](3);
        users[0] = hashAddress;
        users[1] = _getHashAddress(tokenA, tokenB, address(0), address(0)); // Native hash address on foreign chain
        users[2] = _getHashAddress(tokenB, tokenA, address(0), address(0)); // Foreign hash address on foreign chain
        claimRequest[hashAddress] = Claim(uint64(pairID), sender, receiver, claimID, isInvestment, amountA, currentRate, foreignBalance);
        IValidator(validator).checkBalances(foreignFactory, users);
        emit ClaimRequest(hashAddress, claimID, amountA, isInvestment);
        //emit ClaimRequest(tokenA, tokenB, sender, receiver, amountA);
    }

    // Approve or disapprove claim request.
    function _claimBehalfApprove(
        address hashAddress, 
        uint256 foreignBalance, // total user's tokens balance on foreign chain
        uint256 foreignSpent,   // total tokens spent by SmartSwap pair
        uint256 nativeEncoded   // (nativeSpent, nativeRate) = _decode(nativeEncoded)
    ) 
        internal 
    {
        Claim memory c = claimRequest[hashAddress];
        delete claimRequest[hashAddress];
        //address hashSwap = _getHashAddress(getPairByID[c.pairID].tokenB, getPairByID[c.pairID].tokenA, c.sender, c.receiver);
        uint256 balance = _balanceOf[hashAddress];   // swapped amount of foreign tokens (include current claim amount)
        uint256 amount = uint256(c.amount);     // amount of foreign token to swap
        require (amount != 0, "No active claim request");
        require(foreignBalance >= c.foreignBalance, "Oracle error");

        uint256 nativeAmount;
        uint256 rest;
        if (foreignBalance >= balance) {
            //approve, user deposited not less foreign tokens then want to swap
            uint256 pairID = uint256(c.pairID);
            (uint256 nativeRate, uint256 nativeSpent) = _decode(nativeEncoded);
            (nativeAmount, rest) = _calculateAmount(
                pairID,
                amount, 
                uint256(c.currentRate),
                foreignSpent,
                nativeSpent,
                nativeRate
            );
            if (rest != 0) {
                _balanceOf[hashAddress] = balance - rest;    // not all amount swapped
                amount = amount - rest;     // swapped amount
            }
            require(totalSupply[pairID] >= nativeAmount, "Not enough Total Supply");   // may be commented
            totalSupply[pairID] = totalSupply[pairID] - nativeAmount;
            if (c.isInvestment)
                _contributeFromSmartSwap(getPairByID[pairID].tokenA, c.receiver, c.sender, nativeAmount);
            else
                _transfer(getPairByID[pairID].tokenA, c.receiver, nativeAmount);
        } else {
            //disapprove, discard claim
            _balanceOf[hashAddress] = balance - amount;
            amount = 0;
        }
        emit ClaimApprove(hashAddress, c.claimID, nativeAmount, amount, c.isInvestment);
    }

    // use structure to avoid stack too deep
    struct CalcVariables {
        // 18 decimals nominator with decimals converter: 
        // Foreign = Native * Rate(18) / nominatorNativeToForeign
        uint256 nominatorForeignToNative; // 10**(18 + foreign decimals - native decimals)
        uint256 nominatorNativeToForeign; // 10**(18 + native decimals - foreign decimals)
        uint256 localNative;        // already swapped Native tokens = _balanceOf[hashNative]
        uint256 localForeign;       // already swapped Foreign tokens = decoded _balanceOf[hashForeign]
        uint256 localForeignRate;   // Foreign token price / Native token price = decoded _balanceOf[hashForeign]
        address hashNative;         // _getHashAddress(tokenA, tokenB, address(0), address(0));
        address hashForeign;        // _getHashAddress(tokenB, tokenA, address(0), address(0));
    }

    function _calculateAmount(
        uint256 pairID,
        uint256 foreignAmount,
        uint256 rate,    // Foreign token price / Native token price = (Native amount / Foreign amount)
        uint256 foreignSpent,   // already swapped Foreign tokens (got from foreign contract)
        uint256 nativeSpent,    // already swapped Native tokens (got from foreign contract)
        uint256 nativeRate  // Native token price / Foreign token price. I.e. on BSC side: BNB price / ETH price = 0.2
    )
        internal
        returns(uint256 nativeAmount, uint256 rest)
    {
        CalcVariables memory vars;
        {
            address tokenA = getPairByID[pairID].tokenA;
            address tokenB = getPairByID[pairID].tokenB;
            uint256 nativeDecimals = decimals[tokenA];
            uint256 foreignDecimals = decimals[tokenB];
            vars.nominatorForeignToNative = 10**(18+foreignDecimals-nativeDecimals);
            vars.nominatorNativeToForeign = 10**(18+nativeDecimals-foreignDecimals);
            vars.hashNative = _getHashAddress(tokenA, tokenB, address(0), address(0));
            vars.hashForeign = _getHashAddress(tokenB, tokenA, address(0), address(0));
            vars.localNative = _balanceOf[vars.hashNative];
            (vars.localForeignRate, vars.localForeign) = _decode(_balanceOf[vars.hashForeign]);
        }

        // step 1. Check is it enough unspent native tokens
        {
            require(nativeSpent >= vars.localNative, "NativeSpent balance higher then remote");
            uint256 nativeAvailable = nativeSpent - vars.localNative;
            // nativeAvailable - amount ready to spend native tokens
            // nativeRate = Native token price / Foreign token price. I.e. on BSC side BNB price / ETH price = 0.2
            if (nativeAvailable != 0) {
                // ?
                uint256 requireAmount = foreignAmount * vars.nominatorNativeToForeign / nativeRate;
                if (requireAmount <= nativeAvailable) {
                    nativeAmount = requireAmount;   // use already swapped tokens
                    foreignAmount = 0;
                }
                else {
                    nativeAmount = nativeAvailable;
                    foreignAmount = (requireAmount - nativeAvailable) * nativeRate / vars.nominatorNativeToForeign;
                }
                _balanceOf[vars.hashNative] += nativeAmount;
            }
        }
        require(totalSupply[pairID] >= nativeAmount,"ERR: Not enough Total Supply");
        // step 2. recalculate rate for swapped tokens
        if (foreignAmount != 0) {
            // i.e. on BSC side: rate = ETH price / BNB price = 5
            uint256 requireAmount = foreignAmount * rate / vars.nominatorForeignToNative;
            if (totalSupply[pairID] < nativeAmount + requireAmount) {
                requireAmount = totalSupply[pairID] - nativeAmount;
                rest = foreignAmount - (requireAmount * vars.nominatorForeignToNative / rate);
                foreignAmount = foreignAmount - rest;
                emit PartialClaim(rest, totalSupply[pairID], nativeAmount);
            }
            nativeAmount = nativeAmount + requireAmount;
            require(vars.localForeign >= foreignSpent, "ForeignSpent balance higher then local");
            uint256 foreignAvailable = vars.localForeign - foreignSpent;
            // vars.localForeignRate, foreignAvailable - rate and amount swapped foreign tokens
            if (foreignAvailable != 0) { // recalculate avarage rate (native amount / foreign amount)
                rate = ((foreignAvailable * vars.localForeignRate) + (requireAmount * vars.nominatorForeignToNative)) / (foreignAvailable + foreignAmount);
            }
            _balanceOf[vars.hashForeign] = _encode(rate, vars.localForeign + foreignAmount);
        }
    }

    // transfer fee to receiver and request SMART token as compensation.
    // tokenA - token that user send
    // amount - amount of tokens that user send
    // user - address of user
    function _transferFee(address tokenA, uint256 amount, uint256 fee, address user, address licensee) internal {
        uint256 txGas = gasleft();
        uint256 feeAmount = msg.value;
        uint256 companyFeeAmount; // company fee
        uint256 _companyFee;
        if (isLiquidityProvider[msg.sender]) {
            _companyFee = companySPFee;
            user = ISPImplementation(msg.sender).owner();
        } else {
            _companyFee = companyFee;
        }

        if (tokenA < NATIVE_COINS) {
            require(feeAmount >= amount, "Insuficiant value");   // if native coin, then feeAmount = msg.value - swap amount
            feeAmount -= amount;
            companyFeeAmount = amount * _companyFee / 10000;    // company fee
        }
        require(feeAmount >= processingFee + fee && fee >= companyFeeAmount, "Insufficient processing fee");
        if (contractSmart == address(0)) {
            collectedProcessingFee += feeAmount;
            return;    // return if no reimbursement contract 
        }
        uint256 _processingFee = feeAmount - fee;

        uint256 licenseeFeeAmount;
        if (licensee != address(0)) {
            uint256 licenseeFeeRate = IReimbursement(contractSmart).getLicenseeFee(licensee, address(this));
            if (licenseeFeeRate != 0 && fee != 0) {
                if (tokenA < NATIVE_COINS) {
                    licenseeFeeAmount = amount * licenseeFeeRate / 10000;
                } else {
                    licenseeFeeAmount = (fee * licenseeFeeRate)/(licenseeFeeRate + _companyFee);
                    companyFeeAmount = fee - licenseeFeeAmount;
                }
            }
        }
        if (fee >= companyFeeAmount + licenseeFeeAmount) {
            companyFeeAmount = fee - licenseeFeeAmount;
        } else {
            revert("Insuficiant fee");
        }

        if (licenseeFeeAmount != 0) {
            address licenseeFeeTo = IReimbursement(contractSmart).requestReimbursement(user, licenseeFeeAmount, licensee);
            if (licenseeFeeTo == address(0)) {
                TransferHelper.safeTransferETH(user, licenseeFeeAmount);    // refund to user
            } else {
                TransferHelper.safeTransferETH(licenseeFeeTo, licenseeFeeAmount); // transfer to fee receiver
            }
        }

        collectedFees += companyFeeAmount;
        collectedProcessingFee += _processingFee;
        if(!isExcludedSender[user]) {
            txGas -= gasleft(); // get gas amount that was spent on Licensee fee
            feeAmount = (companyFeeAmount * companyFeeReimbursement + (_processingFee + (txGas + 73000)*tx.gasprice) * swapGasReimbursement) / 100;
            if (feeAmount != 0)
                IReimbursement(contractSmart).requestReimbursement(user, feeAmount, reimbursementVault);
        }
    }
    
    // contribute from SmartSwap on user behalf
    function _contributeFromSmartSwap(address token, address to, address user, uint256 value) internal {
        if (token < NATIVE_COINS) {
            IAuction(to).contributeFromSmartSwap{value: value}(payable(user));
        } else {
            IERC20(token).approve(to, value);
            IAuction(to).contributeFromSmartSwap(token, value, user);
        }
    }

    // call appropriate transfer function
    function _transfer(address token, address to, uint256 value) internal {
        if (token < NATIVE_COINS) 
            TransferHelper.safeTransferETH(to, value);
        else
            TransferHelper.safeTransfer(token, to, value);
    }

    // encode 64 bits of rate (decimal = 9). and 192 bits of amount 
    // into uint256 where high 64 bits is rate and low 192 bit is amount
    // rate = foreign token price / native token price
    function _encode(uint256 rate, uint256 amount) internal pure returns(uint256 encodedBalance) {
        require(amount < MAX_AMOUNT, "Amount overflow");
        require(rate < MAX_AMOUNT, "Rate overflow");
        encodedBalance = rate * MAX_AMOUNT + amount;
    }

    // decode from uint256 where high 64 bits is rate and low 192 bit is amount
    // rate = foreign token price / native token price
    function _decode(uint256 encodedBalance) internal pure returns(uint256 rate, uint256 amount) {
        rate = encodedBalance / MAX_AMOUNT;
        amount = uint128(encodedBalance);
    }
    
    function _getHashAddress(
        address tokenA,
        address tokenB, 
        address sender,
        address receiver
    )
        internal
        pure
        returns (address)
    {
        return address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB, sender, receiver)))));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behavior of `implementation`.
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
    
    function rescueFee() external onlyOwner {
        uint fee = address(this).balance - collectedFees - collectedProcessingFee - totalSupply[1];
        payable(msg.sender).transfer(fee);
    }
    
    function donate() external payable {
        totalSupply[1] += msg.value;
    }

// No oracle functions

    function claimToken(
        address tokenA, // foreignToken
        address tokenB, // nativeToken
        address sender,
        address receiver,
        uint128 amountA,    //amount of tokenA that has to be swapped
        uint128 currentRate,     // rate with 18 decimals: tokenA price / tokenB price
        uint256 foreignBalance,  // total tokens amount sent by user to pair on other chain
        uint256 foreignSpent,   // total tokens spent by SmartSwap pair
        uint256 nativeEncoded   // (nativeRate, nativeSpent) = _decode(nativeEncoded)
    ) 
        external 
        onlySystem 
        returns(bool)
    {
        uint256 pairID = getPairID[tokenB][tokenA]; // getPairID[nativeToken][foreignToken]
        require(pairID != 0, "Pair not exist");
        // check rate
        uint256 diffRate;
        uint256 oracleRate = IValidator(validator).getRate(tokenB, tokenA);
        if (uint256(currentRate) < oracleRate) {
            diffRate = 100 - (uint256(currentRate) * 100 / oracleRate);
        } else {
            diffRate = 100 - (oracleRate * 100 / uint256(currentRate));
        }
        require(diffRate <= rateDiffLimit, "Wrong rate");

        uint64 claimID;
        address hashAddress = _getHashAddress(tokenA, tokenB, sender, receiver);
        require(claimRequest[hashAddress].amount == 0, "there is pending claim");
        // new claim request
        _balanceOf[hashAddress] += uint256(amountA); // total swapped amount of foreign token
        claimID = uint64(++claimIdCounter);

        claimRequest[hashAddress] = Claim(uint64(pairID), sender, receiver, claimID, false, amountA, currentRate, foreignBalance);
        //emit ClaimRequest(hashAddress, claimID, amountA, isInvestment);

        //address hashAddress = _getHashAddress(tokenA, tokenB, sender, receiver);
        _claimBehalfApprove(hashAddress, foreignBalance, foreignSpent, nativeEncoded);
        return true;
    }

    /*// ============================= START for TEST only =============================================================
    function reset(uint pairID) external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        collectedFees = 1;
        address tokenA = getPairByID[pairID].tokenA;
        if (tokenA > NATIVE_COINS) {
            uint balance = IERC20(tokenA).balanceOf(address(this));
            TransferHelper.safeTransfer(tokenA, msg.sender, balance);
        }
        address nativeHash = _getHashAddress(tokenA, getPairByID[pairID].tokenB, address(0), address(0));
        address foreignHash = _getHashAddress(getPairByID[pairID].tokenB, tokenA, address(0), address(0));
        _balanceOf[nativeHash] = 0;
        _balanceOf[foreignHash] = 0;
        totalSupply[pairID] = 0;
        
    }
    function clearBalances(uint pairID, address[] calldata users) external onlyOwner {
        address tokenA = getPairByID[pairID].tokenA;
        address tokenB = getPairByID[pairID].tokenB;
        for (uint i = 0; i < users.length; i++) {
            _balanceOf[users[i]] = 0;
            delete claimRequest[users[i]];
            address hashAddress = _getHashAddress(tokenA, tokenB, users[i], users[i]);
            _balanceOf[hashAddress] = 0;
            delete claimRequest[hashAddress];
            hashAddress = _getHashAddress(tokenB, tokenA, users[i], users[i]);
            _balanceOf[hashAddress] = 0;
            delete claimRequest[hashAddress];
        }
    }
    */// =============================== END for TEST only =============================================================
}