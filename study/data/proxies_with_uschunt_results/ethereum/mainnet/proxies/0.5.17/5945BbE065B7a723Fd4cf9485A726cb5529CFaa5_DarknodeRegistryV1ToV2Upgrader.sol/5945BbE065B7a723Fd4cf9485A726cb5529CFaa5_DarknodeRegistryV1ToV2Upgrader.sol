



pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
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
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}






pragma solidity ^0.5.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * NOTE: This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: signature length is invalid");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: signature.s is in the wrong range");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: signature.v is in the wrong range");
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}






pragma solidity ^0.5.0;

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}






pragma solidity ^0.5.0;

//import "./IERC20.sol";
//import "../../math/SafeMath.sol";
//import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}






pragma solidity ^0.5.5;

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
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}






pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user //imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library OpenZeppelinUpgradesAddress {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}





pragma solidity 0.5.17;

/**
 * @notice LinkedList is a library for a circular double linked list.
 */
library LinkedList {
    /*
     * @notice A permanent NULL node (0x0) in the circular double linked list.
     * NULL.next is the head, and NULL.previous is the tail.
     */
    address public constant NULL = address(0);

    /**
     * @notice A node points to the node before it, and the node after it. If
     * node.previous = NULL, then the node is the head of the list. If
     * node.next = NULL, then the node is the tail of the list.
     */
    struct Node {
        bool inList;
        address previous;
        address next;
    }

    /**
     * @notice LinkedList uses a mapping from address to nodes. Each address
     * uniquely identifies a node, and in this way they are used like pointers.
     */
    struct List {
        mapping(address => Node) list;
        uint256 length;
    }

    /**
     * @notice Insert a new node before an existing node.
     *
     * @param self The list being used.
     * @param target The existing node in the list.
     * @param newNode The next node to insert before the target.
     */
    function insertBefore(
        List storage self,
        address target,
        address newNode
    ) internal {
        require(newNode != address(0), "LinkedList: invalid address");
        require(!isInList(self, newNode), "LinkedList: already in list");
        require(
            isInList(self, target) || target == NULL,
            "LinkedList: not in list"
        );

        // It is expected that this value is sometimes NULL.
        address prev = self.list[target].previous;

        self.list[newNode].next = target;
        self.list[newNode].previous = prev;
        self.list[target].previous = newNode;
        self.list[prev].next = newNode;

        self.list[newNode].inList = true;

        self.length += 1;
    }

    /**
     * @notice Insert a new node after an existing node.
     *
     * @param self The list being used.
     * @param target The existing node in the list.
     * @param newNode The next node to insert after the target.
     */
    function insertAfter(
        List storage self,
        address target,
        address newNode
    ) internal {
        require(newNode != address(0), "LinkedList: invalid address");
        require(!isInList(self, newNode), "LinkedList: already in list");
        require(
            isInList(self, target) || target == NULL,
            "LinkedList: not in list"
        );

        // It is expected that this value is sometimes NULL.
        address n = self.list[target].next;

        self.list[newNode].previous = target;
        self.list[newNode].next = n;
        self.list[target].next = newNode;
        self.list[n].previous = newNode;

        self.list[newNode].inList = true;

        self.length += 1;
    }

    /**
     * @notice Remove a node from the list, and fix the previous and next
     * pointers that are pointing to the removed node. Removing anode that is not
     * in the list will do nothing.
     *
     * @param self The list being using.
     * @param node The node in the list to be removed.
     */
    function remove(List storage self, address node) internal {
        require(isInList(self, node), "LinkedList: not in list");

        address p = self.list[node].previous;
        address n = self.list[node].next;

        self.list[p].next = n;
        self.list[n].previous = p;

        // Deleting the node should set this value to false, but we set it here for
        // explicitness.
        self.list[node].inList = false;
        delete self.list[node];

        self.length -= 1;
    }

    /**
     * @notice Insert a node at the beginning of the list.
     *
     * @param self The list being used.
     * @param node The node to insert at the beginning of the list.
     */
    function prepend(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertBefore(self, begin(self), node);
    }

    /**
     * @notice Insert a node at the end of the list.
     *
     * @param self The list being used.
     * @param node The node to insert at the end of the list.
     */
    function append(List storage self, address node) internal {
        // isInList(node) is checked in insertBefore

        insertAfter(self, end(self), node);
    }

    function swap(
        List storage self,
        address left,
        address right
    ) internal {
        // isInList(left) and isInList(right) are checked in remove

        address previousRight = self.list[right].previous;
        remove(self, right);
        insertAfter(self, left, right);
        remove(self, left);
        insertAfter(self, previousRight, left);
    }

    function isInList(List storage self, address node)
        internal
        view
        returns (bool)
    {
        return self.list[node].inList;
    }

    /**
     * @notice Get the node at the beginning of a double linked list.
     *
     * @param self The list being used.
     *
     * @return A address identifying the node at the beginning of the double
     * linked list.
     */
    function begin(List storage self) internal view returns (address) {
        return self.list[NULL].next;
    }

    /**
     * @notice Get the node at the end of a double linked list.
     *
     * @param self The list being used.
     *
     * @return A address identifying the node at the end of the double linked
     * list.
     */
    function end(List storage self) internal view returns (address) {
        return self.list[NULL].previous;
    }

    function next(List storage self, address node)
        internal
        view
        returns (address)
    {
        require(isInList(self, node), "LinkedList: not in list");
        return self.list[node].next;
    }

    function previous(List storage self, address node)
        internal
        view
        returns (address)
    {
        require(isInList(self, node), "LinkedList: not in list");
        return self.list[node].previous;
    }

    function elements(
        List storage self,
        address _start,
        uint256 _count
    ) internal view returns (address[] memory) {
        require(_count > 0, "LinkedList: invalid count");
        require(
            isInList(self, _start) || _start == address(0),
            "LinkedList: not in list"
        );
        address[] memory elems = new address[](_count);

        // Begin with the first node in the list
        uint256 n = 0;
        address nextItem = _start;
        if (nextItem == address(0)) {
            nextItem = begin(self);
        }

        while (n < _count) {
            if (nextItem == address(0)) {
                break;
            }
            elems[n] = nextItem;
            nextItem = next(self, nextItem);
            n += 1;
        }
        return elems;
    }
}






pragma solidity ^0.5.0;

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






pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/ownership/Ownable.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user //imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Ownable implementation from an openzeppelin version.
 */
contract OpenZeppelinUpgradesOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view returns (address);

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
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal {
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






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/cryptography/ECDSA.sol";
//import "@openzeppelin/upgrades/contracts/upgradeability/InitializableAdminUpgradeabilityProxy.sol";
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../RenToken/RenToken.sol";
//import "./DarknodeRegistryStore.sol";
//import "../Governance/Claimable.sol";
//import "../libraries/CanReclaimTokens.sol";
//import "./DarknodeRegistryV1.sol";

contract DarknodeRegistryStateV2 {
}






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
//import "@openzeppelin/upgrades/contracts/upgradeability/InitializableAdminUpgradeabilityProxy.sol";
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../RenToken/RenToken.sol";
//import "./DarknodeRegistryStore.sol";
//import "../Governance/Claimable.sol";
//import "../libraries/CanReclaimTokens.sol";

interface IDarknodePaymentStore {
}






interface IDarknodeSlasher {
}






pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import './Proxy.sol';
//import '../utils/Address.sol';

/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
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
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
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
    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}






pragma solidity ^0.5.0;

//import './BaseUpgradeabilityProxy.sol';

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
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}






pragma solidity ^0.5.0;

//import './BaseUpgradeabilityProxy.sol';

/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
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




interface IDarknodePayment {
    function changeCycle() external returns (uint256);

    function store() external view returns (IDarknodePaymentStore);
}



pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../GSN/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";
//import "./IERC20.sol";

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is Initializable, IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import './UpgradeabilityProxy.sol';

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
   * @return The admin slot.
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
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}






pragma solidity ^0.5.0;

//import "../ownership/Ownable.sol";
//import "./AdminUpgradeabilityProxy.sol";

/**
 * @title ProxyAdmin
 * @dev This contract is the admin of a proxy, and is in charge
 * of upgrading it as well as transferring it to another admin.
 */
contract ProxyAdmin is OpenZeppelinUpgradesOwnable {
  
  /**
   * @dev Returns the current implementation of a proxy.
   * This is needed because only the proxy admin can query it.
   * @return The address of the current implementation of the proxy.
   */
  function getProxyImplementation(AdminUpgradeabilityProxy proxy) public view returns (address) {
    // We need to manually run the static call since the getter cannot be flagged as view
    // bytes4(keccak256("implementation()")) == 0x5c60da1b
    (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
    require(success);
    return abi.decode(returndata, (address));
  }

  /**
   * @dev Returns the admin of a proxy. Only the admin can query it.
   * @return The address of the current admin of the proxy.
   */
  function getProxyAdmin(AdminUpgradeabilityProxy proxy) public view returns (address) {
    // We need to manually run the static call since the getter cannot be flagged as view
    // bytes4(keccak256("admin()")) == 0xf851a440
    (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
    require(success);
    return abi.decode(returndata, (address));
  }

  /**
   * @dev Changes the admin of a proxy.
   * @param proxy Proxy to change admin.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeProxyAdmin(AdminUpgradeabilityProxy proxy, address newAdmin) public onlyOwner {
    proxy.changeAdmin(newAdmin);
  }

  /**
   * @dev Upgrades a proxy to the newest implementation of a contract.
   * @param proxy Proxy to be upgraded.
   * @param implementation the address of the Implementation.
   */
  function upgrade(AdminUpgradeabilityProxy proxy, address implementation) public onlyOwner {
    proxy.upgradeTo(implementation);
  }

  /**
   * @dev Upgrades a proxy to the newest implementation of a contract and forwards a function call to it.
   * This is useful to initialize the proxied contract.
   * @param proxy Proxy to be upgraded.
   * @param implementation Address of the Implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeAndCall(AdminUpgradeabilityProxy proxy, address implementation, bytes memory data) payable public onlyOwner {
    proxy.upgradeToAndCall.value(msg.value)(implementation, data);
  }
}




contract DarknodeRegistryStateV1 {
    using SafeMath for uint256;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice Darknode pods are shuffled after a fixed number of blocks.
    /// An Epoch stores an epoch hash used as an (insecure) RNG seed, and the
    /// blocknumber which restricts when the next epoch can be called.
    struct Epoch {
        uint256 epochhash;
        uint256 blocktime;
    }

    uint256 public numDarknodes;
    uint256 public numDarknodesNextEpoch;
    uint256 public numDarknodesPreviousEpoch;

    /// Variables used to parameterize behavior.
    uint256 public minimumBond;
    uint256 public minimumPodSize;
    uint256 public minimumEpochInterval;
    uint256 public deregistrationInterval;

    /// When one of the above variables is modified, it is only updated when the
    /// next epoch is called. These variables store the values for the next
    /// epoch.
    uint256 public nextMinimumBond;
    uint256 public nextMinimumPodSize;
    uint256 public nextMinimumEpochInterval;

    /// The current and previous epoch.
    Epoch public currentEpoch;
    Epoch public previousEpoch;

    /// REN ERC20 contract used to transfer bonds.
    RenToken public ren;

    /// Darknode Registry Store is the storage contract for darknodes.
    DarknodeRegistryStore public store;

    /// The Darknode Payment contract for changing cycle.
    IDarknodePayment public darknodePayment;

    /// Darknode Slasher allows darknodes to vote on bond slashing.
    IDarknodeSlasher public slasher;
    IDarknodeSlasher public nextSlasher;
}






pragma solidity ^0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

//import "./DarknodeRegistry.sol";

//import "../Governance/RenProxyAdmin.sol";

contract DarknodeRegistryV1ToV2Upgrader is Ownable {
    RenProxyAdmin public renProxyAdmin;
    DarknodeRegistryLogicV1 public darknodeRegistryProxy;
    DarknodeRegistryLogicV2 public darknodeRegistryLogicV2;
    address public previousAdminOwner;
    address public previousDarknodeRegistryOwner;

    constructor(
        RenProxyAdmin _renProxyAdmin,
        DarknodeRegistryLogicV1 _darknodeRegistryProxy,
        DarknodeRegistryLogicV2 _darknodeRegistryLogicV2
    ) public {
        Ownable.initialize(msg.sender);
        renProxyAdmin = _renProxyAdmin;
        darknodeRegistryProxy = _darknodeRegistryProxy;
        darknodeRegistryLogicV2 = _darknodeRegistryLogicV2;
        previousAdminOwner = renProxyAdmin.owner();
        previousDarknodeRegistryOwner = darknodeRegistryProxy.owner();
    }

    function upgrade() public onlyOwner {
        // Pre-checks
        uint256 numDarknodes = darknodeRegistryProxy.numDarknodes();
        uint256 numDarknodesNextEpoch = darknodeRegistryProxy
            .numDarknodesNextEpoch();
        uint256 numDarknodesPreviousEpoch = darknodeRegistryProxy
            .numDarknodesPreviousEpoch();
        uint256 minimumBond = darknodeRegistryProxy.minimumBond();
        uint256 minimumPodSize = darknodeRegistryProxy.minimumPodSize();
        uint256 minimumEpochInterval = darknodeRegistryProxy
            .minimumEpochInterval();
        uint256 deregistrationInterval = darknodeRegistryProxy
            .deregistrationInterval();
        RenToken ren = darknodeRegistryProxy.ren();
        DarknodeRegistryStore store = darknodeRegistryProxy.store();
        IDarknodePayment darknodePayment = darknodeRegistryProxy
            .darknodePayment();

        // Claim and update.
        darknodeRegistryProxy.claimOwnership();
        renProxyAdmin.upgrade(
            AdminUpgradeabilityProxy(
                // Cast gateway instance to payable address
                address(uint160(address(darknodeRegistryProxy)))
            ),
            address(darknodeRegistryLogicV2)
        );

        // Post-checks
        require(
            numDarknodes == darknodeRegistryProxy.numDarknodes(),
            "Migrator: expected 'numDarknodes' not to change"
        );
        require(
            numDarknodesNextEpoch ==
                darknodeRegistryProxy.numDarknodesNextEpoch(),
            "Migrator: expected 'numDarknodesNextEpoch' not to change"
        );
        require(
            numDarknodesPreviousEpoch ==
                darknodeRegistryProxy.numDarknodesPreviousEpoch(),
            "Migrator: expected 'numDarknodesPreviousEpoch' not to change"
        );
        require(
            minimumBond == darknodeRegistryProxy.minimumBond(),
            "Migrator: expected 'minimumBond' not to change"
        );
        require(
            minimumPodSize == darknodeRegistryProxy.minimumPodSize(),
            "Migrator: expected 'minimumPodSize' not to change"
        );
        require(
            minimumEpochInterval ==
                darknodeRegistryProxy.minimumEpochInterval(),
            "Migrator: expected 'minimumEpochInterval' not to change"
        );
        require(
            deregistrationInterval ==
                darknodeRegistryProxy.deregistrationInterval(),
            "Migrator: expected 'deregistrationInterval' not to change"
        );
        require(
            ren == darknodeRegistryProxy.ren(),
            "Migrator: expected 'ren' not to change"
        );
        require(
            store == darknodeRegistryProxy.store(),
            "Migrator: expected 'store' not to change"
        );
        require(
            darknodePayment == darknodeRegistryProxy.darknodePayment(),
            "Migrator: expected 'darknodePayment' not to change"
        );

        darknodeRegistryProxy.updateSlasher(IDarknodeSlasher(0x0));
    }

    function recover(
        address _darknodeID,
        address _bondRecipient,
        bytes calldata _signature
    ) external onlyOwner {
        return
            DarknodeRegistryLogicV2(address(darknodeRegistryProxy)).recover(
                _darknodeID,
                _bondRecipient,
                _signature
            );
    }

    function returnDNR() public onlyOwner {
        darknodeRegistryProxy._directTransferOwnership(
            previousDarknodeRegistryOwner
        );
    }

    function returnProxyAdmin() public onlyOwner {
        renProxyAdmin.transferOwnership(previousAdminOwner);
    }
}






pragma solidity 0.5.17;

//import "@openzeppelin/upgrades/contracts/upgradeability/ProxyAdmin.sol";

/**
 * @title RenProxyAdmin
 * @dev Proxies restrict the proxy's owner from calling functions from the
 * delegate contract logic. The ProxyAdmin contract allows single account to be
 * the governance address of both the proxy and the delegate contract logic.
 */
/* solium-disable-next-line no-empty-blocks */
contract RenProxyAdmin is ProxyAdmin {

}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../../GSN/Context.sol";
//import "../Roles.sol";

contract PauserRole is Initializable, Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../../GSN/Context.sol";
//import "./IERC20.sol";
//import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Initializable, Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
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
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

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
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import './BaseAdminUpgradeabilityProxy.sol';

/**
 * @title AdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for 
 * initializing the implementation, admin, and init data.
 */
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Initializable, Ownable {
    address public pendingOwner;

    function initialize(address _nextOwner) public initializer {
        Ownable.initialize(_nextOwner);
    }

    modifier onlyPendingOwner() {
        require(
            _msgSender() == pendingOwner,
            "Claimable: caller is not the pending owner"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != owner() && newOwner != pendingOwner,
            "Claimable: invalid new owner"
        );
        pendingOwner = newOwner;
    }

    // Allow skipping two-step transfer if the recipient is known to be a valid
    // owner, for use in smart-contracts only.
    function _directTransferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function claimOwnership() public onlyPendingOwner {
        _transferOwnership(pendingOwner);
        delete pendingOwner;
    }
}






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../Governance/Claimable.sol";

contract CanReclaimTokens is Claimable {
    using SafeERC20 for ERC20;

    mapping(address => bool) private recoverableTokensBlacklist;

    function initialize(address _nextOwner) public initializer {
        Claimable.initialize(_nextOwner);
    }

    function blacklistRecoverableToken(address _token) public onlyOwner {
        recoverableTokensBlacklist[_token] = true;
    }

    /// @notice Allow the owner of the contract to recover funds accidentally
    /// sent to the contract. To withdraw ETH, the token should be set to `0x0`.
    function recoverTokens(address _token) external onlyOwner {
        require(
            !recoverableTokensBlacklist[_token],
            "CanReclaimTokens: token is not recoverable"
        );

        if (_token == address(0x0)) {
            msg.sender.transfer(address(this).balance);
        } else {
            ERC20(_token).safeTransfer(
                msg.sender,
                ERC20(_token).balanceOf(address(this))
            );
        }
    }
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../GSN/Context.sol";
//import "../access/roles/PauserRole.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Initializable, Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[50] private ______gap;
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";
//import "./ERC20.sol";
//import "../../lifecycle/Pausable.sol";

/**
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Pausable is Initializable, ERC20, Pausable {
    function initialize(address sender) public initializer {
        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    uint256[50] private ______gap;
}




/// @notice DarknodeRegistry is responsible for the registration and
/// deregistration of Darknodes.
contract DarknodeRegistryLogicV2 is
    Claimable,
    CanReclaimTokens,
    DarknodeRegistryStateV1,
    DarknodeRegistryStateV2
{
    using SafeMath for uint256;

    /// @notice Emitted when a darknode is registered.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was registered.
    /// @param _bond The amount of REN that was transferred as bond.
    event LogDarknodeRegistered(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        uint256 _bond
    );

    /// @notice Emitted when a darknode is deregistered.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was deregistered.
    event LogDarknodeDeregistered(
        address indexed _darknodeOperator,
        address indexed _darknodeID
    );

    /// @notice Emitted when a refund has been made.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was refunded.
    /// @param _amount The amount of REN that was refunded.
    event LogDarknodeRefunded(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        uint256 _amount
    );

    /// @notice Emitted when a recovery has been made.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was recovered.
    /// @param _bondRecipient The address that received the bond.
    /// @param _submitter The address that called the recover method.
    event LogDarknodeRecovered(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        address _bondRecipient,
        address indexed _submitter
    );

    /// @notice Emitted when a darknode's bond is slashed.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was slashed.
    /// @param _challenger The address of the account that submitted the challenge.
    /// @param _percentage The total percentage  of bond slashed.
    event LogDarknodeSlashed(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        address indexed _challenger,
        uint256 _percentage
    );

    /// @notice Emitted when a new epoch has begun.
    event LogNewEpoch(uint256 indexed epochhash);

    /// @notice Emitted when a constructor parameter has been updated.
    event LogMinimumBondUpdated(
        uint256 _previousMinimumBond,
        uint256 _nextMinimumBond
    );
    event LogMinimumPodSizeUpdated(
        uint256 _previousMinimumPodSize,
        uint256 _nextMinimumPodSize
    );
    event LogMinimumEpochIntervalUpdated(
        uint256 _previousMinimumEpochInterval,
        uint256 _nextMinimumEpochInterval
    );
    event LogSlasherUpdated(
        address indexed _previousSlasher,
        address indexed _nextSlasher
    );
    event LogDarknodePaymentUpdated(
        address indexed _previousDarknodePayment,
        address indexed _nextDarknodePayment
    );

    /// @notice Restrict a function to the owner that registered the darknode.
    modifier onlyDarknodeOperator(address _darknodeID) {
        require(
            store.darknodeOperator(_darknodeID) == msg.sender,
            "DarknodeRegistry: must be darknode owner"
        );
        _;
    }

    /// @notice Restrict a function to unregistered darknodes.
    modifier onlyRefunded(address _darknodeID) {
        require(
            isRefunded(_darknodeID),
            "DarknodeRegistry: must be refunded or never registered"
        );
        _;
    }

    /// @notice Restrict a function to refundable darknodes.
    modifier onlyRefundable(address _darknodeID) {
        require(
            isRefundable(_darknodeID),
            "DarknodeRegistry: must be deregistered for at least one epoch"
        );
        _;
    }

    /// @notice Restrict a function to registered nodes without a pending
    /// deregistration.
    modifier onlyDeregisterable(address _darknodeID) {
        require(
            isDeregisterable(_darknodeID),
            "DarknodeRegistry: must be deregisterable"
        );
        _;
    }

    /// @notice Restrict a function to the Slasher contract.
    modifier onlySlasher() {
        require(
            address(slasher) == msg.sender,
            "DarknodeRegistry: must be slasher"
        );
        _;
    }

    /// @notice Restrict a function to registered and deregistered nodes.
    modifier onlyDarknode(address _darknodeID) {
        require(
            isRegistered(_darknodeID) || isDeregistered(_darknodeID),
            "DarknodeRegistry: invalid darknode"
        );
        _;
    }

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _renAddress The address of the RenToken contract.
    /// @param _storeAddress The address of the DarknodeRegistryStore contract.
    /// @param _minimumBond The minimum bond amount that can be submitted by a
    ///        Darknode.
    /// @param _minimumPodSize The minimum size of a Darknode pod.
    /// @param _minimumEpochIntervalSeconds The minimum number of seconds between epochs.
    function initialize(
        string memory _VERSION,
        RenToken _renAddress,
        DarknodeRegistryStore _storeAddress,
        uint256 _minimumBond,
        uint256 _minimumPodSize,
        uint256 _minimumEpochIntervalSeconds,
        uint256 _deregistrationIntervalSeconds
    ) public initializer {
        Claimable.initialize(msg.sender);
        CanReclaimTokens.initialize(msg.sender);
        VERSION = _VERSION;

        store = _storeAddress;
        ren = _renAddress;

        minimumBond = _minimumBond;
        nextMinimumBond = minimumBond;

        minimumPodSize = _minimumPodSize;
        nextMinimumPodSize = minimumPodSize;

        minimumEpochInterval = _minimumEpochIntervalSeconds;
        nextMinimumEpochInterval = minimumEpochInterval;
        deregistrationInterval = _deregistrationIntervalSeconds;

        uint256 epochhash = uint256(blockhash(block.number - 1));
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocktime: block.timestamp
        });
        emit LogNewEpoch(epochhash);
    }

    /// @notice Register a darknode and transfer the bond to this contract.
    /// Before registering, the bond transfer must be approved in the REN
    /// contract. The caller must provide a public encryption key for the
    /// darknode. The darknode will remain pending registration until the next
    /// epoch. Only after this period can the darknode be deregistered. The
    /// caller of this method will be stored as the owner of the darknode.
    ///
    /// @param _darknodeID The darknode ID that will be registered.
    function registerNode(address _darknodeID)
        public
        onlyRefunded(_darknodeID)
    {
        require(
            _darknodeID != address(0),
            "DarknodeRegistry: darknode address cannot be zero"
        );

        // Use the current minimum bond as the darknode's bond and transfer bond to store
        require(
            ren.transferFrom(msg.sender, address(store), minimumBond),
            "DarknodeRegistry: bond transfer failed"
        );

        // Flag this darknode for registration
        store.appendDarknode(
            _darknodeID,
            msg.sender,
            minimumBond,
            "",
            currentEpoch.blocktime.add(minimumEpochInterval),
            0
        );

        numDarknodesNextEpoch = numDarknodesNextEpoch.add(1);

        // Emit an event.
        emit LogDarknodeRegistered(msg.sender, _darknodeID, minimumBond);
    }

    /// @notice An alias for `registerNode` that includes the legacy public key
    /// parameter.
    /// @param _darknodeID The darknode ID that will be registered.
    /// @param _publicKey Deprecated parameter - see `registerNode`.
    function register(address _darknodeID, bytes calldata _publicKey) external {
        return registerNode(_darknodeID);
    }

    /// @notice Register multiple darknodes and transfer the bonds to this contract.
    /// Before registering, the bonds transfer must be approved in the REN contract.
    /// The darknodes will remain pending registration until the next epoch. Only
    /// after this period can the darknodes be deregistered. The caller of this method
    /// will be stored as the owner of each darknode. If one registration fails, all
    /// registrations fail.
    /// @param _darknodeIDs The darknode IDs that will be registered.
    function registerMultiple(address[] calldata _darknodeIDs) external {
        // Save variables in memory to prevent redundant reads from storage
        DarknodeRegistryStore _store = store;
        Epoch memory _currentEpoch = currentEpoch;
        uint256 nextRegisteredAt = _currentEpoch.blocktime.add(
            minimumEpochInterval
        );
        uint256 _minimumBond = minimumBond;

        require(
            ren.transferFrom(
                msg.sender,
                address(_store),
                _minimumBond.mul(_darknodeIDs.length)
            ),
            "DarknodeRegistry: bond transfers failed"
        );

        for (uint256 i = 0; i < _darknodeIDs.length; i++) {
            address darknodeID = _darknodeIDs[i];

            uint256 registeredAt = _store.darknodeRegisteredAt(darknodeID);
            uint256 deregisteredAt = _store.darknodeDeregisteredAt(darknodeID);

            require(
                _isRefunded(registeredAt, deregisteredAt),
                "DarknodeRegistry: must be refunded or never registered"
            );

            require(
                darknodeID != address(0),
                "DarknodeRegistry: darknode address cannot be zero"
            );

            _store.appendDarknode(
                darknodeID,
                msg.sender,
                _minimumBond,
                "",
                nextRegisteredAt,
                0
            );

            emit LogDarknodeRegistered(msg.sender, darknodeID, _minimumBond);
        }

        numDarknodesNextEpoch = numDarknodesNextEpoch.add(_darknodeIDs.length);
    }

    /// @notice Deregister a darknode. The darknode will not be deregistered
    /// until the end of the epoch. After another epoch, the bond can be
    /// refunded by calling the refund method.
    /// @param _darknodeID The darknode ID that will be deregistered. The caller
    ///        of this method must be the owner of this darknode.
    function deregister(address _darknodeID)
        external
        onlyDeregisterable(_darknodeID)
        onlyDarknodeOperator(_darknodeID)
    {
        deregisterDarknode(_darknodeID);
    }

    /// @notice Deregister multiple darknodes. The darknodes will not be
    /// deregistered until the end of the epoch. After another epoch, their
    /// bonds can be refunded by calling the refund or refundMultiple methods.
    /// If one deregistration fails, all deregistrations fail.
    /// @param _darknodeIDs The darknode IDs that will be deregistered. The
    /// caller of this method must be the owner of each darknode.
    function deregisterMultiple(address[] calldata _darknodeIDs) external {
        // Save variables in memory to prevent redundant reads from storage
        DarknodeRegistryStore _store = store;
        Epoch memory _currentEpoch = currentEpoch;
        uint256 _minimumEpochInterval = minimumEpochInterval;

        for (uint256 i = 0; i < _darknodeIDs.length; i++) {
            address darknodeID = _darknodeIDs[i];

            uint256 deregisteredAt = _store.darknodeDeregisteredAt(darknodeID);
            bool registered = isRegisteredInEpoch(
                _store.darknodeRegisteredAt(darknodeID),
                deregisteredAt,
                _currentEpoch
            );

            require(
                _isDeregisterable(registered, deregisteredAt),
                "DarknodeRegistry: must be deregisterable"
            );

            require(
                _store.darknodeOperator(darknodeID) == msg.sender,
                "DarknodeRegistry: must be darknode owner"
            );

            _store.updateDarknodeDeregisteredAt(
                darknodeID,
                _currentEpoch.blocktime.add(_minimumEpochInterval)
            );

            emit LogDarknodeDeregistered(msg.sender, darknodeID);
        }

        numDarknodesNextEpoch = numDarknodesNextEpoch.sub(_darknodeIDs.length);
    }

    /// @notice Progress the epoch if it is possible to do so. This captures
    /// the current timestamp and current blockhash and overrides the current
    /// epoch.
    function epoch() external {
        if (previousEpoch.blocktime == 0) {
            // The first epoch must be called by the owner of the contract
            require(
                msg.sender == owner(),
                "DarknodeRegistry: not authorized to call first epoch"
            );
        }

        // Require that the epoch interval has passed
        require(
            block.timestamp >= currentEpoch.blocktime.add(minimumEpochInterval),
            "DarknodeRegistry: epoch interval has not passed"
        );
        uint256 epochhash = uint256(blockhash(block.number - 1));

        // Update the epoch hash and timestamp
        previousEpoch = currentEpoch;
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocktime: block.timestamp
        });

        // Update the registry information
        numDarknodesPreviousEpoch = numDarknodes;
        numDarknodes = numDarknodesNextEpoch;

        // If any update functions have been called, update the values now
        if (nextMinimumBond != minimumBond) {
            minimumBond = nextMinimumBond;
            emit LogMinimumBondUpdated(minimumBond, nextMinimumBond);
        }
        if (nextMinimumPodSize != minimumPodSize) {
            minimumPodSize = nextMinimumPodSize;
            emit LogMinimumPodSizeUpdated(minimumPodSize, nextMinimumPodSize);
        }
        if (nextMinimumEpochInterval != minimumEpochInterval) {
            minimumEpochInterval = nextMinimumEpochInterval;
            emit LogMinimumEpochIntervalUpdated(
                minimumEpochInterval,
                nextMinimumEpochInterval
            );
        }
        if (nextSlasher != slasher) {
            slasher = nextSlasher;
            emit LogSlasherUpdated(address(slasher), address(nextSlasher));
        }

        // Emit an event
        emit LogNewEpoch(epochhash);
    }

    /// @notice Allows the contract owner to initiate an ownership transfer of
    /// the DarknodeRegistryStore.
    /// @param _newOwner The address to transfer the ownership to.
    function transferStoreOwnership(DarknodeRegistryLogicV2 _newOwner)
        external
        onlyOwner
    {
        store.transferOwnership(address(_newOwner));
        _newOwner.claimStoreOwnership();
    }

    /// @notice Claims ownership of the store passed in to the constructor.
    /// `transferStoreOwnership` must have previously been called when
    /// transferring from another Darknode Registry.
    function claimStoreOwnership() external {
        store.claimOwnership();

        // Sync state with new store.
        // Note: numDarknodesPreviousEpoch is set to 0 for a newly deployed DNR.
        (
            numDarknodesPreviousEpoch,
            numDarknodes,
            numDarknodesNextEpoch
        ) = getDarknodeCountFromEpochs();
    }

    /// @notice Allows the contract owner to update the minimum bond.
    /// @param _nextMinimumBond The minimum bond amount that can be submitted by
    ///        a darknode.
    function updateMinimumBond(uint256 _nextMinimumBond) external onlyOwner {
        // Will be updated next epoch
        nextMinimumBond = _nextMinimumBond;
    }

    /// @notice Allows the contract owner to update the minimum pod size.
    /// @param _nextMinimumPodSize The minimum size of a pod.
    function updateMinimumPodSize(uint256 _nextMinimumPodSize)
        external
        onlyOwner
    {
        // Will be updated next epoch
        nextMinimumPodSize = _nextMinimumPodSize;
    }

    /// @notice Allows the contract owner to update the minimum epoch interval.
    /// @param _nextMinimumEpochInterval The minimum number of blocks between epochs.
    function updateMinimumEpochInterval(uint256 _nextMinimumEpochInterval)
        external
        onlyOwner
    {
        // Will be updated next epoch
        nextMinimumEpochInterval = _nextMinimumEpochInterval;
    }

    /// @notice Allow the contract owner to update the DarknodeSlasher contract
    /// address.
    /// @param _slasher The new slasher address.
    function updateSlasher(IDarknodeSlasher _slasher) external onlyOwner {
        nextSlasher = _slasher;
    }

    /// @notice Allow the DarknodeSlasher contract to slash a portion of darknode's
    ///         bond and deregister it.
    /// @param _guilty The guilty prover whose bond is being slashed.
    /// @param _challenger The challenger who should receive a portion of the bond as reward.
    /// @param _percentage The total percentage  of bond to be slashed.
    function slash(
        address _guilty,
        address _challenger,
        uint256 _percentage
    ) external onlySlasher onlyDarknode(_guilty) {
        require(_percentage <= 100, "DarknodeRegistry: invalid percent");

        // If the darknode has not been deregistered then deregister it
        if (isDeregisterable(_guilty)) {
            deregisterDarknode(_guilty);
        }

        uint256 totalBond = store.darknodeBond(_guilty);
        uint256 penalty = totalBond.div(100).mul(_percentage);
        uint256 challengerReward = penalty.div(2);
        uint256 slasherPortion = penalty.sub(challengerReward);
        if (challengerReward > 0) {
            // Slash the bond of the failed prover
            store.updateDarknodeBond(_guilty, totalBond.sub(penalty));

            // Forward the remaining amount to be handled by the slasher.
            require(
                ren.transfer(msg.sender, slasherPortion),
                "DarknodeRegistry: reward transfer to slasher failed"
            );
            require(
                ren.transfer(_challenger, challengerReward),
                "DarknodeRegistry: reward transfer to challenger failed"
            );
        }

        emit LogDarknodeSlashed(
            store.darknodeOperator(_guilty),
            _guilty,
            _challenger,
            _percentage
        );
    }

    /// @notice Refund the bond of a deregistered darknode. This will make the
    /// darknode available for registration again.
    ///
    /// @param _darknodeID The darknode ID that will be refunded.
    function refund(address _darknodeID)
        external
        onlyRefundable(_darknodeID)
        onlyDarknodeOperator(_darknodeID)
    {
        // Remember the bond amount
        uint256 amount = store.darknodeBond(_darknodeID);

        // Erase the darknode from the registry
        store.removeDarknode(_darknodeID);

        // Refund the operator by transferring REN
        require(
            ren.transfer(msg.sender, amount),
            "DarknodeRegistry: bond transfer failed"
        );

        // Emit an event.
        emit LogDarknodeRefunded(msg.sender, _darknodeID, amount);
    }

    /// @notice A permissioned method for refunding a darknode without the usual
    /// delay. The operator must provide a signature of the darknode ID and the
    /// bond recipient, but the call must come from the contract's owner. The
    /// main use case is for when an operator's keys have been compromised,
    /// allowing for the bonds to be recovered by the operator through the
    /// GatewayRegistry's governance. It is expected that this process would
    /// happen towards the end of the darknode's deregistered period, so that
    /// a malicious operator can't use this to quickly exit their stake after
    /// attempting an attack on the network. It's also expected that the
    /// operator will not re-register the same darknode again.
    function recover(
        address _darknodeID,
        address _bondRecipient,
        bytes calldata _signature
    ) external onlyOwner {
        require(
            isRefundable(_darknodeID) || isDeregistered(_darknodeID),
            "DarknodeRegistry: must be deregistered"
        );

        address darknodeOperator = store.darknodeOperator(_darknodeID);

        require(
            ECDSA.recover(
                keccak256(
                    abi.encodePacked(
                        "\x19Ethereum Signed Message:\n64",
                        "DarknodeRegistry.recover",
                        _darknodeID,
                        _bondRecipient
                    )
                ),
                _signature
            ) == darknodeOperator,
            "DarknodeRegistry: invalid signature"
        );

        // Remember the bond amount
        uint256 amount = store.darknodeBond(_darknodeID);

        // Erase the darknode from the registry
        store.removeDarknode(_darknodeID);

        // Refund the operator by transferring REN
        require(
            ren.transfer(_bondRecipient, amount),
            "DarknodeRegistry: bond transfer failed"
        );

        // Emit an event.
        emit LogDarknodeRefunded(darknodeOperator, _darknodeID, amount);
        emit LogDarknodeRecovered(
            darknodeOperator,
            _darknodeID,
            _bondRecipient,
            msg.sender
        );
    }

    /// @notice Refund the bonds of multiple deregistered darknodes. This will
    /// make the darknodes available for registration again. If one refund fails,
    /// all refunds fail.
    /// @param _darknodeIDs The darknode IDs that will be refunded.
    function refundMultiple(address[] calldata _darknodeIDs) external {
        // Save variables in memory to prevent redundant reads from storage
        DarknodeRegistryStore _store = store;
        Epoch memory _currentEpoch = currentEpoch;
        Epoch memory _previousEpoch = previousEpoch;
        uint256 _deregistrationInterval = deregistrationInterval;

        // The sum of bonds to refund
        uint256 sum;

        for (uint256 i = 0; i < _darknodeIDs.length; i++) {
            address darknodeID = _darknodeIDs[i];

            uint256 deregisteredAt = _store.darknodeDeregisteredAt(darknodeID);
            bool deregistered = _isDeregistered(deregisteredAt, _currentEpoch);

            require(
                _isRefundable(
                    deregistered,
                    deregisteredAt,
                    _previousEpoch,
                    _deregistrationInterval
                ),
                "DarknodeRegistry: must be deregistered for at least one epoch"
            );

            require(
                _store.darknodeOperator(darknodeID) == msg.sender,
                "DarknodeRegistry: must be darknode owner"
            );

            // Remember the bond amount
            uint256 amount = _store.darknodeBond(darknodeID);

            // Erase the darknode from the registry
            _store.removeDarknode(darknodeID);

            // Emit an event
            emit LogDarknodeRefunded(msg.sender, darknodeID, amount);

            // Increment the sum of bonds to be transferred
            sum = sum.add(amount);
        }

        // Transfer all bonds together
        require(
            ren.transfer(msg.sender, sum),
            "DarknodeRegistry: bond transfers failed"
        );
    }

    /// @notice Retrieves the address of the account that registered a darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the owner for.
    function getDarknodeOperator(address _darknodeID)
        external
        view
        returns (address payable)
    {
        return store.darknodeOperator(_darknodeID);
    }

    /// @notice Retrieves the bond amount of a darknode in 10^-18 REN.
    /// @param _darknodeID The ID of the darknode to retrieve the bond for.
    function getDarknodeBond(address _darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeBond(_darknodeID);
    }

    /// @notice Retrieves the encryption public key of the darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the public key for.
    function getDarknodePublicKey(address _darknodeID)
        external
        view
        returns (bytes memory)
    {
        return store.darknodePublicKey(_darknodeID);
    }

    /// @notice Retrieves a list of darknodes which are registered for the
    /// current epoch.
    /// @param _start A darknode ID used as an offset for the list. If _start is
    ///        0x0, the first dark node will be used. _start won't be
    ///        included it is not registered for the epoch.
    /// @param _count The number of darknodes to retrieve starting from _start.
    ///        If _count is 0, all of the darknodes from _start are
    ///        retrieved. If _count is more than the remaining number of
    ///        registered darknodes, the rest of the list will contain
    ///        0x0s.
    function getDarknodes(address _start, uint256 _count)
        external
        view
        returns (address[] memory)
    {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }
        return getDarknodesFromEpochs(_start, count, false);
    }

    /// @notice Retrieves a list of darknodes which were registered for the
    /// previous epoch. See `getDarknodes` for the parameter documentation.
    function getPreviousDarknodes(address _start, uint256 _count)
        external
        view
        returns (address[] memory)
    {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodesPreviousEpoch;
        }
        return getDarknodesFromEpochs(_start, count, true);
    }

    /// @notice Returns whether a darknode is scheduled to become registered
    /// at next epoch.
    /// @param _darknodeID The ID of the darknode to return.
    function isPendingRegistration(address _darknodeID)
        public
        view
        returns (bool)
    {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        return registeredAt != 0 && registeredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the pending deregistered state. In
    /// this state a darknode is still considered registered.
    function isPendingDeregistration(address _darknodeID)
        public
        view
        returns (bool)
    {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the deregistered state.
    function isDeregistered(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return _isDeregistered(deregisteredAt, currentEpoch);
    }

    /// @notice Returns if a darknode can be deregistered. This is true if the
    /// darknodes is in the registered state and has not attempted to
    /// deregister yet.
    function isDeregisterable(address _darknodeID) public view returns (bool) {
        DarknodeRegistryStore _store = store;
        uint256 deregisteredAt = _store.darknodeDeregisteredAt(_darknodeID);
        bool registered = isRegisteredInEpoch(
            _store.darknodeRegisteredAt(_darknodeID),
            deregisteredAt,
            currentEpoch
        );
        return _isDeregisterable(registered, deregisteredAt);
    }

    /// @notice Returns if a darknode is in the refunded state. This is true
    /// for darknodes that have never been registered, or darknodes that have
    /// been deregistered and refunded.
    function isRefunded(address _darknodeID) public view returns (bool) {
        DarknodeRegistryStore _store = store;
        uint256 registeredAt = _store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = _store.darknodeDeregisteredAt(_darknodeID);
        return _isRefunded(registeredAt, deregisteredAt);
    }

    /// @notice Returns if a darknode is refundable. This is true for darknodes
    /// that have been in the deregistered state for one full epoch.
    function isRefundable(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        bool deregistered = _isDeregistered(deregisteredAt, currentEpoch);

        return
            _isRefundable(
                deregistered,
                deregisteredAt,
                previousEpoch,
                deregistrationInterval
            );
    }

    /// @notice Returns the registration time of a given darknode.
    function darknodeRegisteredAt(address darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeRegisteredAt(darknodeID);
    }

    /// @notice Returns the deregistration time of a given darknode.
    function darknodeDeregisteredAt(address darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeDeregisteredAt(darknodeID);
    }

    /// @notice Returns if a darknode is in the registered state.
    function isRegistered(address _darknodeID) public view returns (bool) {
        DarknodeRegistryStore _store = store;
        uint256 registeredAt = _store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = _store.darknodeDeregisteredAt(_darknodeID);
        return isRegisteredInEpoch(registeredAt, deregisteredAt, currentEpoch);
    }

    /// @notice Returns if a darknode was in the registered state last epoch.
    function isRegisteredInPreviousEpoch(address _darknodeID)
        public
        view
        returns (bool)
    {
        DarknodeRegistryStore _store = store;
        uint256 registeredAt = _store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = _store.darknodeDeregisteredAt(_darknodeID);
        return isRegisteredInEpoch(registeredAt, deregisteredAt, previousEpoch);
    }

    /// @notice Returns the darknodes registered by the provided operator.
    /// @dev THIS IS AN EXPENSIVE CALL - this should only called when using
    /// eth_call contract reads - not in transactions.
    function getOperatorDarknodes(address _operator)
        external
        view
        returns (address[] memory)
    {
        address[] memory nodesPadded = new address[](numDarknodes);

        address[] memory allNodes = getDarknodesFromEpochs(
            address(0),
            numDarknodes,
            false
        );

        uint256 j = 0;
        for (uint256 i = 0; i < allNodes.length; i++) {
            if (store.darknodeOperator(allNodes[i]) == _operator) {
                nodesPadded[j] = (allNodes[i]);
                j++;
            }
        }

        address[] memory nodes = new address[](j);
        for (uint256 i = 0; i < j; i++) {
            nodes[i] = nodesPadded[i];
        }

        return nodes;
    }

    /// @notice Returns if a darknode was in the registered state for a given
    /// epoch.
    /// @param _epoch One of currentEpoch, previousEpoch.
    function isRegisteredInEpoch(
        uint256 _registeredAt,
        uint256 _deregisteredAt,
        Epoch memory _epoch
    ) private pure returns (bool) {
        bool registered = _registeredAt != 0 &&
            _registeredAt <= _epoch.blocktime;
        bool notDeregistered = _deregisteredAt == 0 ||
            _deregisteredAt > _epoch.blocktime;
        // The Darknode has been registered and has not yet been deregistered,
        // although it might be pending deregistration
        return registered && notDeregistered;
    }

    /// Private function called by `isDeregistered`, `isRefundable`, and `refundMultiple`.
    function _isDeregistered(
        uint256 _deregisteredAt,
        Epoch memory _currentEpoch
    ) private pure returns (bool) {
        return
            _deregisteredAt != 0 && _deregisteredAt <= _currentEpoch.blocktime;
    }

    /// Private function called by `isDeregisterable` and `deregisterMultiple`.
    function _isDeregisterable(bool _registered, uint256 _deregisteredAt)
        private
        pure
        returns (bool)
    {
        // The Darknode is currently in the registered state and has not been
        // transitioned to the pending deregistration, or deregistered, state
        return _registered && _deregisteredAt == 0;
    }

    /// Private function called by `isRefunded` and `registerMultiple`.
    function _isRefunded(uint256 registeredAt, uint256 deregisteredAt)
        private
        pure
        returns (bool)
    {
        return registeredAt == 0 && deregisteredAt == 0;
    }

    /// Private function called by `isRefundable` and `refundMultiple`.
    function _isRefundable(
        bool _deregistered,
        uint256 _deregisteredAt,
        Epoch memory _previousEpoch,
        uint256 _deregistrationInterval
    ) private pure returns (bool) {
        return
            _deregistered &&
            _deregisteredAt <=
            (_previousEpoch.blocktime - _deregistrationInterval);
    }

    /// @notice Returns a list of darknodes registered for either the current
    /// or the previous epoch. See `getDarknodes` for documentation on the
    /// parameters `_start` and `_count`.
    /// @param _usePreviousEpoch If true, use the previous epoch, otherwise use
    ///        the current epoch.
    function getDarknodesFromEpochs(
        address _start,
        uint256 _count,
        bool _usePreviousEpoch
    ) private view returns (address[] memory) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }

        address[] memory nodes = new address[](count);

        // Begin with the first node in the list
        uint256 n = 0;
        address next = _start;
        if (next == address(0)) {
            next = store.begin();
        }

        // Iterate until all registered Darknodes have been collected
        while (n < count) {
            if (next == address(0)) {
                break;
            }
            // Only include Darknodes that are currently registered
            bool includeNext;
            if (_usePreviousEpoch) {
                includeNext = isRegisteredInPreviousEpoch(next);
            } else {
                includeNext = isRegistered(next);
            }
            if (!includeNext) {
                next = store.next(next);
                continue;
            }
            nodes[n] = next;
            next = store.next(next);
            n += 1;
        }
        return nodes;
    }

    /// Private function called by `deregister` and `slash`
    function deregisterDarknode(address _darknodeID) private {
        address darknodeOperator = store.darknodeOperator(_darknodeID);

        // Flag the darknode for deregistration
        store.updateDarknodeDeregisteredAt(
            _darknodeID,
            currentEpoch.blocktime.add(minimumEpochInterval)
        );
        numDarknodesNextEpoch = numDarknodesNextEpoch.sub(1);

        // Emit an event
        emit LogDarknodeDeregistered(darknodeOperator, _darknodeID);
    }

    function getDarknodeCountFromEpochs()
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        // Begin with the first node in the list
        uint256 nPreviousEpoch = 0;
        uint256 nCurrentEpoch = 0;
        uint256 nNextEpoch = 0;
        address next = store.begin();

        // Iterate until all registered Darknodes have been collected
        while (true) {
            // End of darknode list.
            if (next == address(0)) {
                break;
            }

            if (isRegisteredInPreviousEpoch(next)) {
                nPreviousEpoch += 1;
            }

            if (isRegistered(next)) {
                nCurrentEpoch += 1;
            }

            // Darknode is registered and has not deregistered, or is pending
            // becoming registered.
            if (
                ((isRegistered(next) && !isPendingDeregistration(next)) ||
                    isPendingRegistration(next))
            ) {
                nNextEpoch += 1;
            }
            next = store.next(next);
        }
        return (nPreviousEpoch, nCurrentEpoch, nNextEpoch);
    }
}






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";

//import "../Governance/Claimable.sol";
//import "../libraries/LinkedList.sol";
//import "../RenToken/RenToken.sol";
//import "../libraries/CanReclaimTokens.sol";

/// @notice This contract stores data and funds for the DarknodeRegistry
/// contract. The data / fund logic and storage have been separated to improve
/// upgradability.
contract DarknodeRegistryStore is Claimable, CanReclaimTokens {
    using SafeMath for uint256;

    string public VERSION; // Passed in as a constructor parameter.

    /// @notice Darknodes are stored in the darknode struct. The owner is the
    /// address that registered the darknode, the bond is the amount of REN that
    /// was transferred during registration, and the public key is the
    /// encryption key that should be used when sending sensitive information to
    /// the darknode.
    struct Darknode {
        // The owner of a Darknode is the address that called the register
        // function. The owner is the only address that is allowed to
        // deregister the Darknode, unless the Darknode is slashed for
        // malicious behavior.
        address payable owner;
        // The bond is the amount of REN submitted as a bond by the Darknode.
        // This amount is reduced when the Darknode is slashed for malicious
        // behavior.
        uint256 bond;
        // The block number at which the Darknode is considered registered.
        uint256 registeredAt;
        // The block number at which the Darknode is considered deregistered.
        uint256 deregisteredAt;
        // The public key used by this Darknode for encrypting sensitive data
        // off chain. It is assumed that the Darknode has access to the
        // respective private key, and that there is an agreement on the format
        // of the public key.
        bytes publicKey;
    }

    /// Registry data.
    mapping(address => Darknode) private darknodeRegistry;
    LinkedList.List private darknodes;

    // RenToken.
    RenToken public ren;

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _ren The address of the RenToken contract.
    constructor(string memory _VERSION, RenToken _ren) public {
        Claimable.initialize(msg.sender);
        CanReclaimTokens.initialize(msg.sender);
        VERSION = _VERSION;
        ren = _ren;
        blacklistRecoverableToken(address(ren));
    }

    /// @notice Instantiates a darknode and appends it to the darknodes
    /// linked-list.
    ///
    /// @param _darknodeID The darknode's ID.
    /// @param _darknodeOperator The darknode's owner's address.
    /// @param _bond The darknode's bond value.
    /// @param _publicKey The darknode's public key.
    /// @param _registeredAt The time stamp when the darknode is registered.
    /// @param _deregisteredAt The time stamp when the darknode is deregistered.
    function appendDarknode(
        address _darknodeID,
        address payable _darknodeOperator,
        uint256 _bond,
        bytes calldata _publicKey,
        uint256 _registeredAt,
        uint256 _deregisteredAt
    ) external onlyOwner {
        Darknode memory darknode =
            Darknode({
                owner: _darknodeOperator,
                bond: _bond,
                publicKey: _publicKey,
                registeredAt: _registeredAt,
                deregisteredAt: _deregisteredAt
            });
        darknodeRegistry[_darknodeID] = darknode;
        LinkedList.append(darknodes, _darknodeID);
    }

    /// @notice Returns the address of the first darknode in the store.
    function begin() external view onlyOwner returns (address) {
        return LinkedList.begin(darknodes);
    }

    /// @notice Returns the address of the next darknode in the store after the
    /// given address.
    function next(address darknodeID)
        external
        view
        onlyOwner
        returns (address)
    {
        return LinkedList.next(darknodes, darknodeID);
    }

    /// @notice Removes a darknode from the store and transfers its bond to the
    /// owner of this contract.
    function removeDarknode(address darknodeID) external onlyOwner {
        uint256 bond = darknodeRegistry[darknodeID].bond;
        delete darknodeRegistry[darknodeID];
        LinkedList.remove(darknodes, darknodeID);
        require(
            ren.transfer(owner(), bond),
            "DarknodeRegistryStore: bond transfer failed"
        );
    }

    /// @notice Updates the bond of a darknode. The new bond must be smaller
    /// than the previous bond of the darknode.
    function updateDarknodeBond(address darknodeID, uint256 decreasedBond)
        external
        onlyOwner
    {
        uint256 previousBond = darknodeRegistry[darknodeID].bond;
        require(
            decreasedBond < previousBond,
            "DarknodeRegistryStore: bond not decreased"
        );
        darknodeRegistry[darknodeID].bond = decreasedBond;
        require(
            ren.transfer(owner(), previousBond.sub(decreasedBond)),
            "DarknodeRegistryStore: bond transfer failed"
        );
    }

    /// @notice Updates the deregistration timestamp of a darknode.
    function updateDarknodeDeregisteredAt(
        address darknodeID,
        uint256 deregisteredAt
    ) external onlyOwner {
        darknodeRegistry[darknodeID].deregisteredAt = deregisteredAt;
    }

    /// @notice Returns the owner of a given darknode.
    function darknodeOperator(address darknodeID)
        external
        view
        onlyOwner
        returns (address payable)
    {
        return darknodeRegistry[darknodeID].owner;
    }

    /// @notice Returns the bond of a given darknode.
    function darknodeBond(address darknodeID)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return darknodeRegistry[darknodeID].bond;
    }

    /// @notice Returns the registration time of a given darknode.
    function darknodeRegisteredAt(address darknodeID)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return darknodeRegistry[darknodeID].registeredAt;
    }

    /// @notice Returns the deregistration time of a given darknode.
    function darknodeDeregisteredAt(address darknodeID)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return darknodeRegistry[darknodeID].deregisteredAt;
    }

    /// @notice Returns the encryption public key of a given darknode.
    function darknodePublicKey(address darknodeID)
        external
        view
        onlyOwner
        returns (bytes memory)
    {
        return darknodeRegistry[darknodeID].publicKey;
    }
}






pragma solidity ^0.5.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";

//import "../../GSN/Context.sol";
//import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Initializable, Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    uint256[50] private ______gap;
}






/// @notice DarknodeRegistry is responsible for the registration and
/// deregistration of Darknodes.
contract DarknodeRegistryLogicV1 is
    Claimable,
    CanReclaimTokens,
    DarknodeRegistryStateV1
{
    /// @notice Emitted when a darknode is registered.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was registered.
    /// @param _bond The amount of REN that was transferred as bond.
    event LogDarknodeRegistered(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        uint256 _bond
    );

    /// @notice Emitted when a darknode is deregistered.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was deregistered.
    event LogDarknodeDeregistered(
        address indexed _darknodeOperator,
        address indexed _darknodeID
    );

    /// @notice Emitted when a refund has been made.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _amount The amount of REN that was refunded.
    event LogDarknodeRefunded(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        uint256 _amount
    );

    /// @notice Emitted when a darknode's bond is slashed.
    /// @param _darknodeOperator The owner of the darknode.
    /// @param _darknodeID The ID of the darknode that was slashed.
    /// @param _challenger The address of the account that submitted the challenge.
    /// @param _percentage The total percentage  of bond slashed.
    event LogDarknodeSlashed(
        address indexed _darknodeOperator,
        address indexed _darknodeID,
        address indexed _challenger,
        uint256 _percentage
    );

    /// @notice Emitted when a new epoch has begun.
    event LogNewEpoch(uint256 indexed epochhash);

    /// @notice Emitted when a constructor parameter has been updated.
    event LogMinimumBondUpdated(
        uint256 _previousMinimumBond,
        uint256 _nextMinimumBond
    );
    event LogMinimumPodSizeUpdated(
        uint256 _previousMinimumPodSize,
        uint256 _nextMinimumPodSize
    );
    event LogMinimumEpochIntervalUpdated(
        uint256 _previousMinimumEpochInterval,
        uint256 _nextMinimumEpochInterval
    );
    event LogSlasherUpdated(
        address indexed _previousSlasher,
        address indexed _nextSlasher
    );
    event LogDarknodePaymentUpdated(
        IDarknodePayment indexed _previousDarknodePayment,
        IDarknodePayment indexed _nextDarknodePayment
    );

    /// @notice Restrict a function to the owner that registered the darknode.
    modifier onlyDarknodeOperator(address _darknodeID) {
        require(
            store.darknodeOperator(_darknodeID) == msg.sender,
            "DarknodeRegistry: must be darknode owner"
        );
        _;
    }

    /// @notice Restrict a function to unregistered darknodes.
    modifier onlyRefunded(address _darknodeID) {
        require(
            isRefunded(_darknodeID),
            "DarknodeRegistry: must be refunded or never registered"
        );
        _;
    }

    /// @notice Restrict a function to refundable darknodes.
    modifier onlyRefundable(address _darknodeID) {
        require(
            isRefundable(_darknodeID),
            "DarknodeRegistry: must be deregistered for at least one epoch"
        );
        _;
    }

    /// @notice Restrict a function to registered nodes without a pending
    /// deregistration.
    modifier onlyDeregisterable(address _darknodeID) {
        require(
            isDeregisterable(_darknodeID),
            "DarknodeRegistry: must be deregisterable"
        );
        _;
    }

    /// @notice Restrict a function to the Slasher contract.
    modifier onlySlasher() {
        require(
            address(slasher) == msg.sender,
            "DarknodeRegistry: must be slasher"
        );
        _;
    }

    /// @notice Restrict a function to registered nodes without a pending
    /// deregistration.
    modifier onlyDarknode(address _darknodeID) {
        require(
            isRegistered(_darknodeID),
            "DarknodeRegistry: invalid darknode"
        );
        _;
    }

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    /// @param _renAddress The address of the RenToken contract.
    /// @param _storeAddress The address of the DarknodeRegistryStore contract.
    /// @param _minimumBond The minimum bond amount that can be submitted by a
    ///        Darknode.
    /// @param _minimumPodSize The minimum size of a Darknode pod.
    /// @param _minimumEpochIntervalSeconds The minimum number of seconds between epochs.
    function initialize(
        string memory _VERSION,
        RenToken _renAddress,
        DarknodeRegistryStore _storeAddress,
        uint256 _minimumBond,
        uint256 _minimumPodSize,
        uint256 _minimumEpochIntervalSeconds,
        uint256 _deregistrationIntervalSeconds
    ) public initializer {
        Claimable.initialize(msg.sender);
        CanReclaimTokens.initialize(msg.sender);
        VERSION = _VERSION;

        store = _storeAddress;
        ren = _renAddress;

        minimumBond = _minimumBond;
        nextMinimumBond = minimumBond;

        minimumPodSize = _minimumPodSize;
        nextMinimumPodSize = minimumPodSize;

        minimumEpochInterval = _minimumEpochIntervalSeconds;
        nextMinimumEpochInterval = minimumEpochInterval;
        deregistrationInterval = _deregistrationIntervalSeconds;

        uint256 epochhash = uint256(blockhash(block.number - 1));
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocktime: block.timestamp
        });
        emit LogNewEpoch(epochhash);
    }

    /// @notice Register a darknode and transfer the bond to this contract.
    /// Before registering, the bond transfer must be approved in the REN
    /// contract. The caller must provide a public encryption key for the
    /// darknode. The darknode will remain pending registration until the next
    /// epoch. Only after this period can the darknode be deregistered. The
    /// caller of this method will be stored as the owner of the darknode.
    ///
    /// @param _darknodeID The darknode ID that will be registered.
    /// @param _publicKey The public key of the darknode. It is stored to allow
    ///        other darknodes and traders to encrypt messages to the trader.
    function register(address _darknodeID, bytes calldata _publicKey)
        external
        onlyRefunded(_darknodeID)
    {
        require(
            _darknodeID != address(0),
            "DarknodeRegistry: darknode address cannot be zero"
        );

        // Use the current minimum bond as the darknode's bond and transfer bond to store
        require(
            ren.transferFrom(msg.sender, address(store), minimumBond),
            "DarknodeRegistry: bond transfer failed"
        );

        // Flag this darknode for registration
        store.appendDarknode(
            _darknodeID,
            msg.sender,
            minimumBond,
            _publicKey,
            currentEpoch.blocktime.add(minimumEpochInterval),
            0
        );

        numDarknodesNextEpoch = numDarknodesNextEpoch.add(1);

        // Emit an event.
        emit LogDarknodeRegistered(msg.sender, _darknodeID, minimumBond);
    }

    /// @notice Deregister a darknode. The darknode will not be deregistered
    /// until the end of the epoch. After another epoch, the bond can be
    /// refunded by calling the refund method.
    /// @param _darknodeID The darknode ID that will be deregistered. The caller
    ///        of this method must be the owner of this darknode.
    function deregister(address _darknodeID)
        external
        onlyDeregisterable(_darknodeID)
        onlyDarknodeOperator(_darknodeID)
    {
        deregisterDarknode(_darknodeID);
    }

    /// @notice Progress the epoch if it is possible to do so. This captures
    /// the current timestamp and current blockhash and overrides the current
    /// epoch.
    function epoch() external {
        if (previousEpoch.blocktime == 0) {
            // The first epoch must be called by the owner of the contract
            require(
                msg.sender == owner(),
                "DarknodeRegistry: not authorized to call first epoch"
            );
        }

        // Require that the epoch interval has passed
        require(
            block.timestamp >= currentEpoch.blocktime.add(minimumEpochInterval),
            "DarknodeRegistry: epoch interval has not passed"
        );
        uint256 epochhash = uint256(blockhash(block.number - 1));

        // Update the epoch hash and timestamp
        previousEpoch = currentEpoch;
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocktime: block.timestamp
        });

        // Update the registry information
        numDarknodesPreviousEpoch = numDarknodes;
        numDarknodes = numDarknodesNextEpoch;

        // If any update functions have been called, update the values now
        if (nextMinimumBond != minimumBond) {
            minimumBond = nextMinimumBond;
            emit LogMinimumBondUpdated(minimumBond, nextMinimumBond);
        }
        if (nextMinimumPodSize != minimumPodSize) {
            minimumPodSize = nextMinimumPodSize;
            emit LogMinimumPodSizeUpdated(minimumPodSize, nextMinimumPodSize);
        }
        if (nextMinimumEpochInterval != minimumEpochInterval) {
            minimumEpochInterval = nextMinimumEpochInterval;
            emit LogMinimumEpochIntervalUpdated(
                minimumEpochInterval,
                nextMinimumEpochInterval
            );
        }
        if (nextSlasher != slasher) {
            slasher = nextSlasher;
            emit LogSlasherUpdated(address(slasher), address(nextSlasher));
        }
        if (address(darknodePayment) != address(0x0)) {
            darknodePayment.changeCycle();
        }

        // Emit an event
        emit LogNewEpoch(epochhash);
    }

    /// @notice Allows the contract owner to initiate an ownership transfer of
    /// the DarknodeRegistryStore.
    /// @param _newOwner The address to transfer the ownership to.
    function transferStoreOwnership(DarknodeRegistryLogicV1 _newOwner)
        external
        onlyOwner
    {
        store.transferOwnership(address(_newOwner));
        _newOwner.claimStoreOwnership();
    }

    /// @notice Claims ownership of the store passed in to the constructor.
    /// `transferStoreOwnership` must have previously been called when
    /// transferring from another Darknode Registry.
    function claimStoreOwnership() external {
        store.claimOwnership();

        // Sync state with new store.
        // Note: numDarknodesPreviousEpoch is set to 0 for a newly deployed DNR.
        (
            numDarknodesPreviousEpoch,
            numDarknodes,
            numDarknodesNextEpoch
        ) = getDarknodeCountFromEpochs();
    }

    /// @notice Allows the contract owner to update the address of the
    /// darknode payment contract.
    /// @param _darknodePayment The address of the Darknode Payment
    /// contract.
    function updateDarknodePayment(IDarknodePayment _darknodePayment)
        external
        onlyOwner
    {
        require(
            address(_darknodePayment) != address(0x0),
            "DarknodeRegistry: invalid Darknode Payment address"
        );
        IDarknodePayment previousDarknodePayment = darknodePayment;
        darknodePayment = _darknodePayment;
        emit LogDarknodePaymentUpdated(
            previousDarknodePayment,
            darknodePayment
        );
    }

    /// @notice Allows the contract owner to update the minimum bond.
    /// @param _nextMinimumBond The minimum bond amount that can be submitted by
    ///        a darknode.
    function updateMinimumBond(uint256 _nextMinimumBond) external onlyOwner {
        // Will be updated next epoch
        nextMinimumBond = _nextMinimumBond;
    }

    /// @notice Allows the contract owner to update the minimum pod size.
    /// @param _nextMinimumPodSize The minimum size of a pod.
    function updateMinimumPodSize(uint256 _nextMinimumPodSize)
        external
        onlyOwner
    {
        // Will be updated next epoch
        nextMinimumPodSize = _nextMinimumPodSize;
    }

    /// @notice Allows the contract owner to update the minimum epoch interval.
    /// @param _nextMinimumEpochInterval The minimum number of blocks between epochs.
    function updateMinimumEpochInterval(uint256 _nextMinimumEpochInterval)
        external
        onlyOwner
    {
        // Will be updated next epoch
        nextMinimumEpochInterval = _nextMinimumEpochInterval;
    }

    /// @notice Allow the contract owner to update the DarknodeSlasher contract
    /// address.
    /// @param _slasher The new slasher address.
    function updateSlasher(IDarknodeSlasher _slasher) external onlyOwner {
        require(
            address(_slasher) != address(0),
            "DarknodeRegistry: invalid slasher address"
        );
        nextSlasher = _slasher;
    }

    /// @notice Allow the DarknodeSlasher contract to slash a portion of darknode's
    ///         bond and deregister it.
    /// @param _guilty The guilty prover whose bond is being slashed.
    /// @param _challenger The challenger who should receive a portion of the bond as reward.
    /// @param _percentage The total percentage  of bond to be slashed.
    function slash(
        address _guilty,
        address _challenger,
        uint256 _percentage
    ) external onlySlasher onlyDarknode(_guilty) {
        require(_percentage <= 100, "DarknodeRegistry: invalid percent");

        // If the darknode has not been deregistered then deregister it
        if (isDeregisterable(_guilty)) {
            deregisterDarknode(_guilty);
        }

        uint256 totalBond = store.darknodeBond(_guilty);
        uint256 penalty = totalBond.div(100).mul(_percentage);
        uint256 challengerReward = penalty.div(2);
        uint256 darknodePaymentReward = penalty.sub(challengerReward);
        if (challengerReward > 0) {
            // Slash the bond of the failed prover
            store.updateDarknodeBond(_guilty, totalBond.sub(penalty));

            // Distribute the remaining bond into the darknode payment reward pool
            require(
                address(darknodePayment) != address(0x0),
                "DarknodeRegistry: invalid payment address"
            );
            require(
                ren.transfer(
                    address(darknodePayment.store()),
                    darknodePaymentReward
                ),
                "DarknodeRegistry: reward transfer failed"
            );
            require(
                ren.transfer(_challenger, challengerReward),
                "DarknodeRegistry: reward transfer failed"
            );
        }

        emit LogDarknodeSlashed(
            store.darknodeOperator(_guilty),
            _guilty,
            _challenger,
            _percentage
        );
    }

    /// @notice Refund the bond of a deregistered darknode. This will make the
    /// darknode available for registration again. Anyone can call this function
    /// but the bond will always be refunded to the darknode operator.
    ///
    /// @param _darknodeID The darknode ID that will be refunded.
    function refund(address _darknodeID) external onlyRefundable(_darknodeID) {
        address darknodeOperator = store.darknodeOperator(_darknodeID);

        // Remember the bond amount
        uint256 amount = store.darknodeBond(_darknodeID);

        // Erase the darknode from the registry
        store.removeDarknode(_darknodeID);

        // Refund the operator by transferring REN
        require(
            ren.transfer(darknodeOperator, amount),
            "DarknodeRegistry: bond transfer failed"
        );

        // Emit an event.
        emit LogDarknodeRefunded(darknodeOperator, _darknodeID, amount);
    }

    /// @notice Retrieves the address of the account that registered a darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the owner for.
    function getDarknodeOperator(address _darknodeID)
        external
        view
        returns (address payable)
    {
        return store.darknodeOperator(_darknodeID);
    }

    /// @notice Retrieves the bond amount of a darknode in 10^-18 REN.
    /// @param _darknodeID The ID of the darknode to retrieve the bond for.
    function getDarknodeBond(address _darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeBond(_darknodeID);
    }

    /// @notice Retrieves the encryption public key of the darknode.
    /// @param _darknodeID The ID of the darknode to retrieve the public key for.
    function getDarknodePublicKey(address _darknodeID)
        external
        view
        returns (bytes memory)
    {
        return store.darknodePublicKey(_darknodeID);
    }

    /// @notice Retrieves a list of darknodes which are registered for the
    /// current epoch.
    /// @param _start A darknode ID used as an offset for the list. If _start is
    ///        0x0, the first dark node will be used. _start won't be
    ///        included it is not registered for the epoch.
    /// @param _count The number of darknodes to retrieve starting from _start.
    ///        If _count is 0, all of the darknodes from _start are
    ///        retrieved. If _count is more than the remaining number of
    ///        registered darknodes, the rest of the list will contain
    ///        0x0s.
    function getDarknodes(address _start, uint256 _count)
        external
        view
        returns (address[] memory)
    {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }
        return getDarknodesFromEpochs(_start, count, false);
    }

    /// @notice Retrieves a list of darknodes which were registered for the
    /// previous epoch. See `getDarknodes` for the parameter documentation.
    function getPreviousDarknodes(address _start, uint256 _count)
        external
        view
        returns (address[] memory)
    {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodesPreviousEpoch;
        }
        return getDarknodesFromEpochs(_start, count, true);
    }

    /// @notice Returns whether a darknode is scheduled to become registered
    /// at next epoch.
    /// @param _darknodeID The ID of the darknode to return.
    function isPendingRegistration(address _darknodeID)
        public
        view
        returns (bool)
    {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        return registeredAt != 0 && registeredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the pending deregistered state. In
    /// this state a darknode is still considered registered.
    function isPendingDeregistration(address _darknodeID)
        public
        view
        returns (bool)
    {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt > currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode is in the deregistered state.
    function isDeregistered(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt <= currentEpoch.blocktime;
    }

    /// @notice Returns if a darknode can be deregistered. This is true if the
    /// darknodes is in the registered state and has not attempted to
    /// deregister yet.
    function isDeregisterable(address _darknodeID) public view returns (bool) {
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        // The Darknode is currently in the registered state and has not been
        // transitioned to the pending deregistration, or deregistered, state
        return isRegistered(_darknodeID) && deregisteredAt == 0;
    }

    /// @notice Returns if a darknode is in the refunded state. This is true
    /// for darknodes that have never been registered, or darknodes that have
    /// been deregistered and refunded.
    function isRefunded(address _darknodeID) public view returns (bool) {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return registeredAt == 0 && deregisteredAt == 0;
    }

    /// @notice Returns if a darknode is refundable. This is true for darknodes
    /// that have been in the deregistered state for one full epoch.
    function isRefundable(address _darknodeID) public view returns (bool) {
        return
            isDeregistered(_darknodeID) &&
            store.darknodeDeregisteredAt(_darknodeID) <=
            (previousEpoch.blocktime - deregistrationInterval);
    }

    /// @notice Returns the registration time of a given darknode.
    function darknodeRegisteredAt(address darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeRegisteredAt(darknodeID);
    }

    /// @notice Returns the deregistration time of a given darknode.
    function darknodeDeregisteredAt(address darknodeID)
        external
        view
        returns (uint256)
    {
        return store.darknodeDeregisteredAt(darknodeID);
    }

    /// @notice Returns if a darknode is in the registered state.
    function isRegistered(address _darknodeID) public view returns (bool) {
        return isRegisteredInEpoch(_darknodeID, currentEpoch);
    }

    /// @notice Returns if a darknode was in the registered state last epoch.
    function isRegisteredInPreviousEpoch(address _darknodeID)
        public
        view
        returns (bool)
    {
        return isRegisteredInEpoch(_darknodeID, previousEpoch);
    }

    /// @notice Returns if a darknode was in the registered state for a given
    /// epoch.
    /// @param _darknodeID The ID of the darknode.
    /// @param _epoch One of currentEpoch, previousEpoch.
    function isRegisteredInEpoch(address _darknodeID, Epoch memory _epoch)
        private
        view
        returns (bool)
    {
        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        bool registered = registeredAt != 0 && registeredAt <= _epoch.blocktime;
        bool notDeregistered = deregisteredAt == 0 ||
            deregisteredAt > _epoch.blocktime;
        // The Darknode has been registered and has not yet been deregistered,
        // although it might be pending deregistration
        return registered && notDeregistered;
    }

    /// @notice Returns a list of darknodes registered for either the current
    /// or the previous epoch. See `getDarknodes` for documentation on the
    /// parameters `_start` and `_count`.
    /// @param _usePreviousEpoch If true, use the previous epoch, otherwise use
    ///        the current epoch.
    function getDarknodesFromEpochs(
        address _start,
        uint256 _count,
        bool _usePreviousEpoch
    ) private view returns (address[] memory) {
        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }

        address[] memory nodes = new address[](count);

        // Begin with the first node in the list
        uint256 n = 0;
        address next = _start;
        if (next == address(0)) {
            next = store.begin();
        }

        // Iterate until all registered Darknodes have been collected
        while (n < count) {
            if (next == address(0)) {
                break;
            }
            // Only include Darknodes that are currently registered
            bool includeNext;
            if (_usePreviousEpoch) {
                includeNext = isRegisteredInPreviousEpoch(next);
            } else {
                includeNext = isRegistered(next);
            }
            if (!includeNext) {
                next = store.next(next);
                continue;
            }
            nodes[n] = next;
            next = store.next(next);
            n += 1;
        }
        return nodes;
    }

    /// Private function called by `deregister` and `slash`
    function deregisterDarknode(address _darknodeID) private {
        address darknodeOperator = store.darknodeOperator(_darknodeID);

        // Flag the darknode for deregistration
        store.updateDarknodeDeregisteredAt(
            _darknodeID,
            currentEpoch.blocktime.add(minimumEpochInterval)
        );
        numDarknodesNextEpoch = numDarknodesNextEpoch.sub(1);

        // Emit an event
        emit LogDarknodeDeregistered(darknodeOperator, _darknodeID);
    }

    function getDarknodeCountFromEpochs()
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        // Begin with the first node in the list
        uint256 nPreviousEpoch = 0;
        uint256 nCurrentEpoch = 0;
        uint256 nNextEpoch = 0;
        address next = store.begin();

        // Iterate until all registered Darknodes have been collected
        while (true) {
            // End of darknode list.
            if (next == address(0)) {
                break;
            }

            if (isRegisteredInPreviousEpoch(next)) {
                nPreviousEpoch += 1;
            }

            if (isRegistered(next)) {
                nCurrentEpoch += 1;
            }

            // Darknode is registered and has not deregistered, or is pending
            // becoming registered.
            if (
                ((isRegistered(next) && !isPendingDeregistration(next)) ||
                    isPendingRegistration(next))
            ) {
                nNextEpoch += 1;
            }
            next = store.next(next);
        }
        return (nPreviousEpoch, nCurrentEpoch, nNextEpoch);
    }
}






pragma solidity ^0.5.0;

//import './BaseAdminUpgradeabilityProxy.sol';
//import './InitializableUpgradeabilityProxy.sol';

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
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}






pragma solidity 0.5.17;

//import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Pausable.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Burnable.sol";

contract RenToken is Ownable, ERC20Detailed, ERC20Pausable, ERC20Burnable {
    string private constant _name = "REN";
    string private constant _symbol = "REN";
    uint8 private constant _decimals = 18;

    uint256 public constant INITIAL_SUPPLY =
        1000000000 * 10**uint256(_decimals);

    /// @notice The RenToken Constructor.
    constructor() public {
        ERC20Pausable.initialize(msg.sender);
        ERC20Detailed.initialize(_name, _symbol, _decimals);
        Ownable.initialize(msg.sender);
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function transferTokens(address beneficiary, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        // Note: The deployed version has no revert reason
        /* solium-disable-next-line error-reason */
        require(amount > 0);

        _transfer(msg.sender, beneficiary, amount);
        emit Transfer(msg.sender, beneficiary, amount);

        return true;
    }
}






/* solium-disable-next-line no-empty-blocks */
contract DarknodeRegistryProxy is InitializableAdminUpgradeabilityProxy {

}
