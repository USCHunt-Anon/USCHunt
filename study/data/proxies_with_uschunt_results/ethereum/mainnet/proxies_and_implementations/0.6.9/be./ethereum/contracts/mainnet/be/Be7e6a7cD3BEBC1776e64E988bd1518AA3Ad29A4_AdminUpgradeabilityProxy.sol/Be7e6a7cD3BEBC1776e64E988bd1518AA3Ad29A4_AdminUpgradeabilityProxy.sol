/**
 *Submitted for verification at Etherscan.io on 2021-02-15
*/

// File: contracts\proxy\Proxy.sol

// ////-License-Identifier: MIT
// https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/proxy/Proxy.sol

pragma solidity 0.6.9;

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  fallback () payable external {
    _fallback();
  }

  /**
   * @dev Receive function.
   * Implemented entirely in `_fallback`.
   */
  receive () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal virtual view returns (address);

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
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal virtual {
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

// File: @openzeppelin\contracts\utils\Address.sol


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

// File: contracts\proxy\UpgradeabilityProxy.sol

// https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/proxy/UpgradeabilityProxy.sol

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is Proxy {
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
   * @return impl Address of the current implementation
   */
  function _implementation() internal override view returns (address impl) {
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
    require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

// File: contracts\proxy\AdminUpgradeabilityProxy.sol

// https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/proxy/AdminUpgradeabilityProxy.sol

/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
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
   * @return adm The admin slot.
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
  function _willFallback() internal override virtual {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
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
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

/**
 * @title IBridgeAVM
 * @author Alexander Schlindwein
 */
interface IBridgeAVM {
    function initialize(address l1Exchange, address l2Exchange, address l2Factory) external;
    function receiveExchangeStaticVars(uint tradingFeeInvested) external;
    function receiveExchangePlatformVars(uint marketID, uint dai, uint invested, uint platformFeeInvested) external;
    function receiveExchangeTokenVars(uint marketID, uint[] calldata tokenIDs, string[] calldata names, uint[] calldata supplies, uint[] calldata dais, uint[] calldata investeds) external;
    function setTokenVars(uint marketID, uint[] calldata tokenID) external;
    function receiveIdeaTokenTransfer(uint marketID, uint tokenID, uint amount, address to) external;
}

// : MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

//import"./Ownable.sol";
//import"./IIdeaTokenExchange.sol";
//import"./IIdeaToken.sol";
//import"./IIdeaTokenFactory.sol";
//import"./IInterestManager.sol";
//import"./Initializable.sol";
//import"./IERC20.sol";
//import"./SafeMath.sol";

/**
 * @title IdeaTokenExchange
 * @author Alexander Schlindwein
 *
 * Exchanges Dai <-> IdeaTokens using a bonding curve. Sits behind a proxy
 */
contract IdeaTokenExchange is IIdeaTokenExchange, Initializable, Ownable {
    using SafeMath for uint256;

    // Stored for every IdeaToken and market.
    // Keeps track of the amount of invested dai in this token, and the amount of investment tokens (e.g. cDai).
    struct ExchangeInfo {
        // The amount of Dai collected by trading
        uint dai;
        // The amount of "investment tokens", e.g. cDai
        uint invested; 
    }

    uint constant FEE_SCALE = 10000;

    // The address authorized to set token and platform owners.
    // It is only allowed to change these when the current owner is not set (zero address).
    // Using such an address allows an external program to make authorization calls without having to go through the timelock.
    address _authorizer;

    // The amount of "investment tokens" for the collected trading fee, e.g. cDai 
    uint _tradingFeeInvested; 
    // The address which receives the trading fee when withdrawTradingFee is called
    address _tradingFeeRecipient;

    // marketID => owner. The owner of a platform.
    // This address is allowed to withdraw platform fee.
    // When allInterestToPlatform=true then this address can also withdraw the platform interest
    mapping(uint => address) _platformOwner;

    // marketID => amount. The amount of "investment tokens" for the collected platform fee, e.g. cDai
    mapping(uint => uint) _platformFeeInvested;
    

    // marketID => ExchangeInfo. Stores ExchangeInfo structs for platforms
    mapping(uint => ExchangeInfo) _platformsExchangeInfo;

    // IdeaToken address => owner. The owner of an IdeaToken.
    // This address is allowed to withdraw the interest for an IdeaToken
    mapping(address => address) _tokenOwner;
    // IdeaToken address => ExchangeInfo. Stores ExchangeInfo structs for IdeaTokens
    mapping(address => ExchangeInfo) _tokensExchangeInfo;

    // IdeaTokenFactory contract
    IIdeaTokenFactory _ideaTokenFactory;
    // InterestManager contract
    IInterestManager _interestManager;
    // Dai contract
    IERC20 _dai;

    // IdeaToken address => bool. Whether or not to disable all fee collection for a specific IdeaToken.
    mapping(address => bool) _tokenFeeKillswitch;

    event NewTokenOwner(address ideaToken, address owner);
    event NewPlatformOwner(uint marketID, address owner);

    event InvestedState(uint marketID, address ideaToken, uint dai, uint daiInvested, uint tradingFeeInvested, uint platformFeeInvested, uint volume);
    
    event PlatformInterestRedeemed(uint marketID, uint investmentToken, uint daiRedeemed);
    event TokenInterestRedeemed(address ideaToken, uint investmentToken, uint daiRedeemed);
    event TradingFeeRedeemed(uint daiRedeemed);
    event PlatformFeeRedeemed(uint marketID, uint daiRedeemed);
    
    /**
     * Initializes the contract
     *
     * @param owner The owner of the contract
     * @param tradingFeeRecipient The address of the recipient of the trading fee
     * @param interestManager The address of the InterestManager
     * @param dai The address of Dai
     */
    function initialize(address owner,
                        address authorizer,
                        address tradingFeeRecipient,
                        address interestManager,
                        address dai) external virtual initializer {
        require(authorizer != address(0) &&
                tradingFeeRecipient != address(0) &&
                interestManager != address(0) &&
                dai != address(0),
                "invalid-params");

        setOwnerInternal(owner); // Checks owner to be non-zero
        _authorizer = authorizer;
        _tradingFeeRecipient = tradingFeeRecipient;
        _interestManager = IInterestManager(interestManager);
        _dai = IERC20(dai);
    }

    /**
     * Burns IdeaTokens in exchange for Dai
     *
     * @param ideaToken The IdeaToken to sell
     * @param amount The amount of IdeaTokens to sell
     * @param minPrice The minimum allowed price in Dai for selling `amount` IdeaTokens
     * @param recipient The recipient of the redeemed Dai
     */
    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external virtual override {

        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        require(marketDetails.exists, "token-not-exist");
        uint marketID = marketDetails.id;

        CostAndPriceAmounts memory amounts = getPricesForSellingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]);

        require(amounts.total >= minPrice, "below-min-price");
        require(IIdeaToken(ideaToken).balanceOf(msg.sender) >= amount, "insufficient-tokens");
        
        IIdeaToken(ideaToken).burn(msg.sender, amount);

        _interestManager.accrueInterest();

        ExchangeInfo storage exchangeInfo;
        if(marketDetails.allInterestToPlatform) {
            exchangeInfo = _platformsExchangeInfo[marketID];
        } else {
            exchangeInfo = _tokensExchangeInfo[ideaToken];
        }

        uint tradingFeeInvested;
        uint platformFeeInvested;
        uint invested;
        uint dai;
        {
        uint totalRedeemed = _interestManager.redeem(address(this), amounts.total);
        uint tradingFeeRedeemed = _interestManager.underlyingToInvestmentToken(amounts.tradingFee);
        uint platformFeeRedeemed = _interestManager.underlyingToInvestmentToken(amounts.platformFee);

        invested = exchangeInfo.invested.sub(totalRedeemed.add(tradingFeeRedeemed).add(platformFeeRedeemed));
        exchangeInfo.invested = invested;
        tradingFeeInvested = _tradingFeeInvested.add(tradingFeeRedeemed);
        _tradingFeeInvested = tradingFeeInvested;
        platformFeeInvested = _platformFeeInvested[marketID].add(platformFeeRedeemed);
        _platformFeeInvested[marketID] = platformFeeInvested;
        dai = exchangeInfo.dai.sub(amounts.raw);
        exchangeInfo.dai = dai;
        }

        emit InvestedState(marketID, ideaToken, dai, invested, tradingFeeInvested, platformFeeInvested, amounts.raw);
        require(_dai.transfer(recipient, amounts.total), "dai-transfer");
    }


    /**
     * Returns the price for selling IdeaTokens
     *
     * @param ideaToken The IdeaToken to sell
     * @param amount The amount of IdeaTokens to sell
     *
     * @return The price in Dai for selling `amount` IdeaTokens
     */
    function getPriceForSellingTokens(address ideaToken, uint amount) external virtual view override returns (uint) {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        return getPricesForSellingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    /**
     * Calculates each price related to selling tokens
     *
     * @param marketDetails The market details
     * @param supply The existing supply of the IdeaToken
     * @param amount The amount of IdeaTokens to sell
     *
     * @return total cost, raw cost and trading fee
     */
    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public virtual pure override returns (CostAndPriceAmounts memory) {
        
        uint rawPrice = getRawPriceForSellingTokens(marketDetails.baseCost,
                                                    marketDetails.priceRise,
                                                    marketDetails.hatchTokens,
                                                    supply,
                                                    amount);

        uint tradingFee = 0;
        uint platformFee = 0;

        if(!feesDisabled) {
            tradingFee = rawPrice.mul(marketDetails.tradingFeeRate).div(FEE_SCALE);
            platformFee = rawPrice.mul(marketDetails.platformFeeRate).div(FEE_SCALE);
        }   
        
        uint totalPrice = rawPrice.sub(tradingFee).sub(platformFee);

        return CostAndPriceAmounts({
            total: totalPrice,
            raw: rawPrice,
            tradingFee: tradingFee,
            platformFee: platformFee
        });
    }

    /**
     * Returns the price for selling tokens without any fees applied
     *
     * @param baseCost The baseCost of the token
     * @param priceRise The priceRise of the token
     * @param hatchTokens The amount of hatch tokens
     * @param supply The current total supply of the token
     * @param amount The amount of IdeaTokens to sell
     *
     * @return The price selling `amount` IdeaTokens without any fees applied
     */
    function getRawPriceForSellingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal virtual pure returns (uint) {

        uint hatchPrice = 0;
        uint updatedAmount = amount;
        uint updatedSupply;

        if(supply.sub(amount) < hatchTokens) {

            if(supply <= hatchTokens) {
                return baseCost.mul(amount).div(10**18);
            }

            // No SafeMath required because supply - amount < hatchTokens
            uint tokensInHatch = hatchTokens - (supply - amount);
            hatchPrice = baseCost.mul(tokensInHatch).div(10**18);
            updatedAmount = amount.sub(tokensInHatch);
            // No SafeMath required because supply >= hatchTokens
            updatedSupply = supply - hatchTokens;
        } else {
            // No SafeMath required because supply >= hatchTokens
            updatedSupply = supply - hatchTokens;
        }

        uint priceAtSupply = baseCost.add(priceRise.mul(updatedSupply).div(10**18));
        uint priceAtSupplyMinusAmount = baseCost.add(priceRise.mul(updatedSupply.sub(updatedAmount)).div(10**18));
        uint average = priceAtSupply.add(priceAtSupplyMinusAmount).div(2);
    
        return hatchPrice.add(average.mul(updatedAmount).div(10**18));
    }

    /**
     * Mints IdeaTokens in exchange for Dai
     *
     * @param ideaToken The IdeaToken to buy
     * @param amount The amount of IdeaTokens to buy
     * @param fallbackAmount The fallback amount to buy in case the price changed
     * @param cost The maximum allowed cost in Dai
     * @param recipient The recipient of the bought IdeaTokens
     */
    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external virtual override {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);
        require(marketDetails.exists, "token-not-exist");
        uint marketID = marketDetails.id;

        uint supply = IERC20(ideaToken).totalSupply();
        bool feesDisabled = _tokenFeeKillswitch[ideaToken];
        uint actualAmount = amount;

        CostAndPriceAmounts memory amounts = getCostsForBuyingTokens(marketDetails, supply, actualAmount, feesDisabled);

        if(amounts.total > cost) {
            actualAmount = fallbackAmount;
            amounts = getCostsForBuyingTokens(marketDetails, supply, actualAmount, feesDisabled);
    
            require(amounts.total <= cost, "slippage");
        }

        
        require(_dai.allowance(msg.sender, address(this)) >= amounts.total, "insufficient-allowance");
        require(_dai.transferFrom(msg.sender, address(_interestManager), amounts.total), "dai-transfer");
        
        _interestManager.accrueInterest();
        _interestManager.invest(amounts.total);


        ExchangeInfo storage exchangeInfo;
        if(marketDetails.allInterestToPlatform) {
            exchangeInfo = _platformsExchangeInfo[marketID];
        } else {
            exchangeInfo = _tokensExchangeInfo[ideaToken];
        }

        exchangeInfo.invested = exchangeInfo.invested.add(_interestManager.underlyingToInvestmentToken(amounts.raw));
        uint tradingFeeInvested = _tradingFeeInvested.add(_interestManager.underlyingToInvestmentToken(amounts.tradingFee));
        _tradingFeeInvested = tradingFeeInvested;
        uint platformFeeInvested = _platformFeeInvested[marketID].add(_interestManager.underlyingToInvestmentToken(amounts.platformFee));
        _platformFeeInvested[marketID] = platformFeeInvested;
        exchangeInfo.dai = exchangeInfo.dai.add(amounts.raw);
    
        emit InvestedState(marketID, ideaToken, exchangeInfo.dai, exchangeInfo.invested, tradingFeeInvested, platformFeeInvested, amounts.total);
        IIdeaToken(ideaToken).mint(recipient, actualAmount);
    }

    /**
     * Returns the cost for buying IdeaTokens
     *
     * @param ideaToken The IdeaToken to buy
     * @param amount The amount of IdeaTokens to buy
     *
     * @return The cost in Dai for buying `amount` IdeaTokens
     */
    function getCostForBuyingTokens(address ideaToken, uint amount) external virtual view override returns (uint) {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByTokenAddress(ideaToken);

        return getCostsForBuyingTokens(marketDetails, IERC20(ideaToken).totalSupply(), amount, _tokenFeeKillswitch[ideaToken]).total;
    }

    /**
     * Calculates each cost related to buying tokens
     *
     * @param marketDetails The market details
     * @param supply The existing supply of the IdeaToken
     * @param amount The amount of IdeaTokens to buy
     *
     * @return total cost, raw cost, trading fee, platform fee
     */
    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public virtual pure override returns (CostAndPriceAmounts memory) {
        uint rawCost = getRawCostForBuyingTokens(marketDetails.baseCost,
                                                 marketDetails.priceRise,
                                                 marketDetails.hatchTokens,
                                                 supply,
                                                 amount);

        uint tradingFee = 0;
        uint platformFee = 0;

        if(!feesDisabled) {
            tradingFee = rawCost.mul(marketDetails.tradingFeeRate).div(FEE_SCALE);
            platformFee = rawCost.mul(marketDetails.platformFeeRate).div(FEE_SCALE);
        }
        
        uint totalCost = rawCost.add(tradingFee).add(platformFee);

        return CostAndPriceAmounts({
            total: totalCost,
            raw: rawCost,
            tradingFee: tradingFee,
            platformFee: platformFee
        });
    }

    /**
     * Returns the cost for buying tokens without any fees applied
     *
     * @param baseCost The baseCost of the token
     * @param priceRise The priceRise of the token
     * @param hatchTokens The amount of hatch tokens
     * @param supply The current total supply of the token
     * @param amount The amount of IdeaTokens to buy
     *
     * @return The cost buying `amount` IdeaTokens without any fees applied
     */
    function getRawCostForBuyingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal virtual pure returns (uint) {

        uint hatchCost = 0;
        uint updatedAmount = amount;
        uint updatedSupply;

        if(supply < hatchTokens) {
            // No SafeMath required because supply < hatchTokens
            uint remainingHatchTokens = hatchTokens - supply;

            if(amount <= remainingHatchTokens) {
                return baseCost.mul(amount).div(10**18);
            }

            hatchCost = baseCost.mul(remainingHatchTokens).div(10**18);
            updatedSupply = 0;
            // No SafeMath required because remainingHatchTokens < amount
            updatedAmount = amount - remainingHatchTokens;
        } else {
            // No SafeMath required because supply >= hatchTokens
            updatedSupply = supply - hatchTokens;
        }

        uint priceAtSupply = baseCost.add(priceRise.mul(updatedSupply).div(10**18));
        uint priceAtSupplyPlusAmount = baseCost.add(priceRise.mul(updatedSupply.add(updatedAmount)).div(10**18));
        uint average = priceAtSupply.add(priceAtSupplyPlusAmount).div(2);

        return hatchCost.add(average.mul(updatedAmount).div(10**18));
    }

    /**
     * Withdraws available interest for a publisher
     *
     * @param token The token from which the generated interest is to be withdrawn
     */
    function withdrawTokenInterest(address token) external virtual override {
        require(_tokenOwner[token] == msg.sender, "not-authorized");
        _interestManager.accrueInterest();

        uint interestPayable = getInterestPayable(token);
        if(interestPayable == 0) {
            return;
        }

        ExchangeInfo storage exchangeInfo = _tokensExchangeInfo[token];
        exchangeInfo.invested = exchangeInfo.invested.sub(_interestManager.redeem(msg.sender, interestPayable));

        emit TokenInterestRedeemed(token, exchangeInfo.invested, interestPayable);
    }

    /**
     * Returns the interest available to be paid out for a token
     *
     * @param token The token from which the generated interest is to be withdrawn
     *
     * @return The interest available to be paid out
     */
    function getInterestPayable(address token) public virtual view override returns (uint) {
        ExchangeInfo storage exchangeInfo = _tokensExchangeInfo[token];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    /**
     * Sets an address as owner of a token, allowing the address to withdraw interest
     *
     * @param token The token for which to authorize an address
     * @param owner The address to be set as owner
     */
    function setTokenOwner(address token, address owner) external virtual override {
        address sender = msg.sender;
        address current = _tokenOwner[token];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");

        _tokenOwner[token] = owner;

        emit NewTokenOwner(token, owner);
    }

    /**
     * Withdraws available interest for a platform
     *
     * @param marketID The market id from which the generated interest is to be withdrawn
     */
    function withdrawPlatformInterest(uint marketID) external virtual override {
        address sender = msg.sender;

        require(_platformOwner[marketID] == sender, "not-authorized");
        _interestManager.accrueInterest();

        uint platformInterestPayable = getPlatformInterestPayable(marketID);
        if(platformInterestPayable == 0) {
            return;
        }

        ExchangeInfo storage exchangeInfo = _platformsExchangeInfo[marketID];
        exchangeInfo.invested = exchangeInfo.invested.sub(_interestManager.redeem(sender, platformInterestPayable));

        emit PlatformInterestRedeemed(marketID, exchangeInfo.invested, platformInterestPayable);
    }

    /**
     * Returns the interest available to be paid out for a platform
     *
     * @param marketID The market id from which the generated interest is to be withdrawn
     *
     * @return The interest available to be paid out
     */
    function getPlatformInterestPayable(uint marketID) public virtual view override returns (uint) {
        ExchangeInfo storage exchangeInfo = _platformsExchangeInfo[marketID];
        return _interestManager.investmentTokenToUnderlying(exchangeInfo.invested).sub(exchangeInfo.dai);
    }

    /**
     * Withdraws available platform fee
     *
     * @param marketID The market from which the generated platform fee is to be withdrawn
     */
    function withdrawPlatformFee(uint marketID) external virtual override {
        address sender = msg.sender;
    
        require(_platformOwner[marketID] == sender, "not-authorized");
        _interestManager.accrueInterest();

        uint platformFeePayable = getPlatformFeePayable(marketID);
        if(platformFeePayable == 0) {
            return;
        }

        _platformFeeInvested[marketID] = 0;
        _interestManager.redeem(sender, platformFeePayable);

        emit PlatformFeeRedeemed(marketID, platformFeePayable);
    }

    /**
     * Returns the platform fee available to be paid out
     *
     * @param marketID The market from which the generated interest is to be withdrawn
     *
     * @return The platform fee available to be paid out
     */
    function getPlatformFeePayable(uint marketID) public virtual view override returns (uint) {
        return _interestManager.investmentTokenToUnderlying(_platformFeeInvested[marketID]);
    }

    /**
     * Authorizes an address as owner of a platform/market, which is allowed to withdraw platform fee and platform interest
     *
     * @param marketID The market for which to authorize an address
     * @param owner The address to be authorized
     */
    function setPlatformOwner(uint marketID, address owner) external virtual override {
        address sender = msg.sender;
        address current = _platformOwner[marketID];

        require((current == address(0) && (sender == _owner || sender == _authorizer)) ||
                (current != address(0) && (sender == _owner || sender == current)),
                "not-authorized");
        
        _platformOwner[marketID] = owner;

        emit NewPlatformOwner(marketID, owner);
    }

    /**
     * Withdraws available trading fee
     */
    function withdrawTradingFee() external virtual override {

        uint invested = _tradingFeeInvested;
        if(invested == 0) {
            return;
        }

        _interestManager.accrueInterest();

        _tradingFeeInvested = 0;
        uint redeem = _interestManager.investmentTokenToUnderlying(invested);
        _interestManager.redeem(_tradingFeeRecipient, redeem);

        emit TradingFeeRedeemed(redeem);
    }

    /**
     * Returns the trading fee available to be paid out
     *
     * @return The trading fee available to be paid out
     */
    function getTradingFeePayable() public virtual view override returns (uint) {
        return _interestManager.investmentTokenToUnderlying(_tradingFeeInvested);
    }

    /**
     * Sets the authorizer address
     *
     * @param authorizer The new authorizer address
     */
    function setAuthorizer(address authorizer) external virtual override onlyOwner {
        require(authorizer != address(0), "invalid-params");
        _authorizer = authorizer;
    }

    /**
     * Returns whether or not fees are disabled for a specific IdeaToken
     *
     * @param ideaToken The IdeaToken
     *
     * @return Whether or not fees are disabled for a specific IdeaToken
     */
    function isTokenFeeDisabled(address ideaToken) external virtual view override returns (bool) {
        return _tokenFeeKillswitch[ideaToken];
    }

    /**
     * Sets the fee killswitch for an IdeaToken
     *
     * @param ideaToken The IdeaToken
     * @param set Whether or not to enable the killswitch
     */
    function setTokenFeeKillswitch(address ideaToken, bool set) external virtual override onlyOwner {
        _tokenFeeKillswitch[ideaToken] = set;
    }

    /**
     * Sets the IdeaTokenFactory address. Only required once for deployment
     *
     * @param factory The address of the IdeaTokenFactory 
     */
    function setIdeaTokenFactoryAddress(address factory) external virtual onlyOwner {
        require(address(_ideaTokenFactory) == address(0));
        _ideaTokenFactory = IIdeaTokenFactory(factory);
    }
}

// : MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

//import"./IIdeaTokenExchangeStateTransfer.sol";
//import"./IdeaTokenExchange.sol"; 
//import"./IBridgeAVM.sol";
//import"./IInbox.sol";

/**
 * @title IdeaTokenExchangeStateTransfer
 * @author Alexander Schlindwein
 *
 * Replaces the L1 IdeaTokenExchange logic for the state transfer to Arbitrum L2.
 * 
 * This implementation will disable all state-altering methods and adds state transfer
 * methods which can be called by a transfer manager EOA. State transfer methods will call 
 * Arbitrum's Inbox contract to execute a transaction on L2.
 */
contract IdeaTokenExchangeStateTransfer is IdeaTokenExchange, IIdeaTokenExchangeStateTransfer {

    uint __gapStateTransfer__;

    // EOA which is allowed to manage the state transfer
    address public _transferManager;
    // Address of the BridgeAVM contract on L2
    address public _l2Bridge;
    // Address of Arbitrum's Inbox contract on L1
    IInbox public _l1Inbox;
    // Switch to enable token transfers once the initial state transfer is complete
    bool public _tokenTransferEnabled;

    event StaticVarsTransferred();
    event PlatformVarsTransferred(uint marketID);
    event TokenVarsTransferred(uint marketID, uint tokenID);
    event TokensTransferred(uint marketID, uint tokenID, address user, uint amount, address recipient);
    event TokenTransferEnabled();

    modifier onlyTransferManager {
        require(msg.sender == _transferManager, "only-transfer-manager");
        _;
    }

    /**
     * Initializes the contract's variables.
     *
     * @param transferManager EOA which is allowed to manage the state transfer
     * @param l2Bridge Address of the BridgeAVM contract on L2
     * @param l1Inbox Address of Arbitrum's Inbox contract on L1
     */
    function initializeStateTransfer(address transferManager, address l2Bridge, address l1Inbox) external override {
        require(_transferManager == address(0), "already-init");
        require(transferManager != address(0) && l2Bridge != address(0) &&  l1Inbox != address(0), "invalid-args");

        _transferManager = transferManager;
        _l2Bridge = l2Bridge;
        _l1Inbox = IInbox(l1Inbox);
    }

    /**
     * Transfers _tradingFeeInvested to L2.
     *
     * @param l2GasPriceBid Gas price for the L2 tx
     *
     * @return L1 -> L2 tx ticket id
     */
    function transferStaticVars(uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {
        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangeStaticVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, _tradingFeeInvested);
        
        uint ticketID = sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emit StaticVarsTransferred();

        return ticketID;
    }

    /**
     * Transfers a market's state to L2.
     *
     * @param marketID The ID of the market
     * @param l2GasPriceBid Gas price for the L2 tx
     *
     * @return L1 -> L2 tx ticket id
     */
    function transferPlatformVars(uint marketID, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByID(marketID);
        require(marketDetails.exists, "not-exist");

        ExchangeInfo memory exchangeInfo = _platformsExchangeInfo[marketID];

        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangePlatformVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, exchangeInfo.dai, exchangeInfo.invested, _platformFeeInvested[marketID]);
        
        uint ticketID = sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emit PlatformVarsTransferred(marketID);

        return ticketID;
    }

    /**
     * Transfers token's state to L2.
     *
     * @param marketID The ID of the tokens' market
     * @param tokenIDs The IDs of the tokens
     * @param l2GasPriceBid Gas price for the L2 tx
     *
     * @return L1 -> L2 tx ticket id
     */
    function transferTokenVars(uint marketID, uint[] calldata tokenIDs, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override onlyTransferManager returns (uint) {
        {
        MarketDetails memory marketDetails = _ideaTokenFactory.getMarketDetailsByID(marketID);
        require(marketDetails.exists, "market-not-exist");
        }

        (string[] memory names, uint[] memory supplies, uint[] memory dais, uint[] memory investeds) = makeTokenStateArraysInternal(marketID, tokenIDs);        

        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveExchangeTokenVars.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, tokenIDs, names, supplies, dais, investeds);

        return sendL2TxInternal(l2Bridge, msg.sender, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);
    }

    // Stack too deep
    function makeTokenStateArraysInternal(uint marketID, uint[] memory tokenIDs) internal returns (string[] memory, uint[] memory, uint[] memory, uint[] memory) {
        uint length = tokenIDs.length;
        require(length > 0, "length-0");

        string[] memory names = new string[](length);
        uint[] memory supplies = new uint[](length);
        uint[] memory dais = new uint[](length);
        uint[] memory investeds = new uint[](length);

        for(uint i = 0; i < length; i++) {

            uint tokenID = tokenIDs[i];
            {
            TokenInfo memory tokenInfo = _ideaTokenFactory.getTokenInfo(marketID, tokenID);
            require(tokenInfo.exists, "token-not-exist");

            IIdeaToken ideaToken = tokenInfo.ideaToken;
            ExchangeInfo memory exchangeInfo = _tokensExchangeInfo[address(ideaToken)];
            
            names[i] = tokenInfo.name;
            supplies[i] = ideaToken.totalSupply();
            dais[i] = exchangeInfo.dai;
            investeds[i] = exchangeInfo.invested;
            }

            emit TokenVarsTransferred(marketID, tokenID);
        }

        return (names, supplies, dais, investeds);
    }

    /**
     * Transfers an user's IdeaTokens to L2.
     *
     * @param marketID The ID of the token's market
     * @param tokenID The ID of the token
     * @param l2Recipient The address of the recipient on L2
     * @param l2GasPriceBid Gas price for the L2 tx
     *
     * @return L1 -> L2 tx ticket id
     */
    function transferIdeaTokens(uint marketID, uint tokenID, address l2Recipient, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable override returns (uint) {
        
        require(_tokenTransferEnabled, "not-enabled");
        require(l2Recipient != address(0), "zero-addr");

        TokenInfo memory tokenInfo = _ideaTokenFactory.getTokenInfo(marketID, tokenID);
        require(tokenInfo.exists, "not-exists");

        IIdeaToken ideaToken = tokenInfo.ideaToken;
        uint balance = ideaToken.balanceOf(msg.sender);
        require(balance > 0, "no-balance");

        ideaToken.burn(msg.sender, balance);
        
        address l2Bridge = _l2Bridge;
        bytes4 selector = IBridgeAVM(l2Bridge).receiveIdeaTokenTransfer.selector;
        bytes memory cdata = abi.encodeWithSelector(selector, marketID, tokenID, balance, l2Recipient);
        
        uint ticketID = sendL2TxInternal(l2Bridge, l2Recipient, gasLimit, maxSubmissionCost, l2GasPriceBid, cdata);

        emitTokensTransferredEventInternal(marketID, tokenID, balance, l2Recipient);
    
        return ticketID;
    }

    // Stack too deep
    function emitTokensTransferredEventInternal(uint marketID, uint tokenID, uint balance, address l2Recipient) internal {
        emit TokensTransferred(marketID, tokenID, msg.sender, balance, l2Recipient); 
    }

    /**
     * Enables transferIdeaTokens to be called.
     */
    function setTokenTransferEnabled() external override onlyTransferManager {
        _tokenTransferEnabled = true;

        emit TokenTransferEnabled();
    }

    function sendL2TxInternal(address to, address refund, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid, bytes memory cdata) internal returns (uint) {
        require(gasLimit > 0 && maxSubmissionCost > 0 && l2GasPriceBid > 0, "l2-gas");
        require(msg.value == maxSubmissionCost.add(gasLimit.mul(l2GasPriceBid)), "value");

        return _l1Inbox.createRetryableTicket{value: msg.value}(
            to,                     // L2 destination
            0,                      // value
            maxSubmissionCost,      // maxSubmissionCost
            refund,                 // submission refund address
            refund,                 // value refund address
            gasLimit,               // max gas
            l2GasPriceBid,          // gas price bid
            cdata                   // L2 calldata
        );
    }

    /* **********************************************
     * ************  Disabled functions  ************
     * ********************************************** 
     */

    function initialize(address owner, address authorizer, address tradingFeeRecipient, address interestManager, address dai) external override {
        owner; authorizer; tradingFeeRecipient; interestManager; dai;
        revert("x");
    }

    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external override {
        ideaToken; amount; minPrice; recipient;
        revert("x");
    }

    function getPriceForSellingTokens(address ideaToken, uint amount) external view override returns (uint) {
        ideaToken; amount;
        revert("x");
    }

    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {
        marketDetails; supply; amount; feesDisabled;
        revert("x");
    }

    function getRawPriceForSellingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure override returns (uint) {
        baseCost; priceRise; hatchTokens; supply; amount;
        revert("x");
    }

    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external override {
        ideaToken; amount; fallbackAmount; cost; recipient;
        revert("x");
    }

    function getCostForBuyingTokens(address ideaToken, uint amount) external view override returns (uint) {
        ideaToken; amount;
        revert("x");
    }

    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) public pure override returns (CostAndPriceAmounts memory) {
        marketDetails; supply; amount; feesDisabled;
        revert("x");
    }

    function getRawCostForBuyingTokens(uint baseCost, uint priceRise, uint hatchTokens, uint supply, uint amount) internal pure override returns (uint) {
        baseCost; priceRise; hatchTokens; supply; amount;
        revert("x");
    }

    function withdrawTokenInterest(address token) external override {
        token;
        revert("x");
    }

    function getInterestPayable(address token) public view override returns (uint) {
        token;
        revert("x");
    }

    function setTokenOwner(address token, address owner) external virtual override {
        token; owner;
        revert("x");
    }

    function withdrawPlatformInterest(uint marketID) external override {
        marketID;
        revert("x");
    }

    function getPlatformInterestPayable(uint marketID) public view override returns (uint) {
        marketID;
        revert("x");
    }

    function withdrawPlatformFee(uint marketID) external override {
        marketID;
        revert("x");
    }

    function getPlatformFeePayable(uint marketID) public view override returns (uint) {
        marketID;
        revert("x");
    }

    function setPlatformOwner(uint marketID, address owner) external override {
        marketID; owner;
        revert("x");
    }

    function withdrawTradingFee() external override {
        revert("x");
    }

    function getTradingFeePayable() public view override returns (uint) {
        revert("x");
    }

    function setAuthorizer(address authorizer) external override {
        authorizer;
        revert("x");
    }

    function isTokenFeeDisabled(address ideaToken) external view override returns (bool) {
        ideaToken;
        revert("x");
    }

    function setTokenFeeKillswitch(address ideaToken, bool set) external override {
        ideaToken; set;
        revert("x");
    }

    function setIdeaTokenFactoryAddress(address factory) external override {
        factory;
        revert("x");
    }
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

// : MIT
pragma solidity 0.6.9;

//import"./IERC20.sol";

/**
 * @title IIdeaToken
 * @author Alexander Schlindwein
 */
interface IIdeaToken is IERC20 {
    function initialize(string calldata __name, address owner) external;
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

// : MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

//import"./IIdeaTokenFactory.sol";

/**
 * @title IIdeaTokenExchange
 * @author Alexander Schlindwein
 */

struct CostAndPriceAmounts {
    uint total;
    uint raw;
    uint tradingFee;
    uint platformFee;
interface IIdeaTokenExchange {
    function sellTokens(address ideaToken, uint amount, uint minPrice, address recipient) external;
    function getPriceForSellingTokens(address ideaToken, uint amount) external view returns (uint);
    function getPricesForSellingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);
    function buyTokens(address ideaToken, uint amount, uint fallbackAmount, uint cost, address recipient) external;
    function getCostForBuyingTokens(address ideaToken, uint amount) external view returns (uint);
    function getCostsForBuyingTokens(MarketDetails memory marketDetails, uint supply, uint amount, bool feesDisabled) external pure returns (CostAndPriceAmounts memory);
    function setTokenOwner(address ideaToken, address owner) external;
    function setPlatformOwner(uint marketID, address owner) external;
    function withdrawTradingFee() external;
    function withdrawTokenInterest(address token) external;
    function withdrawPlatformInterest(uint marketID) external;
    function withdrawPlatformFee(uint marketID) external;
    function getInterestPayable(address token) external view returns (uint);
    function getPlatformInterestPayable(uint marketID) external view returns (uint);
    function getPlatformFeePayable(uint marketID) external view returns (uint);
    function getTradingFeePayable() external view returns (uint);
    function setAuthorizer(address authorizer) external;
    function isTokenFeeDisabled(address ideaToken) external view returns (bool);
    function setTokenFeeKillswitch(address ideaToken, bool set) external;
}

// : MIT
pragma solidity 0.6.9;

/**
 * @title IIdeaTokenExchangeStateTransfer
 * @author Alexander Schlindwein
 */
interface IIdeaTokenExchangeStateTransfer {
    function initializeStateTransfer(address transferManager, address l2InterestManager, address l1Inbox) external;
    function transferStaticVars(uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);
    function transferPlatformVars(uint marketID, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);
    function transferTokenVars(uint marketID, uint[] calldata tokenIDs, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);
    function transferIdeaTokens(uint marketID, uint tokenID, address l2Recipient, uint gasLimit, uint maxSubmissionCost, uint l2GasPriceBid) external payable returns (uint);
    function setTokenTransferEnabled() external;


// : MIT
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

//import"./IERC20.sol";
//import"./IIdeaToken.sol";
//import"./IIdeaTokenNameVerifier.sol";

/**
 * @title IIdeaTokenFactory
 * @author Alexander Schlindwein
 */

struct IDPair {
    bool exists;
    uint marketID;
    uint tokenID;
}

struct TokenInfo {
    bool exists;
    uint id;
    string name;
    IIdeaToken ideaToken;
}

struct MarketDetails {
    bool exists;
    uint id;
    string name;

    IIdeaTokenNameVerifier nameVerifier;
    uint numTokens;

    uint baseCost;
    uint priceRise;
    uint hatchTokens;
    uint tradingFeeRate;
    uint platformFeeRate;

    bool allInterestToPlatform;
}

interface IIdeaTokenFactory {
    function addMarket(string calldata marketName, address nameVerifier,
                       uint baseCost, uint priceRise, uint hatchTokens,
                       uint tradingFeeRate, uint platformFeeRate, bool allInterestToPlatform) external;

    function addToken(string calldata tokenName, uint marketID, address lister) external;

    function isValidTokenName(string calldata tokenName, uint marketID) external view returns (bool);
    function getMarketIDByName(string calldata marketName) external view returns (uint);
    function getMarketDetailsByID(uint marketID) external view returns (MarketDetails memory);
    function getMarketDetailsByName(string calldata marketName) external view returns (MarketDetails memory);
    function getMarketDetailsByTokenAddress(address ideaToken) external view returns (MarketDetails memory);
    function getNumMarkets() external view returns (uint);
    function getTokenIDByName(string calldata tokenName, uint marketID) external view returns (uint);
    function getTokenInfo(uint marketID, uint tokenID) external view returns (TokenInfo memory);
    function getTokenIDPair(address token) external view returns (IDPair memory);
    function setTradingFee(uint marketID, uint tradingFeeRate) external;
    function setPlatformFee(uint marketID, uint platformFeeRate) external;
    function setNameVerifier(uint marketID, address nameVerifier) external;
}

// : MIT
pragma solidity 0.6.9;

/**
 * @title IIdeaTokenNameVerifier
 * @author Alexander Schlindwein
 *
 * Interface for token name verifiers
 */
interface IIdeaTokenNameVerifier {
    function verifyTokenName(string calldata name) external pure returns (bool);
}

// : MIT
// See https://github.com/OffchainLabs/arbitrum/blob/develop/packages/arb-bridge-eth/contracts/bridge/interfaces/IInbox.sol

pragma solidity 0.6.9;

/**
 * @title IInbox
 * @author Alexander Schlindwein
 */
interface IInbox {
    function createRetryableTicket(
        address destAddr,
        uint256 arbTxCallValue,
        uint256 maxSubmissionCost,
        address submissionRefundAddress,
        address valueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);
}

// : MIT
pragma solidity 0.6.9;

/**
 * @title IInterestManager
 * @author Alexander Schlindwein
 */
interface IInterestManager {
    function invest(uint amount) external returns (uint);
    function redeem(address recipient, uint amount) external returns (uint);
    function redeemInvestmentToken(address recipient, uint amount) external returns (uint);
    function donateInterest(uint amount) external;
    function redeemDonated(uint amount) external;
    function accrueInterest() external;
    function underlyingToInvestmentToken(uint underlyingAmount) external view returns (uint);
    function investmentTokenToUnderlying(uint investmentTokenAmount) external view returns (uint);
}

// : MIT
// https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/core/contracts/Initializable.sol

pragma solidity 0.6.9;


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
    require(initializing || isConstructor() || !initialized, "already-initialized");

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

// : MIT
pragma solidity 0.6.9;

/**
 * @title Ownable
 * @author Alexander Schlindwein
 *
 * @dev Implements only-owner functionality
 */
contract Ownable {

    address _owner;

    event OwnershipChanged(address oldOwner, address newOwner);

    modifier onlyOwner {
        require(_owner == msg.sender, "only-owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        setOwnerInternal(newOwner);
    }

    function setOwnerInternal(address newOwner) internal {
        require(newOwner != address(0), "zero-addr");

        address oldOwner = _owner;
        _owner = newOwner;

        emit OwnershipChanged(oldOwner, newOwner);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }
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