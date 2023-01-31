


// : MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
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
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/utils/StorageSlot.sol';

//
//   ___ _ __ _ __ ___  _ __ ___
//  / _ \ '__| '__/ _ \| '__/ __|
// |  __/ |  | | | (_) | |  \__ \
//  \___|_|  |_|  \___/|_|  |___/
//
// P1 => Contract is not paused
// P2 => Contract is paused

/// @title Pausable
/// @author Iulian Rotaru
/// @notice Pausable logics, reading storage slot to retrieve pause state
contract Pausable {
  //
  //                      _              _
  //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
  //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
  // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
  //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
  //

  // Storage slot for the Paused state
  bytes32 internal constant _PAUSED_SLOT = 0x8dea8703c3cf94703383ce38a9c894669dccd4ca8e65ddb43267aa0248711450;

  //
  //                      _ _  __ _
  //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
  // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
  // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
  // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
  //

  // Allows methods to be called if paused
  modifier whenPaused() {
    require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == true, 'P1');
    _;
  }

  // Allows methods to be called if not paused
  modifier whenNotPaused() {
    require(StorageSlot.getBooleanSlot(_PAUSED_SLOT).value == false, 'P1');
    _;
  }
}





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

interface HegicOptionsManagerV8888 {
  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  function nextTokenId() external view returns (uint256);

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;
}





// : MIT

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





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

//
//   ___ _ __ _ __ ___  _ __ ___
//  / _ \ '__| '__/ _ \| '__/ __|
// |  __/ |  | | | (_) | |  \__ \
//  \___|_|  |_|  \___/|_|  |___/
//
// V1 => Already initializing
// V2 => Invalid version received. Expected current

/// @title Versioned
/// @author Iulian Rotaru
/// @notice Initialized for multiple versions
contract Versioned {
  //
  //      _        _
  //  ___| |_ __ _| |_ ___
  // / __| __/ _` | __/ _ \
  // \__ \ || (_| | ||  __/
  // |___/\__\__,_|\__\___|
  //

  // Stores the current implementation version
  uint256 version;

  // Stores the initializing state for each version
  bool private _initializing;

  //
  //                      _ _  __ _
  //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
  // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
  // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
  // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
  //

  // Allows to be called only if version number is current version + 1
  modifier initVersion(uint256 _version) {
    require(!_initializing, 'V1');
    require(_version == version + 1, 'V2');
    version = _version;

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }

  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  /// @dev Retrieves current implementation version
  /// @return Implementatiomn version
  function getVersion() public view returns (uint256) {
    return version;
  }
}





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/utils/StorageSlot.sol';

//
//   ___ _ __ _ __ ___  _ __ ___
//  / _ \ '__| '__/ _ \| '__/ __|
// |  __/ |  | | | (_) | |  \__ \
//  \___|_|  |_|  \___/|_|  |___/
//
// O1 => Caller is not admin

/// @title Owned
/// @author Iulian Rotaru
/// @notice Owner logics, reading storage slot to retrieve admin
contract Owned {
  //
  //                      _              _
  //   ___ ___  _ __  ___| |_ __ _ _ __ | |_ ___
  //  / __/ _ \| '_ \/ __| __/ _` | '_ \| __/ __|
  // | (_| (_) | | | \__ \ || (_| | | | | |_\__ \
  //  \___\___/|_| |_|___/\__\__,_|_| |_|\__|___/
  //

  // Storage slot for the Admin address
  bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  //
  //                      _ _  __ _
  //  _ __ ___   ___   __| (_)/ _(_) ___ _ __ ___
  // | '_ ` _ \ / _ \ / _` | | |_| |/ _ \ '__/ __|
  // | | | | | | (_) | (_| | |  _| |  __/ |  \__ \
  // |_| |_| |_|\___/ \__,_|_|_| |_|\___|_|  |___/
  //

  // Modifier allowing only admins to call methods
  modifier isAdmin() {
    require(StorageSlot.getAddressSlot(_ADMIN_SLOT).value == msg.sender, 'O1');
    _;
  }

  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  /// @dev Retrieves Admin address
  /// @return Admin address
  function getAdmin() public view returns (address) {
    return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
  }
}





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

interface HegicFacadeV8888 {
  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  function getOptionPrice(
    address pool,
    uint256 period,
    uint256 amount,
    uint256 strike,
    address[] calldata swappath
  )
    external
    view
    returns (
      uint256 total,
      uint256 baseTotal,
      uint256 settlementFee,
      uint256 premium
    );

  function createOption(
    address pool,
    uint256 period,
    uint256 amount,
    uint256 strike,
    address[] calldata swappath,
    uint256 acceptablePrice
  ) external;
}





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts/token/ERC20/IERC20.sol';

//import'../Owned.sol';

//
//   ___ _ __ _ __ ___  _ __ ___
//  / _ \ '__| '__/ _ \| '__/ __|
// |  __/ |  | | | (_) | |  \__ \
//  \___|_|  |_|  \___/|_|  |___/
//
// A1 => Useless call, not changing address
// A2 => Invalid currencies and amount length
// A3 => Received amount of ETH too low

/// @title Adapter
/// @author Iulian Rotaru
/// @notice Adapter base logics
abstract contract Adapter is Owned {
  address public gateway;

  modifier isGateway() {
    require(msg.sender == gateway, 'A1');
    _;
  }

  //
  //  _       _                        _
  // (_)_ __ | |_ ___ _ __ _ __   __ _| |___
  // | | '_ \| __/ _ \ '__| '_ \ / _` | / __|
  // | | | | | ||  __/ |  | | | | (_| | \__ \
  // |_|_| |_|\__\___|_|  |_| |_|\__,_|_|___/
  //

  /// @dev Changes gateway address
  /// @param newGateway Address of new gateway
  function setGateway(address newGateway) internal {
    require(gateway != newGateway, 'A1');
    gateway = newGateway;
  }

  /// @dev Perform an internal option purchase
  /// @param caller Address purchasing the option
  /// @param currencies List of usable currencies
  /// @param amounts List of usable currencies amounts
  /// @param data Extra data usable by adapter
  /// @return A tuple containing used amounts and output data
  function purchase(
    address caller,
    address[] memory currencies,
    uint256[] memory amounts,
    bytes calldata data
  ) internal virtual returns (uint256[] memory, bytes memory);

  function _preparePayment(address[] memory currencies, uint256[] memory amounts) internal {
    require(currencies.length == amounts.length, 'A2');
    for (uint256 currencyIdx = 0; currencyIdx < currencies.length; ++currencyIdx) {
      if (currencies[currencyIdx] == address(0)) {
        require(msg.value >= amounts[currencyIdx], 'A3');
      } else {
        IERC20(currencies[currencyIdx]).transferFrom(msg.sender, address(this), amounts[currencyIdx]);
      }
    }
  }

  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  /// @dev Perform an option purchase
  /// @param caller Address purchasing the option
  /// @param currencies List of usable currencies
  /// @param amounts List of usable currencies amounts
  /// @param data Extra data usable by adapter
  /// @return A tuple containing used amounts and output data
  function run(
    address caller,
    address[] memory currencies,
    uint256[] memory amounts,
    bytes calldata data
  ) external payable isGateway returns (uint256[] memory, bytes memory) {
    _preparePayment(currencies, amounts);
    return purchase(caller, currencies, amounts, data);
  }

  function name() external view virtual returns (string memory);
}





// : MIT
//  ______   ______     _____
// /\__  _\ /\  == \   /\  __-.
// \/_/\ \/ \ \  __<   \ \ \/\ \
//    \ \_\  \ \_____\  \ \____-
//     \/_/   \/_____/   \/____/
//
pragma solidity 0.8.6;

//import'@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';

//import'../../Versioned.sol';
//import'../../Pausable.sol';
//import'./interfaces/HegicFacade.8888.sol';
//import'./interfaces/HegicOptionsManager.8888.sol';
//import'../Adapter.sol';

//
//   ___ _ __ _ __ ___  _ __ ___
//  / _ \ '__| '__/ _ \| '__/ __|
// |  __/ |  | | | (_) | |  \__ \
//  \___|_|  |_|  \___/|_|  |___/
//
// Hegic8888AdapterV1_1  => Invalid data length received
// Hegic8888AdapterV1_2  => Expected only one currency
// Hegic8888AdapterV1_3  => Expected only one amount
// Hegic8888AdapterV1_4  => Not enough paid to purchase option

/// @title Hegic8888AdapterV1
/// @author Iulian Rotaru
/// @notice Adapter to purchase Hegic ETH or WBTC options
contract Hegic8888AdapterV1 is Versioned, Pausable, Adapter {
  //
  //      _        _
  //  ___| |_ __ _| |_ ___
  // / __| __/ _` | __/ _ \
  // \__ \ || (_| | ||  __/
  // |___/\__\__,_|\__\___|
  //

  HegicFacadeV8888 public facade;
  HegicOptionsManagerV8888 public optionsManager;

  //
  //  _       _                        _
  // (_)_ __ | |_ ___ _ __ _ __   __ _| |___
  // | | '_ \| __/ _ \ '__| '_ \ / _` | / __|
  // | | | | | ||  __/ |  | | | | (_| | \__ \
  // |_|_| |_|\__\___|_|  |_| |_|\__,_|_|___/
  //

  /// @dev Perform an option purchase
  /// @param caller Address purchasing the option
  /// @param currencies List of usable currencies
  /// @param amounts List of usable currencies amounts
  /// @param data Extra data usable by adapter
  /// @return _a A tuple containing used amounts and output data
  function purchase(
    address caller,
    address[] memory currencies,
    uint256[] memory amounts,
    bytes calldata data
  ) internal override returns (uint256[] memory, bytes memory) {
    require(data.length == 128, 'Hegic8888AdapterV1_1');
    require(currencies.length == 1, 'Hegic8888AdapterV1_2');
    require(amounts.length == 1, 'Hegic8888AdapterV1_3');
    uint256 _price;
    uint256 _tokenId;
    {
      address _pool;

      uint256[] memory _parameters = new uint256[](3);
      // uint256 _period;
      // uint256 _amount;
      // uint256 _strike;

      (_pool, _parameters[0], _parameters[1], _parameters[2]) = abi.decode(data, (address, uint256, uint256, uint256));

      (_price, , , ) = facade.getOptionPrice(_pool, _parameters[0], _parameters[1], _parameters[2], currencies);

      require(_price <= amounts[0], 'Hegic8888AdapterV1_4');

      IERC20(currencies[0]).approve(address(facade), _price);

      _tokenId = optionsManager.nextTokenId();
      facade.createOption(_pool, _parameters[0], _parameters[1], _parameters[2], currencies, _price);
      optionsManager.safeTransferFrom(address(this), caller, _tokenId);

      uint256 balance = IERC20(currencies[0]).balanceOf(address(this));

      if (balance > 0) {
        IERC20(currencies[0]).transfer(caller, balance);
      }
    }

    uint256[] memory usedAmount = new uint256[](1);
    usedAmount[0] = _price;

    return (usedAmount, abi.encode(_tokenId));
  }

  //
  //            _                        _
  //   _____  _| |_ ___ _ __ _ __   __ _| |___
  //  / _ \ \/ / __/ _ \ '__| '_ \ / _` | / __|
  // |  __/>  <| ||  __/ |  | | | | (_| | \__ \
  //  \___/_/\_\\__\___|_|  |_| |_|\__,_|_|___/
  //

  // solhint-disable-next-line
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external returns (bytes4) {
    return Hegic8888AdapterV1.onERC721Received.selector;
  }

  /// @dev Retrieve adapter name
  /// @return Adapter name
  function name() external pure override returns (string memory) {
    return 'Hegic8888V1';
  }

  //
  //  _       _ _
  // (_)_ __ (_) |_
  // | | '_ \| | __|
  // | | | | | | |_
  // |_|_| |_|_|\__|
  //

  // solhint-disable-next-line
  function __Hegic8888AdapterV1__constructor(
    address _gateway,
    address _facade,
    address _optionsManager
  ) public initVersion(1) {
    facade = HegicFacadeV8888(_facade);
    optionsManager = HegicOptionsManagerV8888(_optionsManager);
    setGateway(_gateway);
  }
}
