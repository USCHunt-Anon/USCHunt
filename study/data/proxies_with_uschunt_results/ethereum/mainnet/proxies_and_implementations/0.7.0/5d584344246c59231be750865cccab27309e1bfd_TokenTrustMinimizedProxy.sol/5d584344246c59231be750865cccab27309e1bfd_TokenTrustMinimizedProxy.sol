/**
 *Submitted for verification at Etherscan.io on 2021-04-15
*/

pragma solidity >=0.7.0 <0.8.0;

// OpenZeppelin Upgradeability contracts modified by Sam Porter. Proxy for Nameless Protocol contracts
// You can find original set of contracts here: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/proxy

// Had to pack OpenZeppelin upgradeability contracts in one single contract for readability. It's basically the same OpenZeppelin functions 
// but in one contract with some differences:
// 1. DEADLINE is a block after which it becomes impossible to upgrade the contract. Defined in constructor and here it's ~2 years.
// Maybe not even required for most contracts, but I kept it in case if something happens to developers.
// 2. PROPOSE_BLOCK defines how often the contract can be upgraded. Defined in _setNextLogic() function and the interval here is set
// to 172800 blocks ~1 month.
// 3. Admin rights are burnable. Rather not do that without deadline
// 4. prolongLock() allows to add to PROPOSE_BLOCK. Basically allows to prolong lock. For example if there no upgrades planned soon,
// then this function could be called to set next upgrade being possible only in a year, so investors won't need to monitor the code too closely
// all the time. Could prolong to maximum solidity number so the deadline might not be needed 
// 5. logic contract is not being set suddenly. it's being stored in NEXT_LOGIC_SLOT for a month and only after that it can be set as LOGIC_SLOT.
// Users have time to decide on if the deployer or the governance is malicious and exit safely.
// 6. constructor does not require arguments

// It fixes "upgradeability bug" I believe. Also I sincerely believe that upgradeability is not about fixing bugs, but about upgradeability,
// so yeah, proposed logic has to be clean.
// In my heart it exists as eip-1984 but it's too late for that number. https://ethereum-magicians.org/t/trust-minimized-proxy/5742/2

contract TokenTrustMinimizedProxy{
	event Upgraded(address indexed toLogic);
	event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
	event NextLogicDefined(address indexed nextLogic, uint timeOfArrivalBlock);
	event UpgradesRestrictedUntil(uint block);
	event NextLogicCanceled(address indexed toLogic);
	
	bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
	bytes32 internal constant LOGIC_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
	bytes32 internal constant NEXT_LOGIC_SLOT = 0xb182d207b11df9fb38eec1e3fe4966cf344774ba58fb0e9d88ea35ad46f3601e;
	bytes32 internal constant NEXT_LOGIC_BLOCK_SLOT = 0x96de003e85302815fe026bddb9630a50a1d4dc51c5c355def172204c3fd1c733;
	bytes32 internal constant PROPOSE_BLOCK_SLOT = 0xbc9d35b69e82e85049be70f91154051f5e20e574471195334bde02d1a9974c90;
//	bytes32 internal constant DEADLINE_SLOT = 0xb124b82d2ac46ebdb08de751ebc55102cc7325d133e09c1f1c25014e20b979ad;

	constructor() payable {
	//	require(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1) && LOGIC_SLOT==bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) // this require is simply against human error, can be removed if you know what you are doing
	//	&& NEXT_LOGIC_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogic')) - 1) && NEXT_LOGIC_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogicBlock')) - 1)
	//	&& PROPOSE_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.proposeBlock')) - 1)/* && DEADLINE_SLOT == bytes32(uint256(keccak256('eip1984.proxy.deadline')) - 1)*/);
		_setAdmin(msg.sender);
//		uint deadline = block.number + 4204800; // ~2 years as default
//		assembly {sstore(DEADLINE_SLOT,deadline)}
	}

	modifier ifAdmin() {if (msg.sender == _admin()) {_;} else {_fallback();}}
	function _logic() internal view returns (address logic) {assembly { logic := sload(LOGIC_SLOT) }}
	function _proposeBlock() internal view returns (uint bl) {assembly { bl := sload(PROPOSE_BLOCK_SLOT) }}
	function _nextLogicBlock() internal view returns (uint bl) {assembly { bl := sload(NEXT_LOGIC_BLOCK_SLOT) }}
//	function _deadline() internal view returns (uint bl) {assembly { bl := sload(DEADLINE_SLOT) }}
	function _admin() internal view returns (address adm) {assembly { adm := sload(ADMIN_SLOT) }}
	function _isContract(address account) internal view returns (bool b) {uint256 size;assembly {size := extcodesize(account)}return size > 0;}
	function _setAdmin(address newAdm) internal {assembly {sstore(ADMIN_SLOT, newAdm)}}
	function changeAdmin(address newAdm) external ifAdmin {emit AdminChanged(_admin(), newAdm);_setAdmin(newAdm);}
	function upgrade() external ifAdmin {require(block.number>=_nextLogicBlock());address logic;assembly {logic := sload(NEXT_LOGIC_SLOT) sstore(LOGIC_SLOT,logic)}emit Upgraded(logic);}
	fallback () external payable {_fallback();}
	receive () external payable {_fallback();}
	function _fallback() internal {require(msg.sender != _admin());_delegate(_logic());}
	function cancelUpgrade() external ifAdmin {address logic; assembly {logic := sload(LOGIC_SLOT)sstore(NEXT_LOGIC_SLOT, logic)}emit NextLogicCanceled(logic);}

	function proposeTo(address newLogic) external ifAdmin {
		if (_logic() == address(0)) {_updateBlockSlots();assembly {sstore(LOGIC_SLOT,newLogic)}emit Upgraded(newLogic);} else{_setNextLogic(newLogic);}
	}
	
	function prolongLock(uint block_) external ifAdmin {
		uint pb; assembly {pb := sload(PROPOSE_BLOCK_SLOT) pb := add(pb,block_) sstore(PROPOSE_BLOCK_SLOT,pb)}emit UpgradesRestrictedUntil(pb);
	}
	
	function proposeToAndCall(address newLogic, bytes calldata data) payable external ifAdmin {
		if (_logic() == address(0)) {_updateBlockSlots();assembly {sstore(LOGIC_SLOT,newLogic)}}else{_setNextLogic(newLogic);}
		(bool success,) = newLogic.delegatecall(data);require(success);
	}

	function _setNextLogic(address nextLogic) internal {
		require(block.number >= _proposeBlock() && _isContract(nextLogic));
		_updateBlockSlots();
		assembly { sstore(NEXT_LOGIC_SLOT, nextLogic)}
		emit NextLogicDefined(nextLogic,block.number + 172800);
	}

	function _updateBlockSlots() internal {
	    uint proposeBlock = block.number + 172800;uint nextLogicBlock = block.number + 172800; assembly {sstore(NEXT_LOGIC_BLOCK_SLOT,nextLogicBlock) sstore(PROPOSE_BLOCK_SLOT,proposeBlock)}
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
pragma solidity >=0.7.0 <0.8.0;

// A modification of OpenZeppelin ERC20
// Original can be found here: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol

// Very slow erc20 implementation. Limits release of the funds with emission rate in _beforeTokenTransfer().
// Even if there will be a vulnerability in upgradeable contracts defined in _beforeTokenTransfer(), it won't be devastating.
// Developers can't simply rug.
// Allowances are booleans now instead of uints and uni v2 router is hardcoded, so it achieves -7100 gas per trade on uni v2 post-Berlin
// _mint() and _burn() functions are removed.
// Token name and symbol can be changed.
// Bulk transfer allows to transact in bulk cheaper by making up to three times less store writes in comparison to regular erc-20 transfers

contract VSRERC20 {
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	event BulkTransfer(address indexed from, address[] indexed recipients, uint[] amounts);
	event BulkTransferFrom(address[] indexed senders, uint[] amounts, address indexed recipient);
	event NameSymbolChangedTo(string name, string symbol);

	mapping (address => mapping (address => bool)) private _allowances;
	mapping (address => uint) private _balances;

	string private _name;
	string private _symbol;
	address private _governance;
	uint8 private _governanceSet;
	bool private _init;

	function init() public {
		require(_init == false);
		_init = true;
		_name = "Aletheo";
		_symbol = "LET";
		_governance = 0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2;
		_balances[0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2] = 1e27;
		emit NameSymbolChangedTo("Aletheo","LET");
	}

	modifier onlyGovernance() {require(msg.sender == _governance);_;}
	function name() public view returns (string memory) {return _name;}
	function symbol() public view returns (string memory) {return _symbol;}
	function totalSupply() public view returns (uint) {uint supply = (block.number - 12640000)*42e16+1e24;if (supply > 1e27) {supply = 1e27;}return supply;}
	function decimals() public pure returns (uint) {return 18;}
	function balanceOf(address a) public view returns (uint) {return _balances[a];}
	function transfer(address recipient, uint amount) public returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
	function disallow(address spender) public returns (bool) {delete _allowances[msg.sender][spender];emit Approval(msg.sender, spender, 0);return true;}
	function setNameSymbol(string memory n_, string memory s_) public onlyGovernance {_name = n_;_symbol = s_;emit NameSymbolChangedTo(n_,s_);}
	function setGovernance(address a) public onlyGovernance {require(_governanceSet < 3);_governanceSet += 1;_governance = a;}
	function _isContract(address a) internal view returns(bool) {uint s_;assembly {s_ := extcodesize(a)}return s_ > 0;}

	function approve(address spender, uint amount) public returns (bool) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) {emit Approval(msg.sender, spender, 2**256 - 1);return true;}
		else {_allowances[msg.sender][spender] = true;emit Approval(msg.sender, spender, 2**256 - 1);return true;}
	}

	function allowance(address owner, address spender) public view returns (uint) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D||_allowances[owner][spender] == true) {return 2**256 - 1;} else {return 0;}
	}

	function transferFrom(address sender, address recipient, uint amount) public returns (bool) { // hardcoded mainnet uniswapv2 router 02, transfer helper library
		require(msg.sender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D||_allowances[sender][msg.sender] == true);_transfer(sender, recipient, amount);return true;
	}

	function _transfer(address sender, address recipient, uint amount) internal {
		require(sender != address(0) && recipient != address(0));
		_beforeTokenTransfer(sender, amount);
		uint senderBalance = _balances[sender];
		require(senderBalance >= amount);
		_balances[sender] = senderBalance - amount;
		_balances[recipient] += amount;
		emit Transfer(sender, recipient, amount);
	}

	function bulkTransfer(address[] memory recipients, uint[] memory amounts) public returns (bool) { // will be used by the contract, or anybody who wants to use it
		require(recipients.length == amounts.length && amounts.length < 100,"human error");
		uint senderBalance = _balances[msg.sender];
		uint total;
		for(uint i = 0;i<amounts.length;i++) {total += amounts[i];_balances[recipients[i]] += amounts[i];}
		require(senderBalance >= total);
		if (msg.sender == 0xFBcEd1B6BaF244c20Ae896BAAc1d74d88c6E0CD5) {_beforeTokenTransfer(msg.sender, total);}
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
	}

	function _beforeTokenTransfer(address from, uint amount) internal view {
		if(block.number < 12640000) {require(from == 0xd431C747a1211E80acD8678860703156bDb5602c || from == _governance);}
		else {
			if (from == 0xFBcEd1B6BaF244c20Ae896BAAc1d74d88c6E0CD5) {// hardcoded treasury proxy address
				require(block.number > 12640000);
				uint treasury = _balances[0xFBcEd1B6BaF244c20Ae896BAAc1d74d88c6E0CD5];
				uint withd =  999e24 - treasury;
				uint allowed = (block.number - 12640000)*42e16 - withd;
				require(amount <= allowed && amount <= treasury);
			}
		}
	}
}