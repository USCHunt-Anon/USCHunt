

// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}














// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

//import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}














// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    // function decimals() external view override returns (uint8);
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














// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

//import "../IERC20.sol";
//import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}














// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}














// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}












// ////-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "./VeTokenProxy.sol";
//import "./VeTokenStorage.sol";

// # Interface for checking whether address belongs to a whitelisted
// # type of a smart wallet.
interface SmartWalletChecker {
    function isAllowed(address addr) external returns (bool);
}














// ////-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// //import "./Sig.sol";

contract AccessControl is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // event ContractUpgrade(address newContract);
    event SetProxy(address proxy);
    event AdminTransferred(address oldAdmin, address newAdmin);
    event FlipStakableState(bool stakeIsActive);
    event FlipClaimableState(bool claimIsActive);
    event TransferAdmin(address oldAdmin, address newAdmin);

    address private _admin;
    address public proxy;
    bool public stakeIsActive = true;
    bool public claimIsActive = true;

    address public constant ZERO_ADDRESS = address(0);

    constructor() {
        _setAdmin(_msgSender());
    }

    // function verified(bytes32 hash, bytes memory signature) public view returns (bool){
    //     return admin() == Sig.recover(hash, signature);
    // }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view virtual returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Invalid Admin: caller is not the admin");
        _;
    }

    function _setAdmin(address newAdmin) private {
        address oldAdmin = _admin;
        _admin = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }

    function setProxy(address _proxy) external onlyOwner {
        require(_proxy != address(0), "Invalid Address");
        proxy = _proxy;

        emit SetProxy(_proxy);
    }

    modifier onlyProxy() {
        require(proxy == _msgSender(), "Not Permit: caller is not the proxy"); 
        _;
    }

    // modifier sigVerified(bytes memory signature) {
    //     require(verified(Sig.ethSignedHash(msg.sender), signature), "Not verified");
    //     _;
    // }

    modifier activeStake() {
        require(stakeIsActive, "Unstakable");
        _;
    } 

    modifier activeClaim() {
        require(claimIsActive, "Unclaimable");
        _;
    } 
    
    modifier notZeroAddr(address addr_) {
        require(addr_ != ZERO_ADDRESS, "Zero address");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function transferAdmin(address newAdmin) external virtual onlyOwner {
        require(newAdmin != address(0), "Invalid Admin: new admin is the zero address");
        address oldAdmin = admin();
        _setAdmin(newAdmin);

        emit TransferAdmin(oldAdmin, newAdmin);
    }

    /*
    * Pause sale if active, make active if paused
    */
    function flipStakableState() external onlyOwner {
        stakeIsActive = !stakeIsActive;

        emit FlipStakableState(stakeIsActive);
    }

    function flipClaimableState() external onlyOwner {
        claimIsActive = !claimIsActive;

        emit FlipClaimableState(claimIsActive);
    }
}














// ////-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyStorage {
    /**
    * @notice Active brains of VeTokenProxy
    */
    address public veTokenImplementation;

    /**
    * @notice Pending brains of VeTokenProxy
    */
    address public pendingVeTokenImplementation;
}














// ////-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./VeTokenStorage.sol";
//import "./AccessControl.sol";

/**
 * @title VeTokenCore
 * @dev Storage for the VeToken is at this address, while execution is delegated to the `veTokenImplementation`.
 */
contract VeTokenProxy is AccessControl, ProxyStorage {
    function setPendingImplementation(
        address newPendingImplementation_
    ) public onlyOwner 
    {
        address oldPendingImplementation = pendingVeTokenImplementation;

        pendingVeTokenImplementation = newPendingImplementation_;

        emit NewPendingImplementation(oldPendingImplementation, pendingVeTokenImplementation);
    }

    /**
    * @notice Accepts new implementation of comptroller. msg.sender must be pendingImplementation
    * @dev Admin function for new implementation to accept it's role as implementation
    */
    function acceptImplementation() public {
        // Check caller is pendingImplementation and pendingImplementation ≠ address(0)
        require (msg.sender == pendingVeTokenImplementation && pendingVeTokenImplementation != address(0),
                "Invalid veTokenImplementation");

        // Save current values for inclusion in log
        address oldImplementation = veTokenImplementation;
        address oldPendingImplementation = pendingVeTokenImplementation;

        veTokenImplementation = oldPendingImplementation;

        pendingVeTokenImplementation = address(0);

        emit NewImplementation(oldImplementation, veTokenImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingVeTokenImplementation);
    }
    
    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback () external payable {
        // delegate all other functions to current implementation
        (bool success, ) = veTokenImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }

    receive () external payable {}

    function claim (address receiver) external onlyOwner nonReentrant {
        payable(receiver).transfer(address(this).balance);

        emit Claim(receiver);
    }

    /**
      * @notice Emitted when pendingComptrollerImplementation is changed
      */
    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    /**
      * @notice Emitted when pendingComptrollerImplementation is accepted, which means comptroller implementation is updated
      */
    event NewImplementation(address oldImplementation, address newImplementation);
   
    /**
      * @notice Emitted when claim eth in contract
      */
    event Claim(address receiver);
}














contract VeTokenStorage is  ProxyStorage {
    address public token;  // token
    uint256 public supply; // veToken

    // veToken related
    string public name;
    string public symbol;
    string public version;
    uint256 constant decimals = 18;

    // score related
    uint256 public scorePerBlk;
    uint256 public totalStaked;

    mapping (address => UserInfo) internal userInfo;
    PoolInfo public poolInfo;
    uint256 public startBlk;  // start Blk
    uint256 public clearBlk;  // set annually
    
    // User variables
    struct UserInfo {
        uint256 amount;        // How many tokens the user has provided.
        uint256 score;         // score exclude pending amount
        uint256 scoreDebt;     // score debt
        uint256 lastUpdateBlk; // last user's tx Blk
    }

    // Pool variables
    struct PoolInfo {      
        uint256 lastUpdateBlk;     // Last block number that score distribution occurs.
        uint256 accScorePerToken;   // Accumulated socres per token, times 1e12. 
    }

    address public smartWalletChecker;
}














contract VeToken is AccessControl, VeTokenStorage {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    function initialize(
        address tokenAddr_,
        string memory name_,
        string memory symbol_,
        string memory version_,
        uint256 scorePerBlk_,
        uint256 startBlk_
    ) external onlyOwner 
    {
        token = tokenAddr_;
        
        name = name_;
        symbol = symbol_;
        version = version_;

        scorePerBlk = scorePerBlk_;
        startBlk = startBlk_;

        poolInfo.lastUpdateBlk = startBlk > block.number ? startBlk : block.number;
    
        emit Initialize(tokenAddr_, name_, symbol_, version_, scorePerBlk_, startBlk_);
    }

    /* ========== VIEWS & INTERNALS ========== */

    function getPoolInfo() external view returns (PoolInfo memory) 
    {
        return poolInfo;
    }

    function getUserInfo(
        address user_
    ) external view returns (UserInfo memory) 
    {
        return userInfo[user_];
    }

    function getTotalScore() public view returns(uint256) 
    {
        uint256 startBlk = (clearBlk > startBlk) && (block.number > clearBlk) ? clearBlk : startBlk;
        return block.number.sub(startBlk).mul(scorePerBlk);
    }

    function getUserRatio(
        address user_
    ) public view returns (uint256) 
    {
        return currentScore(user_).mul(1e12).div(getTotalScore());
    }

    // Score multiplier over given block range which include start block
    function getMultiplier(
        uint256 from_, 
        uint256 to_
    ) internal view returns (uint256) 
    {
        require(from_ <= to_, "from_ must less than to_");

        from_ = from_ >= startBlk ? from_ : startBlk;

        return to_.sub(from_);
    }
    
    // Boolean value if user's score should be cleared
    function clearUserScore(
        address user_
    ) internal view returns(bool isClearScore)
    {
        if ((block.number > clearBlk) && 
            (userInfo[user_].lastUpdateBlk < clearBlk)) {
                isClearScore = true;
            }
    } 

    function clearPoolScore() internal returns(bool isClearScore)
    {
        if ((block.number > clearBlk) && (poolInfo.lastUpdateBlk < clearBlk)) {
                isClearScore = true;
                startBlk = clearBlk;
            }     
    }

    function accScorePerToken() internal returns (uint256 updated)
    {
        bool isClearPoolScore = clearPoolScore();
        uint256 scoreReward =  getMultiplier(poolInfo.lastUpdateBlk, block.number)
                                            .mul(scorePerBlk);

        if (isClearPoolScore) {
            updated = scoreReward.mul(1e12).div(totalStaked)
                                 .mul(block.number.sub(clearBlk))
                                 .div(block.number.sub(poolInfo.lastUpdateBlk));
        } else {
            updated = poolInfo.accScorePerToken.add(scoreReward.mul(1e12)
                                               .div(totalStaked));
        }
    }

    function accScorePerTokenStatic() internal view returns (uint256 updated)
    {
        uint256 scoreReward =  getMultiplier(poolInfo.lastUpdateBlk, block.number)
                                            .mul(scorePerBlk);

        updated = poolInfo.accScorePerToken.add(scoreReward.mul(1e12)
                                            .div(totalStaked));
        
    }

    // Pending score to be added for user
    function pendingScore(
        address user_
    ) internal view returns (uint256 pending) 
    {
        if (userInfo[user_].amount == 0) {
            return 0;
        }
        if (clearUserScore(user_)) {
            pending = userInfo[user_].amount.mul(accScorePerTokenStatic()).div(1e12);
        } else {
            pending = userInfo[user_].amount.mul(accScorePerTokenStatic()).div(1e12)
                                            .sub(userInfo[user_].scoreDebt);  
        }
    }

    function currentScore(
        address user_
    ) internal view returns(uint256)
    {
        uint256 pending = pendingScore(user_);

        if (clearUserScore(user_)) {
            return pending;
        } else {
            return pending.add(userInfo[user_].score);
        }
    }

    // Boolean value of claimable or not
    function isClaimable() external view returns(bool) 
    {
        return claimIsActive;
    }

    // Boolean value of stakable or not
    function isStakable() external view returns(bool) 
    {
        return stakeIsActive;
    }

    /**
        * @notice Get the current voting power for `msg.sender` 
        * @dev Adheres to the ERC20 `balanceOf` interface for Aragon compatibility
        * @param addr_ User wallet address
        * @return User voting power
    */
    function balanceOf(
        address addr_
    ) external view notZeroAddr(addr_) returns(uint256)
    {
        return userInfo[addr_].amount;
    }

    /**
        * @notice Calculate total voting power 
        * @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
        * @return Total voting power
    */
    function totalSupply() external view returns(uint256) 
    {
        return supply;
    }

    /**
        * @notice Check if the call is from a whitelisted smart contract, revert if not
        * @param addr_ Address to be checked
    */
    function assertNotContract(
        address addr_
    ) internal 
    {
        if (addr_ != tx.origin) {
            address checker = smartWalletChecker;
            if (checker != ZERO_ADDRESS){
                if (SmartWalletChecker(checker).isAllowed(addr_)){
                    return;
                }
            }
            revert("Smart contract depositors not allowed");
        }
    }

    /* ========== WRITES ========== */

    function updateStakingPool() internal
    {
        if (block.number <= poolInfo.lastUpdateBlk || block.number <= startBlk) { 
            poolInfo.lastUpdateBlk = block.number; 
            return;
        }

        if (totalStaked == 0) {
            poolInfo.lastUpdateBlk = block.number; 
            return;
        }  

        poolInfo.accScorePerToken = accScorePerToken();
        poolInfo.lastUpdateBlk = block.number; 

        emit UpdateStakingPool(block.number);
    }

    /**
        * @notice Deposit and lock tokens for a user
        * @dev Anyone (even a smart contract) can deposit for someone else
        * @param value_ Amount to add to user's lock
        * @param user_ User's wallet address
    */
    function depositFor(
        address user_,
        uint256 value_
    ) external nonReentrant activeStake notZeroAddr(user_) 
    {
        require (value_ > 0, "Need non-zero value");

        if (userInfo[user_].amount == 0) {
            assertNotContract(msg.sender);
        }
    
        updateStakingPool();
        userInfo[user_].score = currentScore(user_);
        userInfo[user_].amount = userInfo[user_].amount.add(value_);
        userInfo[user_].scoreDebt = userInfo[user_].amount.mul(poolInfo.accScorePerToken).div(1e12);
        userInfo[user_].lastUpdateBlk = block.number;

        IERC20(token).safeTransferFrom(msg.sender, address(this), value_);
        totalStaked = totalStaked.add(value_);
        supply = supply.add(value_);

        emit DepositFor(user_, value_);
    }

    /**
        * @notice Withdraw tokens for `msg.sender`ime`
        * @param value_ Token amount to be claimed
        * @dev Only possible if it's claimable
    */
    function withdraw(
        uint256 value_
    ) public nonReentrant activeClaim
    {
        require (value_ > 0, "Need non-zero value");
        require (userInfo[msg.sender].amount >= value_, "Exceed staked value");
        
        updateStakingPool();
        userInfo[msg.sender].score = currentScore(msg.sender);
        userInfo[msg.sender].amount = userInfo[msg.sender].amount.sub(value_);
        userInfo[msg.sender].scoreDebt = userInfo[msg.sender].amount.mul(poolInfo.accScorePerToken).div(1e12);
        userInfo[msg.sender].lastUpdateBlk = block.number;

        IERC20(token).safeTransfer(msg.sender, value_);
        totalStaked = totalStaked.sub(value_);
        supply = supply.sub(value_);

        emit Withdraw(value_);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function become(
        VeTokenProxy veTokenProxy
    ) public 
    {
        require(msg.sender == veTokenProxy.owner(), "only MultiSigner can change brains");
        veTokenProxy.acceptImplementation();

        emit Become(address(veTokenProxy), address(this));
    }

    /**
        * @notice Apply setting external contract to check approved smart contract wallets
    */
    function applySmartWalletChecker(
        address smartWalletChecker_
    ) external onlyOwner notZeroAddr(smartWalletChecker_) 
    {
        smartWalletChecker = smartWalletChecker_;

        emit ApplySmartWalletChecker(smartWalletChecker_);
    }

    // Added to support recovering LP Rewards and other mistaken tokens from other systems to be distributed to holders
    function recoverERC20(
        address tokenAddress, 
        uint256 tokenAmount
    ) external onlyOwner notZeroAddr(tokenAddress) 
    {
        // Only the owner address can ever receive the recovery withdrawal
        require(tokenAddress != token, "Not in migration");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);

        emit Recovered(tokenAddress, tokenAmount);
    }

    function setScorePerBlk(
        uint256 scorePerBlk_
    ) external onlyOwner 
    {
        scorePerBlk = scorePerBlk_;

        emit SetScorePerBlk(scorePerBlk_);
    }

    function setClearBlk(
        uint256 clearBlk_
    ) external onlyOwner 
    {
        clearBlk = clearBlk_;

        emit SetClearBlk(clearBlk_);
    }

    receive () external payable {}

    function claim (address receiver) external onlyOwner nonReentrant {
        payable(receiver).transfer(address(this).balance);
    
        emit Claim(receiver);
    }
    
    /* ========== EVENTS ========== */
    event Initialize(address tokenAddr, string name, string symbol, string version, uint scorePerBlk, uint startBlk);
    event DepositFor(address depositor, uint256 value);
    event Withdraw(uint256 value);
    event ApplySmartWalletChecker(address smartWalletChecker);
    event Recovered(address tokenAddress, uint256 tokenAmount);
    event UpdateStakingPool(uint256 blockNumber);
    event SetScorePerBlk(uint256 scorePerBlk);
    event SetClearBlk(uint256 clearBlk);
    event Become(address proxy, address impl);
    event Claim(address receiver);
}
