// ////-License-Identifier: MIT
pragma solidity ^0.8.2;

//import {IRideCut} from "./interfaces/utils/IRideCut.sol";

//import {RideLibOwnership} from "./libraries/utils/RideLibOwnership.sol";
//import {RideLibCutAndLoupe} from "./libraries/utils/RideLibCutAndLoupe.sol";

contract RideHub {
    constructor(address _contractOwner, address _rideCutFacet) payable {
        RideLibOwnership._setContractOwner(_contractOwner);

        // Add the rideCut external function from the RideCut.sol
        IRideCut.FacetCut[] memory cut = new IRideCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IRideCut.rideCut.selector;
        cut[0] = IRideCut.FacetCut({
            facetAddress: _rideCutFacet,
            action: IRideCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        RideLibCutAndLoupe.rideCut(cut, address(0), "");
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        RideLibCutAndLoupe.StorageCutAndLoupe storage s1;
        bytes32 position = RideLibCutAndLoupe.STORAGE_POSITION_CUTANDLOUPE;
        // get diamond storage
        assembly {
            s1.slot := position
        }
        // get facet from function selector
        // address facet = s1.selectorToFacetAndPosition[msg.sig].facetAddress; // diamond-3 implementation
        address facet = address(bytes20(s1.facets[msg.sig])); // diamond-2 implementation
        require(facet != address(0), "RideHub: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
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

// ////-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IRideCut {
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }
    // Add=0, Replace=1, Remove=2

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Add/replace/remove any number of functions and optionally execute
    ///         a function with delegatecall
    /// @param _rideCut Contains the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments
    ///                  _calldata is executed with delegatecall on _init
    function rideCut(
        FacetCut[] calldata _rideCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event RideCut(FacetCut[] _rideCut, address _init, bytes _calldata);
}

//////-License-Identifier: BUSL-1.1
pragma solidity ^0.8.2;

library RideLibOwnership {
    bytes32 constant STORAGE_POSITION_OWNERSHIP = keccak256("ds.ownership");

    struct StorageOwnership {
        address contractOwner;
    }

    function _storageOwnership()
        internal
        pure
        returns (StorageOwnership storage s)
    {
        bytes32 position = STORAGE_POSITION_OWNERSHIP;
        assembly {
            s.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _setContractOwner(address _newOwner) internal {
        StorageOwnership storage s1 = _storageOwnership();
        address previousOwner = s1.contractOwner;
        s1.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function _contractOwner() internal view returns (address) {
        return _storageOwnership().contractOwner;
    }

    function _requireIsContractOwner() internal view {
        require(
            msg.sender == _storageOwnership().contractOwner,
            "not contract owner"
        );
    }
}

//////-License-Identifier: BUSL-1.1
pragma solidity ^0.8.2;

//import {IRideCut} from "../../interfaces/utils/IRideCut.sol";

library RideLibCutAndLoupe {
    bytes32 constant STORAGE_POSITION_CUTANDLOUPE = keccak256("ds.cutandloupe");

    struct StorageCutAndLoupe {
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
    }

    function _storageCutAndLoupe()
        internal
        pure
        returns (StorageCutAndLoupe storage s)
    {
        bytes32 position = STORAGE_POSITION_CUTANDLOUPE;
        assembly {
            s.slot := position
        }
    }

    event RideCut(IRideCut.FacetCut[] _rideCut, address _init, bytes _calldata);

    bytes32 constant CLEAR_ADDRESS_MASK =
        bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    // Internal function version of rideCut
    // This code is almost the same as the external rideCut,
    // except it is using 'Facet[] memory _rideCut' instead of
    // 'Facet[] calldata _rideCut'.
    // The code is duplicated to prevent copying calldata to memory which
    // causes an error for a two dimensional array.
    function rideCut(
        IRideCut.FacetCut[] memory _rideCut,
        address _init,
        bytes memory _calldata
    ) internal {
        StorageCutAndLoupe storage s1 = _storageCutAndLoupe();
        uint256 originalSelectorCount = s1.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        // Check if last selector slot is not full
        // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8"
        if (selectorCount & 7 > 0) {
            // get last selectorSlot
            // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
            selectorSlot = s1.selectorSlots[selectorCount >> 3];
        }
        // loop through diamond cut
        for (uint256 facetIndex; facetIndex < _rideCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = _addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _rideCut[facetIndex].facetAddress,
                _rideCut[facetIndex].action,
                _rideCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            s1.selectorCount = uint16(selectorCount);
        }
        // If last selector slot is not full
        // "selectorCount & 7" is a gas efficient modulo by eight "selectorCount % 8"
        if (selectorCount & 7 > 0) {
            // "selectorSlot >> 3" is a gas efficient division by 8 "selectorSlot / 8"
            s1.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit RideCut(_rideCut, _init, _calldata);
        _initializeRideCut(_init, _calldata);
    }

    function _addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IRideCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {
        StorageCutAndLoupe storage s1 = _storageCutAndLoupe();
        require(
            _selectors.length > 0,
            "RideLibCutAndLoupe: No selectors in facet to cut"
        );
        if (_action == IRideCut.FacetCutAction.Add) {
            _requireHasContractCode(
                _newFacetAddress,
                "RideLibCutAndLoupe: Add facet has no code"
            );
            for (
                uint256 selectorIndex;
                selectorIndex < _selectors.length;
                selectorIndex++
            ) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = s1.facets[selector];
                require(
                    address(bytes20(oldFacet)) == address(0),
                    "RideLibCutAndLoupe: Can't add function that already exists"
                );
                // add facet for selector
                s1.facets[selector] =
                    bytes20(_newFacetAddress) |
                    bytes32(_selectorCount);
                // "_selectorCount & 7" is a gas efficient modulo by eight "_selectorCount % 8"
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                // clear selector position in slot and add selector
                _selectorSlot =
                    (_selectorSlot &
                        ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
                    (bytes32(selector) >> selectorInSlotPosition);
                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    // "_selectorSlot >> 3" is a gas efficient division by 8 "_selectorSlot / 8"
                    s1.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IRideCut.FacetCutAction.Replace) {
            _requireHasContractCode(
                _newFacetAddress,
                "RideLibCutAndLoupe: Replace facet has no code"
            );
            for (
                uint256 selectorIndex;
                selectorIndex < _selectors.length;
                selectorIndex++
            ) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = s1.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                // only useful if immutable functions exist
                require(
                    oldFacetAddress != address(this),
                    "RideLibCutAndLoupe: Can't replace immutable function"
                );
                require(
                    oldFacetAddress != _newFacetAddress,
                    "RideLibCutAndLoupe: Can't replace function with same function"
                );
                require(
                    oldFacetAddress != address(0),
                    "RideLibCutAndLoupe: Can't replace function that doesn't exist"
                );
                // replace old facet address
                s1.facets[selector] =
                    (oldFacet & CLEAR_ADDRESS_MASK) |
                    bytes20(_newFacetAddress);
            }
        } else if (_action == IRideCut.FacetCutAction.Remove) {
            require(
                _newFacetAddress == address(0),
                "RideLibCutAndLoupe: Remove facet address must be address(0)"
            );
            // "_selectorCount >> 3" is a gas efficient division by 8 "_selectorCount / 8"
            uint256 selectorSlotCount = _selectorCount >> 3;
            // "_selectorCount & 7" is a gas efficient modulo by eight "_selectorCount % 8"
            uint256 selectorInSlotIndex = _selectorCount & 7;
            for (
                uint256 selectorIndex;
                selectorIndex < _selectors.length;
                selectorIndex++
            ) {
                if (_selectorSlot == 0) {
                    // get last selectorSlot
                    selectorSlotCount--;
                    _selectorSlot = s1.selectorSlots[selectorSlotCount];
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
                    bytes32 oldFacet = s1.facets[selector];
                    require(
                        address(bytes20(oldFacet)) != address(0),
                        "RideLibCutAndLoupe: Can't remove function that doesn't exist"
                    );
                    // only useful if immutable functions exist
                    require(
                        address(bytes20(oldFacet)) != address(this),
                        "RideLibCutAndLoupe: Can't remove immutable function"
                    );
                    // replace selector with last selector in s1.facets
                    // gets the last selector
                    lastSelector = bytes4(
                        _selectorSlot << (selectorInSlotIndex << 5)
                    );
                    if (lastSelector != selector) {
                        // update last selector slot position info
                        s1.facets[lastSelector] =
                            (oldFacet & CLEAR_ADDRESS_MASK) |
                            bytes20(s1.facets[lastSelector]);
                    }
                    delete s1.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    // "oldSelectorCount >> 3" is a gas efficient division by 8 "oldSelectorCount / 8"
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    // "oldSelectorCount & 7" is a gas efficient modulo by eight "oldSelectorCount % 8"
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = s1.selectorSlots[
                        oldSelectorsSlotCount
                    ];
                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot &
                            ~(CLEAR_SELECTOR_MASK >>
                                oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    // update storage with the modified slot
                    s1.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    _selectorSlot =
                        (_selectorSlot &
                            ~(CLEAR_SELECTOR_MASK >>
                                oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete s1.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
        } else {
            revert("RideLibCutAndLoupe: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function _initializeRideCut(address _init, bytes memory _calldata)
        internal
    {
        if (_init == address(0)) {
            require(
                _calldata.length == 0,
                "RideLibCutAndLoupe: _init is address(0) but_calldata is not empty"
            );
        } else {
            require(
                _calldata.length > 0,
                "RideLibCutAndLoupe: _calldata is empty but _init is not address(0)"
            );
            if (_init != address(this)) {
                _requireHasContractCode(
                    _init,
                    "RideLibCutAndLoupe: _init address has no code"
                );
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    // bubble up the error
                    revert(string(error));
                } else {
                    revert("RideLibCutAndLoupe: _init function reverted");
                }
            }
        }
    }

    function _requireHasContractCode(
        address _contract,
        string memory _errorMessage
    ) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

//: BUSL-1.1
pragma solidity ^0.8.2;

library RideLibOwnership {
    bytes32 constant STORAGE_POSITION_OWNERSHIP = keccak256("ds.ownership");

    struct StorageOwnership {
        address contractOwner;
    }

    function _storageOwnership()
        internal
        pure
        returns (StorageOwnership storage s)
    {
        bytes32 position = STORAGE_POSITION_OWNERSHIP;
        assembly {
            s.slot := position
        }
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _setContractOwner(address _newOwner) internal {
        StorageOwnership storage s1 = _storageOwnership();
        address previousOwner = s1.contractOwner;
        s1.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function _contractOwner() internal view returns (address) {
        return _storageOwnership().contractOwner;
    }

    function _requireIsContractOwner() internal view {
        require(
            msg.sender == _storageOwnership().contractOwner,
            "not contract owner"
        );
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{RideBadge} from "../../facets/core/RideBadge.sol";
//import{RideLibOwnership} from "../../libraries/utils/RideLibOwnership.sol";
//import{RideLibRater} from "../../libraries/core/RideLibRater.sol";

library RideLibBadge {
    bytes32 constant STORAGE_POSITION_BADGE = keccak256("ds.badge");

    /**
     * lifetime cumulative values of drivers
     */
    struct DriverReputation {
        uint256 id;
        string uri;
        uint256 maxMetresPerTrip;
        uint256 metresTravelled;
        uint256 countStart;
        uint256 countEnd;
        uint256 totalRating;
        uint256 countRating;
    }

    struct StorageBadge {
        mapping(uint256 => uint256) badgeToBadgeMaxScore;
        mapping(uint256 => bool) _insertedMaxScore;
        uint256[] _badges;
        mapping(address => DriverReputation) driverToDriverReputation;
    }

    function _storageBadge() internal pure returns (StorageBadge storage s) {
        bytes32 position = STORAGE_POSITION_BADGE;
        assembly {
            s.slot := position
        }
    }

    event SetBadgesMaxScores(address indexed sender, uint256[] scores);

    /**
     * TODO:
     * Check if setBadgesMaxScores is used in other contracts after
     * diamond pattern finalized. if no use then change visibility
     * to external
     */
    /**
     * setBadgesMaxScores maps score to badge
     *
     * @param _badgesMaxScores Score that defines a specific badge rank
     */
    function _setBadgesMaxScores(uint256[] memory _badgesMaxScores) internal {
        RideLibOwnership._requireIsContractOwner();
        require(
            _badgesMaxScores.length == _getBadgesCount() - 1,
            "_badgesMaxScores.length must be 1 less than Badges"
        );
        StorageBadge storage s1 = _storageBadge();
        for (uint256 i = 0; i < _badgesMaxScores.length; i++) {
            s1.badgeToBadgeMaxScore[i] = _badgesMaxScores[i];

            if (!s1._insertedMaxScore[i]) {
                s1._insertedMaxScore[i] = true;
                s1._badges.push(i);
            }
        }

        emit SetBadgesMaxScores(msg.sender, _badgesMaxScores);
    }

    /**
     * _getBadgesCount returns number of recognized badges
     *
     * @return badges count
     */
    function _getBadgesCount() internal pure returns (uint256) {
        return uint256(RideBadge.Badges.Veteran) + 1;
    }

    /**
     * _getBadge returns the badge rank for given score
     *
     * @param _score | unitless integer
     *
     * @return badge rank
     */
    function _getBadge(uint256 _score) internal view returns (uint256) {
        StorageBadge storage s1 = _storageBadge();

        for (uint256 i = 0; i < s1._badges.length; i++) {
            require(
                s1.badgeToBadgeMaxScore[s1._badges[i]] > 0,
                "zero badge score bounds"
            );
        }

        if (_score <= s1.badgeToBadgeMaxScore[0]) {
            return uint256(RideBadge.Badges.Newbie);
        } else if (
            _score > s1.badgeToBadgeMaxScore[0] &&
            _score <= s1.badgeToBadgeMaxScore[1]
        ) {
            return uint256(RideBadge.Badges.Bronze);
        } else if (
            _score > s1.badgeToBadgeMaxScore[1] &&
            _score <= s1.badgeToBadgeMaxScore[2]
        ) {
            return uint256(RideBadge.Badges.Silver);
        } else if (
            _score > s1.badgeToBadgeMaxScore[2] &&
            _score <= s1.badgeToBadgeMaxScore[3]
        ) {
            return uint256(RideBadge.Badges.Gold);
        } else if (
            _score > s1.badgeToBadgeMaxScore[3] &&
            _score <= s1.badgeToBadgeMaxScore[4]
        ) {
            return uint256(RideBadge.Badges.Platinum);
        } else {
            return uint256(RideBadge.Badges.Veteran);
        }
    }

    /**
     * _calculateScore calculates score from driver's reputation details (see params of function)
     *
     *
     * @return Driver's score to determine badge rank | unitless integer
     *
     * Derive Driver's Score Formula:-
     *
     * Score is fundamentally determined based on distance travelled, where the more trips a driver makes,
     * the higher the score. Thus, the base score is directly proportional to:
     *
     * _metresTravelled
     *
     * where _metresTravelled is the total cumulative distance covered by the driver over all trips made.
     *
     * To encourage the completion of trips, the base score would be penalized by the amount of incomplete
     * trips, using:
     *
     *  _countEnd / _countStart
     *
     * which is the ratio of number of trips complete to the number of trips started. This gives:
     *
     * _metresTravelled * (_countEnd / _countStart)
     *
     * Driver score should also be influenced by passenger's rating of the overall trip, thus, the base
     * score is further penalized by the average driver rating over all trips, given by:
     *
     * _totalRating / _countRating
     *
     * where _totalRating is the cumulative rating value by passengers over all trips and _countRating is
     * the total number of rates by those passengers. The rating penalization is also divided by the max
     * possible rating score to make the penalization a ratio:
     *
     * (_totalRating / _countRating) / _maxRating
     *
     * The score formula is given by:
     *
     * _metresTravelled * (_countEnd / _countStart) * ((_totalRating / _countRating) / _maxRating)
     *
     * which simplifies to:
     *
     * (_metresTravelled * _countEnd * _totalRating) / (_countStart * _countRating * _maxRating)
     *
     * note: Solidity rounds down return value to the nearest whole number.
     *
     * note: Score is used to determine badge rank. To determine which score corresponds to which rank,
     *       can just determine from _metresTravelled, as other variables are just penalization factors.
     */
    function _calculateScore() internal view returns (uint256) {
        StorageBadge storage s1 = _storageBadge();

        uint256 metresTravelled = s1
            .driverToDriverReputation[msg.sender]
            .metresTravelled;
        uint256 countStart = s1.driverToDriverReputation[msg.sender].countStart;
        uint256 countEnd = s1.driverToDriverReputation[msg.sender].countEnd;
        uint256 totalRating = s1
            .driverToDriverReputation[msg.sender]
            .totalRating;
        uint256 countRating = s1
            .driverToDriverReputation[msg.sender]
            .countRating;
        uint256 maxRating = RideLibRater._storageRater().ratingMax;

        if (countStart == 0) {
            return 0;
        } else {
            return
                (metresTravelled * countEnd * totalRating) /
                (countStart * countRating * maxRating);
        }
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

library RideLibTicket {
    bytes32 constant STORAGE_POSITION_TICKET = keccak256("ds.ticket");

    /**
     * @dev if a ticket exists (details not 0) in tixIdToTicket, then it is considered active
     *
     * @custom:TODO: Make it loopable so that can list to drivers?
     */
    struct Ticket {
        address passenger;
        address driver;
        uint256 badge;
        bool strict;
        uint256 metres;
        bytes32 keyLocal;
        bytes32 keyPay;
        uint256 requestFee;
        uint256 fare;
        bool tripStart;
        uint256 forceEndTimestamp;
    }

    /**
     * *Required to confirm if driver did initiate destination reached or not
     */
    struct DriverEnd {
        address driver;
        bool reached;
    }

    struct StorageTicket {
        mapping(address => bytes32) userToTixId;
        mapping(bytes32 => Ticket) tixIdToTicket;
        mapping(bytes32 => DriverEnd) tixToDriverEnd;
    }

    function _storageTicket() internal pure returns (StorageTicket storage s) {
        bytes32 position = STORAGE_POSITION_TICKET;
        assembly {
            s.slot := position
        }
    }

    function _requireNotActive() internal view {
        require(
            _storageTicket().userToTixId[msg.sender] == 0,
            "caller is active"
        );
    }

    event TicketCleared(address indexed sender, bytes32 indexed tixId);

    /**
     * _cleanUp clears ticket information and set active status of users to false
     *
     * @param _tixId Ticket ID
     * @param _passenger passenger's address
     * @param _driver driver's address
     *
     * @custom:event TicketCleared
     */
    function _cleanUp(
        bytes32 _tixId,
        address _passenger,
        address _driver
    ) internal {
        StorageTicket storage s1 = _storageTicket();
        delete s1.tixIdToTicket[_tixId];
        delete s1.tixToDriverEnd[_tixId];
        delete s1.userToTixId[_passenger];
        delete s1.userToTixId[_driver];

        emit TicketCleared(msg.sender, _tixId);
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{RideLibBadge} from "../../libraries/core/RideLibBadge.sol";
//import{RideLibTicket} from "../../libraries/core/RideLibTicket.sol";

library RideLibDriver {
    function _requireDrvMatchTixDrv(address _driver) internal view {
        RideLibTicket.StorageTicket storage s1 = RideLibTicket._storageTicket();
        require(
            _driver == s1.tixIdToTicket[s1.userToTixId[msg.sender]].driver,
            "drv not match tix drv"
        );
    }

    function _requireIsDriver() internal view {
        require(
            RideLibBadge
                ._storageBadge()
                .driverToDriverReputation[msg.sender]
                .id != 0,
            "caller not driver"
        );
    }

    function _requireNotDriver() internal view {
        require(
            RideLibBadge
                ._storageBadge()
                .driverToDriverReputation[msg.sender]
                .id == 0,
            "caller is driver"
        );
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{Counters} from "@openzeppelin/contracts/utils/Counters.sol";

library RideLibDriverRegistry {
    using Counters for Counters.Counter;

    bytes32 constant STORAGE_POSITION_DRIVERREGISTRY =
        keccak256("ds.driverregistry");

    struct StorageDriverRegistry {
        Counters.Counter _driverIdCounter;
    }

    function _storageDriverRegistry()
        internal
        pure
        returns (StorageDriverRegistry storage s)
    {
        bytes32 position = STORAGE_POSITION_DRIVERREGISTRY;
        assembly {
            s.slot := position
        }
    }

    /**
     * _mint a driver ID
     *
     * @return driver ID
     */
    function _mint() internal returns (uint256) {
        StorageDriverRegistry storage s1 = _storageDriverRegistry();
        uint256 id = s1._driverIdCounter.current();
        s1._driverIdCounter.increment();
        return id;
    }

    /**
     * _burnFirstDriverId burns driver ID 0
     * can only be called at RideHub deployment
     *
     * TODO: call at init ONLY
     */
    function _burnFirstDriverId() internal {
        StorageDriverRegistry storage s1 = _storageDriverRegistry();
        assert(s1._driverIdCounter.current() == 0);
        s1._driverIdCounter.increment();
    }
}


// : MIT
pragma solidity ^0.8.2;

interface IRideDriverRegistry {
    event RegisteredAsDriver(address indexed sender);

    function registerAsDriver(uint256 _maxMetresPerTrip) external;

    event MaxMetresUpdated(address indexed sender, uint256 metres);

    function updateMaxMetresPerTrip(uint256 _maxMetresPerTrip) external;

    event ApplicantApproved(address indexed applicant);

    function approveApplicant(address _driver, string memory _uri) external;
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{RideLibBadge} from "../../libraries/core/RideLibBadge.sol";

//import{IRideBadge} from "../../interfaces/core/IRideBadge.sol";

/// @title Badge rank for drivers
contract RideBadge is IRideBadge {
    enum Badges {
        Newbie,
        Bronze,
        Silver,
        Gold,
        Platinum,
        Veteran
    } // note: if we edit last badge, rmb edit RideLibBadge._getBadgesCount fn as well

    /**
     * TODO:
     * Check if setBadgesMaxScores is used in other contracts after
     * diamond pattern finalized. if no use then change visibility
     * to external
     */
    /**
     * setBadgesMaxScores maps score to badge
     *
     * @param _badgesMaxScores Score that defines a specific badge rank
     */
    function setBadgesMaxScores(uint256[] memory _badgesMaxScores)
        external
        override
    {
        RideLibBadge._setBadgesMaxScores(_badgesMaxScores);
    }

    //////////////////////////////////////////////////////////////////////////////////
    ///// ---------------------------------------------------------------------- /////
    ///// -------------------------- getter functions -------------------------- /////
    ///// ---------------------------------------------------------------------- /////
    //////////////////////////////////////////////////////////////////////////////////

    function getBadgeToBadgeMaxScore(uint256 _badge)
        external
        view
        override
        returns (uint256)
    {
        return RideLibBadge._storageBadge().badgeToBadgeMaxScore[_badge];
    }

    function getDriverToDriverReputation(address _driver)
        external
        view
        override
        returns (RideLibBadge.DriverReputation memory)
    {
        return RideLibBadge._storageBadge().driverToDriverReputation[_driver];
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{RideLibOwnership} from "../../libraries/utils/RideLibOwnership.sol";
//import{RideLibBadge} from "../../libraries/core/RideLibBadge.sol";

library RideLibRater {
    bytes32 constant STORAGE_POSITION_RATER = keccak256("ds.rater");

    struct StorageRater {
        uint256 ratingMin;
        uint256 ratingMax;
    }

    function _storageRater() internal pure returns (StorageRater storage s) {
        bytes32 position = STORAGE_POSITION_RATER;
        assembly {
            s.slot := position
        }
    }

    event SetRatingBounds(address indexed sender, uint256 min, uint256 max);

    /**
     * setRatingBounds sets bounds for rating
     *
     * @param _min | unitless integer
     * @param _max | unitless integer
     */
    function _setRatingBounds(uint256 _min, uint256 _max) internal {
        RideLibOwnership._requireIsContractOwner();
        StorageRater storage s1 = _storageRater();
        s1.ratingMin = _min;
        s1.ratingMax = _max;

        emit SetRatingBounds(msg.sender, _min, _max);
    }

    /**
     * _giveRating
     *
     * @param _driver driver's address
     * @param _rating unitless integer between RATING_MIN and RATING_MAX
     *
     */
    function _giveRating(address _driver, uint256 _rating) internal {
        RideLibBadge.StorageBadge storage s1 = RideLibBadge._storageBadge();
        StorageRater storage s2 = _storageRater();

        require(s2.ratingMin > 0, "minimum rating must be more than zero");
        require(s2.ratingMax > 0, "maximum rating must be more than zero");
        require(
            _rating >= s2.ratingMin && _rating <= s2.ratingMax,
            "rating must be within min and max ratings (inclusive)"
        );

        s1.driverToDriverReputation[_driver].totalRating += _rating;
        s1.driverToDriverReputation[_driver].countRating += 1;
    }
}


// : MIT
pragma solidity ^0.8.2;

//import{RideLibBadge} from "../../libraries/core/RideLibBadge.sol";

interface IRideBadge {
    event SetBadgesMaxScores(address indexed sender, uint256[] scores);

    function setBadgesMaxScores(uint256[] memory _badgesMaxScores) external;

    function getBadgeToBadgeMaxScore(uint256 _badge)
        external
        view
        returns (uint256);

    function getDriverToDriverReputation(address _driver)
        external
        view
        returns (RideLibBadge.DriverReputation memory);
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


//: BUSL-1.1
pragma solidity ^0.8.2;

//import{RideLibOwnership} from "../../libraries/utils/RideLibOwnership.sol";
//import{RideLibBadge} from "../../libraries/core/RideLibBadge.sol";
//import{RideLibTicket} from "../../libraries/core/RideLibTicket.sol";
//import{RideLibDriver} from "../../libraries/core/RideLibDriver.sol";
//import{RideLibDriverRegistry} from "../../libraries/core/RideLibDriverRegistry.sol";

//import{IRideDriverRegistry} from "../../interfaces/core/IRideDriverRegistry.sol";

contract RideDriverRegistry is IRideDriverRegistry {
    /**
     * registerDriver registers approved applicants (has passed background check)
     *
     * @param _maxMetresPerTrip | unit in metre
     *
     * @custom:event RegisteredAsDriver
     */
    function registerAsDriver(uint256 _maxMetresPerTrip) external override {
        RideLibDriver._requireNotDriver();
        RideLibTicket._requireNotActive();
        RideLibBadge.StorageBadge storage s1 = RideLibBadge._storageBadge();
        require(
            bytes(s1.driverToDriverReputation[msg.sender].uri).length != 0,
            "uri not set in bg check"
        );
        require(msg.sender != address(0), "0 address");

        s1.driverToDriverReputation[msg.sender].id = RideLibDriverRegistry
            ._mint();
        s1
            .driverToDriverReputation[msg.sender]
            .maxMetresPerTrip = _maxMetresPerTrip;
        s1.driverToDriverReputation[msg.sender].metresTravelled = 0;
        s1.driverToDriverReputation[msg.sender].countStart = 0;
        s1.driverToDriverReputation[msg.sender].countEnd = 0;
        s1.driverToDriverReputation[msg.sender].totalRating = 0;
        s1.driverToDriverReputation[msg.sender].countRating = 0;

        emit RegisteredAsDriver(msg.sender);
    }

    /**
     * updateMaxMetresPerTrip updates maximum metre per trip of driver
     *
     * @param _maxMetresPerTrip | unit in metre
     */
    function updateMaxMetresPerTrip(uint256 _maxMetresPerTrip)
        external
        override
    {
        RideLibDriver._requireIsDriver();
        RideLibTicket._requireNotActive();
        RideLibBadge
            ._storageBadge()
            .driverToDriverReputation[msg.sender]
            .maxMetresPerTrip = _maxMetresPerTrip;

        emit MaxMetresUpdated(msg.sender, _maxMetresPerTrip);
    }

    /**
     * approveApplicant of driver applicants
     *
     * @param _driver applicant
     * @param _uri information of applicant
     *
     * @custom:event ApplicantApproved
     */
    function approveApplicant(address _driver, string memory _uri)
        external
        override
    {
        RideLibOwnership._requireIsContractOwner();

        RideLibBadge.StorageBadge storage s1 = RideLibBadge._storageBadge();

        require(
            bytes(s1.driverToDriverReputation[_driver].uri).length == 0,
            "uri already set"
        );
        s1.driverToDriverReputation[_driver].uri = _uri;

        emit ApplicantApproved(_driver);
    }
}



}
