/**
 *Submitted for verification at Etherscan.io on 2021-02-03
*/

// ////-License-Identifier: (c) Armor.Fi DAO, 2021

pragma solidity 0.6.12;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
abstract contract Proxy {
    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    fallback() external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
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
    function implementation() public view virtual returns (address);
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
    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    /**
    * @dev Constructor function
    */
    constructor() public {}

    /**
    * @dev Tells the address of the current implementation
    * @return impl address of the current implementation
    */
    function implementation() public view override returns (address impl) {
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
    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

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
    * @return owner the address of the owner
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

// Sources flattened with hardhat v2.3.0 https://hardhat.org

// File contracts/interfaces/IERC20.sol
pragma solidity ^0.6.6;

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
}


// File contracts/libraries/SafeMath.sol
pragma solidity ^0.6.12;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 * 
 * @dev Default OpenZeppelin
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


// File contracts/vesting.sol
// : (c) Armor.Fi DAO, 2021

pragma solidity ^0.6.12;


contract Vesting {

    using SafeMath for uint256;

    IERC20 public token;

    uint256 public totalTokens;
    uint256 public releaseStart;
    uint256 public releaseEnd;

    mapping (address => uint256) public starts;
    mapping (address => uint256) public grantedToken;

    // this means, released but unclaimed amounts
    mapping (address => uint256) public released;

    event Claimed(address indexed _user, uint256 _amount, uint256 _timestamp);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount, uint256 _timestamp);

    // Storage position of the owner of the contract
    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");
    function owner() public view returns(address _owner) {
        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            _owner := sload(position)
        }
    }

    // do not input same recipient in the _recipients, it will lead to locked token in this contract
    function initialize(
        address _token,
        uint256 _totalTokens,
        uint256 _start,
        uint256 _period,
        address[] calldata _recipients,
        uint256[] calldata _grantedToken
    )
    public
    {
        require(releaseEnd == 0, "Contract is already initialized.");
        require(_recipients.length == _grantedToken.length, "Array lengths do not match.");

        releaseEnd = _start.add(_period);
        releaseStart = _start;

        token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _totalTokens);
        totalTokens = _totalTokens;
        uint256 sum = 0;

        for(uint256 i = 0; i<_recipients.length; i++) {
            starts[_recipients[i]] = releaseStart;
            grantedToken[_recipients[i]] = _grantedToken[i];
            sum = sum.add(_grantedToken[i]);
        }

        // We're gonna just set the weight as full tokens. Ensures grantedToken were entered correctly as well.
        require(sum == totalTokens, "Weight does not match tokens being distributed.");
    }

    /**
     * @dev User may claim tokens that have vested.
     **/
    function claim()
    public
    {
        address user = msg.sender;

        require(releaseStart <= block.timestamp, "Release has not started");
        require(grantedToken[user] > 0 || released[user] > 0, "This contract may only be called by users with a stake.");

        uint256 releasing = releasable(user);
        // updates the grantedToken
        grantedToken[user] = grantedToken[user].sub(releasing);

        // claim will claim both released and releasing
        uint256 claimAmount = released[user].add(releasing);

        // flush the released since released means "unclaimed" amount
        released[user] = 0;

        // and update the starts
        starts[user] = block.timestamp;
        token.transfer(user, claimAmount);
        emit Claimed(user, claimAmount, block.timestamp);
    }

    function end(address _user) external {
        require(msg.sender == owner(), "!owner");
        uint256 releasePulled = released[_user];
        released[_user] = 0;
        uint256 grantPulled = grantedToken[_user];
        grantedToken[_user] = 0;
        token.transfer(owner(), releasePulled + grantPulled);
    }
    
    /**
     * @dev returns claimable token. buffered(released) token + token released from last update
     * @param _user user to check the claimable token
     **/
    function claimableAmount(address _user) external view returns(uint256) {
        return released[_user].add(releasable(_user));
    }

    /**
     * @dev returns the token that can be released from last user update
     * @param _user user to check the releasable token
     **/
    function releasable(address _user) public view returns(uint256) {
        if (block.timestamp < releaseStart) return 0;
        uint256 applicableTimeStamp = block.timestamp >= releaseEnd ? releaseEnd : block.timestamp;
        return grantedToken[_user].mul(applicableTimeStamp.sub(starts[_user])).div(releaseEnd.sub(starts[_user]));
    }

    /**
     * @dev Transfers a sender's weight to another address starting from now.
     * @param _to The address to transfer weight to.
     * @param _amountInFullTokens The amount of tokens (in 0 decimal format). We will not have fractions of tokens.
     **/
    /*function transfer(address _to, uint256 _amountInFullTokens)
    external
    {
        require(_to != msg.sender, "May not transfer to yourself.");

        // first, update the released
        released[msg.sender] = released[msg.sender].add(releasable(msg.sender));
        released[_to] = released[_to].add(releasable(_to));

        // then update the grantedToken;
        grantedToken[msg.sender] = grantedToken[msg.sender].sub(releasable(msg.sender));
        grantedToken[_to] = grantedToken[_to].sub(releasable(_to));

        // then update the starts of user
        starts[msg.sender] = block.timestamp;
        starts[_to] = block.timestamp;

        // If trying to transfer too much, transfer full amount.
        uint256 amount = _amountInFullTokens.mul(1e18) > grantedToken[msg.sender] ? grantedToken[msg.sender] : _amountInFullTokens.mul(1e18);

        // then move _amount
        grantedToken[msg.sender] = grantedToken[msg.sender].sub(amount);
        grantedToken[_to] = grantedToken[_to].add(amount);

        emit Transfer(msg.sender, _to, amount, block.timestamp);
    }*/
}