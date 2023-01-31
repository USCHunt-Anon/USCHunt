// : MIT

pragma solidity ^0.8.0;

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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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





// : MIT
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




/*
@HungryBunz Dev flattened version of ERC721 with unneccessary crap removed
*/
// : MIT
pragma solidity ^0.8.0;
//import"./Address.sol";
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}




// : None
// HungryBunz Implementation V1
pragma solidity ^0.8.0;

//import"./Ownable.sol";
//import"./PaymentSplitter.sol";
//import"./ERC721.sol";
//import"./ECDSA.sol";
//import"./Strings.sol";
//import"./Initializable.sol";

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}




interface IItem {
    function applyProperties(bytes32 properties, uint16 item) external view returns (bytes32);
}




interface IMetadataGen {
    function generateStats(address requester, uint16 newTokenId, uint32 password) external view returns (bytes16);
    function generateAttributes(address requester, uint16 newTokenId, uint32 password) external view returns (bytes16);
}




interface IEvolve {
    function evolve(uint8 next1of1, uint16 burntId, address owner, bytes32 t1, bytes32 t2) external view returns(bytes32);
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

//import"./Address.sol";

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */
contract PaymentSplitter {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    //Openzeppelin implementation makes this payable. Not needed.
    function initPaymentSplitter(address[] memory payees, uint256[] memory shares_) internal {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] = _released[account] + payment;
        _totalReleased = _totalReleased + payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}




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
interface IERC165 {
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




pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}




interface ISnax {
    function computeMultiplier(address requester, bytes16 targetStats, uint16[] memory team) external view returns (uint256);
    function feed(bytes16 stats, uint256 wholeBurn) external view returns (bytes16);
}




interface IMetadataRenderer {
    function renderMetadata(uint16 tokenId, bytes16 atts, bytes16 stats) external view returns (string memory);
}




// : MIT

pragma solidity ^0.8.0;

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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initialization
     */
    function ownableInit() internal {
        _setOwner(msg.sender);
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
        require(owner() == msg.sender, "Caller is not owner");
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
}




pragma solidity ^0.8.0;

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




interface nom {
    function burn(address account, uint256 amount) external;
    function unstake(uint16[] memory tokenIds, address targetAccount) external;
}




pragma solidity ^0.8.0;

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 * Openzepplen implementation pared down to reflect unused components.
 */
contract ERC721 is ERC165, IERC721 {
    using Address for address;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function initERC721(string memory name_, string memory symbol_) internal {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        //_balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        //_balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        //_balances[from] -= 1;
        //_balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}




contract HungryBunz is Initializable, PaymentSplitter, Ownable, ERC721 {
    //******************************************************
    //CRITICAL CONTRACT PARAMETERS
    //******************************************************
    using ECDSA for bytes32;
    using Strings for uint256;
    
    bool _saleStarted;
    bool _saleEnd;
    bool _metadataRevealed;
    bool _transferPaused;
    bool _bypassMintAuth;
    uint8 _season; //Defines rewards season
    uint8 _1of1Index; //Next available 1 of 1
    uint16 _totalSupply;
    uint16 _maxSupply;
    uint256 _maxPerWallet;
    uint256 _baseMintPrice;
    uint256 _nameTagPrice;
    //Address rather than interface because this is used as an address
    //for sender checks more often than used as interface.
    address _nomContractAddress;
    //Address rather than interface because this is used as an address
    //for sender checks more often than used as interface.
    address _xLayerGateway;
    address _openSea;
    address _signerAddress; //Public address for mint auth signature
    
    IItem items;
    ISnax snax;
    IMetadataRenderer renderer;
    IMetadataGen generator;
    IEvolve _evolver;
    ProxyRegistry _osProxies;
    
    //******************************************************
    //GAMEPLAY MECHANICS
    //******************************************************
    uint8 _maxRank; //Maximum rank setting to allow additional evolutions over time...
    mapping(uint8 => mapping(uint8 => uint16)) _evolveThiccness; //Required thiccness total to evolve by current rank
    mapping(uint8 => uint8) _1of1Allotted; //Allocated 1 of 1 pieces per season
    mapping(uint8 => bool) _1of1sOnThisLayer; //Permit 1/1s on this layer and season.
    mapping(uint8 => uint8) _maxStakeRankBySeason;
    
    //******************************************************
    //ANTI BOT AND FAIR LAUNCH HASH TABLES AND ARRAYS
    //******************************************************
    mapping(address => uint256) tokensMintedByAddress; //Tracks total NFTs minted to limit individual wallets.
    
    //******************************************************
    //METADATA HASH TABLES
    //******************************************************
    //Bools stored as uint256 to shave a few units off gas fees.
    mapping(uint16 => bytes32) metadataById; //Stores critical metadata by ID
    mapping(uint16 => bytes32) _lockedTokens; //Tracks tokens locked for staking
    mapping(uint16 => uint256) _inactiveOnThisChain; //Tracks which tokens are active on current chain
    mapping(bytes16 => uint256) _usedCombos; //Stores attribute combo hashes to guarantee uniqueness
    mapping(uint16 => string) namedBunz; //Stores names for bunz
    
    //******************************************************
    //CONTRACT CONSTRUCTOR AND INITIALIZER FOR PROXY
    //******************************************************
    constructor() {
        //Initialize ownable on implementation
        //to prevent any misuse of implementation
        //contract.
        ownableInit();
    }
    
    function initHungryBunz (
        address[] memory payees,
        uint256[] memory paymentShares
    )  external initializer
    {
        //Require to prevent users from initializing
        //implementation contract
        require(owner() == address(0) || owner() == msg.sender,
            "No.");
        
        ownableInit();
        initPaymentSplitter(payees, paymentShares);
        initERC721("HungryBunz", "BUNZ");

        _maxRank = 2;
        _maxStakeRankBySeason[0] = 1;
        _transferPaused = true;
        _signerAddress = 0xF658480075BA1158f12524409066Ca495b54b0dD;
        _baseMintPrice = 0.06 ether;
        _maxSupply = 8888;
        _maxPerWallet = 5;
        _nameTagPrice = 200 * 10**18;
        _evolveThiccness[0][1] = 5000;
        _evolveThiccness[0][2] = 30000;
        //Guesstimate on targets for season 1
        _evolveThiccness[1][1] = 15000;
        _evolveThiccness[1][2] = 30000;
        _1of1Index = 1; //Initialize at 1
        
        //WL Opensea Proxies for Cheaper Trading
        _openSea = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;
        _osProxies = ProxyRegistry(_openSea);
    }
    
    //******************************************************
    //OVERRIDES TO HANDLE CONFLICTS BETWEEN IMPORTS
    //******************************************************
    function _burn(uint256 tokenId) internal virtual override(ERC721) {
        ERC721._burn(tokenId);
        delete metadataById[uint16(tokenId)];
        _totalSupply -= 1;
    }
    
    //Access to ERC721 implementation for use within app contracts.
    function applicationOwnerOf(uint256 tokenId) public view returns (address) {
        return ERC721.ownerOf(tokenId);
    }
    
    //Override ownerOf to accomplish lower cost alternative to lock tokens for staking.
    function ownerOf(uint256 tokenId) public view virtual override(ERC721) returns (address) {
        address owner = ERC721.ownerOf(tokenId);
        if (lockedForStaking(tokenId)) {
            owner = address(uint160(owner) - 1);
        } else if (_inactiveOnThisChain[uint16(tokenId)] == 1) {
            owner = address(0);
        }
        return owner;
    }
    
    //Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    function isApprovedForAll(
        address owner,
        address operator
    )
        public
        view
        override(ERC721)
        returns (bool)
    {
        if (address(_osProxies.proxies(owner)) == operator) {
            return true;
        }
        
        return ERC721.isApprovedForAll(owner, operator);
    }
    
    //Override for simulated transfers and burns.
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override(ERC721) returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        //Transfers not allowed while inactive on this chain. Transfers
        //potentially allowed when spender is foraging contract and
        //token is locked for staking.
        return ((spender == owner || getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender) || spender == address(this)) &&
            (!lockedForStaking(tokenId) || spender == _nomContractAddress) &&
            _inactiveOnThisChain[uint16(tokenId)] == 0 && !_transferPaused);
    }
    
    //******************************************************
    //OWNER ONLY FUNCTIONS TO CONNECT CHILD CONTRACTS.
    //******************************************************    
    function ccNom(address contractAddress) public onlyOwner {
        //Not cast to interface as this will need to be cast to address
        //more often than not.
        _nomContractAddress = contractAddress;
    }
    
    function ccGateway(address contractAddress) public onlyOwner {
        //Notably not cast to interface because this contract never calls
        //functions on gateway.
        _xLayerGateway = contractAddress;
    }

    function ccSnax(ISnax contractAddress) public onlyOwner {
        snax = contractAddress;
    }
    
    function ccItems(IItem contractAddress) public onlyOwner {
        items = contractAddress;
    }
    
    function ccGenerator(IMetadataGen contractAddress) public onlyOwner {
        generator = contractAddress;
    }
    
    function ccRenderer(IMetadataRenderer newRenderer) public onlyOwner {
        renderer = newRenderer;
    }
    
    function ccEvolution(IEvolve newEvolver) public onlyOwner {
        _evolver = newEvolver;
    }

    function getInterfaces() external view returns (bytes memory) {
        return abi.encodePacked(
            _nomContractAddress,
            _xLayerGateway,
            address(snax),
            address(items),
            address(generator),
            address(renderer),
            address(_evolver)
        );
    }
    
    //******************************************************
    //OWNER ONLY FUNCTIONS TO MANAGE CRITICAL PARAMETERS
    //******************************************************
    function startSale() public onlyOwner {
        require(_saleEnd == false, "Cannot restart sale.");
        _saleStarted = true;
    }
    
    function endSale() public onlyOwner {
        _saleStarted = false;
        _saleEnd = true;
    }

    function enableTransfer() public onlyOwner {
        _transferPaused = false;
    }

    //Emergency transfer pause to prevent innapropriate transfer of tokens.
    function pauseTransfer() public onlyOwner {
        _transferPaused = true;
    }
    
    function changeWalletLimit(uint16 newLimit) public onlyOwner {
        //Set to 1 higher than limit for cheaper less than check!
        _maxPerWallet = newLimit;
    }
    
    function reduceSupply(uint16 newSupply) public onlyOwner {
        require (newSupply < _maxSupply,
            "Can only reduce supply");
        require (newSupply > _totalSupply,
            "Cannot reduce below current!");
        _maxSupply = newSupply;
    }
    
    function update1of1Index(uint8 oneOfOneIndex) public onlyOwner {
        //This function is provided exclusively so that owner may
        //update 1of1Index to facilitate creation of 1of1s on L2
        //if this is deemed to be a feature of interest to community
        _1of1Index = oneOfOneIndex;
    }
    
    function startNewSeason(uint8 oneOfOneCount, bool enabledOnThisLayer, uint8 maxStakeRank) public onlyOwner {
        //Require all 1 of 1s for current season claimed before
        //starting a new season. L2 seasons will require sync.
        require(_1of1Index == _1of1Allotted[_season],
            "No.");
        _season++;
        _1of1Allotted[_season] = oneOfOneCount + _1of1Index;
        _1of1sOnThisLayer[_season] = enabledOnThisLayer;
        _maxStakeRankBySeason[_season] = maxStakeRank;
    }
    
    function addRank(uint8 newRank) public onlyOwner { //Used to enable third, fourth, etc. evolution levels.
        _maxRank = newRank;
    }
    
    function updateEvolveThiccness(uint8 rank, uint8 season, uint16 threshold) public onlyOwner {
        //Rank as current. E.G. (1, 10000) sets threshold to evolve to rank 2
        //to 10000 pounds or thiccness points
        _evolveThiccness[season][rank] = threshold;
    }
    
    function setPriceToName(uint256 newPrice) public onlyOwner {
        _nameTagPrice = newPrice;
    }
    
    function reveal() public onlyOwner {
        _metadataRevealed = true;
    }
    
    function bypassMintAuth() public onlyOwner {
        _bypassMintAuth = true;
    }
    
    //******************************************************
    //VIEWS FOR CRITICAL INFORMATION
    //******************************************************
    function baseMintPrice() public view returns (uint256) {
        return _baseMintPrice;
    }
    
    function totalMintPrice(uint8 numberOfTokens) public view returns (uint256) {
        return _baseMintPrice * numberOfTokens;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
    
    //******************************************************
    //ANTI-BOT PASSWORD HANDLERS
    //******************************************************
    function hashTransaction(address sender, uint256 qty, bytes8 salt) private pure returns(bytes32) {
          bytes32 hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(sender, qty, salt)))
          );
          
          return hash;
    }
    
    function matchAddresSigner(bytes32 hash, bytes memory signature) public view returns(bool) {
        return (_signerAddress == hash.recover(signature));
    }
    
    //******************************************************
    //TOKENURI OVERRIDE RELOCATED TO BELOW UTILITY FUNCTIONS
    //******************************************************
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token Doesn't Exist");
        //Heavy lifting is done by rendering contract.
        bytes16 atts = serializeAtts(uint16(tokenId));
        bytes16 stats = serializeStats(uint16(tokenId));
        return renderer.renderMetadata(uint16(tokenId), atts, stats);
    }
    
    function _writeSerializedAtts(uint16 tokenId, bytes16 newAtts) internal {
        bytes16 currentStats = serializeStats(tokenId);
        metadataById[tokenId] = bytes32(abi.encodePacked(newAtts, currentStats));
    }
    
    function writeSerializedAtts(uint16 tokenId, bytes16 newAtts) external {
        require(msg.sender == _xLayerGateway,
            "Not Gateway!");
        _writeSerializedAtts(tokenId, newAtts);
    }
    
    function serializeAtts(uint16 tokenId) public view returns (bytes16) {
        return _metadataRevealed ? bytes16(metadataById[tokenId]) : bytes16(0);
    }
    
    function _writeSerializedStats(uint16 tokenId, bytes16 newStats) internal {
        bytes16 currentAtts = serializeAtts(tokenId);
        metadataById[tokenId] = bytes32(abi.encodePacked(currentAtts, newStats));
    }
    
    function writeSerializedStats(uint16 tokenId, bytes16 newStats) external {
        require(msg.sender == _xLayerGateway,
            "Not Gateway!");
        _writeSerializedStats(tokenId, newStats);
    }
    
    function serializeStats(uint16 tokenId) public view returns (bytes16) {
        return _metadataRevealed ? bytes16(metadataById[tokenId] << 128) : bytes16(0);
    }
    
    function propertiesBytes(uint16 tokenId) external view returns(bytes32) {
        return metadataById[tokenId];
    }
    
    //******************************************************
    //STAKING VIEWS
    //******************************************************
    function lockedForStaking (uint256 tokenId) public view returns(bool) {
        return uint8(bytes1(_lockedTokens[uint16(tokenId)])) == 1;
    }

    //Check stake checks both staking status and ownership.
    function checkStake (uint16 tokenId) external view returns (address) {
        return lockedForStaking(tokenId) ? applicationOwnerOf(tokenId) : address(0);
    }

    //Returns staking timestamp
    function stakeStart (uint16 tokenId) public view returns(uint248) {
        return uint248(bytes31(_lockedTokens[tokenId] << 8));
    }

    //******************************************************
    //STAKING LOCK / UNLOCK AND TIMESTAMP FUNCTION
    //******************************************************
    function updateStakeStart (uint16 tokenId, uint248 newTime) external {
        uint8 stakeStatus = uint8(bytes1(_lockedTokens[tokenId]));
        _lockedTokens[tokenId] = bytes32(abi.encodePacked(stakeStatus, newTime));
    }
    function lockForStaking (uint16 tokenId) external {
        //Nom contract performs owner of check to prevent malicious locking
        require(msg.sender == _nomContractAddress,
            "Unauthorized");
        require(!lockedForStaking(tokenId),
            "Already locked!");
        //Metadata byte 16 is rank, 17 is season.
        require(_maxStakeRankBySeason[uint8(metadataById[tokenId][17])] >= uint8(metadataById[tokenId][16]),
            "Cannot Stake");
        bytes31 currentTimestamp = bytes31(_lockedTokens[tokenId] << 8);
        //Food coma period will persist after token transfer.
        uint248 stakeTimestamp = uint248(currentTimestamp) < block.timestamp ?
            uint248(block.timestamp) : uint248(currentTimestamp);
        _lockedTokens[tokenId] = bytes32(abi.encodePacked(uint8(1), stakeTimestamp));
        
        //Event with ownerOf override clears secondary listings.
        emit Transfer(applicationOwnerOf(tokenId), 
            address(uint160(applicationOwnerOf(tokenId)) - 1),
            tokenId);
    }
    
    function unlock (uint16 tokenId, uint248 newTime) external {
        //Nom contract performs owner of check to prevent malicious unlocking
        require(msg.sender == _nomContractAddress,
            "Unauthorized");
        require(lockedForStaking(tokenId),
            "Not locked!");
        _lockedTokens[tokenId] = bytes32(abi.encodePacked(uint8(0), newTime));
        
        //Event with ownerOf override restores token in marketplace accounts
        emit Transfer(address(uint160(applicationOwnerOf(tokenId)) - 1),
            applicationOwnerOf(tokenId),
            tokenId);
    }
    
    //******************************************************
    //L2 FUNCTIONALITY
    //******************************************************
    function setInactiveOnThisChain(uint16 tokenId) external {
        //This can only be called by the gateway contract to prevent exploits.
        //Gateway will check ownership, and setting inactive is a pre-requisite
        //to issuing the message to mint token on the other chain. By verifying
        //that we aren't trying to re-teleport here, we save back and forth to
        //check the activity status of the token on the gateway contract.
        require(msg.sender == _xLayerGateway,
            "Not Gateway!");
        require(_inactiveOnThisChain[tokenId] == 0,
            "Already inactive!");
        
        //Unstake token to mitigate very minimal exploit by staking then immediately
        //bridging to another layer to accrue slightly more tokens in a given time.
        uint16[] memory lockedTokens = new uint16[](1);
        lockedTokens[0] = tokenId;
        nom(_nomContractAddress).unstake(lockedTokens, applicationOwnerOf(tokenId));
        _inactiveOnThisChain[tokenId] = 1;
        
        //Event with ownerOf override clears secondary listings.
        emit Transfer(applicationOwnerOf(tokenId), address(0), tokenId);
    }
    
    function setActiveOnThisChain(uint16 tokenId, bytes memory metadata, address sender) external {
        require(msg.sender == _xLayerGateway,
            "Not Gateway!");
        if (_exists(uint256(tokenId))) {
            require(_inactiveOnThisChain[tokenId] == 1,
                "Already active");
        }
        _inactiveOnThisChain[tokenId] = 0;
        
        if(!_exists(uint256(tokenId))) {
            _safeMint(sender, tokenId);
        } else {
            address localOwner = applicationOwnerOf(tokenId);
            if (localOwner != sender) {
                //This indicates a transaction occurred
                //on the other layer. Transfer.
                safeTransferFrom(localOwner, sender, tokenId);
            }
        }
        
        metadataById[tokenId] = bytes32(metadata);
        
        uint16 burntId = uint16(bytes2(abi.encodePacked(metadata[14], metadata[15])));
        if (_exists(uint256(burntId))) {
            _burn(burntId);
        }
        
        //Event with ownerOf override restores token in marketplace accounts
        emit Transfer(address(0), applicationOwnerOf(tokenId), tokenId);
    }
    
    //******************************************************
    //MINT FUNCTIONS
    //******************************************************
    function _mintToken(address to, uint32 password, uint16 newId) internal {        
        //Generate data in mint function to reduce calls. Cost 40k.
        //While loop and additional write operation is necessary
        //evil to prevent duplicates.
        bytes16 newAtts;
        while(newAtts == 0 || _usedCombos[newAtts] == 1) {
            newAtts = generator.generateAttributes(to, newId, password);
            password++;
        }
        _usedCombos[newAtts] = 1;
        
        bytes16 newStats = generator.generateStats(to, newId, password);
        metadataById[newId] = bytes32(abi.encodePacked(newAtts, newStats));

        //Cost 20k.
        _safeMint(to, newId);
    }
    
    function publicAccessMint(uint8 numberOfTokens, bytes memory signature, bytes8 salt)
        public
        payable
    {
        //Between the use of msg.sender in the tx hash for purchase authorization,
        //and the requirements for wallet limiter, saving the salt is an undesirable
        //gas add. Users may re-use the same hash for multiple Txs if they prefer,
        //instead of maxing out their mint the first time.
        bytes32 txHash = hashTransaction(msg.sender, numberOfTokens, salt);
        
        require(_saleStarted,
            "Sale not live.");
        if (!_bypassMintAuth) {
            require(matchAddresSigner(txHash, signature),
                "Unauthorized!");
        }
        require((numberOfTokens + tokensMintedByAddress[msg.sender] < _maxPerWallet),
            "Exceeded max mint.");
        require(_totalSupply + numberOfTokens <= _maxSupply,
            "Not enough supply");
        require(msg.value >= totalMintPrice(numberOfTokens),
            "Insufficient funds.");
        
        //Set tokens minted by address before calling internal mint
        //to revert on attempted reentry to bypass wallet limit.
        uint16 offset = _totalSupply;
        tokensMintedByAddress[msg.sender] += numberOfTokens;
        _totalSupply += numberOfTokens; //Set once to save a few k gas

        for (uint i = 0; i < numberOfTokens; i++) {
            offset++;
            _mintToken(msg.sender, uint32(bytes4(signature)), offset);
        }
    }
    
    //******************************************************
    //BURN NOM FOR STAT BOOSTS
    //******************************************************
    //Team must be passed as an argument since gas fees to enumerate a
    //user's collection with Enumerable or similar are too high to justify.
    //Sanitization of the input array is done on the snax contract.
    function consume(uint16 consumer, uint256 burn, uint16[] memory team) public {
        //We only check that a token is active on this chain.
        //You may burn NOM to boost friends' NFTs if you wish.
        //You may also burn NOM to feed currently staked Bunz
        require(_inactiveOnThisChain[consumer] == 0,
            "Not active on this chain!");
        
        //Attempt to burn requisite amount of NOM. Will revert if
        //balance insufficient. This contract is approved burner
        //on NOM contract by default.
        nom(_nomContractAddress).burn(msg.sender, burn);
        
        uint256 wholeBurnRaw = burn / 10 ** 18; //Convert to integer units.
        bytes16 currentStats = serializeStats(consumer);
        //Computation done in snax contract for upgradability. Stack depth
        //limits require us to break the multiplier calc out into a separate
        //call to the snax contract.
        uint256 multiplier = snax.computeMultiplier(msg.sender, currentStats, team); //Returns BPS
        uint256 wholeBurn = (wholeBurnRaw * multiplier) / 10000;
        
        //Snax contract will take a tokenId, retrieve critical stats
        //and then modify stats, primarily thiccness, based on total
        //tokens burned. Output bytes are written back to struct.
        bytes16 transformedStats = snax.feed(currentStats, wholeBurn);
        _writeSerializedStats(consumer, transformedStats);
    }
    
    //******************************************************
    //ATTACH ITEM
    //******************************************************
    function attach(uint16 base, uint16 consumableItem) public {
        //This function will call another function on the item
        //NFT contract which will burn an item, apply its properties
        //to the base NFT, and return these values.
        require(msg.sender == applicationOwnerOf(base),
            "Don't own this token"); //Owner of check performed in item contract
        require(_inactiveOnThisChain[base] == 0,
            "Not active on this chain!");
            
        bytes32 transformedProperties = items.applyProperties(metadataById[base], consumableItem);
        metadataById[base] = transformedProperties;
    }
    
    //******************************************************
    //NAME BUNZ
    //******************************************************
    function getNameTagPrice() public view returns(uint256) {
        return _nameTagPrice;
    }
    
    function name(uint16 tokenId, string memory newName) public {
        require(msg.sender == applicationOwnerOf(tokenId),
            "Don't own this token"); //Owner of check performed in item contract
        require(_inactiveOnThisChain[tokenId] == 0,
            "Not active on this chain!");
            
        //Attempt to burn requisite amount of NOM. Will revert if
        //balance insufficient. This contract is approved burner
        //on NOM contract by default.
        nom(_nomContractAddress).burn(msg.sender, _nameTagPrice);
        
        namedBunz[tokenId] = newName;
    }
    
    //Hook for name not presently used in metadata render contract.
    //Provided for future use.
    function getTokenName(uint16 tokenId) public view returns(string memory) {
        return namedBunz[tokenId];
    }
    
    //******************************************************
    //PRESTIGE SYSTEM
    //******************************************************
    function prestige(uint16[] memory tokenIds) public {
        //This is ugly, but the gas savings elsewhere justify this spaghetti.
        for(uint16 i = 0; i < tokenIds.length; i++) {
            if (uint8(metadataById[tokenIds[i]][17]) != _season) {
                bytes16 currentAtts = serializeAtts(tokenIds[i]);
                bytes12 currentStats = bytes12(metadataById[tokenIds[i]] << 160);
                
                //Atts and rank (byte 16) stay the same. Season (byte 17) and thiccness (bytes 18 and 19) change.
                metadataById[tokenIds[i]] = bytes32(abi.encodePacked(
                        currentAtts, metadataById[tokenIds[i]][16], bytes1(_season), bytes2(0), currentStats
                    ));
            }
        }
    }
    
    //******************************************************
    //EVOLUTION MECHANISM
    //******************************************************
    function evolve(uint16 firstToken, uint16 secondToken) public {
        uint8 rank = uint8(metadataById[firstToken][16]);
        require((rank == uint8(metadataById[secondToken][16])) && (rank < _maxRank),
            "Can't evolve these bunz");
        uint8 season1 = uint8(metadataById[firstToken][17]);
        uint8 season = uint8(metadataById[secondToken][17]) > season1 ? uint8(metadataById[secondToken][17]) : season1;
        uint16 thiccness = uint16(bytes2(abi.encodePacked(metadataById[firstToken][18], metadataById[firstToken][19]))) +
            uint16(bytes2(abi.encodePacked(metadataById[secondToken][18], metadataById[secondToken][19])));
        
        //ownerOf will return the 0 address if tokens are on another layer, and address -1 if staked.
        //Forcing unstake before evolve does not add enough to gas fees to justify the complex
        //logic to gracefully handle token burn while staked without introducing possible attack
        //vectors.
        require(ownerOf(firstToken) == msg.sender && ownerOf(secondToken) == msg.sender, 
            "Not called by owner.");
        require(ownerOf(firstToken) == applicationOwnerOf(firstToken),
            "Unlucky");
        require(thiccness >= _evolveThiccness[season][rank],
            "Not thicc enough.");
        
        //Below logic uses the higher season of the two tokens, since otherwise
        //tying this to global _season would allow users to earn 1/1s without
        //prestiging.
        uint8 next1of1 = (_1of1Index <= _1of1Allotted[season]) && _1of1sOnThisLayer[season] ? _1of1Index : 0;
        bytes32 evolvedToken = _evolver.evolve(next1of1, secondToken, msg.sender, metadataById[firstToken], metadataById[secondToken]);
        
        if (uint8(evolvedToken[8]) != 0) {
            _1of1Index++;
        }
        
        metadataById[firstToken] = evolvedToken;
        _burn(secondToken);
    }
}
