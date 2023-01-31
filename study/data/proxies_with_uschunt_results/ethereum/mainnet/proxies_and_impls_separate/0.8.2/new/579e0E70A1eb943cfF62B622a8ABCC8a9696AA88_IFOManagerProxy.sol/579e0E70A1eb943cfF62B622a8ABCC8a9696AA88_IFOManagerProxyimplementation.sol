/**
 *Submitted for verification at BscScan.com on 2021-12-01
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/IFOManagerImpl.sol

//: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



contract IFOManagerImpl {

    using SafeMath for uint256;

    bytes32 public constant OWNER_SLOT = bytes32(keccak256("IFOManagerProxy.owner"));
    
    modifier onlyOwner() {
        address owner = _getOwner();
        require(msg.sender == owner, "IFOManagerImpl/onlyOwner not a owner");
        _;
    }

    function _getOwner() internal view returns (address) {
        bytes32 ownerSlot = OWNER_SLOT;
        address owner;
        assembly{
            owner := sload(ownerSlot)
        }
        return owner;
    }

    function getBalanceBNB() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalanceERC20(address erc20Addr) public view returns (uint256) {
        return IERC20(erc20Addr).balanceOf(address(this));
    }




    //BNB related
    //deposit BNB
    receive() payable external {}
    //distribute BNB
    function distributeBNB(address[] memory executors, uint256[] memory amounts)
            public
            onlyOwner
    {
        require(executors.length == amounts.length, "IFOManagerImpl/distrubuteBNB the len doesnt match");
        uint256 totalBalanceOfBNB = getBalanceBNB();
        uint256 totalAmounts;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmounts = totalAmounts.add(amounts[i]);
        }
        require(totalAmounts < totalBalanceOfBNB, "IFOManagerImpl/distributeBNB amounts exceeds the balance, please deposit bnb");
        for (uint i = 0; i < amounts.length; i++) {
            address payable executor = payable(executors[i]);
            uint256 amount = amounts[i];
            executor.transfer(amount);
        }

    }
    //withdraw BNB
    function withdrawBNB() public onlyOwner {
        uint256 totalBalance = getBalanceBNB();
        address owner = _getOwner();
        payable(owner).transfer(totalBalance);
    }

    //token related
    //deposite ERC20
    function depositERC20(address erc20Addr, uint256 amount) public {
        uint256 userBalance = IERC20(erc20Addr).balanceOf(msg.sender);
        require(userBalance >= amount, "IFOManagerImpl/depositERC20 user account's balance is not sufficient");
        uint256 userAllowance = IERC20(erc20Addr).allowance(msg.sender,address(this));
        require(userAllowance >= amount, "IFOManagerImpl/depositERC20 please approve this contract first");

        uint256 balanceBefore = IERC20(erc20Addr).balanceOf(address(this));
        IERC20(erc20Addr).transferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = IERC20(erc20Addr).balanceOf(address(this));

        require(balanceAfter > balanceBefore, "IFOManager/depositERC20 please deposit greater than 0");



    }
    //distribute erc20
    function distributeERC20(address erc20Addr, address[] memory executors, uint256[] memory amounts)
        public
        onlyOwner
    {
        require(executors.length == amounts.length, "IFOManagerImpl/distributeERC20 the len doesn't match");
        uint256 totalBalanceOfERC20 = getBalanceERC20(erc20Addr);
        uint256 totalAmounts;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmounts = totalAmounts.add(amounts[i]);
        }
        require(totalBalanceOfERC20 > totalAmounts, "IFOManager/depositERC20 not enough erc20 to distribute, please deposit");
        for (uint i = 0; i < amounts.length; i++) {
            IERC20(erc20Addr).transfer(executors[i], amounts[i]);
        }
    
    }
    //withdraw erc20
    function withdrawERC20(address erc20Addr) public onlyOwner {
        uint256 totalBalanceOfERC20 = getBalanceERC20(erc20Addr);
        address owner = _getOwner();
        IERC20(erc20Addr).transfer(owner, totalBalanceOfERC20);
    }
    //reclaim erc20
    function reclaimERC20(address erc20Addr, address[] memory executors) 
        public
        onlyOwner
    {
        for (uint i; i < executors.length; i++) {
            uint256 allowance = IERC20(erc20Addr).allowance(executors[i], address(this));
            require(allowance > 0, "IFOManagerImpl/reclaimERC20 executor must approve it first!");
            uint256 balanceERC20 = IERC20(erc20Addr).balanceOf(executors[i]);
            if (balanceERC20 > 0) {
                IERC20(erc20Addr).transferFrom(executors[i], address(this), balanceERC20);
            }
        }
    }



}