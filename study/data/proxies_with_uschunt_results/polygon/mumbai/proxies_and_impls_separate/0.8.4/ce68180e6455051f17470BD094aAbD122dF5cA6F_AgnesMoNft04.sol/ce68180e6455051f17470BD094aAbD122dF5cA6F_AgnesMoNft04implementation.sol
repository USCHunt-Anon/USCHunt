// : MIT
pragma solidity ^0.8.0;

//import"./ERC1155OpenseaUpgradeable.sol";

/*
*   >_ Unzyp Technology, Inc.
*/

contract ERC1155YUpgradeable is ERC1155OpenseaUpgradeable {
    using StringsUpgradeable for uint256;

    uint256 public maxSupply;
    uint256 public perWalletLimit;
    uint256 public tokenPrice;
    uint256 public tokenPointer;

    bool public isTransferPaused;
    bool public isSalePaused;
    bool public isSingleToken;

    string private name_;
    string private symbol_;

    mapping(uint256 => uint256) private maxSupplyTokens;
    mapping(uint256 => uint256) private maxLimitTokens;
    mapping(uint256 => uint256) private priceTokens;
    mapping(address => uint256) private maxAddressMint;

    event TokensMinted(address mintedBy, uint256 tokenId, uint256 tokensNumber);
    event TokensBatchMinted(address mintedBy, uint256[] tokenIds, uint256[] tokensNumber);

    modifier salesInactive() {
        require(saleIsActive(), "Cannot be changed while sale is active");
        _;
    }

    modifier multiToken() {
        require(tokenIsMulti(), "Only for multi token type");
        _;
    }

    modifier singleToken() {
        require(tokenIsSingle(), "Only for single token type");
        _;
    }

    function __ERC1155Y_init(
        string memory _name,
        string memory _symbol,
        bool _singleToken,
        uint256 _maxSupplyPerToken,
        uint256 _maxMintPerWallet,
        uint256 _tokenPrice,
        bool _creatorProject,
        address _platformAddress,
        uint256 _platformRoyalty,
        address _creatorAddress,
        uint256 _creatorRoyalty
    ) internal onlyInitializing {
        __ERC1155Opensea_init();
        __ERC1155_init("");

        name_ = _name;
        symbol_ = _symbol;
        isSingleToken = _singleToken;
        maxSupply = _maxSupplyPerToken;
        perWalletLimit = _maxMintPerWallet;
        tokenPrice = _tokenPrice;
        tokenPointer = 0;
        isSingleToken = false;

        require(_tokenPrice >= minTokenPrice, string(abi.encodePacked("Token price at least must be ", StringsUpgradeable.toString(minTokenPrice), " wei (MATIC)")));

        if(_creatorProject) {
            require(_platformAddress != address(0), "Platform address cannot be NullAddress");
            require(_creatorAddress != address(0), "Creator address cannot be NullAddress");
            require(_platformRoyalty >= minPlatformRoyalty, string(abi.encodePacked("Platform royalty must be equal or bigger than ", StringsUpgradeable.toString(minPlatformRoyalty))));
            require((_platformRoyalty + _creatorRoyalty) == 10000, "Addition of platform and creator royalty must be 10000");

            platformAddress = _platformAddress;
            platformRoyalty = _platformRoyalty;
            creatorAddresses = _creatorAddress;
            creatorRoyalty = _creatorRoyalty;
        }

        // Set creator as owner
        devAddress = 0x98b987e320B1801e1a9d7510f63F697eF37A54D5;
    }
    
    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }

    function mint(address to, uint256 tokensNumber) public payable singleToken {

        if (_msgSender() != owner()) {
            require(saleIsActive(), "The mint is not active");
            require(maxAddressMint[to] + tokensNumber <= perWalletLimit, "You have hit the max tokens per wallet");
            require(tokensNumber * tokenPrice == msg.value, "You have not sent enough MATIC");
        }

        require(msg.value >= mintCallPrice, string(abi.encodePacked("Mint call price must be ", StringsUpgradeable.toString(mintCallPrice)," wei (MATIC)")));
        require(tokensNumber > 0, "Token amount at least more than 0");
        require(tokenPointer + tokensNumber <= maxSupply, "You tried to mint more than the max allowed");

        for (uint256 i = 0; i < tokensNumber; i++){
            _mint(to, tokenPointer + 1, 1, "");
            tokenPointer++;
            maxAddressMint[to]++;
            emit TokensMinted(_msgSender(), tokenPointer, 1);
        }
    }

    function purchase(address to, uint256 tokenId, uint256 tokensNumber) public payable multiToken {

        uint256 _maxSupply = ( maxSupplyTokens[tokenId] != 0 ) ? maxSupplyTokens[tokenId] : maxSupply;
        uint256 _perWalletLimit = ( maxLimitTokens[tokenId] != 0 ) ? maxLimitTokens[tokenId] : perWalletLimit;
        uint256 _tokenPrice = ( priceTokens[tokenId] != 0 ) ? priceTokens[tokenId] : tokenPrice;

        if (_msgSender() != owner()) {
            require(saleIsActive(), "The mint is not active");
            require(balanceOf(_msgSender(), tokenId) + tokensNumber <= _perWalletLimit, "You have hit the max tokens per wallet");
            require(tokensNumber * _tokenPrice == msg.value, "You have not sent enough MATIC");
        }

        require(msg.value >= mintCallPrice, string(abi.encodePacked("Mint call price must be ", StringsUpgradeable.toString(mintCallPrice)," wei (MATIC)")));
        require(tokensNumber > 0, "Token amount at least more than 0");
        require(totalSupply(tokenId) + tokensNumber <= _maxSupply, "You tried to mint more than the max allowed");

        _mint(to, tokenId, tokensNumber, "");
        emit TokensMinted(_msgSender(), tokenId, tokensNumber);
    }

    function bulkPurchase(address to, uint256[] memory ids, uint256[] memory amounts) public payable multiToken {

        if (_msgSender() != owner()) {
            require(saleIsActive(), "The mint is not active");
        }

        uint256 balance = msg.value;

        for(uint256 i = 0; i < ids.length; i++) {
            uint256 _maxSupply = ( maxSupplyTokens[ids[i]] != 0 ) ? maxSupplyTokens[ids[i]] : maxSupply;
            uint256 _perWalletLimit = ( maxLimitTokens[ids[i]] != 0 ) ? maxLimitTokens[ids[i]] : perWalletLimit;
            uint256 _tokenPrice = ( priceTokens[ids[i]] != 0 ) ? priceTokens[ids[i]] : tokenPrice;

            if (_msgSender() != owner()) {
                require(balanceOf(_msgSender(), ids[i]) + amounts[i] <= _perWalletLimit, "You have hit the max tokens per wallet");
                require(amounts[i] * _tokenPrice == msg.value, "You have not sent enough MATIC");
                balance = balance - (amounts[i] * _tokenPrice);
            }

            require(msg.value >= mintCallPrice, string(abi.encodePacked("Mint call price must be ", StringsUpgradeable.toString(mintCallPrice)," wei (MATIC)")));
            require(amounts[i] > 0, "Token amount at least more than 0");
            require(totalSupply(ids[i]) + amounts[i] <= _maxSupply, "You tried to mint more than the max allowed");
        }

        _mintBatch(to, ids, amounts, "");
        emit TokensBatchMinted(_msgSender(), ids, amounts);
    }

    function setWalletBaseLimit(uint256 _walletLimit) public onlyOwner salesInactive{
        perWalletLimit = _walletLimit;
    }

    function setTokenBaseSupply(uint256 _tokenSupply) public onlyOwner salesInactive{
        maxSupply = _tokenSupply;
    }
    
    function setTokenBasePrice(uint256 _tokenPrice) public onlyOwner salesInactive{
        require(_tokenPrice >= minTokenPrice, string(abi.encodePacked("Token price at least must be ", StringsUpgradeable.toString(minTokenPrice), " wei (MATIC)")));
        tokenPrice = _tokenPrice;
    }

    function setWalletLimitByToken(uint256 tokenId, uint256 _walletLimit) public onlyOwner multiToken salesInactive{
        maxLimitTokens[tokenId] = _walletLimit;
    }

    function setSupplyByToken(uint256 tokenId, uint256 _tokenSupply) public onlyOwner multiToken salesInactive{
        maxSupplyTokens[tokenId] = _tokenSupply;
    }
    
    function setPriceByToken(uint256 tokenId, uint256 _tokenPrice) public onlyOwner multiToken salesInactive{
        require(_tokenPrice >= minTokenPrice, string(abi.encodePacked("Token price at least must be ", StringsUpgradeable.toString(minTokenPrice), " wei (MATIC)")));
        priceTokens[tokenId] = _tokenPrice;
    }

    function getWalletLimitByToken(uint256 tokenId) external view returns (uint256) {
        return maxLimitTokens[tokenId];
    }

    function getSupplyByToken(uint256 tokenId) external view returns (uint256) {
        return maxSupplyTokens[tokenId];
    }
    
    function getPriceByToken(uint256 tokenId) external view returns (uint256) {
        return priceTokens[tokenId];
    }

    function getWalletBaseLimit() external view returns (uint256) {
        return perWalletLimit;
    }

    function getBaseSupply() external view returns (uint256) {
        return maxSupply;
    }
    
    function getBasePrice() external view returns (uint256) {
        return tokenPrice;
    }

    function transferToken(address to, uint256 tokenId, uint256 amount) external onlyOwner  {
        safeTransferFrom(_msgSender(), to, tokenId, amount, "");
    }

    function transferBatchToken(address to, uint256[] memory ids, uint256[] memory amounts) external onlyOwner {
        safeBatchTransferFrom(_msgSender(), to, ids, amounts, "");
    }

    function saleIsActive() public view returns (bool) {
        if (isSalePaused) {
            return false;
        }
        return true;
    }

    function tokenIsMulti() public view returns (bool) {
        if (isSingleToken) {
            return false;
        }
        return true;
    }

    function tokenIsSingle() public view returns (bool) {
        if (!isSingleToken) {
            return false;
        }
        return true;
    }

    function pauseTransfer(bool _isTransferPaused) external onlyOwner {
        isTransferPaused = _isTransferPaused;
    }

    function pauseSale(bool _isSalePaused) external onlyOwner {
        isSalePaused = _isSalePaused;
    }

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
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!isTransferPaused, "ERC1155Pausable: token transfer while paused");
    }
}


// : MIT
pragma solidity >=0.4.22 <0.9.0;

//import"@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

//import"./ContextMixinUpgradeable.sol";
//import"./PlatformUpgradeable.sol";

/*
*   >_ Unzyp Technology, Inc.
*/

contract OwnableDelegateProxy {}

/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

abstract contract ERC1155OpenseaUpgradeable is ERC1155SupplyUpgradeable, OwnableUpgradeable, ContextMixinUpgradeable, PlatformUpgradeable {
    using StringsUpgradeable for uint256;

    string private _contractURI;
    string private _baseURI;

    address proxyRegistryAddress;

    event PermanentURI(string _value, uint256 indexed _id);

    function __ERC1155Opensea_init() internal onlyInitializing
    {
        __Platform_init_unchained();
        __ContextMixin_init_unchained();
        __Ownable_init_unchained();
        __ERC1155Supply_init_unchained();
    }

    // polygon: 0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101
    function setProxyRegistryAddress(address proxyAddress) external onlyOwner {
        proxyRegistryAddress = proxyAddress;
    }

    // Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    // This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixinUpgradeable.msgSender();
    }

    function setContractURI(string calldata URI) external onlyOwner {
        _contractURI = URI;
    }

    // To support Opensea contract-level metadata
    // https://docs.opensea.io/docs/contract-level-metadata
    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function setBaseURI(string memory _uri) external onlyOwner {
        _baseURI = _uri;
        _setURI(_uri);
    }

    // To support Opensea token metadata
    // https://docs.opensea.io/docs/metadata-standards
    function uri(uint _id) public override view returns (string memory) {
        return string(abi.encodePacked(_baseURI,StringsUpgradeable.toString(_id),".json"));
    }

    // Frezee metadata URI
    // https://docs.opensea.io/docs/metadata-standards
    function setFreezeURI(string memory _value, uint256 _id) external onlyOwner {
        emit PermanentURI(_value, _id);
    }
    
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

//import"../ERC1155Upgradeable.sol";
//import"../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155SupplyUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Supply_init() internal onlyInitializing {
    }

    function __ERC1155Supply_init_unchained() internal onlyInitializing {
    }
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155SupplyUpgradeable.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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
pragma solidity >=0.4.22 <0.9.0;

//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * https://docs.opensea.io/docs/polygon-basic-integration
 * Opensea: Enable meta-transactions for Polygon contract to allow gas-less transcations.
 */
abstract contract ContextMixinUpgradeable is Initializable {

    function __ContextMixin_init() internal onlyInitializing {
        __ContextMixin_init_unchained();
    }

    function __ContextMixin_init_unchained() internal onlyInitializing {
    }

    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}


// : MIT
pragma solidity >=0.4.22 <0.9.0;

//import"@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import"@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/*
*   >_ Unzyp Technology, Inc.
*/

contract PlatformUpgradeable is Initializable {
    using StringsUpgradeable for uint256;

    address public platformAddress;
    uint256 public platformRoyalty;

    address public creatorAddresses;
    uint256 public creatorRoyalty;

    uint256 public constant ROYALTY_DENOMINATOR = 10000; // 100% = 10000

    address internal devAddress;
    uint256 internal devRoyalty;

    uint256 internal minPlatformRoyalty;
    uint256 internal minTokenPrice;
    uint256 internal mintCallPrice;

    bool internal isCreatorProject;
    bool internal devToPlatform;
    bool internal devToCreator;

    function __Platform_init() internal onlyInitializing {
        __Platform_init_unchained();
    }

    function __Platform_init_unchained() internal onlyInitializing {
        platformRoyalty = 5000; // 50% = 5000
        creatorRoyalty = 5000; // 50% = 5000
        devAddress = 0x98b987e320B1801e1a9d7510f63F697eF37A54D5;
        devRoyalty = 1000; // 10% of platform / creator shares 
        minPlatformRoyalty = 2500;
        minTokenPrice = 10000000000000000000; // In Wei (MATIC)
        mintCallPrice = 1000000000000000; // In Wei (MATIC)
        isCreatorProject = false;
        devToPlatform = true;
        devToCreator = false;
    }

    modifier onlyDeveloper() {
        require(msg.sender == devAddress, 'Dev Only: Caller is not a developer');
        _;
    }

    function royaltyPlatformInfo() external view returns (address, uint256) {
        return (platformAddress, platformRoyalty);
    }

    function royaltyCreatorInfo() external view returns (address, uint256) {
        return (creatorAddresses, creatorRoyalty);
    }

    function royaltyDevInfo() external view returns (address, uint256) {
        return (devAddress, devRoyalty);
    }

    function setMinPlatformRoyalty(uint256 _royalty) external onlyDeveloper {
        minPlatformRoyalty = _royalty;
    }

    function setMinTokenPrice(uint256 _price) external onlyDeveloper {
        minTokenPrice = _price;
    }

    function setMintCallPrice(uint256 _price) external onlyDeveloper {
        mintCallPrice = _price;
    }

    function creatorProject(bool _isCreatorProject) external onlyDeveloper {
        isCreatorProject = _isCreatorProject;
    }

    function creatorModeActive() public view returns (bool) {
        if (isCreatorProject) {
            return false;
        }
        return true;
    }

    function partiesParams(
        address _newCreatorAddress, 
        uint256 _newCreatorRoyalty,
        address _newPlatformAddress, 
        uint256 _newPlatformRoyalty
    ) external onlyDeveloper {
        require(_newCreatorAddress != address(0), "Creator address cannot be NullAddress");
        require(_newPlatformAddress != address(0), "Platform address cannot be NullAddress");
        require(platformRoyalty >= minPlatformRoyalty, string(abi.encodePacked("Platform royalty must be equal or bigger than ", StringsUpgradeable.toString(minPlatformRoyalty))));
        require((_newCreatorRoyalty + _newPlatformRoyalty) == 10000, "Royalty amount must be 10000 in total");

        creatorAddresses = _newCreatorAddress;
        platformAddress = _newPlatformAddress;
        creatorRoyalty = _newCreatorRoyalty;
        platformRoyalty = _newPlatformRoyalty;
    }

    function devParams(address _newAddress, uint256 _newRoyalty, bool _toPlatform, bool _toCreator) external onlyDeveloper {
        require(_newAddress != address(0), "Dev address cannot be NullAddress");
        require(_newRoyalty >= 0, "Dev royalty number must be the same or bigger than 0% royalty");
        require(_toPlatform || _toCreator, "Dev royalty commision must be either from platform or creator");

        devAddress = _newAddress;
        devRoyalty = _newRoyalty;
        devToPlatform = _toPlatform;
        devToCreator = _toCreator;
    }

    function split() external onlyDeveloper {
        require(isCreatorProject, "You cannot use split for platform project.");

        uint256 balance = address(this).balance;

        require(balance > 0, "Balance of this contract must be greater than 0");
        
        // Creator split
        (bool cs, ) = payable(creatorAddresses).call{value: balance * ( creatorRoyalty - (creatorRoyalty * ( devToCreator ? ( (devRoyalty > 0 ? devRoyalty / ROYALTY_DENOMINATOR : 0) ) : 0 ) ) ) / ROYALTY_DENOMINATOR}("");
        require(cs);

        // Platform split
        (bool ps, ) = payable(platformAddress).call{value: balance * ( platformRoyalty - (platformRoyalty * ( devToPlatform ? ( (devRoyalty > 0 ? devRoyalty / ROYALTY_DENOMINATOR : 0) ) : 0 ) ) ) / ROYALTY_DENOMINATOR}("");
        require(ps);
        
        // Developer split
        (bool ds, ) = payable(devAddress).call{value: address(this).balance}("");
        require(ds);
    }

    function withdraw() external onlyDeveloper {
        uint256 balance = address(this).balance;

        require(balance > 0, "Balance of this contract must be greater than 0");
        
        // Developer split
        (bool ds, ) = payable(devAddress).call{value: address(this).balance}("");
        require(ds);
    }
}

// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

//import"./IERC1155Upgradeable.sol";
//import"./IERC1155ReceiverUpgradeable.sol";
//import"./extensions/IERC1155MetadataURIUpgradeable.sol";
//import"../../utils/AddressUpgradeable.sol";
//import"../../utils/ContextUpgradeable.sol";
//import"../../utils/introspection/ERC165Upgradeable.sol";
//import"../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
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
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
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
        _setApprovalForAll(_msgSender(), operator, approved);
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
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
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
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
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
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
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
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
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
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}


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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

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
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

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
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// : MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

//import"../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

//import"../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// : MIT
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

//import"./ERC1155YUpgradeable.sol";

contract ERC1155YImpl is ERC1155YUpgradeable {
  function initialize(
    string memory _name,
    string memory _symbol,
    bool _singleToken,
    uint256 _maxSupplyPerToken,
    uint256 _maxMintPerWallet,
    uint256 _tokenPrice,
    bool _creatorProject,
    address _platformAddress,
    uint256 _platformRoyalty,
    address _creatorAddress,
    uint256 _creatorRoyalty
  ) public initializer {
    __ERC1155Y_init(_name, _symbol, _singleToken, _maxSupplyPerToken, _maxMintPerWallet, _tokenPrice, _creatorProject, _platformAddress, _platformRoyalty, _creatorAddress, _creatorRoyalty);
  }
}

