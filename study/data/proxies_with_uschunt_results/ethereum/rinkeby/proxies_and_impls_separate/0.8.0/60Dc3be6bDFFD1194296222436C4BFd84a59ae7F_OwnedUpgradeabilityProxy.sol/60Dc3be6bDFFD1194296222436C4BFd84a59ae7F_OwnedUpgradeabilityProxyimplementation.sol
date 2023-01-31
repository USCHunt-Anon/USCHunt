// : MIT

pragma solidity ^0.8.0;

//import"./IERC1155.sol";
//import"./IERC1155Receiver.sol";
//import"./extensions/IERC1155MetadataURI.sol";
//import"../../utils/Address.sol";
//import"../../utils/Context.sol";
//import"../../utils/introspection/ERC165.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        _balances[id][account] = accountBalance - amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


// : MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


// : MIT
pragma solidity ^0.8.0;

//import"@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
//import"./Ownable.sol";

contract CreatorCoin is Ownable, ERC1155 {
    // state variables
    mapping(uint256 => string) public metadataHash;
    mapping(string => bool) public metadataExists;

    string public baseUri;

    constructor(string memory _baseUri) ERC1155(_baseUri) {
        baseUri = _baseUri;
    }

    // override a data to get the token  metadata by token id
    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseUri, metadataHash[id]));
    }

    // a function to mint erc1155 tokens
    function mint(
        address _to,
        uint256 _id,
        uint256 _noOfTokens,
        string memory _tokenMetadataHash
    ) public onlyOwner {
        require(
            !(metadataExists[_tokenMetadataHash]),
            "Property already exists."
        );

        metadataHash[_id] = _tokenMetadataHash;
        metadataExists[_tokenMetadataHash] = true;

        _mint(_to, _id, _noOfTokens, "");
    }

    // overriding safeTransferFrom and safeTransferFromBatch methods
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override onlyOwner {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyOwner {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}


// : GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


// : MIT

pragma solidity ^0.8.0;

//import"../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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


// : MIT

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// : MIT

pragma solidity ^0.8.0;

//import"./IERC165.sol";

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


// : MIT
pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}


// : MIT
pragma solidity ^0.8.0;
//import"@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
//import"@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//import"@openzeppelin/contracts/utils/math/SafeMath.sol";
//import"./CreatorCoin.sol";
//import"./TransferHelper.sol";

interface oracleInterface {
    function latestAnswer() external view returns (int256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract STO is Ownable {
    using SafeMath for uint256;
    uint256 public creatorCounter;
    CreatorCoin creatorCoinInstance;
    address public usdtContractAddress =
        0x6131ca327571AfD53139fc8d10917F1bf9Bb62fE;
    address public oracleWrapperAddress =
        0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB;
    address public creatorCoinAddress;
    uint256 public tokenDecimalFactor = 10**8;
    struct WhiteListInfo {
        uint256 userRole;
        bool isWhitelisted;
    }
    mapping(address => WhiteListInfo) public whitelistMapping;
    struct PropertyInfo {
        uint256 propertyValue;
        uint256 totalSupply;
        uint256 minAccreditedTokensToBeSold;
        uint256 maxNonAccreditedTokensToBeSold;
        uint256 accreditedTokensSold;
        uint256 nonAccreditedTokensSold;
        uint256 claimCounter;
        address propertyOwner;
    }
    mapping(uint256 => PropertyInfo) public propertyMapping; // mapping to save who minted tokens for that property while propertyListerMapping
    struct UserIncentiveData {
        uint256 claimedCounter;
        uint256 timestamp;
    }
    // a mapping to keep track of user's incentives
    mapping(uint256 => mapping(address => UserIncentiveData))
        public userIncentiveMapping;
    // a struct for the property incentives
    struct PropertyIncentive {
        uint256 tokenIncentiveAmount;
        uint256 tokenSoldAtTime;
        uint256 timestamp;
    }
    //  a mapping to keep track of the property incentives
    mapping(uint256 => mapping(uint256 => PropertyIncentive))
        public propertyIncentiveMapping;
    // a struct to keep track of offers
    struct Offer {
        uint256 offerId;
        uint256 tokenId;
        uint256 tokenAmount;
        uint256 usdtTokenAmount;
        bool isActive;
        address offerCreator;
    }
    // a mapping to keep track of offerId for a given user and property id
    mapping(address => mapping(uint256 => uint256)) public userOfferIdMapping;
    // mapping to map token id to offerId to the offers
    mapping(uint256 => mapping(uint256 => Offer)) public idToOfferMapping;
    // a mapping to keep track of whether this user has created offer for this property or not;
    mapping(address => mapping(uint256 => bool)) public isOfferCreated;
    // a mapping to keep track of the individual offerCounts for each property
    mapping(uint256 => uint256) idToOfferCountMapping;
    // events
    event mintToken(
        uint256 _id,
        string _hash,
        uint256 _propertyValue,
        uint256 _tokenAmount,
        address _userAddress
    );
    event buyProperty(
        uint256 _id,
        uint256 _tokenAmount,
        uint256 _usdtTokenAmount,
        address buyerAddress,
        address propertyOwner
    );
    event incentiveClaimed(
        address _claimerAddress,
        uint256 _claimCount,
        uint256 _incentiveAmount,
        uint256 _id
    );

    event offerCreated(
        uint256 offerId,
        uint256 _id,
        uint256 tokenAmount,
        uint256 usdtTokenAmount,
        bool isActive,
        address offerCreator
    );
    event offerEdited(
        uint256 offerId,
        uint256 _id,
        uint256 tokenAmount,
        uint256 usdtTokenAmount,
        bool isActive,
        address offerCreator
    );
    event offerAccepted(
        uint256 offerId,
        uint256 _id,
        uint256 tokenAmount,
        uint256 usdtTokenAmount,
        address buyerAddress,
        address sellerAddress
    );

    bool isInitialized;

    function initialize(
        address owner,
        address _creatorCoinAddress,
        address _usdtContractAddress,
        address _oracleWrapperAddress
    ) public {
        require(!isInitialized, "Already initialized");
        _setOwner(owner);
        isInitialized = true;
        creatorCoinAddress = _creatorCoinAddress;
        usdtContractAddress = _usdtContractAddress;
        oracleWrapperAddress = _oracleWrapperAddress;
        tokenDecimalFactor = 10**8;
        creatorCoinInstance = CreatorCoin(creatorCoinAddress);
    }

    // a method to whitelist the address to buy/sell properties
    function whitelistAddress(
        address _userAddress,
        uint256 _userRole,
        bool _status
    ) external onlyOwner {
        WhiteListInfo memory wLInfo = WhiteListInfo({
            userRole: _userRole,
            isWhitelisted: _status
        });
        whitelistMapping[_userAddress] = wLInfo;
    }

    function create(
        uint256 _propertyValue,
        uint256 _noOfTokens,
        uint32 _minAccreditedTokenShare, //10^3
        address _to,
        string memory _tokenMetadataHash
    ) external onlyOwner {
        require(
            whitelistMapping[_to].isWhitelisted,
            "you can't perform this operation for this user."
        );
        require(
            whitelistMapping[_to].userRole == 2,
            "Only investor can list his property."
        );
        creatorCounter++;
        uint256 _minAccreditedTokensToBeSold = (
            (uint256(_minAccreditedTokenShare).mul(_noOfTokens))
        ).div(10**5);
        PropertyInfo memory pInfo = PropertyInfo({
            propertyValue: _propertyValue,
            totalSupply: _noOfTokens,
            minAccreditedTokensToBeSold: _minAccreditedTokensToBeSold,
            maxNonAccreditedTokensToBeSold: _noOfTokens.sub(
                _minAccreditedTokensToBeSold
            ),
            claimCounter: 0,
            propertyOwner: _to,
            accreditedTokensSold: 0,
            nonAccreditedTokensSold: 0
        });
        // saving who minted the property tokens
        propertyMapping[creatorCounter] = pInfo;
        creatorCoinInstance.mint(
            _to,
            creatorCounter,
            _noOfTokens,
            _tokenMetadataHash
        );
        emit mintToken(
            creatorCounter,
            creatorCoinInstance.uri(creatorCounter),
            _propertyValue,
            _noOfTokens,
            _to
        );
    }

    function buy(uint256 _id, uint256 _usdtTokenAmount) external validId(_id) {
        // check that user is whitelisted
        require(
            whitelistMapping[msg.sender].isWhitelisted,
            "you can't perform this operation for this user."
        );
        bool isAccreditedUser = whitelistMapping[msg.sender].userRole == 2;
        // get how much usdt tokens are required for this purchase
        uint256 _propertyTokenAmount = _getPropertyTokenAmount(
            _id,
            _usdtTokenAmount
        );
        require(
            propertyMapping[_id].nonAccreditedTokensSold +
                propertyMapping[_id].accreditedTokensSold +
                _propertyTokenAmount <=
                propertyMapping[_id].totalSupply,
            "This amount is not available"
        );
        if (!isAccreditedUser) {
            // if its a non accredited user , check that buying this amount doesnot exceed the buy limit of
            require(
                propertyMapping[_id].nonAccreditedTokensSold +
                    _propertyTokenAmount <=
                    propertyMapping[_id].maxNonAccreditedTokensToBeSold,
                "This Amount is not available for non accredited user."
            );
        }
        // check that this contract has approval to spend buyers usdts
        require(
            IERC20(usdtContractAddress).allowance(msg.sender, address(this)) >=
                _usdtTokenAmount,
            "Contract needs approval to spend usdt tokens"
        );
        if (balanceOf(msg.sender, _id) > 0) {
            require(
                userIncentiveMapping[_id][msg.sender].claimedCounter ==
                    propertyMapping[_id].claimCounter,
                "Claim tokens before buying"
            );
        }
        // check that the property lister has approved this contract to spend its poroperty tokens
        require(
            creatorCoinInstance.isApprovedForAll(
                propertyMapping[_id].propertyOwner,
                address(this)
            ),
            "Contract needs approval to spend lister's property tokens"
        );
        // check that user has enough usdts
        require(
            IERC20(usdtContractAddress).balanceOf(msg.sender) >=
                _usdtTokenAmount,
            "User has insufficient tokens"
        );
        // check that property lister  has enough _noOfTokens
        require(
            creatorCoinInstance.balanceOf(
                propertyMapping[_id].propertyOwner,
                _id
            ) >= _propertyTokenAmount,
            "Property lister has insufficient tokens"
        );
        // send usdt from user to property owner
        TransferHelper.safeTransferFrom(
            usdtContractAddress,
            msg.sender,
            propertyMapping[_id].propertyOwner,
            _usdtTokenAmount
        );
        // send property tokens to the buyer
        creatorCoinInstance.safeTransferFrom(
            propertyMapping[_id].propertyOwner,
            msg.sender,
            _id,
            _propertyTokenAmount,
            ""
        );
        if (isAccreditedUser) {
            propertyMapping[_id].accreditedTokensSold = propertyMapping[_id]
                .accreditedTokensSold
                .add(_propertyTokenAmount);
        } else {
            propertyMapping[_id].nonAccreditedTokensSold = propertyMapping[_id]
                .nonAccreditedTokensSold
                .add(_propertyTokenAmount);
        }
        // // save the userIncentive
        UserIncentiveData memory newIncentive = UserIncentiveData({
            claimedCounter: propertyMapping[_id].claimCounter,
            timestamp: block.timestamp
        });
        userIncentiveMapping[_id][msg.sender] = newIncentive;
        emit buyProperty(
            _id,
            _propertyTokenAmount,
            _usdtTokenAmount,
            msg.sender,
            propertyMapping[_id].propertyOwner
        );
    }

    // an internal method to calculate how much usdt is require to buy x amount of property tokens _getRequiredCurrencyAmount
    function _getPropertyTokenAmount(uint256 _id, uint256 _usdtTokenAmount)
        public
        view
        validId(_id)
        returns (uint256)
    {
        uint256 currentPropertyValue = propertyMapping[_id].propertyValue;
        require(currentPropertyValue != 0, "Property not listed yet.");

        // do the calculations here
        uint256 unitCurrencyPrice = 100043275;
        // uint256 unitCurrencyPrice =   (uint256)( oracleInterface(oracleWrapperAddress).latestAnswer());
        uint256 usdtAmountInDollar = (_usdtTokenAmount.mul(unitCurrencyPrice))
            .div((10**IERC20(usdtContractAddress).decimals())); // $ in 10**8
        return (
            (usdtAmountInDollar.mul(propertyMapping[_id].totalSupply)).div(
                currentPropertyValue
            )
        );
    }

    function updatePropertyValue(uint256 _id, uint256 _propertyValue)
        external
        onlyOwner
        validId(_id)
    {
        propertyMapping[_id].propertyValue = _propertyValue;
    }

    // A function to list incentive
    function generateIncentive(uint256 _id, uint256 _usdtAmount)
        external
        onlyOwner
        validId(_id)
    {
        require(_usdtAmount != 0, "Usdt amount cannot be 0");
        require(
            IERC20(usdtContractAddress).balanceOf(msg.sender) >= _usdtAmount,
            "User has insufficient usdt to list incentive"
        );
        require(
            IERC20(usdtContractAddress).allowance(msg.sender, address(this)) >=
                _usdtAmount,
            "Contract needs approval to spend usdt tokens"
        );
        // transferring usdt from the incentive creator to the contract
        TransferHelper.safeTransferFrom(
            usdtContractAddress,
            msg.sender,
            address(this),
            _usdtAmount
        );
        PropertyIncentive memory newIncentive = PropertyIncentive({
            tokenIncentiveAmount: _usdtAmount,
            tokenSoldAtTime: (propertyMapping[_id].accreditedTokensSold).add(
                propertyMapping[_id].nonAccreditedTokensSold
            ),
            timestamp: block.timestamp
        });
        // incrementing the incentive count for this property id
        propertyMapping[_id].claimCounter = propertyMapping[_id]
            .claimCounter
            .add(1);
        propertyIncentiveMapping[_id][
            propertyMapping[_id].claimCounter
        ] = newIncentive;
    }

    // a method for the user to claim the incentives
    function claimIncentive(uint256 _id) external {
        require(
            userIncentiveMapping[_id][msg.sender].claimedCounter <
                propertyMapping[_id].claimCounter,
            "No Incentives to claim"
        );
        // checking that the claiming address has property tokens
        require(
            creatorCoinInstance.balanceOf(msg.sender, _id) > 0,
            "User has no property token balance"
        );
        uint256 claimCount = (
            userIncentiveMapping[_id][msg.sender].claimedCounter
        ).add(1);
        uint256 _incentiveAmount = (
            balanceOf(msg.sender, _id).mul(
                propertyIncentiveMapping[_id][claimCount].tokenIncentiveAmount
            )
        ).div(propertyIncentiveMapping[_id][claimCount].tokenSoldAtTime);

        require(
            IERC20(usdtContractAddress).balanceOf(address(this)) >=
                _incentiveAmount,
            "Contract has insufficient incentive balance"
        );
        TransferHelper.safeTransfer(
            usdtContractAddress,
            msg.sender,
            _incentiveAmount
        );
        userIncentiveMapping[_id][msg.sender].claimedCounter = claimCount;
        emit incentiveClaimed(msg.sender, claimCount, _incentiveAmount, _id);
    }

    // a method for users to create an offer to sell its tokens
    function createOffer(
        uint256 _id,
        uint256 _tokenAmount,
        uint256 _usdtTokenAmount
    )
        public
        validId(_id)
        validTokenAndUsdtAmount(_tokenAmount, _usdtTokenAmount)
    {
        require(
            !isOfferCreated[msg.sender][_id],
            "User has already created offer for this property"
        );
        require(
            creatorCoinInstance.balanceOf(msg.sender, _id) >= _tokenAmount,
            "User has insufficient property tokens"
        );

        idToOfferCountMapping[_id] = idToOfferCountMapping[_id].add(1);
        Offer memory newOffer = Offer({
            offerId: idToOfferCountMapping[_id],
            tokenId: _id,
            tokenAmount: _tokenAmount,
            usdtTokenAmount: _usdtTokenAmount,
            isActive: true,
            offerCreator: msg.sender
        });
        isOfferCreated[msg.sender][_id] = true;
        userOfferIdMapping[msg.sender][_id] = newOffer.offerId;
        idToOfferMapping[_id][newOffer.offerId] = newOffer;
        emit offerCreated(
            newOffer.offerId,
            _id,
            _tokenAmount,
            _usdtTokenAmount,
            true,
            msg.sender
        );
    }

    // function to edit the offer for a given property id and offerId
    function editOffer(
        uint256 _id,
        uint256 _offerId,
        uint256 _usdtTokenAmount,
        uint256 _tokenAmount
    )
        external
        validId(_id)
        validTokenAndUsdtAmount(_tokenAmount, _usdtTokenAmount)
    {
        // get the current offer
        Offer memory currentOffer = idToOfferMapping[_id][_offerId];
        // check that offer is active
        require(_offerId == currentOffer.offerId, "Invalid offerId");
        require(
            currentOffer.offerCreator == msg.sender,
            "Only offer creator can edit offers"
        );
        require(
            creatorCoinInstance.balanceOf(msg.sender, _id) >= _tokenAmount,
            "User has insufficient property tokens"
        );
        // edit the current offer
        currentOffer.tokenAmount = _tokenAmount;
        currentOffer.usdtTokenAmount = _usdtTokenAmount;
        // save the edited offer id
        idToOfferMapping[_id][_offerId] = currentOffer;
        emit offerEdited(
            _offerId,
            _id,
            _tokenAmount,
            _usdtTokenAmount,
            currentOffer.isActive,
            msg.sender
        );
    }

    // a function to activateOrDeactivate offers
    function changeOfferStatus(
        uint256 _id,
        uint256 _offerId,
        bool _isActive
    ) external validId(_id) {
        Offer memory currentOffer = idToOfferMapping[_id][_offerId];
        require(_offerId == currentOffer.offerId, "Invalid offerId");
        require(
            currentOffer.offerCreator == msg.sender,
            "Only offer creator can edit offers"
        );
        currentOffer.isActive = _isActive;
        idToOfferMapping[_id][_offerId] = currentOffer;

        emit offerEdited(
            _offerId,
            _id,
            currentOffer.tokenAmount,
            currentOffer.usdtTokenAmount,
            _isActive,
            msg.sender
        );
    }

    // function to accept the offer
    function acceptOffer(
        uint256 _id,
        uint256 _offerId,
        uint256 _tokenAmount
    ) external validId(_id) validOfferId(_id, _offerId) {
        Offer memory currentOffer = idToOfferMapping[_id][_offerId];
        require(
            currentOffer.offerCreator != msg.sender,
            "You cannot accept your own offers"
        );
        // check that offer has sufficient tokens available for selling
        require(
            currentOffer.tokenAmount >= _tokenAmount,
            "Offer has insufficient tokens , please try smaller amount"
        );
        // check approval for usdt
        require(
            creatorCoinInstance.isApprovedForAll(
                currentOffer.offerCreator,
                address(this)
            ),
            "Contract needs approval to spend  property tokens"
        );
        /// check that offer creator has balance for property tokens
        require(
            creatorCoinInstance.balanceOf(currentOffer.offerCreator, _id) >=
                currentOffer.tokenAmount,
            "Seller has insufficient property tokens"
        );
        uint256 requiredUsdtTokenAmount = (
            _tokenAmount.mul(currentOffer.usdtTokenAmount)
        ).div(currentOffer.tokenAmount);
        // check approval to property tokens
        require(
            IERC20(usdtContractAddress).allowance(msg.sender, address(this)) >=
                requiredUsdtTokenAmount,
            "Contract needs  approval to spend usdt tokens"
        );
        // check that buyer has sufficient usdt tokens
        require(
            IERC20(usdtContractAddress).balanceOf(msg.sender) >=
                requiredUsdtTokenAmount,
            "You have insufficient usdt token balance"
        );
        // send property tokens to buyer
        creatorCoinInstance.safeTransferFrom(
            currentOffer.offerCreator,
            msg.sender,
            _id,
            _tokenAmount,
            ""
        );
        // send usdt to seller
        TransferHelper.safeTransferFrom(
            usdtContractAddress,
            msg.sender,
            currentOffer.offerCreator,
            requiredUsdtTokenAmount
        );
        // update the current offer
        currentOffer.tokenAmount = currentOffer.tokenAmount.sub(_tokenAmount);
        currentOffer.usdtTokenAmount = currentOffer.usdtTokenAmount.sub(
            requiredUsdtTokenAmount
        );
        // save the updated offer
        idToOfferMapping[_id][_offerId] = currentOffer;

        emit offerAccepted(
            _offerId,
            _id,
            _tokenAmount,
            requiredUsdtTokenAmount,
            msg.sender,
            currentOffer.offerCreator
        );
    }

    modifier validId(uint256 _id) {
        require(_id <= creatorCounter, "Invalid id");
        _;
    }
    modifier validOfferId(uint256 _id, uint256 _offerId) {
        uint256 currentOfferId = idToOfferCountMapping[_id];
        require(_offerId <= currentOfferId, "Invalid offerId");
        _;
    }
    modifier validTokenAndUsdtAmount(
        uint256 _tokenAmount,
        uint256 _usdtTokenAmount
    ) {
        require(_tokenAmount > 0, "Invalid token amount");
        require(_usdtTokenAmount > 0, "Invalid usdt token amount");
        _;
    }

    // a method to get balance of property tokens
    function balanceOf(address _user, uint256 _id)
        public
        view
        returns (uint256)
    {
        return creatorCoinInstance.balanceOf(_user, _id);
    }

    function updateUSDTContractAddress(address _usdtContractAddress)
        external
        onlyOwner
    {
        usdtContractAddress = _usdtContractAddress;
    }
}


