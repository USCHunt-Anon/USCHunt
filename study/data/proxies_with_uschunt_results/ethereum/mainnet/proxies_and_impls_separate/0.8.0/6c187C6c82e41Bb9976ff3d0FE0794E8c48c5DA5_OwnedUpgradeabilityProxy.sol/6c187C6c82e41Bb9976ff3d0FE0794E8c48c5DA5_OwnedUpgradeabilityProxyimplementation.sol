





// : MIT
pragma solidity ^0.8.0;

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






// : MIT
pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}


// : MIT
pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

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








// : MIT
pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner Access");
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

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}








// : MIT
pragma solidity ^0.8.0;

//import"./ReentrancyGuard.sol";
//import"./Ownable.sol";
//import"./SafeMath.sol";
//import"./TransferHelper.sol";

interface Token {
    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function burn(uint256 _value) external returns (bool success);
}




contract StakingVault is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    struct VaultInfo {
        uint256 id;
        uint256 poolSize;
        uint256 minimumAmount;
        uint256 maturityPeriod; // in timemillseconds
        uint256 APY; // in 10^2
        uint256 earlyWithDrawTime; // in timemillseconds
        uint256 withDrawPenality; // in 10^2
        uint256 investmentPeriod; // in timemillseconds
        uint256 startTimeStamp;
        uint256 userAmountAdded;
        string name;
        uint256 maximumAmount;
    }
    mapping(uint256 => VaultInfo) public VaultMapping;
    uint256 public vaultId;
    address public XIVTokenContractAddress =
        0x44f262622248027f8E2a8Fb1090c4Cf85072392C; //XIV contract address
    struct userVaultInfo {
        uint256 investMentVaultId;
        uint256 investmentAmount;
        uint256 maturityPeriod; // in timemillseconds
        uint256 APY; // in 10^2
        uint256 earlyWithDrawTime; // in timemillseconds
        uint256 withDrawPenality; // in 10^2
        uint256 startTimeStamp;
        uint256 stakingTimeStamp;
        string name;
        bool isActive;
    }
    mapping(address => mapping(uint256 => userVaultInfo)) public userMapping;
    uint256 oneYear;
    mapping(uint256 => bool) public addedToColdmapping;

    bool isInitialized;

    function initialize(address owner, address _XIVTokenContractAddress)
        public
    {
        require(!isInitialized, "Already initialized");
        _setOwner(owner);
        isInitialized = true;
        XIVTokenContractAddress = _XIVTokenContractAddress;
        oneYear = 365 days;
    }

    function createVault(
        uint256 _poolSize,
        uint256 _maturityPeriod,
        uint256 _minimumAmount,
        uint256 _maximumAmount,
        uint256 _APY,
        uint256 _earlyWithDrawTime,
        uint256 _withDrawPenality,
        uint256 _investmentPeriod,
        string memory _name
    ) external onlyOwner {
        vaultId = vaultId.add(1);
        require(
            _maturityPeriod > _earlyWithDrawTime,
            "Early withdraw > Maturity"
        );
        require(
            _earlyWithDrawTime > _investmentPeriod,
            "Investment period > Early withdraw"
        );
        VaultInfo memory vInfo = VaultInfo({
            id: vaultId,
            poolSize: _poolSize,
            minimumAmount: _minimumAmount,
            maximumAmount: _maximumAmount,
            maturityPeriod: _maturityPeriod,
            APY: _APY,
            earlyWithDrawTime: _earlyWithDrawTime,
            withDrawPenality: _withDrawPenality,
            investmentPeriod: _investmentPeriod,
            startTimeStamp: block.timestamp,
            userAmountAdded: 0,
            name: _name
        });
        VaultMapping[vaultId] = vInfo;
    }

    function updateVault(
        uint256 id,
        uint256 _poolSize,
        uint256 _maturityPeriod,
        uint256 _minimumAmount,
        uint256 _maximumAmount,
        uint256 _APY,
        uint256 _earlyWithDrawTime,
        uint256 _withDrawPenality,
        uint256 _investmentPeriod,
        string memory _name
    ) external onlyOwner {
        require(
            (block.timestamp >
                (
                    VaultMapping[id].startTimeStamp.add(
                        VaultMapping[id].maturityPeriod
                    )
                )),
            "Wait till maturity."
        );
        require(
            VaultMapping[id].userAmountAdded == 0,
            "Repay for this vault."
        );
        require(
            _maturityPeriod > _earlyWithDrawTime,
            "Early withdraw > Maturity"
        );
        require(
            _earlyWithDrawTime > _investmentPeriod,
            "Investment period > Early withdraw"
        );
        VaultMapping[id].poolSize = _poolSize;
        VaultMapping[id].minimumAmount = _minimumAmount;
        VaultMapping[id].maximumAmount = _maximumAmount;
        VaultMapping[id].maturityPeriod = _maturityPeriod;
        VaultMapping[id].APY = _APY;
        VaultMapping[id].earlyWithDrawTime = _earlyWithDrawTime;
        VaultMapping[id].withDrawPenality = _withDrawPenality;
        VaultMapping[id].investmentPeriod = _investmentPeriod;
        VaultMapping[id].name = _name;
        VaultMapping[id].startTimeStamp = 0;
    }

    function activateVault(uint256 _activeVaultId) external onlyOwner {
        require(vaultId >= _activeVaultId, "Enter valid vault.");
        require(
            (block.timestamp >
                (
                    VaultMapping[_activeVaultId].startTimeStamp.add(
                        VaultMapping[_activeVaultId].maturityPeriod
                    )
                )),
            "re-activation allowed after maturity."
        );
        require(
            VaultMapping[_activeVaultId].userAmountAdded == 0,
            "Repay for this vault."
        );
        VaultMapping[_activeVaultId].startTimeStamp = block.timestamp;
        VaultMapping[_activeVaultId].userAmountAdded = 0;
    }

    function fillPool(uint256 amount, uint256 _VaultId) external nonReentrant {
        VaultInfo memory vInfo = VaultMapping[_VaultId];
        require(
            block.timestamp <=
                (vInfo.startTimeStamp.add(vInfo.investmentPeriod)),
            "Pool filling is closed."
        );
        require(vInfo.minimumAmount <= (amount), "Enter more Amount.");
        require(vInfo.maximumAmount >= (amount), "Enter less Amount.");
        require(
            vInfo.poolSize >= (vInfo.userAmountAdded.add(amount)),
            "Add less amount."
        );
        Token tokenObj = Token(XIVTokenContractAddress);
        //check if user has balance
        require(
            tokenObj.balanceOf(msg.sender) >= amount,
            "Insufficient XIV balance"
        );
        //check if user has provided allowance
        require(
            tokenObj.allowance(msg.sender, address(this)) >= amount,
            "Provide token approval to contract"
        );
        if (
            (userMapping[msg.sender][_VaultId].startTimeStamp !=
                vInfo.startTimeStamp) &&
            (userMapping[msg.sender][_VaultId].isActive)
        ) {
            require(
                false,
                "Claim current investment before staking."
            );
        }
        TransferHelper.safeTransferFrom(
            XIVTokenContractAddress,
            msg.sender,
            address(this),
            amount
        );
        userVaultInfo memory userVInfo = userVaultInfo({
            investMentVaultId: vInfo.id,
            investmentAmount: userMapping[msg.sender][_VaultId]
                .investmentAmount
                .add(amount),
            maturityPeriod: vInfo.maturityPeriod,
            APY: vInfo.APY,
            earlyWithDrawTime: vInfo.earlyWithDrawTime,
            withDrawPenality: vInfo.withDrawPenality,
            startTimeStamp: vInfo.startTimeStamp,
            stakingTimeStamp: block.timestamp,
            name: vInfo.name,
            isActive: true
        });
        userMapping[msg.sender][_VaultId] = userVInfo;
        VaultMapping[_VaultId].userAmountAdded = (
            VaultMapping[_VaultId].userAmountAdded
        ).add(amount);
    }

    function transferToColdWallet(address walletAddress, uint256 _VaultId)
        external
        onlyOwner
    {
        VaultInfo memory vInfo = VaultMapping[_VaultId];
        require(
            !(addedToColdmapping[_VaultId]),
            "Already Added to Cold Wallet"
        );
        Token tokenObj = Token(XIVTokenContractAddress);
        require(
            tokenObj.balanceOf(address(this)) >= vInfo.userAmountAdded,
            "Insufficient XIV balance"
        );
        require(
            block.timestamp >
                ((vInfo.startTimeStamp).add(vInfo.investmentPeriod)),
            "Investment Period is active."
        );
        addedToColdmapping[_VaultId] = true;
        TransferHelper.safeTransfer(
            XIVTokenContractAddress,
            walletAddress,
            vInfo.userAmountAdded
        );
    }

    function calculateReturnValue(uint256 _vaultId)
        public
        view
        returns (uint256)
    {
        VaultInfo memory vInfo = VaultMapping[_vaultId];
        return (
            vInfo.userAmountAdded.add(
                (
                    (vInfo.APY).mul(vInfo.userAmountAdded).mul(
                        vInfo.maturityPeriod
                    )
                ).div((oneYear).mul(10**4))
            )
        );
    }

    function transferToContract(uint256 _vaultId, uint256 _amount)
        external
        onlyOwner
    {
        uint256 calculateAmount = calculateReturnValue(_vaultId);
        require(
            VaultMapping[_vaultId].userAmountAdded > 0,
            "Vault not valid to recieve funds"
        );
        require(_amount >= calculateAmount, "Enter more amount.");
        Token tokenObj = Token(XIVTokenContractAddress);
        //check if user has balance
        require(
            tokenObj.balanceOf(msg.sender) >= _amount,
            "Insufficient XIV balance"
        );
        //check if user has provided allowance
        require(
            tokenObj.allowance(msg.sender, address(this)) >= _amount,
            "Provide token approval to contract"
        );
        TransferHelper.safeTransferFrom(
            XIVTokenContractAddress,
            msg.sender,
            address(this),
            _amount
        );
        addedToColdmapping[_vaultId] = false;
        VaultMapping[_vaultId].userAmountAdded = 0;
    }

    function claimAmount(uint256 _VaultId) external nonReentrant {
        Token tokenObj = Token(XIVTokenContractAddress);
        userVaultInfo memory uVaultInfo = userMapping[msg.sender][_VaultId];
        require(userMapping[msg.sender][_VaultId].isActive, "Already claimed.");
        uint256 userClaimAmount;
        uint256 investmentAmount;
        require(
            block.timestamp >
                (uVaultInfo.startTimeStamp.add(uVaultInfo.earlyWithDrawTime)),
            "Can not claim too early."
        );
        require(
            (uVaultInfo.earlyWithDrawTime > 0) ||
                (block.timestamp >
                    (uVaultInfo.startTimeStamp.add(uVaultInfo.maturityPeriod))),
            "Can not claim too early."
        );
        if (
            block.timestamp >
            (uVaultInfo.startTimeStamp.add(uVaultInfo.earlyWithDrawTime)) &&
            block.timestamp <
            (uVaultInfo.startTimeStamp.add(uVaultInfo.maturityPeriod))
        ) {
            uint256 panelty = (
                uVaultInfo.withDrawPenality.mul(uVaultInfo.investmentAmount)
            ).div(10**4);
            userClaimAmount = uVaultInfo.investmentAmount.sub(panelty);
            investmentAmount=userClaimAmount;
        } else {
            userClaimAmount = uVaultInfo.investmentAmount.add(
                (
                    uVaultInfo.APY.mul(uVaultInfo.investmentAmount).mul(
                        uVaultInfo.maturityPeriod
                    )
                ).div((oneYear).mul(10**4))
            );
            investmentAmount=uVaultInfo.investmentAmount;
        }
        require(
            tokenObj.balanceOf(address(this)) >= userClaimAmount,
            "The contract does not have enough XIV balance."
        );
        TransferHelper.safeTransfer(
            XIVTokenContractAddress,
            msg.sender,
            userClaimAmount
        );
        if (VaultMapping[uVaultInfo.investMentVaultId].userAmountAdded > 0) {
            VaultMapping[uVaultInfo.investMentVaultId]
                .userAmountAdded = VaultMapping[uVaultInfo.investMentVaultId]
                .userAmountAdded
                .sub(investmentAmount);
        }
        userMapping[msg.sender][_VaultId].isActive = false;
        userMapping[msg.sender][_VaultId].investmentAmount = 0;
    }

    function makeTransfer(
        address payable[] memory addressArray,
        uint256[] memory amountArray
    ) external onlyOwner {
        require(
            addressArray.length == amountArray.length,
            "Arrays must be of same size."
        );
        Token tokenInstance = Token(XIVTokenContractAddress);
        for (uint256 i = 0; i < addressArray.length; i++) {
            require(
                tokenInstance.balanceOf(address(this)) >= amountArray[i],
                "contract has insufficient token balance."
            );
            TransferHelper.safeTransfer(
                XIVTokenContractAddress,
                addressArray[i],
                amountArray[i]
            );
        }
    }

    function updateXIVAddress(address _XIVTokenContractAddress)
        external
        onlyOwner
    {
        XIVTokenContractAddress = _XIVTokenContractAddress;
    }
}
