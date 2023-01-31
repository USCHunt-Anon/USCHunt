// : UNLICENCED
pragma solidity >=0.6.0 <0.8.0;

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor(){
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
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




// : UNLICENCED
pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;

//import"./Ownable.sol";
//import"./SafeMath.sol";


interface OracleInterface{
    function latestAnswer() external view returns (int256);
}

interface tellorInterface{
     function getLastNewValueById(uint _requestId) external view returns(uint,bool);
}

interface uniswapInterface{
     function getAmountsOut(uint amountIn, address[] memory path)
        external view returns (uint[] memory amounts);
}
interface Token{
    function decimals() external view returns(uint256);
}
contract OracleWrapperInverse is Ownable{
    
    using SafeMath for uint256;
    address public tellerContractAddress=0x0Ba45A8b5d5575935B8158a88C631E9F9C95a2e5;
    address public UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public usdtContractAddress = 0xBbf126a88DE8c993BFe67c46Bb333a2eC71bC3fF;
    struct TellorInfo{
        uint256 id;
        uint256 tellorPSR;
    }
    uint256 tellorId=1;
    mapping(string=>address) public typeOneMapping;  // chainlink
    string[] typeOneArray;
    mapping(string=> TellorInfo) public typeTwomapping; // tellor
    string[] typeTwoArray;
    mapping(string=> address) public typeThreemapping; // uniswap
    string[] typeThreeArray;
   
    function updateTellerContractAddress(address newAddress) public onlyOwner{
        tellerContractAddress = newAddress;
    }
    
    function addTypeOneMapping(string memory currencySymbol, address chainlinkAddress) external onlyOwner{
        typeOneMapping[currencySymbol]=chainlinkAddress;
        if(!checkAddressIfExists(typeOneArray,currencySymbol)){
            typeOneArray.push(currencySymbol);
        }
    }
    
    function addTypeTwoMapping(string memory currencySymbol, uint256 tellorPSR) external onlyOwner{
        TellorInfo memory tInfo= TellorInfo({
            id:tellorId,
            tellorPSR:tellorPSR
        });
        typeTwomapping[currencySymbol]=tInfo;
        tellorId++;
        if(!checkAddressIfExists(typeTwoArray,currencySymbol)){
            typeTwoArray.push(currencySymbol);
        }
    }
    
    function addTypeThreeMapping(string memory currencySymbol, address tokenContractAddress) external onlyOwner{
        typeThreemapping[currencySymbol]=tokenContractAddress;
        if(!checkAddressIfExists(typeThreeArray,currencySymbol)){
            typeThreeArray.push(currencySymbol);
        }
    }
    function checkAddressIfExists(string[] memory arr, string memory currencySymbol) internal pure returns(bool){
        for(uint256 i=0;i<arr.length;i++){
            if((keccak256(abi.encodePacked(arr[i]))) == (keccak256(abi.encodePacked(currencySymbol)))){
                return true;
            }
        }
        return false;
    }
    function getPrice(string memory currencySymbol,
        uint256 oracleType) external view returns (uint256){
        //oracletype 1 - chainlink and  for teller --2, uniswap---3
        if(oracleType == 1){
            require(typeOneMapping[currencySymbol]!=address(0), "please enter valid currency");
            OracleInterface oObj = OracleInterface(typeOneMapping[currencySymbol]);
            return uint256(oObj.latestAnswer());
        }
        else if(oracleType ==2){
            require(typeTwomapping[currencySymbol].id!=0, "please enter valid currency");
            tellorInterface tObj = tellorInterface(tellerContractAddress);
            uint256 actualFiatPrice;
            bool statusTellor;
            (actualFiatPrice,statusTellor) = tObj.getLastNewValueById(typeTwomapping[currencySymbol].tellorPSR);
            return uint256(actualFiatPrice);
        }else{
            require(typeThreemapping[currencySymbol]!=address(0), "please enter valid currency");
            uniswapInterface uObj = uniswapInterface(UniswapV2Router02);
            address[] memory path = new address[](2);
            path[0] = typeThreemapping[currencySymbol];
            path[1] = usdtContractAddress;
            uint[] memory values=uObj.getAmountsOut(10**(Token(typeThreemapping[currencySymbol]).decimals()),path);
            uint256 usdtDecimals=Token(usdtContractAddress).decimals();
            if(usdtDecimals==8){
                return uint256(values[1]);
            }else{
                return uint256(values[1].mul(10**(8-usdtDecimals)));
            }
        }
    }
    
    function getTypeOneArray() external view returns(string[] memory){
        return typeOneArray;
    }
    
    function getTypeTwoArray() external view returns(string[] memory){
        return typeTwoArray;
    }
    function getTypeThreeArray() external view returns(string[] memory){
        return typeThreeArray;
    }
    function updateUniswapV2Router02(address _UniswapV2Router02) external onlyOwner{
        UniswapV2Router02=_UniswapV2Router02;
    }
    function updateUSDTContractAddress(address _usdtContractAddress) external onlyOwner{
        usdtContractAddress=_usdtContractAddress;
    }
}




