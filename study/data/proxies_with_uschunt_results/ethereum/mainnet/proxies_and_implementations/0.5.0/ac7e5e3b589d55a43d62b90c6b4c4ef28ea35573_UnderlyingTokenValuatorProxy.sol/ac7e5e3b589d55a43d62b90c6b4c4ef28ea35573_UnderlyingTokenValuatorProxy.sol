// File: @openzeppelin/upgrades/contracts/upgradeability/Proxy.sol

pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

// File: @openzeppelin/upgrades/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user //imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library OpenZeppelinUpgradesAddress {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/BaseUpgradeabilityProxy.sol

pragma solidity ^0.5.0;



/**
 * @title BaseUpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract BaseUpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
   * validated in the constructor.
   */
  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) internal {
    require(OpenZeppelinUpgradesAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/UpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title UpgradeabilityProxy
 * @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
 * implementation and init data.
 */
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Contract constructor.
   * @param _logic Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _logic, bytes memory _data) public payable {
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }
  }  
}

// File: @openzeppelin/upgrades/contracts/upgradeability/BaseAdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title BaseAdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {
  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
   * validated in the constructor.
   */

  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  /**
   * @return The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  /**
   * @dev Only fall back when the sender is not the admin.
   */
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}

// File: @openzeppelin/upgrades/contracts/upgradeability/AdminUpgradeabilityProxy.sol

pragma solidity ^0.5.0;


/**
 * @title AdminUpgradeabilityProxy
 * @dev Extends from BaseAdminUpgradeabilityProxy with a constructor for 
 * initializing the implementation, admin, and init data.
 */
contract AdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy, UpgradeabilityProxy {
  /**
   * Contract constructor.
   * @param _logic address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
    constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}

// File: contracts/protocol/interfaces/IUnderlyingTokenValuatorV5.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface IUnderlyingTokenValuatorV5 {

    // ============ Events ============

    event TokenInsertedOrUpdated(
        address indexed token,
        address indexed aggregator,
        address indexed quoteSymbol
    );

    // ============ Admin Functions ============

    function initialize(
        address owner,
        address guardian,
        address weth,
        address[] calldata tokens,
        address[] calldata chainlinkAggregators,
        address[] calldata quoteSymbols
    ) external;

    function insertOrUpdateOracleToken(
        address token,
        address chainlinkAggregator,
        address quoteSymbol
    ) external;

    // ============ Public Functions ============

    function weth() external view returns (address);

    function getAggregatorByToken(
        address token
    ) external view returns (address);

    function getQuoteSymbolByToken(
        address token
    ) external view returns (address);

    function getTokenValue(
        address token,
        uint amount
    ) external view returns (uint);

}

// File: contracts/protocol/impl/UnderlyingTokenValuatorProxy.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;



contract UnderlyingTokenValuatorProxy is AdminUpgradeabilityProxy {

    /**
     * @param logic                 The address of the initial implementation.
     * @param admin                 The address of the proxy administrator.
     * @param owner                 The address of the owner of the implementation contract.
     * @param guardian              The address of the guardian of the implementation contract.
     */
    constructor(
        address logic,
        address admin,
        address owner,
        address guardian,
        address weth,
        address[] memory tokens,
        address[] memory chainlinkAggregators,
        address[] memory quoteSymbols
    )
    AdminUpgradeabilityProxy(
        logic,
        admin,
        abi.encodePacked(
            IUnderlyingTokenValuatorV5(address(0)).initialize.selector,
            abi.encode(owner, guardian, weth, tokens, chainlinkAggregators, quoteSymbols)
        )
    )
    public {}

    function getImplementation() public view returns (address) {
        return _implementation();
    }

    function _willFallback() internal {
        // Don't call super. We want the admin to be able to call-through to the implementation contract
    }

}

pragma solidity ^0.5.0;


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
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @dev Gets the USD value of a currency with 8 decimals.
 */
interface IUsdAggregatorV2 {

    /**
     * @return The USD value of a currency, with 8 decimals.
     */
    function latestAnswer() external view returns (uint);

}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
interface IUnderlyingTokenValuator {

    /**
      * @dev Gets the tokens value in terms of USD.
      *
      * @return The value of the `amount` of `token`, as a number with the same number of decimals as `amount` passed
      *         in to this function.
      */
    function getTokenValue(address token, uint amount) external view returns (uint);

}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
interface IUnderlyingTokenValuatorV5 {

    // ============ Events ============

    event TokenInsertedOrUpdated(
        address indexed token,
        address indexed aggregator,
        address indexed quoteSymbol
    );

    // ============ Admin Functions ============

    function initialize(
        address owner,
        address guardian,
        address weth,
        address[] calldata tokens,
        address[] calldata chainlinkAggregators,
        address[] calldata quoteSymbols
    ) external;

    function insertOrUpdateOracleToken(
        address token,
        address chainlinkAggregator,
        address quoteSymbol
    ) external;

    // ============ Public Functions ============

    function weth() external view returns (address);

    function getAggregatorByToken(
        address token
    ) external view returns (address);

    function getQuoteSymbolByToken(
        address token
    ) external view returns (address);

    function getTokenValue(
        address token,
        uint amount
    ) external view returns (uint);

}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * NOTE:    THE STATE VARIABLES IN THIS CONTRACT CANNOT CHANGE NAME OR POSITION BECAUSE THIS CONTRACT IS USED IN
 *          UPGRADEABLE CONTRACTS.
 */
contract IOwnableOrGuardian is Initializable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);

    modifier onlyOwnerOrGuardian {
        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {
        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }
    // *********************************************
    // ***** State Variables DO NOT CHANGE OR MOVE
    // *********************************************

    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************
    address internal _owner;
    address internal _guardian;
    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************

    // ******************************
    // ***** Misc Functions
    // ******************************

    function owner() external view returns (address) {
        return _owner;
    }

    function guardian() external view returns (address) {
        return _guardian;
    }

    // ******************************
    // ***** Admin Functions
    // ******************************

    function initialize(
        address owner,
        address guardian
    ) public initializer {
        _transferOwnership(owner);
        _transferGuardian(guardian);
    }

    function transferOwnership(
        address owner
    )
    public
    onlyOwner {
        require(
            owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(owner);
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferGuardian(
        address guardian
    )
    public
    onlyOwner {
        require(
            guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {
        _transferGuardian(address(0));
    }

    // ******************************
    // ***** Internal Functions
    // ******************************

    function _transferOwnership(
        address owner
    )
    internal {
        address previousOwner = _owner;
        _owner = owner;
        emit OwnershipTransferred(previousOwner, owner);
    }

    function _transferGuardian(
        address guardian
    )
    internal {
        address previousGuardian = _guardian;
        _guardian = guardian;
        emit GuardianTransferred(previousGuardian, guardian);
    }

}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * NOTE:    THE STATE VARIABLES IN THIS CONTRACT CANNOT CHANGE NAME OR POSITION BECAUSE THIS CONTRACT IS USED IN
 *          UPGRADEABLE CONTRACTS.
 */
contract OwnableOrGuardian is IOwnableOrGuardian {

    constructor(
        address owner,
        address guardian
    ) public {
        IOwnableOrGuardian.initialize(owner, guardian);
    }

}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
contract UnderlyingTokenValuatorData is IOwnableOrGuardian {

    // ============ State Values ============

    address internal _weth;

    mapping(address => IUsdAggregatorV2) internal _tokenToAggregatorMap;

    // Defaults to USD if the value is the ZERO address
    mapping(address => address) internal _tokenToQuoteSymbolMap;

    // ============ Constants ============

    uint8 public constant CHAINLINK_USD_DECIMALS = 8;
    uint public constant CHAINLINK_USD_FACTOR = 10 ** uint(CHAINLINK_USD_DECIMALS);

    uint8 public constant CHAINLINK_ETH_DECIMALS = 18;
    uint public constant CHAINLINK_ETH_FACTOR = 10 ** uint(CHAINLINK_ETH_DECIMALS);

}

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
contract UnderlyingTokenValuatorImplV5 is IUnderlyingTokenValuator, IUnderlyingTokenValuatorV5, UnderlyingTokenValuatorData {

    using SafeMath for uint;

    /**
     * Note, these arrays are set up, such that each index corresponds with one-another.
     *
     * @param tokens                The tokens that are supported by this adapter.
     * @param chainlinkAggregators  The Chainlink aggregators that have on-chain prices.
     * @param quoteSymbols          The token against which this token's value is compared using the aggregator. The
     *                              zero address corresponds with USD.
     */
    function initialize(
        address owner,
        address guardian,
        address weth,
        address[] calldata tokens,
        address[] calldata chainlinkAggregators,
        address[] calldata quoteSymbols
    )
    external
    initializer {
        require(
            tokens.length == chainlinkAggregators.length,
            "UnderlyingTokenValuatorImplV5: INVALID_AGGREGATORS"
        );
        require(
            chainlinkAggregators.length == quoteSymbols.length,
            "UnderlyingTokenValuatorImplV5: INVALID_TOKEN_PAIRS"
        );

        IOwnableOrGuardian.initialize(owner, guardian);

        _weth = weth;

        for (uint i = 0; i < tokens.length; i++) {
            _insertOrUpdateOracleToken(tokens[i], chainlinkAggregators[i], quoteSymbols[i]);
        }
    }

    // ============ Admin Functions ============

    function insertOrUpdateOracleToken(
        address token,
        address chainlinkAggregator,
        address quoteSymbol
    )
    public
    onlyOwnerOrGuardian {
        _insertOrUpdateOracleToken(token, chainlinkAggregator, quoteSymbol);
    }

    // ============ Public Functions ============

    function weth() external view returns (address) {
        return _weth;
    }

    function getAggregatorByToken(
        address token
    ) external view returns (address) {
        return address(_tokenToAggregatorMap[token]);
    }

    function getQuoteSymbolByToken(
        address token
    ) external view returns (address) {
        return _tokenToQuoteSymbolMap[token];
    }

    function getTokenValue(
        address token,
        uint amount
    )
    public
    view
    returns (uint) {
        require(
            address(_tokenToAggregatorMap[token]) != address(0),
            "UnderlyingTokenValuatorImplV5::getTokenValue: INVALID_TOKEN"
        );

        uint chainlinkPrice = uint(_tokenToAggregatorMap[token].latestAnswer());
        address quoteSymbol = _tokenToQuoteSymbolMap[token];

        if (quoteSymbol == address(0)) {
            // The pair has a USD base, we are done.
            return amount.mul(chainlinkPrice).div(CHAINLINK_USD_FACTOR);
        } else if (quoteSymbol == _weth) {
            // The price we just got and converted is NOT against USD. So we need to get its pair's price against USD.
            // We can do so by recursively calling #getTokenValue using the `quoteSymbol` as the parameter instead of `token`.
            return getTokenValue(quoteSymbol, amount.mul(chainlinkPrice).div(CHAINLINK_ETH_FACTOR));
        } else {
            revert("UnderlyingTokenValuatorImplV5::getTokenValue: INVALID_QUOTE_SYMBOL");
        }
    }

    // ============ Internal Functions ============

    function _insertOrUpdateOracleToken(
        address token,
        address chainlinkAggregator,
        address quoteSymbol
    ) internal {
        _tokenToAggregatorMap[token] = IUsdAggregatorV2(chainlinkAggregator);
        if (quoteSymbol != address(0)) {
            // The aggregator's price is NOT against USD. Therefore, we need to store what it's against as well as the
            // # of decimals the aggregator's price has.
            _tokenToQuoteSymbolMap[token] = quoteSymbol;
        }
        emit TokenInsertedOrUpdated(token, chainlinkAggregator, quoteSymbol);
    }

}
}
