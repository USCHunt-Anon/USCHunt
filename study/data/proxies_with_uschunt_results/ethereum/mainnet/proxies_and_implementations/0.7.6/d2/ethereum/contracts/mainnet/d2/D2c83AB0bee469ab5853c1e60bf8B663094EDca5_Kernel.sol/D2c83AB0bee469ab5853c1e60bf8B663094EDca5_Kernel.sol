// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import "./interfaces/IDiamondCut.sol";
//import "./interfaces/IDiamondLoupe.sol";
//import "./libraries/LibDiamond.sol";
//import "./libraries/LibOwnership.sol";
//import "./libraries/LibDiamondStorage.sol";
//import "./interfaces/IERC165.sol";
//import "./interfaces/IERC173.sol";

contract Kernel {
    constructor(IDiamondCut.FacetCut[] memory _diamondCut, address _owner) payable {
        require(_owner != address(0), "owner must not be 0x0");

        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
        LibOwnership.setContractOwner(_owner);

        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        address facet = address(bytes20(ds.facets[msg.sig].facetAddress));
        require(facet != address(0), "Diamond: Function does not exist");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }

    receive() external payable {}
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

interface IDiamondCut {
    enum FacetCutAction {Add, Replace, Remove}
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _diamondCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

// A loupe is a small magnifying glass used to look at diamonds.
// These functions look at diamonds
interface IDiamondLoupe {
    /// These functions are expected to be called frequently
    /// by tools.

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Gets all facet addresses and their four byte function selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors_
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

//import "../interfaces/IDiamondCut.sol";
//import "./LibDiamondStorage.sol";

library LibDiamond {
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    // Internal function version of diamondCut
    // This code is almost the same as the external diamondCut,
    // except it is using 'Facet[] memory _diamondCut' instead of
    // 'Facet[] calldata _diamondCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        uint256 selectorCount = LibDiamondStorage.diamondStorage().selectors.length;

        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            selectorCount = executeDiamondCut(selectorCount, _diamondCut[facetIndex]);
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        initializeDiamondCut(_init, _calldata);
    }

    // executeDiamondCut takes one single FacetCut action and executes it
    // if FacetCutAction can't be identified, it reverts
    function executeDiamondCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        require(cut.functionSelectors.length > 0, "LibDiamond: No selectors in facet to cut");

        if (cut.action == IDiamondCut.FacetCutAction.Add) {
            require(cut.facetAddress != address(0), "LibDiamond: add facet address can't be address(0)");
            enforceHasContractCode(cut.facetAddress, "LibDiamond: add facet must have code");

            return _handleAddCut(selectorCount, cut);
        }

        if (cut.action == IDiamondCut.FacetCutAction.Replace) {
            require(cut.facetAddress != address(0), "LibDiamond: remove facet address can't be address(0)");
            enforceHasContractCode(cut.facetAddress, "LibDiamond: remove facet must have code");

            return _handleReplaceCut(selectorCount, cut);
        }

        if (cut.action == IDiamondCut.FacetCutAction.Remove) {
            require(cut.facetAddress == address(0), "LibDiamond: remove facet address must be address(0)");

            return _handleRemoveCut(selectorCount, cut);
        }

        revert("LibDiamondCut: Incorrect FacetCutAction");
    }

    // _handleAddCut executes a cut with the type Add
    // it reverts if the selector already exists
    function _handleAddCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            address oldFacetAddress = ds.facets[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");

            ds.facets[selector] = LibDiamondStorage.Facet(
                cut.facetAddress,
                uint16(selectorCount)
            );
            ds.selectors.push(selector);

            selectorCount++;
        }

        return selectorCount;
    }

    // _handleReplaceCut executes a cut with the type Replace
    // it does not allow replacing immutable functions
    // it does not allow replacing with the same function
    // it does not allow replacing a function that does not exist
    function _handleReplaceCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            address oldFacetAddress = ds.facets[selector].facetAddress;

            // only useful if immutable functions exist
            require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
            require(oldFacetAddress != cut.facetAddress, "LibDiamondCut: Can't replace function with same function");
            require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");

            // replace old facet address
            ds.facets[selector].facetAddress = cut.facetAddress;
        }

        return selectorCount;
    }

    // _handleRemoveCut executes a cut with the type Remove
    // for efficiency, the selector to be deleted is replaced with the last one and then the last one is popped
    // it reverts if the function doesn't exist or it's immutable
    function _handleRemoveCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            LibDiamondStorage.Facet memory oldFacet = ds.facets[selector];

            require(oldFacet.facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
            require(oldFacet.facetAddress != address(this), "LibDiamondCut: Can't remove immutable function.");

            // replace selector with last selector
            if (oldFacet.selectorPosition != selectorCount - 1) {
                bytes4 lastSelector = ds.selectors[selectorCount - 1];
                ds.selectors[oldFacet.selectorPosition] = lastSelector;
                ds.facets[lastSelector].selectorPosition = oldFacet.selectorPosition;
            }

            // delete last selector
            ds.selectors.pop();
            delete ds.facets[selector];

            selectorCount--;
        }

        return selectorCount;
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but _calldata is not empty");
            return;
        }

        require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
        if (_init != address(this)) {
            enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
        }

        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                // bubble up the error
                revert(string(error));
            } else {
                revert("LibDiamondCut: _init function reverted");
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

//import "./LibDiamondStorage.sol";

library LibOwnership {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        address previousOwner = ds.contractOwner;
        require(previousOwner != _newOwner, "Previous owner and new owner must be different");

        ds.contractOwner = _newOwner;

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = LibDiamondStorage.diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() view internal {
        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
    }

    modifier onlyOwner {
        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
        _;
    }
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

library LibDiamondStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct Facet {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => Facet) facets;
        bytes4[] selectors;

        // ERC165
        mapping(bytes4 => bool) supportedInterfaces;

        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;
//pragma experimental ABIEncoderV2;

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// ////-License-Identifier: Apache-2.0
pragma solidity 0.7.6;

/// @title ERC-173 Contract Ownership Standard
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
/* is ERC165 */
interface IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Get the address of the owner
    /// @return owner_ The address of the owner.
    function owner() external view returns (address owner_);

    /// @notice Set the address of the new owner of the contract
    /// @dev Set _newOwner to address(0) to renounce any ownership.
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}



// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"../libraries/LibKernelStorage.sol";

interface IKernel {
    // deposit allows a user to add more entr to his staked balance
    function deposit(uint256 amount) external;

    // withdraw allows a user to withdraw funds if the balance is not locked
    function withdraw(uint256 amount) external;

    // lock a user's currently staked balance until timestamp & add the bonus to his voting power
    function lock(uint256 timestamp) external;

    // delegate allows a user to delegate his voting power to another user
    function delegate(address to) external;

    // stopDelegate allows a user to take back the delegated voting power
    function stopDelegate() external;

    // lock the balance of a proposal creator until the voting ends; only callable by DAO
    function lockCreatorBalance(address user, uint256 timestamp) external;

    // balanceOf returns the current ENTR balance of a user (bonus not included)
    function balanceOf(address user) external view returns (uint256);

    // balanceAtTs returns the amount of ENTR that the user currently staked (bonus NOT included)
    function balanceAtTs(address user, uint256 timestamp) external view returns (uint256);

    // stakeAtTs returns the Stake object of the user that was valid at `timestamp`
    function stakeAtTs(address user, uint256 timestamp) external view returns (LibKernelStorage.Stake memory);

    // votingPower returns the voting power (bonus included) + delegated voting power for a user at the current block
    function votingPower(address user) external view returns (uint256);

    // votingPowerAtTs returns the voting power (bonus included) + delegated voting power for a user at a point in time
    function votingPowerAtTs(address user, uint256 timestamp) external view returns (uint256);

    // entrStaked returns the total raw amount of ENTR staked at the current block
    function entrStaked() external view returns (uint256);

    // entrStakedAtTs returns the total raw amount of ENTR users have deposited into the contract
    // it does not include any bonus
    function entrStakedAtTs(uint256 timestamp) external view returns (uint256);

    // delegatedPower returns the total voting power that a user received from other users
    function delegatedPower(address user) external view returns (uint256);

    // delegatedPowerAtTs returns the total voting power that a user received from other users at a point in time
    function delegatedPowerAtTs(address user, uint256 timestamp) external view returns (uint256);

    // multiplierAtTs calculates the multiplier at a given timestamp based on the user's stake a the given timestamp
    // it includes the decay mechanism
    function multiplierAtTs(address user, uint256 timestamp) external view returns (uint256);

    // userLockedUntil returns the timestamp until the user's balance is locked
    function userLockedUntil(address user) external view returns (uint256);

    // userDidDelegate returns the address to which a user delegated their voting power; address(0) if not delegated
    function userDelegatedTo(address user) external view returns (address);
    
}


// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import"../interfaces/IRewards.sol";

library LibKernelStorage {
    bytes32 constant STORAGE_POSITION = keccak256("com.enterdao.kernel.storage");

    struct Checkpoint {
        uint256 timestamp;
        uint256 amount;
    }

    struct Stake {
        uint256 timestamp;
        uint256 amount;
        uint256 expiryTimestamp;
        address delegatedTo;
    }

    struct Storage {
        bool initialized;

        // mapping of user address to history of Stake objects
        // every user action creates a new object in the history
        mapping(address => Stake[]) userStakeHistory;

        // array of entr staked Checkpoint
        // deposits/withdrawals create a new object in the history (max one per block)
        Checkpoint[] entrStakedHistory;

        // mapping of user address to history of delegated power
        // every delegate/stopDelegate call create a new checkpoint (max one per block)
        mapping(address => Checkpoint[]) delegatedPowerHistory;

        IERC20 entr;
        IRewards rewards;
    }

    function kernelStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}


// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"./LibDiamondStorage.sol";

library LibOwnership {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        address previousOwner = ds.contractOwner;
        require(previousOwner != _newOwner, "Previous owner and new owner must be different");

        ds.contractOwner = _newOwner;

        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = LibDiamondStorage.diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() view internal {
        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
    }

    modifier onlyOwner {
        require(msg.sender == LibDiamondStorage.diamondStorage().contractOwner, "Must be contract owner");
        _;
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
}


// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IRewards {
    function registerUserAction(address user) external;
}


// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

library LibDiamondStorage {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct Facet {
        address facetAddress;
        uint16 selectorPosition;
    }

    struct DiamondStorage {
        // function selector => facet address and selector position in selectors array
        mapping(bytes4 => Facet) facets;
        bytes4[] selectors;

        // ERC165
        mapping(bytes4 => bool) supportedInterfaces;

        // owner of the contract
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}


// : Apache-2.0
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

//import"../interfaces/IKernel.sol";
//import"../libraries/LibKernelStorage.sol";
//import"../libraries/LibOwnership.sol";
//import"@openzeppelin/contracts/math/SafeMath.sol";
//import"@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KernelFacet {
    using SafeMath for uint256;

    uint256 constant public MAX_LOCK = 365 days;
    uint256 constant BASE_MULTIPLIER = 1e18;

    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed user, uint256 amountWithdrew, uint256 amountLeft);
    event Lock(address indexed user, uint256 timestamp);
    event Delegate(address indexed from, address indexed to);
    event DelegatedPowerIncreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);
    event DelegatedPowerDecreased(address indexed from, address indexed to, uint256 amount, uint256 to_newDelegatedPower);

    function initKernel(address _entr, address _rewards) public {
        require(_entr != address(0), "ENTR address must not be 0x0");

        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();

        require(!ds.initialized, "Kernel: already initialized");
        LibOwnership.enforceIsContractOwner();

        ds.initialized = true;

        ds.entr = IERC20(_entr);
        ds.rewards = IRewards(_rewards);
    }

    // deposit allows a user to add more entr to his staked balance
    function deposit(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

       LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();
        uint256 allowance = ds.entr.allowance(msg.sender, address(this));
        require(allowance >= amount, "Token allowance too small");

        // this must be called before the user's balance is updated so the rewards contract can calculate
        // the amount owed correctly
        if (address(ds.rewards) != address(0)) {
            ds.rewards.registerUserAction(msg.sender);
        }

        uint256 newBalance = balanceOf(msg.sender).add(amount);
        _updateUserBalance(ds.userStakeHistory[msg.sender], newBalance);
        _updateLockedEntr(entrStakedAtTs(block.timestamp).add(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).add(amount);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerIncreased(msg.sender, delegatedTo, amount, newDelegatedPower);
        }
        ds.entr.transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount, newBalance);
    }

    // withdraw allows a user to withdraw funds if the balance is not locked
    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(userLockedUntil(msg.sender) <= block.timestamp, "User balance is locked");

        uint256 balance = balanceOf(msg.sender);
        require(balance >= amount, "Insufficient balance");

        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();

        // this must be called before the user's balance is updated so the rewards contract can calculate
        // the amount owed correctly
        if (address(ds.rewards) != address(0)) {
            ds.rewards.registerUserAction(msg.sender);
        }

        _updateUserBalance(ds.userStakeHistory[msg.sender], balance.sub(amount));
        _updateLockedEntr(entrStakedAtTs(block.timestamp).sub(amount));

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(amount);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerDecreased(msg.sender, delegatedTo, amount, newDelegatedPower);
        }

        ds.entr.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, balance.sub(amount));
    }

    // lock a user's currently staked balance until timestamp & add the bonus to his voting power
    function lock(uint256 timestamp) public {
        require(timestamp > block.timestamp, "Timestamp must be in the future");
        require(timestamp <= block.timestamp + MAX_LOCK, "Timestamp too big");
        require(balanceOf(msg.sender) > 0, "Sender has no balance");

        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();
        LibKernelStorage.Stake[] storage checkpoints = ds.userStakeHistory[msg.sender];
        LibKernelStorage.Stake storage currentStake = checkpoints[checkpoints.length - 1];

        require(timestamp > currentStake.expiryTimestamp, "New timestamp lower than current lock timestamp");

        _updateUserLock(checkpoints, timestamp);

        emit Lock(msg.sender, timestamp);
    }

    function depositAndLock(uint256 amount, uint256 timestamp) public {
        deposit(amount);
        lock(timestamp);
    }

    // delegate allows a user to delegate his voting power to another user
    function delegate(address to) public {
        require(msg.sender != to, "Can't delegate to self");

        uint256 senderBalance = balanceOf(msg.sender);
        require(senderBalance > 0, "No balance to delegate");

        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();

        emit Delegate(msg.sender, to);

        address delegatedTo = userDelegatedTo(msg.sender);
        if (delegatedTo != address(0)) {
            uint256 newDelegatedPower = delegatedPower(delegatedTo).sub(senderBalance);
            _updateDelegatedPower(ds.delegatedPowerHistory[delegatedTo], newDelegatedPower);

            emit DelegatedPowerDecreased(msg.sender, delegatedTo, senderBalance, newDelegatedPower);
        }

        if (to != address(0)) {
            uint256 newDelegatedPower = delegatedPower(to).add(senderBalance);
            _updateDelegatedPower(ds.delegatedPowerHistory[to], newDelegatedPower);

            emit DelegatedPowerIncreased(msg.sender, to, senderBalance, newDelegatedPower);
        }

        _updateUserDelegatedTo(ds.userStakeHistory[msg.sender], to);
    }

    // stopDelegate allows a user to take back the delegated voting power
    function stopDelegate() public {
        return delegate(address(0));
    }

    // balanceOf returns the current ENTR balance of a user (bonus not included)
    function balanceOf(address user) public view returns (uint256) {
        return balanceAtTs(user, block.timestamp);
    }

    // balanceAtTs returns the amount of ENTR that the user currently staked (bonus NOT included)
    function balanceAtTs(address user, uint256 timestamp) public view returns (uint256) {
        LibKernelStorage.Stake memory stake = stakeAtTs(user, timestamp);

        return stake.amount;
    }

    // stakeAtTs returns the Stake object of the user that was valid at `timestamp`
    function stakeAtTs(address user, uint256 timestamp) public view returns (LibKernelStorage.Stake memory) {
        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();
        LibKernelStorage.Stake[] storage stakeHistory = ds.userStakeHistory[user];

        if (stakeHistory.length == 0 || timestamp < stakeHistory[0].timestamp) {
            return LibKernelStorage.Stake(block.timestamp, 0, block.timestamp, address(0));
        }

        uint256 min = 0;
        uint256 max = stakeHistory.length - 1;

        if (timestamp >= stakeHistory[max].timestamp) {
            return stakeHistory[max];
        }

        // binary search of the value in the array
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (stakeHistory[mid].timestamp <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return stakeHistory[min];
    }

    // votingPower returns the voting power (bonus included) + delegated voting power for a user at the current block
    function votingPower(address user) public view returns (uint256) {
        return votingPowerAtTs(user, block.timestamp);
    }

    // votingPowerAtTs returns the voting power (bonus included) + delegated voting power for a user at a point in time
    function votingPowerAtTs(address user, uint256 timestamp) public view returns (uint256) {
        LibKernelStorage.Stake memory stake = stakeAtTs(user, timestamp);

        uint256 ownVotingPower;

        // if the user delegated his voting power to another user, then he doesn't have any voting power left
        if (stake.delegatedTo != address(0)) {
            ownVotingPower = 0;
        } else {
            uint256 balance = stake.amount;
            uint256 multiplier = _stakeMultiplier(stake, timestamp);
            ownVotingPower = balance.mul(multiplier).div(BASE_MULTIPLIER);
        }

        uint256 delegatedVotingPower = delegatedPowerAtTs(user, timestamp);

        return ownVotingPower.add(delegatedVotingPower);
    }

    // entrStaked returns the total raw amount of ENTR staked at the current block
    function entrStaked() public view returns (uint256) {
        return entrStakedAtTs(block.timestamp);
    }

    // entrStakedAtTs returns the total raw amount of ENTR users have deposited into the contract
    // it does not include any bonus
    function entrStakedAtTs(uint256 timestamp) public view returns (uint256) {
        return _checkpointsBinarySearch(LibKernelStorage.kernelStorage().entrStakedHistory, timestamp);
    }

    // delegatedPower returns the total voting power that a user received from other users
    function delegatedPower(address user) public view returns (uint256) {
        return delegatedPowerAtTs(user, block.timestamp);
    }

    // delegatedPowerAtTs returns the total voting power that a user received from other users at a point in time
    function delegatedPowerAtTs(address user, uint256 timestamp) public view returns (uint256) {
        return _checkpointsBinarySearch(LibKernelStorage.kernelStorage().delegatedPowerHistory[user], timestamp);
    }

    // same as multiplierAtTs but for the current block timestamp
    function multiplierOf(address user) public view returns (uint256) {
        return multiplierAtTs(user, block.timestamp);
    }

    // multiplierAtTs calculates the multiplier at a given timestamp based on the user's stake a the given timestamp
    // it includes the decay mechanism
    function multiplierAtTs(address user, uint256 timestamp) public view returns (uint256) {
        LibKernelStorage.Stake memory stake = stakeAtTs(user, timestamp);

        return _stakeMultiplier(stake, timestamp);
    }

    // userLockedUntil returns the timestamp until the user's balance is locked
    function userLockedUntil(address user) public view returns (uint256) {
        LibKernelStorage.Stake memory c = stakeAtTs(user, block.timestamp);

        return c.expiryTimestamp;
    }

    // userDelegatedTo returns the address to which a user delegated their voting power; address(0) if not delegated
    function userDelegatedTo(address user) public view returns (address) {
        LibKernelStorage.Stake memory c = stakeAtTs(user, block.timestamp);

        return c.delegatedTo;
    }

    // _checkpointsBinarySearch executes a binary search on a list of checkpoints that's sorted chronologically
    // looking for the closest checkpoint that matches the specified timestamp
    function _checkpointsBinarySearch(LibKernelStorage.Checkpoint[] storage checkpoints, uint256 timestamp) internal view returns (uint256) {
        if (checkpoints.length == 0 || timestamp < checkpoints[0].timestamp) {
            return 0;
        }

        uint256 min = 0;
        uint256 max = checkpoints.length - 1;

        if (timestamp >= checkpoints[max].timestamp) {
            return checkpoints[max].amount;
        }

        // binary search of the value in the array
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].timestamp <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return checkpoints[min].amount;
    }

    // _stakeMultiplier calculates the multiplier for the given stake at the given timestamp
    function _stakeMultiplier(LibKernelStorage.Stake memory stake, uint256 timestamp) internal view returns (uint256) {
        if (timestamp >= stake.expiryTimestamp) {
            return BASE_MULTIPLIER;
        }

        uint256 diff = stake.expiryTimestamp - timestamp;
        if (diff >= MAX_LOCK) {
            return BASE_MULTIPLIER.mul(2);
        }

        return BASE_MULTIPLIER.add(diff.mul(BASE_MULTIPLIER).div(MAX_LOCK));
    }

    // _updateUserBalance manages an array of checkpoints
    // if there's already a checkpoint for the same timestamp, the amount is updated
    // otherwise, a new checkpoint is inserted
    function _updateUserBalance(LibKernelStorage.Stake[] storage checkpoints, uint256 amount) internal {
        if (checkpoints.length == 0) {
            checkpoints.push(LibKernelStorage.Stake(block.timestamp, amount, block.timestamp, address(0)));
        } else {
            LibKernelStorage.Stake storage old = checkpoints[checkpoints.length - 1];

            if (old.timestamp == block.timestamp) {
                old.amount = amount;
            } else {
                checkpoints.push(LibKernelStorage.Stake(block.timestamp, amount, old.expiryTimestamp, old.delegatedTo));
            }
        }
    }

    // _updateUserLock updates the expiry timestamp on the user's stake
    // it assumes that if the user already has a balance, which is checked for in the lock function
    // then there must be at least 1 checkpoint
    function _updateUserLock(LibKernelStorage.Stake[] storage checkpoints, uint256 expiryTimestamp) internal {
        LibKernelStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(LibKernelStorage.Stake(block.timestamp, old.amount, expiryTimestamp, old.delegatedTo));
        } else {
            old.expiryTimestamp = expiryTimestamp;
        }
    }

    // _updateUserDelegatedTo updates the delegateTo property on the user's stake
    // it assumes that if the user already has a balance, which is checked for in the delegate function
    // then there must be at least 1 checkpoint
    function _updateUserDelegatedTo(LibKernelStorage.Stake[] storage checkpoints, address to) internal {
        LibKernelStorage.Stake storage old = checkpoints[checkpoints.length - 1];

        if (old.timestamp < block.timestamp) {
            checkpoints.push(LibKernelStorage.Stake(block.timestamp, old.amount, old.expiryTimestamp, to));
        } else {
            old.delegatedTo = to;
        }
    }

    // _updateDelegatedPower updates the power delegated TO the user in the checkpoints history
    function _updateDelegatedPower(LibKernelStorage.Checkpoint[] storage checkpoints, uint256 amount) internal {
        if (checkpoints.length == 0 || checkpoints[checkpoints.length - 1].timestamp < block.timestamp) {
            checkpoints.push(LibKernelStorage.Checkpoint(block.timestamp, amount));
        } else {
            LibKernelStorage.Checkpoint storage old = checkpoints[checkpoints.length - 1];
            old.amount = amount;
        }
    }

    // _updateLockedEntr stores the new `amount` into the ENTR locked history
    function _updateLockedEntr(uint256 amount) internal {
        LibKernelStorage.Storage storage ds = LibKernelStorage.kernelStorage();

        if (ds.entrStakedHistory.length == 0 || ds.entrStakedHistory[ds.entrStakedHistory.length - 1].timestamp < block.timestamp) {
            ds.entrStakedHistory.push(LibKernelStorage.Checkpoint(block.timestamp, amount));
        } else {
            LibKernelStorage.Checkpoint storage old = ds.entrStakedHistory[ds.entrStakedHistory.length - 1];
            old.amount = amount;
        }
    }
}



}
