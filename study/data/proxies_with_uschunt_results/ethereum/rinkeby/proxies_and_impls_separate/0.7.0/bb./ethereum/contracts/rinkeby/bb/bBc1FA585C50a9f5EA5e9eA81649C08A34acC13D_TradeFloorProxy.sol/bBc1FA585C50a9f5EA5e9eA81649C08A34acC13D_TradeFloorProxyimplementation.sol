// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"./IERC1155.sol";
//import"./IERC1155MetadataURI.sol";
//import"./IERC1155Receiver.sol";
//import"../../utils/Context.sol";
//import"../../introspection/ERC165.sol";
//import"../../math/SafeMath.sol";
//import"../../utils/Address.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) public {
        _setURI(uri_);

        // register the supported interfaces to conform to ERC1155 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155);

        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
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

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

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

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
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

        _balances[id][account] = _balances[id][account].add(amount);
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
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
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

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

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
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
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

pragma solidity >=0.6.0 <0.8.0;

//import"./ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(address account, uint256 id, uint256 value) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"./ERC1155.sol";
//import"../../utils/Pausable.sol";

/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
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
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}


// : MIT

pragma solidity >=0.6.2 <0.8.0;

//import"../../introspection/IERC165.sol";

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

pragma solidity >=0.6.2 <0.8.0;

//import"./IERC1155.sol";

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

pragma solidity >=0.6.0 <0.8.0;

//import"../../introspection/IERC165.sol";

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

pragma solidity >=0.6.0 <0.8.0;

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


// : MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

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
library EnumerableSet {
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


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor () internal {
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
}


/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * : Apache-2.0
 * See LICENSE.txt for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';
//import'@openzeppelin/contracts/utils/Context.sol';

//import'../utils/AddressBook.sol';
//import'../utils/interfaces/IAddressRegistry.sol';

//import'./interfaces/IMinterCallback.sol';
//import'./WOWSMinterPauser.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-1155[ERC1155]
 * Multi Token Standard, including the Metadata URI extension.
 *
 * This contract is an extension of the minter preset. It accepts the address
 * of the contract minting the token via the ERC-1155 data parameter. When
 * the token is transferred or burned, the minter is notified.
 */
contract TradeFloor is Context, WOWSMinterPauser {
  //////////////////////////////////////////////////////////////////////////////
  // State
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Mapping from minted token ID to minting contract
   *
   * Token IDs are approved for a minting contract upon minting. The token ID
   * is then exclusive to that contract, and can't be reused by a different
   * minting contract.
   */
  mapping(uint256 => address) private _tokenIdToMinter;

  /**
   * @dev Per token information, used to cap NFT's and
   * to allow querying a list of NFT's owned by an address
   */

  // using a stuct allows us to work byRef
  struct ListKey {
    uint64 index;
  }

  // Per token information
  struct TokenInfo {
    bool minted; // Make sure we only mint 1
    ListKey listKey; // Next tokenId in the owner linkedList
  }
  mapping(uint64 => TokenInfo) private _tokenInfos;

  // Mapping owner -> first owned token
  //
  // Note that we work 1 based here because of initialization
  // e.g. firstId == 1 links to tokenId 0;
  struct Owned {
    uint64 count;
    ListKey listKey; // First tokenId in linked list
  }
  mapping(address => Owned) private _owned;

  /**
   * @dev the registry to get the required addreeses from
   */
  IAddressRegistry private _addressRegistry;

  // Name of the metadata json file for OpenSea contract data
  string private _contractMetadataUri;

  // Conversion to hex string
  bytes16 private constant HEX_MAP = '0123456789ABCDEF';

  // bytes4(keccak256('contractURI()')) == 0xe8a3d485
  bytes4 private constant _INTERFACE_ID_CONTRACT_URI = 0xe8a3d485;

  /*
   * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
   * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
   *
   * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
   */
  bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
  uint256 private _fee = 1000; // 10%
  address private _feeRecipient;

  // Rarible events
  string private constant _NAME = 'WolvesOfWallStreet NFT';
  string private constant _SYMBOL = 'WOWS NFT';
  event CreateERC1155_v1(address indexed creator, string name, string symbol);
  event SecondarySaleFees(
    uint256 tokenId,
    address payable[] recipients,
    uint256[] bps
  );

  //////////////////////////////////////////////////////////////////////////////
  // Initialization
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Construct the contract
   *
   * @param addressRegistry registry containing our system addresses
   *
   * Note: Pause operation in this context. Only calls from Proxy allowed
   */
  constructor(IAddressRegistry addressRegistry) WOWSMinterPauser('') {
    // Initialize {AccessControl}
    address marketingWallet =
      addressRegistry.getRegistryEntry(AddressBook.MARKETING_WALLET);
    _setupRole(DEFAULT_ADMIN_ROLE, marketingWallet);
    _pause();
  }

  /**
   * @dev One time contract initializer
   *
   * @param addressRegistry registry containing our system addresses
   * @param tokenUriPrefix The ERC-1155 metadata URI Prefix
   * @param contractUri The contract metadata URI
   */
  function initialize(
    IAddressRegistry addressRegistry,
    string memory tokenUriPrefix,
    string memory contractUri
  ) public {
    require(address(_addressRegistry) == address(0), 'already initialized');
    // Set tokenURIPrefix
    _setURI(tokenUriPrefix);

    // Initialize {AccessControl}
    address marketingWallet =
      addressRegistry.getRegistryEntry(AddressBook.MARKETING_WALLET);
    _setupRole(DEFAULT_ADMIN_ROLE, marketingWallet);

    _feeRecipient = addressRegistry.getRegistryEntry(
      AddressBook.REWARD_HANDLER
    );

    _addressRegistry = addressRegistry;
    _contractMetadataUri = contractUri;

    // Rarible interface
    // Register contractURI interface
    _registerInterface(_INTERFACE_ID_CONTRACT_URI);
    // Register fee interface
    _registerInterface(_INTERFACE_ID_FEES);

    CreateERC1155_v1(_msgSender(), _NAME, _SYMBOL);
  }

  //////////////////////////////////////////////////////////////////////////////
  // Getters
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Get the minter of a given token
   *
   * @param tokenId the token ID to check
   *
   * @return minter Address of the minter of the token, or address(0) if the
   * token is not minted
   */
  function getMinter(uint256 tokenId) public view returns (address minter) {
    return _tokenIdToMinter[tokenId];
  }

  /**
   * @dev Opensea calls this fuction to get information about how to display storefront.
   * Our return value is the base URI of the stock card metadata + the filename.
   *
   * @return full URI to the location of the contract metadata.
   */
  function contractURI() public view returns (string memory) {
    return _contractMetadataUri;
  }

  /**
   * @dev Return list of tokenIds owned by `account`
   */
  function getTokenIds(address account)
    external
    view
    returns (uint256[] memory)
  {
    Owned storage list = _owned[account];
    uint256[] memory result = new uint256[](list.count);
    ListKey storage key = list.listKey;
    for (uint256 i = 0; i < list.count; ++i) {
      result[i] = key.index;
      key = _tokenInfos[key.index].listKey;
    }
    return result;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Minting interface
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Creates `amount` new tokens for `to`, of token type `tokenId`.
   *
   * See {ERC1155-_mint}.
   *
   * Requirements:
   *
   * - The caller must have the `MINTER_ROLE`.
   */
  function mint(
    address to,
    uint256 tokenId,
    uint256 amount,
    bytes memory data
  ) public virtual override {
    // Only tokenIds >= 64 Bit allowed
    require((tokenId >> 64) != 0, 'TokenId reserved');

    // Translate parameter
    address minter = _getAddress(data);
    require(minter != address(0), 'Invalid minter from user data');

    // Update state
    _onMint(minter, tokenId);

    // Call ancestor
    super.mint(to, tokenId, amount, data);
  }

  /**
   * @dev Batched variant of {mint}.
   */
  function mintBatch(
    address to,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override {
    // Translate parameter
    address minter = _getAddress(data);
    require(minter != address(0), 'Invalid minter in data');

    // Update state
    for (uint256 i = 0; i < tokenIds.length; i++) {
      // Only tokenIds >= 64 Bit allowed
      require((tokenIds[i] >> 64) != 0, 'TokenId reserved');
      _onMint(minter, tokenIds[i]);
    }

    // Call ancestor
    super.mintBatch(to, tokenIds, amounts, data);
  }

  //////////////////////////////////////////////////////////////////////////////
  // Implementation of {IERC1155}
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev See {IERC1155-safeTransferFrom}.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    uint256 amount,
    bytes calldata data
  ) public override {
    // Validate parameters
    require(from != address(0), "Can't transfer from zero address");
    require(to != address(0), "Can't transfer to zero address");

    // Look up minter
    address minter = _tokenIdToMinter[tokenId];
    require(minter != address(0), 'Invalid minter for token');

    // Call parent
    super.safeTransferFrom(from, to, tokenId, amount, data);

    if ((tokenId >> 64) == 0)
      _relinkOwner(from, to, uint64(tokenId));
      // Invoke callback
    else IMinterCallback(minter).onTransferFrom(from, to, tokenId, amount);
  }

  /**
   * @dev See {IERC1155-safeBatchTransferFrom}.
   */
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata tokenIds,
    uint256[] calldata amounts,
    bytes calldata data
  ) public override {
    // Validate parameters
    require(from != address(0), "Can't transfer from zero address");
    require(to != address(0), "Can't transfer to zero address");
    require(tokenIds.length == amounts.length, "Lengths don't match");

    // Call parent
    super.safeBatchTransferFrom(from, to, tokenIds, amounts, data);

    // Invoke callbacks
    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];
      if ((tokenId >> 64) == 0) {
        _relinkOwner(from, to, uint64(tokenId));
      } else {
        address minter = _tokenIdToMinter[tokenId];
        require(minter != address(0), 'Invalid minter for token');

        IMinterCallback(minter).onTransferFrom(from, to, tokenId, amounts[i]);
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  // Implementation of {ERC1155Burnable}
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev See {ERC1155Burnable-burn}.
   */
  function burn(
    address account,
    uint256 tokenId,
    uint256 value
  ) public virtual override {
    // Validate parameters
    require(account != address(0), 'Invalid zero address');

    // Call ancestor
    super.burn(account, tokenId, value);

    uint256[] memory tokenIds = new uint256[](1);
    uint256[] memory values = new uint256[](1);
    tokenIds[0] = tokenId;
    values[0] = value;

    _onBurn(account, tokenIds, values);
  }

  /**
   * @dev See {ERC1155Burnable-burnBatch}.
   */
  function burnBatch(
    address account,
    uint256[] memory tokenIds,
    uint256[] memory values
  ) public virtual override {
    // Validate parameters
    require(account != address(0), 'Invalid zero address');
    require(tokenIds.length == values.length, "Lengths don't match");

    // Call parent
    super.burnBatch(account, tokenIds, values);
    _onBurn(account, tokenIds, values);
  }

  //////////////////////////////////////////////////////////////////////////////
  // Implementation of {IERC1155MetadataURI}
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev See {IERC1155MetadataURI-uri}.
   *
   * Revert for unminted SFT NFTs
   */
  function uri(uint256 tokenId)
    public
    view
    virtual
    override(ERC1155)
    returns (string memory)
  {
    // Validate state
    require(
      (tokenId >> 64) > 0 || _tokenInfos[uint64(tokenId)].minted,
      'Token not minted'
    );

    // Calculate URI
    uint256 temp = tokenId;
    uint256 length = tokenId == 0 ? 1 : 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    bytes memory buffer = new bytes(2 * length);
    for (uint256 i = 2 * length; i > 0; --i) {
      buffer[i - 1] = HEX_MAP[tokenId & 0xf];
      tokenId >>= 4;
    }
    return string(abi.encodePacked(super.uri(0), buffer, '.json'));
  }

  //////////////////////////////////////////////////////////////////////////////
  // Rarible Fees and events
  //////////////////////////////////////////////////////////////////////////////

  function setFee(uint256 fee) external {
    // Validate access
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admin');

    // Update state
    _fee = fee;
  }

  function setFeeRecipient(address feeRecipient) external {
    // Validate access
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admin');

    // Update state
    _feeRecipient = feeRecipient;
  }

  function getFeeRecipients(uint256)
    public
    view
    returns (address payable[] memory)
  {
    // Return value
    address payable[] memory recipients = new address payable[](1);

    // Load state
    recipients[0] = payable(_feeRecipient);
    return recipients;
  }

  function getFeeBps(uint256) public view returns (uint256[] memory) {
    // Return value
    uint256[] memory bps = new uint256[](1);

    // Load state
    bps[0] = _fee;

    return bps;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Hooks
  //////////////////////////////////////////////////////////////////////////////

  function onERC1155Received(
    address,
    address from,
    uint256 tokenId,
    uint256 amount,
    bytes memory
  ) external returns (bytes4) {
    // Update state
    uint256[] memory tokenIds = new uint256[](1);
    tokenIds[0] = tokenId;
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = amount;
    _onTokensReceived(from, tokenIds, amounts);

    // This contract supports safe ERC-1155 transfers
    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address,
    address from,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory
  ) external returns (bytes4) {
    _onTokensReceived(from, tokenIds, amounts);

    // This contract supports safe ERC-1155 transfers
    return this.onERC1155BatchReceived.selector;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Administrative functions
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev See {ERC1155-_setURI}.
   */
  function setURI(string memory newUri) public {
    // Access control
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admin');

    // Call parent
    super._setURI(newUri);
  }

  /**
   * @dev Set contract metadata URI
   */
  function setContractURI(string memory newContractUri) public {
    // Access control
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admin');

    _contractMetadataUri = newContractUri;
  }

  /**
   * @dev Withdraw tokenAddress ERC20token to destination
   * tokenAddress cannot be rewardToken.
   * TODO: provide the possibility to swap into WOWS
   *
   * @param tokenAddress the address of the token to transfer
   */
  function collectGarbage(address tokenAddress) external {
    // Validate access
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admins');

    // Transfer token to msg.sender
    uint256 amountToken = IERC20(tokenAddress).balanceOf(address(this));
    if (amountToken > 0)
      IERC20(tokenAddress).transfer(_msgSender(), amountToken);
  }

  /**
   * remove before mainnet deploy
   */
  function testSelfDestroy() external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only admins');
    selfdestruct(_msgSender());
  }

  //////////////////////////////////////////////////////////////////////////////
  // Internal details
  //////////////////////////////////////////////////////////////////////////////

  function _onBurn(
    address account,
    uint256[] memory tokenIds,
    uint256[] memory amounts
  ) private {
    // Count tokenIds < 64 Bit
    uint256 numStakes = 0;

    // Invoke callbacks / count SFT's
    for (uint256 i = 0; i < tokenIds.length; i++) {
      uint256 tokenId = tokenIds[i];

      // Unstake SFT on burn
      if ((tokenId >> 64) == 0) {
        ++numStakes;
        _relinkOwner(account, address(0), uint64(tokenId));
      } else {
        address minter = _tokenIdToMinter[tokenId];
        require(minter != address(0), 'Token has no minter');

        IMinterCallback(minter).onBurn(account, tokenId, amounts[i]);
      }
    }

    // Unstake SFTs if required
    if (numStakes > 0) {
      uint256[] memory unstakeIds = new uint256[](numStakes);
      uint256[] memory unstakeAmounts = new uint256[](numStakes);

      for (uint256 i = 0; i < tokenIds.length; ++i) {
        uint256 tokenId = tokenIds[i];
        if ((tokenId >> 64) == 0) {
          unstakeIds[--numStakes] = tokenId;
          unstakeAmounts[numStakes] = 1;
        }
      }
      // Load address
      IERC1155 sftContract =
        IERC1155(_addressRegistry.getRegistryEntry(AddressBook.SFT_HOLDER));

      sftContract.safeBatchTransferFrom(
        address(this),
        _msgSender(),
        unstakeIds,
        unstakeAmounts,
        ''
      );
    }
  }

  /**
   * @dev Update the state of this contract when `minter` mints `tokenId`
   *
   * Reverts if the token has already been minted by a different minting
   * contract.
   *
   * @param minter The contract doing the minting
   * @param tokenId The token ID being minted
   */
  function _onMint(address minter, uint256 tokenId) private {
    bool tokenMinted = (_tokenIdToMinter[tokenId] != address(0));

    if (tokenMinted) {
      // Token has been minted before, require match
      require(
        _tokenIdToMinter[tokenId] == minter,
        'Token minted by different minter'
      );
    } else {
      // Token hasn't been minted before, record minter
      _tokenIdToMinter[tokenId] = minter;
    }
  }

  /**
   * @dev SFT Token arrived, provide a NFT
   */
  function _onTokensReceived(
    address from,
    uint256[] memory tokenIds,
    uint256[] memory amounts
  ) private {
    // We only support tokens from our SFT Holder contract
    require(
      _msgSender() == _addressRegistry.getRegistryEntry(AddressBook.SFT_HOLDER),
      'Invald sender'
    );

    // Validate parameters
    require(tokenIds.length == amounts.length, 'Lengths mismatch');

    // Update state
    for (uint256 i = 0; i < tokenIds.length; ++i) {
      uint256 tokenId = tokenIds[i];
      require((tokenId >> 64) == 0, 'Invalid TokenId');
      require(amounts[i] == 1, 'Amount != 0 not alowed');
      require(
        _tokenInfos[uint64(tokenId)].minted == false,
        'Token already minted'
      );
      _relinkOwner(address(0), from, uint64(tokenId));
      // OpenSea only listens to TransferSingle event on mint
      _mint(from, tokenId, 1, '');
      // Even the tokenId has not changed we fire URI to
      // let clients know that Metadata has to be refreshed
      emit URI(uri(tokenId), tokenId);
      // Rarible needs to be informed abiut fees
      emit SecondarySaleFees(tokenId, getFeeRecipients(0), getFeeBps(0));
    }
  }

  /**
   * @dev Ownership change -> update linked list owner -> tokenId
   *
   * linkKeys are 1 based where tokenIds are 0-based.
   */
  function _relinkOwner(
    address from,
    address to,
    uint64 tokenId
  ) internal {
    // Load state
    TokenInfo storage tokenInfo = _tokenInfos[tokenId];

    // Remove tokenId from List
    if (from != address(0)) {
      // Load state
      Owned storage fromList = _owned[from];

      // Validate state
      require(fromList.count > 0, 'Count mismatch');

      ListKey storage key = fromList.listKey;
      uint64 count = fromList.count;

      // Search the token which links to tokenId
      for (; count > 0 && key.index != tokenId; --count)
        key = _tokenInfos[key.index].listKey;
      require(key.index == tokenId, 'Key mismatch');

      // Unlink prev -> tokenId
      key.index = tokenInfo.listKey.index;
      // Unlink tokenId -> next
      tokenInfo.listKey.index = 0;
      // Decrement count
      fromList.count--;
    }

    // Update state
    if (to != address(0)) {
      Owned storage toList = _owned[to];
      tokenInfo.listKey.index = toList.listKey.index;
      toList.listKey.index = tokenId;
      toList.count++;
      _tokenInfos[uint64(tokenId)].minted = true;
    } else {
      _tokenInfos[uint64(tokenId)].minted = false;
    }
  }

  /**
   * @dev Get the address from the user data parameter
   *
   * @param data Per ERC-1155, the data parameter is additional data with no
   * specified format, and is sent unaltered in the call to
   * {IERC1155Receiver-onERC1155Received} on the receiver of the minted token.
   */
  function _getAddress(bytes memory data) public pure returns (address addr) {
    // solhint-disable-next-line no-inline-assembly
    assembly {
      addr := mload(add(data, 20))
    }
  }
}


/*
 * Copyright (C) 2020-2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 * *
 * This file is derived from OpenZeppelin, available under the MIT
 * license. https://openzeppelin.com/contracts/

 * : Apache-2.0 AND MIT
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

//import'@openzeppelin/contracts/access/AccessControl.sol';
//import'@openzeppelin/contracts/token/ERC1155/ERC1155Burnable.sol';
//import'@openzeppelin/contracts/token/ERC1155/ERC1155Pausable.sol';
//import'@openzeppelin/contracts/utils/Context.sol';

/**
 * @dev Partial implementation of https://eips.ethereum.org/EIPS/eip-1155[ERC1155]
 * Multi Token Standard
 *
 * This contract is a replacement for the file ERC1155PresetMinterPauser.sol
 * in the OpenZeppelin project.
 */
contract WOWSMinterPauser is
  Context,
  AccessControl,
  ERC1155Burnable,
  ERC1155Pausable
{
  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  // Role to pause token transfers
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

  // Role to mint new tokens
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  //////////////////////////////////////////////////////////////////////////////
  // Constructor
  //////////////////////////////////////////////////////////////////////////////

  constructor(string memory uri) ERC1155(uri) {}

  //////////////////////////////////////////////////////////////////////////////
  // Pausing interface
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Pauses all token transfers.
   *
   * See {ERC1155Pausable} and {Pausable-_pause}.
   *
   * Requirements:
   *
   * - The caller must have the `PAUSER_ROLE`.
   */
  function pause() public virtual {
    // Validate access
    require(hasRole(PAUSER_ROLE, _msgSender()), 'pauser role required');

    // Update state
    _pause();
  }

  /**
   * @dev Unpauses all token transfers.
   *
   * See {ERC1155Pausable} and {Pausable-_unpause}.
   *
   * Requirements:
   *
   * - The caller must have the `PAUSER_ROLE`.
   */
  function unpause() public virtual {
    // Validate access
    require(hasRole(PAUSER_ROLE, _msgSender()), 'pauser role required');

    // Update state
    _unpause();
  }

  //////////////////////////////////////////////////////////////////////////////
  // Minting interface
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Creates `amount` new tokens for `to`, of token type `tokenId`.
   *
   * See {ERC1155-_mint}.
   *
   * Requirements:
   *
   * - The caller must have the `MINTER_ROLE`.
   */
  function mint(
    address to,
    uint256 tokenId,
    uint256 amount,
    bytes memory data
  ) public virtual {
    // Validate access
    require(hasRole(MINTER_ROLE, _msgSender()), 'minter role required');

    // Validate parameters
    require(to != address(0), "Can't mint to zero address");

    // Update state
    _mint(to, tokenId, amount, data);
  }

  /**
   * @dev Batched variant of {mint}.
   */
  function mintBatch(
    address to,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual {
    // Validate access
    require(hasRole(MINTER_ROLE, _msgSender()), 'minter role required');

    // Validate parameters
    require(to != address(0), "Can't mint to zero address");
    require(tokenIds.length == amounts.length, "Lengths don't match");

    // Update state
    _mintBatch(to, tokenIds, amounts, data);
  }

  //////////////////////////////////////////////////////////////////////////////
  // Implementation of {ERC1155} via {ERC1155Pausable}
  //////////////////////////////////////////////////////////////////////////////

  /**
   * @dev See {ERC1155-_beforeTokenTransfer}.
   *
   * This function is necessary due to diamond inheritance.
   */
  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory tokenIds,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override(ERC1155, ERC1155Pausable) {
    // Call ancestor
    super._beforeTokenTransfer(operator, from, to, tokenIds, amounts, data);
  }
}


/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * : Apache-2.0
 * See LICENSE.txt for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

/**
 * @dev Interface to receive callbacks when minted tokens are burnt
 */
interface IMinterCallback {
  /**
   * @dev Called when a token minted by a minter is transferred
   *
   * @param from The account sending the token
   * @param to The account receiving the token
   * @param tokenId The ERC-1155 token ID
   * @param amount The amount of tokens transfered
   */
  function onTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    uint256 amount
  ) external;

  /**
   * @dev Called when a token minted by a minter is burned
   *
   * @param account The account owning the token
   * @param tokenId The ERC-1155 token ID
   * @param amount The amount of tokens burned
   */
  function onBurn(
    address account,
    uint256 tokenId,
    uint256 amount
  ) external;
}


/*
 * Copyright (C) 2020-2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * : Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

library AddressBook {
  bytes32 public constant TEAM_WALLET = 'TEAM_WALLET';
  bytes32 public constant MARKETING_WALLET = 'MARKETING_WALLET';
  bytes32 public constant UNISWAP_V2_ROUTER02 = 'UNISWAP_V2_ROUTER02';
  bytes32 public constant WETH_WOWS_STAKE_FARM = 'WETH_WOWS_STAKE_FARM';
  bytes32 public constant WOWS_TOKEN = 'WOWS_TOKEN';
  bytes32 public constant WOWS_BOOSTER = 'WOWS_BOOSTER';
  bytes32 public constant REWARD_HANDLER = 'REWARD_HANDLER';
  bytes32 public constant SFT_HOLDER = 'SFT_HOLDER';
}


/*
 * Copyright (C) 2021 The Wolfpack
 * This file is part of wolves.finance - https://github.com/wolvesofwallstreet/wolves.finance
 *
 * : Apache-2.0
 * See the file LICENSES/README.md for more information.
 */

pragma solidity >=0.7.0 <0.8.0;

interface IAddressRegistry {
  /**
   * @dev Set an abitrary key / address pair into the registry
   */
  function setRegistryEntry(bytes32 _key, address _location) external;

  /**
   * @dev Get an registry enty with by key, returns 0 address if not existing
   */
  function getRegistryEntry(bytes32 _key) external view returns (address);
}


// : MIT

pragma solidity >=0.6.0 <0.8.0;

//import"../utils/EnumerableSet.sol";
//import"../utils/Address.sol";
//import"../utils/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
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
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
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
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
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
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

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
    function renounceRole(bytes32 role, address account) public virtual {
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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


