// : MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
     * bearer except when using {AccessControl-_setupRole}.
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
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

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
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

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
    function renounceRole(bytes32 role, address account) external;
}


// : MIT

pragma solidity ^0.8.0;

//import"../utils/ContextUpgradeable.sol";
//import"../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}


// : MIT

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


// : MIT

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

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


// : MIT

pragma solidity ^0.8.0;
//import"../proxy/utils/Initializable.sol";

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
        return msg.data;
    }
    uint256[50] private __gap;
}


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"./IERC165Upgradeable.sol";
//import"../../proxy/utils/Initializable.sol";

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


// : MIT

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


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// : MIT

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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// : MIT

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


// : MIT

pragma solidity ^0.8.0;

//import"../IERC20.sol";
//import"../../../utils/Address.sol";

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


// : MIT

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


//: MIT
pragma solidity 0.8.4;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import"@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import"@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract StableFarmingPool is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;
    using SafeCastUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 public constant ADMIN = keccak256("ADMIN");

    bytes32 public constant SUPER_ADMIN = keccak256("SUPER_ADMIN");

    uint32 private constant ONE_YEAR_IN_SECONDS = 365 days;

    // The reward distribution address
    address public stableFarmingRewardDistributor;
    // Info of each pool
    StableFarmingPoolInfo[] public stableFarmingPoolInfo;
    // Info of each user that stakes in pools
    mapping(uint256 => mapping(address => StableFarmingStakingData))
        public stableFarmingStakingData;
    // Info of pending withdrawals.
    mapping(uint256 => mapping(address => StableFarmingPendingWithdrawal))
        public stableFarmingPendingWithdrawals;
    mapping(uint256 => FarmingWhiteList) public farmingWhiteList;
    // Black list user for all system
    mapping(address => bool) public farmingBlackList;
    // Allow emergency withdraw feature
    bool public stableFarmingAllowEmergencyWithdraw;

    event StableFarmingPoolCreated(
        uint256 indexed poolId,
        IERC20 stableFarmingAcceptedToken,
        IERC20 stableFarmingRewardToken,
        uint256 cap,
        uint256 APR,
        uint256 startJoinTime,
        uint256 minInvestment,
        uint256 maxInvestment,
        uint256 lockDuration,
        uint256 delayDuration
    );
    event StableFarmingPoolUpdated(
        uint256 indexed poolId,
        IERC20 stableFarmingAcceptedToken,
        IERC20 stableFarmingRewardToken,
        uint256 cap,
        uint256 APR,
        uint256 startJoinTime,
        uint256 minInvestment,
        uint256 maxInvestment,
        uint256 lockDuration,
        uint256 delayDuration
    );
    event StableFarmingDeposit(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount,
        uint256 stakeTime
    );
    event StableFarmingWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount,
        uint256 unStakeTime
    );
    event StableFarmingRewardsHarvested(
        uint256 indexed poolId,
        address indexed account,
        uint256 reward,
        uint256 rewardsHarvestTime
    );
    event StableFarmingPendingWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount,
        uint256 withdrawTime
    );
    event StableFarmingEmergencyWithdraw(
        uint256 indexed poolId,
        address indexed account,
        uint256 amount
    );

    event AddWhiteList(uint256 poolId, address[] addresses);
    event RemoveWhiteList(uint256 poolId, address[] addresses);
    event AddBlackList(address[] addresses);
    event RemoveBlackList(address[] addresses);

    struct StableFarmingPoolInfo {
        uint256 cap;
        uint256 totalStaked;
        IERC20 stableFarmingAcceptedToken;
        IERC20 stableFarmingRewardToken;
        uint256 minInvestment;
        uint256 maxInvestment;
        uint64 APR;
        uint256 lockDuration;
        uint256 delayDuration;
        uint256 startJoinTime;
    }

    struct StableFarmingStakingData {
        uint256 balance;
        uint256 joinTime;
        uint256 updatedTime;
        uint256 reward;
    }

    struct StableFarmingPendingWithdrawal {
        uint256 amount;
        uint256 applicableAt;
    }

    struct FarmingWhiteList {
        uint256 whiteListCount;
        mapping(address => bool) whitelist;
    }

    modifier onlyWhiteList(uint256 _poolId) {
        FarmingWhiteList storage whitelistData = farmingWhiteList[_poolId];
        require(
            whitelistData.whiteListCount == 0 ||
                whitelistData.whitelist[msg.sender],
            "stableFarmingStakingPool: not able to stake"
        );
        _;
    }

    modifier notInBlackList(address _user) {
        require(
            !farmingBlackList[_user],
            "stableFarmingStakingPool: you are in black list"
        );
        _;
    }

    /**
     * @notice Initialize the contract, get called in the first time deploy
     */
    function __StableFarmingPool_init() public initializer {
        __AccessControl_init();
        _setRoleAdmin(ADMIN, SUPER_ADMIN);
        _setupRole(ADMIN, msg.sender);
        _setupRole(SUPER_ADMIN, msg.sender);
        __Ownable_init();
    }

    /**
     * @notice Validate pool by pool ID
     * @param _poolId id of the pool
     */
    modifier stableFarmingValidatePoolById(uint256 _poolId) {
        require(
            _poolId < stableFarmingPoolInfo.length,
            "stableFarmingStakingPool: Pool are not exist"
        );
        _;
    }

    /**
     * @notice Return total number of pools
     */
    function stableFarmingPoolLength() external view returns (uint256) {
        return stableFarmingPoolInfo.length;
    }

    /**
     * @notice Return total tokens staked in a pool
     * @param _poolId id of the pool
     */
    function stableFarmingTotalStaked(uint256 _poolId)
        external
        view
        stableFarmingValidatePoolById(_poolId)
        returns (uint256)
    {
        return stableFarmingPoolInfo[_poolId].totalStaked;
    }

    /**
     * @notice Add a new pool with different APR and conditions. Can only be called by the owner.
     * @param _cap the maximum number of staking tokens the pool will receive. If this limit is reached, users can not deposit into this pool.
     * @param _minInvestment the minimum investment amount users need to use in order to join the pool.
     * @param _maxInvestment the maximum investment amount users can deposit to join the pool.
     * @param _stableFarmingAcceptedToken token user need to stake into this pool
     * @param _stableFarmingRewardToken token user will get after staked
     * @param _APR the APR rate of the pool.
     * @param _lockDuration the duration users need to wait before being able to withdraw and claim the rewards.
     * @param _delayDuration the duration users need to wait to receive the principal amount, after unstaking from the pool.
     * @param _startJoinTime the time when users can start to join the pool
     */
    function stableFarmingAddPool(
        uint256 _cap,
        IERC20 _stableFarmingAcceptedToken,
        IERC20 _stableFarmingRewardToken,
        uint256 _minInvestment,
        uint256 _maxInvestment,
        uint64 _APR,
        uint256 _lockDuration,
        uint256 _delayDuration,
        uint256 _startJoinTime
    ) external onlyRole(ADMIN) {

        stableFarmingPoolInfo.push(
            StableFarmingPoolInfo({
                cap: _cap,
                totalStaked: 0,
                stableFarmingAcceptedToken: _stableFarmingAcceptedToken,
                stableFarmingRewardToken: _stableFarmingRewardToken,
                minInvestment: _minInvestment,
                maxInvestment: _maxInvestment,
                APR: _APR,
                lockDuration: _lockDuration,
                delayDuration: _delayDuration,
                startJoinTime: _startJoinTime
            })
        );

        {
            emit StableFarmingPoolCreated(
                stableFarmingPoolInfo.length - 1,
                _stableFarmingAcceptedToken,
                _stableFarmingRewardToken,
                _cap,
                _APR,
                _startJoinTime,
                _minInvestment,
                _maxInvestment,
                _lockDuration,
                _delayDuration
            );
        }
    }

    /**
     * @notice update a pool with different APR and conditions. Can only be called by the admin role.
     * @param _poolId id of pool want to update
     * @param cap the maximum number of staking tokens the pool will receive. If this limit is reached, users can not deposit into this pool.
     * @param minInvestment the minimum investment amount users need to use in order to join the pool.
     * @param maxInvestment the maximum investment amount users can deposit to join the pool.
     * @param stableFarmingAcceptedToken token user need to stake into this pool
     * @param stableFarmingRewardToken token user will get after staked
     * @param APR the APR rate of the pool.
     * @param lockDuration the duration users need to wait before being able to withdraw and claim the rewards.
     * @param delayDuration the duration users need to wait to receive the principal amount, after unstaking from the pool.
     * @param startJoinTime the time when users can start to join the pool
     */
    function stableFarmingUpdatePool(
        uint256 _poolId,
        IERC20 stableFarmingAcceptedToken,
        IERC20 stableFarmingRewardToken,
        uint256 cap,
        uint64 APR,
        uint256 startJoinTime,
        uint256 minInvestment,
        uint256 maxInvestment,
        uint256 lockDuration,
        uint256 delayDuration
    ) external onlyRole(ADMIN) {
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];

        require(
            pool.startJoinTime > block.timestamp,
            "stableFarmingStakingPool: update pool after pool started"
        );

        pool.APR = APR;
        pool.cap = cap;
        pool.delayDuration = delayDuration;
        pool.maxInvestment = maxInvestment;
        pool.lockDuration = lockDuration;
        pool.minInvestment = minInvestment;
        pool.stableFarmingAcceptedToken = stableFarmingAcceptedToken;
        pool.stableFarmingRewardToken = stableFarmingRewardToken;
        pool.startJoinTime = startJoinTime;

        emit StableFarmingPoolUpdated(
            _poolId,
            stableFarmingAcceptedToken,
            stableFarmingRewardToken,
            cap,
            APR,
            startJoinTime,
            minInvestment,
            maxInvestment,
            lockDuration,
            delayDuration
        );
    }

    /**
     * @notice Set the reward distributor. Can only be called by the owner.
     * @param _poolId pool will add whitelist
     * @param _whitelist whitelist
     */
    function farmingAddWhiteList(uint256 _poolId, address[] memory _whitelist)
        external
        onlyRole(ADMIN)
    {
        require(
            _whitelist.length > 0,
            "stableFarmingStakingPool: no items in whitelist array"
        );

        FarmingWhiteList storage whitelistData = farmingWhiteList[_poolId];
        for (uint256 i; i < _whitelist.length; i++) {
            if (!whitelistData.whitelist[_whitelist[i]]) {
                whitelistData.whiteListCount++;
                whitelistData.whitelist[_whitelist[i]] = true;
            }
        }

        emit AddWhiteList(_poolId, _whitelist);
    }

    /**
     * @notice Set the reward distributor. Can only be called by the owner.
     * @param _poolId pool will remove whitelist
     * @param _whitelist whitelist
     */
    function farmingRemoveWhiteList(
        uint256 _poolId,
        address[] memory _whitelist
    ) external onlyRole(ADMIN) {
        require(
            _whitelist.length > 0,
            "stableFarmingStakingPool: no items in whitelist array"
        );

        FarmingWhiteList storage whitelistData = farmingWhiteList[_poolId];
        for (uint256 i; i < _whitelist.length; i++) {
            if (whitelistData.whitelist[_whitelist[i]]) {
                whitelistData.whiteListCount--;
                whitelistData.whitelist[_whitelist[i]] = false;
            }
        }

        emit RemoveWhiteList(_poolId, _whitelist);
    }

    /**
     * @notice Add black list user. Can only be called by the owner.
     * @param _blackList whitelist
     */
    function farmingAddBlackList(address[] memory _blackList)
        external
        onlyRole(ADMIN)
    {
        require(
            _blackList.length > 0,
            "stableFarmingStakingPool: no items in blacl list array"
        );

        for (uint256 i; i < _blackList.length; i++) {
            farmingBlackList[_blackList[i]] = true;
        }

        emit AddBlackList(_blackList);
    }

    /**
     * @notice Add black list user. Can only be called by the owner.
     * @param _blackList whitelist
     */
    function farmingRemoveBlackList(address[] memory _blackList)
        external
        onlyRole(ADMIN)
    {
        require(
            _blackList.length > 0,
            "stableFarmingStakingPool: no items in blacl list array"
        );

        for (uint256 i; i < _blackList.length; i++) {
            farmingBlackList[_blackList[i]] = false;
        }

        emit RemoveBlackList(_blackList);
    }

    /**
     * @notice Set the reward distributor. Can only be called by the owner.
     * @param _stableFarmingRewardDistributor the reward distributor
     */
    function stableFarmingSetRewardDistributor(
        address _stableFarmingRewardDistributor
    ) external onlyRole(ADMIN) {
        require(
            _stableFarmingRewardDistributor != address(0),
            "stableFarmingStakingPool: invalid reward distributor"
        );
        stableFarmingRewardDistributor = _stableFarmingRewardDistributor;
    }

    /**
     * @notice Deposit token to earn rewards
     * @param _poolId id of the pool
     * @param _amount amount of token to deposit
     */
    function stableFarmingDeposit(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        stableFarmingValidatePoolById(_poolId)
        onlyWhiteList(_poolId)
        notInBlackList(msg.sender)
    {
        address account = msg.sender;
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        _stableFarmingDeposit(_poolId, _amount, account);

        pool.stableFarmingAcceptedToken.safeTransferFrom(
            account,
            address(this),
            _amount
        );
        emit StableFarmingDeposit(_poolId, account, _amount, block.timestamp);
    }

    /**
     * @notice Withdraw token from a pool
     * @param _poolId id of the pool
     * @param _amount amount to withdraw
     */
    function stableFarmingWithdraw(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        stableFarmingValidatePoolById(_poolId)
        notInBlackList(msg.sender)
    {
        address account = msg.sender;
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][account];

        uint256 lockDuration = pool.lockDuration;

        require(
            block.timestamp >= stakingData.joinTime + lockDuration,
            "stableFarmingStakingPool: still locked"
        );

        require(
            stakingData.balance >= _amount,
            "stableFarmingStakingPool: invalid withdraw amount"
        );

        _stableFarmingHarvest(_poolId, account);

        // if (stakingData.reward > 0) {
        //     require(
        //         stableFarmingRewardDistributor != address(0),
        //         "stableFarmingStakingPool: invalid reward distributor"
        //     );

        //     uint256 reward = stakingData.reward;
        //     stakingData.reward = 0;
        //     pool.stableFarmingAcceptedToken.safeTransferFrom(
        //         stableFarmingRewardDistributor,
        //         account,
        //         reward
        //     );
        //     emit StableFarmingRewardsHarvested(_poolId, account, reward, block.timestamp);
        // }

        stakingData.balance -= _amount;
        if (pool.delayDuration == 0) {
            pool.stableFarmingAcceptedToken.safeTransfer(account, _amount);
            pool.totalStaked -= _amount;
            emit StableFarmingWithdraw(_poolId, account, _amount, block.timestamp);
            return;
        }

        StableFarmingPendingWithdrawal
            storage pending = stableFarmingPendingWithdrawals[_poolId][account];
        pool.totalStaked -= _amount;
        pending.amount += _amount;
        pending.applicableAt = block.timestamp + pool.delayDuration;
        emit StableFarmingWithdraw(_poolId, account, _amount, block.timestamp);
    }

    /**
     * @notice Claim pending withdrawal
     * @param _poolId id of the pool
     */
    function stableFarmingClaimPendingWithdraw(uint256 _poolId)
        external
        nonReentrant
        stableFarmingValidatePoolById(_poolId)
        notInBlackList(msg.sender)
    {
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        address account = msg.sender;
        StableFarmingPendingWithdrawal
            storage pending = stableFarmingPendingWithdrawals[_poolId][account];
        uint256 amount = pending.amount;
        require(
            amount > 0,
            "stableFarmingStakingPool: nothing is currently pending"
        );
        require(
            pending.applicableAt <= block.timestamp,
            "stableFarmingStakingPool: not released yet"
        );
        delete stableFarmingPendingWithdrawals[_poolId][account];
        pool.stableFarmingAcceptedToken.safeTransfer(account, amount);

        emit StableFarmingPendingWithdraw(_poolId, account, amount, block.timestamp);
    }

    /**
     * @notice Claim reward token from a pool
     * @param _poolId id of the pool
     */
    function stableFarmingClaimReward(uint256 _poolId)
        external
        nonReentrant
        stableFarmingValidatePoolById(_poolId)
        notInBlackList(msg.sender)
    {
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        address account = msg.sender;
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][account];

        _stableFarmingHarvest(_poolId, account);

        if (stakingData.reward > 0) {
            require(
                stableFarmingRewardDistributor != address(0),
                "stableFarmingStakingPool: invalid reward distributor"
            );

            require(
                block.timestamp >= stakingData.joinTime + pool.lockDuration,
                "stableFarmingStakingPool: still locked"
            );
            uint256 reward = stakingData.reward;
            stakingData.reward = 0;
            pool.stableFarmingRewardToken.safeTransferFrom(
                stableFarmingRewardDistributor,
                account,
                reward
            );
            emit StableFarmingRewardsHarvested(_poolId, account, reward, block.timestamp);
        }
    }

    /**
     * @notice Gets number of reward tokens of a user from a pool
     * @param _poolId id of the pool
     * @param _account address of a user
     * @return reward earned reward of a user
     */
    function stableFarmingPendingReward(uint256 _poolId, address _account)
        public
        view
        stableFarmingValidatePoolById(_poolId)
        returns (uint256 reward)
    {
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][_account];

        uint256 startTime = stakingData.updatedTime > 0
            ? stakingData.updatedTime
            : block.timestamp;

        uint256 endTime = block.timestamp;
        if (
            pool.lockDuration > 0 &&
            stakingData.joinTime + pool.lockDuration < block.timestamp
        ) {
            endTime = stakingData.joinTime + pool.lockDuration;
        }

        uint256 stakedTimeInSeconds = endTime > startTime
            ? endTime - startTime
            : 0;
        uint256 pendingReward = ((stakingData.balance *
            stakedTimeInSeconds *
            pool.APR) / ONE_YEAR_IN_SECONDS) / 1e20;

        reward = stakingData.reward + pendingReward;
    }

    /**
     * @notice Gets number of deposited tokens in a pool
     * @param _poolId id of the pool
     * @param _account address of a user
     * @return total token deposited in a pool by a user
     */
    function stableFarmingBalanceOf(uint256 _poolId, address _account)
        external
        view
        stableFarmingValidatePoolById(_poolId)
        returns (uint256)
    {
        return stableFarmingStakingData[_poolId][_account].balance;
    }

    /**
     * @notice Change super admin role for other. Can only be called by the current super admin.
     * @param _newSuperAdmin the reward distributor
     */
    function stableFarmingSetSuperAdmin(
        address _newSuperAdmin
    ) external onlyRole(SUPER_ADMIN) {
        require(
            _newSuperAdmin != address(0),
            "stableFarmingStakingPool: invalid address"
        );
        _setupRole(SUPER_ADMIN, _newSuperAdmin);
        renounceRole(SUPER_ADMIN, msg.sender);
    }

    /**
     * @notice Update allowance for emergency withdraw
     * @param _shouldAllow should allow emergency withdraw or not
     */
    function stableFarmingSetAllowEmergencyWithdraw(bool _shouldAllow)
        external
        onlyOwner
    {
        stableFarmingAllowEmergencyWithdraw = _shouldAllow;
    }

    /**
     * @notice Withdraw without caring about rewards. EMERGENCY ONLY.
     * @param _poolId id of the pool
     */
    function stableFarmingEmergencyWithdraw(uint256 _poolId)
        external
        nonReentrant
        stableFarmingValidatePoolById(_poolId)
        notInBlackList(msg.sender)
    {
        require(
            stableFarmingAllowEmergencyWithdraw,
            "stableFarmingStakingPool: emergency withdrawal is not allowed yet"
        );

        address account = msg.sender;
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][account];

        require(
            stakingData.balance > 0,
            "stableFarmingStakingPool: nothing to withdraw"
        );

        uint256 amount = stakingData.balance;

        stakingData.balance = 0;
        stakingData.reward = 0;
        stakingData.updatedTime = block.timestamp;

        pool.stableFarmingAcceptedToken.safeTransfer(account, amount);
        emit StableFarmingEmergencyWithdraw(_poolId, account, amount);
    }

    function _stableFarmingDeposit(
        uint256 _poolId,
        uint256 _amount,
        address account
    ) internal {
        StableFarmingPoolInfo storage pool = stableFarmingPoolInfo[_poolId];
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][account];

        require(
            block.timestamp >= pool.startJoinTime,
            "stableFarmingStakingPool: pool is not started yet"
        );


        require(
            stakingData.balance + _amount >= pool.minInvestment,
            "stableFarmingStakingPool: insufficient amount"
        );

        if (pool.maxInvestment > 0) {
            require(
                stakingData.balance + _amount <= pool.maxInvestment,
                "stableFarmingStakingPool: too large amount"
            );
        }

        if (pool.cap > 0) {
            require(
                pool.totalStaked + _amount <= pool.cap,
                "stableFarmingStakingPool: pool is full"
            );
        }

        _stableFarmingHarvest(_poolId, account);

        stakingData.balance += _amount;
        stakingData.joinTime = block.timestamp;

        pool.totalStaked += _amount;
    }

    function _stableFarmingHarvest(uint256 _poolId, address _account) private {
        StableFarmingStakingData storage stakingData = stableFarmingStakingData[
            _poolId
        ][_account];

        stakingData.reward = stableFarmingPendingReward(_poolId, _account);
        stakingData.updatedTime = block.timestamp;
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"./IAccessControlUpgradeable.sol";
//import"../utils/ContextUpgradeable.sol";
//import"../utils/StringsUpgradeable.sol";
//import"../utils/introspection/ERC165Upgradeable.sol";
//import"../proxy/utils/Initializable.sol";

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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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


