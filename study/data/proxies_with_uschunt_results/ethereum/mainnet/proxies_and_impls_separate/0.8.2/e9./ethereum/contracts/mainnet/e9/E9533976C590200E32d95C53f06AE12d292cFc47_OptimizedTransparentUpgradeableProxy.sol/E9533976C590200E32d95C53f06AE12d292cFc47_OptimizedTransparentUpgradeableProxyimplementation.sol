// : MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// : GPL-3.0-only
pragma solidity 0.8.9;

//import"../framework/MessageReceiverApp.sol";
//import"../interfaces/IMessageBus.sol";
//import"../../safeguard/Pauser.sol";

// interface for NFT contract, ERC721 and metadata, only funcs needed by NFTBridge
interface INFT {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    // we do not support NFT that charges transfer fees
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // impl by NFToken contract, mint an NFT with id and uri to user or burn
    function bridgeMint(
        address to,
        uint256 id,
        string memory uri
    ) external;

    function burn(uint256 id) external;
}

/** @title NFT Bridge */
contract NFTBridge is MessageReceiverApp, Pauser {
    /// per dest chain id executor fee in this chain's gas token
    mapping(uint64 => uint256) public destTxFee;
    /// per dest chain id NFTBridge address
    mapping(uint64 => address) public destBridge;
    /// first key is NFT address on this chain, 2nd key is dest chain id, value is address on dest chain
    mapping(address => mapping(uint64 => address)) public destNFTAddr;

    /// only set to true if NFT addr on this chain is the orig, so we will use deposit/withdraw instead of burn/mint.
    /// not applicable for mcn nft (always burn/mint)
    mapping(address => bool) public origNFT;

    struct NFTMsg {
        address user; // receiver of minted or withdrawn NFT
        address nft; // NFT contract on mint/withdraw chain
        uint256 id; // token ID
        string uri; // tokenURI from source NFT
    }
    // emit in deposit or burn
    event Sent(address sender, address srcNft, uint256 id, uint64 dstChid, address receiver, address dstNft);
    // emit for mint or withdraw message
    event Received(address receiver, address nft, uint256 id, uint64 srcChid);

    // emit when params change
    event SetDestNFT(address srcNft, uint64 dstChid, address dstNft);
    event SetTxFee(uint64 chid, uint256 fee);
    event SetDestBridge(uint64 dstChid, address dstNftBridge);
    event FeeClaimed(uint256 amount);
    event SetOrigNFT(address nft, bool isOrig);
    // emit if executeMessage calls nft transfer or bridgeMint returns error
    event ExtCallErr(bytes returnData);

    constructor(address _msgBus) {
        messageBus = _msgBus;
    }

    // only to be called by Proxy via delegatecall and will modify Proxy state
    // initOwner will fail if owner is already set, so only delegateCall will work
    function init(address _msgBus) external {
        initOwner();
        messageBus = _msgBus;
    }

    /**
     * @notice totalFee returns gas token value to be set in user tx, includes both cbridge msg fee and executor fee on dest chain
     * @dev we use _nft address for user as it's same length so same msg cost
     * @param _dstChid dest chain ID
     * @param _nft address of source NFT contract
     * @param _id token ID to bridge (need to get accurate tokenURI length)
     * @return total fee needed for user tx
     */
    function totalFee(
        uint64 _dstChid,
        address _nft,
        uint256 _id
    ) external view returns (uint256) {
        string memory _uri = INFT(_nft).tokenURI(_id);
        bytes memory message = abi.encode(NFTMsg(_nft, _nft, _id, _uri));
        return IMessageBus(messageBus).calcFee(message) + destTxFee[_dstChid];
    }

    // ===== called by user
    /**
     * @notice locks or burn user's NFT in this contract and send message to mint (or withdraw) on dest chain
     * @param _nft address of source NFT contract
     * @param _id nft token ID to bridge
     * @param _dstChid dest chain ID
     * @param _receiver receiver address on dest chain
     */
    function sendTo(
        address _nft,
        uint256 _id,
        uint64 _dstChid,
        address _receiver
    ) external payable whenNotPaused {
        require(msg.sender == INFT(_nft).ownerOf(_id), "not token owner");
        string memory _uri = INFT(_nft).tokenURI(_id);
        if (origNFT[_nft] == true) {
            // deposit
            INFT(_nft).transferFrom(msg.sender, address(this), _id);
            require(INFT(_nft).ownerOf(_id) == address(this), "transfer NFT failed");
        } else {
            // burn
            INFT(_nft).burn(_id);
        }
        (address _dstBridge, address _dstNft) = checkAddr(_nft, _dstChid);
        msgBus(_dstBridge, _dstChid, abi.encode(NFTMsg(_receiver, _dstNft, _id, _uri)));
        emit Sent(msg.sender, _nft, _id, _dstChid, _receiver, _dstNft);
    }

    // ===== called by MCN NFT after NFT is burnt
    function sendMsg(
        uint64 _dstChid,
        address _sender,
        address _receiver,
        uint256 _id,
        string calldata _uri
    ) external payable whenNotPaused {
        address _nft = msg.sender;
        (address _dstBridge, address _dstNft) = checkAddr(_nft, _dstChid);
        msgBus(_dstBridge, _dstChid, abi.encode(NFTMsg(_receiver, _dstNft, _id, _uri)));
        emit Sent(_sender, _nft, _id, _dstChid, _receiver, _dstNft);
    }

    // ===== called by msgbus
    function executeMessage(
        address sender,
        uint64 srcChid,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        // Must check sender to ensure msg is from another nft bridge
        // but we allow retry later in case it's a temporary config error
        // risk is invalid sender will be retried but this can be easily filtered
        // in executor or require manual trigger for retry
        if (paused() || sender != destBridge[srcChid]) {
            return ExecutionStatus.Retry;
        }
        // withdraw original locked nft back to user, or mint new nft depending on if this is the orig chain of nft
        NFTMsg memory nftMsg = abi.decode((_message), (NFTMsg));
        // if we are on nft orig chain, use transfer, otherwise, use mint
        if (origNFT[nftMsg.nft] == true) {
            try INFT(nftMsg.nft).transferFrom(address(this), nftMsg.user, nftMsg.id) {
                // do nothing here to move on to emit Received event and return success
            } catch (bytes memory returnData) {
                emit ExtCallErr(returnData);
                return ExecutionStatus.Retry;
            }
        } else {
            try INFT(nftMsg.nft).bridgeMint(nftMsg.user, nftMsg.id, nftMsg.uri) {
                // do nothing here to move on to emit Received event and return success
            } catch (bytes memory returnData) {
                emit ExtCallErr(returnData);
                return ExecutionStatus.Retry;
            }
        }
        emit Received(nftMsg.user, nftMsg.nft, nftMsg.id, srcChid);
        return ExecutionStatus.Success;
    }

    // ===== internal utils
    // check _nft and destChid are valid, return dstBridge and dstNft
    function checkAddr(address _nft, uint64 _dstChid) internal view returns (address dstBridge, address dstNft) {
        dstBridge = destBridge[_dstChid];
        require(dstBridge != address(0), "dest NFT Bridge not found");
        dstNft = destNFTAddr[_nft][_dstChid];
        require(dstNft != address(0), "dest NFT not found");
    }

    // check fee and call msgbus sendMessage
    function msgBus(
        address _dstBridge,
        uint64 _dstChid,
        bytes memory message
    ) internal {
        uint256 fee = IMessageBus(messageBus).calcFee(message);
        require(msg.value >= fee + destTxFee[_dstChid], "insufficient fee");
        IMessageBus(messageBus).sendMessage{value: fee}(_dstBridge, _dstChid, message);
    }

    // only owner
    // set per NFT, per chain id, address
    function setDestNFT(
        address srcNft,
        uint64 dstChid,
        address dstNft
    ) external onlyOwner {
        destNFTAddr[srcNft][dstChid] = dstNft;
        emit SetDestNFT(srcNft, dstChid, dstNft);
    }

    // set all dest chains
    function setDestNFTs(
        address srcNft,
        uint64[] calldata dstChid,
        address[] calldata dstNft
    ) external onlyOwner {
        require(dstChid.length == dstNft.length, "length mismatch");
        for (uint256 i = 0; i < dstChid.length; i++) {
            destNFTAddr[srcNft][dstChid[i]] = dstNft[i];
        }
    }

    // set destTxFee
    function setTxFee(uint64 chid, uint256 fee) external onlyOwner {
        destTxFee[chid] = fee;
        emit SetTxFee(chid, fee);
    }

    // set per chain id, nft bridge address
    function setDestBridge(uint64 dstChid, address dstNftBridge) external onlyOwner {
        destBridge[dstChid] = dstNftBridge;
        emit SetDestBridge(dstChid, dstNftBridge);
    }

    // batch set nft bridge addresses for multiple chainids
    function setDestBridges(uint64[] calldata dstChid, address[] calldata dstNftBridge) external onlyOwner {
        for (uint256 i = 0; i < dstChid.length; i++) {
            destBridge[dstChid[i]] = dstNftBridge[i];
        }
    }

    // only called on NFT's orig chain, not applicable for mcn nft
    function setOrigNFT(address _nft) external onlyOwner {
        origNFT[_nft] = true;
        emit SetOrigNFT(_nft, true);
    }

    // remove origNFT entry
    function delOrigNFT(address _nft) external onlyOwner {
        delete origNFT[_nft];
        emit SetOrigNFT(_nft, false);
    }

    // send all gas token this contract has to owner
    function claimFee() external onlyOwner {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
        emit FeeClaimed(amount);
    }
}


// : GPL-3.0-only

pragma solidity >=0.8.0;

//import"../../safeguard/Ownable.sol";

abstract contract MessageBusAddress is Ownable {
    event MessageBusUpdated(address messageBus);

    address public messageBus;

    function setMessageBus(address _messageBus) public onlyOwner {
        messageBus = _messageBus;
        emit MessageBusUpdated(messageBus);
    }
}


// : GPL-3.0-only

pragma solidity 0.8.9;

//import"../interfaces/IMessageReceiverApp.sol";
//import"./MessageBusAddress.sol";

abstract contract MessageReceiverApp is IMessageReceiverApp, MessageBusAddress {
    modifier onlyMessageBus() {
        require(msg.sender == messageBus, "caller is not message bus");
        _;
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}
}


// : GPL-3.0-only

pragma solidity >=0.8.0;

//import"../libraries/MsgDataTypes.sol";

interface IMessageBus {
    function liquidityBridge() external view returns (address);

    function pegBridge() external view returns (address);

    function pegBridgeV2() external view returns (address);

    function pegVault() external view returns (address);

    function pegVaultV2() external view returns (address);

    /**
     * @notice Calculates the required fee for the message.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     @ @return The required fee.
     */
    function calcFee(bytes calldata _message) external view returns (uint256);

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native gas token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * If messages with the same srcTransferId are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _srcBridge The bridge contract to send the transfer with.
     * @param _srcTransferId The transfer ID.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Withdraws message fee in the form of native gas token.
     * @param _account The address receiving the fee.
     * @param _cumulativeFee The cumulative fee credited to the account. Tracked by SGN.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A withdrawal must be
     * signed-off by +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdrawFee(
        address _account,
        uint256 _cumulativeFee,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Execute a message with a successful transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransfer(
        bytes calldata _message,
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message with a refunded transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransferRefund(
        bytes calldata _message, // the same message associated with the original transfer
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message not associated with a transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessage(
        bytes calldata _message,
        MsgDataTypes.RouteInfo calldata _route,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;
}


// : GPL-3.0-only

pragma solidity >=0.8.0;

interface IMessageReceiverApp {
    enum ExecutionStatus {
        Fail, // execution failed, finalized
        Success, // execution succeeded, finalized
        Retry // execution rejected, can retry later
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);
}


// : GPL-3.0-only

pragma solidity >=0.8.0;

library MsgDataTypes {
    // bridge operation type at the sender side (src chain)
    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    // bridge operation type at the receiver side (dst chain)
    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}


// : GPL-3.0-only

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
 *
 * This adds a normal func that setOwner if _owner is address(0). So we can't allow
 * renounceOwnership. So we can support Proxy based upgradable contract
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Only to be called by inherit contracts, in their init func called by Proxy
     * we require _owner == address(0), which is only possible when it's a delegateCall
     * because constructor sets _owner in contract state.
     */
    function initOwner() internal {
        require(_owner == address(0), "owner already set");
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
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


// : GPL-3.0-only

pragma solidity 0.8.9;

//import"@openzeppelin/contracts/security/Pausable.sol";
//import"./Ownable.sol";

abstract contract Pauser is Ownable, Pausable {
    mapping(address => bool) public pausers;

    event PauserAdded(address account);
    event PauserRemoved(address account);

    constructor() {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "Caller is not pauser");
        _;
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpause();
    }

    function isPauser(address account) public view returns (bool) {
        return pausers[account];
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function removePauser(address account) public onlyOwner {
        _removePauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) private {
        require(!isPauser(account), "Account is already pauser");
        pausers[account] = true;
        emit PauserAdded(account);
    }

    function _removePauser(address account) private {
        require(isPauser(account), "Account is not pauser");
        pausers[account] = false;
        emit PauserRemoved(account);
    }
}


// : MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

//import"../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


