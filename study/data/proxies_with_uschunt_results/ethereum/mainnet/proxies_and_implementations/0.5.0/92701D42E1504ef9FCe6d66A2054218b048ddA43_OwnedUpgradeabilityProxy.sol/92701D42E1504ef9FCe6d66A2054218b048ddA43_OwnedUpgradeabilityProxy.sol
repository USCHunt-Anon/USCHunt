/**
 *Submitted for verification at Etherscan.io on 2022-05-12
*/

pragma solidity ^0.5.0;


/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public view returns (address);
}

/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(address indexed implementation);

    // Storage position of the address of the current implementation
    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("offchain.proxy.implementation");

    /**
    * @dev Constructor function
    */
    constructor() public {}

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address impl) {
        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    /**
    * @dev Sets the address of the current implementation
    * @param _newImplementation address representing the new implementation to be set
    */
    function _setImplementation(address _newImplementation) internal {
        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            sstore(position, _newImplementation)
        }
    }

    /**
    * @dev Upgrades the implementation address
    * @param _newImplementation representing the address of the new implementation to be set
    */
    function _upgradeTo(address _newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}

/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    // Storage position of the owner of the contract
    bytes32 private constant PROXY_OWNER_POSITION = keccak256("offchain.proxy.owner");

    /**
    * @dev the constructor sets the original owner of the contract to the sender account.
    */
    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner());
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function proxyOwner() public view returns (address owner) {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {
        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    /**
    * @dev Allows the proxy owner to upgrade the current version of the proxy.
    * @param _implementation representing the address of the new implementation to be set.
    */
    function upgradeTo(address _implementation) public onlyProxyOwner {
        _upgradeTo(_implementation);
    }

    /**
     * @dev Sets the address of the owner
    */
    function _setUpgradeabilityOwner(address _newProxyOwner) internal {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}

// : MIT
pragma solidity ^0.8.4;

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

contract MarketRegistry is Ownable {
    struct TradeDetails {
        uint256 marketId;
        uint256 value;
        bytes32 orderHash;
        bytes tradeData;
    }

    struct Market {
        address proxy;
        bool isLib;
        bool isActive;
    }

    event NewMarketAdded(
        address indexed proxy,
        uint256 indexed marketId,
        bool isLib
    );

    event MarketStatusChanged(
        uint256 indexed marketId,
        bool indexed oldStatus,
        bool indexed newStatus
    );

    event MarketProxyChanged(
        uint256 indexed marketId,
        address indexed oldProxy,
        address indexed newProxy,
        bool oldIsLib,
        bool newIsLib
    );

    Market[] public markets;

    constructor(address[] memory proxies, bool[] memory isLibs) {
        for (uint256 i = 0; i < proxies.length; i++) {
            markets.push(Market(proxies[i], isLibs[i], true));
        }
    }

    function addMarket(address proxy, bool isLib) external onlyOwner {
        markets.push(Market(proxy, isLib, true));
        emit NewMarketAdded(proxy, markets.length - 1, isLib);
    }

    function setMarketStatus(uint256 marketId, bool newStatus)
        external
        onlyOwner
    {
        Market storage market = markets[marketId];
        emit MarketStatusChanged(marketId, market.isActive, newStatus);
        market.isActive = newStatus;
    }

    function setMarketProxy(
        uint256 marketId,
        address newProxy,
        bool isLib
    ) external onlyOwner {
        Market storage market = markets[marketId];
        emit MarketProxyChanged(
            marketId,
            market.proxy,
            newProxy,
            market.isLib,
            isLib
        );
        market.proxy = newProxy;
        market.isLib = isLib;
    }

    function getMarketInfo(uint256 marketId)
        external
        view
        returns (
            address proxy,
            bool isLib,
            bool isActive
        )
    {
        Market memory marketInfo = markets[marketId];
        proxy = marketInfo.proxy;
        isLib = marketInfo.isLib;
        isActive = marketInfo.isActive;
    }
}

contract OkxNFTMarketAggregator is Ownable, ReentrancyGuard {
    bool private _initialized;
    MarketRegistry public marketRegistry;

    event MatchOrderResults(bytes32[] orderHashes, bool[] results);

    function init(address newOwner) external {
        require(!_initialized, "Already initialized");
        _initialized = true;
        _transferOwnership(newOwner);
    }

    function setMarketRegistry(address _marketRegistry) external onlyOwner {
        marketRegistry = MarketRegistry(_marketRegistry);
    }

    function trade(MarketRegistry.TradeDetails[] memory tradeDetails)
        external
        payable
        nonReentrant
    {
        uint256 length = tradeDetails.length;
        bytes32[] memory orderHashes = new bytes32[](length);
        bool[] memory results = new bool[](length);
        uint256 giveBackValue;

        for (uint256 i; i < length; ) {
            (address proxy, bool isLib, bool isActive) = marketRegistry.markets(
                tradeDetails[i].marketId
            );
            require(isActive, "Market inactive");

            bytes memory tradeData = tradeDetails[i].tradeData;
            uint256 ethValue = tradeDetails[i].value;

            (bool success, ) = isLib
                ? proxy.delegatecall(tradeData)
                : proxy.call{value: ethValue}(tradeData);

            orderHashes[i] = tradeDetails[i].orderHash;
            results[i] = success;

            if (!success) {
                giveBackValue += ethValue;
            }

            unchecked {
                ++i;
            }
        }

        if (giveBackValue > 0) {
            (bool transfered, bytes memory reason) = msg.sender.call{
                value: giveBackValue
            }("");
            require(transfered, string(reason));
        }

        emit MatchOrderResults(orderHashes, results);
    }

    // emergency withdraw
    function withdraw(address to, uint256 amount) external onlyOwner {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Withdraw failed");
    }
}