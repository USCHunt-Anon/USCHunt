pragma solidity >=0.7.0;

interface IPermanentStorage {
    function wethAddr() external view returns (address);

    function getCurvePoolInfo(
        address _makerAddr,
        address _takerAssetAddr,
        address _makerAssetAddr
    )
        external
        view
        returns (
            int128 takerAssetIndex,
            int128 makerAssetIndex,
            uint16 swapMethod,
            bool supportGetDx
        );

    function setCurvePoolInfo(
        address _makerAddr,
        address[] calldata _underlyingCoins,
        address[] calldata _coins,
        bool _supportGetDx
    ) external;

    function isTransactionSeen(bytes32 _transactionHash) external view returns (bool); // Kept for backward compatability. Should be removed from AMM 5.2.1 upward

    function isAMMTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isRFQTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderTransactionSeen(bytes32 _transactionHash) external view returns (bool);

    function isLimitOrderAllowFillSeen(bytes32 _allowFillHash) external view returns (bool);

    function isRelayerValid(address _relayer) external view returns (bool);

    function setTransactionSeen(bytes32 _transactionHash) external; // Kept for backward compatability. Should be removed from AMM 5.2.1 upward

    function setAMMTransactionSeen(bytes32 _transactionHash) external;

    function setRFQTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderTransactionSeen(bytes32 _transactionHash) external;

    function setLimitOrderAllowFillSeen(bytes32 _allowFillHash) external;

    function setRelayersValid(address[] memory _relayers, bool[] memory _isValids) external;
}


pragma solidity ^0.7.6;

library PSStorage {
    bytes32 private constant STORAGE_SLOT = 0x92dd52b981a2dd69af37d8a3febca29ed6a974aede38ae66e4ef773173aba471;

    struct Storage {
        address ammWrapperAddr;
        address pmmAddr;
        address wethAddr;
        address rfqAddr;
        address limitOrderAddr;
        address l2DepositAddr;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.storage.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library AMMWrapperStorage {
    bytes32 private constant STORAGE_SLOT = 0xd38d862c9fa97c2fa857a46e08022d272a3579c114ca4f335f1e5fcb692c045e;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
        // curve pool => underlying token address => underlying token index
        mapping(address => mapping(address => int128)) curveTokenIndexes;
        mapping(address => bool) relayerValid;
        // 5.1.0 appended storage
        // curve pool => wrapped token address => wrapped token index
        mapping(address => mapping(address => int128)) curveWrappedTokenIndexes;
        mapping(address => bool) curveSupportGetDx;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.ammwrapper.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library RFQStorage {
    bytes32 private constant STORAGE_SLOT = 0x9174e76494cfb023ddc1eb0effb6c12e107165382bbd0ecfddbc38ea108bbe52;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.rfq.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}

library LimitOrderStorage {
    bytes32 private constant STORAGE_SLOT = 0xb1b5d1092eed9d9f9f6bdd5bf9fe04f7537770f37e1d84ac8960cc3acb80615c;

    struct Storage {
        mapping(bytes32 => bool) transactionSeen;
        mapping(bytes32 => bool) allowFillSeen;
    }

    /// @dev Get the storage bucket for this contract.
    function getStorage() internal pure returns (Storage storage stor) {
        assert(STORAGE_SLOT == bytes32(uint256(keccak256("permanent.limitorder.storage")) - 1));
        bytes32 slot = STORAGE_SLOT;

        // Dip into assembly to change the slot pointed to by the local
        // variable `stor`.
        // See https://solidity.readthedocs.io/en/v0.6.8/assembly.html?highlight=slot#access-to-external-variables-functions-and-libraries
        assembly {
            stor.slot := slot
        }
    }
}


// : MIT
pragma solidity 0.7.6;

//import"./interfaces/IPermanentStorage.sol";
//import"./utils/PSStorage.sol";

contract PermanentStorage is IPermanentStorage {
    // Constants do not have storage slot.
    bytes32 public constant curveTokenIndexStorageId = 0xf4c750cdce673f6c35898d215e519b86e3846b1f0532fb48b84fe9d80f6de2fc; // keccak256("curveTokenIndex")
    bytes32 public constant transactionSeenStorageId = 0x695d523b8578c6379a2121164fd8de334b9c5b6b36dff5408bd4051a6b1704d0; // keccak256("transactionSeen")
    bytes32 public constant relayerValidStorageId = 0x2c97779b4deaf24e9d46e02ec2699240a957d92782b51165b93878b09dd66f61; // keccak256("relayerValid")
    bytes32 public constant allowFillSeenStorageId = 0x808188d002c47900fbb4e871d29754afff429009f6684806712612d807395dd8; // keccak256("allowFillSeen")

    // New supported Curve pools
    address public constant CURVE_renBTC_POOL = 0x93054188d876f558f4a66B2EF1d97d16eDf0895B;
    address public constant CURVE_sBTC_POOL = 0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714;
    address public constant CURVE_hBTC_POOL = 0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F;
    address public constant CURVE_sETH_POOL = 0xc5424B857f758E906013F3555Dad202e4bdB4567;

    // Curve coins
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private constant renBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    address private constant wBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant sBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;
    address private constant hBTC = 0x0316EB71485b0Ab14103307bf65a021042c6d380;
    address private constant sETH = 0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb;

    // Below are the variables which consume storage slots.
    address public operator;
    string public version; // Current version of the contract
    mapping(bytes32 => mapping(address => bool)) private permission;

    // Operator events
    event TransferOwnership(address newOperator);
    event SetPermission(bytes32 storageId, address role, bool enabled);
    event UpgradeAMMWrapper(address newAMMWrapper);
    event UpgradePMM(address newPMM);
    event UpgradeRFQ(address newRFQ);
    event UpgradeLimitOrder(address newLimitOrder);
    event UpgradeWETH(address newWETH);
    event SetCurvePoolInfo(address makerAddr, address[] underlyingCoins, address[] coins, bool supportGetD);
    event SetRelayerValid(address relayer, bool valid);

    /************************************************************
     *          Access control and ownership management          *
     *************************************************************/
    modifier onlyOperator() {
        require(operator == msg.sender, "PermanentStorage: not the operator");
        _;
    }

    modifier validRole(bool _enabled, address _role) {
        if (_enabled) {
            require(
                (_role == operator) || (_role == ammWrapperAddr()) || (_role == pmmAddr()) || (_role == rfqAddr()) || (_role == limitOrderAddr()),
                "PermanentStorage: not a valid role"
            );
        }
        _;
    }

    modifier isPermitted(bytes32 _storageId, address _role) {
        require(permission[_storageId][_role], "PermanentStorage: has no permission");
        _;
    }

    function transferOwnership(address _newOperator) external onlyOperator {
        require(_newOperator != address(0), "PermanentStorage: operator can not be zero address");
        operator = _newOperator;

        emit TransferOwnership(_newOperator);
    }

    /// @dev Set permission for entity to write certain storage.
    function setPermission(
        bytes32 _storageId,
        address _role,
        bool _enabled
    ) external onlyOperator validRole(_enabled, _role) {
        permission[_storageId][_role] = _enabled;

        emit SetPermission(_storageId, _role, _enabled);
    }

    /************************************************************
     *              Constructor and init functions               *
     *************************************************************/
    /// @dev Replacing constructor and initialize the contract. This function should only be called once.
    function initialize(address _operator) external {
        require(keccak256(abi.encodePacked(version)) == keccak256(abi.encodePacked("")), "PermanentStorage: not upgrading from empty");
        require(_operator != address(0), "PermanentStorage: operator can not be zero address");
        operator = _operator;

        // Upgrade version
        version = "5.3.0";
    }

    /************************************************************
     *                     Getter functions                      *
     *************************************************************/
    function hasPermission(bytes32 _storageId, address _role) external view returns (bool) {
        return permission[_storageId][_role];
    }

    function ammWrapperAddr() public view returns (address) {
        return PSStorage.getStorage().ammWrapperAddr;
    }

    function pmmAddr() public view returns (address) {
        return PSStorage.getStorage().pmmAddr;
    }

    function rfqAddr() public view returns (address) {
        return PSStorage.getStorage().rfqAddr;
    }

    function limitOrderAddr() public view returns (address) {
        return PSStorage.getStorage().limitOrderAddr;
    }

    function wethAddr() external view override returns (address) {
        return PSStorage.getStorage().wethAddr;
    }

    function getCurvePoolInfo(
        address _makerAddr,
        address _takerAssetAddr,
        address _makerAssetAddr
    )
        external
        view
        override
        returns (
            int128 takerAssetIndex,
            int128 makerAssetIndex,
            uint16 swapMethod,
            bool supportGetDx
        )
    {
        // underlying_coins
        int128 i = AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][_takerAssetAddr];
        int128 j = AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][_makerAssetAddr];
        supportGetDx = AMMWrapperStorage.getStorage().curveSupportGetDx[_makerAddr];

        swapMethod = 0;
        if (i != 0 && j != 0) {
            // in underlying_coins list
            takerAssetIndex = i;
            makerAssetIndex = j;
            // exchange_underlying
            swapMethod = 2;
        } else {
            // in coins list
            int128 iWrapped = AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][_takerAssetAddr];
            int128 jWrapped = AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][_makerAssetAddr];
            if (iWrapped != 0 && jWrapped != 0) {
                takerAssetIndex = iWrapped;
                makerAssetIndex = jWrapped;
                // exchange
                swapMethod = 1;
            } else {
                revert("PermanentStorage: invalid pair");
            }
        }
        return (takerAssetIndex, makerAssetIndex, swapMethod, supportGetDx);
    }

    /* 
    NOTE: `isTransactionSeen` is replaced by `isAMMTransactionSeen`. It is kept for backward compatability.
    It should be removed from AMM 5.2.1 upward.
    */
    function isTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isAMMTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isRFQTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return RFQStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isLimitOrderTransactionSeen(bytes32 _transactionHash) external view override returns (bool) {
        return LimitOrderStorage.getStorage().transactionSeen[_transactionHash];
    }

    function isLimitOrderAllowFillSeen(bytes32 _allowFillHash) external view override returns (bool) {
        return LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash];
    }

    function isRelayerValid(address _relayer) external view override returns (bool) {
        return AMMWrapperStorage.getStorage().relayerValid[_relayer];
    }

    /************************************************************
     *           Management functions for Operator               *
     *************************************************************/
    /// @dev Update AMMWrapper contract address.
    function upgradeAMMWrapper(address _newAMMWrapper) external onlyOperator {
        PSStorage.getStorage().ammWrapperAddr = _newAMMWrapper;

        emit UpgradeAMMWrapper(_newAMMWrapper);
    }

    /// @dev Update PMM contract address.
    function upgradePMM(address _newPMM) external onlyOperator {
        PSStorage.getStorage().pmmAddr = _newPMM;

        emit UpgradePMM(_newPMM);
    }

    /// @dev Update RFQ contract address.
    function upgradeRFQ(address _newRFQ) external onlyOperator {
        PSStorage.getStorage().rfqAddr = _newRFQ;

        emit UpgradeRFQ(_newRFQ);
    }

    /// @dev Update Limit Order contract address.
    function upgradeLimitOrder(address _newLimitOrder) external onlyOperator {
        PSStorage.getStorage().limitOrderAddr = _newLimitOrder;

        emit UpgradeLimitOrder(_newLimitOrder);
    }

    /// @dev Update WETH contract address.
    function upgradeWETH(address _newWETH) external onlyOperator {
        PSStorage.getStorage().wethAddr = _newWETH;

        emit UpgradeWETH(_newWETH);
    }

    /************************************************************
     *                   External functions                      *
     *************************************************************/
    function setCurvePoolInfo(
        address _makerAddr,
        address[] calldata _underlyingCoins,
        address[] calldata _coins,
        bool _supportGetDx
    ) external override isPermitted(curveTokenIndexStorageId, msg.sender) {
        int128 underlyingCoinsLength = int128(_underlyingCoins.length);
        for (int128 i = 0; i < underlyingCoinsLength; i++) {
            address assetAddr = _underlyingCoins[uint256(i)];
            // underlying coins for original DAI, USDC, TUSD
            AMMWrapperStorage.getStorage().curveTokenIndexes[_makerAddr][assetAddr] = i + 1; // Start the index from 1
        }

        int128 coinsLength = int128(_coins.length);
        for (int128 i = 0; i < coinsLength; i++) {
            address assetAddr = _coins[uint256(i)];
            // wrapped coins for cDAI, cUSDC, yDAI, yUSDC, yTUSD, yBUSD
            AMMWrapperStorage.getStorage().curveWrappedTokenIndexes[_makerAddr][assetAddr] = i + 1; // Start the index from 1
        }

        AMMWrapperStorage.getStorage().curveSupportGetDx[_makerAddr] = _supportGetDx;
        emit SetCurvePoolInfo(_makerAddr, _underlyingCoins, _coins, _supportGetDx);
    }

    /* 
    NOTE: `setTransactionSeen` is replaced by `setAMMTransactionSeen`. It is kept for backward compatability.
    It should be removed from AMM 5.2.1 upward.
    */
    function setTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!AMMWrapperStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        AMMWrapperStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setAMMTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!AMMWrapperStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        AMMWrapperStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setRFQTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!RFQStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        RFQStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setLimitOrderTransactionSeen(bytes32 _transactionHash) external override isPermitted(transactionSeenStorageId, msg.sender) {
        require(!LimitOrderStorage.getStorage().transactionSeen[_transactionHash], "PermanentStorage: transaction seen before");
        LimitOrderStorage.getStorage().transactionSeen[_transactionHash] = true;
    }

    function setLimitOrderAllowFillSeen(bytes32 _allowFillHash) external override isPermitted(allowFillSeenStorageId, msg.sender) {
        require(!LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash], "PermanentStorage: allow fill seen before");
        LimitOrderStorage.getStorage().allowFillSeen[_allowFillHash] = true;
    }

    function setRelayersValid(address[] calldata _relayers, bool[] calldata _isValids) external override isPermitted(relayerValidStorageId, msg.sender) {
        require(_relayers.length == _isValids.length, "PermanentStorage: inputs length mismatch");
        for (uint256 i = 0; i < _relayers.length; i++) {
            AMMWrapperStorage.getStorage().relayerValid[_relayers[i]] = _isValids[i];
            emit SetRelayerValid(_relayers[i], _isValids[i]);
        }
    }
}


