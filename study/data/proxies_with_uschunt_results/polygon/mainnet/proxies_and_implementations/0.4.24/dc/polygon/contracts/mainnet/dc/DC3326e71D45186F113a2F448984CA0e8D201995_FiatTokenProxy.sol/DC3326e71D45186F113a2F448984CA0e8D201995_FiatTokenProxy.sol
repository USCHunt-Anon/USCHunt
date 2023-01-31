

pragma solidity ^0.4.24;


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}




pragma solidity ^0.4.24;

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




pragma solidity ^0.4.24;

//////import './Proxy.sol';
//////import 'openzeppelin-solidity/contracts/AddressUtils.sol';

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
   * validated in the constructor.
   */
  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

  /**
   * @dev Contract constructor.
   * @param _implementation Address of the initial implementation.
   */
  constructor(address _implementation) public {
    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));

    _setImplementation(_implementation);
  }

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
  function _setImplementation(address newImplementation) private {
    require(AddressUtils.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}




pragma solidity ^0.4.24;

//////import './UpgradeabilityProxy.sol';

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
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
   * validated in the constructor.
   */
  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

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
   * Contract constructor.
   * It sets the `msg.sender` as the proxy administrator.
   * @param _implementation address of the initial implementation.
   */
  constructor(address _implementation) UpgradeabilityProxy(_implementation) public {
    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));

    _setAdmin(msg.sender);
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external view ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external view ifAdmin returns (address) {
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
   * It should include the signature and the parameters of the function to be
   * called, as described in
   * https://solidity.readthedocs.io/en/develop/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    require(address(this).call.value(msg.value)(data));
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


/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;

//////import 'zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol';

/**
 * @title FiatTokenProxy
 * @dev This contract proxies FiatToken calls and enables FiatToken upgrades
*/
contract FiatTokenProxy is AdminUpgradeabilityProxy {
    constructor(address _implementation) public AdminUpgradeabilityProxy(_implementation) {
    }
}


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/Ownable.sol

/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;

contract Ownable {

  address private _owner;

  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
  * @dev The constructor sets the original owner of the contract to the sender account.
  */
  constructor() internal {
    setOwner(msg.sender);
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @dev Sets a new owner address
   */
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(msg.sender == owner(), "onlyOwner: not owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "transferOwnership: 0x0 invalid");
    require(newOwner != owner(), "transferOwnership: same address");
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }
}

// File: contracts/Blacklistable.sol

/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;

/**
 * @title Blacklistable Token
 * @dev Allows accounts to be blacklisted by a "blacklister" role
*/
contract Blacklistable is Ownable {

    address public blacklister;
    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @dev Throws if called by any account other than the blacklister
    */
    modifier onlyBlacklister() {
        require(msg.sender == blacklister, "not blacklister");
        _;
    }

    /**
     * @dev Throws if argument account is blacklisted
     * @param _account The address to check
    */
    modifier notBlacklisted(address _account) {
        require(blacklisted[_account] == false, "notBlacklisted: is blacklisted");
        _;
    }

    /**
     * @dev Checks if account is blacklisted
     * @param _account The address to check
    */
    function isBlacklisted(address _account) public view returns (bool) {
        return blacklisted[_account];
    }

    /**
     * @dev Adds account to blacklist
     * @param _account The address to blacklist
    */
    function blacklist(address _account) public onlyBlacklister {
        require(_account != address(0), "blacklist: 0x0 invalid");
        require(!isBlacklisted(_account), "blacklist: already blacklisted");
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    /**
     * @dev Removes account from blacklist
     * @param _account The address to remove from the blacklist
    */
    function unBlacklist(address _account) public onlyBlacklister {
        require(_account != address(0), "unBlacklist: 0x0 invalid");
        require(isBlacklisted(_account), "unBlacklist: not blacklisted");
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }

    function updateBlacklister(address _newBlacklister) public onlyOwner {
        require(_newBlacklister != address(0), "updateBlacklister: 0x0 invalid");
        require(_newBlacklister != blacklister, "updateBlacklister: same address");
        blacklister = _newBlacklister;
        emit BlacklisterChanged(blacklister);
    }
}

// File: contracts/Pausable.sol

/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * Based on openzeppelin tag v1.10.0 commit: feb665136c0dae9912e08397c1a21c4af3651ef3
 * Modifications:
 * 1) Added pauser role, switched pause/unpause to be onlyPauser (6/14/2018)
 * 2) Removed whenNotPause/whenPaused from pause/unpause (6/14/2018)
 * 3) Removed whenPaused (6/14/2018)
 * 4) Switches ownable library to use zeppelinos (7/12/18)
 * 5) Remove constructor (7/13/18)
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  event PauserChanged(address indexed newAddress);


  address public pauser;
  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused, "whenNotPaused: contract paused");
    _;
  }

  /**
   * @dev throws if called by any account other than the pauser
   */
  modifier onlyPauser() {
    require(msg.sender == pauser, "pauser only");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser {
    paused = false;
    emit Unpause();
  }

  /**
   * @dev update the pauser role
   */
  function updatePauser(address _newPauser) public onlyOwner {
    require(_newPauser != address(0), "updatePauser: 0x0 invalid");
    require(_newPauser != pauser, "updatePauser: same address");
    pauser = _newPauser;
    emit PauserChanged(pauser);
  }

}

// File: contracts/ERC20Recovery.sol

/**
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;

/**
 * @title ERC20Recovery
 * @dev Minimal version of ERC20 interface required to allow ERC20 locked tokens recovery
 */

contract ERC20Recovery {
  function balanceOf(address account) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

// File: contracts/FiatTokenV1.sol

/**
* Copyright CENTRE SECZ 2018
* Copyright (c) 2020 Xfers Pte. Ltd.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

pragma solidity ^0.4.24;





/**
 * @title FiatToken
 * @dev Token backed by fiat reserves
 */
contract FiatTokenV1 is Ownable, Pausable, Blacklistable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    address public masterMinter;

    bool internal initialized;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    /**
     * @dev Throws if called by any account other than a minter
    */
    modifier onlyMinters() {
        require(minters[msg.sender] == true, "minters only");
        _;
    }

    /**
     * @dev Throws if called by any account other than the masterMinter
    */
    modifier onlyMasterMinter() {
        require(msg.sender == masterMinter, "master minter only");
        _;
    }

    /**
     * @dev Function to initialise contract
     * @param _name string Token name
     * @param _symbol string Token symbol
     * @param _decimals uint8 Token decimals
     * @param _masterMinter address Address of the master minter
     * @param _pauser address Address of the pauser
     * @param _blacklister address Address of the blacklister
     * @param _owner address Address of the owner
    */
    function initialize(
        string _name,
        string _symbol,
        uint8 _decimals,
        address _masterMinter,
        address _pauser,
        address _blacklister,
        address _owner
    ) public {
        require(!initialized, "already initialized!");
        require(_masterMinter != address(0), "master minter can't be 0x0");
        require(_pauser != address(0), "pauser can't be 0x0");
        require(_blacklister != address(0), "blacklister can't be 0x0");
        require(_owner != address(0), "owner can't be 0x0");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        masterMinter = _masterMinter;
        pauser = _pauser;
        blacklister = _blacklister;
        setOwner(_owner);
        initialized = true;
    }

    /**
     * @dev Function to mint tokens
     * Validates that the contract is not paused
     * only minters can call this function
     * minter and the address that will received the minted tokens are not blacklisted
     * @param _to address The address that will receive the minted tokens.
     * @param _amount uint256 The amount of tokens to mint. Must be less than or equal to the minterAllowance of the caller.
     * @return True if the operation was successful.
    */
    function mint(address _to, uint256 _amount)
        public
        whenNotPaused
        onlyMinters
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(_to != address(0), "can't mint to 0x0");
        require(_amount > 0, "amount to mint has to be > 0");

        uint256 mintingAllowedAmount = minterAllowance(msg.sender);
        require(_amount <= mintingAllowedAmount, "minter allowance too low");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        if (minterAllowance(msg.sender) == 0) {
            minters[msg.sender] = false;
            emit MinterRemoved(msg.sender);
        }
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Function to get minter allowance of an address
     * @param _minter address The address of check minter allowance of
     * @return The minter allowance of the address
    */
    function minterAllowance(address _minter) public view returns (uint256) {
        return minterAllowed[_minter];
    }

    /**
     * @dev Function to check if an address is a minter
     * @param _address The address to check
     * @return A boolean value to indicates if an address is a minter
    */
    function isMinter(address _address) public view returns (bool) {
        return minters[_address];
    }

    /**
     * @dev Function to get total supply of token
     * @return The total supply of the token
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev Function to get token balance of an address
     * @param _address address The account
     * @return The token balance of an address
    */
    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    /**
     * @dev Function to approves a spender to spend up to a certain amount of tokens
     * Validates that the contract is not paused
     * the owner and spender are not blacklisted
     * Avoid calling this function if possible (https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)
     * @param _spender address The Address of the spender
     * @param _amount uint256 The amount of tokens that the spender is approved to spend
     * @return True if the operation was successful.
    */
    function approve(address _spender, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        return _approve(_spender, _amount);
    }

    /**
     * @dev Alternative function to the approve function
     * Increases the allowance of the spender
     * Validates that the contract is not paused
     * the owner and spender are not blacklisted
     * @param _spender address The Address of the spender
     * @param _addedValue uint256 The amount of tokens to be added to a spender's allowance
     * @return True if the operation was successful.
    */
    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        uint256 updatedAllowance = allowed[msg.sender][_spender].add(
            _addedValue
        );
        return _approve(_spender, updatedAllowance);
    }

    /**
     * @dev Alternative function to the approve function
     * Decreases the allowance of the spender
     * Validates that the contract is not paused
     * the owner and spender are not blacklisted
     * @param _spender address The Address of the spender
     * @param _subtractedValue uint256 The amount of tokens to be subtracted from a spender's allowance
     * @return True if the operation was successful.
    */
    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_spender)
        returns (bool)
    {
        uint256 updatedAllowance = allowed[msg.sender][_spender].sub(
            _subtractedValue
        );
        return _approve(_spender, updatedAllowance);
    }

    /**
     * @dev Function to approves a spender to spend up to a certain amount of tokens
     * @param _spender address The Address of the spender
     * @param _amount uint256 The amount of tokens that the spender is approved to spend
    */
    function _approve(address _spender, uint256 _amount)
        internal
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * @dev Function to get token allowance given to a spender by the owner
     * @param _owner address The address of the owner
     * @param _spender address The address of the spender
     * @return The number of tokens that a spender can spend on behalf of the owner
    */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Function to transfer tokens from one address to another.
     * Validates that the contract is not paused
     * the caller, sender and receiver of the tokens are not blacklisted
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _amount uint256 the amount of tokens to be transferred
     * @return True if the operation was successful.
    */
    function transferFrom(address _from, address _to, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(_to)
        notBlacklisted(msg.sender)
        notBlacklisted(_from)
        returns (bool)
    {
        require(_to != address(0), "can't transfer to 0x0");
        require(_amount <= balances[_from], "insufficient balance");
        require(
            _amount <= allowed[_from][msg.sender],
            "token allowance is too low"
        );

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * @dev Function to transfer token to a specified address
     * Validates that the contract is not paused
     * The sender and receiver are not blacklisted
     * @param _to The address to transfer to.
     * @param _amount The amount of tokens to be transferred.
     * @return True if the operation is successful
    */
    function transfer(address _to, uint256 _amount)
        public
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        returns (bool)
    {
        require(_to != address(0), "can't transfer to 0x0");
        require(_amount <= balances[msg.sender], "insufficient balance");

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
    * @dev Function to increase minter allowance of a minter
    * Validates that only the master minter can call this function
    * @param _minter address The address of the minter
    * @param _increasedAmount uint256 The amount of to be added to a minter's allowance
    */
    function increaseMinterAllowance(address _minter, uint256 _increasedAmount)
        public
        onlyMasterMinter
    {
        require(_minter != address(0), "minter can't be 0x0");
        uint256 updatedAllowance = minterAllowance(_minter).add(
            _increasedAmount
        );
        minterAllowed[_minter] = updatedAllowance;
        minters[_minter] = true;
        emit MinterConfigured(_minter, updatedAllowance);
    }

    /**
    * @dev Function to decrease minter allowance of a minter
    * Validates that only the master minter can call this function
    * @param _minter address The address of the minter
    * @param _decreasedAmount uint256 The amount of allowance to be subtracted from a minter's allowance
    */
    function decreaseMinterAllowance(address _minter, uint256 _decreasedAmount)
        public
        onlyMasterMinter
    {
        require(_minter != address(0), "minter can't be 0x0");
        require(minters[_minter], "not a minter");

        uint256 updatedAllowance = minterAllowance(_minter).sub(
            _decreasedAmount
        );
        minterAllowed[_minter] = updatedAllowance;
        if (minterAllowance(_minter) > 0) {
            emit MinterConfigured(_minter, updatedAllowance);
        } else {
            minters[_minter] = false;
            emit MinterRemoved(_minter);

        }
    }

    /**
     * @dev Function to allow a minter to burn some of its own tokens
     * Validates that the contract is not paused
     * caller is a minter and is not blacklisted
     * amount is less than or equal to the minter's mint allowance balance
     * @param _amount uint256 the amount of tokens to be burned
    */
    function burn(uint256 _amount)
        public
        whenNotPaused
        onlyMinters
        notBlacklisted(msg.sender)
    {
        uint256 balance = balances[msg.sender];
        require(_amount > 0, "burn amount has to be > 0");
        require(balance >= _amount, "balance in minter is < amount to burn");

        totalSupply_ = totalSupply_.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

    /**
     * @dev Function to allow the blacklister to burn entire balance of tokens from a blacklisted address
     * Validates that contract is not paused
     * caller is the blacklister
     * address to burn tokens from is a blacklisted address
     * @param _from address the address to burn tokens from
    */
    function lawEnforcementWipingBurn(address _from)
        public
        whenNotPaused
        onlyBlacklister
    {
        require(
            isBlacklisted(_from),
            "Can't wipe balances of a non blacklisted address"
        );
        uint256 balance = balances[_from];
        totalSupply_ = totalSupply_.sub(balance);
        balances[_from] = 0;
        emit Burn(_from, balance);
        emit Transfer(_from, address(0), balance);
    }

    /**
     * @dev Function to update the masterMinter role
     * Validates that the caller is the owner
     */
    function updateMasterMinter(address _newMasterMinter) public onlyOwner {
        require(_newMasterMinter != address(0), "master minter can't be 0x0");
        require(_newMasterMinter != masterMinter, "master minter is the same");
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }

    /**
      * @dev Function to reject all EIP223 compatible tokens
      * @param _from address The address that is transferring the tokens
      * @param _value uint256 the amount of the specified token
      * @param _data bytes The data passed from the caller
      */
    function tokenFallback(address _from, uint256 _value, bytes _data)
        external
        pure
    {
        revert("reject EIP223 token transfers");
    }

    /**
     * @dev Function to reclaim all ERC20Recovery compatible tokens
     * Validates that the caller is the owner
     * @param _tokenAddress address The address of the token contract
     */
    function reclaimToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "token can't be 0x0");
        ERC20Recovery token = ERC20Recovery(_tokenAddress);
        uint256 balance = token.balanceOf(this);
        require(token.transfer(owner(), balance), "reclaim token failed");
    }
}