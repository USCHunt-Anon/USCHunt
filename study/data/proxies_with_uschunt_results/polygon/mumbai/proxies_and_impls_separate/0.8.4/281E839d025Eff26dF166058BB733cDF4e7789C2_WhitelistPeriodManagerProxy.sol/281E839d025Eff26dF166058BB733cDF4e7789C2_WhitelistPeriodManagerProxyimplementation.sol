// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v4.3.0

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


// File @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol@v4.3.0

// : MIT

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


// File @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol@v4.3.0

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


// File @openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol@v4.3.0

// : MIT

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


// File @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol@v4.3.0

// : MIT

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


// File contracts/security/Pausable.sol

// : MIT

pragma solidity 0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Initializable, PausableUpgradeable {
    
    address private _pauser;
    
    event PauserChanged(
        address indexed previousPauser,
        address indexed newPauser
    );

    /**
     * @dev The pausable constructor sets the original `pauser` of the contract to the sender
     * account & Initializes the contract in unpaused state..
     */
    function __Pausable_init(address pauser) internal initializer {
        require(pauser != address(0), "Pauser Address cannot be 0");
        __Pausable_init();
        _pauser = pauser;
    }
    
    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isPauser(address pauser) public view returns (bool) {
        return pauser == _pauser;
    }
    
    /**
     * @dev Throws if called by any account other than the pauser.
     */
    modifier onlyPauser() {
        require(
            isPauser(msg.sender),
            "Only pauser is allowed to perform this operation"
        );
        _;
    }

    /**
     * @dev Allows the current pauser to transfer control of the contract to a newPauser.
     * @param newPauser The address to transfer pauserShip to.
     */
    function changePauser(address newPauser) public onlyPauser {
        _changePauser(newPauser);
    }

    /**
     * @dev Transfers control of the contract to a newPauser.
     * @param newPauser The address to transfer ownership to.
     */
    function _changePauser(address newPauser) internal {
        require(newPauser != address(0));
        emit PauserChanged(_pauser, newPauser);
        _pauser = newPauser;
    }

    function renouncePauser() external virtual onlyPauser {
        emit PauserChanged(_pauser, address(0));
        _pauser = address(0);
    }
}


// File contracts/hyphen/metatx/ERC2771ContextUpgradeable.sol

// : MIT

pragma solidity ^0.8.0;


/**
 * @dev Context variant with ERC2771 support. 
 * Here _trustedForwarder is made internal instead of private
 * so it can be changed via Child contracts with a setter method.
 */
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    address internal _trustedForwarder;

    function __ERC2771Context_init(address trustedForwarder) internal initializer {
        __Context_init_unchained();
        __ERC2771Context_init_unchained(trustedForwarder);
    }

    function __ERC2771Context_init_unchained(address trustedForwarder) internal initializer {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
    uint256[49] private __gap;
}


// File contracts/hyphen/interfaces/ILiquidityProviders.sol

// : MIT
pragma solidity ^0.8.0;

interface ILiquidityProviders {
    function initialize(address _trustedForwarder, address _lpToken) external;

    function addLPFee(address _token, uint256 _amount) external;

    function addNativeLiquidity() external;

    function addTokenLiquidity(address _token, uint256 _amount) external;

    function claimFee(uint256 _nftId) external;

    function getFeeAccumulatedOnNft(uint256 _nftId) external view returns (uint256);

    function getSuppliedLiquidityByToken(address tokenAddress) external view returns (uint256);

    function getTokenPriceInLPShares(address _baseToken) external view returns (uint256);

    function getTotalLPFeeByToken(address tokenAddress) external view returns (uint256);

    function getTotalReserveByToken(address tokenAddress) external view returns (uint256);

    function getSuppliedLiquidity(uint256 _nftId) external view returns (uint256);

    function increaseNativeLiquidity(uint256 _nftId) external;

    function increaseTokenLiquidity(uint256 _nftId, uint256 _amount) external;

    function isTrustedForwarder(address forwarder) external view returns (bool);

    function owner() external view returns (address);

    function paused() external view returns (bool);

    function removeLiquidity(uint256 _nftId, uint256 amount) external;

    function renounceOwnership() external;

    function setLiquidityPool(address _liquidityPool) external;

    function setLpToken(address _lpToken) external;

    function setWhiteListPeriodManager(address _whiteListPeriodManager) external;

    function sharesToTokenAmount(uint256 _shares, address _tokenAddress) external view returns (uint256);

    function totalLPFees(address) external view returns (uint256);

    function totalLiquidity(address) external view returns (uint256);

    function totalReserve(address) external view returns (uint256);

    function totalSharesMinted(address) external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function whiteListPeriodManager() external view returns (address);
}


// File contracts/hyphen/interfaces/ITokenManager.sol

// : MIT
pragma solidity ^0.8.0;

interface ITokenManager {

    struct TokenInfo {
        uint256 transferOverhead;
        bool supportedToken;
        uint256 minCap;
        uint256 maxCap;
        uint256 equilibriumFee; // Percentage fee Represented in basis points
        uint256 maxFee; // Percentage fee Represented in basis points
    }
    
    function getEquilibriumFee(address tokenAddress) external view returns (uint256);

    function getMaxFee(address tokenAddress) external view returns (uint256);

    function changeFee(
        address tokenAddress,
        uint256 _equilibriumFee,
        uint256 _maxFee
    ) external;

    function getTokensInfo(address tokenAddress) external view returns (TokenInfo memory);
}


// File contracts/hyphen/structures/LpTokenMetadata.sol

// : MIT
pragma solidity ^0.8.0;

struct LpTokenMetadata {
    address token;
    uint256 suppliedLiquidity;
    uint256 shares;
}


// File contracts/hyphen/interfaces/ILPToken.sol

// : MIT
pragma solidity ^0.8.0;

interface ILPToken {
    function approve(address to, uint256 tokenId) external;

    function balanceOf(address _owner) external view returns (uint256);

    function exists(uint256 _tokenId) external view returns (bool);

    function getAllNftIdsByUser(address _owner) external view returns (uint256[] memory);

    function getApproved(uint256 tokenId) external view returns (address);

    function initialize(
        string memory _name,
        string memory _symbol,
        address _trustedForwarder
    ) external;

    function isApprovedForAll(address _owner, address operator) external view returns (bool);

    function isTrustedForwarder(address forwarder) external view returns (bool);

    function liquidityPoolAddress() external view returns (address);

    function mint(address _to) external returns (uint256);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function paused() external view returns (bool);

    function renounceOwnership() external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setLiquidtyPool(address _lpm) external;

    function setWhiteListPeriodManager(address _whiteListPeriodManager) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenMetadata(uint256)
        external
        view
        returns (
            address token,
            uint256 totalSuppliedLiquidity,
            uint256 totalShares
        );

    function tokenOfOwnerByIndex(address _owner, uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferOwnership(address newOwner) external;

    function updateLiquidityPoolAddress(address _liquidityPoolAddress) external;

    function updateTokenMetadata(uint256 _tokenId, LpTokenMetadata memory _lpTokenMetadata) external;

    function whiteListPeriodManager() external view returns (address);
}


// File contracts/hyphen/WhitelistPeriodManager.sol

// : MIT
pragma solidity ^0.8.0;








contract WhitelistPeriodManager is Initializable, OwnableUpgradeable, Pausable, ERC2771ContextUpgradeable {
    ILiquidityProviders private liquidityProviders;
    ITokenManager private tokenManager;
    ILPToken private lpToken;
    bool public areWhiteListRestrictionsEnabled;

    /* LP Status */
    // EOA? -> status, stores addresses that we want to ignore, like staking contracts.
    mapping(address => bool) public isExcludedAddress;
    // Token -> TVL
    mapping(address => uint256) private totalLiquidity;
    // Token -> TVL
    mapping(address => mapping(address => uint256)) private totalLiquidityByLp;

    /* Caps */
    // Token Address -> Limit
    mapping(address => uint256) public perTokenTotalCap;
    // Token Address -> Limit
    mapping(address => uint256) public perTokenWalletCap;

    event ExcludedAddressStatusUpdated(address indexed lp, bool indexed status);
    event TotalCapUpdated(address indexed token, uint256 totalCap);
    event PerTokenWalletCap(address indexed token, uint256 perCommunityWalletCap);
    event WhiteListStatusUpdated(bool status);

    modifier onlyLiquidityPool() {
        require(_msgSender() == address(liquidityProviders), "ERR__UNAUTHORIZED");
        _;
    }

    modifier onlyLpNft() {
        require(_msgSender() == address(lpToken), "ERR__UNAUTHORIZED");
        _;
    }

    modifier tokenChecks(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be 0");
        require(_isSupportedToken(tokenAddress), "Token not supported");
        _;
    }

    /**
     * @dev initalizes the contract, acts as constructor
     * @param _trustedForwarder address of trusted forwarder
     */
    function initialize(
        address _trustedForwarder,
        address _liquidityProviders,
        address _tokenManager,
        address _lpToken,
        address _pauser
    ) public initializer {
        __ERC2771Context_init(_trustedForwarder);
        __Ownable_init();
        __Pausable_init(_pauser);
        areWhiteListRestrictionsEnabled = true;
        _setLiquidityProviders(_liquidityProviders);
        _setTokenManager(_tokenManager);
        _setLpToken(_lpToken);
    }

    function _isSupportedToken(address _token) internal view returns (bool) {
        return tokenManager.getTokensInfo(_token).supportedToken;
    }

    /**
     * @dev Internal Function which checks for various caps before allowing LP to add liqudity
     */
    function _beforeLiquidityAddition(
        address _lp,
        address _token,
        uint256 _amount
    ) internal {
        if (isExcludedAddress[_lp]) {
            return;
        }
        // Per Token Total Cap or PTTC
        require(ifEnabled(totalLiquidity[_token] + _amount <= perTokenTotalCap[_token]), "ERR__LIQUIDITY_EXCEEDS_PTTC");
        require(
            ifEnabled(totalLiquidityByLp[_token][_lp] + _amount <= perTokenWalletCap[_token]),
            "ERR__LIQUIDITY_EXCEEDS_PTWC"
        );
        totalLiquidity[_token] += _amount;
        totalLiquidityByLp[_token][_lp] += _amount;
    }

    /**
     * @dev External Function which checks for various caps before allowing LP to add liqudity. Only callable by LiquidityPoolManager
     */
    function beforeLiquidityAddition(
        address _lp,
        address _token,
        uint256 _amount
    ) external onlyLiquidityPool whenNotPaused {
        _beforeLiquidityAddition(_lp, _token, _amount);
    }

    /**
     * @dev Internal Function which checks for various caps before allowing LP to remove liqudity
     */
    function _beforeLiquidityRemoval(
        address _lp,
        address _token,
        uint256 _amount
    ) internal {
        if (isExcludedAddress[_lp]) {
            return;
        }
        totalLiquidityByLp[_token][_lp] -= _amount;
        totalLiquidity[_token] -= _amount;
    }

    /**
     * @dev External Function which checks for various caps before allowing LP to remove liqudity. Only callable by LiquidityPoolManager
     */
    function beforeLiquidityRemoval(
        address _lp,
        address _token,
        uint256 _amount
    ) external onlyLiquidityPool whenNotPaused {
        _beforeLiquidityRemoval(_lp, _token, _amount);
    }

    /**
     * @dev External Function which checks for various caps before allowing LP to transfer their LpNFT. Only callable by LpNFT contract
     */
    function beforeLiquidityTransfer(
        address _from,
        address _to,
        address _token,
        uint256 _amount
    ) external onlyLpNft whenNotPaused {
        // Release limit from  _from
        _beforeLiquidityRemoval(_from, _token, _amount);

        // Block limit of _to
        _beforeLiquidityAddition(_to, _token, _amount);
    }

    function _setTokenManager(address _tokenManager) internal {
        tokenManager = ITokenManager(_tokenManager);
    }

    function setTokenManager(address _tokenManager) external onlyOwner {
        _setTokenManager(_tokenManager);
    }

    function _setLiquidityProviders(address _liquidityProviders) internal {
        liquidityProviders = ILiquidityProviders(_liquidityProviders);
    }

    function setLiquidityProviders(address _liquidityProviders) external onlyOwner {
        _setLiquidityProviders(_liquidityProviders);
    }

    function _setLpToken(address _lpToken) internal {
        lpToken = ILPToken(_lpToken);
    }

    function setLpToken(address _lpToken) external onlyOwner {
        _setLpToken(_lpToken);
    }

    function setIsExcludedAddressStatus(address[] memory _addresses, bool[] memory _status) external onlyOwner {
        require(_addresses.length == _status.length, "ERR__LENGTH_MISMATCH");
        for (uint256 i = 0; i < _addresses.length; ++i) {
            isExcludedAddress[_addresses[i]] = _status[i];
            emit ExcludedAddressStatusUpdated(_addresses[i], _status[i]);
        }
    }

    function setTotalCap(address _token, uint256 _totalCap) public tokenChecks(_token) onlyOwner {
        require(totalLiquidity[_token] <= _totalCap, "ERR__TOTAL_CAP_LESS_THAN_SL");
        require(_totalCap >= perTokenWalletCap[_token], "ERR__TOTAL_CAP_LT_PTWC");
        if (perTokenTotalCap[_token] != _totalCap) {
            perTokenTotalCap[_token] = _totalCap;
            emit TotalCapUpdated(_token, _totalCap);
        }
    }

    /**
     * @dev Special care must be taken when calling this function
     *      There are no checks for _perTokenWalletCap (since it's onlyOwner), but it's essential that it
     *      should be >= max lp provided by an lp.
     *      Checking this on chain will probably require implementing a bbst, which needs more bandwidth
     *      Call the view function getMaxCommunityLpPositon() separately before changing this value
     */
    function setPerTokenWalletCap(address _token, uint256 _perTokenWalletCap) public tokenChecks(_token) onlyOwner {
        require(_perTokenWalletCap <= perTokenTotalCap[_token], "ERR__PWC_GT_PTTC");
        if (perTokenWalletCap[_token] != _perTokenWalletCap) {
            perTokenWalletCap[_token] = _perTokenWalletCap;
            emit PerTokenWalletCap(_token, _perTokenWalletCap);
        }
    }

    function setCap(
        address _token,
        uint256 _totalCap,
        uint256 _perTokenWalletCap
    ) public onlyOwner {
        setTotalCap(_token, _totalCap);
        setPerTokenWalletCap(_token, _perTokenWalletCap);
    }

    function setCaps(
        address[] memory _tokens,
        uint256[] memory _totalCaps,
        uint256[] memory _perTokenWalletCaps
    ) external onlyOwner {
        require(
            _tokens.length == _totalCaps.length && _totalCaps.length == _perTokenWalletCaps.length,
            "ERR__LENGTH_MISMACH"
        );
        for (uint256 i = 0; i < _tokens.length; ++i) {
            setCap(_tokens[i], _totalCaps[i], _perTokenWalletCaps[i]);
        }
    }

    /**
     * @dev Enables (or disables) reverts if liquidity exceeds caps.
     *      Even if this is disabled, the contract will continue to track LP's positions
     */
    function setAreWhiteListRestrictionsEnabled(bool _status) external onlyOwner {
        areWhiteListRestrictionsEnabled = _status;
        emit WhiteListStatusUpdated(_status);
    }

    /**
     * @dev Returns the maximum amount a single community LP has provided
     */
    function getMaxCommunityLpPositon(address _token) external view returns (uint256) {
        uint256 totalSupply = lpToken.totalSupply();
        uint256 maxLp = 0;
        for (uint256 i = 1; i <= totalSupply; ++i) {
            uint256 liquidity = totalLiquidityByLp[_token][lpToken.ownerOf(i)];
            if (liquidity > maxLp) {
                maxLp = liquidity;
            }
        }
        return maxLp;
    }

    /**
     * @dev returns the value of if (areWhiteListEnabled) then (_cond)
     */
    function ifEnabled(bool _cond) private view returns (bool) {
        return !areWhiteListRestrictionsEnabled || (areWhiteListRestrictionsEnabled && _cond);
    }

    /**
     * @dev Meta-Transaction Helper, returns msgSender
     */
    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev Meta-Transaction Helper, returns msgData
     */
    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}