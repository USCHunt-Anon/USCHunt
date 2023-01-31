/**
 *Submitted for verification at Etherscan.io on 2021-01-16
*/

// File: contracts/other/ProxyStorage.sol

// ////-License-Identifier: MIT
pragma solidity ^0.6.12;
contract ProxyStorage {

    function readBool(bytes32 _key) public view returns(bool) {
        return storageRead(_key) == bytes32(uint256(1));
    }

    function setBool(bytes32 _key, bool _value) internal {
        if(_value) {
            storageSet(_key, bytes32(uint256(1)));
        } else {
            storageSet(_key, bytes32(uint256(0)));
        }
    }

    function readAddress(bytes32 _key) public view returns(address) {
        return bytes32ToAddress(storageRead(_key));
    }

    function setAddress(bytes32 _key, address _value) internal {
        storageSet(_key, addressToBytes32(_value));
    }

    function storageRead(bytes32 _key) public view returns(bytes32) {
        bytes32 value;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            value := sload(_key)
        }
        return value;
    }

    function storageSet(bytes32 _key, bytes32 _value) internal {
        // targetAddress = _address;  // No!
        bytes32 implAddressStorageKey = _key;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(implAddressStorageKey, _value)
        }
    }

    function bytes32ToAddress(bytes32 _value) public pure returns(address) {
        return address(uint160(uint256(_value)));
    }

    function addressToBytes32(address _value) public pure returns(bytes32) {
        return bytes32(uint256(_value));
    }

}

// File: contracts/other/Proxy.sol

pragma solidity ^0.6.12;


contract Proxy is ProxyStorage {

    bytes32 constant IMPLEMENTATION_SLOT = keccak256(abi.encodePacked("IMPLEMENTATION_SLOT"));
    bytes32 constant OWNER_SLOT = keccak256(abi.encodePacked("OWNER_SLOT"));

    modifier onlyProxyOwner() {
        require(msg.sender == readAddress(OWNER_SLOT), "Proxy.onlyProxyOwner: msg sender not owner");
        _;
    }

    constructor () public {
        setAddress(OWNER_SLOT, msg.sender);
    }

    function getProxyOwner() public view returns (address) {
       return readAddress(OWNER_SLOT);
    }

    function setProxyOwner(address _newOwner) onlyProxyOwner public {
        setAddress(OWNER_SLOT, _newOwner);
    }

    function getImplementation() public view returns (address) {
        return readAddress(IMPLEMENTATION_SLOT);
    }

    function setImplementation(address _newImplementation) onlyProxyOwner public {
        setAddress(IMPLEMENTATION_SLOT, _newImplementation);
    }


    fallback () external payable {
       return internalFallback();
    }

    receive () payable external {
        return internalFallback();
    }
    function internalFallback() internal virtual {
        address contractAddr = readAddress(IMPLEMENTATION_SLOT);
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), contractAddr, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}

// File: contracts/other/ProxyPausable.sol

pragma solidity ^0.6.12;


contract ProxyPausable is Proxy {

    bytes32 constant PAUSED_SLOT = keccak256(abi.encodePacked("PAUSED_SLOT"));
    bytes32 constant PAUZER_SLOT = keccak256(abi.encodePacked("PAUZER_SLOT"));

    constructor() Proxy() public {
        setAddress(PAUZER_SLOT, msg.sender);
    }

    modifier onlyPauzer() {
        require(msg.sender == readAddress(PAUZER_SLOT), "ProxyPausable.onlyPauzer: msg sender not pauzer");
        _;
    }

    modifier notPaused() {
        require(!readBool(PAUSED_SLOT), "ProxyPausable.notPaused: contract is paused");
        _;
    }

    function getPauzer() public view returns (address) {
        return readAddress(PAUZER_SLOT);
    }

    function setPauzer(address _newPauzer) public onlyProxyOwner{
        setAddress(PAUZER_SLOT, _newPauzer);
    }

    function renouncePauzer() public onlyPauzer {
        setAddress(PAUZER_SLOT, address(0));
    }

    function getPaused() public view returns (bool) {
        return readBool(PAUSED_SLOT);
    }

    function setPaused(bool _value) public onlyPauzer {
        setBool(PAUSED_SLOT, _value);
    }

    function internalFallback() internal virtual override notPaused {
        super.internalFallback();
    }

}

// File: contracts/storage/InviteStorage.sol

// : MIT
pragma solidity ^0.6.12;

library InviteStorage {

    bytes32 public constant sSlot = keccak256("InviteStorage.storage.location");

    struct Storage{
        address owner;
        uint256 lastId;
        mapping(uint256 => address)  indexs;
        mapping(address => address)  inviter;
        mapping(address => address[])  inviterList;
        mapping(address => bool)  whiteListed;
        mapping(address => uint256)  userIndex;
    }

    function load() internal pure returns (Storage storage s) {
        bytes32 loc = sSlot;
        assembly {
        s_slot := loc
        }
    }

}

// File: contracts/market/Invite.sol


pragma solidity ^0.6.12;



contract Invite {


    constructor(uint256 index)public{
        init(index);
    }
    modifier onlyOwner() {
        require(InviteStorage.load().owner == msg.sender, "Invite.onlyOwner: caller is not the owner");
        _;
    }

    function init(uint256 index)public{
        require(InviteStorage.load().owner==address(0),'Invite.init: already initialised');
        InviteStorage.load().owner=msg.sender;
        InviteStorage.load().lastId = index;
    }

    function owner()public view returns(address){
        return InviteStorage.load().owner;
    }

    function setWhiteList(address[] memory users) public onlyOwner{
        InviteStorage.Storage storage inviteData=InviteStorage.load();
        for(uint256 i=0;i<users.length;i++){
            address user=users[i];
            inviteData.whiteListed[user] = true;
            if(inviteData.userIndex[user] == 0){
                inviteData.userIndex[user] = inviteData.lastId;
                inviteData.indexs[inviteData.lastId] = user;
                inviteData.lastId = inviteData.lastId + 1;
            }
        }

    }

    function setInviteUser(address inviteUser) public{
        InviteStorage.Storage storage inviteData=InviteStorage.load();
        require(!inviteData.whiteListed[msg.sender], 'whiteList user cannot be invited');
        if(inviteData.userIndex[msg.sender] == 0){
            inviteData.userIndex[msg.sender] = inviteData.lastId;
            inviteData.indexs[inviteData.lastId] = msg.sender;
            inviteData.lastId = inviteData.lastId + 1;
        }

        if(inviteData.whiteListed[inviteUser] || inviteData.inviter[inviteUser] != address(0)){
            inviteData.inviter[msg.sender] = inviteUser;
            inviteData.inviterList[inviteUser].push(msg.sender);
        }
    }

    function getInviteCount(address user) external view returns (uint256) {
        return InviteStorage.load().inviterList[user].length;
    }

    function lastId()public view returns(uint256){
        return InviteStorage.load().lastId;
    }

    function indexs(uint256 id)public view returns(address){
        return InviteStorage.load().indexs[id];
    }

    function inviter(address user)public view returns(address){
        return InviteStorage.load().inviter[user];
    }

    function inviterList(address user)public view returns(address[] memory){
        return InviteStorage.load().inviterList[user];
    }

    function whiteListed(address user)public view returns(bool){
        return InviteStorage.load().whiteListed[user];
    }

    function userIndex(address user)public view returns(uint256){
        return InviteStorage.load().userIndex[user];
    }
}