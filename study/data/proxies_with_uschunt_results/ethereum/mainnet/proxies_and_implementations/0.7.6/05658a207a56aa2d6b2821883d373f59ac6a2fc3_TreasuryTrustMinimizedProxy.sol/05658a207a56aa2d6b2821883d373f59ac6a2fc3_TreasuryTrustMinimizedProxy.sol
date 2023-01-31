/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

// ////-License-Identifier: MIT
pragma solidity >=0.7.6 <0.8.0;

// EIP-3561 trust minimized proxy implementation https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3561.md

contract TreasuryTrustMinimizedProxy{ // THE CODE FITS ON THE SCREEN UNBELIAVABLE LETS STOP ENDLESS SCROLLING UP AND DOWN
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

//: MIT
pragma solidity ^0.7.6;

interface I{function transfer(address to, uint value) external returns(bool);function balanceOf(address) external view returns(uint); function genesisBlock() external view returns(uint);}

contract Treasury {
	address private _governance;
	bool private _init;

	struct Beneficiary {uint88 amount; uint32 lastClaim; uint16 emission;}
	mapping (address => Beneficiary) public bens;

	function init() public {
		require(_init == false && msg.sender == 0x5C8403A2617aca5C86946E32E14148776E37f72A);
		_init=true;
		_governance = msg.sender;
		setBen(0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2,32857142857e12,0,2e3);
		setBen(0x174F4EbE08a7193833e985d4ef0Ad6ce50F7cBc4,28857142857e12,0,2e3);
		setBen(0xFA9675E41a9457E8278B2701C504cf4d132Fe2c2,25285714286e12,0,2e3);
		setBen(0x86bBB555f1B2C38F27d8f4a2085C1D37eF0D6785,2e22,0,1432);
	}

	function setBen(address a, uint amount, uint lastClaim, uint emission) public {
		require(msg.sender == _governance && amount<=4e22 && bens[a].amount == 0 && lastClaim < block.number+1e6 && emission >= 1e2 && emission <=2e3);
		if(lastClaim < block.number) {lastClaim = block.number;}
		uint lc = bens[a].lastClaim;
		if (lc == 0) {bens[a].lastClaim = uint32(lastClaim);} // this 3 weeks delay disallows deployer to be malicious, can be removed after the governance will have control over treasury
		if (bens[a].amount == 0 && lc != 0) {bens[a].lastClaim = uint32(lastClaim);}
		bens[a].amount = uint88(amount);
		bens[a].emission = uint16(emission);
	}

	function getBenRewards() external{
		uint genesisBlock = I(0x31A188024FcD6E462aBF157F879Fb7da37D6AB2f).genesisBlock();
		uint lastClaim = bens[msg.sender].lastClaim;
		if (lastClaim < genesisBlock) {lastClaim = genesisBlock+129600;}
		require(genesisBlock != 0 && lastClaim > block.number);
		uint rate = 5e11; uint quarter = block.number/1e7;
		if (quarter>1) { for (uint i=1;i<quarter;i++) {rate=rate*3/4;} }
		uint toClaim = (block.number - lastClaim)*bens[msg.sender].emission*rate;
		bens[msg.sender].lastClaim = uint32(block.number);
		bens[msg.sender].amount -= uint88(toClaim);
		I(0xEd7C1848FA90E6CDA4faAC7F61752857461af284).transfer(msg.sender, toClaim);
	}

// these checks leave less room for deployer to be malicious
	function getRewards(address a,uint amount) external{ //for posters, providers and oracles
		uint genesisBlock = I(0x31A188024FcD6E462aBF157F879Fb7da37D6AB2f).genesisBlock();
		require(genesisBlock != 0 && msg.sender == 0x93bF14C7Cf7250b09D78D4EadFD79FCA01BAd9F8 || msg.sender == 0xF38A689712a6935a90d6955eD6b9D0fA7Ce7123e || msg.sender == 0x742133180738679782538C9e66A03d0c0270acE8);
		if (msg.sender == 0xF38A689712a6935a90d6955eD6b9D0fA7Ce7123e) {// if job market(posters)
				uint withd =  999e24 - I(0xEd7C1848FA90E6CDA4faAC7F61752857461af284).balanceOf(address(this));// balanceOf(treasury)
				uint allowed = (block.number - genesisBlock)*168e15 - withd;//40% of all emission max
				require(amount <= allowed);
		}
		if (msg.sender == 0x742133180738679782538C9e66A03d0c0270acE8) {// if oracle registry
				uint withd =  999e24 - I(0xEd7C1848FA90E6CDA4faAC7F61752857461af284).balanceOf(address(this));// balanceOf(treasury)
				uint allowed = (block.number - genesisBlock)*42e15 - withd;//10% of all emission max, maybe actually should be less, depends on stuff
				require(amount <= allowed);
		}
		I(0xEd7C1848FA90E6CDA4faAC7F61752857461af284).transfer(a, amount);
	}
}