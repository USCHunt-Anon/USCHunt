/**
 *Submitted for verification at snowtrace.io on 2022-01-07
*/

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
	bytes32 internal constant TRUST_MINIMIZED_SLOT = 0xa0ea182b754772c4f5848349cff27d3431643ba25790e0c61a8e4bdf4cec9201;

	constructor() payable {
		require(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1) && LOGIC_SLOT==bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) // this require is simply against human error, can be removed if you know what you are doing
		&& NEXT_LOGIC_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogic')) - 1) && NEXT_LOGIC_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogicBlock')) - 1)
		&& PROPOSE_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.proposeBlock')) - 1)/* && DEADLINE_SLOT == bytes32(uint256(keccak256('eip1984.proxy.deadline')) - 1)*/
		&& TRUST_MINIMIZED_SLOT == bytes32(uint256(keccak256('eip1984.proxy.trustMinimized')) - 1));
		_setAdmin(msg.sender);
	}

	modifier ifAdmin() {if (msg.sender == _admin()) {_;} else {_fallback();}}
	function _logic() internal view returns (address logic) {assembly { logic := sload(LOGIC_SLOT) }}
	function _nextLogic() internal view returns (address nextLogic) {assembly { nextLogic := sload(NEXT_LOGIC_SLOT) }}
	function _proposeBlock() internal view returns (uint bl) {assembly { bl := sload(PROPOSE_BLOCK_SLOT) }}
	function _nextLogicBlock() internal view returns (uint bl) {assembly { bl := sload(NEXT_LOGIC_BLOCK_SLOT) }}
	function _trustMinimized() internal view returns (uint tm) {assembly { tm := sload(TRUST_MINIMIZED_SLOT) }}
	function _admin() internal view returns (address adm) {assembly { adm := sload(ADMIN_SLOT) }}
	function _setAdmin(address newAdm) internal {assembly {sstore(ADMIN_SLOT, newAdm)}}
	function changeAdmin(address newAdm) external ifAdmin {emit AdminChanged(_admin(), newAdm);_setAdmin(newAdm);}
	function upgrade() external ifAdmin {require(block.number>=_nextLogicBlock(),"too soon");address logic;assembly {logic := sload(NEXT_LOGIC_SLOT) sstore(LOGIC_SLOT,logic)}emit Upgraded(logic);}
	fallback () external payable {_fallback();}
	receive () external payable {_fallback();}
	function _fallback() internal {require(msg.sender != _admin());_delegate(_logic());}
	function cancelUpgrade() external ifAdmin {address logic; assembly {logic := sload(LOGIC_SLOT)sstore(NEXT_LOGIC_SLOT, logic)}emit NextLogicCanceled();}
	function prolongLock(uint b) external ifAdmin {require(b > _proposeBlock(),"get maxxed"); assembly {sstore(PROPOSE_BLOCK_SLOT,b)} emit ProposingUpgradesRestrictedUntil(b,b+1296000);}
	function removeTrust() external ifAdmin {assembly{ sstore(TRUST_MINIMIZED_SLOT, 1) }emit TrustRemoved();} // before this called acts like a normal eip 1967 transparent proxy. after the deployer confirms everything is deployed correctly must be called
	function _updateBlockSlot() internal {uint nlb = block.number + 1296000; assembly {sstore(NEXT_LOGIC_BLOCK_SLOT,nlb)}}
	function _setNextLogic(address nl) internal {require(block.number >= _proposeBlock(),"too soon");_updateBlockSlot();assembly { sstore(NEXT_LOGIC_SLOT, nl)}emit NextLogicDefined(nl,block.number + 1296000);}

	function proposeToAndCall(address newLogic, bytes calldata data) payable external ifAdmin {
		if (_trustMinimized() == 0) {_updateBlockSlot();assembly {sstore(LOGIC_SLOT,newLogic)}emit Upgraded(newLogic);}	else{ _setNextLogic(newLogic);}
		(bool success,) = newLogic.delegatecall(data);require(success,"failed to call");
	}

    function viewSlots() external ifAdmin returns(address logic, address nextLogic, uint proposeBlock, uint nextLogicBlock, uint trustMinimized, address admin) {
        return (_logic(),_nextLogic(),_proposeBlock(),_nextLogicBlock(),_trustMinimized(),_admin());
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

pragma solidity ^0.8.6;

// A modification of OpenZeppelin ERC20
// Original can be found here: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol

contract eERC {
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);

	mapping (address => mapping (address => bool)) private _allowances;
	mapping (address => uint) private _balances;

	string private _name;
	string private _symbol;
    bool public ini;
    uint public exchangeRate;
    address public liquidityManager;
    address public governance;
    address public _treasury;
    address public _staking;
	mapping (address => bool) public pools; // a couple of addresses which are not pools might be recorded as such, array was here, but there is nothing to gain from it for hacka
 	uint public sellTax;

	function init() public {
		require(msg.sender == 0xc22eFB5258648D016EC7Db1cF75411f6B3421AEc);
		//require(ini==false);ini=true; // THIS
		//ini = false;
		//address p1 = 0xCE094041255945cB67Ba2EE8e86759b3BfAFf85A;
		//address p2 = 0x7dbf3317615Ab1183f8232d7AbdFD3912c906BC9;
		//address p3 = 0x0BCcDA9f5f4b00e22E5382d7d492a36f6747ceD5;
		//pools[p1]=true;	pools[p2]=true; pools[p3]=true;
		//uint leftover = _balances[liquidityManager]-40000e18;
		//_balances[liquidityManager]-=leftover;
		//emit Transfer(liquidityManager,_treasury,leftover);
		//exchangeRate = 40;
		//uint leftover1 = _balances[p1]-3000e18;
		//_balances[p1]=3000e18;
		//emit Transfer(p1,_treasury,leftover1);
		//uint leftover2 = _balances[p2]-190e18;
		//_balances[p2]=190e18;
		//emit Transfer(p2,_treasury,leftover2);
		//_balances[p3]=_balances[p3]/2;
		//uint leftover3 = _balances[p3]-1e18;
		//_balances[p3]=1e18;
		//emit Transfer(p3,_treasury,leftover3);
		//I(p1).sync();I(p2).sync();I(p3).sync();
		//sellTax = 10;
		_balances[_treasury]+=93000e18;
		emit Transfer(address(0),_treasury,93000e18);
	}
	
	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function totalSupply() public view returns (uint) {//subtract balance of treasury
		return 1e24-_balances[0x000000000000000000000000000000000000dEaD]-_balances[_treasury];
	}

	function decimals() public pure returns (uint) {
		return 18;
	}

	function balanceOf(address a) public view returns (uint) {
		return _balances[a];
	}

	function transfer(address recipient, uint amount) public returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function disallow(address spender) public returns (bool) {
		delete _allowances[msg.sender][spender];
		emit Approval(msg.sender, spender, 0);
		return true;
	}

	function approve(address spender, uint amount) public returns (bool) { // hardcoded trader joe router
		if (spender == 0x60aE616a2155Ee3d9A68541Ba4544862310933d4) {
			emit Approval(msg.sender, spender, 2**256 - 1);
			return true;
		}
		else {
			_allowances[msg.sender][spender] = true; //boolean is cheaper for trading
			emit Approval(msg.sender, spender, 2**256 - 1);
			return true;
		}
	}

	function allowance(address owner, address spender) public view returns (uint) { // hardcoded trader joe router
		if (spender == 0x60aE616a2155Ee3d9A68541Ba4544862310933d4||_allowances[owner][spender] == true) {
			return 2**256 - 1;
		} else {
			return 0;
		}
	}

	function transferFrom(address sender, address recipient, uint amount) public returns (bool) { // hardcoded trader joe router
		require(msg.sender == 0x60aE616a2155Ee3d9A68541Ba4544862310933d4||_allowances[sender][msg.sender] == true);
		_transfer(sender, recipient, amount);
		return true;
	}

	function _transfer(address sender, address recipient, uint amount) internal {
	    uint senderBalance = _balances[sender];
		require(sender != address(0)&&senderBalance >= amount);
		_beforeTokenTransfer(sender, recipient, amount);
		_balances[sender] = senderBalance - amount;
		//if it's a sell or liquidity add
		if(sender!=liquidityManager&&sellTax>0&&pools[recipient]==true){
			uint treasuryShare = amount/sellTax;
  			amount -= treasuryShare;
			_balances[_treasury] += treasuryShare;//treasury
		}
		_balances[recipient] += amount;
		emit Transfer(sender, recipient, amount);
	}

	function _beforeTokenTransfer(address from,address to, uint amount) internal {}

	function setLiquidityManager(address a) external {
		require(msg.sender == governance); liquidityManager = a;
	}
	
	function addPool(address a) external {
		require(msg.sender == liquidityManager);
		if(pools[a]==false){
			pools[a]=true;
		}
	}

	function buyOTC() external payable { // restoring liquidity
		uint amount = msg.value*exchangeRate/1000; _balances[msg.sender]+=amount; _balances[_treasury]-=amount;
		emit Transfer(_treasury, msg.sender, amount);
		uint deployerShare = msg.value/20;
		payable(governance).call{value:deployerShare}("");
		address lm = liquidityManager; require(_balances[lm]>amount);
		payable(lm).call{value:address(this).balance}("");
		I(lm).addLiquidity();
	}

	function changeExchangeRate(uint er) public { require(msg.sender==governance); exchangeRate = er; }

	function setSellTaxModifier(uint m) public {
		require(msg.sender == governance&&(m>=10||m==0));sellTax = m;
	}
}

interface I{
	function sync() external; function totalSupply() external view returns(uint);
	function balanceOf(address a) external view returns (uint);
	function addLiquidity() external;
}