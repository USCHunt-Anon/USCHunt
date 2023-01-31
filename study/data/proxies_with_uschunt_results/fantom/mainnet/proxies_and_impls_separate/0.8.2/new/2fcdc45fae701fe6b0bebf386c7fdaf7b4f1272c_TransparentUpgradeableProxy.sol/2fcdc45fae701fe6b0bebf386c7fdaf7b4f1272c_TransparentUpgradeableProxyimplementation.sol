/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [////IMPORTANT]
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
     * ////IMPORTANT: because control is transferred to `recipient`, care must be
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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

// solhint-disable-next-line compiler-version
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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;
//////import"../proxy/utils/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"./IERC165Upgradeable.sol";
//////import"../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant alphabet = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"../utils/ContextUpgradeable.sol";
//////import"../utils/StringsUpgradeable.sol";
//////import"../utils/introspection/ERC165Upgradeable.sol";
//////import"../proxy/utils/Initializable.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                StringsUpgradeable.toHexString(uint160(account), 20),
                " is missing role ",
                StringsUpgradeable.toHexString(uint256(role), 32)
            )));
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"../IERC20.sol";
//////import"../../../utils/Address.sol";

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;
//////import"../proxy/utils/Initializable.sol";

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




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"../utils/ContextUpgradeable.sol";
//////import"../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}




/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;

//////import"./AccessControlUpgradeable.sol";
//////import"../utils/structs/EnumerableSetUpgradeable.sol";
//////import"../proxy/utils/Initializable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping (bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
    uint256[49] private __gap;
}


/** 
 *  SourceUnit: c:\Projects\fiberblock\smart-contracts\contracts\game\AsteroidGame.sol
*/

////// -FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

//////import"@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
//////import"@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
//////import"@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

//////import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//////import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AsteroidGame is AccessControlEnumerableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    uint256 public constant HUNDRED_PERCENT = 10000; // 100%

    uint256 public constant ASTEROID_MOVING = 1;
    uint256 public constant ASTEROID_COLLIDED = 2;
    uint256 public constant ASTEROID_EXPLODED = 3;

    event TreasuryUpdated(address treasury);

    event RoomCreated(uint256 roomId, address token, uint256 searchFee, uint256 totalPrizes, uint256 winnerRewardPercent, uint256 ownerRewardPercent);
    event RoomUpdated(uint256 roomId, address token, uint256 searchFee, uint256 totalPrizes, uint256 winnerRewardPercent, uint256 ownerRewardPercent);
    event RoomStatusUpdated(uint256 roomId, bool status);

    event RocketUpdated(uint256 roomId, uint256 rocketId, uint256 delayTime, uint256 price);

    event AsteroidNotFound(uint256 roomId, uint256 asteroidId, address user, uint256 searchFee);
    event AsteroidFound(uint256 roomId, uint256 asteroidId, address user, uint256 searchFee);
    event AsteroidCreated(uint256 roomId, uint256 asteroidId, address user, uint256 reward);
    event AsteroidExploded(uint256 roomId, uint256 asteroidId);

    event Shoot(uint256 roomId, uint256 asteroidId, uint256 rocketId, address user, uint256 rocketPrice, uint256 delayTime);

    event RewardAdded(uint256 roomId, uint256 asteroidId, address user, uint256 amount);
    event RewardClaimed(uint256 roomId, uint256 asteroidId, address user, uint256 amount);

    struct Room {
        IERC20 token;
        uint256 currentAsteroid;
        uint256 searchFee;
        bool enable;
        uint256 totalPrizes;
        uint256 winnerRewardPercent;
        uint256 ownerRewardPercent;
    }

    struct Asteroid {
        address owner;
        uint256 reward;         // wei
        uint256 collisionAt;    // second
        uint256 status;
        uint256 totalPrizes;
        uint256 winnerRewardPercent;
        uint256 ownerRewardPercent;
        uint256 shootingWeight;
        uint256 searchingWeight;
    }

    struct Rocket {
        uint256 delayTime;      // second
        uint256 price;          // wei
    }

    struct Shooting {
        address account;
        uint256 rocketId;
        uint256 delayTime;
        uint256 rocketPrice;
    }

    // room id => room information
    mapping(uint256 => Room) public rooms;

    // room id => asteroid id => asteroid information
    mapping(uint256 => mapping(uint256 => Asteroid)) public asteroids;

    // room id => rocket id => rocket information
    mapping(uint256 => mapping(uint256 => Rocket)) public rockets;

    // room id => asteroid id => user address => true value if is player
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public isPlayer;

    // room id => asteroid id => array of shooting information
    mapping(uint256 => mapping(uint256 => Shooting[])) private _shootings;

    // room id => asteroid id => array of user address
    mapping(uint256 => mapping(uint256 => address[])) private _winners;

    // room id => asteroid id => total players
    mapping(uint256 => mapping(uint256 => uint256)) public totalPlayers;

    // room id => asteroid id => user address => true value if reward was claimed
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public isClaimed;

    uint256 public totalRooms;

    address public treasury;

    uint256 public minLifeTime;
    uint256 public maxLifeTime;
    uint256 public minSearchingWeight;
    uint256 public maxSearchingWeight;
    uint256 public searchingRatio;
    uint256 public minShootingWeight;
    uint256 public maxShootingWeight;
    uint256 public shootingRatio;

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "AsteroidGame: caller is not admin");
        _;
    }

    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "AsteroidGame: caller is not operator");
        _;
    }

    modifier roomExists(uint256 roomId) {
        require(address(rooms[roomId].token) != address(0), "AsteroidGame: room does not exist");
        _;
    }

    modifier roomActive(uint256 roomId) {
        require(rooms[roomId].enable, "AsteroidGame: room was disabled");
        _;
    }

    function initialize()
        external
        initializer
    {
        __AccessControlEnumerable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        address msgSender = _msgSender();

        _setupRole(DEFAULT_ADMIN_ROLE, msgSender);
        _setupRole(OPERATOR_ROLE, msgSender);

        treasury = msgSender;

        minLifeTime = 1800; // 30 minutes
        maxLifeTime = 3600; // 60 minutes

        minSearchingWeight = 2000;
        maxSearchingWeight = 4000;
        searchingRatio = 1;

        minShootingWeight = 2000;
        maxShootingWeight = 4000;
        shootingRatio = 1;
    }

    function setTreasury(address _addr)
        external
        onlyAdmin
    {
        require(_addr != address(0), "AsteroidGame: address is invalid");

        treasury = _addr;

        emit TreasuryUpdated(_addr);
    }

    function setConfig(
        uint256 _minLifeTime,
        uint256 _maxLifeTime,
        uint256 _minSearchingWeight,
        uint256 _maxSearchingWeight,
        uint256 _searchingRatio,
        uint256 _minShootingWeight,
        uint256 _maxShootingWeight,
        uint256 _shootingRatio
    )
        external
        onlyOperator
    {
        require(_minLifeTime > 0 && _minLifeTime < _maxLifeTime, "AsteroidGame: time is invalid");

        require(_minSearchingWeight < _maxSearchingWeight && _maxSearchingWeight <= HUNDRED_PERCENT, "AsteroidGame: searching weight is invalid");

        require(_minShootingWeight < _maxShootingWeight && _maxShootingWeight <= HUNDRED_PERCENT, "AsteroidGame: shooting weight is invalid");

        if (minLifeTime != _minLifeTime) {
            minLifeTime = _minLifeTime;
        }

        if (maxLifeTime != _maxLifeTime) {
            maxLifeTime = _maxLifeTime;
        }

        if (minSearchingWeight != _minSearchingWeight) {
            minSearchingWeight = _minSearchingWeight;
        }

        if (maxSearchingWeight != _maxSearchingWeight) {
            maxSearchingWeight = _maxSearchingWeight;
        }

        if (searchingRatio != _searchingRatio) {
            searchingRatio = _searchingRatio;
        }

        if (minShootingWeight != _minShootingWeight) {
            minShootingWeight = _minShootingWeight;
        }

        if (maxShootingWeight != _maxShootingWeight) {
            maxShootingWeight = _maxShootingWeight;
        }

        if (shootingRatio != _shootingRatio) {
            shootingRatio = _shootingRatio;
        }
    }

    function pause()
        external
        onlyOperator
    {
        _pause();
    }

    function unpause()
        external
        onlyOperator
    {
        _unpause();
    }

    function createRoom(address _token, uint256 _searchFee, uint256 _totalPrizes, uint256 _winnerRewardPercent, uint256 _ownerRewardPercent)
        external
        onlyOperator
    {
        require(_token != address(0), "AsteroidGame: address is invalid");

        require(_searchFee > 0, "AsteroidGame: search fee is invalid");

        require(_totalPrizes > 0, "AsteroidGame: total prizes is invalid");

        require(_winnerRewardPercent + _ownerRewardPercent <= HUNDRED_PERCENT, "AsteroidGame: percent is invalid");

        uint256 roomId = ++totalRooms;

        rooms[roomId] = Room(IERC20(_token), 1, _searchFee, true, _totalPrizes, _winnerRewardPercent, _ownerRewardPercent);

        emit RoomCreated(roomId, _token, _searchFee, _totalPrizes, _winnerRewardPercent, _ownerRewardPercent);
    }

    function updateRoom(uint256 _roomId, address _token, uint256 _searchFee, uint256 _totalPrizes, uint256 _winnerRewardPercent, uint256 _ownerRewardPercent)
        external
        onlyOperator
        roomExists(_roomId)
    {
        require(_token != address(0), "AsteroidGame: address is invalid");

        require(_searchFee > 0, "AsteroidGame: search fee is invalid");

        require(_totalPrizes > 0, "AsteroidGame: total prizes is invalid");

        require(_winnerRewardPercent + _ownerRewardPercent <= HUNDRED_PERCENT, "AsteroidGame: percent is invalid");

        Room storage room = rooms[_roomId];

        if (address(room.token) != _token) {
            uint256 asteroidId = room.currentAsteroid;

            require(asteroidId == 1 && asteroids[_roomId][asteroidId].reward == 0, "AsteroidGame: can not update");

            room.token = IERC20(_token);
        }

        if (room.searchFee != _searchFee) {
            room.searchFee = _searchFee;
        }

        if (room.totalPrizes != _totalPrizes) {
            room.totalPrizes = _totalPrizes;
        }

        if (room.winnerRewardPercent != _winnerRewardPercent) {
            room.winnerRewardPercent = _winnerRewardPercent;
        }

        if (room.ownerRewardPercent != _ownerRewardPercent) {
            room.ownerRewardPercent = _ownerRewardPercent;
        }

        emit RoomUpdated(_roomId, _token, _searchFee, _totalPrizes, _winnerRewardPercent, _ownerRewardPercent);
    }

    function updateRoomStatus(uint256 _roomId, bool _status)
        external
        onlyOperator
        roomExists(_roomId)
    {
        rooms[_roomId].enable = _status;

        emit RoomStatusUpdated(_roomId, _status);
    }

    function getRooms(uint256 _offset, uint256 _limit)
        external
        view
        returns(Room[] memory data)
    {
        uint256 max = totalRooms;

        if (_offset >= max) {
            return data;
        }

        if (_offset + _limit < max) {
            max = _offset + _limit;
        }

        data = new Room[](max - _offset);

        uint256 cnt = 0;

        for (uint256 i = _offset; i < max; i++) {
            data[cnt++] = rooms[i + 1];
        }

        return data;
    }

    function setRocket(uint256 _roomId, uint256 _rocketId, uint256 _delayTime, uint256 _price)
        external
        onlyOperator
        roomExists(_roomId)
    {
        require(_delayTime > 0, "AsteroidGame: delay time is invalid");

        require(_price > 0, "AsteroidGame: price is invalid");

        Rocket storage rocket = rockets[_roomId][_rocketId];

        if (rocket.delayTime != _delayTime) {
            rocket.delayTime = _delayTime;
        }

        if (rocket.price != _price) {
            rocket.price = _price;
        }

        emit RocketUpdated(_roomId, _rocketId, _delayTime, _price);
    }

    function _random(uint256 _min, uint256 _max)
        internal
        view
        returns(uint256)
    {
        uint256 rnd = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.gaslimit)));

        return rnd % (_max - _min + 1) + _min;
    }

    function _updateAsteroidStatus(uint256 _roomId)
        internal
    {
        Room storage room = rooms[_roomId];

        Asteroid storage asteroid = asteroids[_roomId][room.currentAsteroid];

        if (asteroid.status == ASTEROID_MOVING && asteroid.collisionAt <= block.timestamp) {
            asteroid.status = ASTEROID_COLLIDED;
        }

        if (asteroid.status == ASTEROID_COLLIDED || asteroid.status == ASTEROID_EXPLODED) {
            room.currentAsteroid++;
        }
    }

    function createAsteroid(uint256 _roomId, uint256 _reward)
        external
        onlyOperator
        nonReentrant
        whenNotPaused
        roomActive(_roomId)
    {
        require(_reward > 0, "AsteroidGame: reward is invalid");

        _updateAsteroidStatus(_roomId);

        Room memory room = rooms[_roomId];

        uint256 asteroidId = room.currentAsteroid;

        Asteroid storage asteroid = asteroids[_roomId][asteroidId];

        require(asteroid.status == 0, "AsteroidGame: asteroid has found");

        address msgSender = _msgSender();

        room.token.safeTransferFrom(msgSender, address(this), _reward);

        asteroid.reward += _reward;
        asteroid.owner = msgSender;
        asteroid.totalPrizes = room.totalPrizes;
        asteroid.winnerRewardPercent = room.winnerRewardPercent;
        asteroid.ownerRewardPercent = room.ownerRewardPercent;
        asteroid.collisionAt = block.timestamp + _random(minLifeTime, maxLifeTime);
        asteroid.status = ASTEROID_MOVING;

        emit AsteroidCreated(_roomId, asteroidId, msgSender, _reward);
    }

    function searchAsteroid(uint256 _roomId)
        external
        nonReentrant
        whenNotPaused
        roomActive(_roomId)
    {
        _updateAsteroidStatus(_roomId);

        Room memory room = rooms[_roomId];

        uint256 asteroidId = room.currentAsteroid;

        Asteroid storage asteroid = asteroids[_roomId][asteroidId];

        require(asteroid.status == 0, "AsteroidGame: asteroid has found");

        address msgSender = _msgSender();

        room.token.safeTransferFrom(msgSender, address(this), room.searchFee);

        asteroid.reward += room.searchFee;

        uint256 weight = minSearchingWeight + asteroid.searchingWeight;

        // Generates number in range 1.00 to 100.00
        if (_random(100, 10000) > weight) {
            if (weight + searchingRatio <= maxSearchingWeight) {
                asteroid.searchingWeight += searchingRatio;
            }

            emit AsteroidNotFound(_roomId, asteroidId, msgSender, room.searchFee);

        } else {
            asteroid.owner = msgSender;
            asteroid.totalPrizes = room.totalPrizes;
            asteroid.winnerRewardPercent = room.winnerRewardPercent;
            asteroid.ownerRewardPercent = room.ownerRewardPercent;
            asteroid.collisionAt = block.timestamp + _random(minLifeTime, maxLifeTime);
            asteroid.status = ASTEROID_MOVING;

            emit AsteroidFound(_roomId, asteroidId, msgSender, room.searchFee);
        }
    }

    function getAsteroids(uint256 _roomId, uint256 _offset, uint256 _limit)
        external
        view
        returns(Asteroid[] memory data)
    {
        uint256 max = rooms[_roomId].currentAsteroid;

        if (_offset >= max) {
            return data;
        }

        if (_offset + _limit < max) {
            max = _offset + _limit;
        }

        data = new Asteroid[](max - _offset);

        uint256 cnt = 0;

        for (uint256 i = _offset; i < max; i++) {
            data[cnt++] = asteroids[_roomId][i + 1];
        }

        return data;
    }

    function addReward(uint256 _roomId, uint256 _reward)
        external
        nonReentrant
        whenNotPaused
        roomActive(_roomId)
    {
        require(_reward > 0, "AsteroidGame: reward is invalid");

        Room memory room = rooms[_roomId];

        uint256 asteroidId = room.currentAsteroid;

        Asteroid storage asteroid = asteroids[_roomId][asteroidId];

        require(asteroid.status == ASTEROID_MOVING && asteroid.collisionAt > block.timestamp, "AsteroidGame: asteroid has collided, exploded or not existed");
    
        address msgSender = _msgSender();

        room.token.safeTransferFrom(msgSender, address(this), _reward);

        asteroid.reward += _reward;

        emit RewardAdded(_roomId, asteroidId, msgSender, _reward);
    }

    function shootAsteroid(uint256 _roomId, uint256 _rocketId)
        external
        nonReentrant
        whenNotPaused
        roomActive(_roomId)
    {
        Rocket memory rocket = rockets[_roomId][_rocketId];

        require(rocket.price > 0, "AsteroidGame: rocket does not exist");

        Room memory room = rooms[_roomId];

        uint256 asteroidId = room.currentAsteroid;

        Asteroid storage asteroid = asteroids[_roomId][asteroidId];

        require(asteroid.status == ASTEROID_MOVING && asteroid.collisionAt > block.timestamp, "AsteroidGame: asteroid has collided, exploded or not existed");

        asteroid.reward += rocket.price;

        address msgSender = _msgSender();

        room.token.safeTransferFrom(msgSender, address(this), rocket.price);

        _shootings[_roomId][asteroidId].push(Shooting(msgSender, _rocketId, rocket.delayTime, rocket.price));

        emit Shoot(_roomId, asteroidId, _rocketId, msgSender, rocket.price, rocket.delayTime);

        uint256 weight = minShootingWeight + asteroid.shootingWeight;

        // Generates number in range 1.00 to 100.00
        if (_random(100, 10000) > weight) {
            if (weight + shootingRatio <= maxShootingWeight) {
                asteroid.shootingWeight += shootingRatio;
            }

            asteroid.collisionAt += rocket.delayTime;

        } else {
            asteroid.status = ASTEROID_EXPLODED;

            emit AsteroidExploded(_roomId, asteroidId);
        }

        if (!isPlayer[_roomId][asteroidId][msgSender]) {
            totalPlayers[_roomId][asteroidId]++;

            isPlayer[_roomId][asteroidId][msgSender] = true;
        }

        _sortWinners(_roomId, asteroidId, msgSender);
    }

    // Because total prizes is small, so this function will not out of gas
    function _sortWinners(uint256 _roomId, uint256 _asteroidId, address _player)
        internal
    {
        uint256 duplicated = 0;

        address[] storage winners = _winners[_roomId][_asteroidId];

        uint256 size = winners.length;

        address[] memory players = new address[](size);

        for (uint256 i = 0; i < size; i++) {
            players[i] = winners[i];

            if (players[i] == _player) {
                duplicated = i + 1;
            }
        }

        if (duplicated == 0) {
            if (asteroids[_roomId][_asteroidId].totalPrizes == size) {
                duplicated = 1;

            } else {
                winners.push(_player);
            }
        }

        if (duplicated != 0) {
            size--;

            for (uint256 i = duplicated - 1; i < size; i++) {
                winners[i] = players[i + 1];
            }

            if (winners[size] != _player) {
                winners[size] = _player;
            }
        }
    }

    function getShootings(uint256 _roomId, uint256 _asteroidId, uint256 _offset, uint256 _limit)
        external
        view
        returns(Shooting[] memory data)
    {
        uint256 max = _shootings[_roomId][_asteroidId].length;

        if (_offset >= max) {
            return data;
        }

        if (_offset + _limit < max) {
            max = _offset + _limit;
        }

        data = new Shooting[](max - _offset);

        uint256 cnt = 0;

        for (uint256 i = _offset; i < max; i++) {
            data[cnt++] = _shootings[_roomId][_asteroidId][i];
        }

        return data;
    }

    function totalShootings(uint256 _roomId, uint256 _asteroidId)
        external
        view
        returns(uint256)
    {
        return _shootings[_roomId][_asteroidId].length;
    }

    function getWinners(uint256 _roomId, uint256 _asteroidId)
        public
        view
        returns(address[] memory winners, uint256 winnerReward, uint256 ownerReward, uint256 systemFee)
    {
        Asteroid memory asteroid = asteroids[_roomId][_asteroidId];

        if (asteroid.status == 0 || asteroid.status == ASTEROID_MOVING && asteroid.collisionAt > block.timestamp) {
            return (winners, winnerReward, ownerReward, systemFee);
        }

        winners = _winners[_roomId][_asteroidId];

        uint256 numWinners = winners.length;

        if (numWinners > 0) {
            winnerReward = asteroid.reward * asteroid.winnerRewardPercent / HUNDRED_PERCENT;
            winnerReward = winnerReward - (winnerReward * asteroid.shootingWeight / HUNDRED_PERCENT);
        }

        ownerReward = asteroid.reward * asteroid.ownerRewardPercent / HUNDRED_PERCENT;
        ownerReward = ownerReward - (ownerReward * asteroid.searchingWeight / HUNDRED_PERCENT);

        systemFee = asteroid.reward - (winnerReward + ownerReward);

        if (numWinners > 0) {
            winnerReward = winnerReward / numWinners;
        }
    }

    function getBalance(uint256 _roomId, uint256 _asteroidId, address _account)
        public
        view
        returns(uint256 reward, uint256 systemFee)
    {
        if (isClaimed[_roomId][_asteroidId][_account]) {
            return (reward, systemFee);
        }

        (address[] memory winners, uint256 winnerReward, uint256 ownerReward, uint256 fee) = getWinners(_roomId, _asteroidId);

        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i] == _account) {
                reward += winnerReward;
                break;
            }
        }

        if (asteroids[_roomId][_asteroidId].owner == _account) {
            reward += ownerReward;
        }

        systemFee = fee;
    }

    function claimReward(uint256 _roomId, uint256 _asteroidId)
        external
        nonReentrant
        whenNotPaused
        roomActive(_roomId)
    {
        address msgSender = _msgSender();

        (uint256 amount, uint256 systemFee) = getBalance(_roomId, _asteroidId, msgSender);

        require(amount > 0, "AsteroidGame: amount is invalid");

        isClaimed[_roomId][_asteroidId][msgSender] = true;

        Room memory room = rooms[_roomId];

        room.token.safeTransfer(msgSender, amount);

        if (asteroids[_roomId][_asteroidId].owner == msgSender) {
            room.token.safeTransfer(treasury, systemFee);
        }

        emit RewardClaimed(_roomId, _asteroidId, msgSender, amount);
    }

}