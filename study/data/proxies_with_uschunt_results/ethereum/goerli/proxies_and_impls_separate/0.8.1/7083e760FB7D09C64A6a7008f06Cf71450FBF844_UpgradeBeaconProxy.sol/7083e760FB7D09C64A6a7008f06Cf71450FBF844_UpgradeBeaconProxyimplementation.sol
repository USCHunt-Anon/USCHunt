// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

//import"../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

//import"../utils/Context.sol";

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


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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


// : MIT
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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

//import"../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


// : MIT OR Apache-2.0
pragma solidity 0.8.14;

// //import{TypedMemView} from "@summa-tx/memview-sol/contracts/TypedMemView.sol";
//import{TypedMemView} from "../../../nomad-core/libs/TypedMemView.sol";
//import{TypeCasts} from "../../../nomad-core/contracts/XAppConnectionManager.sol";
//import{UpgradeBeaconProxy} from "../../../nomad-core/contracts/upgrade/UpgradeBeaconProxy.sol";

//import{IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import{Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

//import{ConnextMessage} from "../libraries/ConnextMessage.sol";
//import{Encoding} from "../libraries/Encoding.sol";
//import{XAppConnectionClient} from "../../shared/XAppConnectionClient.sol";

//import{ITokenRegistry} from "../interfaces/ITokenRegistry.sol";
//import{IBridgeToken} from "../interfaces/IBridgeToken.sol";

/**
 * @title TokenRegistry
 * @notice manages a registry of token contracts on this chain
 * -
 * We sort token types as "representation token" or "locally originating token".
 * Locally originating - a token contract that was originally deployed on the local chain
 * Representation (repr) - a token that was originally deployed on some other chain
 * -
 * When the BridgeRouter handles an incoming message, it determines whether the
 * transfer is for an asset of local origin. If not, it checks for an existing
 * representation contract. If no such representation exists, it deploys a new
 * representation contract. It then stores the relationship in the
 * `representationToCanonical` and `canonicalToRepresentation` mappings to ensure
 * we can always perform a lookup in either direction.
 * NOTE: The locally originating tokens should NEVER be represented in these lookup tables.
 */
contract TokenRegistry is Initializable, XAppConnectionClient, ITokenRegistry {
  // ============ Libraries ============

  using TypedMemView for bytes;
  using TypedMemView for bytes29;
  using ConnextMessage for bytes29;

  // ============ Public Storage ============
  uint32 private _local;

  // UpgradeBeacon from which new token proxies will get their implementation
  address public tokenBeacon;
  // local representation token address => token ID
  mapping(address => ConnextMessage.TokenId) public representationToCanonical;
  // hash of the tightly-packed TokenId => local representation token address
  // If the token is of local origin, this MUST map to address(0).
  mapping(bytes32 => address) public canonicalToRepresentation;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[49] private __GAP;

  // ============ Events ============

  /**
   * @notice emitted when a representation token contract is deployed
   * @param domain the domain of the chain where the canonical asset is deployed
   * @param id the bytes32 address of the canonical token contract
   * @param representation the address of the newly locally deployed representation contract
   */
  event TokenDeployed(uint32 indexed domain, bytes32 indexed id, address indexed representation);

  // ======== Initializer =========
  function setLocalDomain(uint32 domain) public {
    _local = domain;
  }

  function initialize(address _tokenBeacon, address _xAppConnectionManager) public initializer {
    tokenBeacon = _tokenBeacon;
    __XAppConnectionClient_initialize(_xAppConnectionManager);
  }

  // ======== TokenId & Address Lookup for Representation Tokens =========

  /**
   * @notice Look up the canonical token ID for a representation token
   * @param _representation the address of the representation contract
   * @return _domain the domain of the canonical version.
   * @return _id the identifier of the canonical version in its domain.
   */
  function getCanonicalTokenId(address _representation) external view returns (uint32 _domain, bytes32 _id) {
    ConnextMessage.TokenId memory _canonical = representationToCanonical[_representation];
    _domain = _canonical.domain;
    _id = _canonical.id;
  }

  /**
   * @notice Look up the representation address for a canonical token
   * @param _domain the domain of the canonical version.
   * @param _id the identifier of the canonical version in its domain.
   * @return _representation the address of the representation contract
   */
  function getRepresentationAddress(uint32 _domain, bytes32 _id) public view returns (address _representation) {
    bytes29 _tokenId = ConnextMessage.formatTokenId(_domain, _id);
    bytes32 _idHash = _tokenId.keccak();
    _representation = canonicalToRepresentation[_idHash];
  }

  // ======== External: Deploying Representation Tokens =========

  /**
   * @notice Get the address of the local token for the provided tokenId;
   * if the token is remote and no local representation exists, deploy the representation contract
   * @param _domain the token's native domain
   * @param _id the token's id on its native domain
   * @return _token the address of the local token contract
   */
  function ensureLocalToken(uint32 _domain, bytes32 _id) external override returns (address _token) {
    _token = getLocalAddress(_domain, _id);
    if (_token == address(0)) {
      // Representation does not exist yet;
      // deploy representation contract
      _token = _deployToken(_domain, _id);
    }
  }

  // ======== External: Enrolling Representation Tokens =========

  /**
   * @notice Enroll a custom token. This allows projects to work with
   * governance to specify a custom representation.
   * @dev This is done by inserting the custom representation into the token
   * lookup tables. It is permissioned to the owner (governance) and can
   * potentially break token representations. It must be used with extreme
   * caution.
   * After the token is inserted, new mint instructions will be sent to the
   * custom token. The default representation (and old custom representations)
   * may still be burnt. Until all users have explicitly called migrate, both
   * representations will continue to exist.
   * The custom representation MUST be trusted, and MUST allow the router to
   * both mint AND burn tokens at will.
   * @param _domain the domain of the canonical Token to enroll
   * @param _id the bytes32 ID pf the canonical of the Token to enroll
   * @param _custom the address of the custom implementation to use.
   */
  function enrollCustom(
    uint32 _domain,
    bytes32 _id,
    address _custom
  ) external override onlyOwner {
    // update mappings with custom token
    _setRepresentationToCanonical(_domain, _id, _custom);
    _setCanonicalToRepresentation(_domain, _id, _custom);
  }

  // ======== Match Old Representation Tokens =========

  /**
   * @notice Returns the current representation contract
   * for the same canonical token as the old representation contract
   * @dev If _oldRepr is not a representation, this will error.
   * @param _oldRepr The address of the old representation token
   * @return _currentRepr The address of the current representation token
   */
  function oldReprToCurrentRepr(address _oldRepr) external view override returns (address _currentRepr) {
    // get the canonical token ID for the old representation contract
    ConnextMessage.TokenId memory _tokenId = representationToCanonical[_oldRepr];
    require(_tokenId.domain != 0, "!repr");
    // get the current primary representation for the same canonical token ID
    _currentRepr = getRepresentationAddress(_tokenId.domain, _tokenId.id);
  }

  // ======== TokenId & Address Lookup for ALL Local Tokens (Representation AND Canonical) =========

  /**
   * @notice Return tokenId for a local token address
   * @param _token the local address of the token contract (representation or canonical)
   * @return _domain canonical domain
   * @return _id canonical identifier on that domain
   */
  function getTokenId(address _token) external view override returns (uint32 _domain, bytes32 _id) {
    ConnextMessage.TokenId memory _tokenId = representationToCanonical[_token];
    if (_tokenId.domain == 0) {
      _domain = _localDomain();
      _id = TypeCasts.addressToBytes32(_token);
    } else {
      _domain = _tokenId.domain;
      _id = _tokenId.id;
    }
  }

  /**
   * @notice Looks up the local address corresponding to a domain/id pair.
   * @dev If the token is local, it will return the local address.
   * If the token is non-local and no local representation exists, this
   * will return `address(0)`.
   * @param _domain the domain of the canonical version.
   * @param _id the identifier of the canonical version in its domain.
   * @return _token the local address of the token contract (representation or canonical)
   */
  function getLocalAddress(uint32 _domain, address _id) external view returns (address _token) {
    _token = getLocalAddress(_domain, TypeCasts.addressToBytes32(_id));
  }

  /**
   * @notice Looks up the local address corresponding to a domain/id pair.
   * @dev If the token is local, it will return the local address.
   * If the token is non-local and no local representation exists, this
   * will return `address(0)`.
   * @param _domain the domain of the canonical version.
   * @param _id the identifier of the canonical version in its domain.
   * @return _token the local address of the token contract (representation or canonical)
   */
  function getLocalAddress(uint32 _domain, bytes32 _id) public view override returns (address _token) {
    if (_domain == _localDomain()) {
      // Token is of local origin
      _token = TypeCasts.bytes32ToAddress(_id);
    } else {
      // Token is a representation of a token of remote origin
      _token = getRepresentationAddress(_domain, _id);
    }
  }

  /**
   * @notice Return the local token contract for the
   * canonical tokenId; revert if there is no local token
   * @param _domain the token's native domain
   * @param _id the token's id on its native domain
   * @return IERC20 for the local IERC20 token contract
   */
  function mustHaveLocalToken(uint32 _domain, bytes32 _id) external view override returns (IERC20) {
    address _token = getLocalAddress(_domain, _id);
    require(_token != address(0), "!token");
    return IERC20(_token);
  }

  /**
   * @notice Determine if token is of local origin
   * @return TRUE if token is locally originating
   */
  function isLocalOrigin(address _token) public view override returns (bool) {
    // If the contract WAS deployed by the TokenRegistry,
    // it will be stored in this mapping.
    // If so, it IS NOT of local origin
    if (representationToCanonical[_token].domain != 0) {
      return false;
    }
    // If the contract WAS NOT deployed by the TokenRegistry,
    // and the contract exists, then it IS of local origin
    // Return true if code exists at _addr
    uint256 _codeSize;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      _codeSize := extcodesize(_token)
    }
    return _codeSize != 0;
  }

  // ======== Internal Functions =========

  /**
   * @notice Set the primary representation for a given canonical
   * @param _domain the domain of the canonical token
   * @param _id the bytes32 ID pf the canonical of the token
   * @param _representation the address of the representation token
   */
  function _setRepresentationToCanonical(
    uint32 _domain,
    bytes32 _id,
    address _representation
  ) internal {
    representationToCanonical[_representation].domain = _domain;
    representationToCanonical[_representation].id = _id;
  }

  /**
   * @notice Set the canonical token for a given representation
   * @param _domain the domain of the canonical token
   * @param _id the bytes32 ID pf the canonical of the token
   * @param _representation the address of the representation token
   */
  function _setCanonicalToRepresentation(
    uint32 _domain,
    bytes32 _id,
    address _representation
  ) internal {
    bytes29 _tokenId = ConnextMessage.formatTokenId(_domain, _id);
    bytes32 _idHash = _tokenId.keccak();
    canonicalToRepresentation[_idHash] = _representation;
  }

  /**
   * @notice Deploy and initialize a new token contract
   * @dev Each token contract is a proxy which
   * points to the token upgrade beacon
   * @return _token the address of the token contract
   */
  function _deployToken(uint32 _domain, bytes32 _id) internal returns (address _token) {
    // deploy and initialize the token contract
    _token = address(new UpgradeBeaconProxy(tokenBeacon, ""));
    // initialize the token separately from the
    IBridgeToken(_token).initialize();
    // set the default token name & symbol
    (string memory _name, string memory _symbol) = _defaultDetails(_domain, _id);
    IBridgeToken(_token).setDetails(_name, _symbol, 18);
    // transfer ownership to bridgeRouter
    IBridgeToken(_token).transferOwnership(owner());
    // store token in mappings
    _setCanonicalToRepresentation(_domain, _id, _token);
    _setRepresentationToCanonical(_domain, _id, _token);
    // emit event upon deploying new token
    emit TokenDeployed(_domain, _id, _token);
  }

  /**
   * @notice Get default name and details for a token
   * Sets name to "nomad.[domain].[id]"
   * and symbol to
   * @param _domain the domain of the canonical token
   * @param _id the bytes32 ID pf the canonical of the token
   */
  function _defaultDetails(uint32 _domain, bytes32 _id)
    internal
    pure
    returns (string memory _name, string memory _symbol)
  {
    // get the first and second half of the token ID
    (, uint256 _secondHalfId) = Encoding.encodeHex(uint256(_id));
    // encode the default token name: "[decimal domain].[hex 4 bytes of ID]"
    _name = string(
      abi.encodePacked(
        Encoding.decimalUint32(_domain), // 10
        ".", // 1
        uint32(_secondHalfId) // 4
      )
    );
    // allocate the memory for a new 32-byte string
    _symbol = new string(10 + 1 + 4);
    assembly {
      mstore(add(_symbol, 0x20), mload(add(_name, 0x20)))
    }
  }

  /**
   * @dev explicit override for compiler inheritance
   * @dev explicit override for compiler inheritance
   * @return domain of chain on which the contract is deployed
   */
  function _localDomain() internal view override(XAppConnectionClient) returns (uint32) {
    // return XAppConnectionClient._localDomain();
    return _local;
  }
}


// : MIT OR Apache-2.0
pragma solidity 0.8.14;

interface IBridgeToken {
  function initialize() external;

  function name() external returns (string memory);

  function balanceOf(address _account) external view returns (uint256);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function detailsHash() external view returns (bytes32);

  function burn(address _from, uint256 _amnt) external;

  function mint(address _to, uint256 _amnt) external;

  function setDetailsHash(bytes32 _detailsHash) external;

  function setDetails(
    string calldata _name,
    string calldata _symbol,
    uint8 _decimals
  ) external;

  // inherited from ownable
  function transferOwnership(address _newOwner) external;
}


// : MIT OR Apache-2.0
pragma solidity 0.8.14;

//import{IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenRegistry {
  function isLocalOrigin(address _token) external view returns (bool);

  function ensureLocalToken(uint32 _domain, bytes32 _id) external returns (address _local);

  function mustHaveLocalToken(uint32 _domain, bytes32 _id) external view returns (IERC20);

  function getLocalAddress(uint32 _domain, bytes32 _id) external view returns (address _local);

  function getTokenId(address _token) external view returns (uint32, bytes32);

  function enrollCustom(
    uint32 _domain,
    bytes32 _id,
    address _custom
  ) external;

  function oldReprToCurrentRepr(address _oldRepr) external view returns (address _currentRepr);
}


// : UNLICENSED
pragma solidity 0.8.14;

//import{TypedMemView} from "../../../nomad-core/libs/TypedMemView.sol";

library ConnextMessage {
  // ============ Libraries ============

  using TypedMemView for bytes;
  using TypedMemView for bytes29;

  // ============ Enums ============

  // WARNING: do NOT re-write the numbers / order
  // of message types in an upgrade;
  // will cause in-flight messages to be mis-interpreted
  enum Types {
    Invalid, // 0
    TokenId, // 1
    Message, // 2
    Transfer // 3
  }

  // ============ Structs ============

  // Tokens are identified by a TokenId:
  // domain - 4 byte chain ID of the chain from which the token originates
  // id - 32 byte identifier of the token address on the origin chain, in that chain's address format
  struct TokenId {
    uint32 domain;
    bytes32 id;
  }

  // ============ Constants ============

  uint256 private constant TOKEN_ID_LEN = 36; // 4 bytes domain + 32 bytes id
  uint256 private constant IDENTIFIER_LEN = 1;
  uint256 private constant TRANSFER_LEN = 129;
  // 1 byte identifier + 32 bytes recipient + 32 bytes amount + 32 bytes detailsHash + 32 bytes external hash

  // ============ Modifiers ============

  /**
   * @notice Asserts a message is of type `_t`
   * @param _view The message
   * @param _t The expected type
   */
  modifier typeAssert(bytes29 _view, Types _t) {
    _view.assertType(uint40(_t));
    _;
  }

  // ============ Internal Functions: Validation ============

  /**
   * @notice Checks that Action is valid type
   * @param _action The action
   * @return TRUE if action is valid
   */
  function isValidAction(bytes29 _action) internal pure returns (bool) {
    return isTransfer(_action);
  }

  /**
   * @notice Checks that the message is of the specified type
   * @param _type the type to check for
   * @param _action The message
   * @return True if the message is of the specified type
   */
  function isType(bytes29 _action, Types _type) internal pure returns (bool) {
    return actionType(_action) == uint8(_type) && messageType(_action) == _type;
  }

  /**
   * @notice Checks that the message is of type Transfer
   * @param _action The message
   * @return True if the message is of type Transfer
   */
  function isTransfer(bytes29 _action) internal pure returns (bool) {
    return isType(_action, Types.Transfer);
  }

  /**
   * @notice Checks that view is a valid message length
   * @param _view The bytes string
   * @return TRUE if message is valid
   */
  function isValidMessageLength(bytes29 _view) internal pure returns (bool) {
    uint256 _len = _view.len();
    return _len == TOKEN_ID_LEN + TRANSFER_LEN;
  }

  /**
   * @notice Asserts that the message is of type Message
   * @param _view The message
   * @return The message
   */
  function mustBeMessage(bytes29 _view) internal pure returns (bytes29) {
    return tryAsMessage(_view).assertValid();
  }

  // ============ Internal Functions: Formatting ============

  /**
   * @notice Formats an action message
   * @param _tokenId The token ID
   * @param _action The action
   * @return The formatted message
   */
  function formatMessage(bytes29 _tokenId, bytes29 _action)
    internal
    view
    typeAssert(_tokenId, Types.TokenId)
    returns (bytes memory)
  {
    require(isValidAction(_action), "!action");
    bytes29[] memory _views = new bytes29[](2);
    _views[0] = _tokenId;
    _views[1] = _action;
    return TypedMemView.join(_views);
  }

  /**
   * @notice Formats Transfer
   * @param _to The recipient address as bytes32
   * @param _amnt The transfer amount
   * @param _detailsHash The token details hash
   * @param _transferId Unique identifier for transfer
   * @return
   */
  function formatTransfer(
    bytes32 _to,
    uint256 _amnt,
    bytes32 _detailsHash,
    bytes32 _transferId
  ) internal pure returns (bytes29) {
    return
      abi.encodePacked(Types.Transfer, _to, _amnt, _detailsHash, _transferId).ref(0).castTo(uint40(Types.Transfer));
  }

  /**
   * @notice Serializes a Token ID struct
   * @param _tokenId The token id struct
   * @return The formatted Token ID
   */
  function formatTokenId(TokenId memory _tokenId) internal pure returns (bytes29) {
    return formatTokenId(_tokenId.domain, _tokenId.id);
  }

  /**
   * @notice Creates a serialized Token ID from components
   * @param _domain The domain
   * @param _id The ID
   * @return The formatted Token ID
   */
  function formatTokenId(uint32 _domain, bytes32 _id) internal pure returns (bytes29) {
    return abi.encodePacked(_domain, _id).ref(0).castTo(uint40(Types.TokenId));
  }

  /**
   * @notice Formats the keccak256 hash of the token details
   * Token Details Format:
   *      length of name cast to bytes - 32 bytes
   *      name - x bytes (variable)
   *      length of symbol cast to bytes - 32 bytes
   *      symbol - x bytes (variable)
   *      decimals - 1 byte
   * @param _name The name
   * @param _symbol The symbol
   * @param _decimals The decimals
   * @return The Details message
   */
  function formatDetailsHash(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(bytes(_name).length, _name, bytes(_symbol).length, _symbol, _decimals));
  }

  /**
   * @notice Converts to a Message
   * @param _message The message
   * @return The newly typed message
   */
  function tryAsMessage(bytes29 _message) internal pure returns (bytes29) {
    if (isValidMessageLength(_message)) {
      return _message.castTo(uint40(Types.Message));
    }
    return TypedMemView.nullView();
  }

  // ============ Internal Functions: Parsing msg ============

  /**
   * @notice Returns the type of the message
   * @param _view The message
   * @return The type of the message
   */
  function messageType(bytes29 _view) internal pure returns (Types) {
    return Types(uint8(_view.typeOf()));
  }

  /**
   * @notice Retrieves the token ID from a Message
   * @param _message The message
   * @return The ID
   */
  function tokenId(bytes29 _message) internal pure typeAssert(_message, Types.Message) returns (bytes29) {
    return _message.slice(0, TOKEN_ID_LEN, uint40(Types.TokenId));
  }

  /**
   * @notice Retrieves the action data from a Message
   * @param _message The message
   * @return The action
   */
  function action(bytes29 _message) internal pure typeAssert(_message, Types.Message) returns (bytes29) {
    uint256 _actionLen = _message.len() - TOKEN_ID_LEN;
    uint40 _type = uint40(msgType(_message));
    return _message.slice(TOKEN_ID_LEN, _actionLen, _type);
  }

  // ============ Internal Functions: Parsing tokenId ============

  /**
   * @notice Retrieves the domain from a TokenID
   * @param _tokenId The message
   * @return The domain
   */
  function domain(bytes29 _tokenId) internal pure typeAssert(_tokenId, Types.TokenId) returns (uint32) {
    return uint32(_tokenId.indexUint(0, 4));
  }

  /**
   * @notice Retrieves the ID from a TokenID
   * @param _tokenId The message
   * @return The ID
   */
  function id(bytes29 _tokenId) internal pure typeAssert(_tokenId, Types.TokenId) returns (bytes32) {
    // before = 4 bytes domain
    return _tokenId.index(4, 32);
  }

  /**
   * @notice Retrieves the EVM ID
   * @param _tokenId The message
   * @return The EVM ID
   */
  function evmId(bytes29 _tokenId) internal pure typeAssert(_tokenId, Types.TokenId) returns (address) {
    // before = 4 bytes domain + 12 bytes empty to trim for address
    return _tokenId.indexAddress(16);
  }

  // ============ Internal Functions: Parsing action ============

  /**
   * @notice Retrieves the action identifier from message
   * @param _message The action
   * @return The message type
   */
  function msgType(bytes29 _message) internal pure returns (uint8) {
    return uint8(_message.indexUint(TOKEN_ID_LEN, 1));
  }

  /**
   * @notice Retrieves the identifier from action
   * @param _action The action
   * @return The action type
   */
  function actionType(bytes29 _action) internal pure returns (uint8) {
    return uint8(_action.indexUint(0, 1));
  }

  /**
   * @notice Retrieves the recipient from a Transfer
   * @param _transferAction The message
   * @return The recipient address as bytes32
   */
  function recipient(bytes29 _transferAction) internal pure returns (bytes32) {
    // before = 1 byte identifier
    return _transferAction.index(1, 32);
  }

  /**
   * @notice Retrieves the EVM Recipient from a Transfer
   * @param _transferAction The message
   * @return The EVM Recipient
   */
  function evmRecipient(bytes29 _transferAction) internal pure returns (address) {
    // before = 1 byte identifier + 12 bytes empty to trim for address = 13 bytes
    return _transferAction.indexAddress(13);
  }

  /**
   * @notice Retrieves the amount from a Transfer
   * @param _transferAction The message
   * @return The amount
   */
  function amnt(bytes29 _transferAction) internal pure returns (uint256) {
    // before = 1 byte identifier + 32 bytes ID = 33 bytes
    return _transferAction.indexUint(33, 32);
  }

  /**
   * @notice Retrieves the unique identifier from a Transfer
   * @param _transferAction The message
   * @return The amount
   */
  function transferId(bytes29 _transferAction) internal pure returns (bytes32) {
    // before = 1 byte identifier + 32 bytes ID + 32 bytes amount + 32 bytes detailsHash = 97 bytes
    return _transferAction.index(97, 32);
  }

  /**
   * @notice Retrieves the detailsHash from a Transfer
   * @param _transferAction The message
   * @return The detailsHash
   */
  function detailsHash(bytes29 _transferAction) internal pure returns (bytes32) {
    // before = 1 byte identifier + 32 bytes ID + 32 bytes amount = 65 bytes
    return _transferAction.index(65, 32);
  }
}


// : MIT OR Apache-2.0
pragma solidity 0.8.14;

library Encoding {
  // ============ Constants ============

  bytes private constant NIBBLE_LOOKUP = "0123456789abcdef";

  // ============ Internal Functions ============

  /**
   * @notice Encode a uint32 in its DECIMAL representation, with leading
   * zeroes.
   * @param _num The number to encode
   * @return _encoded The encoded number, suitable for use in abi.
   * encodePacked
   */
  function decimalUint32(uint32 _num) internal pure returns (uint80 _encoded) {
    uint80 ASCII_0 = 0x30;
    // all over/underflows are impossible
    // this will ALWAYS produce 10 decimal characters
    for (uint8 i = 0; i < 10; i += 1) {
      _encoded |= ((_num % 10) + ASCII_0) << (i * 8);
      _num = _num / 10;
    }
  }

  /**
   * @notice Encodes the uint256 to hex. `first` contains the encoded top 16 bytes.
   * `second` contains the encoded lower 16 bytes.
   * @param _bytes The 32 bytes as uint256
   * @return _firstHalf The top 16 bytes
   * @return _secondHalf The bottom 16 bytes
   */
  function encodeHex(uint256 _bytes) internal pure returns (uint256 _firstHalf, uint256 _secondHalf) {
    for (uint8 i = 31; i > 15; i -= 1) {
      uint8 _b = uint8(_bytes >> (i * 8));
      _firstHalf |= _byteHex(_b);
      if (i != 16) {
        _firstHalf <<= 16;
      }
    }
    // abusing underflow here =_=
    unchecked {
      for (uint8 i = 15; i < 255; i -= 1) {
        uint8 _b = uint8(_bytes >> (i * 8));
        _secondHalf |= _byteHex(_b);
        if (i != 0) {
          _secondHalf <<= 16;
        }
      }
    }
  }

  /**
   * @notice Returns the encoded hex character that represents the lower 4 bits of the argument.
   * @param _byte The byte
   * @return _char The encoded hex character
   */
  function _nibbleHex(uint8 _byte) private pure returns (uint8 _char) {
    uint8 _nibble = _byte & 0x0f; // keep bottom 4, 0 top 4
    _char = uint8(NIBBLE_LOOKUP[_nibble]);
  }

  /**
   * @notice Returns a uint16 containing the hex-encoded byte.
   * @param _byte The byte
   * @return _encoded The hex-encoded byte
   */
  function _byteHex(uint8 _byte) private pure returns (uint16 _encoded) {
    _encoded |= _nibbleHex(_byte >> 4); // top 4 bits
    _encoded <<= 8;
    _encoded |= _nibbleHex(_byte); // lower 4 bits
  }
}


// : UNLICENSED
pragma solidity 0.8.14;

//import{Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

//import{IProposedOwnable} from "./interfaces/IProposedOwnable.sol";

/**
 * @title ProposedOwnable
 * @notice Contract module which provides a basic access control mechanism,
 * where there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed via a two step process:
 * 1. Call `proposeOwner`
 * 2. Wait out the delay period
 * 3. Call `acceptOwner`
 *
 * @dev This module is used through inheritance. It will make available the
 * modifier `onlyOwner`, which can be applied to your functions to restrict
 * their use to the owner.
 *
 * @dev The majority of this code was taken from the openzeppelin Ownable
 * contract
 *
 */
abstract contract ProposedOwnable is IProposedOwnable {
  // ========== Custom Errors ===========

  error ProposedOwnable__onlyOwner_notOwner();
  error ProposedOwnable__onlyProposed_notProposedOwner();
  error ProposedOwnable__proposeNewOwner_invalidProposal();
  error ProposedOwnable__proposeNewOwner_noOwnershipChange();
  error ProposedOwnable__renounceOwnership_noProposal();
  error ProposedOwnable__renounceOwnership_delayNotElapsed();
  error ProposedOwnable__renounceOwnership_invalidProposal();
  error ProposedOwnable__acceptProposedOwner_delayNotElapsed();

  // ============ Properties ============

  address private _owner;

  address private _proposed;
  uint256 private _proposedOwnershipTimestamp;

  uint256 private constant _delay = 7 days;

  // ======== Getters =========

  /**
   * @notice Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @notice Returns the address of the proposed owner.
   */
  function proposed() public view virtual returns (address) {
    return _proposed;
  }

  /**
   * @notice Returns the address of the proposed owner.
   */
  function proposedTimestamp() public view virtual returns (uint256) {
    return _proposedOwnershipTimestamp;
  }

  /**
   * @notice Returns the delay period before a new owner can be accepted.
   */
  function delay() public view virtual returns (uint256) {
    return _delay;
  }

  /**
   * @notice Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    if (_owner != msg.sender) revert ProposedOwnable__onlyOwner_notOwner();
    _;
  }

  /**
   * @notice Throws if called by any account other than the proposed owner.
   */
  modifier onlyProposed() {
    if (_proposed != msg.sender) revert ProposedOwnable__onlyProposed_notProposedOwner();
    _;
  }

  /**
   * @notice Indicates if the ownership has been renounced() by
   * checking if current owner is address(0)
   */
  function renounced() public view returns (bool) {
    return _owner == address(0);
  }

  // ======== External =========

  /**
   * @notice Sets the timestamp for an owner to be proposed, and sets the
   * newly proposed owner as step 1 in a 2-step process
   */
  function proposeNewOwner(address newlyProposed) public virtual onlyOwner {
    // Contract as source of truth
    if (_proposed == newlyProposed && newlyProposed != address(0))
      revert ProposedOwnable__proposeNewOwner_invalidProposal();

    // Sanity check: reasonable proposal
    if (_owner == newlyProposed) revert ProposedOwnable__proposeNewOwner_noOwnershipChange();

    _setProposed(newlyProposed);
  }

  /**
   * @notice Renounces ownership of the contract after a delay
   */
  function renounceOwnership() public virtual onlyOwner {
    // Ensure there has been a proposal cycle started
    if (_proposedOwnershipTimestamp == 0) revert ProposedOwnable__renounceOwnership_noProposal();

    // Ensure delay has elapsed
    if ((block.timestamp - _proposedOwnershipTimestamp) <= _delay)
      revert ProposedOwnable__renounceOwnership_delayNotElapsed();

    // Require proposed is set to 0
    if (_proposed != address(0)) revert ProposedOwnable__renounceOwnership_invalidProposal();

    // Emit event, set new owner, reset timestamp
    _setOwner(_proposed);
  }

  /**
   * @notice Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function acceptProposedOwner() public virtual onlyProposed {
    // NOTE: no need to check if _owner == _proposed, because the _proposed
    // is 0-d out and this check is implicitly enforced by modifier

    // NOTE: no need to check if _proposedOwnershipTimestamp > 0 because
    // the only time this would happen is if the _proposed was never
    // set (will fail from modifier) or if the owner == _proposed (checked
    // above)

    // Ensure delay has elapsed
    if ((block.timestamp - _proposedOwnershipTimestamp) <= _delay)
      revert ProposedOwnable__acceptProposedOwner_delayNotElapsed();

    // Emit event, set new owner, reset timestamp
    _setOwner(_proposed);
  }

  // ======== Internal =========

  function _setOwner(address newOwner) internal {
    address oldOwner = _owner;
    _owner = newOwner;
    _proposedOwnershipTimestamp = 0;
    _proposed = address(0);
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  function _setProposed(address newlyProposed) private {
    _proposedOwnershipTimestamp = block.timestamp;
    _proposed = newlyProposed;
    emit OwnershipProposed(_proposed);
  }
}

abstract contract ProposedOwnableUpgradeable is Initializable, ProposedOwnable {
  /**
   * @dev Initializes the contract setting the deployer as the initial
   */
  function __ProposedOwnable_init() internal onlyInitializing {
    __ProposedOwnable_init_unchained();
  }

  function __ProposedOwnable_init_unchained() internal onlyInitializing {
    _setOwner(msg.sender);
  }

  /**
   * @dev This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[49] private __gap;
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ External Imports ============
//import{Home} from "../../nomad-core/contracts/Home.sol";
//import{XAppConnectionManager} from "../../nomad-core/contracts/XAppConnectionManager.sol";

//import{ProposedOwnableUpgradeable} from "./ProposedOwnable.sol";

abstract contract XAppConnectionClient is ProposedOwnableUpgradeable {
  // ============ Mutable Storage ============

  XAppConnectionManager public xAppConnectionManager;
  uint256[49] private __GAP; // gap for upgrade safety

  // ============ Modifiers ============

  /**
   * @notice Only accept messages from an Nomad Replica contract
   */
  modifier onlyReplica() {
    require(_isReplica(msg.sender), "!replica");
    _;
  }

  // ======== Initializer =========

  function __XAppConnectionClient_initialize(address _xAppConnectionManager) internal initializer {
    xAppConnectionManager = XAppConnectionManager(_xAppConnectionManager);
    __ProposedOwnable_init();
  }

  // ============ External functions ============

  /**
   * @notice Modify the contract the xApp uses to validate Replica contracts
   * @param _xAppConnectionManager The address of the xAppConnectionManager contract
   */
  function setXAppConnectionManager(address _xAppConnectionManager) external onlyOwner {
    xAppConnectionManager = XAppConnectionManager(_xAppConnectionManager);
  }

  // ============ Internal functions ============

  /**
   * @notice Get the local Home contract from the xAppConnectionManager
   * @return The local Home contract
   */
  function _home() internal view returns (Home) {
    return xAppConnectionManager.home();
  }

  /**
   * @notice Determine whether _potentialReplcia is an enrolled Replica from the xAppConnectionManager
   * @return True if _potentialReplica is an enrolled Replica
   */
  function _isReplica(address _potentialReplica) internal view returns (bool) {
    return xAppConnectionManager.isReplica(_potentialReplica);
  }

  /**
   * @notice Get the local domain from the xAppConnectionManager
   * @return The local domain
   */
  function _localDomain() internal view virtual returns (uint32) {
    return xAppConnectionManager.localDomain();
  }
}


// : MIT
pragma solidity 0.8.14;

/**
 * @title IProposedOwnable
 * @notice Defines a minimal interface for ownership with a two step proposal and acceptance
 * process
 */
interface IProposedOwnable {
  /**
   * @dev This emits when change in ownership of a contract is proposed.
   */
  event OwnershipProposed(address indexed proposedOwner);

  /**
   * @dev This emits when ownership of a contract changes.
   */
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @notice Get the address of the owner
   * @return owner_ The address of the owner.
   */
  function owner() external view returns (address owner_);

  /**
   * @notice Get the address of the proposed owner
   * @return proposed_ The address of the proposed.
   */
  function proposed() external view returns (address proposed_);

  /**
   * @notice Set the address of the proposed owner of the contract
   * @param newlyProposed The proposed new owner of the contract
   */
  function proposeNewOwner(address newlyProposed) external;

  /**
   * @notice Set the address of the proposed owner of the contract
   */
  function acceptProposedOwner() external;
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{Version0} from "./Version0.sol";
//import{NomadBase} from "./NomadBase.sol";
//import{QueueLib} from "../libs/Queue.sol";
//import{MerkleLib} from "../libs/Merkle.sol";
//import{Message} from "../libs/Message.sol";
//import{MerkleTreeManager} from "./Merkle.sol";
//import{QueueManager} from "./Queue.sol";
//import{IUpdaterManager} from "../interfaces/IUpdaterManager.sol";
// ============ External Imports ============
//import{Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Home
 * @author Illusory Systems Inc.
 * @notice Accepts messages to be dispatched to remote chains,
 * constructs a Merkle tree of the messages,
 * and accepts signatures from a bonded Updater
 * which notarize the Merkle tree roots.
 * Accepts submissions of fraudulent signatures
 * by the Updater and slashes the Updater in this case.
 */
contract Home is Version0, QueueManager, MerkleTreeManager, NomadBase {
  // ============ Libraries ============

  using QueueLib for QueueLib.Queue;
  using MerkleLib for MerkleLib.Tree;

  // ============ Constants ============

  // Maximum bytes per message = 2 KiB
  // (somewhat arbitrarily set to begin)
  uint256 public constant MAX_MESSAGE_BODY_BYTES = 2 * 2**10;

  // ============ Public Storage Variables ============

  // domain => next available nonce for the domain
  mapping(uint32 => uint32) public nonces;
  // contract responsible for Updater bonding, slashing and rotation
  IUpdaterManager public updaterManager;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[48] private __GAP;

  // ============ Events ============

  /**
   * @notice Emitted when a new message is dispatched via Nomad
   * @param leafIndex Index of message's leaf in merkle tree
   * @param destinationAndNonce Destination and destination-specific
   * nonce combined in single field ((destination << 32) & nonce)
   * @param messageHash Hash of message; the leaf inserted to the Merkle tree for the message
   * @param committedRoot the latest notarized root submitted in the last signed Update
   * @param message Raw bytes of message
   */
  event Dispatch(
    bytes32 indexed messageHash,
    uint256 indexed leafIndex,
    uint64 indexed destinationAndNonce,
    bytes32 committedRoot,
    bytes message
  );

  /**
   * @notice Emitted when proof of an improper update is submitted,
   * which sets the contract to FAILED state
   * @param oldRoot Old root of the improper update
   * @param newRoot New root of the improper update
   * @param signature Signature on `oldRoot` and `newRoot
   */
  event ImproperUpdate(bytes32 oldRoot, bytes32 newRoot, bytes signature);

  /**
   * @notice Emitted when the Updater is slashed
   * (should be paired with ImproperUpdater or DoubleUpdate event)
   * @param updater The address of the updater
   * @param reporter The address of the entity that reported the updater misbehavior
   */
  event UpdaterSlashed(address indexed updater, address indexed reporter);

  /**
   * @notice Emitted when the UpdaterManager contract is changed
   * @param updaterManager The address of the new updaterManager
   */
  event NewUpdaterManager(address updaterManager);

  // ============ Constructor ============

  constructor(uint32 _localDomain) NomadBase(_localDomain) {} // solhint-disable-line no-empty-blocks

  // ============ Initializer ============

  function initialize(IUpdaterManager _updaterManager) public initializer {
    // initialize queue, set Updater Manager, and initialize
    __QueueManager_initialize();
    _setUpdaterManager(_updaterManager);
    __NomadBase_initialize(updaterManager.updater());
  }

  // ============ Modifiers ============

  /**
   * @notice Ensures that function is called by the UpdaterManager contract
   */
  modifier onlyUpdaterManager() {
    require(msg.sender == address(updaterManager), "!updaterManager");
    _;
  }

  // ============ External: Updater & UpdaterManager Configuration  ============

  /**
   * @notice Set a new Updater
   * @param _updater the new Updater
   */
  function setUpdater(address _updater) external onlyUpdaterManager {
    _setUpdater(_updater);
  }

  /**
   * @notice Set a new UpdaterManager contract
   * @dev Home(s) will initially be initialized using a trusted UpdaterManager contract;
   * we will progressively decentralize by swapping the trusted contract with a new implementation
   * that implements Updater bonding & slashing, and rules for Updater selection & rotation
   * @param _updaterManager the new UpdaterManager contract
   */
  function setUpdaterManager(address _updaterManager) external onlyOwner {
    _setUpdaterManager(IUpdaterManager(_updaterManager));
  }

  // ============ External Functions  ============

  /**
   * @notice Dispatch the message it to the destination domain & recipient
   * @dev Format the message, insert its hash into Merkle tree,
   * enqueue the new Merkle root, and emit `Dispatch` event with message information.
   * @param _destinationDomain Domain of destination chain
   * @param _recipientAddress Address of recipient on destination chain as bytes32
   * @param _messageBody Raw bytes content of message
   */
  function dispatch(
    uint32 _destinationDomain,
    bytes32 _recipientAddress,
    bytes memory _messageBody
  ) external notFailed {
    require(_messageBody.length <= MAX_MESSAGE_BODY_BYTES, "msg too long");
    // get the next nonce for the destination domain, then increment it
    uint32 _nonce = nonces[_destinationDomain];
    nonces[_destinationDomain] = _nonce + 1;
    // format the message into packed bytes
    bytes memory _message = Message.formatMessage(
      localDomain,
      bytes32(uint256(uint160(msg.sender))),
      _nonce,
      _destinationDomain,
      _recipientAddress,
      _messageBody
    );
    // insert the hashed message into the Merkle tree
    bytes32 _messageHash = keccak256(_message);
    tree.insert(_messageHash);
    // enqueue the new Merkle root after inserting the message
    queue.enqueue(root());
    // Emit Dispatch event with message information
    // note: leafIndex is count() - 1 since new leaf has already been inserted
    emit Dispatch(_messageHash, count() - 1, _destinationAndNonce(_destinationDomain, _nonce), committedRoot, _message);
  }

  /**
   * @notice Submit a signature from the Updater "notarizing" a root,
   * which updates the Home contract's `committedRoot`,
   * and publishes the signature which will be relayed to Replica contracts
   * @dev emits Update event
   * @dev If _newRoot is not contained in the queue,
   * the Update is a fraudulent Improper Update, so
   * the Updater is slashed & Home is set to FAILED state
   * @param _committedRoot Current updated merkle root which the update is building off of
   * @param _newRoot New merkle root to update the contract state to
   * @param _signature Updater signature on `_committedRoot` and `_newRoot`
   */
  function update(
    bytes32 _committedRoot,
    bytes32 _newRoot,
    bytes memory _signature
  ) external notFailed {
    // check that the update is not fraudulent;
    // if fraud is detected, Updater is slashed & Home is set to FAILED state
    if (improperUpdate(_committedRoot, _newRoot, _signature)) return;
    // clear all of the intermediate roots contained in this update from the queue
    while (true) {
      bytes32 _next = queue.dequeue();
      if (_next == _newRoot) break;
    }
    // update the Home state with the latest signed root & emit event
    committedRoot = _newRoot;
    emit Update(localDomain, _committedRoot, _newRoot, _signature);
  }

  /**
   * @notice Suggest an update for the Updater to sign and submit.
   * @dev If queue is empty, null bytes returned for both
   * (No update is necessary because no messages have been dispatched since the last update)
   * @return _committedRoot Latest root signed by the Updater
   * @return _new Latest enqueued Merkle root
   */
  function suggestUpdate() external view returns (bytes32 _committedRoot, bytes32 _new) {
    if (queue.length() != 0) {
      _committedRoot = committedRoot;
      _new = queue.lastItem();
    }
  }

  // ============ Public Functions  ============

  /**
   * @notice Hash of Home domain concatenated with "NOMAD"
   */
  function homeDomainHash() public view override returns (bytes32) {
    return _homeDomainHash(localDomain);
  }

  /**
   * @notice Check if an Update is an Improper Update;
   * if so, slash the Updater and set the contract to FAILED state.
   *
   * An Improper Update is an update building off of the Home's `committedRoot`
   * for which the `_newRoot` does not currently exist in the Home's queue.
   * This would mean that message(s) that were not truly
   * dispatched on Home were falsely included in the signed root.
   *
   * An Improper Update will only be accepted as valid by the Replica
   * If an Improper Update is attempted on Home,
   * the Updater will be slashed immediately.
   * If an Improper Update is submitted to the Replica,
   * it should be relayed to the Home contract using this function
   * in order to slash the Updater with an Improper Update.
   *
   * An Improper Update submitted to the Replica is only valid
   * while the `_oldRoot` is still equal to the `committedRoot` on Home;
   * if the `committedRoot` on Home has already been updated with a valid Update,
   * then the Updater should be slashed with a Double Update.
   * @dev Reverts (and doesn't slash updater) if signature is invalid or
   * update not current
   * @param _oldRoot Old merkle tree root (should equal home's committedRoot)
   * @param _newRoot New merkle tree root
   * @param _signature Updater signature on `_oldRoot` and `_newRoot`
   * @return TRUE if update was an Improper Update (implying Updater was slashed)
   */
  function improperUpdate(
    bytes32 _oldRoot,
    bytes32 _newRoot,
    bytes memory _signature
  ) public notFailed returns (bool) {
    require(_isUpdaterSignature(_oldRoot, _newRoot, _signature), "!updater sig");
    require(_oldRoot == committedRoot, "not a current update");
    // if the _newRoot is not currently contained in the queue,
    // slash the Updater and set the contract to FAILED state
    if (!queue.contains(_newRoot)) {
      _fail();
      emit ImproperUpdate(_oldRoot, _newRoot, _signature);
      return true;
    }
    // if the _newRoot is contained in the queue,
    // this is not an improper update
    return false;
  }

  // ============ Internal Functions  ============

  /**
   * @notice Set the UpdaterManager
   * @param _updaterManager Address of the UpdaterManager
   */
  function _setUpdaterManager(IUpdaterManager _updaterManager) internal {
    require(Address.isContract(address(_updaterManager)), "!contract updaterManager");
    updaterManager = IUpdaterManager(_updaterManager);
    emit NewUpdaterManager(address(_updaterManager));
  }

  /**
   * @notice Slash the Updater and set contract state to FAILED
   * @dev Called when fraud is proven (Improper Update or Double Update)
   */
  function _fail() internal override {
    // set contract to FAILED
    _setFailed();
    // slash Updater
    updaterManager.slashUpdater(payable(msg.sender));
    emit UpdaterSlashed(updater, msg.sender);
  }

  /**
   * @notice Internal utility function that combines
   * `_destination` and `_nonce`.
   * @dev Both destination and nonce should be less than 2^32 - 1
   * @param _destination Domain of destination chain
   * @param _nonce Current nonce for given destination chain
   * @return Returns (`_destination` << 32) & `_nonce`
   */
  function _destinationAndNonce(uint32 _destination, uint32 _nonce) internal pure returns (uint64) {
    return (uint64(_destination) << 32) | _nonce;
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{MerkleLib} from "../libs/Merkle.sol";

/**
 * @title MerkleTreeManager
 * @author Illusory Systems Inc.
 * @notice Contains a Merkle tree instance and
 * exposes view functions for the tree.
 */
contract MerkleTreeManager {
  // ============ Libraries ============

  using MerkleLib for MerkleLib.Tree;
  MerkleLib.Tree public tree;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[49] private __GAP;

  // ============ Public Functions ============

  /**
   * @notice Calculates and returns tree's current root
   */
  function root() public view returns (bytes32) {
    return tree.root();
  }

  /**
   * @notice Returns the number of inserted leaves in the tree (current index)
   */
  function count() public view returns (uint256) {
    return tree.count;
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{Message} from "../libs/Message.sol";
// ============ External Imports ============
//import{ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//import{Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import{OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title NomadBase
 * @author Illusory Systems Inc.
 * @notice Shared utilities between Home and Replica.
 */
abstract contract NomadBase is Initializable, OwnableUpgradeable {
  // ============ Enums ============

  // States:
  //   0 - UnInitialized - before initialize function is called
  //   note: the contract is initialized at deploy time, so it should never be in this state
  //   1 - Active - as long as the contract has not become fraudulent
  //   2 - Failed - after a valid fraud proof has been submitted;
  //   contract will no longer accept updates or new messages
  enum States {
    UnInitialized,
    Active,
    Failed
  }

  // ============ Immutable Variables ============

  // Domain of chain on which the contract is deployed
  uint32 public immutable localDomain;

  // ============ Public Variables ============

  // Address of bonded Updater
  address public updater;
  // Current state of contract
  States public state;
  // The latest root that has been signed by the Updater
  bytes32 public committedRoot;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[47] private __GAP;

  // ============ Events ============

  /**
   * @notice Emitted when update is made on Home
   * or unconfirmed update root is submitted on Replica
   * @param homeDomain Domain of home contract
   * @param oldRoot Old merkle root
   * @param newRoot New merkle root
   * @param signature Updater's signature on `oldRoot` and `newRoot`
   */
  event Update(uint32 indexed homeDomain, bytes32 indexed oldRoot, bytes32 indexed newRoot, bytes signature);

  /**
   * @notice Emitted when proof of a double update is submitted,
   * which sets the contract to FAILED state
   * @param oldRoot Old root shared between two conflicting updates
   * @param newRoot Array containing two conflicting new roots
   * @param signature Signature on `oldRoot` and `newRoot`[0]
   * @param signature2 Signature on `oldRoot` and `newRoot`[1]
   */
  event DoubleUpdate(bytes32 oldRoot, bytes32[2] newRoot, bytes signature, bytes signature2);

  /**
   * @notice Emitted when Updater is rotated
   * @param oldUpdater The address of the old updater
   * @param newUpdater The address of the new updater
   */
  event NewUpdater(address oldUpdater, address newUpdater);

  // ============ Modifiers ============

  /**
   * @notice Ensures that contract state != FAILED when the function is called
   */
  modifier notFailed() {
    require(state != States.Failed, "failed state");
    _;
  }

  // ============ Constructor ============

  constructor(uint32 _localDomain) {
    localDomain = _localDomain;
  }

  // ============ Initializer ============

  function __NomadBase_initialize(address _updater) internal initializer {
    __Ownable_init();
    _setUpdater(_updater);
    state = States.Active;
  }

  // ============ External Functions ============

  /**
   * @notice Called by external agent. Checks that signatures on two sets of
   * roots are valid and that the new roots conflict with each other. If both
   * cases hold true, the contract is failed and a `DoubleUpdate` event is
   * emitted.
   * @dev When `fail()` is called on Home, updater is slashed.
   * @param _oldRoot Old root shared between two conflicting updates
   * @param _newRoot Array containing two conflicting new roots
   * @param _signature Signature on `_oldRoot` and `_newRoot`[0]
   * @param _signature2 Signature on `_oldRoot` and `_newRoot`[1]
   */
  function doubleUpdate(
    bytes32 _oldRoot,
    bytes32[2] calldata _newRoot,
    bytes calldata _signature,
    bytes calldata _signature2
  ) external notFailed {
    if (
      NomadBase._isUpdaterSignature(_oldRoot, _newRoot[0], _signature) &&
      NomadBase._isUpdaterSignature(_oldRoot, _newRoot[1], _signature2) &&
      _newRoot[0] != _newRoot[1]
    ) {
      _fail();
      emit DoubleUpdate(_oldRoot, _newRoot, _signature, _signature2);
    }
  }

  // ============ Public Functions ============

  /**
   * @notice Hash of Home domain concatenated with "NOMAD"
   */
  function homeDomainHash() public view virtual returns (bytes32);

  // ============ Internal Functions ============

  /**
   * @notice Hash of Home domain concatenated with "NOMAD"
   * @param _homeDomain the Home domain to hash
   */
  function _homeDomainHash(uint32 _homeDomain) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_homeDomain, "NOMAD"));
  }

  /**
   * @notice Set contract state to FAILED
   * @dev Called when a valid fraud proof is submitted
   */
  function _setFailed() internal {
    state = States.Failed;
  }

  /**
   * @notice Moves the contract into failed state
   * @dev Called when fraud is proven
   * (Double Update is submitted on Home or Replica,
   * or Improper Update is submitted on Home)
   */
  function _fail() internal virtual;

  /**
   * @notice Set the Updater
   * @param _newUpdater Address of the new Updater
   */
  function _setUpdater(address _newUpdater) internal {
    address _oldUpdater = updater;
    updater = _newUpdater;
    emit NewUpdater(_oldUpdater, _newUpdater);
  }

  /**
   * @notice Checks that signature was signed by Updater
   * @param _oldRoot Old merkle root
   * @param _newRoot New merkle root
   * @param _signature Signature on `_oldRoot` and `_newRoot`
   * @return TRUE iff signature is valid signed by updater
   **/
  function _isUpdaterSignature(
    bytes32 _oldRoot,
    bytes32 _newRoot,
    bytes memory _signature
  ) internal view returns (bool) {
    bytes32 _digest = keccak256(abi.encodePacked(homeDomainHash(), _oldRoot, _newRoot));
    _digest = ECDSA.toEthSignedMessageHash(_digest);
    return (ECDSA.recover(_digest, _signature) == updater);
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{QueueLib} from "../libs/Queue.sol";
// ============ External Imports ============
//import{Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title QueueManager
 * @author Illusory Systems Inc.
 * @notice Contains a queue instance and
 * exposes view functions for the queue.
 **/
contract QueueManager is Initializable {
  // ============ Libraries ============

  using QueueLib for QueueLib.Queue;
  QueueLib.Queue internal queue;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[49] private __GAP;

  // ============ Initializer ============

  function __QueueManager_initialize() internal initializer {
    queue.initialize();
  }

  // ============ Public Functions ============

  /**
   * @notice Returns number of elements in queue
   */
  function queueLength() external view returns (uint256) {
    return queue.length();
  }

  /**
   * @notice Returns TRUE iff `_item` is in the queue
   */
  function queueContains(bytes32 _item) external view returns (bool) {
    return queue.contains(_item);
  }

  /**
   * @notice Returns last item enqueued to the queue
   */
  function queueEnd() external view returns (bytes32) {
    return queue.lastItem();
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{Version0} from "./Version0.sol";
//import{NomadBase} from "./NomadBase.sol";
//import{MerkleLib} from "../libs/Merkle.sol";
//import{Message} from "../libs/Message.sol";
// ============ External Imports ============
// //import{TypedMemView} from "@summa-tx/memview-sol/contracts/TypedMemView.sol";
//import{TypedMemView} from "../libs/TypedMemView.sol";

/**
 * @title Replica
 * @author Illusory Systems Inc.
 * @notice Track root updates on Home,
 * prove and dispatch messages to end recipients.
 */
contract Replica is Version0, NomadBase {
  // ============ Libraries ============

  using MerkleLib for MerkleLib.Tree;
  using TypedMemView for bytes;
  using TypedMemView for bytes29;
  using Message for bytes29;

  // ============ Enums ============

  // Status of Message:
  //   0 - None - message has not been proven or processed
  //   1 - Proven - message inclusion proof has been validated
  //   2 - Processed - message has been dispatched to recipient
  enum MessageStatus {
    None,
    Proven,
    Processed
  }

  // ============ Immutables ============

  // Minimum gas for message processing
  uint256 public immutable PROCESS_GAS;
  // Reserved gas (to ensure tx completes in case message processing runs out)
  uint256 public immutable RESERVE_GAS;

  // ============ Public Storage ============

  // Domain of home chain
  uint32 public remoteDomain;
  // Number of seconds to wait before root becomes confirmable
  uint256 public optimisticSeconds;
  // re-entrancy guard
  uint8 private entered;
  // Mapping of roots to allowable confirmation times
  mapping(bytes32 => uint256) public confirmAt;
  // Mapping of message leaves to MessageStatus
  mapping(bytes32 => MessageStatus) public messages;

  // ============ Upgrade Gap ============

  // gap for upgrade safety
  uint256[45] private __GAP;

  // ============ Events ============

  /**
   * @notice Emitted when message is processed
   * @param messageHash Hash of message that failed to process
   * @param success TRUE if the call was executed successfully, FALSE if the call reverted
   * @param returnData the return data from the external call
   */
  event Process(bytes32 indexed messageHash, bool indexed success, bytes indexed returnData);

  /**
   * @notice Emitted when the value for optimisticTimeout is set
   * @param timeout The new value for optimistic timeout
   */
  event SetOptimisticTimeout(uint256 timeout);

  /**
   * @notice Emitted when a root's confirmation is modified by governance
   * @param root The root for which confirmAt has been set
   * @param previousConfirmAt The previous value of confirmAt
   * @param newConfirmAt The new value of confirmAt
   */
  event SetConfirmation(bytes32 indexed root, uint256 previousConfirmAt, uint256 newConfirmAt);

  // ============ Constructor ============

  // solhint-disable-next-line no-empty-blocks
  constructor(
    uint32 _localDomain,
    uint256 _processGas,
    uint256 _reserveGas
  ) NomadBase(_localDomain) {
    require(_processGas >= 850_000, "!process gas");
    require(_reserveGas >= 15_000, "!reserve gas");
    PROCESS_GAS = _processGas;
    RESERVE_GAS = _reserveGas;
  }

  // ============ Initializer ============

  function initialize(
    uint32 _remoteDomain,
    address _updater,
    bytes32 _committedRoot,
    uint256 _optimisticSeconds
  ) public initializer {
    __NomadBase_initialize(_updater);
    // set storage variables
    entered = 1;
    remoteDomain = _remoteDomain;
    committedRoot = _committedRoot;
    confirmAt[_committedRoot] = 1;
    optimisticSeconds = _optimisticSeconds;
    emit SetOptimisticTimeout(_optimisticSeconds);
  }

  // ============ External Functions ============

  /**
   * @notice Called by external agent. Submits the signed update's new root,
   * marks root's allowable confirmation time, and emits an `Update` event.
   * @dev Reverts if update doesn't build off latest committedRoot
   * or if signature is invalid.
   * @param _oldRoot Old merkle root
   * @param _newRoot New merkle root
   * @param _signature Updater's signature on `_oldRoot` and `_newRoot`
   */
  function update(
    bytes32 _oldRoot,
    bytes32 _newRoot,
    bytes memory _signature
  ) external notFailed {
    // ensure that update is building off the last submitted root
    require(_oldRoot == committedRoot, "not current update");
    // validate updater signature
    require(_isUpdaterSignature(_oldRoot, _newRoot, _signature), "!updater sig");
    // Hook for future use
    _beforeUpdate();
    // set the new root's confirmation timer
    confirmAt[_newRoot] = block.timestamp + optimisticSeconds;
    // update committedRoot
    committedRoot = _newRoot;
    emit Update(remoteDomain, _oldRoot, _newRoot, _signature);
  }

  /**
   * @notice First attempts to prove the validity of provided formatted
   * `message`. If the message is successfully proven, then tries to process
   * message.
   * @dev Reverts if `prove` call returns false
   * @param _message Formatted message (refer to NomadBase.sol Message library)
   * @param _proof Merkle proof of inclusion for message's leaf
   * @param _index Index of leaf in home's merkle tree
   */
  function proveAndProcess(
    bytes memory _message,
    bytes32[32] calldata _proof,
    uint256 _index
  ) external {
    require(prove(keccak256(_message), _proof, _index), "!prove");
    process(_message);
  }

  /**
   * @notice Given formatted message, attempts to dispatch
   * message payload to end recipient.
   * @dev Recipient must implement a `handle` method (refer to IMessageRecipient.sol)
   * Reverts if formatted message's destination domain is not the Replica's domain,
   * if message has not been proven,
   * or if not enough gas is provided for the dispatch transaction.
   * @param _message Formatted message
   * @return _success TRUE iff dispatch transaction succeeded
   */
  function process(bytes memory _message) public returns (bool _success) {
    bytes29 _m = _message.ref(0);
    // ensure message was meant for this domain
    require(_m.destination() == localDomain, "!destination");
    // ensure message has been proven
    bytes32 _messageHash = _m.keccak();
    require(messages[_messageHash] == MessageStatus.Proven, "!proven");
    // check re-entrancy guard
    require(entered == 1, "!reentrant");
    entered = 0;
    // update message status as processed
    messages[_messageHash] = MessageStatus.Processed;
    // A call running out of gas TYPICALLY errors the whole tx. We want to
    // a) ensure the call has a sufficient amount of gas to make a
    //    meaningful state change.
    // b) ensure that if the subcall runs out of gas, that the tx as a whole
    //    does not revert (i.e. we still mark the message processed)
    // To do this, we require that we have enough gas to process
    // and still return. We then delegate only the minimum processing gas.
    require(gasleft() >= PROCESS_GAS + RESERVE_GAS, "!gas");
    // get the message recipient
    address _recipient = _m.recipientAddress();
    // set up for assembly call
    uint256 _toCopy;
    uint256 _maxCopy = 256;
    uint256 _gas = PROCESS_GAS;
    // allocate memory for returndata
    bytes memory _returnData = new bytes(_maxCopy);
    bytes memory _calldata = abi.encodeWithSignature(
      "handle(uint32,uint32,bytes32,bytes)",
      _m.origin(),
      _m.nonce(),
      _m.sender(),
      _m.body().clone()
    );
    // dispatch message to recipient
    // by assembly calling "handle" function
    // we call via assembly to avoid memcopying a very large returndata
    // returned by a malicious contract
    assembly {
      _success := call(
        _gas, // gas
        _recipient, // recipient
        0, // ether value
        add(_calldata, 0x20), // inloc
        mload(_calldata), // inlen
        0, // outloc
        0 // outlen
      )
      // limit our copy to 256 bytes
      _toCopy := returndatasize()
      if gt(_toCopy, _maxCopy) {
        _toCopy := _maxCopy
      }
      // Store the length of the copied bytes
      mstore(_returnData, _toCopy)
      // copy the bytes from returndata[0:_toCopy]
      returndatacopy(add(_returnData, 0x20), 0, _toCopy)
    }
    // emit process results
    emit Process(_messageHash, _success, _returnData);
    // reset re-entrancy guard
    entered = 1;
  }

  // ============ External Owner Functions ============

  /**
   * @notice Set optimistic timeout period for new roots
   * @dev Only callable by owner (Governance)
   * @param _optimisticSeconds New optimistic timeout period
   */
  function setOptimisticTimeout(uint256 _optimisticSeconds) external onlyOwner {
    optimisticSeconds = _optimisticSeconds;
    emit SetOptimisticTimeout(_optimisticSeconds);
  }

  /**
   * @notice Set Updater role
   * @dev MUST ensure that all roots signed by previous Updater have
   * been relayed before calling. Only callable by owner (Governance)
   * @param _updater New Updater
   */
  function setUpdater(address _updater) external onlyOwner {
    _setUpdater(_updater);
  }

  /**
   * @notice Set confirmAt for a given root
   * @dev To be used if in the case that fraud is proven
   * and roots need to be deleted / added. Only callable by owner (Governance)
   * @param _root The root for which to modify confirm time
   * @param _confirmAt The new confirmation time. Set to 0 to "delete" a root.
   */
  function setConfirmation(bytes32 _root, uint256 _confirmAt) external onlyOwner {
    uint256 _previousConfirmAt = confirmAt[_root];
    confirmAt[_root] = _confirmAt;
    emit SetConfirmation(_root, _previousConfirmAt, _confirmAt);
  }

  // ============ Public Functions ============

  /**
   * @notice Check that the root has been submitted
   * and that the optimistic timeout period has expired,
   * meaning the root can be processed
   * @param _root the Merkle root, submitted in an update, to check
   * @return TRUE iff root has been submitted & timeout has expired
   */
  function acceptableRoot(bytes32 _root) public view returns (bool) {
    uint256 _time = confirmAt[_root];
    if (_time == 0) {
      return false;
    }
    return block.timestamp >= _time;
  }

  /**
   * @notice Attempts to prove the validity of message given its leaf, the
   * merkle proof of inclusion for the leaf, and the index of the leaf.
   * @dev Reverts if message's MessageStatus != None (i.e. if message was
   * already proven or processed)
   * @dev For convenience, we allow proving against any previous root.
   * This means that witnesses never need to be updated for the new root
   * @param _leaf Leaf of message to prove
   * @param _proof Merkle proof of inclusion for leaf
   * @param _index Index of leaf in home's merkle tree
   * @return Returns true if proof was valid and `prove` call succeeded
   **/
  function prove(
    bytes32 _leaf,
    bytes32[32] calldata _proof,
    uint256 _index
  ) public returns (bool) {
    // ensure that message has not been proven or processed
    require(messages[_leaf] == MessageStatus.None, "!MessageStatus.None");
    // calculate the expected root based on the proof
    bytes32 _calculatedRoot = MerkleLib.branchRoot(_leaf, _proof, _index);
    // if the root is valid, change status to Proven
    if (acceptableRoot(_calculatedRoot)) {
      messages[_leaf] = MessageStatus.Proven;
      return true;
    }
    return false;
  }

  /**
   * @notice Hash of Home domain concatenated with "NOMAD"
   */
  function homeDomainHash() public view override returns (bytes32) {
    return _homeDomainHash(remoteDomain);
  }

  // ============ Internal Functions ============

  /**
   * @notice Moves the contract into failed state
   * @dev Called when a Double Update is submitted
   */
  function _fail() internal override {
    _setFailed();
  }

  /// @notice Hook for potential future use
  // solhint-disable-next-line no-empty-blocks
  function _beforeUpdate() internal {}
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

/**
 * @title Version0
 * @notice Version getter for contracts
 **/
contract Version0 {
  uint8 public constant VERSION = 0;
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// ============ Internal Imports ============
//import{Home} from "./Home.sol";
//import{Replica} from "./Replica.sol";
//import{TypeCasts} from "../libs/TypeCasts.sol";
// ============ External Imports ============
//import{ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//import{Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title XAppConnectionManager
 * @author Illusory Systems Inc.
 * @notice Manages a registry of local Replica contracts
 * for remote Home domains. Accepts Watcher signatures
 * to un-enroll Replicas attached to fraudulent remote Homes
 */
contract XAppConnectionManager is Ownable {
  // ============ Public Storage ============

  // Home contract
  Home public home;
  // local Replica address => remote Home domain
  mapping(address => uint32) public replicaToDomain;
  // remote Home domain => local Replica address
  mapping(uint32 => address) public domainToReplica;
  // watcher address => replica remote domain => has/doesn't have permission
  mapping(address => mapping(uint32 => bool)) private watcherPermissions;

  // ============ Events ============

  /**
   * @notice Emitted when a new Replica is enrolled / added
   * @param domain the remote domain of the Home contract for the Replica
   * @param replica the address of the Replica
   */
  event ReplicaEnrolled(uint32 indexed domain, address replica);

  /**
   * @notice Emitted when a new Replica is un-enrolled / removed
   * @param domain the remote domain of the Home contract for the Replica
   * @param replica the address of the Replica
   */
  event ReplicaUnenrolled(uint32 indexed domain, address replica);

  /**
   * @notice Emitted when Watcher permissions are changed
   * @param domain the remote domain of the Home contract for the Replica
   * @param watcher the address of the Watcher
   * @param access TRUE if the Watcher was given permissions, FALSE if permissions were removed
   */
  event WatcherPermissionSet(uint32 indexed domain, address watcher, bool access);

  // ============ Modifiers ============

  modifier onlyReplica() {
    require(isReplica(msg.sender), "!replica");
    _;
  }

  // ============ Constructor ============

  // solhint-disable-next-line no-empty-blocks
  constructor() Ownable() {}

  // ============ External Functions ============

  /**
   * @notice Un-Enroll a replica contract
   * in the case that fraud was detected on the Home
   * @dev in the future, if fraud occurs on the Home contract,
   * the Watcher will submit their signature directly to the Home
   * and it can be relayed to all remote chains to un-enroll the Replicas
   * @param _domain the remote domain of the Home contract for the Replica
   * @param _updater the address of the Updater for the Home contract (also stored on Replica)
   * @param _signature signature of watcher on (domain, replica address, updater address)
   */
  function unenrollReplica(
    uint32 _domain,
    bytes32 _updater,
    bytes memory _signature
  ) external {
    // ensure that the replica is currently set
    address _replica = domainToReplica[_domain];
    require(_replica != address(0), "!replica exists");
    // ensure that the signature is on the proper updater
    require(Replica(_replica).updater() == TypeCasts.bytes32ToAddress(_updater), "!current updater");
    // get the watcher address from the signature
    // and ensure that the watcher has permission to un-enroll this replica
    address _watcher = _recoverWatcherFromSig(_domain, TypeCasts.addressToBytes32(_replica), _updater, _signature);
    require(watcherPermissions[_watcher][_domain], "!valid watcher");
    // remove the replica from mappings
    _unenrollReplica(_replica);
  }

  /**
   * @notice Set the address of the local Home contract
   * @param _home the address of the local Home contract
   */
  function setHome(address _home) external onlyOwner {
    home = Home(_home);
  }

  /**
   * @notice Allow Owner to enroll Replica contract
   * @param _replica the address of the Replica
   * @param _domain the remote domain of the Home contract for the Replica
   */
  function ownerEnrollReplica(address _replica, uint32 _domain) external onlyOwner {
    // un-enroll any existing replica
    _unenrollReplica(_replica);
    // add replica and domain to two-way mapping
    replicaToDomain[_replica] = _domain;
    domainToReplica[_domain] = _replica;
    emit ReplicaEnrolled(_domain, _replica);
  }

  /**
   * @notice Allow Owner to un-enroll Replica contract
   * @param _replica the address of the Replica
   */
  function ownerUnenrollReplica(address _replica) external onlyOwner {
    _unenrollReplica(_replica);
  }

  /**
   * @notice Allow Owner to set Watcher permissions for a Replica
   * @param _watcher the address of the Watcher
   * @param _domain the remote domain of the Home contract for the Replica
   * @param _access TRUE to give the Watcher permissions, FALSE to remove permissions
   */
  function setWatcherPermission(
    address _watcher,
    uint32 _domain,
    bool _access
  ) external onlyOwner {
    watcherPermissions[_watcher][_domain] = _access;
    emit WatcherPermissionSet(_domain, _watcher, _access);
  }

  /**
   * @notice Query local domain from Home
   * @return local domain
   */
  function localDomain() external view returns (uint32) {
    return home.localDomain();
  }

  /**
   * @notice Get access permissions for the watcher on the domain
   * @param _watcher the address of the watcher
   * @param _domain the domain to check for watcher permissions
   * @return TRUE iff _watcher has permission to un-enroll replicas on _domain
   */
  function watcherPermission(address _watcher, uint32 _domain) external view returns (bool) {
    return watcherPermissions[_watcher][_domain];
  }

  // ============ Public Functions ============

  /**
   * @notice Check whether _replica is enrolled
   * @param _replica the replica to check for enrollment
   * @return TRUE iff _replica is enrolled
   */
  function isReplica(address _replica) public view returns (bool) {
    return replicaToDomain[_replica] != 0;
  }

  // ============ Internal Functions ============

  /**
   * @notice Remove the replica from the two-way mappings
   * @param _replica replica to un-enroll
   */
  function _unenrollReplica(address _replica) internal {
    uint32 _currentDomain = replicaToDomain[_replica];
    domainToReplica[_currentDomain] = address(0);
    replicaToDomain[_replica] = 0;
    emit ReplicaUnenrolled(_currentDomain, _replica);
  }

  /**
   * @notice Get the Watcher address from the provided signature
   * @return address of watcher that signed
   */
  function _recoverWatcherFromSig(
    uint32 _domain,
    bytes32 _replica,
    bytes32 _updater,
    bytes memory _signature
  ) internal view returns (address) {
    bytes32 _homeDomainHash = Replica(TypeCasts.bytes32ToAddress(_replica)).homeDomainHash();
    bytes32 _digest = keccak256(abi.encodePacked(_homeDomainHash, _domain, _updater));
    _digest = ECDSA.toEthSignedMessageHash(_digest);
    return ECDSA.recover(_digest, _signature);
  }
}


// : MIT
pragma solidity >=0.6.11;

// ============ External Imports ============
//import{Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title UpgradeBeaconProxy
 * @notice
 * Proxy contract which delegates all logic, including initialization,
 * to an implementation contract.
 * The implementation contract is stored within an Upgrade Beacon contract;
 * the implementation contract can be changed by performing an upgrade on the Upgrade Beacon contract.
 * The Upgrade Beacon contract for this Proxy is immutably specified at deployment.
 * @dev This implementation combines the gas savings of keeping the UpgradeBeacon address outside of contract storage
 * found in 0age's implementation:
 * https://github.com/dharma-eng/dharma-smart-wallet/blob/master/contracts/proxies/smart-wallet/UpgradeBeaconProxyV1.sol
 * With the added safety checks that the UpgradeBeacon and implementation are contracts at time of deployment
 * found in OpenZeppelin's implementation:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/beacon/BeaconProxy.sol
 */
contract UpgradeBeaconProxy {
  // ============ Immutables ============

  // Upgrade Beacon address is immutable (therefore not kept in contract storage)
  address private immutable upgradeBeacon;

  // ============ Constructor ============

  /**
   * @notice Validate that the Upgrade Beacon is a contract, then set its
   * address immutably within this contract.
   * Validate that the implementation is also a contract,
   * Then call the initialization function defined at the implementation.
   * The deployment will revert and pass along the
   * revert reason if the initialization function reverts.
   * @param _upgradeBeacon Address of the Upgrade Beacon to be stored immutably in the contract
   * @param _initializationCalldata Calldata supplied when calling the initialization function
   */
  constructor(address _upgradeBeacon, bytes memory _initializationCalldata) payable {
    // Validate the Upgrade Beacon is a contract
    require(Address.isContract(_upgradeBeacon), "beacon !contract");
    // set the Upgrade Beacon
    upgradeBeacon = _upgradeBeacon;
    // Validate the implementation is a contract
    address _implementation = _getImplementation(_upgradeBeacon);
    require(Address.isContract(_implementation), "beacon implementation !contract");
    // Call the initialization function on the implementation
    if (_initializationCalldata.length > 0) {
      _initialize(_implementation, _initializationCalldata);
    }
  }

  // ============ External Functions ============

  /**
   * @notice Forwards all calls with data to _fallback()
   * No public functions are declared on the contract, so all calls hit fallback
   */
  fallback() external payable {
    _fallback();
  }

  /**
   * @notice Forwards all calls with no data to _fallback()
   */
  receive() external payable {
    _fallback();
  }

  // ============ Private Functions ============

  /**
   * @notice Call the initialization function on the implementation
   * Used at deployment to initialize the proxy
   * based on the logic for initialization defined at the implementation
   * @param _implementation - Contract to which the initalization is delegated
   * @param _initializationCalldata - Calldata supplied when calling the initialization function
   */
  function _initialize(address _implementation, bytes memory _initializationCalldata) private {
    // Delegatecall into the implementation, supplying initialization calldata.
    (bool _ok, ) = _implementation.delegatecall(_initializationCalldata);
    // Revert and include revert data if delegatecall to implementation reverts.
    if (!_ok) {
      assembly {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
    }
  }

  /**
   * @notice Delegates function calls to the implementation contract returned by the Upgrade Beacon
   */
  function _fallback() private {
    _delegate(_getImplementation());
  }

  /**
   * @notice Delegate function execution to the implementation contract
   * @dev This is a low level function that doesn't return to its internal
   * call site. It will return whatever is returned by the implementation to the
   * external caller, reverting and returning the revert data if implementation
   * reverts.
   * @param _implementation - Address to which the function execution is delegated
   */
  function _delegate(address _implementation) private {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())
      // Delegatecall to the implementation, supplying calldata and gas.
      // Out and outsize are set to zero - instead, use the return buffer.
      let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
      // Copy the returned data from the return buffer.
      returndatacopy(0, 0, returndatasize())
      switch result
      // Delegatecall returns 0 on error.
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  /**
   * @notice Call the Upgrade Beacon to get the current implementation contract address
   * @return _implementation Address of the current implementation.
   */
  function _getImplementation() private view returns (address _implementation) {
    _implementation = _getImplementation(upgradeBeacon);
  }

  /**
   * @notice Call the Upgrade Beacon to get the current implementation contract address
   * @dev _upgradeBeacon is passed as a parameter so that
   * we can also use this function in the constructor,
   * where we can't access immutable variables.
   * @param _upgradeBeacon Address of the UpgradeBeacon storing the current implementation
   * @return _implementation Address of the current implementation.
   */
  function _getImplementation(address _upgradeBeacon) private view returns (address _implementation) {
    // Get the current implementation address from the upgrade beacon.
    (bool _ok, bytes memory _returnData) = _upgradeBeacon.staticcall("");
    // Revert and pass along revert message if call to upgrade beacon reverts.
    require(_ok, string(_returnData));
    // Set the implementation to the address returned from the upgrade beacon.
    _implementation = abi.decode(_returnData, (address));
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface IUpdaterManager {
  function slashUpdater(address payable _reporter) external;

  function updater() external view returns (address);
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// work based on eth2 deposit contract, which is used under CC0-1.0

/**
 * @title MerkleLib
 * @author Illusory Systems Inc.
 * @notice An incremental merkle tree modeled on the eth2 deposit contract.
 **/
library MerkleLib {
  uint256 internal constant TREE_DEPTH = 32;
  uint256 internal constant MAX_LEAVES = 2**TREE_DEPTH - 1;

  /**
   * @notice Struct representing incremental merkle tree. Contains current
   * branch and the number of inserted leaves in the tree.
   **/
  struct Tree {
    bytes32[TREE_DEPTH] branch;
    uint256 count;
  }

  /**
   * @notice Inserts `_node` into merkle tree
   * @dev Reverts if tree is full
   * @param _node Element to insert into tree
   **/
  function insert(Tree storage _tree, bytes32 _node) internal {
    require(_tree.count < MAX_LEAVES, "merkle tree full");

    _tree.count += 1;
    uint256 size = _tree.count;
    for (uint256 i = 0; i < TREE_DEPTH; i++) {
      if ((size & 1) == 1) {
        _tree.branch[i] = _node;
        return;
      }
      _node = keccak256(abi.encodePacked(_tree.branch[i], _node));
      size /= 2;
    }
    // As the loop should always end prematurely with the `return` statement,
    // this code should be unreachable. We assert `false` just to be safe.
    assert(false);
  }

  /**
   * @notice Calculates and returns`_tree`'s current root given array of zero
   * hashes
   * @param _zeroes Array of zero hashes
   * @return _current Calculated root of `_tree`
   **/
  function rootWithCtx(Tree storage _tree, bytes32[TREE_DEPTH] memory _zeroes)
    internal
    view
    returns (bytes32 _current)
  {
    uint256 _index = _tree.count;

    for (uint256 i = 0; i < TREE_DEPTH; i++) {
      uint256 _ithBit = (_index >> i) & 0x01;
      bytes32 _next = _tree.branch[i];
      if (_ithBit == 1) {
        _current = keccak256(abi.encodePacked(_next, _current));
      } else {
        _current = keccak256(abi.encodePacked(_current, _zeroes[i]));
      }
    }
  }

  /// @notice Calculates and returns`_tree`'s current root
  function root(Tree storage _tree) internal view returns (bytes32) {
    return rootWithCtx(_tree, zeroHashes());
  }

  /// @notice Returns array of TREE_DEPTH zero hashes
  /// @return _zeroes Array of TREE_DEPTH zero hashes
  function zeroHashes() internal pure returns (bytes32[TREE_DEPTH] memory _zeroes) {
    _zeroes[0] = Z_0;
    _zeroes[1] = Z_1;
    _zeroes[2] = Z_2;
    _zeroes[3] = Z_3;
    _zeroes[4] = Z_4;
    _zeroes[5] = Z_5;
    _zeroes[6] = Z_6;
    _zeroes[7] = Z_7;
    _zeroes[8] = Z_8;
    _zeroes[9] = Z_9;
    _zeroes[10] = Z_10;
    _zeroes[11] = Z_11;
    _zeroes[12] = Z_12;
    _zeroes[13] = Z_13;
    _zeroes[14] = Z_14;
    _zeroes[15] = Z_15;
    _zeroes[16] = Z_16;
    _zeroes[17] = Z_17;
    _zeroes[18] = Z_18;
    _zeroes[19] = Z_19;
    _zeroes[20] = Z_20;
    _zeroes[21] = Z_21;
    _zeroes[22] = Z_22;
    _zeroes[23] = Z_23;
    _zeroes[24] = Z_24;
    _zeroes[25] = Z_25;
    _zeroes[26] = Z_26;
    _zeroes[27] = Z_27;
    _zeroes[28] = Z_28;
    _zeroes[29] = Z_29;
    _zeroes[30] = Z_30;
    _zeroes[31] = Z_31;
  }

  /**
   * @notice Calculates and returns the merkle root for the given leaf
   * `_item`, a merkle branch, and the index of `_item` in the tree.
   * @param _item Merkle leaf
   * @param _branch Merkle proof
   * @param _index Index of `_item` in tree
   * @return _current Calculated merkle root
   **/
  function branchRoot(
    bytes32 _item,
    bytes32[TREE_DEPTH] memory _branch,
    uint256 _index
  ) internal pure returns (bytes32 _current) {
    _current = _item;

    for (uint256 i = 0; i < TREE_DEPTH; i++) {
      uint256 _ithBit = (_index >> i) & 0x01;
      bytes32 _next = _branch[i];
      if (_ithBit == 1) {
        _current = keccak256(abi.encodePacked(_next, _current));
      } else {
        _current = keccak256(abi.encodePacked(_current, _next));
      }
    }
  }

  // keccak256 zero hashes
  bytes32 internal constant Z_0 = hex"0000000000000000000000000000000000000000000000000000000000000000";
  bytes32 internal constant Z_1 = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";
  bytes32 internal constant Z_2 = hex"b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30";
  bytes32 internal constant Z_3 = hex"21ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85";
  bytes32 internal constant Z_4 = hex"e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a19344";
  bytes32 internal constant Z_5 = hex"0eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d";
  bytes32 internal constant Z_6 = hex"887c22bd8750d34016ac3c66b5ff102dacdd73f6b014e710b51e8022af9a1968";
  bytes32 internal constant Z_7 = hex"ffd70157e48063fc33c97a050f7f640233bf646cc98d9524c6b92bcf3ab56f83";
  bytes32 internal constant Z_8 = hex"9867cc5f7f196b93bae1e27e6320742445d290f2263827498b54fec539f756af";
  bytes32 internal constant Z_9 = hex"cefad4e508c098b9a7e1d8feb19955fb02ba9675585078710969d3440f5054e0";
  bytes32 internal constant Z_10 = hex"f9dc3e7fe016e050eff260334f18a5d4fe391d82092319f5964f2e2eb7c1c3a5";
  bytes32 internal constant Z_11 = hex"f8b13a49e282f609c317a833fb8d976d11517c571d1221a265d25af778ecf892";
  bytes32 internal constant Z_12 = hex"3490c6ceeb450aecdc82e28293031d10c7d73bf85e57bf041a97360aa2c5d99c";
  bytes32 internal constant Z_13 = hex"c1df82d9c4b87413eae2ef048f94b4d3554cea73d92b0f7af96e0271c691e2bb";
  bytes32 internal constant Z_14 = hex"5c67add7c6caf302256adedf7ab114da0acfe870d449a3a489f781d659e8becc";
  bytes32 internal constant Z_15 = hex"da7bce9f4e8618b6bd2f4132ce798cdc7a60e7e1460a7299e3c6342a579626d2";
  bytes32 internal constant Z_16 = hex"2733e50f526ec2fa19a22b31e8ed50f23cd1fdf94c9154ed3a7609a2f1ff981f";
  bytes32 internal constant Z_17 = hex"e1d3b5c807b281e4683cc6d6315cf95b9ade8641defcb32372f1c126e398ef7a";
  bytes32 internal constant Z_18 = hex"5a2dce0a8a7f68bb74560f8f71837c2c2ebbcbf7fffb42ae1896f13f7c7479a0";
  bytes32 internal constant Z_19 = hex"b46a28b6f55540f89444f63de0378e3d121be09e06cc9ded1c20e65876d36aa0";
  bytes32 internal constant Z_20 = hex"c65e9645644786b620e2dd2ad648ddfcbf4a7e5b1a3a4ecfe7f64667a3f0b7e2";
  bytes32 internal constant Z_21 = hex"f4418588ed35a2458cffeb39b93d26f18d2ab13bdce6aee58e7b99359ec2dfd9";
  bytes32 internal constant Z_22 = hex"5a9c16dc00d6ef18b7933a6f8dc65ccb55667138776f7dea101070dc8796e377";
  bytes32 internal constant Z_23 = hex"4df84f40ae0c8229d0d6069e5c8f39a7c299677a09d367fc7b05e3bc380ee652";
  bytes32 internal constant Z_24 = hex"cdc72595f74c7b1043d0e1ffbab734648c838dfb0527d971b602bc216c9619ef";
  bytes32 internal constant Z_25 = hex"0abf5ac974a1ed57f4050aa510dd9c74f508277b39d7973bb2dfccc5eeb0618d";
  bytes32 internal constant Z_26 = hex"b8cd74046ff337f0a7bf2c8e03e10f642c1886798d71806ab1e888d9e5ee87d0";
  bytes32 internal constant Z_27 = hex"838c5655cb21c6cb83313b5a631175dff4963772cce9108188b34ac87c81c41e";
  bytes32 internal constant Z_28 = hex"662ee4dd2dd7b2bc707961b1e646c4047669dcb6584f0d8d770daf5d7e7deb2e";
  bytes32 internal constant Z_29 = hex"388ab20e2573d171a88108e79d820e98f26c0b84aa8b2f4aa4968dbb818ea322";
  bytes32 internal constant Z_30 = hex"93237c50ba75ee485f4c22adf2f741400bdf8d6a9cc7df7ecae576221665d735";
  bytes32 internal constant Z_31 = hex"8448818bb4ae4562849e949e17ac16e0be16688e156b5cf15e098c627c0056a9";
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// //import"@summa-tx/memview-sol/contracts/TypedMemView.sol";

//import"./TypedMemView.sol";

//import{TypeCasts} from "./TypeCasts.sol";

/**
 * @title Message Library
 * @author Illusory Systems Inc.
 * @notice Library for formatted messages used by Home and Replica.
 **/
library Message {
  using TypedMemView for bytes;
  using TypedMemView for bytes29;

  // Number of bytes in formatted message before `body` field
  uint256 internal constant PREFIX_LENGTH = 76;

  /**
   * @notice Returns formatted (packed) message with provided fields
   * @param _originDomain Domain of home chain
   * @param _sender Address of sender as bytes32
   * @param _nonce Destination-specific nonce
   * @param _destinationDomain Domain of destination chain
   * @param _recipient Address of recipient on destination chain as bytes32
   * @param _messageBody Raw bytes of message body
   * @return Formatted message
   **/
  function formatMessage(
    uint32 _originDomain,
    bytes32 _sender,
    uint32 _nonce,
    uint32 _destinationDomain,
    bytes32 _recipient,
    bytes memory _messageBody
  ) internal pure returns (bytes memory) {
    return abi.encodePacked(_originDomain, _sender, _nonce, _destinationDomain, _recipient, _messageBody);
  }

  /**
   * @notice Returns leaf of formatted message with provided fields.
   * @param _origin Domain of home chain
   * @param _sender Address of sender as bytes32
   * @param _nonce Destination-specific nonce number
   * @param _destination Domain of destination chain
   * @param _recipient Address of recipient on destination chain as bytes32
   * @param _body Raw bytes of message body
   * @return Leaf (hash) of formatted message
   **/
  function messageHash(
    uint32 _origin,
    bytes32 _sender,
    uint32 _nonce,
    uint32 _destination,
    bytes32 _recipient,
    bytes memory _body
  ) internal pure returns (bytes32) {
    return keccak256(formatMessage(_origin, _sender, _nonce, _destination, _recipient, _body));
  }

  /// @notice Returns message's origin field
  function origin(bytes29 _message) internal pure returns (uint32) {
    return uint32(_message.indexUint(0, 4));
  }

  /// @notice Returns message's sender field
  function sender(bytes29 _message) internal pure returns (bytes32) {
    return _message.index(4, 32);
  }

  /// @notice Returns message's nonce field
  function nonce(bytes29 _message) internal pure returns (uint32) {
    return uint32(_message.indexUint(36, 4));
  }

  /// @notice Returns message's destination field
  function destination(bytes29 _message) internal pure returns (uint32) {
    return uint32(_message.indexUint(40, 4));
  }

  /// @notice Returns message's recipient field as bytes32
  function recipient(bytes29 _message) internal pure returns (bytes32) {
    return _message.index(44, 32);
  }

  /// @notice Returns message's recipient field as an address
  function recipientAddress(bytes29 _message) internal pure returns (address) {
    return TypeCasts.bytes32ToAddress(recipient(_message));
  }

  /// @notice Returns message's body field as bytes29 (refer to TypedMemView library for details on bytes29 type)
  function body(bytes29 _message) internal pure returns (bytes29) {
    return _message.slice(PREFIX_LENGTH, _message.len() - PREFIX_LENGTH, 0);
  }

  function leaf(bytes29 _message) internal view returns (bytes32) {
    return
      messageHash(
        origin(_message),
        sender(_message),
        nonce(_message),
        destination(_message),
        recipient(_message),
        TypedMemView.clone(body(_message))
      );
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

/**
 * @title QueueLib
 * @author Illusory Systems Inc.
 * @notice Library containing queue struct and operations for queue used by
 * Home and Replica.
 **/
library QueueLib {
  /**
   * @notice Queue struct
   * @dev Internally keeps track of the `first` and `last` elements through
   * indices and a mapping of indices to enqueued elements.
   **/
  struct Queue {
    uint128 first;
    uint128 last;
    mapping(uint256 => bytes32) queue;
  }

  /**
   * @notice Initializes the queue
   * @dev Empty state denoted by _q.first > q._last. Queue initialized
   * with _q.first = 1 and _q.last = 0.
   **/
  function initialize(Queue storage _q) internal {
    if (_q.first == 0) {
      _q.first = 1;
    }
  }

  /**
   * @notice Enqueues a single new element
   * @param _item New element to be enqueued
   * @return _last Index of newly enqueued element
   **/
  function enqueue(Queue storage _q, bytes32 _item) internal returns (uint128 _last) {
    _last = _q.last + 1;
    _q.last = _last;
    if (_item != bytes32(0)) {
      // saves gas if we're queueing 0
      _q.queue[_last] = _item;
    }
  }

  /**
   * @notice Dequeues element at front of queue
   * @dev Removes dequeued element from storage
   * @return _item Dequeued element
   **/
  function dequeue(Queue storage _q) internal returns (bytes32 _item) {
    uint128 _last = _q.last;
    uint128 _first = _q.first;
    require(_length(_last, _first) != 0, "Empty");
    _item = _q.queue[_first];
    if (_item != bytes32(0)) {
      // saves gas if we're dequeuing 0
      delete _q.queue[_first];
    }
    _q.first = _first + 1;
  }

  /**
   * @notice Batch enqueues several elements
   * @param _items Array of elements to be enqueued
   * @return _last Index of last enqueued element
   **/
  function enqueue(Queue storage _q, bytes32[] memory _items) internal returns (uint128 _last) {
    _last = _q.last;
    for (uint256 i = 0; i < _items.length; i += 1) {
      _last += 1;
      bytes32 _item = _items[i];
      if (_item != bytes32(0)) {
        _q.queue[_last] = _item;
      }
    }
    _q.last = _last;
  }

  /**
   * @notice Batch dequeues `_number` elements
   * @dev Reverts if `_number` > queue length
   * @param _number Number of elements to dequeue
   * @return Array of dequeued elements
   **/
  function dequeue(Queue storage _q, uint256 _number) internal returns (bytes32[] memory) {
    uint128 _last = _q.last;
    uint128 _first = _q.first;
    // Cannot underflow unless state is corrupted
    require(_length(_last, _first) >= _number, "Insufficient");

    bytes32[] memory _items = new bytes32[](_number);

    for (uint256 i = 0; i < _number; i++) {
      _items[i] = _q.queue[_first];
      delete _q.queue[_first];
      _first++;
    }
    _q.first = _first;
    return _items;
  }

  /**
   * @notice Returns true if `_item` is in the queue and false if otherwise
   * @dev Linearly scans from _q.first to _q.last looking for `_item`
   * @param _item Item being searched for in queue
   * @return True if `_item` currently exists in queue, false if otherwise
   **/
  function contains(Queue storage _q, bytes32 _item) internal view returns (bool) {
    for (uint256 i = _q.first; i <= _q.last; i++) {
      if (_q.queue[i] == _item) {
        return true;
      }
    }
    return false;
  }

  /// @notice Returns last item in queue
  /// @dev Returns bytes32(0) if queue empty
  function lastItem(Queue storage _q) internal view returns (bytes32) {
    return _q.queue[_q.last];
  }

  /// @notice Returns element at front of queue without removing element
  /// @dev Reverts if queue is empty
  function peek(Queue storage _q) internal view returns (bytes32 _item) {
    require(!isEmpty(_q), "Empty");
    _item = _q.queue[_q.first];
  }

  /// @notice Returns true if queue is empty and false if otherwise
  function isEmpty(Queue storage _q) internal view returns (bool) {
    return _q.last < _q.first;
  }

  /// @notice Returns number of elements in queue
  function length(Queue storage _q) internal view returns (uint256) {
    uint128 _last = _q.last;
    uint128 _first = _q.first;
    // Cannot underflow unless state is corrupted
    return _length(_last, _first);
  }

  /// @notice Returns number of elements between `_last` and `_first` (used internally)
  function _length(uint128 _last, uint128 _first) internal pure returns (uint256) {
    return uint256(_last + 1 - _first);
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.6.11;

// //import"@summa-tx/memview-sol/contracts/TypedMemView.sol";
//import"./TypedMemView.sol";

library TypeCasts {
  using TypedMemView for bytes;
  using TypedMemView for bytes29;

  function coerceBytes32(string memory _s) internal pure returns (bytes32 _b) {
    _b = bytes(_s).ref(0).index(0, uint8(bytes(_s).length));
  }

  // treat it as a null-terminated string of max 32 bytes
  function coerceString(bytes32 _buf) internal pure returns (string memory _newStr) {
    uint8 _slen = 0;
    while (_slen < 32 && _buf[_slen] != 0) {
      _slen++;
    }

    // solhint-disable-next-line no-inline-assembly
    assembly {
      _newStr := mload(0x40)
      mstore(0x40, add(_newStr, 0x40)) // may end up with extra
      mstore(_newStr, _slen)
      mstore(add(_newStr, 0x20), _buf)
    }
  }

  // alignment preserving cast
  function addressToBytes32(address _addr) internal pure returns (bytes32) {
    return bytes32(uint256(uint160(_addr)));
  }

  // alignment preserving cast
  function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
    return address(uint160(uint256(_buf)));
  }
}


// : MIT OR Apache-2.0
pragma solidity >=0.8.11;

library TypedMemView {
  // Why does this exist?
  // the solidity `bytes memory` type has a few weaknesses.
  // 1. You can't index ranges effectively
  // 2. You can't slice without copying
  // 3. The underlying data may represent any type
  // 4. Solidity never deallocates memory, and memory costs grow
  //    superlinearly

  // By using a memory view instead of a `bytes memory` we get the following
  // advantages:
  // 1. Slices are done on the stack, by manipulating the pointer
  // 2. We can index arbitrary ranges and quickly convert them to stack types
  // 3. We can insert type info into the pointer, and typecheck at runtime

  // This makes `TypedMemView` a useful tool for efficient zero-copy
  // algorithms.

  // Why bytes29?
  // We want to avoid confusion between views, digests, and other common
  // types so we chose a large and uncommonly used odd number of bytes
  //
  // Note that while bytes are left-aligned in a word, integers and addresses
  // are right-aligned. This means when working in assembly we have to
  // account for the 3 unused bytes on the righthand side
  //
  // First 5 bytes are a type flag.
  // - ff_ffff_fffe is reserved for unknown type.
  // - ff_ffff_ffff is reserved for invalid types/errors.
  // next 12 are memory address
  // next 12 are len
  // bottom 3 bytes are empty

  // Assumptions:
  // - non-modification of memory.
  // - No Solidity updates
  // - - wrt free mem point
  // - - wrt bytes representation in memory
  // - - wrt memory addressing in general

  // Usage:
  // - create type constants
  // - use `assertType` for runtime type assertions
  // - - unfortunately we can't do this at compile time yet :(
  // - recommended: implement modifiers that perform type checking
  // - - e.g.
  // - - `uint40 constant MY_TYPE = 3;`
  // - - ` modifer onlyMyType(bytes29 myView) { myView.assertType(MY_TYPE); }`
  // - instantiate a typed view from a bytearray using `ref`
  // - use `index` to inspect the contents of the view
  // - use `slice` to create smaller views into the same memory
  // - - `slice` can increase the offset
  // - - `slice can decrease the length`
  // - - must specify the output type of `slice`
  // - - `slice` will return a null view if you try to overrun
  // - - make sure to explicitly check for this with `notNull` or `assertType`
  // - use `equal` for typed comparisons.

  // The null view
  bytes29 public constant NULL = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
  uint256 constant LOW_12_MASK = 0xffffffffffffffffffffffff;
  uint8 constant TWELVE_BYTES = 96;

  /**
   * @notice      Returns the encoded hex character that represents the lower 4 bits of the argument.
   * @param _b    The byte
   * @return      char - The encoded hex character
   */
  function nibbleHex(uint8 _b) internal pure returns (uint8 char) {
    // This can probably be done more efficiently, but it's only in error
    // paths, so we don't really care :)
    uint8 _nibble = _b | 0xf0; // set top 4, keep bottom 4
    if (_nibble == 0xf0) {
      return 0x30;
    } // 0
    if (_nibble == 0xf1) {
      return 0x31;
    } // 1
    if (_nibble == 0xf2) {
      return 0x32;
    } // 2
    if (_nibble == 0xf3) {
      return 0x33;
    } // 3
    if (_nibble == 0xf4) {
      return 0x34;
    } // 4
    if (_nibble == 0xf5) {
      return 0x35;
    } // 5
    if (_nibble == 0xf6) {
      return 0x36;
    } // 6
    if (_nibble == 0xf7) {
      return 0x37;
    } // 7
    if (_nibble == 0xf8) {
      return 0x38;
    } // 8
    if (_nibble == 0xf9) {
      return 0x39;
    } // 9
    if (_nibble == 0xfa) {
      return 0x61;
    } // a
    if (_nibble == 0xfb) {
      return 0x62;
    } // b
    if (_nibble == 0xfc) {
      return 0x63;
    } // c
    if (_nibble == 0xfd) {
      return 0x64;
    } // d
    if (_nibble == 0xfe) {
      return 0x65;
    } // e
    if (_nibble == 0xff) {
      return 0x66;
    } // f
  }

  /**
   * @notice      Returns a uint16 containing the hex-encoded byte.
   * @param _b    The byte
   * @return      encoded - The hex-encoded byte
   */
  function byteHex(uint8 _b) internal pure returns (uint16 encoded) {
    encoded |= nibbleHex(_b >> 4); // top 4 bits
    encoded <<= 8;
    encoded |= nibbleHex(_b); // lower 4 bits
  }

  /**
   * @notice      Encodes the uint256 to hex. `first` contains the encoded top 16 bytes.
   *              `second` contains the encoded lower 16 bytes.
   *
   * @param _b    The 32 bytes as uint256
   * @return      first - The top 16 bytes
   * @return      second - The bottom 16 bytes
   */
  function encodeHex(uint256 _b) internal pure returns (uint256 first, uint256 second) {
    for (uint8 i = 31; i > 15; ) {
      uint8 _byte = uint8(_b >> (i * 8));
      first |= byteHex(_byte);
      if (i != 16) {
        first <<= 16;
      }
      unchecked {
        i -= 1;
      }
    }

    // abusing underflow here =_=
    for (uint8 i = 15; i < 255; ) {
      uint8 _byte = uint8(_b >> (i * 8));
      second |= byteHex(_byte);
      if (i != 0) {
        second <<= 16;
      }
      unchecked {
        i -= 1;
      }
    }
  }

  /**
   * @notice          Changes the endianness of a uint256.
   * @dev             https://graphics.stanford.edu/~seander/bithacks.html#ReverseParallel
   * @param _b        The unsigned integer to reverse
   * @return          v - The reversed value
   */
  function reverseUint256(uint256 _b) internal pure returns (uint256 v) {
    v = _b;

    // swap bytes
    v =
      ((v >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) |
      ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);
    // swap 2-byte long pairs
    v =
      ((v >> 16) & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) |
      ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);
    // swap 4-byte long pairs
    v =
      ((v >> 32) & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) |
      ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);
    // swap 8-byte long pairs
    v =
      ((v >> 64) & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) |
      ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);
    // swap 16-byte long pairs
    v = (v >> 128) | (v << 128);
  }

  /**
   * @notice      Create a mask with the highest `_len` bits set.
   * @param _len  The length
   * @return      mask - The mask
   */
  function leftMask(uint8 _len) private pure returns (uint256 mask) {
    // ugly. redo without assembly?
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      mask := sar(sub(_len, 1), 0x8000000000000000000000000000000000000000000000000000000000000000)
    }
  }

  /**
   * @notice      Return the null view.
   * @return      bytes29 - The null view
   */
  function nullView() internal pure returns (bytes29) {
    return NULL;
  }

  /**
   * @notice      Check if the view is null.
   * @return      bool - True if the view is null
   */
  function isNull(bytes29 memView) internal pure returns (bool) {
    return memView == NULL;
  }

  /**
   * @notice      Check if the view is not null.
   * @return      bool - True if the view is not null
   */
  function notNull(bytes29 memView) internal pure returns (bool) {
    return !isNull(memView);
  }

  /**
   * @notice          Check if the view is of a valid type and points to a valid location
   *                  in memory.
   * @dev             We perform this check by examining solidity's unallocated memory
   *                  pointer and ensuring that the view's upper bound is less than that.
   * @param memView   The view
   * @return          ret - True if the view is valid
   */
  function isValid(bytes29 memView) internal pure returns (bool ret) {
    if (typeOf(memView) == 0xffffffffff) {
      return false;
    }
    uint256 _end = end(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ret := not(gt(_end, mload(0x40)))
    }
  }

  /**
   * @notice          Require that a typed memory view be valid.
   * @dev             Returns the view for easy chaining.
   * @param memView   The view
   * @return          bytes29 - The validated view
   */
  function assertValid(bytes29 memView) internal pure returns (bytes29) {
    require(isValid(memView), "Validity assertion failed");
    return memView;
  }

  /**
   * @notice          Return true if the memview is of the expected type. Otherwise false.
   * @param memView   The view
   * @param _expected The expected type
   * @return          bool - True if the memview is of the expected type
   */
  function isType(bytes29 memView, uint40 _expected) internal pure returns (bool) {
    return typeOf(memView) == _expected;
  }

  /**
   * @notice          Require that a typed memory view has a specific type.
   * @dev             Returns the view for easy chaining.
   * @param memView   The view
   * @param _expected The expected type
   * @return          bytes29 - The view with validated type
   */
  function assertType(bytes29 memView, uint40 _expected) internal pure returns (bytes29) {
    if (!isType(memView, _expected)) {
      (, uint256 g) = encodeHex(uint256(typeOf(memView)));
      (, uint256 e) = encodeHex(uint256(_expected));
      string memory err = string(
        abi.encodePacked("Type assertion failed. Got 0x", uint80(g), ". Expected 0x", uint80(e))
      );
      revert(err);
    }
    return memView;
  }

  /**
   * @notice          Return an identical view with a different type.
   * @param memView   The view
   * @param _newType  The new type
   * @return          newView - The new view with the specified type
   */
  function castTo(bytes29 memView, uint40 _newType) internal pure returns (bytes29 newView) {
    // then | in the new type
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      // shift off the top 5 bytes
      newView := or(newView, shr(40, shl(40, memView)))
      newView := or(newView, shl(216, _newType))
    }
  }

  /**
   * @notice          Unsafe raw pointer construction. This should generally not be called
   *                  directly. Prefer `ref` wherever possible.
   * @dev             Unsafe raw pointer construction. This should generally not be called
   *                  directly. Prefer `ref` wherever possible.
   * @param _type     The type
   * @param _loc      The memory address
   * @param _len      The length
   * @return          newView - The new view with the specified type, location and length
   */
  function unsafeBuildUnchecked(
    uint256 _type,
    uint256 _loc,
    uint256 _len
  ) private pure returns (bytes29 newView) {
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      newView := shl(96, or(newView, _type)) // insert type
      newView := shl(96, or(newView, _loc)) // insert loc
      newView := shl(24, or(newView, _len)) // empty bottom 3 bytes
    }
  }

  /**
   * @notice          Instantiate a new memory view. This should generally not be called
   *                  directly. Prefer `ref` wherever possible.
   * @dev             Instantiate a new memory view. This should generally not be called
   *                  directly. Prefer `ref` wherever possible.
   * @param _type     The type
   * @param _loc      The memory address
   * @param _len      The length
   * @return          newView - The new view with the specified type, location and length
   */
  function build(
    uint256 _type,
    uint256 _loc,
    uint256 _len
  ) internal pure returns (bytes29 newView) {
    uint256 _end = _loc + _len;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      if gt(_end, mload(0x40)) {
        _end := 0
      }
    }
    if (_end == 0) {
      return NULL;
    }
    newView = unsafeBuildUnchecked(_type, _loc, _len);
  }

  /**
   * @notice          Instantiate a memory view from a byte array.
   * @dev             Note that due to Solidity memory representation, it is not possible to
   *                  implement a deref, as the `bytes` type stores its len in memory.
   * @param arr       The byte array
   * @param newType   The type
   * @return          bytes29 - The memory view
   */
  function ref(bytes memory arr, uint40 newType) internal pure returns (bytes29) {
    uint256 _len = arr.length;

    uint256 _loc;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      _loc := add(arr, 0x20) // our view is of the data, not the struct
    }

    return build(newType, _loc, _len);
  }

  /**
   * @notice          Return the associated type information.
   * @param memView   The memory view
   * @return          _type - The type associated with the view
   */
  function typeOf(bytes29 memView) internal pure returns (uint40 _type) {
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      // 216 == 256 - 40
      _type := shr(216, memView) // shift out lower 24 bytes
    }
  }

  /**
   * @notice          Optimized type comparison. Checks that the 5-byte type flag is equal.
   * @param left      The first view
   * @param right     The second view
   * @return          bool - True if the 5-byte type flag is equal
   */
  function sameType(bytes29 left, bytes29 right) internal pure returns (bool) {
    return (left ^ right) >> (2 * TWELVE_BYTES) == 0;
  }

  /**
   * @notice          Return the memory address of the underlying bytes.
   * @param memView   The view
   * @return          _loc - The memory address
   */
  function loc(bytes29 memView) internal pure returns (uint96 _loc) {
    uint256 _mask = LOW_12_MASK; // assembly can't use globals
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      // 120 bits = 12 bytes (the encoded loc) + 3 bytes (empty low space)
      _loc := and(shr(120, memView), _mask)
    }
  }

  /**
   * @notice          The number of memory words this memory view occupies, rounded up.
   * @param memView   The view
   * @return          uint256 - The number of memory words
   */
  function words(bytes29 memView) internal pure returns (uint256) {
    return (uint256(len(memView)) + 32) / 32;
  }

  /**
   * @notice          The in-memory footprint of a fresh copy of the view.
   * @param memView   The view
   * @return          uint256 - The in-memory footprint of a fresh copy of the view.
   */
  function footprint(bytes29 memView) internal pure returns (uint256) {
    return words(memView) * 32;
  }

  /**
   * @notice          The number of bytes of the view.
   * @param memView   The view
   * @return          _len - The length of the view
   */
  function len(bytes29 memView) internal pure returns (uint96 _len) {
    uint256 _mask = LOW_12_MASK; // assembly can't use globals
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      _len := and(shr(24, memView), _mask)
    }
  }

  /**
   * @notice          Returns the endpoint of `memView`.
   * @param memView   The view
   * @return          uint256 - The endpoint of `memView`
   */
  function end(bytes29 memView) internal pure returns (uint256) {
    unchecked {
      return loc(memView) + len(memView);
    }
  }

  /**
   * @notice          Safe slicing without memory modification.
   * @param memView   The view
   * @param _index    The start index
   * @param _len      The length
   * @param newType   The new type
   * @return          bytes29 - The new view
   */
  function slice(
    bytes29 memView,
    uint256 _index,
    uint256 _len,
    uint40 newType
  ) internal pure returns (bytes29) {
    uint256 _loc = loc(memView);

    // Ensure it doesn't overrun the view
    if (_loc + _index + _len > end(memView)) {
      return NULL;
    }

    _loc = _loc + _index;
    return build(newType, _loc, _len);
  }

  /**
   * @notice          Shortcut to `slice`. Gets a view representing the first `_len` bytes.
   * @param memView   The view
   * @param _len      The length
   * @param newType   The new type
   * @return          bytes29 - The new view
   */
  function prefix(
    bytes29 memView,
    uint256 _len,
    uint40 newType
  ) internal pure returns (bytes29) {
    return slice(memView, 0, _len, newType);
  }

  /**
   * @notice          Shortcut to `slice`. Gets a view representing the last `_len` byte.
   * @param memView   The view
   * @param _len      The length
   * @param newType   The new type
   * @return          bytes29 - The new view
   */
  function postfix(
    bytes29 memView,
    uint256 _len,
    uint40 newType
  ) internal pure returns (bytes29) {
    return slice(memView, uint256(len(memView)) - _len, _len, newType);
  }

  /**
   * @notice          Construct an error message for an indexing overrun.
   * @param _loc      The memory address
   * @param _len      The length
   * @param _index    The index
   * @param _slice    The slice where the overrun occurred
   * @return          err - The err
   */
  function indexErrOverrun(
    uint256 _loc,
    uint256 _len,
    uint256 _index,
    uint256 _slice
  ) internal pure returns (string memory err) {
    (, uint256 a) = encodeHex(_loc);
    (, uint256 b) = encodeHex(_len);
    (, uint256 c) = encodeHex(_index);
    (, uint256 d) = encodeHex(_slice);
    err = string(
      abi.encodePacked(
        "TypedMemView/index - Overran the view. Slice is at 0x",
        uint48(a),
        " with length 0x",
        uint48(b),
        ". Attempted to index at offset 0x",
        uint48(c),
        " with length 0x",
        uint48(d),
        "."
      )
    );
  }

  /**
   * @notice          Load up to 32 bytes from the view onto the stack.
   * @dev             Returns a bytes32 with only the `_bytes` highest bytes set.
   *                  This can be immediately cast to a smaller fixed-length byte array.
   *                  To automatically cast to an integer, use `indexUint`.
   * @param memView   The view
   * @param _index    The index
   * @param _bytes    The bytes
   * @return          result - The 32 byte result
   */
  function index(
    bytes29 memView,
    uint256 _index,
    uint8 _bytes
  ) internal pure returns (bytes32 result) {
    if (_bytes == 0) {
      return bytes32(0);
    }
    if (_index + _bytes > len(memView)) {
      revert(indexErrOverrun(loc(memView), len(memView), _index, uint256(_bytes)));
    }
    require(_bytes <= 32, "TypedMemView/index - Attempted to index more than 32 bytes");

    uint8 bitLength;
    unchecked {
      bitLength = _bytes * 8;
    }
    uint256 _loc = loc(memView);
    uint256 _mask = leftMask(bitLength);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      result := and(mload(add(_loc, _index)), _mask)
    }
  }

  /**
   * @notice          Parse an unsigned integer from the view at `_index`.
   * @dev             Requires that the view have >= `_bytes` bytes following that index.
   * @param memView   The view
   * @param _index    The index
   * @param _bytes    The bytes
   * @return          result - The unsigned integer
   */
  function indexUint(
    bytes29 memView,
    uint256 _index,
    uint8 _bytes
  ) internal pure returns (uint256 result) {
    return uint256(index(memView, _index, _bytes)) >> ((32 - _bytes) * 8);
  }

  /**
   * @notice          Parse an unsigned integer from LE bytes.
   * @param memView   The view
   * @param _index    The index
   * @param _bytes    The bytes
   * @return          result - The unsigned integer
   */
  function indexLEUint(
    bytes29 memView,
    uint256 _index,
    uint8 _bytes
  ) internal pure returns (uint256 result) {
    return reverseUint256(uint256(index(memView, _index, _bytes)));
  }

  /**
   * @notice          Parse an address from the view at `_index`. Requires that the view have >= 20 bytes
   *                  following that index.
   * @param memView   The view
   * @param _index    The index
   * @return          address - The address
   */
  function indexAddress(bytes29 memView, uint256 _index) internal pure returns (address) {
    return address(uint160(indexUint(memView, _index, 20)));
  }

  /**
   * @notice          Return the keccak256 hash of the underlying memory
   * @param memView   The view
   * @return          digest - The keccak256 hash of the underlying memory
   */
  function keccak(bytes29 memView) internal pure returns (bytes32 digest) {
    uint256 _loc = loc(memView);
    uint256 _len = len(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      digest := keccak256(_loc, _len)
    }
  }

  /**
   * @notice          Return the sha2 digest of the underlying memory.
   * @dev             We explicitly deallocate memory afterwards.
   * @param memView   The view
   * @return          digest - The sha2 hash of the underlying memory
   */
  function sha2(bytes29 memView) internal view returns (bytes32 digest) {
    uint256 _loc = loc(memView);
    uint256 _len = len(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      let ptr := mload(0x40)
      pop(staticcall(gas(), 2, _loc, _len, ptr, 0x20)) // sha2 #1
      digest := mload(ptr)
    }
  }

  /**
   * @notice          Implements bitcoin's hash160 (rmd160(sha2()))
   * @param memView   The pre-image
   * @return          digest - the Digest
   */
  function hash160(bytes29 memView) internal view returns (bytes20 digest) {
    uint256 _loc = loc(memView);
    uint256 _len = len(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      let ptr := mload(0x40)
      pop(staticcall(gas(), 2, _loc, _len, ptr, 0x20)) // sha2
      pop(staticcall(gas(), 3, ptr, 0x20, ptr, 0x20)) // rmd160
      digest := mload(add(ptr, 0xc)) // return value is 0-prefixed.
    }
  }

  /**
   * @notice          Implements bitcoin's hash256 (double sha2)
   * @param memView   A view of the preimage
   * @return          digest - the Digest
   */
  function hash256(bytes29 memView) internal view returns (bytes32 digest) {
    uint256 _loc = loc(memView);
    uint256 _len = len(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      let ptr := mload(0x40)
      pop(staticcall(gas(), 2, _loc, _len, ptr, 0x20)) // sha2 #1
      pop(staticcall(gas(), 2, ptr, 0x20, ptr, 0x20)) // sha2 #2
      digest := mload(ptr)
    }
  }

  /**
   * @notice          Return true if the underlying memory is equal. Else false.
   * @param left      The first view
   * @param right     The second view
   * @return          bool - True if the underlying memory is equal
   */
  function untypedEqual(bytes29 left, bytes29 right) internal pure returns (bool) {
    return (loc(left) == loc(right) && len(left) == len(right)) || keccak(left) == keccak(right);
  }

  /**
   * @notice          Return false if the underlying memory is equal. Else true.
   * @param left      The first view
   * @param right     The second view
   * @return          bool - False if the underlying memory is equal
   */
  function untypedNotEqual(bytes29 left, bytes29 right) internal pure returns (bool) {
    return !untypedEqual(left, right);
  }

  /**
   * @notice          Compares type equality.
   * @dev             Shortcuts if the pointers are identical, otherwise compares type and digest.
   * @param left      The first view
   * @param right     The second view
   * @return          bool - True if the types are the same
   */
  function equal(bytes29 left, bytes29 right) internal pure returns (bool) {
    return left == right || (typeOf(left) == typeOf(right) && keccak(left) == keccak(right));
  }

  /**
   * @notice          Compares type inequality.
   * @dev             Shortcuts if the pointers are identical, otherwise compares type and digest.
   * @param left      The first view
   * @param right     The second view
   * @return          bool - True if the types are not the same
   */
  function notEqual(bytes29 left, bytes29 right) internal pure returns (bool) {
    return !equal(left, right);
  }

  /**
   * @notice          Copy the view to a location, return an unsafe memory reference
   * @dev             Super Dangerous direct memory access.
   *
   *                  This reference can be overwritten if anything else modifies memory (!!!).
   *                  As such it MUST be consumed IMMEDIATELY.
   *                  This function is private to prevent unsafe usage by callers.
   * @param memView   The view
   * @param _newLoc   The new location
   * @return          written - the unsafe memory reference
   */
  function unsafeCopyTo(bytes29 memView, uint256 _newLoc) private view returns (bytes29 written) {
    require(notNull(memView), "TypedMemView/copyTo - Null pointer deref");
    require(isValid(memView), "TypedMemView/copyTo - Invalid pointer deref");
    uint256 _len = len(memView);
    uint256 _oldLoc = loc(memView);

    uint256 ptr;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ptr := mload(0x40)
      // revert if we're writing in occupied memory
      if gt(ptr, _newLoc) {
        revert(0x60, 0x20) // empty revert message
      }

      // use the identity precompile to copy
      // guaranteed not to fail, so pop the success
      pop(staticcall(gas(), 4, _oldLoc, _len, _newLoc, _len))
    }

    written = unsafeBuildUnchecked(typeOf(memView), _newLoc, _len);
  }

  /**
   * @notice          Copies the referenced memory to a new loc in memory, returning a `bytes` pointing to
   *                  the new memory
   * @dev             Shortcuts if the pointers are identical, otherwise compares type and digest.
   * @param memView   The view
   * @return          ret - The view pointing to the new memory
   */
  function clone(bytes29 memView) internal view returns (bytes memory ret) {
    uint256 ptr;
    uint256 _len = len(memView);
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ptr := mload(0x40) // load unused memory pointer
      ret := ptr
    }
    unchecked {
      unsafeCopyTo(memView, ptr + 0x20);
    }
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      mstore(0x40, add(add(ptr, _len), 0x20)) // write new unused pointer
      mstore(ptr, _len) // write len of new array (in bytes)
    }
  }

  /**
   * @notice          Join the views in memory, return an unsafe reference to the memory.
   * @dev             Super Dangerous direct memory access.
   *
   *                  This reference can be overwritten if anything else modifies memory (!!!).
   *                  As such it MUST be consumed IMMEDIATELY.
   *                  This function is private to prevent unsafe usage by callers.
   * @param memViews  The views
   * @return          unsafeView - The conjoined view pointing to the new memory
   */
  function unsafeJoin(bytes29[] memory memViews, uint256 _location) private view returns (bytes29 unsafeView) {
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      let ptr := mload(0x40)
      // revert if we're writing in occupied memory
      if gt(ptr, _location) {
        revert(0x60, 0x20) // empty revert message
      }
    }

    uint256 _offset = 0;
    for (uint256 i = 0; i < memViews.length; i++) {
      bytes29 memView = memViews[i];
      unchecked {
        unsafeCopyTo(memView, _location + _offset);
        _offset += len(memView);
      }
    }
    unsafeView = unsafeBuildUnchecked(0, _location, _offset);
  }

  /**
   * @notice          Produce the keccak256 digest of the concatenated contents of multiple views.
   * @param memViews  The views
   * @return          bytes32 - The keccak256 digest
   */
  function joinKeccak(bytes29[] memory memViews) internal view returns (bytes32) {
    uint256 ptr;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ptr := mload(0x40) // load unused memory pointer
    }
    return keccak(unsafeJoin(memViews, ptr));
  }

  /**
   * @notice          Produce the sha256 digest of the concatenated contents of multiple views.
   * @param memViews  The views
   * @return          bytes32 - The sha256 digest
   */
  function joinSha2(bytes29[] memory memViews) internal view returns (bytes32) {
    uint256 ptr;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ptr := mload(0x40) // load unused memory pointer
    }
    return sha2(unsafeJoin(memViews, ptr));
  }

  /**
   * @notice          copies all views, joins them into a new bytearray.
   * @param memViews  The views
   * @return          ret - The new byte array
   */
  function join(bytes29[] memory memViews) internal view returns (bytes memory ret) {
    uint256 ptr;
    assembly {
      // solhint-disable-previous-line no-inline-assembly
      ptr := mload(0x40) // load unused memory pointer
    }

    bytes29 _newView;
    unchecked {
      _newView = unsafeJoin(memViews, ptr + 0x20);
    }
    uint256 _written = len(_newView);
    uint256 _footprint = footprint(_newView);

    assembly {
      // solhint-disable-previous-line no-inline-assembly
      // store the legnth
      mstore(ptr, _written)
      // new pointer is old + 0x20 + the footprint of the body
      mstore(0x40, add(add(ptr, _footprint), 0x20))
      ret := ptr
    }
  }
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}


