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

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initialization
     */
    function ownableInit() internal {
        _setOwner(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Caller is not owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




// : None
// HungryBunz Foraging / $NOM Implementation V1
pragma solidity ^0.8.0;

//import"./ERC20.sol";
//import"./Ownable.sol";
//import"./Initializable.sol";

interface IHungryBunz {
    function applicationOwnerOf(uint256 tokenId) external view returns (address); //Used to verify ownership of game items.
    function ownerOf(uint256 tokenId) external view returns (address); //Used to verify ownership of game items.
    function burnConsumed(uint256) external; //Used to burn an item's NFT, once it has been consumed.
    function lockForStaking (uint16 tokenId) external; //Lock for staking
    function unlock (uint16 tokenId, uint248 newTime) external; //Unlock
    function serializeStats(uint16 tokenId) external view returns (bytes16); //Get serialized stats
    function serializeAtts(uint16 tokenId) external view returns (bytes16); //Get serialized stats
    function checkStake (uint16 tokenId) external view returns (address);
    function stakeStart (uint16 tokenId) external view returns(uint248);
    function updateStakeStart (uint16 tokenId, uint248 newTime) external;
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




pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}




pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function erc20init(string memory name_, string memory symbol_) internal {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}




contract NOM is Initializable, ERC20, Ownable {
    //******************************************************
    //CRITICAL STATE VARIABLES
    //****************************************************** 
    //Pausable library is simple enough to imitate in this contract
    bool public paused = false;

    address _mainContractAddress;
    address _gatewayContractAddress;
    IHungryBunz _HungryBunz;
    
    mapping(address => mapping(uint16 => uint256)) ownedStakes;
    mapping(uint16 => uint256) stakes;
    mapping(address => bool) approvedBurners;
    mapping(address => bool) approvedMinters;

    //Track balances not yet transferred to users.
    //Saves nominal gas vs incrementing supply and
    //emitting event on every claim.
    mapping(address => uint256) balances;
    
    uint256 _baseReward; //Base reward per block of time.
    uint256 _scavengingIncrement; //Seconds in a day.
    uint8 _maxScavengingPeriods; //Max length of time to scavenge.
    uint8 _foodComaPeriods; //Food coma duration in periods.
    
    struct st {
        uint8 rank; //1 = Whelp, 2 = Chunk, 3 = Hunk
        uint8 season; //Determines eligibility for season rewards
        uint16 thiccness; //Used to calculate score and determine eligibility to evolve
        uint16 criticalChance; //Determines likelihood of dropping critical $NOM
        uint16 criticalMult; //How much more $NOM the character drops on a critical day
        uint16 teamCritChance; //Nerfs this chunks critical chance, but boosts all others a player owns
        uint16 teamCritMult; //Nerfs this players critical chance, but boosts all others a player owns
    }
    
    constructor()
    {
        ownableInit();
    }

    function nomInit(address hbContractAddress) external initializer {
        //Require to prevent users from initializing
        //implementation contract
        require(owner() == address(0) || owner() == msg.sender,
            "No.");
        
        ownableInit();
        erc20init("Nom", "NOM");
        //Base reward per block of time. Expressed
        //in smaller units to accomodate basis point
        //calculations.
        _baseReward = 10 * (10 ** 14);
        _scavengingIncrement = 86400; //Seconds in a day.
        _maxScavengingPeriods = 12; //Max length of time to scavenge.
        _foodComaPeriods = 2; //Food coma duration in periods.
        
        _mainContractAddress = hbContractAddress;
        _HungryBunz = IHungryBunz(hbContractAddress);
        approvedBurners[hbContractAddress] = true;
        
        paused = true; //Start contract as paused
    }
    
    //******************************************************
    //ERC20 FUNCTIONALITY OVERRIDES
    //******************************************************
    function balanceOf(address account) public view override (ERC20) returns (uint256) {
        //_balances is actual supply, balances is hypothetical
        return ERC20.balanceOf(account) + balances[account];
    }

    //******************************************************
    //OWNER ONLY FUNCTIONS TO MANAGE ESSENTIAL FUNCTIONS
    //******************************************************
    function updateGatewayContract(address gatewayContractAddress) public onlyOwner {
        _gatewayContractAddress = gatewayContractAddress;
        approvedBurners[gatewayContractAddress] = true;
        approvedMinters[gatewayContractAddress] = true;
    }
    
    //Approve functions can be given a false status to revoke permissions.
    function approveBurner(address newConsumer, bool status) public onlyOwner {
        approvedBurners[newConsumer] = status;
    }

    function approveMinter(address newMinter, bool status) public onlyOwner {
        approvedMinters[newMinter] = status;
    }
    
    function updateAppPeriod(uint256 newDuration) public onlyOwner {
        _scavengingIncrement = newDuration;
    }
    
    function updateBaseReward(uint256 newBase) public onlyOwner {
        _baseReward = newBase;
    }
    
    function updateActivePeriods(uint8 newCount) public onlyOwner {
        _maxScavengingPeriods = newCount;
    }
    
    function updateRestPeriods(uint8 newCount) public onlyOwner {
        _foodComaPeriods = newCount;
    }

    //Cost of owner pausing when already paused is mild annoyance.
    //Removed extra requires
    function pause() onlyOwner public {
        paused = true;
    }

    //See above comment explaining bare bones implementation.
    function unpause() onlyOwner public {
        paused = false;
    }
    
    //******************************************************
    //CALCULATE REWARDS AND UPDATE BALANCES
    //******************************************************
    function _checkEligibility(uint16 tokenId) internal view returns(uint256) {
        //Check for paused state will return 0 eligible periods, thus allowing
        //users to unstake if rewards are paused.
        uint256 elapsedTime;
        uint256 stakeStart = _HungryBunz.stakeStart(tokenId);
        if (stakeStart != 0 && paused == false &&
            block.timestamp > stakeStart)
        {
            elapsedTime = block.timestamp - stakeStart;    
        } else {
            elapsedTime = 0;
        }
        
        uint256 elapsedPeriods = elapsedTime / _scavengingIncrement;
        return elapsedPeriods;
    }
    
    //Check if arbitrary uint16 falls within the bottom NNNN basis points of the range
    function _uint16HitMiss(uint16 basisPoints16, uint16 value) internal pure returns (bool) {
        uint256 max = 65535;
        uint256 basisPoints256 = uint256(basisPoints16);
        uint256 scaledThreshold = max * basisPoints256 / 10000;
        return (value <= scaledThreshold);
    }
    
    function _retrieveStruct(uint16 tokenId) internal view returns (st memory) {
        st memory output;
        bytes16 serialized = _HungryBunz.serializeStats(tokenId);
        output.rank = uint8(serialized[0]);
        output.season = uint8(serialized[1]);
        output.thiccness = uint16(bytes2(abi.encodePacked(serialized[2], serialized[3])));
        output.criticalChance = uint16(bytes2(abi.encodePacked(serialized[6], serialized[7])));
        output.criticalMult = uint16(bytes2(abi.encodePacked(serialized[8], serialized[9])));
        output.teamCritChance = uint16(bytes2(abi.encodePacked(serialized[12], serialized[13])));
        output.teamCritMult = uint16(bytes2(abi.encodePacked(serialized[14], serialized[15])));
                    
        return output;
    }
    
    /*
     Since visual attributes for tokens are, and will remain, fairly consistent over time,
     we use each tokens' visual properties as a seed for its team and individual critical
     stats. To ensure that all tokens have chance to hit criticals, we use the timestamp of
     the first block every other day as salt. This salt changes frequently enough to prevent
     any one NFT from becoming a guaranteed loser, but not so often that the expected value
     of waiting for the right salt to claim rewards becomes an effective strategy.
     
     A savvy user could identify the tokens which are due to pay out critical rewards in the
     near future and attempt to buy them off the secondary market. We expect that holders should
     price this factor into their listings, and that this strategy will enrichen mechanics and
     improve liquidity on the whole.
     */
    
    function _calculateRewards(uint16[] memory tokenIds) internal view returns (uint256) {
        //This function only called by internal _claim function
        st memory statSwap;
        
        bool teamCritHit;
        uint16 critSeed;
        uint256 teamCritMult = 10000; //100% as basis points for accuracy
        uint256 reward;
        uint256 eodStart = (block.timestamp - (block.timestamp % 172800)); //Every other day's start
        
        //Have to iterate through tokens twice to enumerate team crit chance and mult
        for (uint i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] != 0) {
                statSwap = _retrieveStruct(tokenIds[i]);
                
                //Calculate team critical hit. Upper bound of probability of hitting
                //team critical during any 2 day window is 34%, assuming 16 staked
                //tokens with 1/256 2.56% team critical multiplier.
                if (!teamCritHit) {
                    critSeed = uint16(bytes2(keccak256(abi.encodePacked(
                        _HungryBunz.serializeAtts(tokenIds[i]),
                        eodStart
                    ))));
                    teamCritHit = _uint16HitMiss(statSwap.teamCritChance, critSeed);
                }

                //Plus equals assignment forces incorrect order of operations. Use long form.
                teamCritMult = (teamCritMult * uint32(statSwap.teamCritMult)) / 10000;
            }
        }
        
        //Cap team critical mult at 8x for maximum daily nom of 26x
        if (teamCritMult > 80000) {
            teamCritMult = 80000;
        }
        
        for (uint i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] != 0) {
                statSwap = _retrieveStruct(tokenIds[i]);
                
                uint8 level = statSwap.rank;
                uint8 critHit;
                if (!teamCritHit) {
                    critSeed = uint16(bytes2(keccak256(abi.encodePacked(
                        _HungryBunz.serializeAtts(tokenIds[i]),
                        eodStart
                    ))));
                    
                    //Crit chance in excess of 10000 should not cause any grief,
                    //but overflow check inculded regardless.
                    uint16 critChance = (statSwap.criticalChance <= 10000) ? 
                        statSwap.criticalChance : 10000;
                    critHit = _uint16HitMiss(critChance, critSeed) ? 1 : 0;
                } else {
                    //Team crit chance will either be 0 (no team crit) or 10000 (team crit hit)
                    //If team crit chance isn't zero, then critHit must be 1.
                    critHit = 1;
                }

                uint8 eligiblePeriods = _checkEligibility(tokenIds[i]) > _maxScavengingPeriods ? 
                    _maxScavengingPeriods : uint8(_checkEligibility(tokenIds[i]));
                
                //Computing reward multiplier in basis points. Multiplying basis points for Critical and Team crit requires divide by 10k
                uint256 thisRewardMult = uint16((critHit * statSwap.criticalMult * teamCritMult) / 10000);
                thisRewardMult = thisRewardMult >= 10000 ? thisRewardMult : 10000;
                
                //Reward mult. Leave additional decimals.
                reward += eligiblePeriods * _baseReward * (level ** 2) * thisRewardMult;
            }
        }
        
        return reward;
    }
    
    //Internal function only called after input sanitization. Passes
    //sanitized array for reward assessments, and then sets user balance.
    //Timestamp is not updated in this function, since timestamp is stored
    //on main contract to reduce write operations, and main contract
    //exposes distinct functions for simple restake / claim, and unstake
    //operations.
    function _claim(uint16[] memory tokenIds, address targetAccount) internal returns (uint256) {
        uint256 rewards = _calculateRewards(tokenIds);
        balances[targetAccount] += rewards;
        
        return rewards;
    }
    
    //******************************************************
    //MAJOR HOOKS TO STAKE, CLAIM, AND UNSTAKE
    //******************************************************
    function stake(uint16[] memory tokenIds) public {
        //We don't sanitize this input, beyond owner check, since
        //consequence of staking twice is irrelevant and main
        //will revert when attempting to relock token. We use
        //the overriden ownerOf function to prevent staking while
        //token is on another layer.
        for (uint i = 0; i < tokenIds.length; i++) {
            if (_HungryBunz.ownerOf(tokenIds[i]) == msg.sender) {
                //This function locks the token. Main contract will
                //not update timestamp if staking start is in the
                //future. Main contract reverts if token rank is
                //above max stakable rank.
                _HungryBunz.lockForStaking(tokenIds[i]);
            }
        }
    }

    //Function will not remove tokens which are owned and staked, but ineligible for claim.
    //Onus is on user to decide if they have a sufficient incentive to claim while token is
    //ineligible to claim nom
    function _sanitizeArray(uint16[] memory tokenIds, address account) internal view returns (uint16[] memory) {
        require(tokenIds.length < 17,
            "Cannot claim more than 16 at a time");
        
        uint16[] memory claimable = new uint16[](tokenIds.length);
        uint16 j = 0;
        uint16 validationSetLength;

        for (uint16 i = 0; i < tokenIds.length; i++) { //We assume no one will try to claim more than total supply....
            //If token is not current staked and owned by msg.sender, remove it from the claim array
            if (_HungryBunz.checkStake(tokenIds[i]) == account) {
                //Claimable can never contain more than i non zero values.
                //If invalid entries are deleted and claimable array is
                //shortened, then use claimable.length for later elements.
                validationSetLength = i < uint16(claimable.length) ? i : uint16(claimable.length);
                
                //Nested for loop for maximum of 128 iterations is favorable, gas-wise, to
                //other solutions which write to storage more frequently.
                for (uint16 k = 0; k < validationSetLength; k++) {
                    //User attempted to claim token more than once.
                    require(tokenIds[i] != claimable[k], "Shame!");
                }
                
                claimable[j] = tokenIds[i];
                j++;
            } else {
                //If stake not owned or staked, shorten claimable array by 1
                delete claimable[claimable.length - 1];
            }
        }

        return claimable;
    }
    
    //Restake and unstake functions share some redundant logic, but are left separate
    //to accomodate different calls to main contract.
    function restake(uint16[] memory tokenIds) public returns (uint256) { //Claim NOM
        //No advantage to running restake while claims are paused.
        require(paused == false, "Claims paused.");
        
        //Sanitize removes duplicates and tokens which are not owned by sender, or don't
        //exist on this layer.
        uint16[] memory claimable = _sanitizeArray(tokenIds, msg.sender);
        if (claimable.length > 0) {
            //We can claim safely before updating timers and completing
            //unlock procedure because simulated transfers eliminate
            //opportunities for reentrant attacks from receiver functions
            uint256 rewards = _claim(claimable, msg.sender);

            for (uint i = 0; i < claimable.length; i++) {
                if (claimable[i] != 0) {
                    if(_checkEligibility(claimable[i]) >= (_foodComaPeriods + _maxScavengingPeriods)) {
                        _HungryBunz.updateStakeStart(claimable[i], uint248(block.timestamp));
                    } else {
                        uint248 tokenStakeStart = uint248(block.timestamp) + 
                            uint248(_scavengingIncrement * (_foodComaPeriods));
                        _HungryBunz.updateStakeStart(claimable[i], tokenStakeStart);
                    }
                }
            }

            return rewards;
        } else {
            return 0;
        }
    }
    
    function unstake(uint16[] memory tokenIds, address targetAccount) external returns (uint256) { //Claim NOM and return NFTs
        address account = msg.sender == _mainContractAddress ? targetAccount : msg.sender;
        
        //Sanitize removes duplicates and tokens which are not owned by sender, or don't
        //exist on this layer.
        uint16[] memory claimable = _sanitizeArray(tokenIds, account);
        
        if(claimable.length > 0) {
            //We can claim safely before updating timers and completing
            //unlock procedure because simulated transfers eliminate
            //opportunities for reentrant attacks from receiver functions.
            //Reversion in unlock procedure will revert the entire tx.
            uint256 rewards = _claim(claimable, account);

            for (uint i = 0; i < claimable.length; i++) {
                if(claimable[i] != 0) {
                    if(_checkEligibility(claimable[i]) >= (_foodComaPeriods + _maxScavengingPeriods)) {
                        _HungryBunz.unlock(claimable[i], uint248(block.timestamp));
                    } else {
                        uint248 tokenStakeStart = uint248(block.timestamp) + 
                            uint248(_scavengingIncrement * (_foodComaPeriods));
                        _HungryBunz.unlock(claimable[i], tokenStakeStart);
                    }
                }
            }
            
            return rewards;
        } else {
            return 0;
        }
    }
    
    //******************************************************
    //VIEWS
    //******************************************************
    function getBunzStatus(uint16 tokenId) public view returns (bool) {
        //True if Bunz is resting, false if scavenging.
        return _HungryBunz.stakeStart(tokenId) > uint248(block.timestamp);
    }
    
    //View balance of tokens not yet withdrawn
    function viewBalance(address owner) external view returns (uint256) {
        return balances[owner];
    }
    
    //Check if claims are paused
    function claimStatus() external view returns (bool) {
        return paused;
    }
    
    //******************************************************
    //WITHDRAW FROM NON STANDARD BALANCE FOR TRADING
    //******************************************************
    function withdrawBalance() public {
        balances[msg.sender] = 0;
        _mint(msg.sender, balances[msg.sender]);
    }
    
    //******************************************************
    //BURN AND MINT FUNCTIONALITY FOR MAIN CONTRACT & BRIDGE
    //******************************************************
    function burn(address account, uint256 amount) public {
        require(approvedBurners[msg.sender] == true, 
            "Not Approved!");
        if(balances[account] >= amount) {
            balances[account] -= amount;
        } else {
            balances[account] = 0;
            _burn(account, (amount - balances[account]));
        }
    }
    
    //Mint function for other application contracts
    function applicationMint(address to, uint256 amount) public {
        require(approvedMinters[msg.sender] == true,
            "Not Approved!");
        _mint(to, amount);
    }
}
