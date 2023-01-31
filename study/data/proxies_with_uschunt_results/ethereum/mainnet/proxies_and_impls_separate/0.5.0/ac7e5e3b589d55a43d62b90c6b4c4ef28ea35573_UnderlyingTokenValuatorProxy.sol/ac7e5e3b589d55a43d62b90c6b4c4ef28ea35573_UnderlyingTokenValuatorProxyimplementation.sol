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