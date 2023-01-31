/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

// ////-License-Identifier: MIT
pragma solidity >=0.7.6 <0.8.0;

// EIP-3561 trust minimized proxy implementation https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3561.md

contract AletheoTrustMinimizedProxy{ // THE CODE FITS ON THE SCREEN UNBELIAVABLE LETS STOP ENDLESS SCROLLING UP AND DOWN
	event Upgraded(address indexed toLogic);
	event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
	event NextLogicDefined(address indexed nextLogic, uint earliestArrivalBlock);
	event ProposingUpgradesRestrictedUntil(uint block, uint nextProposedLogicEarliestArrival);
	event NextLogicCanceled();
	event TrustRemoved();

	bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
	bytes32 internal constant LOGIC_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
	bytes32 internal constant NEXT_LOGIC_SLOT = 0xb182d207b11df9fb38eec1e3fe4966cf344774ba58fb0e9d88ea35ad46f3601e;
	bytes32 internal constant NEXT_LOGIC_BLOCK_SLOT = 0x96de003e85302815fe026bddb9630a50a1d4dc51c5c355def172204c3fd1c733;
	bytes32 internal constant PROPOSE_BLOCK_SLOT = 0xbc9d35b69e82e85049be70f91154051f5e20e574471195334bde02d1a9974c90;
//	bytes32 internal constant DEADLINE_SLOT = 0xb124b82d2ac46ebdb08de751ebc55102cc7325d133e09c1f1c25014e20b979ad;
	bytes32 internal constant TRUST_MINIMIZED_SLOT = 0xa0ea182b754772c4f5848349cff27d3431643ba25790e0c61a8e4bdf4cec9201;

	constructor() payable {
//		require(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1) && LOGIC_SLOT==bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) // this require is simply against human error, can be removed if you know what you are doing
//		&& NEXT_LOGIC_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogic')) - 1) && NEXT_LOGIC_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogicBlock')) - 1)
//		&& PROPOSE_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.proposeBlock')) - 1)/* && DEADLINE_SLOT == bytes32(uint256(keccak256('eip1984.proxy.deadline')) - 1)*/
//		&& TRUST_MINIMIZED_SLOT == bytes32(uint256(keccak256('eip1984.proxy.trustMinimized')) - 1));
		_setAdmin(msg.sender);
//		uint deadline = block.number + 4204800; // ~2 years as default
//		assembly {sstore(DEADLINE_SLOT,deadline)}
	}

	modifier ifAdmin() {if (msg.sender == _admin()) {_;} else {_fallback();}}
	function _logic() internal view returns (address logic) {assembly { logic := sload(LOGIC_SLOT) }}
	function _proposeBlock() internal view returns (uint bl) {assembly { bl := sload(PROPOSE_BLOCK_SLOT) }}
	function _nextLogicBlock() internal view returns (uint bl) {assembly { bl := sload(NEXT_LOGIC_BLOCK_SLOT) }}
//	function _deadline() internal view returns (uint bl) {assembly { bl := sload(DEADLINE_SLOT) }}
	function _trustMinimized() internal view returns (bool tm) {assembly { tm := sload(TRUST_MINIMIZED_SLOT) }}
	function _admin() internal view returns (address adm) {assembly { adm := sload(ADMIN_SLOT) }}
	function _setAdmin(address newAdm) internal {assembly {sstore(ADMIN_SLOT, newAdm)}}
	function changeAdmin(address newAdm) external ifAdmin {emit AdminChanged(_admin(), newAdm);_setAdmin(newAdm);}
	function upgrade() external ifAdmin {require(block.number>=_nextLogicBlock());address logic;assembly {logic := sload(NEXT_LOGIC_SLOT) sstore(LOGIC_SLOT,logic)}emit Upgraded(logic);}
	fallback () external payable {_fallback();}
	receive () external payable {_fallback();}
	function _fallback() internal {require(msg.sender != _admin());_delegate(_logic());}
	function cancelUpgrade() external ifAdmin {address logic; assembly {logic := sload(LOGIC_SLOT)sstore(NEXT_LOGIC_SLOT, logic)}emit NextLogicCanceled();}
	function prolongLock(uint b) external ifAdmin {require(b > _proposeBlock()); assembly {sstore(PROPOSE_BLOCK_SLOT,b)} emit ProposingUpgradesRestrictedUntil(b,b+172800);}
	function removeTrust() external ifAdmin {assembly{ sstore(TRUST_MINIMIZED_SLOT, true) }emit TrustRemoved();} // before this called acts like a normal eip 1967 transparent proxy. after the deployer confirms everything is deployed correctly must be called
	function _updateBlockSlot() internal {uint nlb = block.number + 172800; assembly {sstore(NEXT_LOGIC_BLOCK_SLOT,nlb)}}
	function _setNextLogic(address nl) internal {require(block.number >= _proposeBlock());_updateBlockSlot();assembly { sstore(NEXT_LOGIC_SLOT, nl)}emit NextLogicDefined(nl,block.number + 172800);}

	function proposeToAndCall(address newLogic, bytes calldata data) payable external ifAdmin {
		if (_logic() == address(0) || _trustMinimized() == false) {assembly {sstore(LOGIC_SLOT,newLogic)}emit Upgraded(newLogic);}else{_setNextLogic(newLogic);}
		(bool success,) = newLogic.delegatecall(data);require(success);
	}

	function _delegate(address logic_) internal {
		assembly {
			calldatacopy(0, 0, calldatasize())
			let result := delegatecall(gas(), logic_, 0, calldatasize(), 0, 0)
			returndatacopy(0, 0, returndatasize())
			switch result
			case 0 { revert(0, returndatasize()) }
			default { return(0, returndatasize()) }
		}
	}
}

// : MIT
pragma solidity ^0.7.6;

// A modification of OpenZeppelin ERC20
// Original can be found here: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol

// Very slow erc20 implementation. Limits release of the funds with emission rate in _beforeTokenTransfer().
// Even if there will be a vulnerability in upgradeable contracts defined in _beforeTokenTransfer(), it won't be devastating.
// Developers can't simply rug.

interface I{function genesisBlock() external view returns(uint);}

contract VSRERC {
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
//	event BulkTransfer(address indexed from, address[] indexed recipients, uint[] amounts);
//	event BulkTransferFrom(address[] indexed senders, uint[] amounts, address indexed recipient);

	mapping (address => mapping (address => bool)) private _allowances;
	mapping (address => uint) private _balances;

	string private _name;
	string private _symbol;
//	address private _bridge;
	bool private _init;
//	bool private _bridgeDefined;

	function init() public {
		require(_init == false);
		_init = true;
		_name = "Aletheo";
		_symbol = "LET";
		_balances[0x31A188024FcD6E462aBF157F879Fb7da37D6AB2f] = 1e24;//founding event
		_balances[0x05658a207a56AA2d6b2821883D373f59Ac6A2fC3] = 896e22;//treasury
		_balances[0x5C8403A2617aca5C86946E32E14148776E37f72A] = 4e22;//reserved for airdrop
	}
//	function defineBridge(address b) public {require(msg.sender == 0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2 && _bridgeDefined == false);_bridgeDefined == true; _bridge = b;_balances[b] = 10e24;}
	function name() public view returns (string memory) {return _name;}
	function symbol() public view returns (string memory) {return _symbol;}
	function totalSupply() public view returns (uint) {return 10e24;}
	function decimals() public pure returns (uint) {return 18;}
	function balanceOf(address a) public view returns (uint) {return _balances[a];}
	function transfer(address recipient, uint amount) public returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
	function disallow(address spender) public returns (bool) {delete _allowances[msg.sender][spender];emit Approval(msg.sender, spender, 0);return true;}

	function approve(address spender, uint amount) public returns (bool) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) {emit Approval(msg.sender, spender, 2**256 - 1);return true;}
		else {_allowances[msg.sender][spender] = true;emit Approval(msg.sender, spender, 2**256 - 1);return true;}
	}

	function allowance(address owner, address spender) public view returns (uint) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D||_allowances[owner][spender] == true) {return 2**256 - 1;} else {return 0;}
	}

	function transferFrom(address sender, address recipient, uint amount) public returns (bool) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		require(msg.sender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D || _allowances[sender][msg.sender] == true);_transfer(sender, recipient, amount);return true;
	}

	function _transfer(address sender, address recipient, uint amount) internal {
		require(sender != address(0));
		_beforeTokenTransfer(sender, amount);
		uint senderBalance = _balances[sender];
		require(senderBalance >= amount);
		_balances[sender] = senderBalance - amount;
		_balances[recipient] += amount;
		emit Transfer(sender, recipient, amount);
	}

	/*function bulkTransfer(address[] memory recipients, uint[] memory amounts) public returns (bool) { // will be used by the contract, or anybody who wants to use it
		require(recipients.length == amounts.length && amounts.length < 100,"human error");
		uint senderBalance = _balances[msg.sender];
		uint total;
		for(uint i = 0;i<amounts.length;i++) {total += amounts[i];_balances[recipients[i]] += amounts[i];}
		require(senderBalance >= total);
		if (msg.sender == 0x05658a207a56AA2d6b2821883D373f59Ac6A2fC3) {_beforeTokenTransfer(msg.sender, total);}
		_balances[msg.sender] = senderBalance - total;
		emit BulkTransfer(msg.sender, recipients, amounts);
		return true;
	}

	function bulkTransferFrom(address[] memory senders, address recipient, uint[] memory amounts) public returns (bool) {
		require(senders.length == amounts.length && amounts.length < 100,"human error");
		uint total;
		uint senderBalance;
		for (uint i = 0;i<amounts.length;i++) {
			senderBalance = _balances[senders[i]];
			if (senderBalance >= amounts[i] && _allowances[senders[i]][msg.sender]== true){total+= amounts[i];_balances[senders[i]] = senderBalance - amounts[i];}
			else {delete senders[i];delete amounts[i];}
		}
		_balances[msg.sender] += total;
		emit BulkTransferFrom(senders, amounts, recipient);
		return true;
	}*/

	function _beforeTokenTransfer(address from, uint amount) internal view {
		if(from == 0x05658a207a56AA2d6b2821883D373f59Ac6A2fC3) {
			uint genesisBlock = I(0x31A188024FcD6E462aBF157F879Fb7da37D6AB2f).genesisBlock();
			require(genesisBlock != 0);
			uint treasury = _balances[0x05658a207a56AA2d6b2821883D373f59Ac6A2fC3]; 
			uint withd =  9e24 - treasury; 
			uint allowed = (block.number - genesisBlock)*42e16 - withd;
			require(amount <= allowed && amount <= treasury);
		}
	}
}