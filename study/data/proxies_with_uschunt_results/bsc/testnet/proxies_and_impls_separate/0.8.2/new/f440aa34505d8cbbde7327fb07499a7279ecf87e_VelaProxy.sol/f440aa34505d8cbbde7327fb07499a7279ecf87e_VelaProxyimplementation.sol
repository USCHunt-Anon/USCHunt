// : MIT


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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

// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
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
    uint256[49] private __gap;
}

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


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
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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

    function authorOf(uint256 tokenId) external view  returns (address author);

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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


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


pragma solidity ^0.8.0;

contract VelaMarketplace is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;
    event AdminWalletUpdated(address wallet);
    event VelaNFTContractUpdated(address erc721);

    event Erc20WhitelistUpdated(address[] erc20s, uint256 serviceFee, bool status);
    event Erc721WhitelistUpdated(address[] erc721s, bool status);
    event ServiceFeePercentUpdated(uint256 percent);
    event AuthorLicensePercentUpdated(uint256 percent);
    event AuthorFeePercentUpdated(uint256 percent);
    
    event TokenSold(address erc721, address erc20, address buyer, address seller, uint256 price, uint256 tokenId);
    event Payout(address erc721, address erc20, uint256 tokenId, uint256 serviceFeePayment, uint256 sellerPayment);

    event Listed(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);
    event PriceChanged(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);
    event ListingCanceled(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);
    
    
    event AuctionListed(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);
    event AuctionPriceChanged(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);
    event AuctionListingCanceled(address erc721, address erc20, address seller, uint256 price, uint256 tokenId);

    event BidCreated(address erc721, address erc20, address bidder, uint256 price, uint256 tokenId);
    event BidAccepted(address erc721, address erc20, address bidder, address seller, uint256 price, uint256 tokenId);
    event BidCanceled(address erc721, address erc20, address bidder, uint256 price, uint256 tokenId);

    uint256 constant public ONE_HUNDRED_PERCENT = 10000; // 100%
    
    uint256 public serviceFeePercent;
    uint256 public authorFeePercent;
    uint256 public authorLicensePercent;
    address public adminWallet; // address receive system fee
    address public velaNFTContract;

    struct NftInfo {
        address erc20;
        address seller;
        uint256 price;
        bool auction;
        uint256 beginAuction;
        uint256 endAuction;
    }

    mapping(address => mapping(uint256 => NftInfo)) public nfts; // erc721 address => token id => sell order

    struct Bid {
        address erc20;
        address bidder;
        uint256 price;
    }

    mapping(address => mapping(uint256 => bool)) public authorSell; // erc20 address => status
    mapping(address => mapping(uint256 => Bid)) public bids; // erc721 address => token id => bid id => bid order
    mapping(address => bool) public erc20Whitelist; // erc20 address => status
    mapping(address => bool) public erc721Whitelist; // erc721 address => status
    mapping(address => uint256) public erc20ServiceFee; // erc721 address => service fee

    modifier inWhitelist(address erc721, address erc20) {
        require(erc721Whitelist[erc721] && erc20Whitelist[erc20], "Vela Marketplace: erc721 and erc20 must be in whitelist");
        _;
    }

    function initialize()  public  initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        serviceFeePercent = 250; // 2.5%
        authorFeePercent = 2000; // 20%
        authorLicensePercent = 100; // 1%
        adminWallet = _msgSender();
        velaNFTContract = address(0);
    }

    function listingPrice(address erc721, address erc20, uint256 tokenId, uint256 price) public whenNotPaused nonReentrant inWhitelist(erc721, erc20){
        address msgSender = _msgSender();
        require(price > 0, "Vela Marketplace: price must be greater than 0");
        NftInfo memory info = nfts[erc721][tokenId];
        if (info.seller == address(0)) {
            IERC721(erc721).transferFrom(msgSender, address(this), tokenId);
            emit Listed(erc721, erc20, msgSender, price, tokenId);    
        } else {
            require(info.auction == false, "Vela Marketplace: can not change the auction item");
            require(info.seller == msgSender, "Vela Marketplace: can not change sale if sender has not made one");
            emit PriceChanged(erc721, erc20, msgSender, price, tokenId);
        }
        nfts[erc721][tokenId] = NftInfo(erc20, msgSender, price, false, 0, 0);
    }

    function buy(address erc721, uint256 tokenId) public payable whenNotPaused nonReentrant {
        address msgSender = _msgSender();
        NftInfo memory info = nfts[erc721][tokenId];
        require(info.auction == false, "Vela Marketplace: can not buy the auction item");
        require(info.price > 0, "Vela Marketplace: token is not for sale");
        require(info.seller != msgSender, "Vela Marketplace: can not buy");
        require(erc721Whitelist[erc721], "Vela Marketplace: erc721 must be in whitelist");
        if (info.erc20 == address(0)) {
            require(msg.value == info.price, "Vela Marketplace: deposit amount is not enough");
        } else {
            require(erc20Whitelist[info.erc20], "Vela Marketplace: erc20 must be in whitelist");
            IERC20(info.erc20).safeTransferFrom(msgSender, address(this), info.price);
        }
        IERC721(erc721).transferFrom(address(this), msgSender, tokenId);
        _payout(erc721, info.erc20, tokenId, info.price, info.seller);
        emit TokenSold(erc721, info.erc20, msgSender, info.seller, info.price, tokenId);
        delete nfts[erc721][tokenId];
    }

    function cancelListing(address erc721, uint256 tokenId) public whenNotPaused nonReentrant{
        address msgSender = _msgSender();
        NftInfo memory info = nfts[erc721][tokenId];
        require(erc721Whitelist[erc721], "Vela Marketplace: erc721 must be in whitelist");
        if (info.erc20 != address(0)) {
            require(erc20Whitelist[info.erc20], "Vela Marketplace: erc20 must be in whitelist");
        }
        require(info.auction == false, "Vela Marketplace: can not to cancel listing the auction item");
        require(info.seller == msgSender, "Vela Marketplace: can not to cancel listing if sender has not made one");
        IERC721(erc721).transferFrom(address(this), msgSender, tokenId);
        emit ListingCanceled(erc721, info.erc20, msgSender, info.price, tokenId);
        delete nfts[erc721][tokenId];
    }

    function auctionListingPrice(address erc721, address erc20, uint256 tokenId, uint256 price, uint256 beginAuction, uint256 endAuction) public whenNotPaused nonReentrant inWhitelist(erc721, erc20){
        address msgSender = _msgSender();
        require(price > 0, "Vela Marketplace: price must be greater than 0");
        require(beginAuction > 0, "Vela Marketplace: beginAuction must be greater than 0");
        require(endAuction > 0, "Vela Marketplace: endAuction must be greater than 0");
        require(endAuction > beginAuction, "Vela Marketplace: endAuction must be greater than beginAuction");
        NftInfo memory info = nfts[erc721][tokenId];
        if (info.seller == address(0)) {
            IERC721(erc721).transferFrom(msgSender, address(this), tokenId);
            emit AuctionListed(erc721, erc20, msgSender, price, tokenId);    
        } else {
            require(info.auction == true, "Vela Marketplace: can not change the not auction item");
            require(info.seller == msgSender, "Vela Marketplace: can not change sale if sender has not made one");
            emit AuctionPriceChanged(erc721, erc20, msgSender, price, tokenId);
        }

        nfts[erc721][tokenId] = NftInfo(erc20, msgSender, price, true, beginAuction, endAuction);
    }

    function bid(address erc721, uint256 tokenId, uint256 price) public payable whenNotPaused nonReentrant {
        require(price > 0, "Vela Marketplace: price must be greater than 0");
        address msgSender = _msgSender();
        address nftOwner = IERC721(erc721).ownerOf(tokenId);
        NftInfo memory info = nfts[erc721][tokenId];
        Bid memory oldBid = bids[erc721][tokenId];
        require(erc721Whitelist[erc721], "Vela Marketplace: erc721 must be in whitelist");
        if (info.erc20 != address(0)) {
            require(erc20Whitelist[info.erc20], "Vela Marketplace: erc20 must be in whitelist");
        }
        require(info.price <= price, "Vela Marketplace: do not allow new bid price lower than open bid price");
        require(oldBid.price < price, "Vela Marketplace: don not allow new bid price lower than current bid price");
        require(info.auction == true, "Vela Marketplace: can not bid the not auction item");
        require(block.timestamp > info.beginAuction && block.timestamp < info.endAuction, "Marketplace: the auction out of date");
        require(info.seller != msgSender && nftOwner != msgSender, "Marketplace: can not bid");
        if (info.erc20 == address(0)) {
            require(msg.value == price, "Vela Marketplace: deposit amount is not enough");
        } else {
            IERC20(info.erc20).safeTransferFrom(msgSender, address(this), price);
        }
        
        
        emit BidCreated(erc721, info.erc20, msgSender, price, tokenId);
        if (oldBid.bidder != address(0)) {
            _cancelBid(erc721, tokenId);
        }

        bids[erc721][tokenId] = Bid(info.erc20, msgSender, price);
    }

    function acceptBid(address erc721, uint256 tokenId) public whenNotPaused nonReentrant {
        address msgSender = _msgSender();
        Bid memory bidInfo = bids[erc721][tokenId];
        NftInfo memory nftInfo = nfts[erc721][tokenId];
        require(erc721Whitelist[erc721], "Vela Marketplace: erc721 must be in whitelist");
        if (nftInfo.erc20 != address(0)) {
            require(erc20Whitelist[nftInfo.erc20], "Vela Marketplace: erc20 must be in whitelist");
        }
        require(bidInfo.bidder != address(0), "Vela Marketplace: can not accept a bid when there is none");
        address nftOwner = IERC721(erc721).ownerOf(tokenId);
        
        require(nftInfo.auction == true, "Vela Marketplace: can not accept bid the not auction item");
        require(bidInfo.bidder != address(0), "Vela Marketplace: there is not bid");
        require(nftInfo.seller == msgSender || nftOwner == msgSender, "Vela Marketplace: sender is not token owner");
        if (nftOwner == address(this)) {
            IERC721(erc721).transferFrom(address(this), bidInfo.bidder, tokenId);
        } else {
            IERC721(erc721).transferFrom(msgSender, bidInfo.bidder, tokenId);
        }
        _payout(erc721, bidInfo.erc20, tokenId, bidInfo.price, msgSender);
        emit BidAccepted(erc721, bidInfo.erc20, bidInfo.bidder, msgSender, bidInfo.price, tokenId);

        delete nfts[erc721][tokenId];
        delete bids[erc721][tokenId];

    }

    function cancelAuctionListing(address erc721, uint256 tokenId) public whenNotPaused nonReentrant{
        address msgSender = _msgSender();
        NftInfo memory info = nfts[erc721][tokenId];
        require(erc721Whitelist[erc721], "Vela Marketplace: erc721 must be in whitelist");
        if (info.erc20 != address(0)) {
            require(erc20Whitelist[info.erc20], "Vela Marketplace: erc20 must be in whitelist");
        }

        require(info.auction == true, "Vela Marketplace: can not to cancel listing the not auction item");
        require(info.seller == msgSender, "Vela Marketplace: can not to cancel listing if sender has not made one");
        IERC721(erc721).transferFrom(address(this), msgSender, tokenId);

        _cancelBid(erc721, tokenId);        
        emit AuctionListingCanceled(erc721, info.erc20, msgSender, info.price, tokenId);

        delete nfts[erc721][tokenId];
        delete bids[erc721][tokenId];
    }

    function _cancelBid(address erc721, uint256 tokenId) internal {
        Bid memory oldBid = bids[erc721][tokenId];
        if (oldBid.erc20 == address(0)) {
            payable(oldBid.bidder).transfer(oldBid.price);
        } else {
            IERC20(oldBid.erc20).safeTransfer(oldBid.bidder, oldBid.price);
        }
        emit BidCanceled(erc721, oldBid.erc20, oldBid.bidder, oldBid.price, tokenId);
    }

    function updateErc20Whitelist(address[] memory erc20s, uint256 serviceFee, bool status) public onlyOwner {
        uint256 length = erc20s.length;
        require(length > 0, "Vela Marketplace: erc20 list is required");
        for (uint256 i = 0; i < length; i++) {
            erc20Whitelist[erc20s[i]] = status;
            erc20ServiceFee[erc20s[i]] = serviceFee;
        }
        emit Erc20WhitelistUpdated(erc20s, serviceFee, status);
    }

    function updateErc721Whitelist(address[] memory erc721s, bool status) public onlyOwner {
        uint256 length = erc721s.length;
        require(length > 0, "Vela Marketplace: erc721 list is required");
        for (uint256 i = 0; i < length; i++) {
            erc721Whitelist[erc721s[i]] = status;
        }
        emit Erc721WhitelistUpdated(erc721s, status);
    }

    function setAuthorLicensePercent(uint256 percent) public onlyOwner{
        require(percent <= ONE_HUNDRED_PERCENT, "Marketplace: percent is invalid");
        authorLicensePercent = percent;
        emit AuthorLicensePercentUpdated(percent);
    }

    function setAuthorFeePercent(uint256 percent) public onlyOwner{
        require(percent <= ONE_HUNDRED_PERCENT, "Marketplace: percent is invalid");
        authorFeePercent = percent;
        emit AuthorFeePercentUpdated(percent);
    }

    function setServiceFeePercent(uint256 percent) public onlyOwner{
        require(percent <= ONE_HUNDRED_PERCENT, "Marketplace: percent is invalid");
        serviceFeePercent = percent;
        emit ServiceFeePercentUpdated(percent);
    }

    function setVelaNFTContract(address erc721) public onlyOwner {
        require(erc721 != address(0), "Vela Marketplace: address is invalid");
        velaNFTContract = erc721;

        emit VelaNFTContractUpdated(velaNFTContract);
    }

    function setAdminWallet(address wallet) public onlyOwner {
        require(wallet != address(0), "Marketplace: address is invalid");
        adminWallet = wallet;
        emit AdminWalletUpdated(wallet);
    }


    function pause() public onlyOwner{
        _pause();
    }

    function unpause() public onlyOwner{
        _unpause();
    }

    function _payout(address erc721, address erc20, uint256 tokenId, uint256 price, address seller) internal{
        uint256 _serviceFeePercent = serviceFeePercent;
        if (erc20ServiceFee[erc20] > 0){
            _serviceFeePercent = erc20ServiceFee[erc20];
        }
        if (erc721 == velaNFTContract && authorSell[erc721][tokenId] == false){
            _serviceFeePercent = authorFeePercent;
        }

        uint256 serviceFeePayment = _calculateServiceFee(price, _serviceFeePercent);
        uint256 sellerPayment = price - serviceFeePayment;

        uint256 authorLicensePayment = 0;
        address author;
        if (erc721 == velaNFTContract && authorSell[erc721][tokenId] == true){
            authorLicensePayment = _calculateServiceFee(price, authorLicensePercent);
            sellerPayment = sellerPayment - authorLicensePayment;
            author = IERC721(erc721).authorOf(tokenId);
        }
        
        if (erc20 == address(0)) {
            if (serviceFeePayment > 0) {
                payable(adminWallet).transfer(serviceFeePayment);
            }
            if (sellerPayment > 0) {
                payable(seller).transfer(sellerPayment);
            }
            if (erc721 == velaNFTContract  && authorSell[erc721][tokenId] == true){
                payable(author).transfer(authorLicensePayment);
            }
        } else {
            if (serviceFeePayment > 0) {
                IERC20(erc20).safeTransfer(adminWallet, serviceFeePayment);
            }
            if (sellerPayment > 0) {
                IERC20(erc20).safeTransfer(seller, sellerPayment);
            }
            if (erc721 == velaNFTContract  && authorSell[erc721][tokenId] == true){
                IERC20(erc20).safeTransfer(author, authorLicensePayment);
            }
        }

        if (authorSell[erc721][tokenId] == false){
            authorSell[erc721][tokenId] = true;
        }

        emit Payout(erc721, erc20, tokenId, serviceFeePayment, sellerPayment);
    }

    function _calculateServiceFee(uint256 price, uint256 feePercent) internal pure returns (uint256){
        return price * feePercent / ONE_HUNDRED_PERCENT;
    }
    
}