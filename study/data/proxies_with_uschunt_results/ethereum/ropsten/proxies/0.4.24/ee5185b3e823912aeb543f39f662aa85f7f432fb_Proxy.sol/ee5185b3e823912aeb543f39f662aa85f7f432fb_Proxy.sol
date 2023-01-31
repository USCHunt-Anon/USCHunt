pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: @daostack/infra/contracts/Reputation.sol

/**
 * @title Reputation system
 * @dev A DAO has Reputation System which allows peers to rate other peers in order to build trust .
 * A reputation is use to assign influence measure to a DAO'S peers.
 * Reputation is similar to regular tokens but with one crucial difference: It is non-transferable.
 * The Reputation contract maintain a map of address to reputation value.
 * It provides an onlyOwner functions to mint and burn reputation _to (or _from) a specific address.
 */

contract Reputation is Ownable {

    uint8 public decimals = 18;             //Number of decimals of the smallest unit
    // Event indicating minting of reputation to an address.
    event Mint(address indexed _to, uint256 _amount);
    // Event indicating burning of reputation for an address.
    event Burn(address indexed _from, uint256 _amount);

      /// @dev `Checkpoint` is the structure that attaches a block number to a
      ///  given value, the block number attached is the one that last changed the
      ///  value
    struct Checkpoint {

    // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

          // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

      // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

      // `balances` is the map that tracks the balance of each address, in this
      //  contract when the balance changes the block number that the change
      //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

      // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    /// @notice Constructor to create a MiniMeToken
    constructor(
    ) public
    {
        creationBlock = block.number;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() public view returns (uint) {
        return totalSupplyAt(block.number);
    }

  ////////////////
  // Query balance and totalSupply in History
  ////////////////
    /**
    * @dev return the reputation amount of a given owner
    * @param _owner an address of the owner which we want to get his reputation
    */
    function reputationOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /**
    * @dev return the reputation amount of a given owner
    * @param _owner an address of the owner which we want to get his reputation
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

      /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
      /// @param _owner The address from which the balance will be retrieved
      /// @param _blockNumber The block number when the balance is queried
      /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber)
    public view returns (uint)
    {

          // These next few lines are used when the balance of the token is
          //  requested before a check point was ever created for this token, it
          //  requires that the `parentToken.balanceOfAt` be queried at the
          //  genesis block for that token as this contains initial balance of
          //  this token
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
          // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

      /// @notice Total amount of tokens at a specific `_blockNumber`.
      /// @param _blockNumber The block number when the totalSupply is queried
      /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) public view returns(uint) {

          // These next few lines are used when the totalSupply of the token is
          //  requested before a check point was ever created for this token, it
          //  requires that the `parentToken.totalSupplyAt` be queried at the
          //  genesis block for this token as that contains totalSupply of this
          //  token at this block number.
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
          // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

  ////////////////
  // Generate and destroy tokens
  ////////////////

      /// @notice Generates `_amount` tokens that are assigned to `_owner`
      /// @param _owner The address that will be assigned the new tokens
      /// @param _amount The quantity of tokens generated
      /// @return True if the tokens are generated correctly
    function mint(address _owner, uint _amount) public onlyOwner returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Mint(_owner, _amount);
        return true;
    }

      /// @notice Burns `_amount` tokens from `_owner`
      /// @param _owner The address that will lose the tokens
      /// @param _amount The quantity of tokens to burn
      /// @return True if the tokens are burned correctly
    function burn(address _owner, uint _amount) onlyOwner public returns (bool) {
        uint curTotalSupply = totalSupply();
        uint amountBurned = _amount;
        if (curTotalSupply < amountBurned) {
            amountBurned = curTotalSupply;
        }
        uint previousBalanceFrom = balanceOf(_owner);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
          //require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_owner], previousBalanceFrom - amountBurned);
        emit Burn(_owner, amountBurned);
        return true;
    }

  ////////////////
  // Internal helper functions to query and set a value in a snapshot array
  ////////////////

      /// @dev `getValueAt` retrieves the number of tokens at a given block number
      /// @param checkpoints The history of values being queried
      /// @param _block The block number to retrieve the value at
      /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) view internal returns (uint) {
        if (checkpoints.length == 0) {
            return 0;
        }

          // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

          // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

      /// @dev `updateValueAtNow` used to update the `balances` map and the
      ///  `totalSupplyHistory`
      /// @param checkpoints The history of data being updated
      /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
        require(uint128(_value) == _value); //check value is in the 128 bits bounderies
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}

// File: @daostack/infra/contracts/VotingMachines/IntVoteInterface.sol

interface IntVoteInterface {
    //When implementing this interface please do not only override function and modifier,
    //but also to keep the modifiers on the overridden functions.
    modifier onlyProposalOwner(bytes32 _proposalId) {revert(); _;}
    modifier votable(bytes32 _proposalId) {revert(); _;}

    event NewProposal(bytes32 indexed _proposalId, address indexed _organization, uint _numOfChoices, address _proposer, bytes32 _paramsHash);
    event ExecuteProposal(bytes32 indexed _proposalId, address indexed _organization, uint _decision, uint _totalReputation);
    event VoteProposal(bytes32 indexed _proposalId, address indexed _organization, address indexed _voter, uint _vote, uint _reputation);
    event CancelProposal(bytes32 indexed _proposalId, address indexed _organization );
    event CancelVoting(bytes32 indexed _proposalId, address indexed _organization, address indexed _voter);

    /**
     * @dev register a new proposal with the given parameters. Every proposal has a unique ID which is being
     * generated by calculating keccak256 of a incremented counter.
     * @param _numOfChoices number of voting choices
     * @param _proposalParameters defines the parameters of the voting machine used for this proposal
     * @param _proposer address
     * @return proposal's id.
     */
    function propose(
        uint _numOfChoices,
        bytes32 _proposalParameters,
        address _proposer
        ) external returns(bytes32);

    // Only owned proposals and only the owner:
    function cancelProposal(bytes32 _proposalId) external returns(bool);

    // Only owned proposals and only the owner:
    function ownerVote(bytes32 _proposalId, uint _vote, address _voter) external returns(bool);

    function vote(bytes32 _proposalId, uint _vote,address _voter) external returns(bool);

    function voteWithSpecifiedAmounts(
        bytes32 _proposalId,
        uint _vote,
        uint _rep,
        uint _token,
        address _voter
    )
    external
    returns(bool);

    function cancelVote(bytes32 _proposalId) external;

    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint);

    function isVotable(bytes32 _proposalId) external view returns(bool);

    /**
     * @dev voteStatus returns the reputation voted for a proposal for a specific voting choice.
     * @param _proposalId the ID of the proposal
     * @param _choice the index in the
     * @return voted reputation for the given choice
     */
    function voteStatus(bytes32 _proposalId,uint _choice) external view returns(uint);

    /**
     * @dev isAbstainAllow returns if the voting machine allow abstain (0)
     * @return bool true or false
     */
    function isAbstainAllow() external pure returns(bool);

    /**
     * @dev getAllowedRangeOfChoices returns the allowed range of choices for a voting machine.
     * @return min - minimum number of choices
               max - maximum number of choices
     */
    function getAllowedRangeOfChoices() external pure returns(uint min,uint max);
}

// File: @daostack/infra/contracts/libs/RealMath.sol

/**
 * RealMath: fixed-point math library, based on fractional and integer parts.
 * Using int256 as real216x40, which isn't in Solidity yet.
 * 40 fractional bits gets us down to 1E-12 precision, while still letting us
 * go up to galaxy scale counting in meters.
 * Internally uses the wider int256 for some math.
 *
 * Note that for addition, subtraction, and mod (%), you should just use the
 * built-in Solidity operators. Functions for these operations are not provided.
 *
 * Note that the fancy functions like sqrt, atan2, etc. aren't as accurate as
 * they should be. They are (hopefully) Good Enough for doing orbital mechanics
 * on block timescales in a game context, but they may not be good enough for
 * other applications.
 */


library RealMath {

    /**
     * How many total bits are there?
     */
    int256 constant REAL_BITS = 256;

    /**
     * How many fractional bits are there?
     */
    int256 constant REAL_FBITS = 40;

    /**
     * How many integer bits are there?
     */
    int256 constant REAL_IBITS = REAL_BITS - REAL_FBITS;

    /**
     * What's the first non-fractional bit
     */
    int256 constant REAL_ONE = int256(1) << REAL_FBITS;

    /**
     * What's the last fractional bit?
     */
    int256 constant REAL_HALF = REAL_ONE >> 1;

    /**
     * What's two? Two is pretty useful.
     */
    int256 constant REAL_TWO = REAL_ONE << 1;

    /**
     * And our logarithms are based on ln(2).
     */
    int256 constant REAL_LN_TWO = 762123384786;

    /**
     * It is also useful to have Pi around.
     */
    int256 constant REAL_PI = 3454217652358;

    /**
     * And half Pi, to save on divides.
     * TODO: That might not be how the compiler handles constants.
     */
    int256 constant REAL_HALF_PI = 1727108826179;

    /**
     * And two pi, which happens to be odd in its most accurate representation.
     */
    int256 constant REAL_TWO_PI = 6908435304715;

    /**
     * What's the sign bit?
     */
    int256 constant SIGN_MASK = int256(1) << 255;


    /**
     * Convert an integer to a real. Preserves sign.
     */
    function toReal(int216 ipart) internal pure returns (int256) {
        return int256(ipart) * REAL_ONE;
    }

    /**
     * Convert a real to an integer. Preserves sign.
     */
    function fromReal(int256 realValue) internal pure returns (int216) {
        return int216(realValue / REAL_ONE);
    }

    /**
     * Round a real to the nearest integral real value.
     */
    function round(int256 realValue) internal pure returns (int256) {
        // First, truncate.
        int216 ipart = fromReal(realValue);
        if ((fractionalBits(realValue) & (uint40(1) << (REAL_FBITS - 1))) > 0) {
            // High fractional bit is set. Round up.
            if (realValue < int256(0)) {
                // Rounding up for a negative number is rounding down.
                ipart -= 1;
            } else {
                ipart += 1;
            }
        }
        return toReal(ipart);
    }

    /**
     * Get the absolute value of a real. Just the same as abs on a normal int256.
     */
    function abs(int256 realValue) internal pure returns (int256) {
        if (realValue > 0) {
            return realValue;
        } else {
            return -realValue;
        }
    }

    /**
     * Returns the fractional bits of a real. Ignores the sign of the real.
     */
    function fractionalBits(int256 realValue) internal pure returns (uint40) {
        return uint40(abs(realValue) % REAL_ONE);
    }

    /**
     * Get the fractional part of a real, as a real. Ignores sign (so fpart(-0.5) is 0.5).
     */
    function fpart(int256 realValue) internal pure returns (int256) {
        // This gets the fractional part but strips the sign
        return abs(realValue) % REAL_ONE;
    }

    /**
     * Get the fractional part of a real, as a real. Respects sign (so fpartSigned(-0.5) is -0.5).
     */
    function fpartSigned(int256 realValue) internal pure returns (int256) {
        // This gets the fractional part but strips the sign
        int256 fractional = fpart(realValue);
        if (realValue < 0) {
            // Add the negative sign back in.
            return -fractional;
        } else {
            return fractional;
        }
    }

    /**
     * Get the integer part of a fixed point value.
     */
    function ipart(int256 realValue) internal pure returns (int256) {
        // Subtract out the fractional part to get the real part.
        return realValue - fpartSigned(realValue);
    }

    /**
     * Multiply one real by another. Truncates overflows.
     */
    function mul(int256 realA, int256 realB) internal pure returns (int256) {
        // When multiplying fixed point in x.y and z.w formats we get (x+z).(y+w) format.
        // So we just have to clip off the extra REAL_FBITS fractional bits.
        return int256((int256(realA) * int256(realB)) >> REAL_FBITS);
    }

    /**
     * Divide one real by another real. Truncates overflows.
     */
    function div(int256 realNumerator, int256 realDenominator) internal pure returns (int256) {
        // We use the reverse of the multiplication trick: convert numerator from
        // x.y to (x+z).(y+w) fixed point, then divide by denom in z.w fixed point.
        return int256((int256(realNumerator) * REAL_ONE) / int256(realDenominator));
    }

    /**
     * Create a real from a rational fraction.
     */
    function fraction(int216 numerator, int216 denominator) internal pure returns (int256) {
        return div(toReal(numerator), toReal(denominator));
    }

    // Now we have some fancy math things (like pow and trig stuff). This isn't
    // in the RealMath that was deployed with the original Macroverse
    // deployment, so it needs to be linked into your contract statically.

    /**
     * Raise a number to a positive integer power in O(log power) time.
     * See <https://stackoverflow.com/a/101613>
     */
    function ipow(int256 realBase, int216 exponent) internal pure returns (int256) {
        if (exponent < 0) {
            // Negative powers are not allowed here.
            revert();
        }

        int256 tempRealBase = realBase;
        int256 tempExponent = exponent;

        // Start with the 0th power
        int256 realResult = REAL_ONE;
        while (tempExponent != 0) {
            // While there are still bits set
            if ((tempExponent & 0x1) == 0x1) {
                // If the low bit is set, multiply in the (many-times-squared) base
                realResult = mul(realResult, tempRealBase);
            }
            // Shift off the low bit
            tempExponent = tempExponent >> 1;
            // Do the squaring
            tempRealBase = mul(tempRealBase, tempRealBase);
        }

        // Return the final result.
        return realResult;
    }

    /**
     * Zero all but the highest set bit of a number.
     * See <https://stackoverflow.com/a/53184>
     */
    function hibit(uint256 _val) internal pure returns (uint256) {
        // Set all the bits below the highest set bit
        uint256 val = _val;
        val |= (val >> 1);
        val |= (val >> 2);
        val |= (val >> 4);
        val |= (val >> 8);
        val |= (val >> 16);
        val |= (val >> 32);
        val |= (val >> 64);
        val |= (val >> 128);
        return val ^ (val >> 1);
    }

    /**
     * Given a number with one bit set, finds the index of that bit.
     */
    function findbit(uint256 val) internal pure returns (uint8 index) {
        index = 0;
        // We and the value with alternating bit patters of various pitches to find it.
        if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
            // Picth 1
            index |= 1;
        }
        if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
            // Pitch 2
            index |= 2;
        }
        if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
            // Pitch 4
            index |= 4;
        }
        if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
            // Pitch 8
            index |= 8;
        }
        if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
            // Pitch 16
            index |= 16;
        }
        if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
            // Pitch 32
            index |= 32;
        }
        if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
            // Pitch 64
            index |= 64;
        }
        if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
            // Pitch 128
            index |= 128;
        }
    }

    /**
     * Shift realArg left or right until it is between 1 and 2. Return the
     * rescaled value, and the number of bits of right shift applied. Shift may be negative.
     *
     * Expresses realArg as realScaled * 2^shift, setting shift to put realArg between [1 and 2).
     *
     * Rejects 0 or negative arguments.
     */
    function rescale(int256 realArg) internal pure returns (int256 realScaled, int216 shift) {
        if (realArg <= 0) {
            // Not in domain!
            revert();
        }

        // Find the high bit
        int216 highBit = findbit(hibit(uint256(realArg)));

        // We'll shift so the high bit is the lowest non-fractional bit.
        shift = highBit - int216(REAL_FBITS);

        if (shift < 0) {
            // Shift left
            realScaled = realArg << -shift;
        } else if (shift >= 0) {
            // Shift right
            realScaled = realArg >> shift;
        }
    }

    /**
     * Calculate the natural log of a number. Rescales the input value and uses
     * the algorithm outlined at <https://math.stackexchange.com/a/977836> and
     * the ipow implementation.
     *
     * Lets you artificially limit the number of iterations.
     *
     * Note that it is potentially possible to get an un-converged value; lack
     * of convergence does not throw.
     */
    function lnLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
        if (realArg <= 0) {
            // Outside of acceptable domain
            revert();
        }

        if (realArg == REAL_ONE) {
            // Handle this case specially because people will want exactly 0 and
            // not ~2^-39 ish.
            return 0;
        }

        // We know it's positive, so rescale it to be between [1 and 2)
        int256 realRescaled;
        int216 shift;
        (realRescaled, shift) = rescale(realArg);

        // Compute the argument to iterate on
        int256 realSeriesArg = div(realRescaled - REAL_ONE, realRescaled + REAL_ONE);

        // We will accumulate the result here
        int256 realSeriesResult = 0;

        for (int216 n = 0; n < maxIterations; n++) {
            // Compute term n of the series
            int256 realTerm = div(ipow(realSeriesArg, 2 * n + 1), toReal(2 * n + 1));
            // And add it in
            realSeriesResult += realTerm;
            if (realTerm == 0) {
                // We must have converged. Next term is too small to represent.
                break;
            }
            // If we somehow never converge I guess we will run out of gas
        }

        // Double it to account for the factor of 2 outside the sum
        realSeriesResult = mul(realSeriesResult, REAL_TWO);

        // Now compute and return the overall result
        return mul(toReal(shift), REAL_LN_TWO) + realSeriesResult;

    }

    /**
     * Calculate a natural logarithm with a sensible maximum iteration count to
     * wait until convergence. Note that it is potentially possible to get an
     * un-converged value; lack of convergence does not throw.
     */
    function ln(int256 realArg) internal pure returns (int256) {
        return lnLimited(realArg, 100);
    }

    /**
     * Calculate e^x. Uses the series given at
     * <http://pages.mtu.edu/~shene/COURSES/cs201/NOTES/chap04/exp.html>.
     *
     * Lets you artificially limit the number of iterations.
     *
     * Note that it is potentially possible to get an un-converged value; lack
     * of convergence does not throw.
     */
    function expLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
        // We will accumulate the result here
        int256 realResult = 0;

        // We use this to save work computing terms
        int256 realTerm = REAL_ONE;

        for (int216 n = 0; n < maxIterations; n++) {
            // Add in the term
            realResult += realTerm;

            // Compute the next term
            realTerm = mul(realTerm, div(realArg, toReal(n + 1)));

            if (realTerm == 0) {
                // We must have converged. Next term is too small to represent.
                break;
            }
            // If we somehow never converge I guess we will run out of gas
        }

        // Return the result
        return realResult;

    }

    /**
     * Calculate e^x with a sensible maximum iteration count to wait until
     * convergence. Note that it is potentially possible to get an un-converged
     * value; lack of convergence does not throw.
     */
    function exp(int256 realArg) internal pure returns (int256) {
        return expLimited(realArg, 100);
    }

    /**
     * Raise any number to any power, except for negative bases to fractional powers.
     */
    function pow(int256 realBase, int256 realExponent) internal pure returns (int256) {
        if (realExponent == 0) {
            // Anything to the 0 is 1
            return REAL_ONE;
        }

        if (realBase == 0) {
            if (realExponent < 0) {
                // Outside of domain!
                revert();
            }
            // Otherwise it's 0
            return 0;
        }

        if (fpart(realExponent) == 0) {
            // Anything (even a negative base) is super easy to do to an integer power.

            if (realExponent > 0) {
                // Positive integer power is easy
                return ipow(realBase, fromReal(realExponent));
            } else {
                // Negative integer power is harder
                return div(REAL_ONE, ipow(realBase, fromReal(-realExponent)));
            }
        }

        if (realBase < 0) {
            // It's a negative base to a non-integer power.
            // In general pow(-x^y) is undefined, unless y is an int or some
            // weird rational-number-based relationship holds.
            revert();
        }

        // If it's not a special case, actually do it.
        return exp(mul(realExponent, ln(realBase)));
    }

    /**
     * Compute the square root of a number.
     */
    function sqrt(int256 realArg) internal pure returns (int256) {
        return pow(realArg, REAL_HALF);
    }

    /**
     * Compute the sin of a number to a certain number of Taylor series terms.
     */
    function sinLimited(int256 _realArg, int216 maxIterations) internal pure returns (int256) {
        // First bring the number into 0 to 2 pi
        // TODO: This will introduce an error for very large numbers, because the error in our Pi will compound.
        // But for actual reasonable angle values we should be fine.
        int256 realArg = _realArg;
        realArg = realArg % REAL_TWO_PI;

        int256 accumulator = REAL_ONE;

        // We sum from large to small iteration so that we can have higher powers in later terms
        for (int216 iteration = maxIterations - 1; iteration >= 0; iteration--) {
            accumulator = REAL_ONE - mul(div(mul(realArg, realArg), toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
            // We can't stop early; we need to make it to the first term.
        }

        return mul(realArg, accumulator);
    }

    /**
     * Calculate sin(x) with a sensible maximum iteration count to wait until
     * convergence.
     */
    function sin(int256 realArg) internal pure returns (int256) {
        return sinLimited(realArg, 15);
    }

    /**
     * Calculate cos(x).
     */
    function cos(int256 realArg) internal pure returns (int256) {
        return sin(realArg + REAL_HALF_PI);
    }

    /**
     * Calculate tan(x). May overflow for large results. May throw if tan(x)
     * would be infinite, or return an approximation, or overflow.
     */
    function tan(int256 realArg) internal pure returns (int256) {
        return div(sin(realArg), cos(realArg));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: @daostack/infra/contracts/VotingMachines/GenesisProtocolCallbacksInterface.sol

interface GenesisProtocolCallbacksInterface {
    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256);
    function mintReputation(uint _amount,address _beneficiary,bytes32 _proposalId) external returns(bool);
    function burnReputation(uint _amount,address _owner,bytes32 _proposalId) external returns(bool);
    function reputationOf(address _owner,bytes32 _proposalId) view external returns(uint);
    function stakingTokenTransfer(StandardToken _stakingToken,address _beneficiary,uint _amount,bytes32 _proposalId) external returns(bool);
}

// File: @daostack/infra/contracts/VotingMachines/GenesisProtocolExecuteInterface.sol

interface GenesisProtocolExecuteInterface {
    function executeProposal(bytes32 _proposalId,int _decision) external returns(bool);
}

// File: openzeppelin-solidity/contracts/ECRecovery.sol

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 _hash, bytes _sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(_hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 _hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
    );
  }
}

// File: @daostack/infra/contracts/libs/OrderStatisticTree.sol

library OrderStatisticTree {

    struct Node {
        mapping (bool => uint) children; // a mapping of left(false) child and right(true) child nodes
        uint parent; // parent node
        bool side;   // side of the node on the tree (left or right)
        uint height; //Height of this node
        uint count; //Number of tree nodes below this node (including this one)
        uint dupes; //Number of duplicates values for this node
    }

    struct Tree {
        // a mapping between node value(uint) to Node
        // the tree's root is always at node 0 ,which points to the "real" tree
        // as its right child.this is done to eliminate the need to update the tree
        // root in the case of rotation.(saving gas).
        mapping(uint => Node) nodes;
    }
    /**
     * @dev rank - find the rank of a value in the tree,
     *      i.e. its index in the sorted list of elements of the tree
     * @param _tree the tree
     * @param _value the input value to find its rank.
     * @return smaller - the number of elements in the tree which their value is
     * less than the input value.
     */
    function rank(Tree storage _tree,uint _value) internal view returns (uint smaller) {
        if (_value != 0) {
            smaller = _tree.nodes[0].dupes;

            uint cur = _tree.nodes[0].children[true];
            Node storage currentNode = _tree.nodes[cur];

            while (true) {
                if (cur <= _value) {
                    if (cur<_value) {
                        smaller = smaller + 1+currentNode.dupes;
                    }
                    uint leftChild = currentNode.children[false];
                    if (leftChild!=0) {
                        smaller = smaller + _tree.nodes[leftChild].count;
                    }
                }
                if (cur == _value) {
                    break;
                }
                cur = currentNode.children[cur<_value];
                if (cur == 0) {
                    break;
                }
                currentNode = _tree.nodes[cur];
            }
        }
    }

    function count(Tree storage _tree) internal view returns (uint) {
        Node storage root = _tree.nodes[0];
        Node memory child = _tree.nodes[root.children[true]];
        return root.dupes+child.count;
    }

    function updateCount(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        n.count = 1+_tree.nodes[n.children[false]].count+_tree.nodes[n.children[true]].count+n.dupes;
    }

    function updateCounts(Tree storage _tree,uint _value) private {
        uint parent = _tree.nodes[_value].parent;
        while (parent!=0) {
            updateCount(_tree,parent);
            parent = _tree.nodes[parent].parent;
        }
    }

    function updateHeight(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        uint heightLeft = _tree.nodes[n.children[false]].height;
        uint heightRight = _tree.nodes[n.children[true]].height;
        if (heightLeft > heightRight)
            n.height = heightLeft+1;
        else
            n.height = heightRight+1;
    }

    function balanceFactor(Tree storage _tree,uint _value) private view returns (int bf) {
        Node storage n = _tree.nodes[_value];
        return int(_tree.nodes[n.children[false]].height)-int(_tree.nodes[n.children[true]].height);
    }

    function rotate(Tree storage _tree,uint _value,bool dir) private {
        bool otherDir = !dir;
        Node storage n = _tree.nodes[_value];
        bool side = n.side;
        uint parent = n.parent;
        uint valueNew = n.children[otherDir];
        Node storage nNew = _tree.nodes[valueNew];
        uint orphan = nNew.children[dir];
        Node storage p = _tree.nodes[parent];
        Node storage o = _tree.nodes[orphan];
        p.children[side] = valueNew;
        nNew.side = side;
        nNew.parent = parent;
        nNew.children[dir] = _value;
        n.parent = valueNew;
        n.side = dir;
        n.children[otherDir] = orphan;
        o.parent = _value;
        o.side = otherDir;
        updateHeight(_tree,_value);
        updateHeight(_tree,valueNew);
        updateCount(_tree,_value);
        updateCount(_tree,valueNew);
    }

    function rebalanceInsert(Tree storage _tree,uint _nValue) private {
        updateHeight(_tree,_nValue);
        Node storage n = _tree.nodes[_nValue];
        uint pValue = n.parent;
        if (pValue!=0) {
            int pBf = balanceFactor(_tree,pValue);
            bool side = n.side;
            int sign;
            if (side)
                sign = -1;
            else
                sign = 1;
            if (pBf == sign*2) {
                if (balanceFactor(_tree,_nValue) == (-1 * sign)) {
                    rotate(_tree,_nValue,side);
                }
                rotate(_tree,pValue,!side);
            } else if (pBf != 0) {
                rebalanceInsert(_tree,pValue);
            }
        }
    }

    function rebalanceDelete(Tree storage _tree,uint _pValue,bool side) private {
        if (_pValue!=0) {
            updateHeight(_tree,_pValue);
            int pBf = balanceFactor(_tree,_pValue);
            int sign;
            if (side)
                sign = 1;
            else
                sign = -1;
            int bf = balanceFactor(_tree,_pValue);
            if (bf==(2*sign)) {
                Node storage p = _tree.nodes[_pValue];
                uint sValue = p.children[!side];
                int sBf = balanceFactor(_tree,sValue);
                if (sBf == (-1 * sign)) {
                    rotate(_tree,sValue,!side);
                }
                rotate(_tree,_pValue,side);
                if (sBf!=0) {
                    p = _tree.nodes[_pValue];
                    rebalanceDelete(_tree,p.parent,p.side);
                }
            } else if (pBf != sign) {
                p = _tree.nodes[_pValue];
                rebalanceDelete(_tree,p.parent,p.side);
            }
        }
    }

    function fixParents(Tree storage _tree,uint parent,bool side) private {
        if (parent!=0) {
            updateCount(_tree,parent);
            updateCounts(_tree,parent);
            rebalanceDelete(_tree,parent,side);
        }
    }

    function insertHelper(Tree storage _tree,uint _pValue,bool _side,uint _value) private {
        Node storage root = _tree.nodes[_pValue];
        uint cValue = root.children[_side];
        if (cValue==0) {
            root.children[_side] = _value;
            Node storage child = _tree.nodes[_value];
            child.parent = _pValue;
            child.side = _side;
            child.height = 1;
            child.count = 1;
            updateCounts(_tree,_value);
            rebalanceInsert(_tree,_value);
        } else if (cValue==_value) {
            _tree.nodes[cValue].dupes++;
            updateCount(_tree,_value);
            updateCounts(_tree,_value);
        } else {
            insertHelper(_tree,cValue,(_value >= cValue),_value);
        }
    }

    function insert(Tree storage _tree,uint _value) internal {
        if (_value==0) {
            _tree.nodes[_value].dupes++;
        } else {
            insertHelper(_tree,0,true,_value);
        }
    }

    function rightmostLeaf(Tree storage _tree,uint _value) private view returns (uint leaf) {
        uint child = _tree.nodes[_value].children[true];
        if (child!=0) {
            return rightmostLeaf(_tree,child);
        } else {
            return _value;
        }
    }

    function zeroOut(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        n.parent = 0;
        n.side = false;
        n.children[false] = 0;
        n.children[true] = 0;
        n.count = 0;
        n.height = 0;
        n.dupes = 0;
    }

    function removeBranch(Tree storage _tree,uint _value,uint _left) private {
        uint ipn = rightmostLeaf(_tree,_left);
        Node storage i = _tree.nodes[ipn];
        uint dupes = i.dupes;
        removeHelper(_tree,ipn);
        Node storage n = _tree.nodes[_value];
        uint parent = n.parent;
        Node storage p = _tree.nodes[parent];
        uint height = n.height;
        bool side = n.side;
        uint ncount = n.count;
        uint right = n.children[true];
        uint left = n.children[false];
        p.children[side] = ipn;
        i.parent = parent;
        i.side = side;
        i.count = ncount+dupes-n.dupes;
        i.height = height;
        i.dupes = dupes;
        if (left!=0) {
            i.children[false] = left;
            _tree.nodes[left].parent = ipn;
        }
        if (right!=0) {
            i.children[true] = right;
            _tree.nodes[right].parent = ipn;
        }
        zeroOut(_tree,_value);
        updateCounts(_tree,ipn);
    }

    function removeHelper(Tree storage _tree,uint _value) private {
        Node storage n = _tree.nodes[_value];
        uint parent = n.parent;
        bool side = n.side;
        Node storage p = _tree.nodes[parent];
        uint left = n.children[false];
        uint right = n.children[true];
        if ((left == 0) && (right == 0)) {
            p.children[side] = 0;
            zeroOut(_tree,_value);
            fixParents(_tree,parent,side);
        } else if ((left != 0) && (right != 0)) {
            removeBranch(_tree,_value,left);
        } else {
            uint child = left+right;
            Node storage c = _tree.nodes[child];
            p.children[side] = child;
            c.parent = parent;
            c.side = side;
            zeroOut(_tree,_value);
            fixParents(_tree,parent,side);
        }
    }

    function remove(Tree storage _tree,uint _value) internal {
        Node storage n = _tree.nodes[_value];
        if (_value==0) {
            if (n.dupes==0) {
                return;
            }
        } else {
            if (n.count==0) {
                return;
            }
        }
        if (n.dupes>0) {
            n.dupes--;
            if (_value!=0) {
                n.count--;
            }
            fixParents(_tree,n.parent,n.side);
        } else {
            removeHelper(_tree,_value);
        }
    }

}

// File: @daostack/infra/contracts/VotingMachines/GenesisProtocol.sol

/**
 * @title GenesisProtocol implementation -an organization's voting machine scheme.
 */
contract GenesisProtocol is IntVoteInterface {
    using SafeMath for uint;
    using RealMath for int216;
    using RealMath for int256;
    using ECRecovery for bytes32;
    using OrderStatisticTree for OrderStatisticTree.Tree;

    enum ProposalState { None ,Closed, Executed, PreBoosted,Boosted,QuietEndingPeriod }
    enum ExecutionState { None, PreBoostedTimeOut, PreBoostedBarCrossed, BoostedTimeOut,BoostedBarCrossed }

    //Organization's parameters
    struct Parameters {
        uint preBoostedVoteRequiredPercentage; // the absolute vote percentages bar.
        uint preBoostedVotePeriodLimit; //the time limit for a proposal to be in an absolute voting mode.
        uint boostedVotePeriodLimit; //the time limit for a proposal to be in an relative voting mode.
        uint thresholdConstA;//constant A for threshold calculation . threshold =A * (e ** (numberOfBoostedProposals/B))
        uint thresholdConstB;//constant B for threshold calculation . threshold =A * (e ** (numberOfBoostedProposals/B))
        uint minimumStakingFee; //minimum staking fee allowed.
        uint quietEndingPeriod; //quite ending period
        uint proposingRepRewardConstA;//constant A for calculate proposer reward. proposerReward =(A*(RTotal) +B*(R+ - R-))/1000
        uint proposingRepRewardConstB;//constant B for calculate proposing reward.proposerReward =(A*(RTotal) +B*(R+ - R-))/1000
        uint stakerFeeRatioForVoters; // The “ratio of stake” to be paid to voters.
                                      // All stakers pay a portion of their stake to all voters, stakerFeeRatioForVoters * (s+ + s-).
                                      //All voters (pre and during boosting period) divide this portion in proportion to their reputation.
        uint votersReputationLossRatio;//Unsuccessful pre booster voters lose votersReputationLossRatio% of their reputation.
        uint votersGainRepRatioFromLostRep; //the percentages of the lost reputation which is divided by the successful pre boosted voters,
                                            //in proportion to their reputation.
                                            //The rest (100-votersGainRepRatioFromLostRep)% of lost reputation is divided between the successful wagers,
                                            //in proportion to their stake.
        uint[2] daoBountyParams; //daoBountyParams[0] = daoBountyConst //The DAO adds up a bounty for successful staker.
                                //The bounty formula is: s * daoBountyConst, where s+ is the wager staked for the proposal,
                                //and  daoBountyConst is a constant factor that is configurable and changeable by the DAO given.
                                //  daoBountyConst should be greater than stakerFeeRatioForVoters and less than 2 * stakerFeeRatioForVoters.
                                //daoBountyParams[1] = daoBountyLimit The daoBounty cannot be greater than daoBountyLimit.
        address voteOnBehalf; //this address is allowd to vote of behalf of someone else.
    }
    struct Voter {
        uint vote; // YES(1) ,NO(2)
        uint reputation; // amount of voter's reputation
        bool preBoosted;
    }

    struct Staker {
        uint vote; // YES(1) ,NO(2)
        uint amount; // amount of staker's stake
        uint amountForBounty; // amount of staker's stake which will be use for bounty calculation
    }

    struct Proposal {
        address organization; // the organization's address the proposal is target to. fullfill genesisProtocol callbacks interface.
        uint numOfChoices;
        uint votersStakes;
        uint submittedTime;
        uint boostedPhaseTime; //the time the proposal shift to relative mode.
        ProposalState state;
        uint winningVote; //the winning vote.
        address proposer;
        uint currentBoostedVotePeriodLimit;
        bytes32 paramsHash;
        uint daoBountyRemain;
        uint[2] totalStakes;// totalStakes[0] - (amount staked minus fee) - Total number of tokens staked which can be redeemable by stakers.
                           // totalStakes[1] - (amount staked) - Total number of redeemable tokens.
        //      vote      reputation
        mapping(uint    =>  uint     ) votes;
        //      vote      reputation
        mapping(uint    =>  uint     ) preBoostedVotes;
        //      address     voter
        mapping(address =>  Voter    ) voters;
        //      vote        stakes
        mapping(uint    =>  uint     ) stakes;
        //      address  staker
        mapping(address  => Staker   ) stakers;
    }

    event Stake(bytes32 indexed _proposalId, address indexed _organization, address indexed _staker,uint _vote,uint _amount);
    event Redeem(bytes32 indexed _proposalId, address indexed _organization, address indexed _beneficiary,uint _amount);
    event RedeemDaoBounty(bytes32 indexed _proposalId, address indexed _organization, address indexed _beneficiary,uint _amount);
    event RedeemReputation(bytes32 indexed _proposalId, address indexed _organization, address indexed _beneficiary,uint _amount);
    event GPExecuteProposal(bytes32 indexed _proposalId, ExecutionState _executionState);

    mapping(bytes32=>Parameters) public parameters;  // A mapping from hashes to parameters
    mapping(bytes32=>Proposal) public proposals; // Mapping from the ID of the proposal to the proposal itself.

    uint constant public NUM_OF_CHOICES = 2;
    uint constant public NO = 2;
    uint constant public YES = 1;
    uint public proposalsCnt; // Total number of proposals
    mapping(address=>uint) public orgBoostedProposalsCnt;
    StandardToken public stakingToken;
    mapping(bytes=>bool) stakeSignatures; //stake signatures
    address constant GEN_TOKEN_ADDRESS = 0x543Ff227F64Aa17eA132Bf9886cAb5DB55DCAddf;
    mapping(address=>OrderStatisticTree.Tree) proposalsExpiredTimes; //proposals expired times

    // Digest describing the data the user signs according EIP 712.
    // Needs to match what is passed to Metamask.
    bytes32 public constant DELEGATION_HASH_EIP712 =
    keccak256(abi.encodePacked("address GenesisProtocolAddress","bytes32 ProposalId", "uint Vote","uint AmountToStake","uint Nonce"));
    // web3.eth.sign prefix
    string public constant ETH_SIGN_PREFIX= "\x19Ethereum Signed Message:\n32";

    /**
     * @dev Constructor
     */
    constructor(StandardToken _stakingToken) public
    {

        if (isContract(address(GEN_TOKEN_ADDRESS))) {
            stakingToken = StandardToken(GEN_TOKEN_ADDRESS);
        } else {
            stakingToken = _stakingToken;
        }
    }

  /**
   * @dev Check that the proposal is votable (open and not executed yet)
   */
    modifier votable(bytes32 _proposalId) {
        require(_isVotable(_proposalId));
        _;
    }

    /**
     * @dev register a new proposal with the given parameters. Every proposal has a unique ID which is being
     * generated by calculating keccak256 of a incremented counter.
     * @param _numOfChoices number of voting choices
     * @param _paramsHash parameters hash
     * @param _proposer address
     * @return proposal's id.
     */
    function propose(uint _numOfChoices, bytes32 _paramsHash,address _proposer)
        external
        returns(bytes32)
    {
              // Check valid params and number of choices:
        require(_numOfChoices == NUM_OF_CHOICES);
         //Check parameters existence.
        require(parameters[_paramsHash].preBoostedVoteRequiredPercentage > 0);
            // Generate a unique ID:
        bytes32 proposalId = keccak256(abi.encodePacked(this, proposalsCnt));
        proposalsCnt++;
         // Open proposal:
        Proposal memory proposal;
        proposal.numOfChoices = _numOfChoices;
        proposal.organization = msg.sender;
        proposal.state = ProposalState.PreBoosted;
        // solium-disable-next-line security/no-block-members
        proposal.submittedTime = now;
        proposal.currentBoostedVotePeriodLimit = parameters[_paramsHash].boostedVotePeriodLimit;
        proposal.proposer = _proposer;
        proposal.winningVote = NO;
        proposal.paramsHash = _paramsHash;
        proposals[proposalId] = proposal;
        //GenesisProtocolCallbacksInterface(proposal.organization).setProposal(proposalId);
        emit NewProposal(proposalId, proposal.organization, _numOfChoices, _proposer, _paramsHash);
        return proposalId;
    }

  /**
   * @dev Cancel a proposal, only the owner can call this function and only if allowOwner flag is true.
   */
    function cancelProposal(bytes32 ) external returns(bool) {
        //This is not allowed.
        return false;
    }

    /**
     * @dev staking function
     * @param _proposalId id of the proposal
     * @param _vote  NO(2) or YES(1).
     * @param _amount the betting amount
     * @return bool true - the proposal has been executed
     *              false - otherwise.
     */
    function stake(bytes32 _proposalId, uint _vote, uint _amount) external returns(bool) {
        return _stake(_proposalId,_vote,_amount,msg.sender);
    }

    /**
     * @dev stakeWithSignature function
     * @param _proposalId id of the proposal
     * @param _vote  NO(2) or YES(1).
     * @param _amount the betting amount
     * @param _nonce nonce value ,it is part of the signature to ensure that
              a signature can be received only once.
     * @param _signatureType signature type
              1 - for web3.eth.sign
              2 - for eth_signTypedData according to EIP #712.
     * @param _signature  - signed data by the staker
     * @return bool true - the proposal has been executed
     *              false - otherwise.
     */
    function stakeWithSignature(
        bytes32 _proposalId,
        uint _vote,
        uint _amount,
        uint _nonce,
        uint _signatureType,
        bytes _signature
        )
        external
        returns(bool)
        {
        require(stakeSignatures[_signature] == false);
        // Recreate the digest the user signed
        bytes32 delegationDigest;
        if (_signatureType == 2) {
            delegationDigest = keccak256(
                abi.encodePacked(
                    DELEGATION_HASH_EIP712, keccak256(
                        abi.encodePacked(
                           address(this),
                          _proposalId,
                          _vote,
                          _amount,
                          _nonce)))
            );
        } else {
            delegationDigest = keccak256(
                abi.encodePacked(
                    ETH_SIGN_PREFIX, keccak256(
                        abi.encodePacked(
                            address(this),
                           _proposalId,
                           _vote,
                           _amount,
                           _nonce)))
            );
        }
        address staker = delegationDigest.recover(_signature);
        //a garbage staker address due to wrong signature will revert due to lack of approval and funds.
        require(staker!=address(0));
        stakeSignatures[_signature] = true;
        return _stake(_proposalId,_vote,_amount,staker);
    }

    /**
     * @dev voting function
     * @param _proposalId id of the proposal
     * @param _vote NO(2) or YES(1).
     * @return bool true - the proposal has been executed
     *              false - otherwise.
     */
    function vote(bytes32 _proposalId, uint _vote,address _voter) external votable(_proposalId) returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        address voter;
        if (params.voteOnBehalf != address(0)) {
            require(msg.sender == params.voteOnBehalf);
            voter = _voter;
        } else {
            voter = msg.sender;
        }
        return internalVote(_proposalId, voter, _vote, 0);
    }

  /**
   * @dev voting function with owner functionality (can vote on behalf of someone else)
   * @return bool true - the proposal has been executed
   *              false - otherwise.
   */
    function ownerVote(bytes32 , uint , address ) external returns(bool) {
      //This is not allowed.
        return false;
    }

    function voteWithSpecifiedAmounts(bytes32 _proposalId,uint _vote,uint _rep,uint,address _voter) external votable(_proposalId) returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        address voter;
        if (params.voteOnBehalf != address(0)) {
            require(msg.sender == params.voteOnBehalf);
            voter = _voter;
        } else {
            voter = msg.sender;
        }
        return internalVote(_proposalId,voter,_vote,_rep);
    }

  /**
   * @dev Cancel the vote of the msg.sender.
   * cancel vote is not allow in genesisProtocol so this function doing nothing.
   * This function is here in order to comply to the IntVoteInterface .
   */
    function cancelVote(bytes32 _proposalId) external votable(_proposalId) {
       //this is not allowed
        return;
    }

  /**
    * @dev getNumberOfChoices returns the number of choices possible in this proposal
    * @param _proposalId the ID of the proposals
    * @return uint that contains number of choices
    */
    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint) {
        return proposals[_proposalId].numOfChoices;
    }

    /**
     * @dev voteInfo returns the vote and the amount of reputation of the user committed to this proposal
     * @param _proposalId the ID of the proposal
     * @param _voter the address of the voter
     * @return uint vote - the voters vote
     *        uint reputation - amount of reputation committed by _voter to _proposalId
     */
    function voteInfo(bytes32 _proposalId, address _voter) external view returns(uint, uint) {
        Voter memory voter = proposals[_proposalId].voters[_voter];
        return (voter.vote, voter.reputation);
    }

    /**
    * @dev voteStatus returns the reputation voted for a proposal for a specific voting choice.
    * @param _proposalId the ID of the proposal
    * @param _choice the index in the
    * @return voted reputation for the given choice
    */
    function voteStatus(bytes32 _proposalId,uint _choice) external view returns(uint) {
        return proposals[_proposalId].votes[_choice];
    }

    /**
    * @dev isVotable check if the proposal is votable
    * @param _proposalId the ID of the proposal
    * @return bool true or false
    */
    function isVotable(bytes32 _proposalId) external view returns(bool) {
        return _isVotable(_proposalId);
    }

    /**
    * @dev proposalStatus return the total votes and stakes for a given proposal
    * @param _proposalId the ID of the proposal
    * @return uint preBoostedVotes YES
    * @return uint preBoostedVotes NO
    * @return uint stakersStakes
    * @return uint totalRedeemableStakes
    * @return uint total stakes YES
    * @return uint total stakes NO
    */
    function proposalStatus(bytes32 _proposalId) external view returns(uint, uint, uint ,uint, uint ,uint) {
        return (
                proposals[_proposalId].preBoostedVotes[YES],
                proposals[_proposalId].preBoostedVotes[NO],
                proposals[_proposalId].totalStakes[0],
                proposals[_proposalId].totalStakes[1],
                proposals[_proposalId].stakes[YES],
                proposals[_proposalId].stakes[NO]
        );
    }

  /**
    * @dev getProposalOrganization return the organization for a given proposal
    * @param _proposalId the ID of the proposal
    * @return uint total reputation supply
    */
    function getProposalOrganization(bytes32 _proposalId) external view returns(address) {
        return (proposals[_proposalId].organization);
    }

  /**
    * @dev scoreThresholdParams return the score threshold params for a given
    * organization.
    * @param _organization the organization's organization
    * @return uint thresholdConstA
    * @return uint thresholdConstB
    */
    /*function scoreThresholdParams(address _organization) external view returns(uint,uint) {
        bytes32 paramsHash = GenesisProtocolCallbacksInterface(_organization).getParametersHash();
        Parameters memory params = parameters[paramsHash];
        return (params.thresholdConstA,params.thresholdConstB);
    }*/

    /**
      * @dev getStaker return the vote and stake amount for a given proposal and staker
      * @param _proposalId the ID of the proposal
      * @param _staker staker address
      * @return uint vote
      * @return uint amount
    */
    function getStaker(bytes32 _proposalId,address _staker) external view returns(uint,uint) {
        return (proposals[_proposalId].stakers[_staker].vote,proposals[_proposalId].stakers[_staker].amount);
    }

    /**
      * @dev voteStake return the amount stakes for a given proposal and vote
      * @param _proposalId the ID of the proposal
      * @param _vote vote number
      * @return uint stake amount
    */
    function voteStake(bytes32 _proposalId,uint _vote) external view returns(uint) {
        return proposals[_proposalId].stakes[_vote];
    }

  /**
    * @dev voteStake return the winningVote for a given proposal
    * @param _proposalId the ID of the proposal
    * @return uint winningVote
    */
    function winningVote(bytes32 _proposalId) external view returns(uint) {
        return proposals[_proposalId].winningVote;
    }

    /**
      * @dev voteStake return the state for a given proposal
      * @param _proposalId the ID of the proposal
      * @return ProposalState proposal state
    */
    function state(bytes32 _proposalId) external view returns(ProposalState) {
        return proposals[_proposalId].state;
    }

   /**
    * @dev isAbstainAllow returns if the voting machine allow abstain (0)
    * @return bool true or false
    */
    function isAbstainAllow() external pure returns(bool) {
        return false;
    }

    /**
     * @dev getAllowedRangeOfChoices returns the allowed range of choices for a voting machine.
     * @return min - minimum number of choices
               max - maximum number of choices
     */
    function getAllowedRangeOfChoices() external pure returns(uint min,uint max) {
        return (NUM_OF_CHOICES,NUM_OF_CHOICES);
    }

    /**
      * @dev execute check if the proposal has been decided, and if so, execute the proposal
      * @param _proposalId the id of the proposal
      * @return bool true - the proposal has been executed
      *              false - otherwise.
     */
    function execute(bytes32 _proposalId) external votable(_proposalId) returns(bool) {
        return _execute(_proposalId);
    }

    /**
     * @dev redeem a reward for a successful stake, vote or proposing.
     * The function use a beneficiary address as a parameter (and not msg.sender) to enable
     * users to redeem on behalf of someone else.
     * @param _proposalId the ID of the proposal
     * @param _beneficiary - the beneficiary address
     * @return rewards -
     *         rewards[0] - stakerTokenAmount
     *         rewards[1] - stakerReputationAmount
     *         rewards[2] - voterTokenAmount
     *         rewards[3] - voterReputationAmount
     *         rewards[4] - proposerReputationAmount
     * @return reputation - redeem reputation
     */
    function redeem(bytes32 _proposalId,address _beneficiary) public returns (uint[5] rewards) {
        Proposal storage proposal = proposals[_proposalId];
        require((proposal.state == ProposalState.Executed) || (proposal.state == ProposalState.Closed),"wrong proposal state");
        Parameters memory params = parameters[proposal.paramsHash];
        uint amount;
        uint reputation;
        uint lostReputation;
        if (proposal.winningVote == YES) {
            lostReputation = proposal.preBoostedVotes[NO];
        } else {
            lostReputation = proposal.preBoostedVotes[YES];
        }
        lostReputation = (lostReputation * params.votersReputationLossRatio)/100;
        //as staker
        Staker storage staker = proposal.stakers[_beneficiary];
        if ((staker.amount>0) &&
             (staker.vote == proposal.winningVote)) {
            uint totalWinningStakes = proposal.stakes[proposal.winningVote];
            if (totalWinningStakes != 0) {
                rewards[0] = (staker.amount * proposal.totalStakes[0]) / totalWinningStakes;
            }
            if (proposal.state != ProposalState.Closed) {
                rewards[1] = (staker.amount * ( lostReputation - ((lostReputation * params.votersGainRepRatioFromLostRep)/100)))/proposal.stakes[proposal.winningVote];
            }
            staker.amount = 0;
        }
        //as voter
        Voter storage voter = proposal.voters[_beneficiary];
        if ((voter.reputation != 0 ) && (voter.preBoosted)) {
            uint preBoostedVotes = proposal.preBoostedVotes[YES] + proposal.preBoostedVotes[NO];
            if (preBoostedVotes>0) {
                rewards[2] = ((proposal.votersStakes * voter.reputation) / preBoostedVotes);
            }
            if (proposal.state == ProposalState.Closed) {
              //give back reputation for the voter
                rewards[3] = ((voter.reputation * params.votersReputationLossRatio)/100);
            } else if (proposal.winningVote == voter.vote ) {
                rewards[3] = (((voter.reputation * params.votersReputationLossRatio)/100) +
                (((voter.reputation * lostReputation * params.votersGainRepRatioFromLostRep)/100)/preBoostedVotes));
            }
            voter.reputation = 0;
        }
        //as proposer
        if ((proposal.proposer == _beneficiary)&&(proposal.winningVote == YES)&&(proposal.proposer != address(0))) {
            rewards[4] = (params.proposingRepRewardConstA.mul(proposal.votes[YES]+proposal.votes[NO]) + params.proposingRepRewardConstB.mul(proposal.votes[YES]-proposal.votes[NO]))/1000;
            proposal.proposer = 0;
        }
        amount = rewards[0] + rewards[2];
        reputation = rewards[1] + rewards[3] + rewards[4];
        if (amount != 0) {
            proposal.totalStakes[1] = proposal.totalStakes[1].sub(amount);
            require(stakingToken.transfer(_beneficiary, amount));
            emit Redeem(_proposalId,proposal.organization,_beneficiary,amount);
        }
        if (reputation != 0 ) {
            GenesisProtocolCallbacksInterface(proposal.organization).mintReputation(reputation,_beneficiary,_proposalId);
            emit RedeemReputation(_proposalId,proposal.organization,_beneficiary,reputation);
        }
    }

    /**
     * @dev redeemDaoBounty a reward for a successful stake, vote or proposing.
     * The function use a beneficiary address as a parameter (and not msg.sender) to enable
     * users to redeem on behalf of someone else.
     * @param _proposalId the ID of the proposal
     * @param _beneficiary - the beneficiary address
     * @return redeemedAmount - redeem token amount
     * @return potentialAmount - potential redeem token amount(if there is enough tokens bounty at the organization )
     */
    function redeemDaoBounty(bytes32 _proposalId,address _beneficiary) public returns(uint redeemedAmount,uint potentialAmount) {
        Proposal storage proposal = proposals[_proposalId];
        require((proposal.state == ProposalState.Executed) || (proposal.state == ProposalState.Closed));
        uint totalWinningStakes = proposal.stakes[proposal.winningVote];
        if (
          // solium-disable-next-line operator-whitespace
            (proposal.stakers[_beneficiary].amountForBounty>0)&&
            (proposal.stakers[_beneficiary].vote == proposal.winningVote)&&
            (proposal.winningVote == YES)&&
            (totalWinningStakes != 0))
        {
            //as staker
            Parameters memory params = parameters[proposal.paramsHash];
            uint beneficiaryLimit = (proposal.stakers[_beneficiary].amountForBounty.mul(params.daoBountyParams[1])) / totalWinningStakes;
            potentialAmount = (params.daoBountyParams[0].mul(proposal.stakers[_beneficiary].amountForBounty))/100;
            if (potentialAmount > beneficiaryLimit) {
                potentialAmount = beneficiaryLimit;
            }
        }
        if ((potentialAmount != 0)&&(stakingToken.balanceOf(proposal.organization) >= potentialAmount)) {
            proposal.daoBountyRemain = proposal.daoBountyRemain.sub(potentialAmount);
            require(GenesisProtocolCallbacksInterface(proposal.organization).stakingTokenTransfer(stakingToken,_beneficiary,potentialAmount,_proposalId));
            proposal.stakers[_beneficiary].amountForBounty = 0;
            redeemedAmount = potentialAmount;
            emit RedeemDaoBounty(_proposalId,proposal.organization,_beneficiary,redeemedAmount);
        }
    }

    /**
     * @dev shouldBoost check if a proposal should be shifted to boosted phase.
     * @param _proposalId the ID of the proposal
     * @return bool true or false.
     */
    function shouldBoost(bytes32 _proposalId) public view returns(bool) {
        Proposal memory proposal = proposals[_proposalId];
        return (_score(_proposalId) >= threshold(proposal.paramsHash,proposal.organization));
    }

    /**
     * @dev score return the proposal score
     * @param _proposalId the ID of the proposal
     * @return uint proposal score.
     */
    function score(bytes32 _proposalId) public view returns(int) {
        return _score(_proposalId);
    }

    /**
     * @dev getBoostedProposalsCount return the number of boosted proposal for an organization
     * @param _organization the organization
     * @return uint number of boosted proposals
     */
    function getBoostedProposalsCount(address _organization) public view returns(uint) {
        uint expiredProposals;
        if (proposalsExpiredTimes[_organization].count() != 0) {
          // solium-disable-next-line security/no-block-members
            expiredProposals = proposalsExpiredTimes[_organization].rank(now);
        }
        return orgBoostedProposalsCnt[_organization].sub(expiredProposals);
    }

    /**
     * @dev threshold return the organization's score threshold which required by
     * a proposal to shift to boosted state.
     * This threshold is dynamically set and it depend on the number of boosted proposal.
     * @param _organization the organization
     * @param _paramsHash the organization parameters hash
     * @return int organization's score threshold.
     */
    function threshold(bytes32 _paramsHash,address _organization) public view returns(int) {
        uint boostedProposals = getBoostedProposalsCount(_organization);
        int216 e = 2;

        Parameters memory params = parameters[_paramsHash];
        require(params.thresholdConstB > 0,"should be a valid parameter hash");
        int256 power = int216(boostedProposals).toReal().div(int216(params.thresholdConstB).toReal());

        if (power.fromReal() > 100 ) {
            power = int216(100).toReal();
        }
        int256 res = int216(params.thresholdConstA).toReal().mul(e.toReal().pow(power));
        return res.fromReal();
    }

    /**
     * @dev hash the parameters, save them if necessary, and return the hash value
     * @param _params a parameters array
     *    _params[0] - _preBoostedVoteRequiredPercentage,
     *    _params[1] - _preBoostedVotePeriodLimit, //the time limit for a proposal to be in an absolute voting mode.
     *    _params[2] -_boostedVotePeriodLimit, //the time limit for a proposal to be in an relative voting mode.
     *    _params[3] -_thresholdConstA
     *    _params[4] -_thresholdConstB
     *    _params[5] -_minimumStakingFee
     *    _params[6] -_quietEndingPeriod
     *    _params[7] -_proposingRepRewardConstA
     *    _params[8] -_proposingRepRewardConstB
     *    _params[9] -_stakerFeeRatioForVoters
     *    _params[10] -_votersReputationLossRatio
     *    _params[11] -_votersGainRepRatioFromLostRep
     *    _params[12] - _daoBountyConst
     *    _params[13] - _daoBountyLimit
    */
    function setParameters(
        uint[14] _params, //use array here due to stack too deep issue.
        address _voteOnBehalf
    )
    public
    returns(bytes32)
    {
        require(_params[0] <= 100 && _params[0] > 0,"0 < preBoostedVoteRequiredPercentage <= 100");
        require(_params[4] > 0 && _params[4] <= 100000000,"0 < thresholdConstB < 100000000 ");
        require(_params[3] <= 100000000 ether,"thresholdConstA <= 100000000 wei");
        require(_params[9] <= 100,"stakerFeeRatioForVoters <= 100");
        require(_params[10] <= 100,"votersReputationLossRatio <= 100");
        require(_params[11] <= 100,"votersGainRepRatioFromLostRep <= 100");
        require(_params[2] >= _params[6],"boostedVotePeriodLimit >= quietEndingPeriod");
        require(_params[7] <= 100000000,"proposingRepRewardConstA <= 100000000");
        require(_params[8] <= 100000000,"proposingRepRewardConstB <= 100000000");
        require(_params[12] <= (2 * _params[9]),"daoBountyConst <= 2 * stakerFeeRatioForVoters");
        require(_params[12] >= _params[9],"daoBountyConst >= stakerFeeRatioForVoters");

        bytes32 paramsHash = getParametersHash(_params,_voteOnBehalf);

        uint[2] memory _daoBountyParams;
        _daoBountyParams[0] = _params[12];
        _daoBountyParams[1] = _params[13];

        parameters[paramsHash] = Parameters({
            preBoostedVoteRequiredPercentage: _params[0],
            preBoostedVotePeriodLimit: _params[1],
            boostedVotePeriodLimit: _params[2],
            thresholdConstA:_params[3],
            thresholdConstB:_params[4],
            minimumStakingFee: _params[5],
            quietEndingPeriod: _params[6],
            proposingRepRewardConstA: _params[7],
            proposingRepRewardConstB:_params[8],
            stakerFeeRatioForVoters:_params[9],
            votersReputationLossRatio:_params[10],
            votersGainRepRatioFromLostRep:_params[11],
            daoBountyParams:_daoBountyParams,
            voteOnBehalf:_voteOnBehalf
        });
        return paramsHash;
    }

  /**
   * @dev hashParameters returns a hash of the given parameters
   */
    function getParametersHash(
        uint[14] _params,//use array here due to stack too deep issue.
        address _voteOnBehalf
    )
        public
        pure
        returns(bytes32)
        {
        //double call to keccak256 to avoid deep stack issue when call with too many params.
        return keccak256(
            abi.encodePacked(
             keccak256(
              abi.encodePacked(
                _params[0],
                _params[1],
                _params[2],
                _params[3],
                _params[4],
                _params[5],
                _params[6],
                _params[7],
                _params[8],
                _params[9],
                _params[10],
                _params[11],
                _params[12],
                _params[13]
             )),
             _voteOnBehalf
        ));
    }

    /**
      * @dev execute check if the proposal has been decided, and if so, execute the proposal
      * @param _proposalId the id of the proposal
      * @return bool true - the proposal has been executed
      *              false - otherwise.
     */
    function _execute(bytes32 _proposalId) internal votable(_proposalId) returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        Proposal memory tmpProposal = proposal;
        uint totalReputation = GenesisProtocolCallbacksInterface(proposal.organization).getTotalReputationSupply(_proposalId);
        uint executionBar = totalReputation * params.preBoostedVoteRequiredPercentage/100;
        ExecutionState executionState = ExecutionState.None;

        if (proposal.state == ProposalState.PreBoosted) {
            // solium-disable-next-line security/no-block-members
            if ((now - proposal.submittedTime) >= params.preBoostedVotePeriodLimit) {
                proposal.state = ProposalState.Closed;
                proposal.winningVote = NO;
                executionState = ExecutionState.PreBoostedTimeOut;
             } else if (proposal.votes[proposal.winningVote] > executionBar) {
              // someone crossed the absolute vote execution bar.
                proposal.state = ProposalState.Executed;
                executionState = ExecutionState.PreBoostedBarCrossed;
               } else if ( shouldBoost(_proposalId)) {
                //the proposal crossed its absolutePhaseScoreLimit or preBoostedVotePeriodLimit
                //change proposal mode to boosted mode.
                proposal.state = ProposalState.Boosted;
                // solium-disable-next-line security/no-block-members
                proposal.boostedPhaseTime = now;
                proposalsExpiredTimes[proposal.organization].insert(proposal.boostedPhaseTime + proposal.currentBoostedVotePeriodLimit);
                orgBoostedProposalsCnt[proposal.organization]++;
              }
           }

        if ((proposal.state == ProposalState.Boosted) ||
            (proposal.state == ProposalState.QuietEndingPeriod)) {
            // solium-disable-next-line security/no-block-members
            if ((now - proposal.boostedPhaseTime) >= proposal.currentBoostedVotePeriodLimit) {
                proposalsExpiredTimes[proposal.organization].remove(proposal.boostedPhaseTime + proposal.currentBoostedVotePeriodLimit);
                proposal.state = ProposalState.Executed;
                orgBoostedProposalsCnt[tmpProposal.organization] = orgBoostedProposalsCnt[tmpProposal.organization].sub(1);
                executionState = ExecutionState.BoostedTimeOut;
             } else if (proposal.votes[proposal.winningVote] > executionBar) {
               // someone crossed the absolute vote execution bar.
                orgBoostedProposalsCnt[tmpProposal.organization] = orgBoostedProposalsCnt[tmpProposal.organization].sub(1);
                proposalsExpiredTimes[proposal.organization].remove(proposal.boostedPhaseTime + proposal.currentBoostedVotePeriodLimit);
                proposal.state = ProposalState.Executed;
                executionState = ExecutionState.BoostedBarCrossed;
            }
       }
        if (executionState != ExecutionState.None) {
            if (proposal.winningVote == YES) {
                uint daoBountyRemain = (params.daoBountyParams[0].mul(proposal.stakes[proposal.winningVote]))/100;
                if (daoBountyRemain > params.daoBountyParams[1]) {
                    daoBountyRemain = params.daoBountyParams[1];
                }
                proposal.daoBountyRemain = daoBountyRemain;
            }
            emit ExecuteProposal(_proposalId, proposal.organization, proposal.winningVote, totalReputation);
            emit GPExecuteProposal(_proposalId, executionState);
            GenesisProtocolExecuteInterface(proposal.organization).executeProposal(_proposalId,int(proposal.winningVote));
            //(tmpProposal.executable).execute(_proposalId, tmpProposal.organization, int(proposal.winningVote));
        }
        return (executionState != ExecutionState.None);
    }

    /**
     * @dev staking function
     * @param _proposalId id of the proposal
     * @param _vote  NO(2) or YES(1).
     * @param _amount the betting amount
     * @return bool true - the proposal has been executed
     *              false - otherwise.
     */
    function _stake(bytes32 _proposalId, uint _vote, uint _amount,address _staker) internal returns(bool) {
        // 0 is not a valid vote.
        require(_vote <= NUM_OF_CHOICES && _vote > 0);
        require(_amount > 0);
        if (_execute(_proposalId)) {
            return true;
        }

        Proposal storage proposal = proposals[_proposalId];

        if (proposal.state != ProposalState.PreBoosted) {
            return false;
        }

        // enable to increase stake only on the previous stake vote
        Staker storage staker = proposal.stakers[_staker];
        if ((staker.amount > 0) && (staker.vote != _vote)) {
            return false;
        }

        uint amount = _amount;
        Parameters memory params = parameters[proposal.paramsHash];
        require(amount >= params.minimumStakingFee);
        require(stakingToken.transferFrom(_staker, address(this), amount));
        proposal.totalStakes[1] = proposal.totalStakes[1].add(amount); //update totalRedeemableStakes
        staker.amount += amount;
        staker.amountForBounty = staker.amount;
        staker.vote = _vote;

        proposal.votersStakes += (params.stakerFeeRatioForVoters * amount)/100;
        proposal.stakes[_vote] = amount.add(proposal.stakes[_vote]);
        amount = amount - ((params.stakerFeeRatioForVoters*amount)/100);
        proposal.totalStakes[0] = amount.add(proposal.totalStakes[0]);
      // Event:
        emit Stake(_proposalId, proposal.organization, _staker, _vote, _amount);
      // execute the proposal if this vote was decisive:
        return _execute(_proposalId);
    }

    /**
     * @dev Vote for a proposal, if the voter already voted, cancel the last vote and set a new one instead
     * @param _proposalId id of the proposal
     * @param _voter used in case the vote is cast for someone else
     * @param _vote a value between 0 to and the proposal's number of choices.
     * @param _rep how many reputation the voter would like to stake for this vote.
     *         if  _rep==0 so the voter full reputation will be use.
     * @return true in case of proposal execution otherwise false
     * throws if proposal is not open or if it has been executed
     * NB: executes the proposal if a decision has been reached
     */
    function internalVote(bytes32 _proposalId, address _voter, uint _vote, uint _rep) private returns(bool) {
        // 0 is not a valid vote.
        require(_vote <= NUM_OF_CHOICES && _vote > 0,"0 < _vote <= 2");
        if (_execute(_proposalId)) {
            return true;
        }

        Parameters memory params = parameters[proposals[_proposalId].paramsHash];
        Proposal storage proposal = proposals[_proposalId];

        // Check voter has enough reputation:
        uint reputation = GenesisProtocolCallbacksInterface(proposal.organization).reputationOf(_voter,_proposalId);
        require(reputation >= _rep,"reputation >= _rep");
        uint rep = _rep;
        if (rep == 0) {
            rep = reputation;
        }
        // If this voter has already voted, return false.
        if (proposal.voters[_voter].reputation != 0) {
            return false;
        }
        // The voting itself:
        proposal.votes[_vote] = rep.add(proposal.votes[_vote]);
        //check if the current winningVote changed or there is a tie.
                //for the case there is a tie the current winningVote set to NO.
        if ((proposal.votes[_vote] > proposal.votes[proposal.winningVote]) ||
           ((proposal.votes[NO] == proposal.votes[proposal.winningVote]) &&
             proposal.winningVote == YES))
        {
            // solium-disable-next-line security/no-block-members
            uint _now = now;
            if ((proposal.state == ProposalState.QuietEndingPeriod) ||
               ((proposal.state == ProposalState.Boosted) && ((_now - proposal.boostedPhaseTime) >= (params.boostedVotePeriodLimit - params.quietEndingPeriod)))) {
                //quietEndingPeriod
                proposalsExpiredTimes[proposal.organization].remove(proposal.boostedPhaseTime + proposal.currentBoostedVotePeriodLimit);
                if (proposal.state != ProposalState.QuietEndingPeriod) {
                    proposal.currentBoostedVotePeriodLimit = params.quietEndingPeriod;
                    proposal.state = ProposalState.QuietEndingPeriod;
                }
                proposal.boostedPhaseTime = _now;
                proposalsExpiredTimes[proposal.organization].insert(proposal.boostedPhaseTime + proposal.currentBoostedVotePeriodLimit);
            }
            proposal.winningVote = _vote;
        }
        proposal.voters[_voter] = Voter({
            reputation: rep,
            vote: _vote,
            preBoosted:(proposal.state == ProposalState.PreBoosted)
        });
        if (proposal.state != ProposalState.Boosted) {
            proposal.preBoostedVotes[_vote] = rep.add(proposal.preBoostedVotes[_vote]);
            uint reputationDeposit = (params.votersReputationLossRatio * rep)/100;
            GenesisProtocolCallbacksInterface(proposal.organization).burnReputation(reputationDeposit,_voter,_proposalId);
        }
        // Event:
        emit VoteProposal(_proposalId, proposal.organization, _voter, _vote, rep);
        // execute the proposal if this vote was decisive:
        return _execute(_proposalId);
    }

    /**
     * @dev _score return the proposal score
     * For dual choice proposal S = (S+) - (S-)
     * @param _proposalId the ID of the proposal
     * @return int proposal score.
     */
    function _score(bytes32 _proposalId) private view returns(int) {
        Proposal storage proposal = proposals[_proposalId];
        return int(proposal.stakes[YES]) - int(proposal.stakes[NO]);
    }

    /**
      * @dev _isVotable check if the proposal is votable
      * @param _proposalId the ID of the proposal
      * @return bool true or false
    */
    function _isVotable(bytes32 _proposalId) private view returns(bool) {
        ProposalState pState = proposals[_proposalId].state;
        return ((pState == ProposalState.PreBoosted)||(pState == ProposalState.Boosted)||(pState == ProposalState.QuietEndingPeriod));
    }

    /**
      * @dev isContract check if a given address is a contract address
      * @param _addr the address to check.
      * @return bool true or false
    */
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
          size := extcodesize(_addr)
        }
        return (size > 0);
    }

}

// File: openzeppelin-solidity/contracts/token/ERC827/ERC827.sol

/**
 * @title ERC827 interface, an extension of ERC20 token standard
 *
 * @dev Interface of a ERC827 token, following the ERC20 standard with extra
 * @dev methods to transfer value and data and execute calls in transfers and
 * @dev approvals.
 */
contract ERC827 is ERC20 {
  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC827/ERC827Token.sol

/* solium-disable security/no-low-level-calls */

pragma solidity ^0.4.23;




/**
 * @title ERC827, an extension of ERC20 token standard
 *
 * @dev Implementation the ERC827, following the ERC20 standard with extra
 * @dev methods to transfer value and data and execute calls in transfers and
 * @dev approvals.
 *
 * @dev Uses OpenZeppelin StandardToken.
 */
contract ERC827Token is ERC827, StandardToken {

  /**
   * @dev Addition to ERC20 token methods. It allows to
   * @dev approve the transfer of value and execute a call with the sent data.
   *
   * @dev Beware that changing an allowance with this method brings the risk that
   * @dev someone may use both the old and the new allowance by unfortunate
   * @dev transaction ordering. One possible solution to mitigate this race condition
   * @dev is to first reduce the spender's allowance to 0 and set the desired value
   * @dev afterwards:
   * @dev https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * @param _spender The address that will spend the funds.
   * @param _value The amount of tokens to be spent.
   * @param _data ABI-encoded contract call to call `_to` address.
   *
   * @return true if the call function was executed successfully
   */
  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.approve(_spender, _value);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens to a specified
   * @dev address and execute a call with the sent data on the same transaction
   *
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   * @param _data ABI-encoded contract call to call `_to` address.
   *
   * @return true if the call function was executed successfully
   */
  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_to != address(this));

    super.transfer(_to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens from one address to
   * @dev another and make a contract call on the same transaction
   *
   * @param _from The address which you want to send tokens from
   * @param _to The address which you want to transfer to
   * @param _value The amout of tokens to be transferred
   * @param _data ABI-encoded contract call to call `_to` address.
   *
   * @return true if the call function was executed successfully
   */
  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public payable returns (bool)
  {
    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * @dev an owner allowed to a spender and execute a call with the sent data.
   *
   * @dev approve should be called when allowed[_spender] == 0. To increment
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until
   * @dev the first transaction is mined)
   * @dev From MonolithDAO Token.sol
   *
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * @dev an owner allowed to a spender and execute a call with the sent data.
   *
   * @dev approve should be called when allowed[_spender] == 0. To decrement
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until
   * @dev the first transaction is mined)
   * @dev From MonolithDAO Token.sol
   *
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {
    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    // solium-disable-next-line security/no-call-value
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

}

// File: contracts/Plantoid.sol

contract Upgradable is GenesisProtocolExecuteInterface {

    uint32 public val = 5;

    function test(uint32 v) public returns(uint32, uint256) {
        val = v;
        return (val, address(this).balance);
    }

    function getTest() public view returns (uint32) {
        return val;
    }
}

contract Proxy  {

    address public ownerX;
    address public _implementation;

    address public artist;
    uint public threshold;

    uint[14] public genesisProtocolParams;

    constructor(address _owner, address _artist, uint _threshold) public {
        ownerX = _owner;
        artist = _artist;
        threshold = _threshold;

    }


    modifier onlyOwnerX() {
        require(msg.sender == ownerX);
        _;
    }

    event Upgraded(address indexed implementation);
    event FallingBack(address indexed implemantion, bytes data);

    function implementation() public view returns (address) {
        return _implementation;
    }

    function upgradeTo(address impl) public onlyOwnerX {
        require(_implementation != impl);
        _implementation = impl;
        emit Upgraded(impl);
// this is a trick to call a constructor in the case of a delegated contract
//        Plantoid(address(this)).setup();
    }

    function () public payable {
        // data = msg.data
        // sender = msg.sender
        // myGovContract.call(sender, data)

        // if (governanceContract.shouldCall(hash(msg.data)) {
        //     call(msg.data)
        // }

        bytes memory data = msg.data;
        address _impl = implementation();
        require(_impl != address(0));

        emit FallingBack(_impl, data);

        assembly {
            let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}

contract Plantoid is GenesisProtocolExecuteInterface, GenesisProtocolCallbacksInterface {

    event GotDonation(address _donor, uint amount);
    event AcceptedDonation(address _donor, uint amount);
    event DebugDonation(address _donor, uint amount, uint _threshold, uint _overflow);
    event Reproducing(uint seedCnt);
    event NewProposal(uint id, bytes32 pid, address _proposer, string url);
    event VotingProposal(uint id, bytes32 pid, address _voter, uint _reputation, bool _voted);
    event VotedProposal(uint id, bytes32 pid, address _voter);
    event WinningProposal(uint id, bytes32 pid, address _proposer);
    event NewVotingMachine(address voteMachine);
    event Execution(bytes32 pid, address addr, int _decision);
    event ReputationOf(address _owner, uint rep);


// NEVER TOUCH
    uint public save1;
    uint public save2;

    address public artist;
    uint public threshold;

    uint[14] public genesisProtocolParams;

    uint public weiRaised;
    uint public seedCnt;

    mapping (uint => Seed) public seeds;
// TILL HERE

    //enum Phase { Capitalisation, Mating, Hiring, Finish }
    //Using "status" instead:
    // - 0: Collecting money
    // - 1: Bidding and Voting
    // - 2: Hiring and Milestones
    // - 3: Reproduction complete
    modifier ifStatus (uint _id, uint _status) {
        require(seeds[_id].status == _status);
        _;
    }

    modifier onlyVotingMachine() {
        require(msg.sender == VoteMachine,"only VotingMachine");
        _;
    }

    struct Proposal {
        bytes32 id;
        address proposer;
        string url;
        uint votes;
        uint block;
    }

    struct Seed {
        uint id;
        uint status;
     //   mapping (address => uint) reputation;
        Reputation reputation;
        mapping(bytes32=>Proposal) proposals;
        uint nProposals;
        mapping (address => bool) voters;
        uint totVotes;
    }

    //mapping between proposal to seed index
    mapping (bytes32=>uint) public pid2id;

// GENESIS PROTOCOL VARIABLES

    address public VoteMachine;
    bytes32 public genesisParams;
    bytes32 public orgHash;


    function init() public {
      genesisProtocolParams = [
      50,     //_preBoostedVoteRequiredPercentage=50,
      1800,     //_preBoostedVotePeriodLimit=60, (in seconds)
      60,     //_boostedVotePeriodLimit=60,
      1,      //_thresholdConstA=1,
      1,      //_thresholdConstB=1,
      0,      //_minimumStakingFee=0,
      0,      //_quietEndingPeriod=0
      60000,      //_proposingRepRewardConstA=60000
      1000,      //_proposingRepRewardConstB=1000
      2,      //_stakerFeeRatioForVoters=10,
      0,      //_votersReputationLossRatio=10
      0,      //_votersGainRepRatioFromLostRep=80
      3,      //_daoBountyConst = 15,
      0      //_daoBountyLimit = 10
      ];
    }

    function setVotingMachine(address voteM) public { //onlyOwnerX {
        require(VoteMachine != voteM);
        VoteMachine = voteM;
        emit NewVotingMachine(VoteMachine);

        //require(orgHash == bytes32(0));
        genesisParams = GenesisProtocol(VoteMachine).setParameters(genesisProtocolParams, address(this));
        orgHash = keccak256(abi.encodePacked(genesisParams, IntVoteInterface(VoteMachine), address(this)));

    }





    // Simple callback function
    function () public payable {
        fund();
    }

    function getBalance() public constant returns(uint256) {
        return address(this).balance;
    }

    function getSeed(uint id) public constant returns(uint _id, uint _status, uint _weis, uint _thres) {
        _status = seeds[id].status;
        _thres = threshold;
        _id = id;
        if (_status == 1) { _weis = threshold; } else { _weis = weiRaised; }
    }

    function addProposal(uint256 id, string url) public ifStatus(id, 1) {
        Seed storage currSeed = seeds[id]; // try with 'memory' instead of 'storage'
        Proposal memory newprop;

        newprop.id = GenesisProtocol(VoteMachine).propose(2, genesisParams, msg.sender);
        //function propose(uint _numOfChoices, bytes32 _paramsHash, address _proposer)

        newprop.proposer = msg.sender;
        newprop.url = url;
        newprop.block = block.number;

        currSeed.proposals[newprop.id] = newprop;
        currSeed.nProposals++;
        emit NewProposal(id, newprop.id, msg.sender, url);

        //add the pid to the pid2id arrays (for the callback interface functions)
        pid2id[newprop.id] = id;

    }




    function voteProposal(uint256 id, bytes32 pid) public ifStatus(id, 1) {

        GenesisProtocol(VoteMachine).vote(pid, 1, msg.sender);
/*        Seed storage currSeed = seeds[id];


        emit VotingProposal(id, pid, msg.sender, currSeed.reputation.reputationOf(msg.sender), currSeed.voters[msg.sender]);


        assert(currSeed.reputation.reputationOf(msg.sender) != 0);
        assert(!currSeed.voters[msg.sender]);

        emit VotedProposal(id, pid, msg.sender);

        currSeed.proposals[pid].votes += currSeed.reputation.reputationOf(msg.sender);
        currSeed.voters[msg.sender] = true;
        currSeed.totVotes += currSeed.reputation.reputationOf(msg.sender);

        // check if we got a winner
        // Absolute majority
        if (currSeed.proposals[pid].votes > threshold / 2) {
            emit WinningProposal(id, pid, currSeed.proposals[pid].proposer);
            currSeed.proposals[pid].proposer.transfer(threshold);
        }
*/
    }

    function nProposals(uint256 id) public constant returns (uint _id, uint n) {
        n = seeds[id].nProposals;
        _id = id;
    }

    function getProposal(uint256 id, bytes32 pid) public constant returns(uint _id, bytes32 _pid, address _from, string _url, uint _votes) {
        _from = seeds[id].proposals[pid].proposer;
        _url = seeds[id].proposals[pid].url;
        _votes = seeds[id].proposals[pid].votes;
        _pid = seeds[id].proposals[pid].id;
        _id = id;
    }

    // External fund function
    function fund() public payable {
    //    require(msg.value > 0);

        uint funds = msg.value;

        // Log that the Plantoid received a new donation
        emit GotDonation(msg.sender, msg.value);

        while (funds > 0) {
            funds = _fund(funds);
        }


    }

    // Internal fund function
    function _fund(uint _donation) internal returns(uint overflow) {

        uint donation;

      // Check if there is an overflow
        if (weiRaised + _donation > threshold) {
            overflow = weiRaised + _donation - threshold;
            donation = threshold - weiRaised;

            emit DebugDonation(msg.sender, _donation, threshold, overflow);

            //emit DebugDonation(0x01, donation);

        } else {
            donation = _donation;

           emit AcceptedDonation(msg.sender, donation);
        }
      // Increase the amount of weiRaised (for that particular Seed)
        weiRaised += donation;


      // instantiate a new Reputation system (DAOstack) if one doesnt exist
      if((seeds[seedCnt].reputation) == Reputation(0)) { seeds[seedCnt].reputation = new Reputation(); }
      // Increase the reputation of the donor (for that particular Seed)
         seeds[seedCnt].reputation.mint(msg.sender, donation);

        if (weiRaised >= threshold) {
            emit Reproducing(seedCnt);
            // change status of the seeds
            seeds[seedCnt].status = 1;

            // Create new Seed:
            seedCnt++;
            //Seed memory newseed; //= Seed(seedCnt, 0, new Proposal[](0)); // 'reputation' member doesn't count
            seeds[seedCnt].id = seedCnt;
            seeds[seedCnt].reputation = new Reputation();
            weiRaised = 0;
            // Feed the new seed if there was an overflow of donations
            // (overflow != 0) {  _fund(overflow); }
        }
    }

// FUNCTIONS for ExecutableInterface

    function execute(bytes32, address , int) public returns(bool) {
    }

// FUNCTIONS for GenesisProtocolCallbacksInterface

    function getTotalReputationSupply(bytes32 pid) external view returns(uint256) {
        uint id = pid2id[pid];
        return seeds[id].reputation.totalSupply();
    }

    function mintReputation(uint _amount,address _beneficiary,bytes32 pid) external onlyVotingMachine returns(bool) {
      uint id = pid2id[pid];
      return seeds[id].reputation.mint(_beneficiary,_amount);
    }

    function burnReputation(uint _amount,address _beneficiary,bytes32 pid) external onlyVotingMachine returns(bool) {
      uint id = pid2id[pid];
      return seeds[id].reputation.burn(_beneficiary,_amount);
    }

    function reputationOf(address _owner,bytes32 pid) view external returns(uint) {
        uint id = pid2id[pid];
        uint rep = seeds[id].reputation.balanceOfAt(_owner, seeds[id].proposals[pid].block);
        return rep;
    }

    function stakingTokenTransfer(StandardToken _stakingToken, address _beneficiary,uint _amount,bytes32) external onlyVotingMachine returns(bool) {
      return _stakingToken.transfer(_beneficiary,_amount);
    }

    function executeProposal(bytes32 pid,int _decision) external onlyVotingMachine returns(bool) {
      emit Execution(pid, 0, _decision);
      return execute(pid, 0, _decision);
    }
}