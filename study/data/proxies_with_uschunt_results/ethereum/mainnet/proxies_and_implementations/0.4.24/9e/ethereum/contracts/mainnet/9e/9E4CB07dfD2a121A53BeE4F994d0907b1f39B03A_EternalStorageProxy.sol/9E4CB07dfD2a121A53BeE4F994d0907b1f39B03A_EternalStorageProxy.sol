// File: bridge-contracts/contracts/upgradeability/EternalStorage.sol

pragma solidity 0.4.24;

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

// File: openzeppelin-solidity/contracts/AddressUtils.sol

pragma solidity ^0.4.24;


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

// File: bridge-contracts/contracts/upgradeability/Proxy.sol

pragma solidity 0.4.24;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    /* solcov ignore next */
    function implementation() public view returns (address);

    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function() public payable {
        // solhint-disable-previous-line no-complex-fallback
        address _impl = implementation();
        require(_impl != address(0));
        assembly {
            /*
                0x40 is the "free memory slot", meaning a pointer to next slot of empty memory. mload(0x40)
                loads the data in the free memory slot, so `ptr` is a pointer to the next slot of empty
                memory. It's needed because we're going to write the return data of delegatecall to the
                free memory slot.
            */
            let ptr := mload(0x40)
            /*
                `calldatacopy` is copy calldatasize bytes from calldata
                First argument is the destination to which data is copied(ptr)
                Second argument specifies the start position of the copied data.
                    Since calldata is sort of its own unique location in memory,
                    0 doesn't refer to 0 in memory or 0 in storage - it just refers to the zeroth byte of calldata.
                    That's always going to be the zeroth byte of the function selector.
                Third argument, calldatasize, specifies how much data will be copied.
                    calldata is naturally calldatasize bytes long (same thing as msg.data.length)
            */
            calldatacopy(ptr, 0, calldatasize)
            /*
                delegatecall params explained:
                gas: the amount of gas to provide for the call. `gas` is an Opcode that gives
                    us the amount of gas still available to execution

                _impl: address of the contract to delegate to

                ptr: to pass copied data

                calldatasize: loads the size of `bytes memory data`, same as msg.data.length

                0, 0: These are for the `out` and `outsize` params. Because the output could be dynamic,
                        these are set to 0, 0 so the output data will not be written to memory. The output
                        data will be read using `returndatasize` and `returdatacopy` instead.

                result: This will be 0 if the call fails and 1 if it succeeds
            */
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            /*

            */
            /*
                ptr current points to the value stored at 0x40,
                because we assigned it like ptr := mload(0x40).
                Because we use 0x40 as a free memory pointer,
                we want to make sure that the next time we want to allocate memory,
                we aren't overwriting anything //important.
                So, by adding ptr and returndatasize,
                we get a memory location beyond the end of the data we will be copying to ptr.
                We place this in at 0x40, and any reads from 0x40 will now read from free memory
            */
            mstore(0x40, add(ptr, returndatasize))
            /*
                `returndatacopy` is an Opcode that copies the last return data to a slot. `ptr` is the
                    slot it will copy to, 0 means copy from the beginning of the return data, and size is
                    the amount of data to copy.
                `returndatasize` is an Opcode that gives us the size of the last return data. In this case, that is the size of the data returned from delegatecall
            */
            returndatacopy(ptr, 0, returndatasize)

            /*
                if `result` is 0, revert.
                if `result` is 1, return `size` amount of data from `ptr`. This is the data that was
                copied to `ptr` from the delegatecall return data
            */
            switch result
                case 0 {
                    revert(ptr, returndatasize)
                }
                default {
                    return(ptr, returndatasize)
                }
        }
    }
}

// File: bridge-contracts/contracts/upgradeability/UpgradeabilityStorage.sol

pragma solidity 0.4.24;

/**
 * @title UpgradeabilityStorage
 * @dev This contract holds all the necessary state variables to support the upgrade functionality
 */
contract UpgradeabilityStorage {
    // Version name of the current implementation
    uint256 internal _version;

    // Address of the current implementation
    address internal _implementation;

    /**
    * @dev Tells the version name of the current implementation
    * @return uint256 representing the name of the current version
    */
    function version() external view returns (uint256) {
        return _version;
    }

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address) {
        return _implementation;
    }
}

// File: bridge-contracts/contracts/upgradeability/UpgradeabilityProxy.sol

pragma solidity 0.4.24;




/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy, UpgradeabilityStorage {
    /**
    * @dev This event will be emitted every time the implementation gets upgraded
    * @param version representing the version name of the upgraded implementation
    * @param implementation representing the address of the upgraded implementation
    */
    event Upgraded(uint256 version, address indexed implementation);

    /**
    * @dev Upgrades the implementation address
    * @param version representing the version name of the new implementation to be set
    * @param implementation representing the address of the new implementation to be set
    */
    function _upgradeTo(uint256 version, address implementation) internal {
        require(_implementation != implementation);
        require(AddressUtils.isContract(implementation));
        require(version > _version);
        _version = version;
        _implementation = implementation;
        emit Upgraded(version, implementation);
    }
}

// File: bridge-contracts/contracts/upgradeability/UpgradeabilityOwnerStorage.sol

pragma solidity 0.4.24;

/**
 * @title UpgradeabilityOwnerStorage
 * @dev This contract keeps track of the upgradeability owner
 */
contract UpgradeabilityOwnerStorage {
    // Owner of the contract
    address internal _upgradeabilityOwner;

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function upgradeabilityOwner() public view returns (address) {
        return _upgradeabilityOwner;
    }

    /**
    * @dev Sets the address of the owner
    */
    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
        _upgradeabilityOwner = newUpgradeabilityOwner;
    }
}

// File: bridge-contracts/contracts/upgradeability/OwnedUpgradeabilityProxy.sol

pragma solidity 0.4.24;



/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityOwnerStorage, UpgradeabilityProxy {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev the constructor sets the original owner of the contract to the sender account.
    */
    constructor() public {
        setUpgradeabilityOwner(msg.sender);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyUpgradeabilityOwner() {
        require(msg.sender == upgradeabilityOwner());
        /* solcov ignore next */
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferProxyOwnership(address newOwner) external onlyUpgradeabilityOwner {
        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(upgradeabilityOwner(), newOwner);
        setUpgradeabilityOwner(newOwner);
    }

    /**
    * @dev Allows the upgradeability owner to upgrade the current version of the proxy.
    * @param version representing the version name of the new implementation to be set.
    * @param implementation representing the address of the new implementation to be set.
    */
    function upgradeTo(uint256 version, address implementation) public onlyUpgradeabilityOwner {
        _upgradeTo(version, implementation);
    }

    /**
    * @dev Allows the upgradeability owner to upgrade the current version of the proxy and call the new implementation
    * to initialize whatever is needed through a low level call.
    * @param version representing the version name of the new implementation to be set.
    * @param implementation representing the address of the new implementation to be set.
    * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
    * signature of the implementation to be called with the needed payload
    */
    function upgradeToAndCall(uint256 version, address implementation, bytes data)
        external
        payable
        onlyUpgradeabilityOwner
    {
        upgradeTo(version, implementation);
        // solhint-disable-next-line avoid-call-value
        require(address(this).call.value(msg.value)(data));
    }
}

// File: contracts/upgradeability/EternalStorageProxy.sol

pragma solidity 0.4.24;



/**
 * @title EternalStorageProxy
 * @dev This proxy holds the storage of the token contract and delegates every call to the current implementation set.
 * Besides, it allows to upgrade the token's behaviour towards further implementations, and provides basic
 * authorization control functionalities
 */
// solhint-disable-next-line no-empty-blocks
contract EternalStorageProxy is EternalStorage, OwnedUpgradeabilityProxy {}


// File: bridge-contracts/contracts/upgradeable_contracts/Initializable.sol

pragma solidity 0.4.24;


contract Initializable is EternalStorage {
    bytes32 internal constant INITIALIZED = keccak256(abi.encodePacked("isInitialized"));
    bytes32 internal constant DEPLOYED_AT_BLOCK = keccak256(abi.encodePacked("deployedAtBlock"));

    function setInitialize() internal {
        boolStorage[INITIALIZED] = true;
    }

    function isInitialized() public view returns (bool) {
        return boolStorage[INITIALIZED];
    }

    function deployedAtBlock() external view returns (uint256) {
        return uintStorage[DEPLOYED_AT_BLOCK];
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


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

// File: bridge-contracts/contracts/upgradeable_contracts/Sacrifice.sol

pragma solidity 0.4.24;

contract Sacrifice {
    constructor(address _recipient) public payable {
        selfdestruct(_recipient);
    }
}

// File: bridge-contracts/contracts/upgradeable_contracts/Claimable.sol

pragma solidity 0.4.24;



contract Claimable {
    bytes4 internal constant TRANSFER = 0xa9059cbb; // transfer(address,uint256)

    modifier validAddress(address _to) {
        require(_to != address(0));
        /* solcov ignore next */
        _;
    }

    function claimValues(address _token, address _to) internal {
        if (_token == address(0)) {
            claimNativeCoins(_to);
        } else {
            claimErc20Tokens(_token, _to);
        }
    }

    function claimNativeCoins(address _to) internal {
        uint256 value = address(this).balance;
        if (!_to.send(value)) {
            (new Sacrifice).value(value)(_to);
        }
    }

    function claimErc20Tokens(address _token, address _to) internal {
        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        safeTransfer(_token, _to, balance);
    }

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        bytes memory returnData;
        bool returnDataResult;
        bytes memory callData = abi.encodeWithSelector(TRANSFER, _to, _value);
        assembly {
            let result := call(gas, _token, 0x0, add(callData, 0x20), mload(callData), 0, 32)
            returnData := mload(0)
            returnDataResult := mload(0)

            switch result
                case 0 {
                    revert(0, 0)
                }
        }

        // Return data is optional
        if (returnData.length > 0) {
            require(returnDataResult);
        }
    }
}

// File: bridge-contracts/contracts/interfaces/IUpgradeabilityOwnerStorage.sol

pragma solidity 0.4.24;

interface IUpgradeabilityOwnerStorage {
    function upgradeabilityOwner() external view returns (address);
}

// File: bridge-contracts/contracts/upgradeable_contracts/Upgradeable.sol

pragma solidity 0.4.24;


contract Upgradeable {
    // Avoid using onlyUpgradeabilityOwner name to prevent issues with implementation from proxy contract
    modifier onlyIfUpgradeabilityOwner() {
        require(msg.sender == IUpgradeabilityOwnerStorage(this).upgradeabilityOwner());
        /* solcov ignore next */
        _;
    }
}

// File: bridge-contracts/contracts/libraries/Bytes.sol

pragma solidity 0.4.24;

library Bytes {
    function bytesToBytes32(bytes _bytes) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(_bytes, 32))
        }
    }
}

// File: bridge-contracts/contracts/interfaces/IAMB.sol

pragma solidity 0.4.24;

interface IAMB {
    function messageSender() external view returns (address);
    function maxGasPerTx() external view returns (uint256);
    function transactionHash() external view returns (bytes32);
    function messageCallStatus(bytes32 _txHash) external view returns (bool);
    function failedMessageDataHash(bytes32 _txHash) external view returns (bytes32);
    function failedMessageReceiver(bytes32 _txHash) external view returns (address);
    function failedMessageSender(bytes32 _txHash) external view returns (address);
    function requireToPassMessage(address _contract, bytes _data, uint256 _gas) external;
}

// File: bridge-contracts/contracts/upgradeable_contracts/Ownable.sol

pragma solidity 0.4.24;


/**
 * @title Ownable
 * @dev This contract has an owner address providing basic authorization control
 */
contract Ownable is EternalStorage {
    /**
    * @dev Event to show ownership has been transferred
    * @param previousOwner representing the address of the previous owner
    * @param newOwner representing the address of the new owner
    */
    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner());
        /* solcov ignore next */
        _;
    }

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function owner() public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("owner"))];
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner the address to transfer ownership to.
    */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        setOwner(newOwner);
    }

    /**
    * @dev Sets a new owner address
    */
    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);
        addressStorage[keccak256(abi.encodePacked("owner"))] = newOwner;
    }
}

// File: contracts/mediator/AMBMediator.sol

pragma solidity 0.4.24;





contract AMBMediator is EternalStorage, Ownable {
    bytes32 internal constant BRIDGE_CONTRACT = keccak256(abi.encodePacked("bridgeContract"));
    bytes32 internal constant MEDIATOR_CONTRACT = keccak256(abi.encodePacked("mediatorContract"));
    bytes32 internal constant REQUEST_GAS_LIMIT = keccak256(abi.encodePacked("requestGasLimit"));

    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    function _setBridgeContract(address _bridgeContract) internal {
        require(AddressUtils.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    function bridgeContract() public view returns (IAMB) {
        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    function mediatorContractOnOtherSide() public view returns (address) {
        return addressStorage[MEDIATOR_CONTRACT];
    }

    function setRequestGasLimit(uint256 _requestGasLimit) external onlyOwner {
        _setRequestGasLimit(_requestGasLimit);
    }

    function _setRequestGasLimit(uint256 _requestGasLimit) internal {
        require(_requestGasLimit <= bridgeContract().maxGasPerTx());
        uintStorage[REQUEST_GAS_LIMIT] = _requestGasLimit;
    }

    function requestGasLimit() public view returns (uint256) {
        return uintStorage[REQUEST_GAS_LIMIT];
    }
}

// File: contracts/kitty/ERC721.sol

pragma solidity 0.4.24;
/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

// File: contracts/mediator/ERC721Bridge.sol

pragma solidity 0.4.24;




contract ERC721Bridge is EternalStorage {
    bytes32 internal constant ERC721_TOKEN = keccak256(abi.encodePacked("erc721token"));

    function erc721token() public view returns (ERC721) {
        return ERC721(addressStorage[ERC721_TOKEN]);
    }

    function setErc721token(address _token) internal {
        require(AddressUtils.isContract(_token));
        addressStorage[ERC721_TOKEN] = _token;
    }
}

// File: contracts/mediator/BasicMediator.sol

pragma solidity 0.4.24;







contract BasicMediator is Initializable, AMBMediator, ERC721Bridge, Upgradeable, Claimable {
    event FailedMessageFixed(bytes32 indexed dataHash, address recipient, uint256 tokenId);

    bytes32 internal constant NONCE = keccak256(abi.encodePacked("nonce"));
    bytes4 internal constant GET_KITTY = 0xe98b7f4d; // getKitty(uint256)

    function initialize(
        address _bridgeContract,
        address _mediatorContract,
        address _erc721token,
        uint256 _requestGasLimit,
        address _owner
    ) external returns (bool) {
        require(!isInitialized());

        _setBridgeContract(_bridgeContract);
        _setMediatorContractOnOtherSide(_mediatorContract);
        setErc721token(_erc721token);
        _setRequestGasLimit(_requestGasLimit);
        setOwner(_owner);
        setNonce(keccak256(abi.encodePacked(address(this))));
        setInitialize();

        return isInitialized();
    }

    function getBridgeInterfacesVersion() external pure returns (uint64 major, uint64 minor, uint64 patch) {
        return (1, 0, 0);
    }

    function getBridgeMode() external pure returns (bytes4 _data) {
        return bytes4(keccak256(abi.encodePacked("nft-to-nft-amb")));
    }

    function transferToken(address _from, uint256 _tokenId) external {
        ERC721 token = erc721token();
        address to = address(this);

        token.transferFrom(_from, to, _tokenId);
        bridgeSpecificActionsOnTokenTransfer(_from, _tokenId);
    }

    /**
    *  getKitty(uint256) returns:
    *       bool isGestating,
    *       bool isReady,
    *       uint256 cooldownIndex,
    *       uint256 nextActionAt,
    *       uint256 siringWithId,
    *       uint256 birthTime,
    *       uint256 matronId,
    *       uint256 sireId,
    *       uint256 generation,
    *       uint256 genes
    **/
    function getMetadata(uint256 _tokenId) internal view returns (bytes memory metadata) {
        bytes memory callData = abi.encodeWithSelector(GET_KITTY, _tokenId);
        address tokenAddress = erc721token();
        metadata = new bytes(320);
        assembly {
            let result := call(gas, tokenAddress, 0x0, add(callData, 0x20), mload(callData), 0, 0)
            returndatacopy(add(metadata, 0x20), 0, returndatasize)

            switch result
                case 0 {
                    revert(0, 0)
                }
        }
    }

    function nonce() internal view returns (bytes32) {
        return Bytes.bytesToBytes32(bytesStorage[NONCE]);
    }

    function setNonce(bytes32 _hash) internal {
        bytesStorage[NONCE] = abi.encodePacked(_hash);
    }

    function setMessageHashTokenId(bytes32 _hash, uint256 _tokenId) internal {
        uintStorage[keccak256(abi.encodePacked("messageHashTokenId", _hash))] = _tokenId;
    }

    function messageHashTokenId(bytes32 _hash) internal view returns (uint256) {
        return uintStorage[keccak256(abi.encodePacked("messageHashTokenId", _hash))];
    }

    function setMessageHashRecipient(bytes32 _hash, address _recipient) internal {
        addressStorage[keccak256(abi.encodePacked("messageHashRecipient", _hash))] = _recipient;
    }

    function messageHashRecipient(bytes32 _hash) internal view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("messageHashRecipient", _hash))];
    }

    function setMessageHashFixed(bytes32 _hash) internal {
        boolStorage[keccak256(abi.encodePacked("messageHashFixed", _hash))] = true;
    }

    function messageHashFixed(bytes32 _hash) public view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("messageHashFixed", _hash))];
    }

    function requestFailedMessageFix(bytes32 _txHash) external {
        require(!bridgeContract().messageCallStatus(_txHash));
        require(bridgeContract().failedMessageReceiver(_txHash) == address(this));
        require(bridgeContract().failedMessageSender(_txHash) == mediatorContractOnOtherSide());
        bytes32 dataHash = bridgeContract().failedMessageDataHash(_txHash);

        bytes4 methodSelector = this.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, dataHash);
        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function claimTokens(address _token, address _to) public onlyIfUpgradeabilityOwner validAddress(_to) {
        claimValues(_token, _to);
    }

    function fixFailedMessage(bytes32 _dataHash) external;

    function bridgeSpecificActionsOnTokenTransfer(address _from, uint256 _tokenId) internal;
}

// File: contracts/interfaces/IHomeMediator.sol

pragma solidity 0.4.24;

interface IHomeMediator {
    function handleBridgedTokens(address _recipient, uint256 _tokenId, bytes _metadata, bytes32 _nonce) external;
}

// File: contracts/mediator/ForeignMediator.sol

pragma solidity 0.4.24;



contract ForeignMediator is BasicMediator {
    function passMessage(address _from, uint256 _tokenId) internal {
        bytes memory metadata = getMetadata(_tokenId);

        bytes4 methodSelector = IHomeMediator(0).handleBridgedTokens.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _from, _tokenId, metadata, nonce());

        bytes32 dataHash = keccak256(data);
        setMessageHashTokenId(dataHash, _tokenId);
        setMessageHashRecipient(dataHash, _from);
        setNonce(dataHash);

        bridgeContract().requireToPassMessage(mediatorContractOnOtherSide(), data, requestGasLimit());
    }

    function handleBridgedTokens(
        address _recipient,
        uint256 _tokenId,
        bytes32 /* _nonce */
    ) external {
        require(msg.sender == address(bridgeContract()));
        require(bridgeContract().messageSender() == mediatorContractOnOtherSide());
        erc721token().transfer(_recipient, _tokenId);
    }

    function bridgeSpecificActionsOnTokenTransfer(address _from, uint256 _tokenId) internal {
        passMessage(_from, _tokenId);
    }

    function fixFailedMessage(bytes32 _dataHash) external {
        require(msg.sender == address(bridgeContract()));
        require(bridgeContract().messageSender() == mediatorContractOnOtherSide());
        require(!messageHashFixed(_dataHash));

        address recipient = messageHashRecipient(_dataHash);
        uint256 tokenId = messageHashTokenId(_dataHash);

        setMessageHashFixed(_dataHash);
        erc721token().transfer(recipient, tokenId);

        emit FailedMessageFixed(_dataHash, recipient, tokenId);
    }
}