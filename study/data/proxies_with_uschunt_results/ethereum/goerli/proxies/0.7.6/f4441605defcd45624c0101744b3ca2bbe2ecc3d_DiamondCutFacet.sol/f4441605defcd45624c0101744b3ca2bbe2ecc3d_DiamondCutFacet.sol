/**
 *Submitted for verification at Etherscan.io on 2021-05-21
*/

// ////-License-Identifier: MIT
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Kevin Park, credit: Nick Mudge
*
* Implementation of an ERC20 governance token that can govern itself and a project
* using the Diamond Standard.
/******************************************************************************/

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
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
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library LibGovStorage {
    struct Voted {
        uint96 votes;
        bool support;
    }

    struct Proposal {
        mapping(address => Voted) voted;
        address proposalContract;
        address proposer;
        uint64 endTime;
        bool executed;
        bool stuck;
        uint96 againstVotes;
        uint96 forVotes;
    }

    // How Divisors work:
    // To get a percentage of a number in Solidity we divide instead of multiply
    // We get the number to divide to get a percentage of a number with this formula:
    // divisor = 100 / percentage number
    // For example let's say we want 25 percent of the number 7808.
    // First we need to get the divisor so we get it like this:  100 / 25 = 4
    // So the divisor is 4.  Now we divide 475 by 4 which is 1952
    // And that is the answer: 25 percent of 7808 is 1952.

    struct GovernanceStorage {
        mapping(address => uint96) balances;
        mapping(address => mapping(address => uint96)) approved;
        uint96 totalSupplyCap;
        uint96 totalSupply;
        address loveMinter;
        // The initial account to grant all the tokens
        address loveBoat;
        uint256 mintingAllowedAfter;
        mapping(uint256 => Proposal) proposals;
        mapping(address => uint24[]) votedProposalIds;
        uint24 proposalCount;
        // Proposer must own enough tokens to submit a proposal
        uint8 proposalThresholdDivisor;
        // The minimum amount of time a proposal can be voted on. In hours.
        uint16 minimumVotingTime;
        // The maximum amount of time a proposal can be voted on. In hours.
        uint16 maximumVotingTime;
        // Require an amount of governance tokens for votes to pass a proposal
        uint8 quorumDivisor;
        // Proposers get an additional amount of tokens if proposal passes
        uint8 proposerAwardDivisor;
        // Voters get an additional amount of tokens for voting on a proposal
        uint8 voterAwardDivisor;
        // Cap voter and proposer token awards.
        // This is to help prevent too much inflation
        uint8 voteAwardCapDivisor;
    }

    function governanceStorage() internal pure returns (GovernanceStorage storage ds) {
        bytes32 position = keccak256("governance.token.diamond.governance");
        assembly {
            ds.slot := position
        }
    }
}

library LibPolygonStorage {
    struct PolygonERC20Storage {
        address childChainManagerProxy;
    }

    function polygonERC20Storage() internal pure returns (PolygonERC20Storage storage ds) {
        bytes32 position = keccak256("governance.token.diamond.PolygonToken");
        assembly {
            ds.slot := position
        }
    }
}

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        // maps function selectors to the facets that execute the functions.
        // and maps the selectors to their position in the selectorSlots array.
        // func selector => address facet, selector position
        mapping(bytes4 => bytes32) facets;
        // array of slots of function selectors.
        // each slot holds 8 function selectors.
        mapping(uint256 => bytes32) selectorSlots;
        // The number of function selectors in selectorSlots
        uint16 selectorCount;
        // Used to query if a contract implements an interface.
        // Used to implement ERC-165.
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {
        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    bytes32 constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

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
        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
                // add facet for selector
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                // clear selector position in slot and add selector
                _selectorSlot =
                    (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
                    (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IDiamondCut.FacetCutAction.Replace) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                // only useful if immutable functions exist
                require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
                require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
                require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
                // replace old facet address
                ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);
            }
        } else if (_action == IDiamondCut.FacetCutAction.Remove) {
            require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
            uint256 selectorSlotCount = _selectorCount >> 3;
            uint256 selectorInSlotIndex = _selectorCount & 7;
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                if (_selectorSlot == 0) {
                    // get last selectorSlot
                    selectorSlotCount--;
                    _selectorSlot = ds.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }
                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;
                // adding a block here prevents stack too deep error
                {
                    bytes4 selector = _selectors[selectorIndex];
                    bytes32 oldFacet = ds.facets[selector];
                    require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
                    // only useful if immutable functions exist
                    require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
                    // replace selector with last selector in ds.facets
                    // gets the last selector
                    lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex << 5));
                    if (lastSelector != selector) {
                        // update last selector slot position info
                        ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
                    }
                    delete ds.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    // update storage with the modified slot
                    ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    _selectorSlot =
                        (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete ds.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
        } else {
            revert("LibDiamondCut: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
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
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

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

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

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

contract DiamondCutFacet is IDiamondCut {
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
    ) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = LibDiamond.addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        LibDiamond.initializeDiamondCut(_init, _calldata);
    }
}

contract DiamondLoupe is IDiamondLoupe, IERC165 {
    // Diamond Loupe Functions
    ////////////////////////////////////////////////////////////////////
    /// These functions are expected to be called frequently by tools.

    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external view override returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facets_ = new Facet[](ds.selectorCount);
        uint8[] memory numFacetSelectors = new uint8[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facets_[facetIndex].facetAddress == facetAddress_) {
                        facets_[facetIndex].functionSelectors[numFacetSelectors[facetIndex]] = selector;
                        // probably will never have more than 256 functions from one facet contract
                        require(numFacetSelectors[facetIndex] < 255);
                        numFacetSelectors[facetIndex]++;
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facets_[numFacets].facetAddress = facetAddress_;
                facets_[numFacets].functionSelectors = new bytes4[](ds.selectorCount);
                facets_[numFacets].functionSelectors[0] = selector;
                numFacetSelectors[numFacets] = 1;
                numFacets++;
            }
        }
        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
            uint256 numSelectors = numFacetSelectors[facetIndex];
            bytes4[] memory selectors = facets_[facetIndex].functionSelectors;
            // setting the number of selectors
            assembly {
                mstore(selectors, numSelectors)
            }
        }
        // setting the number of facets
        assembly {
            mstore(facets_, numFacets)
        }
    }

    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return _facetFunctionSelectors The selectors associated with a facet address.
    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory _facetFunctionSelectors) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numSelectors;
        _facetFunctionSelectors = new bytes4[](ds.selectorCount);
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facet = address(bytes20(ds.facets[selector]));
                if (_facet == facet) {
                    _facetFunctionSelectors[numSelectors] = selector;
                    numSelectors++;
                }
            }
        }
        // Set the number of selectors in the array
        assembly {
            mstore(_facetFunctionSelectors, numSelectors)
        }
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddresses_ = new address[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facetAddress_ == facetAddresses_[facetIndex]) {
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facetAddresses_[numFacets] = facetAddress_;
                numFacets++;
            }
        }
        // Set the number of facet addresses in the array
        assembly {
            mstore(facetAddresses_, numFacets)
        }
    }

    /// @notice Gets the facet that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddress_ = address(bytes20(ds.facets[_functionSelector]));
    }

    // This implements ERC-165.
    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }
}

contract LoveToken {
    function name() public pure returns (string memory) {
        return "Test Love";
    }

    function symbol() public pure returns (string memory) {
        return "LOVE";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return LibGovStorage.governanceStorage().totalSupply;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param _account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address _account) external view returns (uint256) {
        return LibGovStorage.governanceStorage().balances[_account];
    }

    /// @notice Minimum time between mints
    uint32 public constant minimumTimeBetweenMints = 1 days * 365;

    /// @notice Cap on the percentage of totalSupply that can be minted at each mint
    uint8 public constant mintCap = 2;

    /// @notice An event thats emitted when the minter address is changed
    event MinterChanged(address minter, address newMinter);

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /**
     * @notice Construct LOVE ERC20 token
     * @param _loveMinter The account with minting ability
     * @param _loveBoat The initial account to grant all the tokens
     * @param _mintAmount Pass in the total supply
     */
    constructor(
        address _loveMinter,
        address _loveBoat,
        uint256 _mintAmount
    ) {
        emit Transfer(address(0), _loveBoat, _mintAmount);
        emit MinterChanged(address(0), _loveMinter);
    }

    function mintingAllowedAfter() public view returns (uint256) {
        return LibGovStorage.governanceStorage().mintingAllowedAfter;
    }

    /**
     * @notice Change the minter address
     * @param _minter The address of the new minter
     */
    function setMinter(address _minter) external {
        require(msg.sender == LibGovStorage.governanceStorage().loveMinter, "Love::setMinter: only the minter can change the minter address");

        emit MinterChanged(LibGovStorage.governanceStorage().loveMinter, _minter);
        LibGovStorage.governanceStorage().loveMinter = _minter;
    }

    /**
     * @notice Mint new tokens
     * @param dst The address of the destination account
     * @param rawAmount The number of tokens to be minted
     */
    function mint(address dst, uint256 rawAmount) external {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        require(msg.sender == gs.loveMinter, "Love::mint: only the minter can mint");
        require(block.timestamp >= gs.mintingAllowedAfter, "Love::mint: minting not allowed yet");
        require(dst != address(0), "Love::mint: cannot transfer to the zero address");

        // record the mint
        gs.mintingAllowedAfter = SafeMath.add(block.timestamp, minimumTimeBetweenMints);

        // mint the amount
        uint96 amount = safe96(rawAmount, "Love::mint: amount exceeds 96 bits");
        require(amount <= SafeMath.div(SafeMath.mul(gs.totalSupply, mintCap), 100), "Love::mint: exceeded mint cap");
        gs.totalSupply = safe96(SafeMath.add(gs.totalSupply, amount), "Love::mint: totalSupply exceeds 96 bits");

        // transfer the amount to the recipient
        gs.balances[dst] = add96(gs.balances[dst], amount, "Love::mint: transfer amount overflows");
        emit Transfer(address(0), dst, amount);
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        uint96 value = safe96(_value, "Love: value exceeds 96 bits");
        _transferFrom(msg.sender, _to, value);
        success = true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _rawValue
    ) external returns (bool success) {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        uint96 spenderAllowance = gs.approved[_from][msg.sender];
        uint96 value = safe96(_rawValue, "Love: value exceeds 96 bits");

        if (msg.sender != _from && spenderAllowance != uint96(-1)) {
            uint96 newSpenderAllowance = sub96(spenderAllowance, value, "Love:transferFrom: value exceeds spenderAllowance");
            gs.approved[_from][msg.sender] = newSpenderAllowance;
            emit Approval(_from, msg.sender, newSpenderAllowance);
        }

        _transferFrom(_from, _to, value);
        success = true;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint96 _value
    ) internal {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        require(_value <= gs.balances[_from], "Love:_transferFrom: Balance less than transfer amount");
        gs.balances[_from] = sub96(gs.balances[_from], _value, "Love:_transferFrom: value exceeds balance");
        gs.balances[_to] = add96(gs.balances[_to], _value, "Love:_transferFrom: value overflows");
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        uint96 value = safe96(_value, "Love: value exceeds 96 bits");
        gs.approved[msg.sender][_spender] = value;
        emit Approval(msg.sender, _spender, value);
        success = true;
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
}

contract DiamondLove {
    constructor() {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        // Set total supply cap. The token supply cannot grow past this.
        gs.totalSupplyCap = 100_000_000e18;
        gs.totalSupply = 1_000_000e18;
        gs.loveMinter = 0xe843cAc20FCA69B8B95c346c0E76eA1b0df87050; // Address with the permission to mint Love tokens
        gs.loveBoat = 0xe843cAc20FCA69B8B95c346c0E76eA1b0df87050;
        // No minting is allowed for about a year after the contract is deployed. Only 2% of the total supply can be minted every year.
        gs.mintingAllowedAfter = block.timestamp + 1 days * 365;

        // Initially mint tokens to gs.loveBoat. The vesting contract will be deployed on Polygon L2.
        // Events are emitted in the LoveToken facet constructor which we deploy WITH this Diamond.
        gs.balances[gs.loveBoat] = gs.totalSupply;

        // L2 Polygon ERC20
        LibPolygonStorage.PolygonERC20Storage storage ps = LibPolygonStorage.polygonERC20Storage();
        ps.childChainManagerProxy = 0xb5505a6d998549090530911180f38aC5130101c6; // Mumbai POS ChildChainManagerProxy contract address

        // Set DiamondLove contract owner
        LibDiamond.setContractOwner(0xe843cAc20FCA69B8B95c346c0E76eA1b0df87050);

        // Deploy facets
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupe diamondLoupe = new DiamondLoupe();
        LoveToken loveToken = new LoveToken(gs.loveMinter, gs.loveBoat, gs.totalSupply);

        // Create array of facet cuts (DiamondCutFacet, DiamondLoupe, LoveToken)
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Add DiamondCutFacet
        bytes4[] memory funcSDiamondCut = new bytes4[](1);
        funcSDiamondCut[0] = DiamondCutFacet.diamondCut.selector;

        cut[0] = IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, funcSDiamondCut);

        // Add DiamondLoupe
        bytes4[] memory funcSDiamondLoupe = new bytes4[](5);
        funcSDiamondLoupe[0] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcSDiamondLoupe[1] = IDiamondLoupe.facets.selector;
        funcSDiamondLoupe[2] = IDiamondLoupe.facetAddress.selector;
        funcSDiamondLoupe[3] = IDiamondLoupe.facetAddresses.selector;
        funcSDiamondLoupe[4] = IERC165.supportsInterface.selector;

        cut[1] = IDiamondCut.FacetCut(address(diamondLoupe), IDiamondCut.FacetCutAction.Add, funcSDiamondLoupe);

        // Add LoveToken
        bytes4[] memory funcSLoveToken = new bytes4[](11);
        funcSLoveToken[0] = LoveToken.name.selector;
        funcSLoveToken[1] = LoveToken.symbol.selector;
        funcSLoveToken[2] = LoveToken.decimals.selector;
        funcSLoveToken[3] = LoveToken.totalSupply.selector;
        funcSLoveToken[4] = LoveToken.balanceOf.selector;
        funcSLoveToken[5] = LoveToken.mintingAllowedAfter.selector;
        funcSLoveToken[6] = LoveToken.setMinter.selector;
        funcSLoveToken[7] = LoveToken.mint.selector;
        funcSLoveToken[8] = LoveToken.transfer.selector;
        funcSLoveToken[9] = LoveToken.transferFrom.selector;
        funcSLoveToken[10] = LoveToken.approve.selector;

        cut[2] = IDiamondCut.FacetCut(address(loveToken), IDiamondCut.FacetCutAction.Add, funcSLoveToken);

        LibDiamond.diamondCut(cut, address(0), new bytes(0));

        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "DiamondLove: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}