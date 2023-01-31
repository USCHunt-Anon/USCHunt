



// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

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














// ////-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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















// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

//import './Proxy.sol';
//import '@openzeppelin/contracts/utils/Address.sol';

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












// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

//import './UpgradeabilityProxy.sol';

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


// : GPL-3.0-or-later

pragma solidity ^0.6.12;

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

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-zero");
        z = x / y;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    }
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

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

// : MIT

pragma solidity ^0.6.0;

/// @dev The non-empty constructor is conflict with upgrades-openzeppelin. 

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
contract ReentrancyGuard {
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

    // NOTE: _NOT_ENTERED is set to ZERO such that it needn't constructor
    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    uint256 private _status;

    // constructor () internal {
    //     _status = _NOT_ENTERED;
    // }

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
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

//import"../lib/SafeERC20.sol";


interface INestMining {
    
    struct Params {
        uint8    miningEthUnit;     // = 10;
        uint32   nestStakedNum1k;   // = 1;
        uint8    biteFeeRate;       // = 1; 
        uint8    miningFeeRate;     // = 10;
        uint8    priceDurationBlock; 
        uint8    maxBiteNestedLevel; // = 3;
        uint8    biteInflateFactor;
        uint8    biteNestInflateFactor;
    }

    function priceOf(address token) external view returns(uint256 ethAmount, uint256 tokenAmount, uint256 bn);
    
    function priceListOfToken(address token, uint8 num) external view returns(uint128[] memory data, uint256 bn);

    // function priceOfTokenAtHeight(address token, uint64 atHeight) external view returns(uint256 ethAmount, uint256 tokenAmount, uint64 bn);

    function latestPriceOf(address token) external view returns (uint256 ethAmount, uint256 tokenAmount, uint256 bn);

    function priceAvgAndSigmaOf(address token) 
        external view returns (uint128, uint128, int128, uint32);

    function minedNestAmount() external view returns (uint256);

    /// @dev Only for governance
    function loadContracts() external; 
    
    function loadGovernance() external;

    function upgrade() external;

    function setup(uint32   genesisBlockNumber, uint128  latestMiningHeight, uint128  minedNestTotalAmount, Params calldata initParams) external;

    function setParams1(uint128  latestMiningHeight, uint128  minedNestTotalAmount) external;
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

interface INToken {
    // mint ntoken for value
    function mint(uint256 amount, address account) external;

    // the block height where the ntoken was created
    function checkBlockInfo() external view returns(uint256 createBlock, uint256 recentlyUsedBlock);
    // the owner (auction winner) of the ntoken
    function checkBidder() external view returns(address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

//import"../lib/SafeERC20.sol";

interface INestPool {

    // function getNTokenFromToken(address token) view external returns (address);
    // function setNTokenToToken(address token, address ntoken) external; 

    function addNest(address miner, uint256 amount) external;
    function addNToken(address contributor, address ntoken, uint256 amount) external;

    function depositEth(address miner) external payable;
    function depositNToken(address miner,  address from, address ntoken, uint256 amount) external;

    function freezeEth(address miner, uint256 ethAmount) external; 
    function unfreezeEth(address miner, uint256 ethAmount) external;

    function freezeNest(address miner, uint256 nestAmount) external;
    function unfreezeNest(address miner, uint256 nestAmount) external;

    function freezeToken(address miner, address token, uint256 tokenAmount) external; 
    function unfreezeToken(address miner, address token, uint256 tokenAmount) external;

    function freezeEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;
    function unfreezeEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;

    function getNTokenFromToken(address token) external view returns (address); 
    function setNTokenToToken(address token, address ntoken) external; 

    function withdrawEth(address miner, uint256 ethAmount) external;
    function withdrawToken(address miner, address token, uint256 tokenAmount) external;

    function withdrawNest(address miner, uint256 amount) external;
    function withdrawEthAndToken(address miner, uint256 ethAmount, address token, uint256 tokenAmount) external;
    // function withdrawNToken(address miner, address ntoken, uint256 amount) external;
    function withdrawNTokenAndTransfer(address miner, address ntoken, uint256 amount, address to) external;


    function balanceOfNestInPool(address miner) external view returns (uint256);
    function balanceOfEthInPool(address miner) external view returns (uint256);
    function balanceOfTokenInPool(address miner, address token)  external view returns (uint256);

    function addrOfNestToken() external view returns (address);
    function addrOfNestMining() external view returns (address);
    function addrOfNTokenController() external view returns (address);
    function addrOfNNRewardPool() external view returns (address);
    function addrOfNNToken() external view returns (address);
    function addrOfNestStaking() external view returns (address);
    function addrOfNestQuery() external view returns (address);
    function addrOfNestDAO() external view returns (address);

    function addressOfBurnedNest() external view returns (address);

    function setGovernance(address _gov) external; 
    function governance() external view returns(address);
    function initNestLedger(uint256 amount) external;
    function drainNest(address to, uint256 amount, address gov) external;

}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

interface INestDAO {

    function addETHReward(address ntoken) external payable; 

    function addNestReward(uint256 amount) external;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external;
    
    /// @dev Only for governance
    function start() external; 

    function initEthLedger(address ntoken, uint256 amount) external;

    event NTokenRedeemed(address ntoken, address user, uint256 amount);

    event AssetsCollected(address user, uint256 ethAmount, uint256 nestAmount);

    event ParamsSetup(address gov, uint256 oldParam, uint256 newParam);

    event FlagSet(address gov, uint256 flag);

}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;


interface INestStaking {
    // Views

    /// @dev How many stakingToken (XToken) deposited into to this reward pool (staking pool)
    /// @param  ntoken The address of NToken
    /// @return The total amount of XTokens deposited in this staking pool
    function totalStaked(address ntoken) external view returns (uint256);

    /// @dev How many stakingToken (XToken) deposited by the target account
    /// @param  ntoken The address of NToken
    /// @param  account The target account
    /// @return The total amount of XToken deposited in this staking pool
    function stakedBalanceOf(address ntoken, address account) external view returns (uint256);


    // Mutative
    /// @dev Stake/Deposit into the reward pool (staking pool)
    /// @param  ntoken The address of NToken
    /// @param  amount The target amount
    function stake(address ntoken, uint256 amount) external;

    function stakeFromNestPool(address ntoken, uint256 amount) external;

    /// @dev Withdraw from the reward pool (staking pool), get the original tokens back
    /// @param  ntoken The address of NToken
    /// @param  amount The target amount
    function unstake(address ntoken, uint256 amount) external;

    /// @dev Claim the reward the user earned
    /// @param ntoken The address of NToken
    /// @return The amount of ethers as rewards
    function claim(address ntoken) external returns (uint256);

    /// @dev Add ETH reward to the staking pool
    /// @param ntoken The address of NToken
    function addETHReward(address ntoken) external payable;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external; 

    function pause() external;

    function resume() external;

    //function setParams(uint8 dividendShareRate) external;

    /* ========== EVENTS ========== */

    // Events
    event RewardAdded(address ntoken, address sender, uint256 reward);
    event NTokenStaked(address ntoken, address indexed user, uint256 amount);
    event NTokenUnstaked(address ntoken, address indexed user, uint256 amount);
    event SavingWithdrawn(address ntoken, address indexed to, uint256 amount);
    event RewardClaimed(address ntoken, address indexed user, uint256 reward);

    event FlagSet(address gov, uint256 flag);
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

/// @title The interface of NestQuery
/// @author Inf Loop - <inf-loop@nestprotocol.org>
/// @author Paradox  - <paradox@nestprotocol.org>
interface INestQuery {

    /// @notice Activate a pay-per-query defi client with NEST tokens
    /// @dev No contract is allowed to call it
    /// @param defi The addres of client (DeFi DApp)
    function activate(address defi) external;

    /// @notice Deactivate a pay-per-query defi client
    /// @param defi The address of a client (DeFi DApp)
    function deactivate(address defi) external;

    /// @notice Query for PPQ (pay-per-query) clients
    /// @dev Consider that if a user call a DeFi that queries NestQuery, DeFi should
    ///     pass the user's wallet address to query() as `payback`.
    /// @param token The address of token contract
    /// @param payback The address of change
    function query(address token, address payback) 
        external payable returns (uint256, uint256, uint256);

    /// @notice Query for PPQ (pay-per-query) clients
    /// @param token The address of token contract
    /// @param payback The address of change
    /// @return ethAmount The amount of ETH in pair (ETH, TOKEN)
    /// @return tokenAmount The amount of TOKEN in pair (ETH, TOKEN)
    /// @return avgPrice The average of last 50 prices 
    /// @return vola The volatility of prices 
    /// @return bn The block number when (ETH, TOKEN) takes into effective
    function queryPriceAvgVola(address token, address payback) 
        external payable returns (uint256, uint256, uint128, int128, uint256);

    /// @notice The main function called by DeFi clients, compatible to Nest Protocol v3.0 
    /// @dev  The payback address is ZERO, so the changes are kept in this contract
    ///         The ABI keeps consist with Nest v3.0
    /// @param tokenAddress The address of token contract address
    /// @return ethAmount The amount of ETH in price pair (ETH, ERC20)
    /// @return erc20Amount The amount of ERC20 in price pair (ETH, ERC20)
    /// @return blockNum The block.number where the price is being in effect
    function updateAndCheckPriceNow(address tokenAddress) 
        external payable returns (uint256, uint256, uint256);

    /// @notice A non-free function for querying price 
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @param payback The address for change
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function queryPriceList(address token, uint8 num, address payback) 
        external payable returns (uint128[] memory);

    /// @notice A view function returning the historical price list from the current block
    /// @param token  The address of the token contract
    /// @param num    The number of price sheets in the list
    /// @return The array of prices, each of which is (blockNnumber, ethAmount, tokenAmount)
    function priceList(address token, uint8 num) 
        external view returns (uint128[] memory);

    /// @notice A view function returning the latestPrice
    /// @param token  The address of the token contract
    function latestPrice(address token)
    external view returns (uint256 ethAmount, uint256 tokenAmount, uint128 avgPrice, int128 vola, uint256 bn) ;

    /// @dev Only for governance
    function loadContracts() external; 

    /// @dev Only for governance
    function loadGovernance() external; 


    event ClientActivated(address, uint256, uint256);
    // event ClientRenewed(address, uint256, uint256, uint256);
    event PriceQueried(address client, address token, uint256 ethAmount, uint256 tokenAmount, uint256 bn);
    event PriceAvgVolaQueried(address client, address token, uint256 bn, uint128 avgPrice, int128 vola);

    event PriceListQueried(address client, address token, uint256 bn, uint8 num);

    // governance events
    event ParamsSetup(address gov, uint256 oldParams, uint256 newParams);
    event FlagSet(address gov, uint256 flag);
}

// : GPL-3.0-or-later

pragma solidity 0.6.12;

//import"./Address.sol";
//import"./SafeMath.sol";

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// : GPL-3.0-or-later

pragma solidity 0.6.12;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// : GPL-3.0-or-later

pragma solidity ^0.6.12;

//import"./lib/SafeMath.sol";
//import"./lib/TransferHelper.sol";
//import"./lib/ReentrancyGuard.sol";


//import"./iface/INestMining.sol";
//import"./iface/INToken.sol";
//import"./iface/INestPool.sol";
//import"./iface/INestDAO.sol";
//import"./iface/INestStaking.sol";
//import"./iface/INestQuery.sol";

// //import"hardhat/console.sol";

/// @dev The contract is for redeeming nest token and getting ETH in return
contract NestDAO is INestDAO, ReentrancyGuard {

    using SafeMath for uint256;

    /* ========== STATE ============== */

    uint8 public flag; 

    /// @dev the block height where DAO was started
    uint32  public startedBlock;
    uint32  public lastCollectingBlock;
    uint184 private _reserved;

    uint8 constant DAO_FLAG_UNINITIALIZED    = 0;
    uint8 constant DAO_FLAG_INITIALIZED      = 1;
    uint8 constant DAO_FLAG_ACTIVE           = 2;
    uint8 constant DAO_FLAG_NO_STAKING       = 3;
    uint8 constant DAO_FLAG_PAUSED           = 4;
    uint8 constant DAO_FLAG_SHUTDOWN         = 127;

    struct Ledger {
        uint128 rewardedAmount;
        uint128 redeemedAmount;
        uint128 quotaAmount;
        uint32  lastBlock;
        uint96  _reserved;
    }

    /// @dev Mapping from ntoken => amount (of ntokens owned by DAO)
    mapping(address => Ledger) public ntokenLedger;

    /// @dev Mapping from ntoken => amount (of ethers owned by DAO)
    mapping(address => uint256) public ethLedger;

    /* ========== PARAMETERS ============== */

    uint256 public ntokenRepurchaseThreshold;
    uint256 public collectInterval;

    uint256 constant DAO_REPURCHASE_PRICE_DEVIATION = 5;  // price deviation < 5% 
    uint256 constant DAO_REPURCHASE_NTOKEN_TOTALSUPPLY = 5_000_000;  // total supply > 5 million 

    uint256 constant DAO_COLLECT_INTERVAL = 5_760;  // 24 hour * 60 min * 4 block/min ~= 1 day

    uint256 constant _ethFee = 0.01 ether;

    /* ========== ADDRESSES ============== */

    address public governance;

    address private C_NestPool;
    address private C_NestToken;
    address private C_NestMining;
    address private C_NestStaking;
    address private C_NestQuery;

    /* ========== CONSTRUCTOR ========== */

    receive() external payable {}

    // NOTE: to support open-zeppelin/upgrades, leave it blank
    constructor() public { }

    /// @dev It is called by the proxy (open-zeppelin/upgrades), only ONCE!
    function initialize(address NestPool) external 
    {
        require(flag == DAO_FLAG_UNINITIALIZED, "Nest:DAO:!flag");
        governance = msg.sender;
        flag = DAO_FLAG_INITIALIZED;
        C_NestPool = NestPool;
        ntokenRepurchaseThreshold = DAO_REPURCHASE_NTOKEN_TOTALSUPPLY;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyGovernance() 
    {
        require(msg.sender == governance, "Nest:DAO:!governance");
        _;
    }

    modifier onlyGovOrBy(address _contract) 
    {
        require(msg.sender == governance || msg.sender == _contract, "Nest:DAO:!sender");
        _;
    }

    modifier whenActive() 
    {
        require(flag == DAO_FLAG_ACTIVE, "Nest:DAO:!flag");
        _;
    }

    /* ========== GOVERNANCE ========== */

    /// @dev Ensure that all governance-addresses be consistent with each other
    function loadGovernance() override external 
    { 
        governance = INestPool(C_NestPool).governance();
    }

    /// @dev The function loads all nest-contracts, it is supposed to be called by NestPool
    function loadContracts() override external onlyGovOrBy(C_NestPool)
    {
        C_NestToken = INestPool(C_NestPool).addrOfNestToken();
        C_NestStaking = INestPool(C_NestPool).addrOfNestStaking();
        C_NestQuery = INestPool(C_NestPool).addrOfNestQuery();
        C_NestMining = INestPool(C_NestPool).addrOfNestMining();
    }

    function start() override external onlyGovernance
    {  
        require(flag == DAO_FLAG_INITIALIZED, "Nest:DAO:!flag");
        ERC20(C_NestToken).approve(C_NestStaking, uint(-1));
        startedBlock = uint32(block.number);
        lastCollectingBlock = uint32(block.number);
        flag = DAO_FLAG_ACTIVE;
        collectInterval = DAO_COLLECT_INTERVAL;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_ACTIVE));
    }

    /// @dev Stop service for emergency
    function pause() external onlyGovernance
    {
        require(flag == DAO_FLAG_ACTIVE, "Nest:DAO:!flag");
        flag = DAO_FLAG_PAUSED;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_PAUSED));
    }

    /// @dev Resume service 
    function resume() external onlyGovernance
    {
        require(flag == DAO_FLAG_ACTIVE || flag == DAO_FLAG_PAUSED, "Nest:DAO:!flag");
        flag = DAO_FLAG_ACTIVE;
        emit FlagSet(address(msg.sender), uint256(DAO_FLAG_ACTIVE));
    }

    function setParams(uint256 _ntokenRepurchaseThreshold, uint256 _collectInterval) external onlyGovernance
    {
        emit ParamsSetup(address(msg.sender), ntokenRepurchaseThreshold, _ntokenRepurchaseThreshold);
        ntokenRepurchaseThreshold = _ntokenRepurchaseThreshold;
        emit ParamsSetup(address(msg.sender), collectInterval, _collectInterval);
        collectInterval = _collectInterval;
    }

    function totalETHRewards(address ntoken)
        external view returns (uint256) 
    {
       return  ethLedger[ntoken];
    }

    /// @notice Migrate ethers to a new NestDAO
    /// @param newDAO_ The address of the new contract
    /// @param ntokenL_ The list of ntokens whose ethers are going to be migrated
    function migrateTo(address newDAO_, address[] memory ntokenL_) external onlyGovernance
    {
        require(flag == DAO_FLAG_PAUSED, "Nest:DAO:!flag");
        uint256 _len = ntokenL_.length;
        for (uint256 i; i < _len; i++) {
            address _ntoken = ntokenL_[i];
            uint256 _blncs = ethLedger[_ntoken];

            INestDAO(newDAO_).addETHReward{value:_blncs}(_ntoken);
            
            ethLedger[_ntoken] = 0;

            uint256 _staked = INestStaking(C_NestStaking).stakedBalanceOf(_ntoken, address(this));
            if (_staked > 0) {
                INestStaking(C_NestStaking).unstake(_ntoken, _staked);
            }

            uint256 _ntokenAmount = ERC20(_ntoken).balanceOf(address(this));

            if (_ntokenAmount > 0) {
                ERC20(_ntoken).transfer(newDAO_, _ntokenAmount);

            }
        }
    }

    /// @dev The function shall be called when ethers are taken from Nestv3.0
    function initEthLedger(address ntoken, uint256 amount) 
        override external
        onlyGovernance 
    {
        require (flag == DAO_FLAG_INITIALIZED, "Nest:DAO:!flag");
        ethLedger[ntoken] = amount;

    }

    /* ========== MAIN ========== */

    /// @notice Pump eth rewards to NestDAO for repurchasing `ntoken`
    /// @param ntoken The address of ntoken in the ether Ledger
    function addETHReward(address ntoken) 
        override
        external
        payable
    {
        ethLedger[ntoken] = ethLedger[ntoken].add(msg.value);
    }

    /// @dev Called by NestMining
    function addNestReward(uint256 amount) 
        override 
        external 
        onlyGovOrBy(C_NestMining)
    {
        Ledger storage it = ntokenLedger[C_NestToken];
        it.rewardedAmount = uint128(uint256(it.rewardedAmount).add(amount));
    }

    /// @dev Collect ethers from NestPool
    function collectNestReward() public returns(uint256)
    {
        // withdraw NEST from NestPool (mined by miners)
        uint256 nestAmount = INestPool(C_NestPool).balanceOfTokenInPool(address(this), C_NestToken);
        if (nestAmount == 0) {
            return 0;
        }

        INestPool(C_NestPool).withdrawNest(address(this), nestAmount);

        return nestAmount;
    }


    /// @dev Collect ethers from NestStaking
    function collectETHReward(address ntoken) public returns (uint256)
    {
        // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        uint256 ntokenAmount = ERC20(ntoken).balanceOf(address(this));

        // if (ntokenAmount == 0) {
        //     return 0;
        // }
        // // stake new NEST/NTOKENs into StakingPool
        // INestStaking(C_NestStaking).stake(ntoken, ntokenAmount);

        if (ntokenAmount != 0) {
            // stake new NEST/NTOKENs into StakingPool
            INestStaking(C_NestStaking).stake(ntoken, ntokenAmount);
        }

        // claim rewards from StakingPool 
        uint256 _rewards = INestStaking(C_NestStaking).claim(ntoken);
        ethLedger[ntoken] = ethLedger[ntoken].add(_rewards);

        return _rewards;
    }

    function _collect(address ntoken) internal
    {
        if (block.number < uint256(lastCollectingBlock).add(collectInterval)) {
            return;
        }

        uint256 ethAmount = collectETHReward(ntoken);
        
        uint256 nestAmount = collectNestReward();
        
        lastCollectingBlock = uint32(block.number);
        emit AssetsCollected(address(msg.sender), ethAmount, nestAmount);
    }

    /// @dev Redeem ntokens for ethers
    function redeem(address ntoken, uint256 amount) 
        external payable nonReentrant whenActive
    {
        // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        require (msg.value >= _ethFee, "Nest:DAO:!ethFee");

        require(INToken(ntoken).totalSupply() >= ntokenRepurchaseThreshold, "Nest:DAO:!total");

        // check if there is sufficient ethers for repurchase
        uint256 bal = ethLedger[ntoken];
        require(bal > 0, "Nest:DAO:!bal");

        // check the repurchasing quota
        uint256 quota = quotaOf(ntoken);

        // check if the price is steady
        uint256 price;
        bool isDeviated;
        
        
        {
            (uint256 ethAmount, uint256 tokenAmount,) = INestMining(C_NestMining).latestPriceOf(ntoken);
            (, uint256 avg, ,) = INestMining(C_NestMining).priceAvgAndSigmaOf(ntoken);
            price = tokenAmount.mul(1e18).div(ethAmount);

            uint256 diff = price > avg? (price - avg) : (avg - price);
            isDeviated = (diff.mul(100) < avg.mul(DAO_REPURCHASE_PRICE_DEVIATION))? false : true;

            if(msg.value > _ethFee){
                TransferHelper.safeTransferETH(msg.sender, msg.value.sub(_ethFee));
            }
            this.addETHReward{value:_ethFee}(address(ntoken));

        }

        require(isDeviated == false, "Nest:DAO:!price");

        // check if there is sufficient quota for repurchase
        require (amount <= quota, "Nest:DAO:!quota");
        // amount.mul(1e18).div(price) < bal
        require (amount.mul(1e18) <= bal.mul(price), "Nest:DAO:!bal2");

        // update the ledger
        Ledger memory it = ntokenLedger[ntoken];

        it.redeemedAmount = uint128(amount.add(it.redeemedAmount));
        it.quotaAmount = uint128(quota.sub(amount));
        it.lastBlock = uint32(block.number);
        ntokenLedger[ntoken] = it;

        // transactions
        ethLedger[ntoken] = ethLedger[ntoken].sub(amount.mul(1e18).div(price));

        ERC20(ntoken).transferFrom(address(msg.sender), address(this), amount);
        TransferHelper.safeTransferETH(msg.sender, amount.mul(1e18).div(price));

        _collect(ntoken); 
    }

    // function _price(address ntoken) internal view 
    //     returns (uint256 price, uint256 avg, bool isDeviated)
    // {
    //     (price, avg, , ) = 
    //         INestQuery(C_NestQuery).queryPriceAvgVola(ntoken, );
    //     uint256 diff = price > avg? (price - avg) : (avg - price);
    //     isDeviated = (diff.mul(100) < avg.mul(DAO_REPURCHASE_PRICE_DEVIATION))? false : true;
    // }

    function _quota(address ntoken) internal view returns (uint256 quota) 
    {
        if (INToken(ntoken).totalSupply() < ntokenRepurchaseThreshold) {
            return 0;
        }

        //  calculate the accumulated amount of NEST/NTOKEN available to repurchasing
        Ledger memory it = ntokenLedger[ntoken];
        uint256 _acc;
        uint256 n;
        if(ntoken == C_NestToken){
             n = 1000;
            uint256 intv = (it.lastBlock == 0) ? 
                (block.number).sub(startedBlock) : (block.number).sub(uint256(it.lastBlock));
            _acc = (n * intv > 300_000)? 300_000 : (n * intv);
        }else{
            n = 10;
            uint256 intv = (it.lastBlock == 0) ? 
                (block.number).sub(startedBlock) : (block.number).sub(uint256(it.lastBlock));
            _acc = (n * intv > 3000)? 3000 : (n * intv);
        }

        uint256 total;
         total = _acc.mul(1e18).add(it.quotaAmount);
        if(ntoken == C_NestToken){
            if(total > uint256(300_000).mul(1e18)){
                quota = uint256(300_000).mul(1e18);
            }else{
                quota = total;
            }   
        }else{
            if(total > uint256(3000).mul(1e18)){
                quota = uint256(3000).mul(1e18);
            }else{
                quota = total;
            }   
        }
        
    }

    /* ========== VIEWS ========== */

    function quotaOf(address ntoken) public view returns (uint256 quota) 
    {
       // check if ntoken is a NTOKEN
        address _ntoken = INestPool(C_NestPool).getNTokenFromToken(ntoken);
        require (_ntoken == ntoken, "Nest:DAO:!ntoken");

        return _quota(ntoken);
    }
}


}
