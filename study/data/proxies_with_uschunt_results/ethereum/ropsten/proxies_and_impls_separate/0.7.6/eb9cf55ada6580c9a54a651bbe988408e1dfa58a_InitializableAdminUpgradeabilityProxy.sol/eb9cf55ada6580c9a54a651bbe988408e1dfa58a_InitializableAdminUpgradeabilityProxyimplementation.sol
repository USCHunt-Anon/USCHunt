pragma solidity 0.7.6;

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



interface IERC20Detailed is IERC20 {
  function name() external view returns(string memory);
  function symbol() external view returns(string memory);
  function decimals() external view returns(uint8);
}



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
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly { codehash := extcodehash(account) }
    return (codehash != accountHash && codehash != 0x0);
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
}



abstract contract Proxy {
/**
 * @dev Fallback function.
 * Implemented entirely in `_fallback`.
 */
fallback () payable external {
_fallback();
}

/**
 * @return The Address of the implementation.
 */
function _implementation() internal virtual view returns (address);

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
case 0 { revert(0, returndatasize()) }
default { return(0, returndatasize()) }
}
}

/**
 * @dev Function that is run as the first thing in the fallback function.
 * Can be redefined in derived contracts to add functionality.
 * Redefinitions must call super._willFallback().
 */
function _willFallback() internal virtual {
}

/**
 * @dev fallback implementation.
 * Extracted to enable manual triggering.
 */
function _fallback() internal {
_willFallback();
_delegate(_implementation());
}
}



abstract contract Context {
function _msgSender() internal view virtual returns (address payable) {
return msg.sender;
}

function _msgData() internal view virtual returns (bytes memory) {
this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
return msg.data;
}
}



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
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");

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
}




contract ERC20 is Context, IERC20 {
using SafeMath for uint256;
using Address for address;

mapping (address => uint256) private _balances;

mapping (address => mapping (address => uint256)) private _allowances;

uint256 private _totalSupply;

string internal _name;
string internal _symbol;
uint8 private _decimals;

/**
 * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
 * a default value of 18.
 *
 * To select a different value for {decimals}, use {_setupDecimals}.
 *
 * All three of these values are immutable: they can only be set once during
 * construction.
 */
constructor (string memory name, string memory symbol) public {
_name = name;
_symbol = symbol;
_decimals = 18;
}

/**
 * @dev Returns the name of the token.
 */
function name() public view returns (string memory) {
return _name;
}

/**
 * @dev Returns the symbol of the token, usually a shorter version of the
 * name.
 */
function symbol() public view returns (string memory) {
return _symbol;
}

/**
 * @dev Returns the number of decimals used to get its user representation.
 * For example, if `decimals` equals `2`, a balance of `505` tokens should
 * be displayed to a user as `5,05` (`505 / 10 ** 2`).
 *
 * Tokens usually opt for a value of 18, imitating the relationship between
 * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
 * called.
 *
 * NOTE: This information is only used for _display_ purposes: it in
 * no way affects any of the arithmetic of the contract, including
 * {IERC20-balanceOf} and {IERC20-transfer}.
 */
function decimals() public view returns (uint8) {
return _decimals;
}

/**
 * @dev See {IERC20-totalSupply}.
 */
function totalSupply() public view override returns (uint256) {
return _totalSupply;
}

/**
 * @dev See {IERC20-balanceOf}.
 */
function balanceOf(address account) public view override returns (uint256) {
return _balances[account];
}

/**
 * @dev See {IERC20-transfer}.
 *
 * Requirements:
 *
 * - `recipient` cannot be the zero address.
 * - the caller must have a balance of at least `amount`.
 */
function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
_transfer(_msgSender(), recipient, amount);
return true;
}

/**
 * @dev See {IERC20-allowance}.
 */
function allowance(address owner, address spender) public view virtual override returns (uint256) {
return _allowances[owner][spender];
}

/**
 * @dev See {IERC20-approve}.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 */
function approve(address spender, uint256 amount) public virtual override returns (bool) {
_approve(_msgSender(), spender, amount);
return true;
}

/**
 * @dev See {IERC20-transferFrom}.
 *
 * Emits an {Approval} event indicating the updated allowance. This is not
 * required by the EIP. See the note at the beginning of {ERC20};
 *
 * Requirements:
 * - `sender` and `recipient` cannot be the zero address.
 * - `sender` must have a balance of at least `amount`.
 * - the caller must have allowance for ``sender``'s tokens of at least
 * `amount`.
 */
function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
_transfer(sender, recipient, amount);
_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
return true;
}

/**
 * @dev Atomically increases the allowance granted to `spender` by the caller.
 *
 * This is an alternative to {approve} that can be used as a mitigation for
 * problems described in {IERC20-approve}.
 *
 * Emits an {Approval} event indicating the updated allowance.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 */
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
return true;
}

/**
 * @dev Atomically decreases the allowance granted to `spender` by the caller.
 *
 * This is an alternative to {approve} that can be used as a mitigation for
 * problems described in {IERC20-approve}.
 *
 * Emits an {Approval} event indicating the updated allowance.
 *
 * Requirements:
 *
 * - `spender` cannot be the zero address.
 * - `spender` must have allowance for the caller of at least
 * `subtractedValue`.
 */
function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
return true;
}

/**
 * @dev Moves tokens `amount` from `sender` to `recipient`.
 *
 * This is internal function is equivalent to {transfer}, and can be used to
 * e.g. implement automatic token fees, slashing mechanisms, etc.
 *
 * Emits a {Transfer} event.
 *
 * Requirements:
 *
 * - `sender` cannot be the zero address.
 * - `recipient` cannot be the zero address.
 * - `sender` must have a balance of at least `amount`.
 */
function _transfer(address sender, address recipient, uint256 amount) internal virtual {
require(sender != address(0), "ERC20: transfer from the zero address");
require(recipient != address(0), "ERC20: transfer to the zero address");

_beforeTokenTransfer(sender, recipient, amount);

_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
_balances[recipient] = _balances[recipient].add(amount);
emit Transfer(sender, recipient, amount);
}

/** @dev Creates `amount` tokens and assigns them to `account`, increasing
 * the total supply.
 *
 * Emits a {Transfer} event with `from` set to the zero address.
 *
 * Requirements
 *
 * - `to` cannot be the zero address.
 */
function _mint(address account, uint256 amount) internal virtual {
require(account != address(0), "ERC20: mint to the zero address");

_beforeTokenTransfer(address(0), account, amount);

_totalSupply = _totalSupply.add(amount);
_balances[account] = _balances[account].add(amount);
emit Transfer(address(0), account, amount);
}

/**
 * @dev Destroys `amount` tokens from `account`, reducing the
 * total supply.
 *
 * Emits a {Transfer} event with `to` set to the zero address.
 *
 * Requirements
 *
 * - `account` cannot be the zero address.
 * - `account` must have at least `amount` tokens.
 */
function _burn(address account, uint256 amount) internal virtual {
require(account != address(0), "ERC20: burn from the zero address");

_beforeTokenTransfer(account, address(0), amount);

_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
_totalSupply = _totalSupply.sub(amount);
emit Transfer(account, address(0), amount);
}

/**
 * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
 *
 * This is internal function is equivalent to `approve`, and can be used to
 * e.g. set automatic allowances for certain subsystems, etc.
 *
 * Emits an {Approval} event.
 *
 * Requirements:
 *
 * - `owner` cannot be the zero address.
 * - `spender` cannot be the zero address.
 */
function _approve(address owner, address spender, uint256 amount) internal virtual {
require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");

_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}

/**
 * @dev Sets {decimals} to a value other than the default one of 18.
 *
 * WARNING: This function should only be called from the constructor. Most
 * applications that interact with token contracts will not expect
 * {decimals} to ever change, and may work incorrectly if it does.
 */
function _setupDecimals(uint8 decimals_) internal {
_decimals = decimals_;
}

/**
 * @dev Hook that is called before any transfer of tokens. This includes
 * minting and burning.
 *
 * Calling conditions:
 *
 * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
 * will be to transferred to `to`.
 * - when `from` is zero, `amount` tokens will be minted for `to`.
 * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
 * - `from` and `to` are never both zero.
 *
 * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
 */
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}







contract BaseUpgradeabilityProxy is Proxy {
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
function _implementation() internal override view returns (address impl) {
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





contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
/**
 * @dev Contract constructor.
 * @param _logic Address of the initial implementation.
 * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
 * It should include the signature and the parameters of the function to be called, as described in
 * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
 * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
 */
constructor(address _logic, bytes memory _data) public payable {
assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
_setImplementation(_logic);
if(_data.length > 0) {
(bool success,) = _logic.delegatecall(_data);
require(success);
}
}
}







/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
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
function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
_upgradeTo(newImplementation);
(bool success,) = newImplementation.delegatecall(data);
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
function _willFallback() internal override virtual {
require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
super._willFallback();
}
}




/**
 * @title InitializableUpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with an initializer for initializing
 * implementation and init data.
 */
contract InitializableUpgradeabilityProxy is BaseUpgradeabilityProxy {
/**
* @dev Contract initializer.
* @param _logic Address of the initial implementation.
* @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
* It should include the signature and the parameters of the function to be called, as described in
* https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
* This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
*/
function initialize(address _logic, bytes memory _data) public payable {
require(_implementation() == address(0));
assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
_setImplementation(_logic);
if (_data.length > 0) {
(bool success, ) = _logic.delegatecall(_data);
require(success);
}
}
}





/**
 * @title InitializableAdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with an initializer for
 * initializing the implementation, admin, and init data.
 */
contract InitializableAdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, InitializableUpgradeabilityProxy {
/**
* Contract initializer.
* @param _logic address of the initial implementation.
* @param _admin Address of the proxy administrator.
* @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
* It should include the signature and the parameters of the function to be called, as described in
* https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
* This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
*/
function initialize(address _logic, address _admin, bytes memory _data) public payable {
require(_implementation() == address(0));
InitializableUpgradeabilityProxy.initialize(_logic, _data);
assert(ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
_setAdmin(_admin);
}

/**
* @dev Only fall back when the sender is not the admin.
*/
function _willFallback() internal override(BaseAdminUpgradeabilityProxy, Proxy) {
BaseAdminUpgradeabilityProxy._willFallback();
}

}



abstract contract VersionedInitializable {
/**
* @dev Indicates that the contract has been initialized.
*/
uint256 internal lastInitializedRevision = 0;

/**
* @dev Modifier to use in the initializer function of a contract.
*/
modifier initializer() {
uint256 revision = getRevision();
require(revision > lastInitializedRevision, "Contract instance has already been initialized");

lastInitializedRevision = revision;

_;

}

/// @dev returns the revision number of the contract.
/// Needs to be defined in the inherited class as a constant.
function getRevision() internal pure virtual returns(uint256);


// Reserved storage space to allow for layout changes in the future.
uint256[50] private ______gap;
}






contract IToken is ERC20, VersionedInitializable {


string internal constant NAME = "IToken";
string internal constant SYMBOL = "IS";
uint8 internal constant DECIMALS = 18;


uint256 internal constant MINT_AMOUNT = 5000000 ether;

uint256 public constant REVISION = 1;

/// @dev owner => next valid nonce to submit with permit()
//    mapping (address => uint256) public _nonces;




bytes32 public DOMAIN_SEPARATOR;
bytes public constant EIP712_REVISION = bytes("1");
bytes32 internal constant EIP712_DOMAIN = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");


constructor() ERC20(NAME, SYMBOL) public {}

/**
* @dev initializes the contract upon assignment to the InitializableAdminUpgradeabilityProxy
*/
function initialize(

) external initializer {


//        DOMAIN_SEPARATOR = keccak256(abi.encode(
//                EIP712_DOMAIN,
//                keccak256(bytes(NAME)),
//                keccak256(EIP712_REVISION),
//                chainId,
//                address(this)
//            ));
_name = NAME;
_symbol = SYMBOL;
_setupDecimals(DECIMALS);
_mint(_msgSender(), MINT_AMOUNT);
}


/**
* @dev returns the revision of the implementation contract
*/
function getRevision() internal pure override returns (uint256) {
return REVISION;
}


//
//    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
//        if (from == to) {
//            return;
//        }
//
//        if (from != address(0)) {
//            uint256 fromBalance = balanceOf(from);
//            _writeSnapshot(from, uint128(fromBalance), uint128(fromBalance.sub(amount)));
//        }
//        if (to != address(0)) {
//            uint256 toBalance = balanceOf(to);
//            _writeSnapshot(to, uint128(toBalance), uint128(toBalance.add(amount)));
//        }
//
//        // caching the aave governance address to avoid multiple state loads
//        ITransferHook aaveGovernance = _aaveGovernance;
//        if (aaveGovernance != ITransferHook(0)) {
//            aaveGovernance.onTransfer(from, to, amount);
//        }
//    }
}