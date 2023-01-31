



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

library address_make_payable {
   function make_payable(address x) internal pure returns (address payable) {
      return address(uint160(x));
   }
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
//import"./lib/AddressPayable.sol";

//import"./iface/INestPool.sol";
//import"./iface/INestStaking.sol";

//import"./lib/SafeERC20.sol";
//import"./lib/ReentrancyGuard.sol";
//import'./lib/TransferHelper.sol';

/// @title NestStaking
/// @author Inf Loop - <inf-loop@nestprotocol.org>
/// @author Paradox  - <paradox@nestprotocol.org>

contract NestStaking is INestStaking, ReentrancyGuard {

    using SafeMath for uint256;

    /* ========== STATE ============== */

    /// @dev  The flag of staking global state
    uint8 public flag;      // = 0: uninitialized
                            // = 1: active
                            // = 2: no staking
                            // = 3: paused 

    uint248 private _reserved1;

    uint8 constant STAKING_FLAG_UNINITIALIZED    = 0;
    uint8 constant STAKING_FLAG_ACTIVE           = 1;
    uint8 constant STAKING_FLAG_NO_STAKING       = 2;
    uint8 constant STAKING_FLAG_PAUSED           = 3;

    /// @dev The balance of savings w.r.t a ntoken(or nest-token)
    ///     _pending_saving_Amount: ntoken => saving amount
    //mapping(address => uint256) private _pending_saving_amount;

    /// @dev The per-ntoken-reward (ETH) w.r.t a ntoken(or nest-token)
    ///     _reward_per_ntoken_stored: ntoken => amount
    mapping(address => uint256) private _reward_per_ntoken_stored;

    // _reward_per_ntoken_claimed: (ntoken, acount, amount) => amount
    mapping(address => mapping(address => uint256)) _reward_per_ntoken_claimed;

    // ntoken => last reward 
    mapping(address => uint256) public lastRewardsTotal;

    // _ntoken_total: ntoken => amount
    mapping(address => uint256) _ntoken_staked_total;

    // _staked_balances: (ntoken, account) => amount
    mapping(address => mapping(address => uint256)) private _staked_balances;

    // rewardsTotal: (ntoken) => amount
    mapping(address => uint256) public rewardsTotal;
    
    // _rewards_balances: (ntoken, account) => amount
    mapping(address => mapping(address => uint256)) public rewardBalances;

    /* ========== PARAMETERS ============== */
    
    /// @dev The percentage of dividends 
    uint8 private _dividend_share; // = 100 as default;

    uint8 constant STAKING_DIVIDEND_SHARE_PRECENTAGE = 100;

    uint248 private _reserved2;

    /* ========== ADDRESSES ============== */

    address private C_NestToken;
    address private C_NestPool;

    address private governance;

    /* ========== CONSTRUCTOR ========== */

    receive() external payable {}

    // NOTE: to support open-zeppelin/upgrades, leave it blank
    constructor() public { }

    /// @dev It is called by the proxy (open-zeppelin/upgrades), only ONCE!
    function initialize(address NestPool) external 
    {
        require(flag == STAKING_FLAG_UNINITIALIZED, "Nest:Stak:!flag");
        governance = msg.sender;
        _dividend_share = STAKING_DIVIDEND_SHARE_PRECENTAGE;
        flag = STAKING_FLAG_ACTIVE;
        C_NestPool = NestPool;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyGovOrBy(address _contract) 
    {
        require(msg.sender == governance || msg.sender == _contract, "Nest:Stak:!sender");
        _;
    }

    modifier whenActive() 
    {
        require(flag == STAKING_FLAG_ACTIVE, "Nest:Stak:!flag");
        _;
    }

    modifier onlyGovernance() 
    {
        require(msg.sender == governance, "Nest:Stak:!gov");
        _;
    }

    mapping(uint256 => mapping(address => bool)) private _status;

    modifier onlyOneBlock() {
        require(
            !_status[block.number][tx.origin],
            'Nest:Stak:!block'
        );
        require(
            !_status[block.number][msg.sender],
            'Nest:Stak:!block'
        );

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }

    /* ========== GOVERNANCE ========== */

    function loadContracts() override external onlyGovOrBy(C_NestPool)
    {
        C_NestToken = INestPool(C_NestPool).addrOfNestToken();
    }

    /// @dev To ensure that all of governance-addresses be consist with each other
    function loadGovernance() override external 
    { 
        governance = INestPool(C_NestPool).governance();
    }

    /// @dev Stop service for emergency
    function pause() override external onlyGovernance
    {
        require(flag == STAKING_FLAG_ACTIVE, "Nest:Stak:!flag");
        flag = STAKING_FLAG_PAUSED;
        emit FlagSet(address(msg.sender), uint256(STAKING_FLAG_PAUSED));
    }

    /// @dev Resume service 
    function resume() override external onlyGovernance
    {
        require(flag == STAKING_FLAG_PAUSED, "Nest:Stak:!flag");
        flag = STAKING_FLAG_ACTIVE;
        emit FlagSet(address(msg.sender), uint256(STAKING_FLAG_ACTIVE));
    }

    /*
    // exist bug
    function withdrawSavingByGov(address ntoken, address to, uint256 amount) 
        external 
        nonReentrant 
        onlyGovernance 
    {
        require(flag == STAKING_FLAG_PAUSED, "Nest:Stak:!flag");

        _pending_saving_amount[ntoken] = _pending_saving_amount[ntoken].sub(amount);

        // must refresh WETH balance record after updating WETH balance
        // or lastRewardsTotal could be less than the newest WETH balance in the next update
        uint256 _newTotal = rewardsTotal[ntoken].sub(amount);
        lastRewardsTotal[ntoken] = _newTotal;
        rewardsTotal[ntoken] = _newTotal;
        emit SavingWithdrawn(ntoken, to, amount);
        TransferHelper.safeTransferETH(to, amount);      
    }
   
    function setParams(uint8 dividendShareRate) override external onlyGovernance
    {
        if (dividendShareRate > 0 && dividendShareRate <= 100) {
            _dividend_share = dividendShareRate;
        }
    }
    */
    /* ========== VIEWS ========== */
    /*
    function totalSaving(address ntoken)
        external view returns (uint256) 
    {
       return  _pending_saving_amount[ntoken];
    }
    */
    function totalRewards(address ntoken)
        external view returns (uint256) 
    {
       return  rewardsTotal[ntoken];
    }

    function totalStaked(address ntoken) 
        external override view returns (uint256) 
    {
        return _ntoken_staked_total[ntoken];
    }

    function stakedBalanceOf(address ntoken, address account) 
        external override view returns (uint256) 
    {
        return _staked_balances[ntoken][account];
    }

    // CM: <tokenShare> = <OldTokenShare> + (<NewTokenShare> * _dividend_share% / <tokenAmount>) 
    function rewardPerToken(address ntoken) 
        public 
        view 
        returns (uint256) 
    {
        uint256 _total = _ntoken_staked_total[ntoken];
        if (_total == 0) {
            // use the old rewardPerTokenStored
            // if not, the new accrued amount will never be distributed to anyone
            return _reward_per_ntoken_stored[ntoken];
        }
        uint256 _rewardPerToken = _reward_per_ntoken_stored[ntoken].add(
                accrued(ntoken).mul(1e18).mul(_dividend_share).div(_total).div(100)
            );
        return _rewardPerToken;
    }

    // CM: <NewTokenShare> = <rewardToken blnc> - <last blnc>
    function accrued(address ntoken) 
        public 
        view 
        returns (uint256) 
    {
        // eth increment of eth since last update
        uint256 _newest = rewardsTotal[ntoken];
        // lastest must be larger than lastUpdate
        return _newest.sub(lastRewardsTotal[ntoken]); 
    }

    // CM: <user share> = [<tokenAmonut> * (<tokenShare> - <tokenShareCollected>) / 1e18] + <reward>
    function earned(address ntoken, address account) 
        public 
        view 
        returns (uint256) 
    {
        return _staked_balances[ntoken][account].mul(
                        rewardPerToken(ntoken).sub(_reward_per_ntoken_claimed[ntoken][account])
                    ).div(1e18).add(rewardBalances[ntoken][account]);
    }
    /*  // it is extra
    // calculate
    function _rewardPerTokenAndAccrued(address ntoken) 
        internal
        view 
        returns (uint256, uint256) 
    {
        uint256 _total = _ntoken_staked_total[ntoken];
        if (_total == 0) {
            // use the old rewardPerTokenStored, and accrued should be zero here
            // if not the new accrued amount will never be distributed to anyone
            return (_reward_per_ntoken_stored[ntoken], 0);
        }
        uint256 _accrued = accrued(ntoken);
        uint256 _rewardPerToken = _reward_per_ntoken_stored[ntoken].add(
                _accrued.mul(1e18).mul(_dividend_share).div(_total).div(100) 
            ); // 80% of accrued to NEST holders as dividend
        return (_rewardPerToken, _accrued);
    }
    */
    /* ========== STAK/UNSTAK/CLAIM ========== */

    modifier updateReward(address ntoken, address account) 
    {
        uint256 _total = _ntoken_staked_total[ntoken];
        uint256 _accrued = rewardsTotal[ntoken].sub(lastRewardsTotal[ntoken]);
        uint256 _rewardPerToken;      

        if (_total == 0) {
            // use the old rewardPerTokenStored, and accrued should be zero here
            // if not the new accrued amount will never be distributed to anyone
            _rewardPerToken = _reward_per_ntoken_stored[ntoken];
        } else {
            // 80% of accrued to NEST holders as dividend
            _rewardPerToken = _reward_per_ntoken_stored[ntoken].add(
                _accrued.mul(1e18).mul(_dividend_share).div(_total).div(100) 
            );
            // update _reward_per_ntoken_stored
            _reward_per_ntoken_stored[ntoken] = _rewardPerToken;
            lastRewardsTotal[ntoken] = rewardsTotal[ntoken];
            //uint256 _newSaving = _accrued.sub(_accrued.mul(_dividend_share).div(100)); // left 20%
            //_pending_saving_amount[ntoken] = _pending_saving_amount[ntoken].add(_newSaving);
        }

        uint256 _newEarned = _staked_balances[ntoken][account].mul(
                _rewardPerToken.sub(_reward_per_ntoken_claimed[ntoken][account])
            ).div(1e18);

        if (account != address(0)) { // Q: redundant
            rewardBalances[ntoken][account] = rewardBalances[ntoken][account].add(_newEarned);
            _reward_per_ntoken_claimed[ntoken][account] = _reward_per_ntoken_stored[ntoken];
        }
        _;
    }

    /// @notice Stake NTokens to get the dividends
    function stake(address ntoken, uint256 amount)
        external 
        override 
        nonReentrant 
        onlyOneBlock
        whenActive
        updateReward(ntoken, msg.sender) 
    {
        require(amount > 0, "Nest:Stak:!amount");
        _ntoken_staked_total[ntoken] = _ntoken_staked_total[ntoken].add(amount);
        _staked_balances[ntoken][msg.sender] = _staked_balances[ntoken][msg.sender].add(amount);
        //TransferHelper.safeTransferFrom(ntoken, msg.sender, address(this), amount);
        emit NTokenStaked(ntoken, msg.sender, amount);
        TransferHelper.safeTransferFrom(ntoken, msg.sender, address(this), amount);

    }

    /// @notice Stake NTokens to get the dividends
    function stakeFromNestPool(address ntoken, uint256 amount) 
        external 
        override 
        nonReentrant 
        onlyOneBlock
        whenActive
        updateReward(ntoken, msg.sender) 
    {
        require(amount > 0, "Nest:Stak:!amount");
        _ntoken_staked_total[ntoken] = _ntoken_staked_total[ntoken].add(amount);
        _staked_balances[ntoken][msg.sender] = _staked_balances[ntoken][msg.sender].add(amount);
        INestPool(C_NestPool).withdrawNTokenAndTransfer(msg.sender, ntoken, amount, address(this));
        emit NTokenStaked(ntoken, msg.sender, amount);
    }

    /// @notice Unstake NTokens
    function unstake(address ntoken, uint256 amount) 
        public 
        override 
        nonReentrant 
        onlyOneBlock
        whenActive
        updateReward(ntoken, msg.sender)
    {
        require(amount > 0, "Nest:Stak:!amount");
        _ntoken_staked_total[ntoken] = _ntoken_staked_total[ntoken].sub(amount);
        _staked_balances[ntoken][msg.sender] = _staked_balances[ntoken][msg.sender].sub(amount);
        //TransferHelper.safeTransfer(ntoken, msg.sender, amount);
        emit NTokenUnstaked(ntoken, msg.sender, amount);
        TransferHelper.safeTransfer(ntoken, msg.sender, amount);

    }

    /// @notice Claim rewards
    function claim(address ntoken) 
        public 
        override 
        nonReentrant 
        whenActive
        updateReward(ntoken, msg.sender) 
        returns (uint256)
    {
        uint256 _reward = rewardBalances[ntoken][msg.sender];
        if (_reward > 0) {
            rewardBalances[ntoken][msg.sender] = 0;
            // WETH balance decreased after this
            //TransferHelper.safeTransferETH(msg.sender, _reward);
            // must refresh WETH balance record after updating WETH balance
            // or lastRewardsTotal could be less than the newest WETH balance in the next update
            uint256 _newTotal = rewardsTotal[ntoken].sub(_reward);
            lastRewardsTotal[ntoken] = _newTotal;
            rewardsTotal[ntoken] = _newTotal;         
           
            emit RewardClaimed(ntoken, msg.sender, _reward);

             TransferHelper.safeTransferETH(msg.sender, _reward);
        }
        return _reward;
    }

    /* ========== INTER-CALLS ========== */

    function addETHReward(address ntoken) 
        override 
        external 
        payable 
    {
        // NOTE: no need to update reward here
        // support for sending ETH for rewards
        rewardsTotal[ntoken] = rewardsTotal[ntoken].add(msg.value); 
    }

}



}
