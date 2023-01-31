/**
 *Submitted for verification at Etherscan.io on 2022-02-14
*/

// ////-License-Identifier: GPL-3.0

pragma solidity >=0.7.0;

library GoEHelper {
    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function toString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}


contract ProxyData {
    address internal proxied;
}

contract Proxy is ProxyData {
    constructor(address _proxied) {
        proxied = _proxied;
    }

    function implementation() public view returns (address) {
        return proxied;
    }    
    function proxyType() public pure returns (uint256) {
        return 1; // for "forwarding proxy"
                  // see EIP 897 for more details
    }

    receive() external payable {

    }
   
    fallback () external payable {
        address addr = proxied;
        assembly {
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 0)
            returndatacopy(freememstart, 0, returndatasize())
            switch success
            case 0 { revert(freememstart, returndatasize()) }
            default { return(freememstart, returndatasize()) }
        }
    }
}

contract GoE721Data is ProxyData {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    string  _name;
    string  _symbol;
    string  _baseUrl;
    string  _baseExtention;
    uint256  _mintIdx;
    uint256 _maxSupply;
    uint256 _mintCost;

    mapping(uint256 => address)  _owners;
    mapping(address => uint256)  _balances;
    mapping(uint256 => address)  _tokenApprovals;
    mapping(address => mapping(address => bool))  _operatorApprovals;

}
contract GoE721Basic is GoE721Data {
    function changeURLParams(string memory _nURL, string memory _nBaseExt) external {
        _baseUrl = _nURL;
        _baseExtention = _nBaseExt;
    }

    function totalSupply() public view returns(uint256){

        return _mintIdx-1;
    }

    function maxSupply() public view returns(uint256) {
        
        return _maxSupply;
    }

    function mintCost() public view returns(uint256) {
        return _mintCost;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function walletOfOwner(address wallet) public view returns(uint256[] memory walletNFTs){
        uint256 amnt = 0;
        for(uint256 i=0; i<_mintIdx; i++){
            if(ownerOf(i) == wallet){
                amnt += 1;
            }
        }
        walletNFTs = new uint256[](amnt);
        uint256 _idx = 0;
        for(uint256 i=0; i<_mintIdx; i++){
            if(ownerOf(i) == wallet){
                walletNFTs[_idx] = i;
                _idx += 1;
            }
        }
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "GoE: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, GoEHelper.toString(tokenId), _baseExtention)) : "";
    }

    function mint(address to, address token) public payable  {
        require(_mintIdx <= _maxSupply, "GoE: no more mints");
        require(token == address(0), "GoE: This token is not supported");
        require(msg.value >= _mintCost, "GoE: Min payment of 1 ether is required");
        _mint(to, _mintIdx);
        _mintIdx += 1;
    }

    function supportsInterface(bytes4) public pure returns (bool) {
        // need to check interfaces
        return true;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "GoE: balance query for the zero address");
        return _balances[owner];
    }
 
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "GoE: owner query for nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) public{
        address owner = ownerOf(tokenId);
        require(to != owner, "GoE: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "GoE: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "GoE: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "GoE: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from,address to,uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "GoE: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from,address to,uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "GoE: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _baseURI() internal view returns (string memory) {

        return _baseUrl;
    }

    function _safeTransfer(address from,address to,uint256 tokenId,bytes memory) internal  {

        _transfer(from, to, tokenId);
    }

    function _exists(uint256 tokenId) internal view  returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view  returns (bool) {
        require(_exists(tokenId), "GoE: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "GoE: mint to the zero address");
        require(!_exists(tokenId), "GoE: token already minted");
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from,address to,uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "GoE: transfer of token that is not own");
        require(to != address(0), "GoE: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}