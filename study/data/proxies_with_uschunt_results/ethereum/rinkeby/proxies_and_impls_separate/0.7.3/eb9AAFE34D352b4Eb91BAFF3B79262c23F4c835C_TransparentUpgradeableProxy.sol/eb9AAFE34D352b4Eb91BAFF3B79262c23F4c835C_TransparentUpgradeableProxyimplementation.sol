// : MIT

pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;



// Part: IPubSubMgr

interface IPubSubMgr {
    function publish(bytes32 topic, bytes calldata data) external;
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/AddressUpgradeable

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/EnumerableSetUpgradeable

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
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
    function _remove(Set storage set, bytes32 value) private returns (bool) {
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

            bytes32 lastvalue = set._values[lastIndex];

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
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
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
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
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
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
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
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/IERC165Upgradeable

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/IERC20Upgradeable

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/IERC721ReceiverUpgradeable

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/SafeMathUpgradeable

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
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/IERC721Upgradeable

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/Initializable

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
        return !AddressUpgradeable.isContract(address(this));
    }
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/SafeERC20Upgradeable

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// Part: OpenZeppelin/openzeppelin-contracts-upgradeable@3.4.0-solc-0.7/ReentrancyGuardUpgradeable

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// File: Broker.sol

contract Broker is
    Initializable,
    IERC721ReceiverUpgradeable,
    ReentrancyGuardUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;

    enum OrderStatus {NONEXIST, LISTED, MORTGAGED, CLEARING, CLAIMABLE}

    ///@notice Lender detail
    ///@param price lender offer price
    ///@param interest lender offer interest
    struct LenderDetail {
        uint256 price;
        uint256 interest;
    }

    ///@notice Vendee detail
    ///@param vendee vendee address
    ///@param price vendee offer price
    struct VendeeDetail {
        address vendee;
        uint256 price;
    }

    ///@notice Order detail
    struct OrderDetail {
        address pledger;
        address lender;
        uint256 price;
        uint256 interest;
        uint256 duration;
        uint256 dealTime;
        OrderStatus status;
        VendeeDetail vendee;
        EnumerableSetUpgradeable.AddressSet lendersAddress;
        mapping(address => LenderDetail) lenders;
    }

    uint256 public constant MAX_REPAY_INTEREST_CUT = 1000;

    ///@notice usdxc token
    address public usdxc;

    ///@notice admin
    address public admin;

    ///@notice platform beneficiary address
    address public beneficiary;

    ///@notice Redemption time period
    uint256 public redemptionPeriod;

    ///@notice clearing time period
    uint256 public clearingPeriod;

    ///@notice Repay interest platform commission（base 1000）
    uint256 public repayInterestCut;

    ///@notice Auction interest pledger commission
    uint256 public auctionPledgerCut;

    ///@notice Auction interest platform commission
    uint256 public auctionDevCut;

    ///@dev Order details list
    mapping(address => mapping(uint256 => OrderDetail)) orders;

    ///@notice To prevent malicious attacks, the maximum number of lenderAddresses for each NFT. After exceeding the maximum threshold, lenderOffer is not allowed, and 0 means no limit
    mapping(address => mapping(uint256 => uint256)) public maxLendersCnt;
    ///@notice The default value of the maximum number of lenderAddresses per NFT.
    uint256 public defaultMaxLendersCnt;

    address public pendingBeneficiary;

    uint256 public MAX_REPAY_INTEREST_PLATFORM_CUT = 200;

    uint256 public MAX_AUCTION_PLEDGER_CUT = 50;
    uint256 public MAX_AUCTION_PLATFORM_CUT = 200;

    // pubSubMgr contract
    address public pubSubMgr;

    ///@notice pledger maker order
    event Pledged(
        address nftAddress,
        uint256 tokenId,
        address pledger,
        uint256 price,
        uint256 interest,
        uint256 duration
    );

    ///@notice pledger cancel order
    event PledgeCanceled(
        address nftAddress,
        uint256 tokenId,
        address pledger,
        address[] lenders
    );

    ///@notice pledger taker order
    event PledgerDealed(
        address nftAddress,
        uint256 tokenId,
        address pledger,
        address lender,
        uint256 price,
        uint256 interest,
        uint256 duration,
        uint256 dealTime,
        address[] unsettledLenders
    );

    ///@notice pledger repay debt
    event PledgerRepaid(
        address nftAddress,
        uint256 tokenId,
        address pledger,
        address lender,
        uint256 cost,
        uint256 devCommission
    );

    ///@notice lender lenderOffer
    event LenderOffered(
        address nftAddress,
        uint256 tokenId,
        address pledger,
        address lender,
        uint256 price,
        uint256 interest
    );

    ///@notice lender lenderCancelOffer
    event LenderOfferCanceled(
        address nftAddress,
        uint256 tokenId,
        address lender
    );

    ///@notice lender lenderDeal
    event LenderDealed(
        address nftAddress,
        uint256 tokenId,
        address lender,
        uint256 dealTime
    );

    ///@notice aution
    event Auctioned(
        address nftAddress,
        uint256 tokenId,
        address vendee,
        uint256 price,
        address previousVendee,
        uint256 previousPrice
    );

    ///@notice After the auction is completed, the winner will withdraw nft (if no one responds, the original lender will withdraw it)
    event Claimed(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address taker
    );

    event SetRedemptionPeriod(uint256 _period);
    event SetClearingPeriod(uint256 _period);
    event SetRepayInterestCut(uint256 _cut);
    event SetAuctionCut(uint256 _pledgerCut, uint256 _devCut);

    event ProposeBeneficiary(address _pendingBeneficiary);
    event ClaimBeneficiary(address beneficiary);

    event SetMaxLendersCnt(
        address nftAddress,
        uint256 tokenId,
        uint256 _maxLendersCnt
    );

    event SetDefaultMaxLendersCnt(
        uint256 _defaultMaxLendersCnt
    );

    modifier onlyBeneficiary {
        require(msg.sender == beneficiary, "Beneficiary required");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == admin, "Admin required");
        _;
    }

    ///@notice initialize
    function initialize(
        address _usdxc,
        address _beneficiary,
        uint256 _redemptionPeriod,
        uint256 _clearingPeriod,
        uint256 _repayInterestCut,
        uint256 _auctionPledgerCut,
        uint256 _auctionDevCut
    ) external initializer {
        require(_usdxc != address(0), "_usdxc is zero address");
        require(_beneficiary != address(0), "_beneficiary is zero address");
        __ReentrancyGuard_init();
        admin = msg.sender;
        usdxc = _usdxc;
        beneficiary = _beneficiary;
        redemptionPeriod = _redemptionPeriod;
        clearingPeriod = _clearingPeriod;
        repayInterestCut = _repayInterestCut;
        auctionPledgerCut = _auctionPledgerCut;
        auctionDevCut = _auctionDevCut;
    }

    ///@notice nft pledger make order
    ///@param nftAddress NFT address
    ///@param tokenId tokenId
    ///@param price price
    ///@param interest interest
    ///@param duration duration
    function pledge(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 interest,
        uint256 duration
    ) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.NONEXIST,
            "Invalid NFT status"
        );
        require(price > 0, "Invalid price");

        OrderDetail storage detail = orders[nftAddress][tokenId];
        detail.pledger = msg.sender;
        detail.price = price;
        detail.interest = interest;
        detail.duration = duration;
        detail.status = OrderStatus.LISTED;

        IERC721Upgradeable(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        emit Pledged(
            nftAddress,
            tokenId,
            msg.sender,
            price,
            interest,
            duration
        );
    }

    ///@notice nft pledger cancle order
    function cancelPledge(address nftAddress, uint256 tokenId)
        external
        nonReentrant
    {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.LISTED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(detail.pledger == msg.sender, "Auth failed");

        address[] memory _lenders =
            new address[](detail.lendersAddress.length());

        for (uint256 i = 0; i < detail.lendersAddress.length(); ++i) {
            // give back lenders their token
            address _lender = detail.lendersAddress.at(i);
            uint256 _lenderPrice = detail.lenders[_lender].price;
            _lenders[i] = _lender;
            IERC20Upgradeable(usdxc).safeTransfer(_lender, _lenderPrice);
            // delete detail.lenders[_lender];
        }
        for (uint256 i = 0; i < _lenders.length; ++i) {
            detail.lendersAddress.remove(_lenders[i]);
            delete detail.lenders[_lenders[i]];
        }
        delete orders[nftAddress][tokenId];

        IERC721Upgradeable(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit PledgeCanceled(nftAddress, tokenId, msg.sender, _lenders);
    }

    ///@notice nft The pledger chooses a suitable lender and completes the order
    function pledgerDeal(
        address nftAddress,
        uint256 tokenId,
        address lender,
        uint256 price,
        uint256 interest
    ) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.LISTED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(detail.pledger == msg.sender, "Auth failed");
        require(detail.lendersAddress.contains(lender), "Invalid lender");

        LenderDetail memory _lenderDetail = detail.lenders[lender];
        require(
            price == _lenderDetail.price && interest == _lenderDetail.interest,
            "Invalid price"
        );
        address[] memory _unsettledLenders =
            new address[](detail.lendersAddress.length());
        uint256 _unsettledLendersCount = 0;

        uint256 n = detail.lendersAddress.length();
        for (uint256 i = 0; i < n; ++i) {
            // transfer token of picked lender to pledger
            // transfer others' back
            address _lender = detail.lendersAddress.at(i);
            uint256 _lenderPrice = detail.lenders[_lender].price;
            if (_lender == lender) {
                IERC20Upgradeable(usdxc).safeTransfer(msg.sender, _lenderPrice);
            } else {
                _unsettledLenders[_unsettledLendersCount] = _lender;
                _unsettledLendersCount++;
                IERC20Upgradeable(usdxc).safeTransfer(_lender, _lenderPrice);
            }
            delete detail.lenders[_lender];
        }

        for (uint256 i = 0; i < n; ++i) {
            detail.lendersAddress.remove(detail.lendersAddress.at(0));
        }

        delete detail.lendersAddress;

        detail.lender = lender;
        detail.price = _lenderDetail.price;
        detail.interest = _lenderDetail.interest;
        detail.dealTime = block.timestamp;
        detail.status = OrderStatus.MORTGAGED;

        IPubSubMgr(pubSubMgr).publish(keccak256("deposit"), abi.encode(nftAddress, tokenId, msg.sender, lender, price, detail.duration));

        emit PledgerDealed(
            nftAddress,
            tokenId,
            msg.sender,
            lender,
            detail.price,
            detail.interest,
            detail.duration,
            detail.dealTime,
            _unsettledLenders
        );
    }

    ///@notice nft pledger repay debt
    function pledgerRepay(address nftAddress, uint256 tokenId)
        external
        nonReentrant
    {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.MORTGAGED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(detail.pledger == msg.sender, "Auth failed");

        uint256 _price = detail.price;
        uint256 _cost = _price.add(detail.interest);
        uint256 _devCommission =
            detail.interest.mul(repayInterestCut).div(MAX_REPAY_INTEREST_CUT);
        address _lender = detail.lender;
        delete orders[nftAddress][tokenId];

        IERC721Upgradeable(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        IERC20Upgradeable(usdxc).safeTransferFrom(
            msg.sender,
            beneficiary,
            _devCommission
        );
        IERC20Upgradeable(usdxc).safeTransferFrom(
            msg.sender,
            _lender,
            _cost.sub(_devCommission)
        );

        IPubSubMgr(pubSubMgr).publish(keccak256("withdraw"), abi.encode(nftAddress, tokenId, msg.sender, _lender, _price));

        emit PledgerRepaid(
            nftAddress,
            tokenId,
            msg.sender,
            _lender,
            _cost,
            _devCommission
        );
    }

    ///@notice lender makes offer
    ///@param nftAddress nft address
    ///@param tokenId tokenId
    ///@param price price
    ///@param interest interest
    function lenderOffer(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 interest
    ) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.LISTED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(!detail.lendersAddress.contains(msg.sender), "Already offered");
        require(price > 0, "Invalid price");
        uint256 n = detail.lendersAddress.length();
        require(maxLendersCnt[nftAddress][tokenId] == 0 || n < maxLendersCnt[nftAddress][tokenId], "exeed max lenders cnt");
        require(defaultMaxLendersCnt == 0 || n < defaultMaxLendersCnt, "exceed default max lenders cnt");

        detail.lendersAddress.add(msg.sender);
        detail.lenders[msg.sender] = LenderDetail({
            price: price,
            interest: interest
        });
        IERC20Upgradeable(usdxc).safeTransferFrom(
            msg.sender,
            address(this),
            price
        );

        emit LenderOffered(
            nftAddress,
            tokenId,
            detail.pledger,
            msg.sender,
            price,
            interest
        );
    }

    // lender cancle order
    function lenderCancelOffer(address nftAddress, uint256 tokenId)
        external
        nonReentrant
    {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.LISTED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(detail.lendersAddress.contains(msg.sender), "No offer");

        LenderDetail memory _lenderDetail = detail.lenders[msg.sender];
        delete detail.lenders[msg.sender];
        detail.lendersAddress.remove(msg.sender);
        IERC20Upgradeable(usdxc).safeTransfer(msg.sender, _lenderDetail.price);

        emit LenderOfferCanceled(nftAddress, tokenId, msg.sender);
    }

    // lender 成单
    function lenderDeal(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 interest
    ) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.LISTED,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(
            price == detail.price && interest == detail.interest,
            "Invalid price"
        );

        uint256 n = detail.lendersAddress.length();
        for (uint256 i = 0; i < n; ++i) {
            // transfer token of picked lender to pledger
            // transfer others' back
            address _lender = detail.lendersAddress.at(i);
            uint256 _lenderPrice = detail.lenders[_lender].price;
            IERC20Upgradeable(usdxc).safeTransfer(_lender, _lenderPrice);
            delete detail.lenders[_lender];
        }

        for (uint i = 0; i < n; ++i) {
            detail.lendersAddress.remove(detail.lendersAddress.at(0));
        }

        delete detail.lendersAddress;

        detail.lender = msg.sender;
        detail.dealTime = block.timestamp;
        detail.status = OrderStatus.MORTGAGED;

        IERC20Upgradeable(usdxc).safeTransferFrom(
            msg.sender,
            detail.pledger,
            detail.price
        );

        IPubSubMgr(pubSubMgr).publish(keccak256("deposit"), abi.encode(nftAddress, tokenId, detail.pledger, msg.sender, price, detail.duration));
        emit LenderDealed(nftAddress, tokenId, msg.sender, block.timestamp);
    }

    ///@notice auction
    function auction(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.CLEARING,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        require(msg.sender != detail.pledger, "Cannot auction self");
        require(price > detail.price.add(detail.interest), "Invalid price");
        uint256 previousPrice = detail.vendee.price;
        require(price > previousPrice, "Price too low");

        address previousVendee = detail.vendee.vendee;

        detail.vendee.vendee = msg.sender;
        detail.vendee.price = price;

        if (previousVendee != address(0)) {
            IERC20Upgradeable(usdxc).safeTransfer(
                previousVendee,
                previousPrice
            );
        }
        IERC20Upgradeable(usdxc).safeTransferFrom(
            msg.sender,
            address(this),
            price
        );

        emit Auctioned(
            nftAddress,
            tokenId,
            msg.sender,
            price,
            previousVendee,
            previousPrice
        );
    }

    ///@notice Distributed after the auction phase is over
    ///@param nftAddress nft address
    ///@param tokenId token id
    function claim(address nftAddress, uint256 tokenId) external nonReentrant {
        require(
            getNftStatus(nftAddress, tokenId) == OrderStatus.CLAIMABLE,
            "Invalid NFT status"
        );
        OrderDetail storage detail = orders[nftAddress][tokenId];
        address vendee = detail.vendee.vendee;
        address lender = detail.lender;
        if (vendee != address(0)) {
            // When there is an auctioneer, distribute the auctioneer’s token
            uint256 _price = detail.vendee.price;
            uint256 _profit = _price.sub(detail.price).sub(detail.interest);
            uint256 _beneficiaryCommissionOfInterest =
                detail.interest.mul(repayInterestCut).div(
                    MAX_REPAY_INTEREST_CUT
                );
            uint256 _beneficiaryCommissionOfProfit =
                _profit.mul(auctionDevCut).div(MAX_REPAY_INTEREST_CUT);
            uint256 _beneficiaryCommission =
                _beneficiaryCommissionOfInterest.add(
                    _beneficiaryCommissionOfProfit
                );
            uint256 _pledgerCommissionOfProfit =
                _profit.mul(auctionPledgerCut).div(MAX_REPAY_INTEREST_CUT);

            IERC20Upgradeable(usdxc).safeTransfer(
                detail.pledger,
                _pledgerCommissionOfProfit
            );
            IERC20Upgradeable(usdxc).safeTransfer(
                beneficiary,
                _beneficiaryCommission
            );
            IERC20Upgradeable(usdxc).safeTransfer(
                lender,
                _price.sub(_beneficiaryCommission).sub(
                    _pledgerCommissionOfProfit
                )
            );
            IERC721Upgradeable(nftAddress).safeTransferFrom(
                address(this),
                vendee,
                tokenId
            );
            emit Claimed(nftAddress, tokenId, _price, vendee);
        } else {
            // When there is no auctioneer, transfer nft
            IERC721Upgradeable(nftAddress).safeTransferFrom(
                address(this),
                lender,
                tokenId
            );
            emit Claimed(nftAddress, tokenId, 0, lender);
        }
        IPubSubMgr(pubSubMgr).publish(keccak256("withdraw"), abi.encode(nftAddress, tokenId, detail.pledger, lender, detail.price));

        delete orders[nftAddress][tokenId];
    }

    ///@notice Get NFT status in the market
    function getNftStatus(address nftAddress, uint256 tokenId)
        public
        view
        returns (OrderStatus)
    {
        OrderDetail storage detail = orders[nftAddress][tokenId];
        if (detail.pledger == address(0)) {
            return OrderStatus.NONEXIST;
        }
        if (detail.lender == address(0)) {
            return OrderStatus.LISTED;
        }
        // todo Change the order to reduce gas?
        if (
            block.timestamp >
            detail.dealTime.add(detail.duration).add(redemptionPeriod).add(
                clearingPeriod
            )
        ) {
            return OrderStatus.CLAIMABLE;
        }
        if (
            block.timestamp >
            detail.dealTime.add(detail.duration).add(redemptionPeriod)
        ) {
            return OrderStatus.CLEARING;
        }
        return OrderStatus.MORTGAGED;
    }

    function lenderOfferInfo(
        address nftAddress,
        uint256 tokenId,
        address user
    ) external view returns (uint256, uint256) {
        OrderDetail storage detail = orders[nftAddress][tokenId];
        // detail.lendersAddress
        for (uint256 i = 0; i < detail.lendersAddress.length(); ++i) {
            if (detail.lendersAddress.at(i) == user) {
                return (
                    detail.lenders[user].price,
                    detail.lenders[user].interest
                );
            }
        }
    }

    function t1(
        address nftAddress,
        uint256 tokenId
    ) external view returns (uint256) {
        OrderDetail storage detail = orders[nftAddress][tokenId];
        return detail.lendersAddress.length();
    }

    function t2(
        address nftAddress,
        uint256 tokenId,
        uint256 index
    ) external view returns (address) {
        OrderDetail storage detail = orders[nftAddress][tokenId];
        return detail.lendersAddress.at(index);
    }

    ///@notice set redemption period
    ///@param _period new redemption period
    function setRedemptionPeriod(uint256 _period) external onlyOwner {
        redemptionPeriod = _period;

        emit SetRedemptionPeriod(_period);
    }

    ///@notice set clearing period
    ///@param _period new clearing period
    function setClearingPeriod(uint256 _period) external onlyOwner {
        clearingPeriod = _period;

        emit SetClearingPeriod(_period);
    }

    ///@notice set repay interest cut
    ///@param _cut new repay interest cut
    function setRepayInterestCut(uint256 _cut) external onlyOwner {
        require(_cut <= MAX_REPAY_INTEREST_PLATFORM_CUT, "Invalid repay interest platform cut");
        repayInterestCut = _cut;

        emit SetRepayInterestCut(_cut);
    }

    function setAuctionCut(uint256 _pledgerCut, uint256 _devCut)
        external
        onlyOwner
    {
        require(
            _pledgerCut.add(_devCut) < MAX_REPAY_INTEREST_CUT,
            "Invalid cut"
        );

        require(
            _pledgerCut <= MAX_AUCTION_PLEDGER_CUT,
            "Invalid auction pledger cut"
        );

        require(
            _devCut <= MAX_AUCTION_PLATFORM_CUT,
            "Invalid auction platform cut"
        );
        auctionPledgerCut = _pledgerCut;
        auctionDevCut = _devCut;

        emit SetAuctionCut(_pledgerCut, _devCut);
    }

    function proposeBeneficiary(address _pendingBeneficiary) external onlyBeneficiary {
        require(_pendingBeneficiary != address(0), "_pendingBeneficiary is zero address");
        pendingBeneficiary = _pendingBeneficiary;

        emit ProposeBeneficiary(_pendingBeneficiary);
    }


    function claimBeneficiary() external {
        require(msg.sender == pendingBeneficiary, "msg.sender is not pendingBeneficiary");
        beneficiary = pendingBeneficiary;
        pendingBeneficiary = address(0);

        emit ClaimBeneficiary(beneficiary);
    }

    ///@notice Set the maximum number of lenders
    ///@param _maxLendersCnt new maximum number of lenders
    function setMaxLendersCnt(address nftAddress, uint256 tokenId, uint256 _maxLendersCnt) external onlyOwner {
        maxLendersCnt[nftAddress][tokenId] = _maxLendersCnt;
        emit SetMaxLendersCnt(nftAddress, tokenId, _maxLendersCnt);
    }

    ///@notice Set the default maximum lenders amount
    ///@param _defaultMaxLendersCnt new default maximum lenders amount
    function setDefaultMaxLendersCnt(uint256 _defaultMaxLendersCnt) external onlyOwner {
        defaultMaxLendersCnt = _defaultMaxLendersCnt;
        emit SetDefaultMaxLendersCnt(_defaultMaxLendersCnt);
    }

    function setPubSubMgr(address _pubSubMgr) external onlyOwner {
        pubSubMgr = _pubSubMgr;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
