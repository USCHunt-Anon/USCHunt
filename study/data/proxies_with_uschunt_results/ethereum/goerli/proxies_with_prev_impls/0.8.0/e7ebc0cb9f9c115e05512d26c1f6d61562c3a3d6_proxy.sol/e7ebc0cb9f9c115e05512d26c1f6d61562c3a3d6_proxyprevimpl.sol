pragma solidity ^0.6.12;

library CairoConstants {
    uint256 public constant FIELD_PRIME =
        0x800000000000011000000000000000000000000000000000000000000000001;
}


// : Apache-2.0.
pragma solidity ^0.6.12;

/*
  Common Utility librarries.
  I. Addresses (extending address).
*/
library Addresses {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function performEthTransfer(address recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{value: amount}(""); // NOLINT: low-level-calls.
        require(success, "ETH_TRANSFER_FAILED");
    }

    /*
      Safe wrapper around ERC20/ERC721 calls.
      This is required because many deployed ERC20 contracts don't return a value.
      See https://github.com/ethereum/solidity/issues/4116.
    */
    function safeTokenContractCall(address tokenAddress, bytes memory callData) internal {
        require(isContract(tokenAddress), "BAD_TOKEN_ADDRESS");
        // NOLINTNEXTLINE: low-level-calls.
        (bool success, bytes memory returndata) = tokenAddress.call(callData);
        require(success, string(returndata));

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "TOKEN_OPERATION_FAILED");
        }
    }

    /*
      Validates that the passed contract address is of a real contract,
      and that its id hash (as infered fromn identify()) matched the expected one.
    */
    function validateContractId(address contractAddress, bytes32 expectedIdHash) internal {
        require(isContract(contractAddress), "ADDRESS_NOT_CONTRACT");
        (bool success, bytes memory returndata) = contractAddress.call( // NOLINT: low-level-calls.
            abi.encodeWithSignature("identify()")
        );
        require(success, "FAILED_TO_IDENTIFY_CONTRACT");
        string memory realContractId = abi.decode(returndata, (string));
        require(
            keccak256(abi.encodePacked(realContractId)) == expectedIdHash,
            "UNEXPECTED_CONTRACT_IDENTIFIER"
        );
    }
}

/*
  II. StarkExTypes - Common data types.
*/
library StarkExTypes {
    // Structure representing a list of verifiers (validity/availability).
    // A statement is valid only if all the verifiers in the list agree on it.
    // Adding a verifier to the list is immediate - this is used for fast resolution of
    // any soundness issues.
    // Removing from the list is time-locked, to ensure that any user of the system
    // not content with the announced removal has ample time to leave the system before it is
    // removed.
    struct ApprovalChainData {
        address[] list;
        // Represents the time after which the verifier with the given address can be removed.
        // Removal of the verifier with address A is allowed only in the case the value
        // of unlockedForRemovalTime[A] != 0 and unlockedForRemovalTime[A] < (current time).
        mapping(address => uint256) unlockedForRemovalTime;
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

/**
  Interface for contract initialization.
  The functions it exposes are the app specific parts of the contract initialization,
  and are called by the ProxySupport contract that implement the generic part of behind-proxy
  initialization.
*/
abstract contract ContractInitializer {
    function numOfSubContracts() internal pure virtual returns (uint256);

    function isInitialized() internal view virtual returns (bool);

    function validateInitData(bytes calldata data) internal pure virtual;

    function processSubContractAddresses(bytes calldata subContractAddresses) internal virtual;

    function initializeContractState(bytes calldata data) internal virtual;
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"Governance.sol";

contract GenericGovernance is Governance {
    bytes32 immutable GOVERNANCE_INFO_TAG_HASH;

    constructor(string memory governanceContext) public {
        GOVERNANCE_INFO_TAG_HASH = keccak256(abi.encodePacked(governanceContext));
    }

    /*
      Returns the GovernanceInfoStruct associated with the governance tag.
    */
    function getGovernanceInfo() internal view override returns (GovernanceInfoStruct storage gub) {
        bytes32 location = GOVERNANCE_INFO_TAG_HASH;
        assembly {
            gub_slot := location
        }
    }

    function isGovernor(address testGovernor) external view returns (bool) {
        return _isGovernor(testGovernor);
    }

    function nominateNewGovernor(address newGovernor) external {
        _nominateNewGovernor(newGovernor);
    }

    function removeGovernor(address governorForRemoval) external {
        _removeGovernor(governorForRemoval);
    }

    function acceptGovernance() external {
        _acceptGovernance();
    }

    function cancelNomination() external {
        _cancelNomination();
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"MGovernance.sol";

/*
  Implements Generic Governance, applicable for both proxy and main contract, and possibly others.
  Notes:
   The use of the same function names by both the Proxy and a delegated implementation
   is not possible since calling the implementation functions is done via the default function
   of the Proxy. For this reason, for example, the implementation of MainContract (MainGovernance)
   exposes mainIsGovernor, which calls the internal _isGovernor method.
*/
abstract contract Governance is MGovernance {
    event LogNominatedGovernor(address nominatedGovernor);
    event LogNewGovernorAccepted(address acceptedGovernor);
    event LogRemovedGovernor(address removedGovernor);
    event LogNominationCancelled();

    function getGovernanceInfo() internal view virtual returns (GovernanceInfoStruct storage);

    /*
      Current code intentionally prevents governance re-initialization.
      This may be a problem in an upgrade situation, in a case that the upgrade-to implementation
      performs an initialization (for real) and within that calls initGovernance().

      Possible workarounds:
      1. Clearing the governance info altogether by changing the MAIN_GOVERNANCE_INFO_TAG.
         This will remove existing main governance information.
      2. Modify the require part in this function, so that it will exit quietly
         when trying to re-initialize (uncomment the lines below).
    */
    function initGovernance() internal {
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        require(!gub.initialized, "ALREADY_INITIALIZED");
        gub.initialized = true; // to ensure addGovernor() won't fail.
        // Add the initial governer.
        addGovernor(msg.sender);
    }

    function _isGovernor(address testGovernor) internal view override returns (bool) {
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        return gub.effectiveGovernors[testGovernor];
    }

    /*
      Cancels the nomination of a governor candidate.
    */
    function _cancelNomination() internal onlyGovernance {
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        gub.candidateGovernor = address(0x0);
        emit LogNominationCancelled();
    }

    function _nominateNewGovernor(address newGovernor) internal onlyGovernance {
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        require(!_isGovernor(newGovernor), "ALREADY_GOVERNOR");
        gub.candidateGovernor = newGovernor;
        emit LogNominatedGovernor(newGovernor);
    }

    /*
      The addGovernor is called in two cases:
      1. by _acceptGovernance when a new governor accepts its role.
      2. by initGovernance to add the initial governor.
      The difference is that the init path skips the nominate step
      that would fail because of the onlyGovernance modifier.
    */
    function addGovernor(address newGovernor) private {
        require(!_isGovernor(newGovernor), "ALREADY_GOVERNOR");
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        gub.effectiveGovernors[newGovernor] = true;
    }

    function _acceptGovernance() internal {
        // The new governor was proposed as a candidate by the current governor.
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        require(msg.sender == gub.candidateGovernor, "ONLY_CANDIDATE_GOVERNOR");

        // Update state.
        addGovernor(gub.candidateGovernor);
        gub.candidateGovernor = address(0x0);

        // Send a notification about the change of governor.
        emit LogNewGovernorAccepted(msg.sender);
    }

    /*
      Remove a governor from office.
    */
    function _removeGovernor(address governorForRemoval) internal onlyGovernance {
        require(msg.sender != governorForRemoval, "GOVERNOR_SELF_REMOVE");
        GovernanceInfoStruct storage gub = getGovernanceInfo();
        require(_isGovernor(governorForRemoval), "NOT_GOVERNOR");
        gub.effectiveGovernors[governorForRemoval] = false;
        emit LogRemovedGovernor(governorForRemoval);
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

interface IStarknetMessaging {
    // This event needs to be compatible with the one defined in Output.sol.
    event LogMessageToL1(
        uint256 indexed from_address,
        address indexed to_address,
        uint256[] payload
    );

    // An event that is raised when a message is sent from L1 to L2.
    event LogMessageToL2(
        address indexed from_address,
        uint256 indexed to_address,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce
    );

    // An event that is raised when a message from L2 to L1 is consumed.
    event ConsumedMessageToL1(
        uint256 indexed from_address,
        address indexed to_address,
        uint256[] payload
    );

    // An event that is raised when a message from L1 to L2 is consumed.
    event ConsumedMessageToL2(
        address indexed from_address,
        uint256 indexed to_address,
        uint256 indexed selector,
        uint256[] payload,
        uint256 nonce
    );

    /**
      Sends a message to an L2 contract.

      Returns the hash of the message.
    */
    function sendMessageToL2(
        uint256 to_address,
        uint256 selector,
        uint256[] calldata payload
    ) external returns (bytes32);

    /**
      Consumes a message that was sent from an L2 contract.

      Returns the hash of the message.
    */
    function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
        external
        returns (bytes32);
}


// : Apache-2.0.
pragma solidity ^0.6.12;

struct GovernanceInfoStruct {
    mapping(address => bool) effectiveGovernors;
    address candidateGovernor;
    bool initialized;
}

abstract contract MGovernance {
    function _isGovernor(address testGovernor) internal view virtual returns (bool);

    /*
      Allows calling the function only by a Governor.
    */
    modifier onlyGovernance() {
        require(_isGovernor(msg.sender), "ONLY_GOVERNANCE");
        _;
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

/*
  Library to provide basic storage, in storage location out of the low linear address space.

  New types of storage variables should be added here upon need.
*/
library NamedStorage {
    function bytes32ToUint256Mapping(string memory tag_)
        internal
        pure
        returns (mapping(bytes32 => uint256) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable_slot := location
        }
    }

    function bytes32ToAddressMapping(string memory tag_)
        internal
        pure
        returns (mapping(bytes32 => address) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable_slot := location
        }
    }

    function addressToBoolMapping(string memory tag_)
        internal
        pure
        returns (mapping(address => bool) storage randomVariable)
    {
        bytes32 location = keccak256(abi.encodePacked(tag_));
        assembly {
            randomVariable_slot := location
        }
    }

    function getUintValue(string memory tag_) internal view returns (uint256 retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setUintValue(string memory tag_, uint256 value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }

    function setUintValueOnce(string memory tag_, uint256 value) internal {
        require(getUintValue(tag_) == 0, "ALREADY_SET");
        setUintValue(tag_, value);
    }

    function getAddressValue(string memory tag_) internal view returns (address retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setAddressValue(string memory tag_, address value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }

    function setAddressValueOnce(string memory tag_, address value) internal {
        require(getAddressValue(tag_) == address(0x0), "ALREADY_SET");
        setAddressValue(tag_, value);
    }

    function getBoolValue(string memory tag_) internal view returns (bool retVal) {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            retVal := sload(slot)
        }
    }

    function setBoolValue(string memory tag_, bool value) internal {
        bytes32 slot = keccak256(abi.encodePacked(tag_));
        assembly {
            sstore(slot, value)
        }
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"Governance.sol";
//import"Common.sol";
//import"BlockDirectCall.sol";
//import"ContractInitializer.sol";

/**
  This contract contains the code commonly needed for a contract to be deployed behind
  an upgradability proxy.
  It perform the required semantics of the proxy pattern,
  but in a generic manner.
  Instantiation of the Governance and of the ContractInitializer, that are the app specific
  part of initialization, has to be done by the using contract.
*/
abstract contract ProxySupport is Governance, BlockDirectCall, ContractInitializer {
    using Addresses for address;

    // The two function below (isFrozen & initialize) needed to bind to the Proxy.
    function isFrozen() external view virtual returns (bool) {
        return false;
    }

    /*
      The initialize() function serves as an alternative constructor for a proxied deployment.

      Flow and notes:
      1. This function cannot be called directly on the deployed contract, but only via
         delegate call.
      2. If an EIC is provided - init is passed onto EIC and the standard init flow is skipped.
         This true for both first intialization or a later one.
      3. The data passed to this function is as follows:
         [sub_contracts addresses, eic address, initData].

         When calling on an initialized contract (no EIC scenario), initData.length must be 0.
    */
    function initialize(bytes calldata data) external notCalledDirectly {
        uint256 eicOffset = 32 * numOfSubContracts();
        uint256 expectedBaseSize = eicOffset + 32;
        require(data.length >= expectedBaseSize, "INIT_DATA_TOO_SMALL");
        address eicAddress = abi.decode(data[eicOffset:expectedBaseSize], (address));

        bytes calldata subContractAddresses = data[:eicOffset];

        processSubContractAddresses(subContractAddresses);

        bytes calldata initData = data[expectedBaseSize:];

        // EIC Provided - Pass initData to EIC and the skip standard init flow.
        if (eicAddress != address(0x0)) {
            callExternalInitializer(eicAddress, initData);
            return;
        }

        if (isInitialized()) {
            require(initData.length == 0, "UNEXPECTED_INIT_DATA");
        } else {
            // Contract was not initialized yet.
            validateInitData(initData);
            initializeContractState(initData);
            initGovernance();
        }
    }

    function callExternalInitializer(address externalInitializerAddr, bytes calldata eicData)
        private
    {
        require(externalInitializerAddr.isContract(), "EIC_NOT_A_CONTRACT");

        // NOLINTNEXTLINE: low-level-calls, controlled-delegatecall.
        (bool success, bytes memory returndata) = externalInitializerAddr.delegatecall(
            abi.encodeWithSelector(this.initialize.selector, eicData)
        );
        require(success, string(returndata));
        require(returndata.length == 0, string(returndata));
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"Common.sol";
//import"StarknetTokenBridge.sol";

contract StarknetEthBridge is StarknetTokenBridge {
    using Addresses for address;

    function deposit(uint256 l2Recipient) external payable {
        // The msg.value in this transaction was already credited to the contract.
        require(address(this).balance <= maxTotalBalance(), "MAX_BALANCE_EXCEEDED");
        sendMessage(msg.value, l2Recipient);
    }

    function withdraw(uint256 amount, address recipient) public override {
        consumeMessage(amount, recipient);
        // Make sure we don't accidentally burn funds.
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        require(address(this).balance - amount <= address(this).balance, "UNDERFLOW");
        recipient.performEthTransfer(amount);
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"GenericGovernance.sol";
//import"ContractInitializer.sol";
//import"ProxySupport.sol";
//import"CairoConstants.sol";
//import"StarknetTokenStorage.sol";
//import"IStarknetMessaging.sol";

abstract contract StarknetTokenBridge is
    StarknetTokenStorage,
    GenericGovernance,
    ContractInitializer,
    ProxySupport
{
    event LogDeposit(address sender, uint256 amount, uint256 l2Recipient);
    event LogWithdrawal(address recipient, uint256 amount);
    event LogSetL2TokenBridge(uint256 value);
    event LogSetMaxTotalBalance(uint256 value);
    event LogSetMaxDeposit(uint256 value);

    constructor() internal GenericGovernance("STARKWARE_DEFAULT_GOVERNANCE_INFO") {}

    function isInitialized() internal view override returns (bool) {
        return messagingContract() != IStarknetMessaging(0);
    }

    function numOfSubContracts() internal pure override returns (uint256) {
        return 0;
    }

    function validateInitData(bytes calldata data) internal pure override {
        require(data.length == 64, "ILLEGAL_DATA_SIZE");
    }

    function processSubContractAddresses(bytes calldata subContractAddresses) internal override {}

    /*
      Gets the addresses of bridgedToken & messagingContract from the ProxySupport initialize(),
      and sets the storage slot accordingly.
    */
    function initializeContractState(bytes calldata data) internal override {
        (address bridgedToken_, IStarknetMessaging messagingContract_) = abi.decode(
            data,
            (address, IStarknetMessaging)
        );
        bridgedToken(bridgedToken_);
        messagingContract(messagingContract_);
    }

    // The selector of the deposit handler in L2.
    uint256 constant DEPOSIT_SELECTOR =
        1285101517810983806491589552491143496277809242732141897358598292095611420389;
    uint256 constant TRANSFER_FROM_STARKNET = 0;
    uint256 constant UINT256_PART_SIZE_BITS = 128;
    uint256 constant UINT256_PART_SIZE = 2**UINT256_PART_SIZE_BITS;

    modifier isValidL2Address(uint256 l2Address) {
        require(l2Address != 0, "L2_ADDRESS_OUT_OF_RANGE");
        require(l2Address < CairoConstants.FIELD_PRIME, "L2_ADDRESS_OUT_OF_RANGE");
        _;
    }

    modifier l2TokenBridgeNotSet() {
        require(l2TokenBridge() == 0, "L2_TOKEN_CONTRACT_ALREADY_SET");
        _;
    }

    modifier l2TokenBridgeSet() {
        require(l2TokenBridge() != 0, "L2_TOKEN_CONTRACT_NOT_SET");
        _;
    }

    function setL2TokenBridge(uint256 l2TokenBridge_)
        external
        l2TokenBridgeNotSet
        isValidL2Address(l2TokenBridge_)
        onlyGovernance
    {
        emit LogSetL2TokenBridge(l2TokenBridge_);
        l2TokenBridge(l2TokenBridge_);
    }

    function setMaxTotalBalance(uint256 maxTotalBalance_) external onlyGovernance {
        emit LogSetMaxTotalBalance(maxTotalBalance_);
        maxTotalBalance(maxTotalBalance_);
    }

    function setMaxDeposit(uint256 maxDeposit_) external onlyGovernance {
        emit LogSetMaxDeposit(maxDeposit_);
        maxDeposit(maxDeposit_);
    }

    function sendMessage(uint256 amount, uint256 l2Recipient)
        internal
        l2TokenBridgeSet
        isValidL2Address(l2Recipient)
    {
        require(amount <= maxDeposit(), "TRANSFER_TO_STARKNET_AMOUNT_EXCEEDED");
        emit LogDeposit(msg.sender, amount, l2Recipient);

        uint256[] memory payload = new uint256[](3);
        payload[0] = l2Recipient;
        payload[1] = amount & (UINT256_PART_SIZE - 1);
        payload[2] = amount >> UINT256_PART_SIZE_BITS;
        messagingContract().sendMessageToL2(l2TokenBridge(), DEPOSIT_SELECTOR, payload);
    }

    function consumeMessage(uint256 amount, address recipient) internal {
        emit LogWithdrawal(recipient, amount);

        uint256[] memory payload = new uint256[](4);
        payload[0] = TRANSFER_FROM_STARKNET;
        payload[1] = uint256(recipient);
        payload[2] = amount & (UINT256_PART_SIZE - 1);
        payload[3] = amount >> UINT256_PART_SIZE_BITS;

        messagingContract().consumeMessageFromL2(l2TokenBridge(), payload);
    }

    function withdraw(uint256 amount, address recipient) public virtual;

    function withdraw(uint256 amount) external {
        withdraw(amount, msg.sender);
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

//import"NamedStorage.sol";
//import"IStarknetMessaging.sol";

abstract contract StarknetTokenStorage {
    // Random storage slot tags.
    string internal constant BRIDGED_TOKEN_TAG = "STARKNET_ERC20_TOKEN_BRIDGE_TOKEN_ADDRESS";
    string internal constant L2_TOKEN_TAG = "STARKNET_TOKEN_BRIDGE_L2_TOKEN_CONTRACT";
    string internal constant MAX_DEPOSIT_TAG = "STARKNET_TOKEN_BRIDGE_MAX_DEPOSIT";
    string internal constant MAX_TOTAL_BALANCE_TAG = "STARKNET_TOKEN_BRIDGE_MAX_TOTAL_BALANCE";
    string internal constant MESSAGING_CONTRACT_TAG = "STARKNET_TOKEN_BRIDGE_MESSAGING_CONTRACT";

    // Storage Getters.
    function bridgedToken() internal view returns (address) {
        return NamedStorage.getAddressValue(BRIDGED_TOKEN_TAG);
    }

    function l2TokenBridge() internal view returns (uint256) {
        return NamedStorage.getUintValue(L2_TOKEN_TAG);
    }

    function maxDeposit() public view returns (uint256) {
        return NamedStorage.getUintValue(MAX_DEPOSIT_TAG);
    }

    function maxTotalBalance() public view returns (uint256) {
        return NamedStorage.getUintValue(MAX_TOTAL_BALANCE_TAG);
    }

    function messagingContract() internal view returns (IStarknetMessaging) {
        return IStarknetMessaging(NamedStorage.getAddressValue(MESSAGING_CONTRACT_TAG));
    }

    // Storage Setters.
    function bridgedToken(address contract_) internal {
        NamedStorage.setAddressValueOnce(BRIDGED_TOKEN_TAG, contract_);
    }

    function l2TokenBridge(uint256 value) internal {
        NamedStorage.setUintValueOnce(L2_TOKEN_TAG, value);
    }

    function maxDeposit(uint256 value) internal {
        NamedStorage.setUintValue(MAX_DEPOSIT_TAG, value);
    }

    function maxTotalBalance(uint256 value) internal {
        NamedStorage.setUintValue(MAX_TOTAL_BALANCE_TAG, value);
    }

    function messagingContract(IStarknetMessaging contract_) internal {
        NamedStorage.setAddressValueOnce(MESSAGING_CONTRACT_TAG, address(contract_));
    }
}


// : Apache-2.0.
pragma solidity ^0.6.12;

/*
  This contract provides means to block direct call of an external function.
  A derived contract (e.g. MainDispatcherBase) should decorate sensitive functions with the
  notCalledDirectly modifier, thereby preventing it from being called directly, and allowing only calling
  using delegate_call.

  This Guard contract uses pseudo-random slot, So each deployed contract would have its own guard.
*/
abstract contract BlockDirectCall {
    bytes32 immutable UNIQUE_SAFEGUARD_SLOT; // NOLINT naming-convention.

    constructor() internal {
        // The slot is pseudo-random to allow hierarchy of contracts with guarded functions.
        bytes32 slot = keccak256(abi.encode(this, block.timestamp, gasleft()));
        UNIQUE_SAFEGUARD_SLOT = slot;
        assembly {
            sstore(slot, 42)
        }
    }

    modifier notCalledDirectly() {
        {
            // Prevent too many local variables in stack.
            uint256 safeGuardValue;
            bytes32 slot = UNIQUE_SAFEGUARD_SLOT;
            assembly {
                safeGuardValue := sload(slot)
            }
            require(safeGuardValue == 0, "DIRECT_CALL_DISALLOWED");
        }
        _;
    }
}


