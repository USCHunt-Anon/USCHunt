// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;
////import './interfaces/IERC20.sol';
////import './interfaces/IWETH.sol';
////import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
////import './libraries/LibDiamond.sol';
////import './libraries/OrderBookStorage.sol';
////import './interfaces/IDiamondLoupe.sol';
////import './interfaces/IDiamondCut.sol';

contract OrderBookProxy {
    address public weth;

    constructor(address _weth, IDiamondCut.FacetCut[] memory _diamondCut) {
        weth = _weth;
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
        LibDiamond.setContractOwner(tx.origin);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;

        //Initialization of OrderBook elements
        OrderBookStorage.OrderBook storage orderBookStorage = OrderBookStorage.orderBookStruct();
        orderBookStorage.tradeFee = 2000000000000000; //Initialized with 0.20% as trade fee
        orderBookStorage.tradeFeeTo = tx.origin;
        OrderBookStorage.UserOrder memory _order;
        _order.orderId = OrderBookStorage.ORDER_ID_OFFSET;
        orderBookStorage.userOrders.push(_order);
    }

    receive() external payable {}

    function transferOwnership(address _newOwner) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.setContractOwner(_newOwner);
    }

    function owner() external view returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }

    function addToTokenBalance(
        address user,
        address tokenAddress,
        uint256 amount
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][tokenAddress];
        require(userBal + amount >= userBal, 'Amount must be positive. ');
        ds.userBalances[user][tokenAddress] += amount;
    }

    function minusFromTokenBalance(
        address user,
        address tokenAddress,
        uint256 amount
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][tokenAddress];
        require(userBal - amount <= userBal, 'Amount must be positive. ');
        require(userBal - amount >= 0, 'Insufficient balance. ');
        ds.userBalances[user][tokenAddress] -= amount;
    }

    /**
     * @dev This method deposits a specified amount to the specified ERC20 token to the contract.
     * tokenAddress is the specified token
     *
     */
    function depositERC20(uint256 amount, address tokenAddress) external {
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), 'Deposit failed. ');
        addToTokenBalance(msg.sender, tokenAddress, amount);
    }

    /**
     * @dev This method withdraws a specified ERC20 token amount to the user from the contract.
     * tokenAddress is the specified token
     *
     */
    function withdrawERC20(uint256 amount, address tokenAddress) external {
        require(IERC20(tokenAddress).transfer(msg.sender, amount), 'Withdraw failed. ');
        minusFromTokenBalance(msg.sender, tokenAddress, amount);
    }

    /**
     * @dev This method deposits ETH to the contract.
     *
     */
    function depositETH() external payable {
        IWETH(weth).deposit{value: msg.value}();
        addToTokenBalance(msg.sender, weth, msg.value);
    }

    /**
     * @dev This method withdraws ETH amount to the user from the contract.
     *
     */
    function withdrawETH(uint256 amount) external virtual {
        minusFromTokenBalance(msg.sender, weth, amount);
        IWETH(weth).withdraw(amount);
        TransferHelper.safeTransferETH(msg.sender, amount);
    }

    /**
     * @dev This method shows the user's ERC20 token balances
     *
     */
    function getTokenBalance(address user, address tokenAddress) external view returns (uint256) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][tokenAddress];
        return userBal;
    }

    /**
     * @dev This method shows the user's ETH balances
     *
     */
    function getETHBalance(address user) external view returns (uint256) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][weth];
        return userBal;
    }

    function updateWETH(address _weth) external {
        LibDiamond.enforceIsContractOwner();
        require(_weth != address(0x0), 'Invalid wallet address');
        require(_weth != address(this), 'Invalid wallet address');
        weth = _weth;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), 'Diamond: Function does not exist');
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;

library OrderBookStorage {
    enum OrderType{BUY, SELL}
    enum OrderStatus{COMPLETED, PENDING, CANCELLED}
    enum MatchStatus{FULL, PARTIAL, NO}
    uint constant internal ORDER_ID_OFFSET = 1000;

    struct UserOrder {
        uint orderId;
        uint amount;
        uint amountFulfilled;
        uint price;
        bytes32 pairName;
        address[] path;
        uint maxFee;
        OrderType orderType;
        address user;
        OrderStatus orderStatus;
        uint timestamp;
        uint8 isMarketMaker;
        uint8 isMarketTaker;
    }

    struct OrderBook {
        //User Orders Array containing both Buy & Sell orders
        UserOrder[] userOrders;
        //Map containing pair name => mapping of UserOrder pointer to the next UserOrder pointer in sorted order
        mapping(bytes32 => mapping(uint => uint)) buyOrders;
        uint buyOrdersLength;
        //Map containing pair name => mapping of UserOrder pointer to the next UserOrder pointer in sorted order
        mapping(bytes32 => mapping(uint => uint)) sellOrders;
        uint sellOrdersLength;
        uint tradeFee;
        address tradeFeeTo;
        // balance of user for each token. 
        mapping(address => mapping(address => uint256)) userBalances;
    }

    // Returns the struct from a specified position in contract storage
    // ds is short for DiamondStorage
    function orderBookStruct() internal pure returns(OrderBook storage ds) {
        // Specifies a random position from a hash of a string
        bytes32 storagePosition = keccak256("OrderBook.storage.OrderBookStorage");
        // Set the position of our struct in contract storage
        assembly {
            ds.slot := storagePosition
        }
    }
}

// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;

////import "../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.otborderbook.storage");

    struct DiamondStorage {
        // maps function selectors to the facets that execute the functions.
        // and maps the selectors to their position in the selectorSlots array.
        // func selector => address facet, selector position
        mapping(bytes4 => bytes32) facets;
        // array of slots of function selectors.
        // each slot holds 8 function selectors.
        mapping(uint256 => bytes32) selectorSlots;
        // The number of function selectors in selectorSlots
        uint16 selectorCount;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    // Internal function version of diamondCut
    // This code is almost the same as the external diamondCut,
    // except it is using 'Facet[] memory _diamondCut' instead of
    // 'Facet[] calldata _diamondCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
                // add facet for selector
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                // clear selector position in slot and add selector
                _selectorSlot = (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) | (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IDiamondCut.FacetCutAction.Replace) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                // only useful if immutable functions exist
                require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
                require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
                require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
                // replace old facet address
                ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);
            }
        } else if (_action == IDiamondCut.FacetCutAction.Remove) {
            require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
            uint256 selectorSlotCount = _selectorCount >> 3;
            uint256 selectorInSlotIndex = _selectorCount & 7;
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                if (_selectorSlot == 0) {
                    // get last selectorSlot
                    selectorSlotCount--;
                    _selectorSlot = ds.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }
                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;
                // adding a block here prevents stack too deep error
                {
                    bytes4 selector = _selectors[selectorIndex];
                    bytes32 oldFacet = ds.facets[selector];
                    require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
                    // only useful if immutable functions exist
                    require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
                    // replace selector with last selector in ds.facets
                    // gets the last selector
                    lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex << 5));
                    if (lastSelector != selector) {
                        // update last selector slot position info
                        ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
                    }
                    delete ds.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    // update storage with the modified slot
                    ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    _selectorSlot =
                        (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete ds.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
        } else {
            revert("LibDiamondCut: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// ////-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.5;

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// : GPL-3.0-or-later
pragma solidity >=0.8.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


// : GPL-3.0-or-later
pragma solidity >=0.8.5;

library OrderBookStorage {
    enum OrderType{BUY, SELL}
    enum OrderStatus{COMPLETED, PENDING, CANCELLED}
    enum MatchStatus{FULL, PARTIAL, NO}
    uint constant internal ORDER_ID_OFFSET = 1000;

    struct UserOrder {
        uint orderId;
        uint amount;
        uint amountFulfilled;
        uint price;
        bytes32 pairName;
        address[] path;
        uint maxFee;
        OrderType orderType;
        address user;
        OrderStatus orderStatus;
        uint timestamp;
        uint8 isMarketMaker;
        uint8 isMarketTaker;
    }

    struct OrderBook {
        //User Orders Array containing both Buy & Sell orders
        UserOrder[] userOrders;
        //Map containing pair name => mapping of UserOrder pointer to the next UserOrder pointer in sorted order
        mapping(bytes32 => mapping(uint => uint)) buyOrders;
        uint buyOrdersLength;
        //Map containing pair name => mapping of UserOrder pointer to the next UserOrder pointer in sorted order
        mapping(bytes32 => mapping(uint => uint)) sellOrders;
        uint sellOrdersLength;
        uint tradeFee;
        address tradeFeeTo;
        // balance of user for each token. 
        mapping(address => mapping(address => uint256)) userBalances;
    }

    // Returns the struct from a specified position in contract storage
    // ds is short for DiamondStorage
    function orderBookStruct() internal pure returns(OrderBook storage ds) {
        // Specifies a random position from a hash of a string
        bytes32 storagePosition = keccak256("OrderBook.storage.OrderBookStorage");
        // Set the position of our struct in contract storage
        assembly {
            ds.slot := storagePosition
        }
    }
}

// : GPL-3.0-or-later
pragma solidity >=0.8.5;

//import"../interfaces/IDiamondCut.sol";

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.otborderbook.storage");

    struct DiamondStorage {
        // maps function selectors to the facets that execute the functions.
        // and maps the selectors to their position in the selectorSlots array.
        // func selector => address facet, selector position
        mapping(bytes4 => bytes32) facets;
        // array of slots of function selectors.
        // each slot holds 8 function selectors.
        mapping(uint256 => bytes32) selectorSlots;
        // The number of function selectors in selectorSlots
        uint16 selectorCount;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
        mapping(bytes4 => bool) supportedInterfaces;
        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    // Internal function version of diamondCut
    // This code is almost the same as the external diamondCut,
    // except it is using 'Facet[] memory _diamondCut' instead of
    // 'Facet[] calldata _diamondCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
                // add facet for selector
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                // clear selector position in slot and add selector
                _selectorSlot = (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) | (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IDiamondCut.FacetCutAction.Replace) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                // only useful if immutable functions exist
                require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
                require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
                require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
                // replace old facet address
                ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);
            }
        } else if (_action == IDiamondCut.FacetCutAction.Remove) {
            require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
            uint256 selectorSlotCount = _selectorCount >> 3;
            uint256 selectorInSlotIndex = _selectorCount & 7;
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                if (_selectorSlot == 0) {
                    // get last selectorSlot
                    selectorSlotCount--;
                    _selectorSlot = ds.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }
                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;
                // adding a block here prevents stack too deep error
                {
                    bytes4 selector = _selectors[selectorIndex];
                    bytes32 oldFacet = ds.facets[selector];
                    require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
                    // only useful if immutable functions exist
                    require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
                    // replace selector with last selector in ds.facets
                    // gets the last selector
                    lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex << 5));
                    if (lastSelector != selector) {
                        // update last selector slot position info
                        ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
                    }
                    delete ds.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    // update storage with the modified slot
                    ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    _selectorSlot =
                        (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete ds.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
        } else {
            revert("LibDiamondCut: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// : GPL-3.0-or-later
pragma solidity >=0.8.0;

//import'./SafeMath.sol';

library Decimal {
    using SafeMath for uint;
    uint8 public constant decimals = 18;
    /**
     * @dev This method represents number of digits after decimal point supported
     */
    function multiplier() internal pure returns(uint) {
        return 10**decimals;
    }
    /**
     * @dev This method returns integer part of solidity decimal
     */
    function integer(uint _value) internal pure returns (uint) {
        return (_value / multiplier()) * multiplier(); // Can't overflow
    }
    /**
     * @dev This method returns fractional part of solidity decimal
     */
    function fractional(uint _value) internal pure returns (uint) {
        return _value.sub(integer(_value));
    }
    /**
     * @dev This method separates out solidity decimal to integral & fraction parts
     */
    function decimalFrom(uint _value) internal pure returns(uint, uint) {
        return ((_value / multiplier()), fractional(_value));
    }
    /**
     * @dev This method converts integral & fraction parts into solidity decimal
     */
    function decimalTo(uint _integral, uint _fractional) public pure returns(uint) {
        //return _integral.mul(multiplier()).add(_fractional.mul(multiplier()) / calculateFractionMultiplier(_fractional));
        return _integral.mul(multiplier()).add(_fractional);
    }

    function calculateFractionMultiplier(uint number) internal pure returns(uint) {
        uint fractionMultiplier = 1;
        while (number != 0) {
            number /= 10;
            fractionMultiplier = fractionMultiplier.mul(10);
        }
        return fractionMultiplier;
    }
    /**
     * @dev This method adds solidity decimal with integer value
     */
    function uintAddition(uint _value, uint x) internal pure returns(uint) {
        return _value.add(x.mul(multiplier()));
    }
    /**
     * @dev This method adds solidity decimal with solidity decimal
     * Assumption both the decimals conatains same decimal multiplier
     */
    function decimalAddition(uint _value, uint x) internal pure returns(uint) {
        return _value.add(x);
    }
    /**
     * @dev This method adds solidity decimal with integer value
     */
    function uintSubtraction(uint _value, uint x) internal pure returns(uint) {
        return _value.sub(x.mul(multiplier()));
    }
    /**
     * @dev This method adds solidity decimal with solidity decimal
     * Assumption both the decimals conatains same decimal multiplier
     */
    function decimalSubtraction(uint _value, uint x) internal pure returns(uint) {
        return _value.sub(x);
    }
    /**
     * @dev This method multiplies solidity decimal with integer value
     */
    function uintMultiply(uint _value, uint x) internal pure returns(uint) {
        return _value.mul(x);
    }
    /**
     * @dev This method multiplies solidity decimal with solidity decimal
     * Assumption both the decimals conatains same decimal multiplier
     */
    function decimalMultiply(uint _value, uint y) internal pure returns (uint) {
        if (_value == 0 || y == 0) return 0;

        // Separate into integer and fractional parts
        // x = x1 + x2, y = y1 + y2
        uint x1 = integer(_value);
        uint x2 = fractional(_value);
        uint y1 = integer(y);
        uint y2 = fractional(y);

        // (x1 + x2) * (y1 + y2) = (x1 * y1) + (x1 * y2) + (x2 * y1) + (x2 * y2)
        uint x1y1 = x1.mul(y1);
        uint x2y1 = x2.mul(y1);
        uint x1y2 = x1.mul(y2);
        uint x2y2 = x2.mul(y2);

        return (x1y1.add(x2y1).add(x1y2).add(x2y2)) / multiplier();
    }

    function reciprocal(uint x) internal pure returns (uint) {
        assert(x != 0);
        return multiplier() * multiplier() / x;
    }
    /**
     * @dev This method divides solidity decimal with solidity decimal
     * Assumption both the decimals conatains same decimal multiplier
     */
    function decimalDivide(uint _value, uint y) internal pure returns (uint) {
        assert(y != 0);
        return decimalMultiply(_value, reciprocal(y));
    }
}

pragma solidity >=0.6.2;

//import'./IOTBSwapRouter01.sol';

interface IOTBSwapRouter02 is IOTBSwapRouter01 {
    /*function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    */

pragma solidity >=0.6.2;

interface IOTBSwapRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


pragma solidity >=0.5.0;

interface IOTBSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


pragma solidity >=0.5.0;

interface IOTBSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// : GPL-3.0-or-later
pragma solidity >=0.8.0;

interface IOTBLotterySystem {
    function mintTickets(address user, uint amount) external;
}

// : GPL-3.0-or-later
pragma solidity >=0.8.5;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// : GPL-3.0-or-later
pragma solidity >=0.8.5;

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// : GPL-3.0-or-later
pragma solidity >=0.8.5;

//import'../interfaces/IOTBSwapFactory.sol';
//import'../interfaces/IOTBSwapPair.sol';
//import'../interfaces/IERC20.sol';
//import'../interfaces/IOTBSwapRouter02.sol';
//import'../interfaces/IOTBLotterySystem.sol';

//import'../libraries/LibDiamond.sol';
//import'../libraries/SafeMath.sol';
//import'../libraries/Decimal.sol';
//import'../libraries/OrderBookStorage.sol';

contract OTBOrderbookTradeFacet {
    using Decimal for uint256;
    using SafeMath for uint256;

    event BuyEvent(
        bytes32 indexed pairName,
        uint256 tradedAmount,
        uint256 txAmount,
        uint256 price,
        OrderBookStorage.MatchStatus matchStatus
    );
    event SellEvent(
        bytes32 indexed pairName,
        uint256 tradedAmount,
        uint256 txAmount,
        uint256 price,
        OrderBookStorage.MatchStatus matchStatus
    );
    event Completed(
        bytes32 indexed pairName,
        address user,
        uint256 orderId,
        uint256 tradedAmount,
        uint256 txAmount,
        uint256 price,
        uint256 timestamp,
        OrderBookStorage.OrderType orderType,
        bool isTaker
    );
    event Cancelled(
        bytes32 indexed pairName,
        address user,
        uint256 orderId,
        uint256 unfulfilled,
        uint256 amount,
        uint256 price,
        uint256 timestamp,
        OrderBookStorage.OrderType orderType
    );

    address internal immutable factory;
    address internal immutable router;
    address internal immutable lottery;

    constructor(
        address _factory,
        address _router,
        address _lottery
    ) {
        factory = _factory;
        router = _router;
        lottery = _lottery;
    }

    /**
     * @dev Return Address of pair of contract. tokenA and tokenB order is interchangeable.
     * Input: Address for tokenA and address for tokenB
     * Output: Boolean, Returns false if no pair exists, else true if pair exists.
     */
    function hasPair(address _tokenA, address _tokenB) public view returns (bool) {
        if (IOTBSwapFactory(factory).getPair(_tokenA, _tokenB) == address(0)) {
            return false;
        }
        return true;
    }

    /**
     * @dev Return bytes32 name of pair of coins. Usually string concatenated value of symbols of token pairs.
     * Input: Address for tokenA and address for tokenB
     * Output: bytes32 name of pair (where one exists).
     */
    // function getPair(address _tokenA, address _tokenB) internal returns (bytes32 _pairName) {
    //     if (hasPair(_tokenA, _tokenB)) {
    //         _pairName = bytes32(abi.encodePacked(IERC20(_tokenA).symbol(), IERC20(_tokenB).symbol()));
    //     }
    //     OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
    //     if(ds.buyOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] == 0) {
    //         ds.buyOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] = OrderBookStorage.ORDER_ID_OFFSET;
    //     }
    //     if(ds.sellOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] == 0) {
    //         ds.sellOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] = OrderBookStorage.ORDER_ID_OFFSET;
    //     }
    // }
    /**
     * @dev Puts in the order for amount of TokenA user wants to receive from the AmountB paid.
     * AmountA & AmountB is required to be passed in decimal format i.e. 40 tokens means 4000000000 must be passed
     * Buy order is Bid order.
     * Should search order books for matching first.
     * If Orderbook, doesn’t fullfill then search the swap contract.
     * If neither can fullfill then, this order gets added to the orderbook and becomes a maker order.
     * e.g. paid for TokenB of 20 tokens to get 40 Tokens TokenA
     */
    function buy(
        address _tradedToken,
        address _txToken,
        uint256 _tradedTokenAmount,
        uint256 _txTokenAmount
    ) external {
        require(hasPair(_tradedToken, _txToken), 'Pair does not exist');
        OrderBookStorage.UserOrder memory _order = createUserOrder(
            OrderBookStorage.OrderType.BUY,
            _tradedToken,
            _txToken,
            _tradedTokenAmount,
            _txTokenAmount
        );
        uint256 _unmatchedTokenAmount = trade(OrderBookStorage.OrderType.BUY, _order);
        if (_unmatchedTokenAmount > 0) {
            minusFromTokenBalance(_order.user, _order.path[1], _unmatchedTokenAmount.decimalMultiply(_order.price));
            // IERC20(_order.path[1]).transferFrom(_order.user, address(this), _unmatchedTokenAmount.decimalMultiply(_order.price));
        }
    }

    /**
     * @dev Puts in the order for amount of TokenB user wants to receive from the AmountA they paid.
     * AmountA & AmountB is required to be passed in decimal format i.e. 40 tokens means 4000000000 must be passed
     * Sell order is Ask order.
     * e.g. paid for TokenA of 40 tokens to get 20 Tokens TokenB
     */
    function sell(
        address _tradedToken,
        address _txToken,
        uint256 _tradedTokenAmount,
        uint256 _txTokenAmount
    ) external {
        require(hasPair(_tradedToken, _txToken), 'Pair does not exist');
        OrderBookStorage.UserOrder memory _order = createUserOrder(
            OrderBookStorage.OrderType.SELL,
            _tradedToken,
            _txToken,
            _tradedTokenAmount,
            _txTokenAmount
        );
        uint256 _unmatchedTokenAmount = trade(OrderBookStorage.OrderType.SELL, _order);
        if (_unmatchedTokenAmount > 0) {
            minusFromTokenBalance(_order.user, _order.path[0], _unmatchedTokenAmount);
            // IERC20(_order.path[0]).transferFrom(_order.user, address(this), _unmatchedTokenAmount);
        }
    }

    function trade(OrderBookStorage.OrderType _orderType, OrderBookStorage.UserOrder memory _order)
        internal
        returns (uint256 _unmatchedTokenAmount)
    {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        _unmatchedTokenAmount = _order.amount;
        OrderBookStorage.MatchStatus _matchStatus = OrderBookStorage.MatchStatus.NO;
        uint256 _availableVolume = 0;
        uint256 _prevOrderId = OrderBookStorage.ORDER_ID_OFFSET;
        uint256 _idxOrderid = findMatchedNextOrderId(_orderType, _order.pairName, _prevOrderId);
        while (_idxOrderid != OrderBookStorage.ORDER_ID_OFFSET) {
            OrderBookStorage.UserOrder memory _offer = ds.userOrders[_idxOrderid - OrderBookStorage.ORDER_ID_OFFSET];
            if (checkPrice(_orderType, _offer.price, _order.price)) {
                _availableVolume = _offer.amount.decimalSubtraction(_offer.amountFulfilled);
                if (_availableVolume >= _unmatchedTokenAmount) {
                    //Full Match
                    _matchStatus = OrderBookStorage.MatchStatus.FULL;
                    (_availableVolume, _unmatchedTokenAmount) = executeMatch(
                        _offer.orderId - OrderBookStorage.ORDER_ID_OFFSET,
                        _order,
                        _unmatchedTokenAmount
                    );
                } else {
                    //Partial Match
                    _matchStatus = OrderBookStorage.MatchStatus.PARTIAL;
                    (_availableVolume, _unmatchedTokenAmount) = executeMatch(
                        _offer.orderId - OrderBookStorage.ORDER_ID_OFFSET,
                        _order,
                        _availableVolume
                    );
                }
            } else {
                //No more Match found
                _matchStatus = OrderBookStorage.MatchStatus.NO;
                break;
            }
            if (_availableVolume == 0 && _matchStatus != OrderBookStorage.MatchStatus.NO) {
                removeMatchedOffer(_orderType, _order.pairName, _prevOrderId, _idxOrderid);
            } else {
                _prevOrderId = _idxOrderid;
            }
            if (_unmatchedTokenAmount == 0) {
                break;
            }
            _idxOrderid = findMatchedNextOrderId(_orderType, _order.pairName, _prevOrderId);
        }

        if (_matchStatus == OrderBookStorage.MatchStatus.NO || _matchStatus == OrderBookStorage.MatchStatus.PARTIAL) {
            createMakerOffer(_orderType, _order.pairName, _order.orderId, _order.price);
        }

        // persist at userOrders
        ds.userOrders.push(_order);
        raiseTradeEvent(_orderType, _matchStatus, _order, _order.amount);
    }

    function checkSwapOnRouter(OrderBookStorage.OrderType _orderType, uint256 _orderId)
        external
        view
        returns (
            OrderBookStorage.OrderType _oType,
            uint256 _oId,
            bool hasMatch
        )
    {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 _orderIndex = _orderId - OrderBookStorage.ORDER_ID_OFFSET;
        OrderBookStorage.UserOrder memory _order = ds.userOrders[_orderIndex];
        uint256 _unmatchedTokenAmount = (_order.amount * 1015) / 1000;
        _oType = _orderType;
        _oId = _orderId;
        hasMatch = false;
        if (_unmatchedTokenAmount > 0) {
            if (
                checkLiquidityProviderMatch(
                    _orderType,
                    _order.path,
                    _unmatchedTokenAmount,
                    _unmatchedTokenAmount.decimalMultiply(_order.price)
                )
            ) {
                hasMatch = true;
            }
        }
    }

    function swapOnRouter(OrderBookStorage.OrderType _orderType, uint256 _orderId) external {
        OrderBookStorage.MatchStatus _matchStatus = OrderBookStorage.MatchStatus.NO;

        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 _orderIndex = _orderId - OrderBookStorage.ORDER_ID_OFFSET;
        OrderBookStorage.UserOrder memory _order = ds.userOrders[_orderIndex];

        uint256 _unmatchedTokenAmount = (_order.amount * 1015) / 1000;
        require(_unmatchedTokenAmount > 0, 'Order already fullfilled. ');
        require(
            checkLiquidityProviderMatch(
                _orderType,
                _order.path,
                _unmatchedTokenAmount,
                _unmatchedTokenAmount.decimalMultiply(_order.price)
            ),
            'No liquidity match'
        );

        performSwap(_orderType, _order, _unmatchedTokenAmount, _unmatchedTokenAmount.decimalMultiply(_order.price));
        updateCurrentOrderForMatchFound(_order, _unmatchedTokenAmount);
        _matchStatus = OrderBookStorage.MatchStatus.FULL;

        if (_matchStatus == OrderBookStorage.MatchStatus.FULL) {
            //Generate Lottery
            IOTBLotterySystem(lottery).mintTickets(_order.user, 1);
        }
    }

    /**
     * @dev Cancels the trade. Must remove from the appropriate sellOrder or buyOrder books. Must be the user of the open order.
     */
    function cancelTrade(uint256 _orderId) external {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 _orderIndex = _orderId - OrderBookStorage.ORDER_ID_OFFSET;
        require(msg.sender == ds.userOrders[_orderIndex].user, 'User Not Authorized');
        require(
            ds.userOrders[_orderIndex].orderStatus == OrderBookStorage.OrderStatus.PENDING,
            'Only Pending order allowed'
        );
        ds.userOrders[_orderIndex].orderStatus = OrderBookStorage.OrderStatus.CANCELLED;
        OrderBookStorage.OrderType _matchOrderType;
        if (ds.userOrders[_orderIndex].orderType == OrderBookStorage.OrderType.BUY) {
            _matchOrderType = OrderBookStorage.OrderType.SELL;
        } else {
            _matchOrderType = OrderBookStorage.OrderType.BUY;
        }
        uint256 _prevOrderId = findPrevOrderId(
            ds.userOrders[_orderIndex].orderType,
            ds.userOrders[_orderIndex].pairName,
            _orderId
        );
        removeMatchedOffer(_matchOrderType, ds.userOrders[_orderIndex].pairName, _prevOrderId, _orderId);
        uint256 unfulfilledAmount = ds.userOrders[_orderIndex].amount.decimalSubtraction(
            ds.userOrders[_orderIndex].amountFulfilled
        );

        if (ds.userOrders[_orderIndex].orderType == OrderBookStorage.OrderType.BUY) {
            addToTokenBalance(
                ds.userOrders[_orderIndex].user,
                ds.userOrders[_orderIndex].path[1],
                unfulfilledAmount.decimalMultiply(ds.userOrders[_orderIndex].price)
            );
            // IERC20(ds.userOrders[_orderIndex].path[1]).transfer(ds.userOrders[_orderIndex].user, unfulfilledAmount.decimalMultiply(ds.userOrders[_orderIndex].price));
        } else {
            addToTokenBalance(ds.userOrders[_orderIndex].user, ds.userOrders[_orderIndex].path[0], unfulfilledAmount);
            // IERC20(ds.userOrders[_orderIndex].path[0]).transfer(ds.userOrders[_orderIndex].user, unfulfilledAmount);
        }

        emit Cancelled(
            ds.userOrders[_orderIndex].pairName,
            ds.userOrders[_orderIndex].user,
            _orderId,
            unfulfilledAmount,
            ds.userOrders[_orderIndex].amount,
            ds.userOrders[_orderIndex].price,
            ds.userOrders[_orderIndex].timestamp,
            ds.userOrders[_orderIndex].orderType
        );
    }

    function addToTokenBalance(
        address user,
        address tokenAddress,
        uint256 amount
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][tokenAddress];
        require(userBal + amount >= userBal, 'Amount must be positive. ');
        ds.userBalances[user][tokenAddress] += amount;
    }

    function minusFromTokenBalance(
        address user,
        address tokenAddress,
        uint256 amount
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 userBal = ds.userBalances[user][tokenAddress];
        require(userBal - amount <= userBal, 'Amount must be positive. ');
        require(userBal - amount >= 0, 'Insufficient balance. ');
        ds.userBalances[user][tokenAddress] -= amount;
    }

    /**
     * @dev This function creates User order struct populating all information for current Trade.
     */
    function createUserOrder(
        OrderBookStorage.OrderType _orderType,
        address _tradedToken,
        address _txToken,
        uint256 _tradedTokenAmount,
        uint256 _txTokenAmount
    ) internal returns (OrderBookStorage.UserOrder memory) {
        bytes32 _pairName;
        if (hasPair(_tradedToken, _txToken)) {
            _pairName = bytes32(abi.encodePacked(IOTBSwapFactory(factory).getPair(_tradedToken, _txToken)));
        }
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        if (ds.buyOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] == 0) {
            ds.buyOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] = OrderBookStorage.ORDER_ID_OFFSET;
        }
        if (ds.sellOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] == 0) {
            ds.sellOrders[_pairName][OrderBookStorage.ORDER_ID_OFFSET] = OrderBookStorage.ORDER_ID_OFFSET;
        }
        //bytes32 _pairName = getPair(_tradedToken, _txToken);

        address[] memory _path = new address[](2);
        _path[0] = _tradedToken;
        _path[1] = _txToken;

        //OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        OrderBookStorage.UserOrder memory _order = OrderBookStorage.UserOrder({
            orderId: OrderBookStorage.ORDER_ID_OFFSET.add(ds.userOrders.length),
            amount: _tradedTokenAmount,
            amountFulfilled: 0,
            price: _txTokenAmount.decimalDivide(_tradedTokenAmount),
            pairName: _pairName,
            path: _path,
            orderType: _orderType,
            maxFee: 0,
            orderStatus: OrderBookStorage.OrderStatus.PENDING,
            user: msg.sender,
            timestamp: block.timestamp,
            isMarketMaker: 1,
            isMarketTaker: 0
        });
        return _order;
    }

    /**
     * @dev This internal function executes steps when a full or parial match found in either of Buy or Sell orders.
     */
    function executeMatch(
        uint256 matchingOrderIndex,
        OrderBookStorage.UserOrder memory _order,
        uint256 _tokenAmount
    ) internal returns (uint256, uint256) {
        uint256 existingOfferAvailableAmount = updateOrderForMatchFound(matchingOrderIndex, _tokenAmount);
        uint256 newOfferAvailableAmount = updateCurrentOrderForMatchFound(_order, _tokenAmount);

        settleTrade(matchingOrderIndex, _order, _tokenAmount);
        //Generate Lottery
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        IOTBLotterySystem(lottery).mintTickets(ds.userOrders[matchingOrderIndex].user, 1);
        return (existingOfferAvailableAmount, newOfferAvailableAmount);
    }

    /**
     * @dev This internal function updates order fulfillment details and changes status of the order by order Id.
     */
    function updateOrderForMatchFound(uint256 _orderIndex, uint256 _tokenAmount) internal returns (uint256) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        ds.userOrders[_orderIndex].amountFulfilled = ds.userOrders[_orderIndex].amountFulfilled.decimalAddition(
            _tokenAmount
        );
        require(
            ds.userOrders[_orderIndex].amount >= ds.userOrders[_orderIndex].amountFulfilled,
            'Amount can not be less than fulfilled'
        );
        uint256 _availableAmount = ds.userOrders[_orderIndex].amount.decimalSubtraction(
            ds.userOrders[_orderIndex].amountFulfilled
        );
        if (_availableAmount == 0) {
            ds.userOrders[_orderIndex].orderStatus = OrderBookStorage.OrderStatus.COMPLETED;
            ds.userOrders[_orderIndex].isMarketTaker = 1;
            ds.userOrders[_orderIndex].isMarketMaker = 0;
            emit Completed(
                ds.userOrders[_orderIndex].pairName,
                ds.userOrders[_orderIndex].user,
                _orderIndex + OrderBookStorage.ORDER_ID_OFFSET,
                _tokenAmount,
                _tokenAmount.decimalMultiply(ds.userOrders[_orderIndex].price),
                ds.userOrders[_orderIndex].price,
                ds.userOrders[_orderIndex].timestamp,
                ds.userOrders[_orderIndex].orderType,
                false
            );
        }
        return _availableAmount;
    }

    /**
     * @dev This internal function updates order fulfillment details and changes status of the order by order Id.
     */
    function updateCurrentOrderForMatchFound(OrderBookStorage.UserOrder memory _order, uint256 _tokenAmount)
        internal
        returns (uint256)
    {
        _order.amountFulfilled = _order.amountFulfilled.decimalAddition(_tokenAmount);
        require(_order.amount >= _order.amountFulfilled, 'Amount can not be less than fulfilled');
        uint256 _availableAmount = _order.amount.decimalSubtraction(_order.amountFulfilled);
        if (_availableAmount == 0) {
            _order.orderStatus = OrderBookStorage.OrderStatus.COMPLETED;
            _order.isMarketTaker = 1;
            _order.isMarketMaker = 0;
            emit Completed(
                _order.pairName,
                _order.user,
                _order.orderId,
                _tokenAmount,
                _tokenAmount.decimalMultiply(_order.price),
                _order.price,
                _order.timestamp,
                _order.orderType,
                true
            );
        }
        return _availableAmount;
    }

    /**
     * @dev This internal function settles trade by setting token transfer & trade fee transfer to the Orderbook.
     */
    function settleTrade(
        uint256 matchingOrderIndex,
        OrderBookStorage.UserOrder memory _order,
        uint256 _tradedTokenAmount
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 _tradedTokenFees = calculateFees(_tradedTokenAmount);
        uint256 _txTokenAmount = 0;
        uint256 _txTokenFee = 0;
        if (_order.orderType == OrderBookStorage.OrderType.BUY) {
            _txTokenAmount = _tradedTokenAmount.decimalMultiply(ds.userOrders[matchingOrderIndex].price);
            // IERC20(_order.path[1]).transferFrom(_order.user, address(this), _txTokenAmount);
            minusFromTokenBalance(_order.user, _order.path[1], _txTokenAmount);
            _txTokenFee = calculateFees(_txTokenAmount);
            // IERC20(_order.path[0]).transfer(_order.user, _tradedTokenAmount.decimalSubtraction(_tradedTokenFees));
            // IERC20(_order.path[1]).transfer(ds.userOrders[matchingOrderIndex].user, _txTokenAmount.decimalSubtraction(_txTokenFee));
            addToTokenBalance(_order.user, _order.path[0], _tradedTokenAmount.decimalSubtraction(_tradedTokenFees));
            addToTokenBalance(
                ds.userOrders[matchingOrderIndex].user,
                _order.path[1],
                _txTokenAmount.decimalSubtraction(_txTokenFee)
            );

            _order.maxFee = _order.maxFee.decimalAddition(_tradedTokenFees);
            ds.userOrders[matchingOrderIndex].maxFee = ds.userOrders[matchingOrderIndex].maxFee.decimalAddition(
                _txTokenFee
            );
        }
        if (_order.orderType == OrderBookStorage.OrderType.SELL) {
            // IERC20(_order.path[0]).transferFrom(_order.user, address(this), _tradedTokenAmount);
            minusFromTokenBalance(_order.user, _order.path[0], _tradedTokenAmount);
            uint256 _txTokenDepositedAmount = _tradedTokenAmount.decimalMultiply(
                ds.userOrders[matchingOrderIndex].price
            );
            _txTokenAmount = _tradedTokenAmount.decimalMultiply(_order.price);
            _txTokenFee = calculateFees(_txTokenAmount);
            // IERC20(_order.path[1]).transfer(_order.user, _txTokenAmount.decimalSubtraction(_txTokenFee));
            // IERC20(_order.path[1]).transfer(ds.userOrders[matchingOrderIndex].user, _txTokenDepositedAmount.decimalSubtraction(_txTokenAmount));
            // IERC20(_order.path[0]).transfer(ds.userOrders[matchingOrderIndex].user, _tradedTokenAmount.decimalSubtraction(_tradedTokenFees));

            addToTokenBalance(_order.user, _order.path[1], _txTokenAmount.decimalSubtraction(_txTokenFee));
            addToTokenBalance(
                ds.userOrders[matchingOrderIndex].user,
                _order.path[1],
                _txTokenDepositedAmount.decimalSubtraction(_txTokenAmount)
            );
            addToTokenBalance(
                ds.userOrders[matchingOrderIndex].user,
                _order.path[0],
                _tradedTokenAmount.decimalSubtraction(_tradedTokenFees)
            );

            _order.maxFee = _order.maxFee.decimalAddition(_txTokenFee);
            ds.userOrders[matchingOrderIndex].maxFee = ds.userOrders[matchingOrderIndex].maxFee.decimalAddition(
                _tradedTokenFees
            );
        }

        // IERC20(_order.path[0]).transfer(ds.tradeFeeTo, _tradedTokenFees);
        // IERC20(_order.path[1]).transfer(ds.tradeFeeTo, _txTokenFee);

        addToTokenBalance(ds.tradeFeeTo, _order.path[0], _tradedTokenFees);
        addToTokenBalance(ds.tradeFeeTo, _order.path[1], _txTokenFee);
    }

    /**
     * @dev This internal function adds entry into buy order book or sell order book for unfulfilled orders or unfulfilled matches.
     */
    function createMakerOffer(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _newOrderId,
        uint256 _price
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        uint256 prevOrderId = findSortedIndex(_orderType, _pairName, _price);

        if (_orderType == OrderBookStorage.OrderType.BUY) {
            ds.buyOrders[_pairName][_newOrderId] = ds.buyOrders[_pairName][prevOrderId];
            ds.buyOrders[_pairName][prevOrderId] = _newOrderId;
            ds.buyOrdersLength++;
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            ds.sellOrders[_pairName][_newOrderId] = ds.sellOrders[_pairName][prevOrderId];
            ds.sellOrders[_pairName][prevOrderId] = _newOrderId;
            ds.sellOrdersLength++;
        }
    }

    /**
     * @dev This internal function removes an existing open buy or sell offer from buy order book or sell order book.
     * This is Internal function.
     */
    function removeMatchedOffer(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _prevOrderId,
        uint256 _orderIdToBeRemoved
    ) internal {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            ds.sellOrders[_pairName][_prevOrderId] = ds.sellOrders[_pairName][_orderIdToBeRemoved];
            ds.sellOrders[_pairName][_orderIdToBeRemoved] = 0;
            ds.sellOrdersLength--;
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            ds.buyOrders[_pairName][_prevOrderId] = ds.buyOrders[_pairName][_orderIdToBeRemoved];
            ds.buyOrders[_pairName][_orderIdToBeRemoved] = 0;
            ds.buyOrdersLength--;
        }
    }

    /**
     * @dev This internal function calculates fee for traded amount
     */
    function calculateFees(uint256 _amount) internal view returns (uint256) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        return _amount.decimalMultiply(ds.tradeFee);
    }

    /**
     * @dev This internal function checks in OTBSwap Liquidity provider for full match of the Buy or Sell trade.
     */
    function checkLiquidityProviderMatch(
        OrderBookStorage.OrderType _orderType,
        address[] memory _path,
        uint256 _tradedTokenAmount,
        uint256 _txTokenAmount
    ) internal view returns (bool) {
        require(hasPair(_path[0], _path[1]), 'Pair does not exist');

        if (_orderType == OrderBookStorage.OrderType.BUY) {
            (uint256 reserveA, uint256 reserveB, ) = IOTBSwapPair(IOTBSwapFactory(factory).getPair(_path[0], _path[1]))
                .getReserves();
            if (IOTBSwapRouter02(router).getAmountOut(_txTokenAmount, reserveA, reserveB) >= _tradedTokenAmount) {
                return true;
            }
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            (uint256 reserveA, uint256 reserveB, ) = IOTBSwapPair(IOTBSwapFactory(factory).getPair(_path[0], _path[1]))
                .getReserves();
            if (IOTBSwapRouter02(router).getAmountOut(_tradedTokenAmount, reserveA, reserveB) >= _txTokenAmount) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev This internal function performs token swap using OTBSwap Swap liquidity provider
     */
    function performSwap(
        OrderBookStorage.OrderType _orderType,
        OrderBookStorage.UserOrder memory _order,
        uint256 _tradedTokenAmount,
        uint256 _txTokenAmount
    ) internal {
        address[] memory path = new address[](2);
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            // Since user already deposited on the contract, this is no longer needed.
            // IERC20(_path[1]).transferFrom(msg.sender, address(this), _txTokenAmount);

            path[1] = _order.path[0];
            IERC20(path[1]).approve(address(router), _txTokenAmount);
            performExactSwap(_order, _txTokenAmount, _tradedTokenAmount);
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            // Since user already deposited on the contract, this is no longer needed.
            // IERC20(_path[0]).transferFrom(msg.sender, address(this), _tradedTokenAmount);
            path[0] = _order.path[0];

            IERC20(path[0]).approve(address(router), _tradedTokenAmount);
            performExactSwap(_order, _tradedTokenAmount, _txTokenAmount);
        }
    }

    /**
     * @dev This internal function performs token swap using OTBSwap Swap liquidity provider
     */
    function performExactSwap(
        OrderBookStorage.UserOrder memory _order,
        uint256 _tokenInAmount,
        uint256 _tokenOutAmount
    ) internal {
        require(_order.path[0] != _order.path[1], 'Both In & out can not be same token');
        uint256 _tokenOutAmountWithFee = (_tokenInAmount * 1015) / 1000;
        if (_order.path[0] == IOTBSwapRouter02(router).WETH()) {
            IOTBSwapRouter02(router).swapExactETHForTokens(
                _tokenOutAmountWithFee,
                _order.path,
                address(this),
                block.timestamp + 1200
            );
            addToTokenBalance(_order.user, _order.path[1], _tokenOutAmount);
            IERC20(_order.path[1]).transferFrom(msg.sender, address(this), (_tokenOutAmountWithFee - _tokenOutAmount));
        } else if (_order.path[1] == IOTBSwapRouter02(router).WETH()) {
            IOTBSwapRouter02(router).swapExactTokensForETH(
                _tokenInAmount,
                _tokenOutAmountWithFee,
                _order.path,
                address(this),
                block.timestamp + 1200
            );
            addToTokenBalance(_order.user, _order.path[1], _tokenOutAmount);
            IERC20(_order.path[1]).transferFrom(msg.sender, address(this), (_tokenOutAmountWithFee - _tokenOutAmount));
        } else {
            IOTBSwapRouter02(router).swapExactTokensForTokens(
                _tokenInAmount,
                _tokenOutAmountWithFee,
                _order.path,
                address(this),
                block.timestamp + 1200
            );
            addToTokenBalance(_order.user, _order.path[1], _tokenOutAmount);
            IERC20(_order.path[1]).transferFrom(msg.sender, address(this), (_tokenOutAmountWithFee - _tokenOutAmount));
        }
    }

    /**
     * @dev This internal function sorts orders & returns index of insertion
     */
    function verifySortedIndex(
        OrderBookStorage.OrderType _orderType,
        uint256 _prevOrderId,
        uint256 _price,
        uint256 _nextOrderId
    ) internal view returns (bool) {
        require(_price > 0, 'Invalid price');
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            return
                (_prevOrderId == OrderBookStorage.ORDER_ID_OFFSET ||
                    ds.userOrders[_prevOrderId - OrderBookStorage.ORDER_ID_OFFSET].price >= _price) &&
                (_nextOrderId == OrderBookStorage.ORDER_ID_OFFSET ||
                    _price > ds.userOrders[_nextOrderId - OrderBookStorage.ORDER_ID_OFFSET].price);
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            return
                (_prevOrderId == OrderBookStorage.ORDER_ID_OFFSET ||
                    ds.userOrders[_prevOrderId - OrderBookStorage.ORDER_ID_OFFSET].price <= _price) &&
                (_nextOrderId == OrderBookStorage.ORDER_ID_OFFSET ||
                    _price < ds.userOrders[_nextOrderId - OrderBookStorage.ORDER_ID_OFFSET].price);
        }
        return false;
    }

    /**
     * @dev This internal function inserts entery post sorting into exact location
     */
    function findSortedIndex(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _price
    ) internal view returns (uint256 insertLocation) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        insertLocation = OrderBookStorage.ORDER_ID_OFFSET;
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            while (true) {
                if (verifySortedIndex(_orderType, insertLocation, _price, ds.buyOrders[_pairName][insertLocation])) {
                    return insertLocation;
                }
                insertLocation = ds.buyOrders[_pairName][insertLocation];
            }
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            while (true) {
                if (verifySortedIndex(_orderType, insertLocation, _price, ds.sellOrders[_pairName][insertLocation])) {
                    return insertLocation;
                }
                insertLocation = ds.sellOrders[_pairName][insertLocation];
            }
        }
    }

    /**
     * @dev This internal function locate exact previous location of any existing location
     */
    function isPrevOrderId(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _prevOrderId,
        uint256 _orderId
    ) internal view returns (bool) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            return ds.buyOrders[_pairName][_prevOrderId] == _orderId;
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            return ds.sellOrders[_pairName][_prevOrderId] == _orderId;
        }
        return false;
    }

    /**
     * @dev This internal function finds previous location of any existing location
     */
    function findPrevOrderId(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _orderId
    ) internal view returns (uint256 _currentOrderId) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        _currentOrderId = OrderBookStorage.ORDER_ID_OFFSET;
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            while (ds.buyOrders[_pairName][_currentOrderId] != OrderBookStorage.ORDER_ID_OFFSET) {
                if (isPrevOrderId(_orderType, _pairName, _currentOrderId, _orderId)) {
                    return _currentOrderId;
                }
                _currentOrderId = ds.buyOrders[_pairName][_currentOrderId];
            }
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            while (ds.sellOrders[_pairName][_currentOrderId] != OrderBookStorage.ORDER_ID_OFFSET) {
                if (isPrevOrderId(_orderType, _pairName, _currentOrderId, _orderId)) {
                    return _currentOrderId;
                }
                _currentOrderId = ds.sellOrders[_pairName][_currentOrderId];
            }
        }
    }

    /**
     * @dev This internal function finds next order id in orderbook
     */
    function findMatchedNextOrderId(
        OrderBookStorage.OrderType _orderType,
        bytes32 _pairName,
        uint256 _orderId
    ) internal view returns (uint256 nextOrderId) {
        OrderBookStorage.OrderBook storage ds = OrderBookStorage.orderBookStruct();
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            nextOrderId = ds.sellOrders[_pairName][_orderId];
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            nextOrderId = ds.buyOrders[_pairName][_orderId];
        }
    }

    /**
     * @dev This internal function checks price check comparison for Buy or Sell order
     */
    function checkPrice(
        OrderBookStorage.OrderType _orderType,
        uint256 _offerPrice,
        uint256 _tradePrice
    ) internal pure returns (bool) {
        if (_orderType == OrderBookStorage.OrderType.BUY && _offerPrice <= _tradePrice) {
            return true;
        }
        if (_orderType == OrderBookStorage.OrderType.SELL && _offerPrice >= _tradePrice) {
            return true;
        }
        return false;
    }

    /**
     * @dev This internal function raises trade event post all Buy & Sell order
     */
    function raiseTradeEvent(
        OrderBookStorage.OrderType _orderType,
        OrderBookStorage.MatchStatus _matchStatus,
        OrderBookStorage.UserOrder memory _order,
        uint256 _tradedAmount
    ) internal {
        if (_orderType == OrderBookStorage.OrderType.BUY) {
            emit BuyEvent(
                _order.pairName,
                _tradedAmount,
                _tradedAmount.decimalMultiply(_order.price),
                _order.price,
                _matchStatus
            );
        }
        if (_orderType == OrderBookStorage.OrderType.SELL) {
            emit SellEvent(
                _order.pairName,
                _tradedAmount,
                _tradedAmount.decimalMultiply(_order.price),
                _order.price,
                _matchStatus
            );
        }
    }