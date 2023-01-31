/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

// ////-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

// OpenZeppelin Upgradeability contracts modified by Sam Porter. Proxy for Nameless Protocol contracts
// You can find original set of contracts here: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/proxy

// Had to pack OpenZeppelin upgradeability contracts in one single contract for readability. It's basically the same OpenZeppelin functions 
// but in one contract with some differences:
// 1. DEADLINE is a block after which it becomes impossible to upgrade the contract. Defined in constructor and here it's ~2 years.
// Maybe not even required for most contracts, but I kept it in case if something happens to developers.
// 2. PROPOSE_BLOCK defines how often the contract can be upgraded. Defined in _setNextLogic() function and the interval here is set
// to 172800 blocks ~1 month.
// 3. Admin rights are burnable
// 4. prolongLock() allows to add to PROPOSE_BLOCK. Basically allows to prolong lock. For example if there no upgrades planned soon,
// then this function could be called to set next upgrade being possible only in a year, so investors won't need to monitor the code too closely
// all the time. Could prolong to maximum solidity number so the deadline might not be needed 
// 5. logic contract is not being set suddenly. it's being stored in NEXT_LOGIC_SLOT for a month and only after that it can be set as LOGIC_SLOT.
// Users have time to decide on if the deployer or the governance is malicious and exit safely.
// 6. constructor does not require arguments
// 7. before removeTrust() is called, the proxy acts like eip-1967 proxy, can be upgraded at any point in time. it's to counter human error,
// after deployer confirms that everything is deployed correctly, must be called

// It fixes "upgradeability bug" I believe. Also I sincerely believe that upgradeability is not about fixing bugs, but about upgradeability,
// so yeah, proposed logic has to be clean and without typos(!) or overflows(!).
// In my heart it exists as eip-1984 but it's too late for that number. https://ethereum-magicians.org/t/trust-minimized-proxy/5742/2

contract AletheoTreasuryTrustMinimizedProxy{ // THE CODE FITS ON THE SCREEN UNBELIAVABLE LETS STOP ENDLESS SCROLLING UP AND DOWN
	event Upgraded(address indexed toLogic);
	event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
	event NextLogicDefined(address indexed nextLogic, uint earliestArrivalBlock);
	event UpgradesRestrictedUntil(uint block);
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
	function prolongLock(uint b) external ifAdmin {require(b > _proposeBlock()); assembly {sstore(PROPOSE_BLOCK_SLOT,b)} emit UpgradesRestrictedUntil(b);}
	function removeTrust() external ifAdmin {assembly{ sstore(TRUST_MINIMIZED_SLOT, true) }emit TrustRemoved();} // before this called acts like a normal eip 1967 transparent proxy. after the deployer confirms everything is deployed correctly must be called
	function _updateBlockSlot() internal {uint nlb = block.number + 172800; assembly {sstore(NEXT_LOGIC_BLOCK_SLOT,nlb)}}
	function _setNextLogic(address nl) internal {require(block.number >= _proposeBlock());_updateBlockSlot();assembly { sstore(NEXT_LOGIC_SLOT, nl)}emit NextLogicDefined(nl,block.number + 172800);}

	function proposeToAndCall(address newLogic, bytes calldata data) payable external ifAdmin {
		if (_logic() == address(0) || _trustMinimized() == false) {_updateBlockSlot();assembly {sstore(LOGIC_SLOT,newLogic)}emit Upgraded(newLogic);}else{_setNextLogic(newLogic);}
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
pragma solidity >=0.8.4 <0.9.0;
// stable coin based grants in next implementation
// i am thinking of moving all beneficiary logic out of treasury in next implementation
interface I{function transfer(address to, uint value) external returns(bool);function balanceOf(address) external returns(uint);}
contract Treasury {
	address private _governance;
	uint8 private _governanceSet;
	bool private _init;

	struct Beneficiary {bool solid; uint88 amount; uint32 lastClaim; uint16 emission;}
	mapping (address => Beneficiary) public bens;

	function init() public {
		require(_init == false && msg.sender == 0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2);
		_init=true;
		_governance = msg.sender;
		setBeneficiary(0x2D9F853F1a71D0635E64FcC4779269A05BccE2E2,true,32857142857e12,0,1e4);
		setBeneficiary(0x174F4EbE08a7193833e985d4ef0Ad6ce50F7cBc4,true,28857142857e12,0,1e4);
		setBeneficiary(0xFA9675E41a9457E8278B2701C504cf4d132Fe2c2,true,25285714286e12,0,1e4);
	}
// so we assume that not only beneficiaries but also the governance is malicious
// the function can overwrite some existing beneficiaries parameters
// or we do it differently: a boolean that makes a grant editable/removable/irremovable, so that governance can express trust,
// because if a malicious beneficiary scams governance, governance can ruin that beneficiary' reputation,
// however if malicious governance scams a beneficiary, beneficiary can't do anything
// best solution is yet to be found, design could change
// another way could be is to disallow editing/removing grants at all but give those grants in small parts instead
// so future small parts could be cancelled if required
	function setBeneficiary(address a, bool solid, uint amount, uint lastClaim, uint emission) public {
		require(msg.sender == _governance && bens[a].solid == false && amount<=4e22 && lastClaim < block.number+1e6 && emission >= 1e2 && emission <=1e4);
		if(lastClaim < block.number) {lastClaim = block.number;}
		if(lastClaim < 12510400) {lastClaim = 12510400;}
		if(lastClaim > 12510400 && lastClaim < 1264e4) {lastClaim = 1264e4;}//so it adds even more convenience
		if (solid == true) {bens[a].solid = true;}
		uint lc = bens[a].lastClaim;
		if (lc == 0) {bens[a].lastClaim = uint32(lastClaim+129600);} // this 3 weeks delay disallows deployer to be malicious, can be removed after the governance will have control over treasury
		if (bens[a].amount == 0 && lc != 0) {bens[a].lastClaim = uint32(lastClaim);}
		bens[a].amount = uint88(amount);
		bens[a].emission = uint16(emission);
	}

	function getBeneficiaryRewards() external{
		uint lastClaim = bens[msg.sender].lastClaim; uint rate = 1e11; uint quarter = block.number/1e7;
		if (quarter>1) { for (uint i=1;i<quarter;i++) {rate=rate*3/4;} }
		uint toClaim = (block.number - lastClaim)*bens[msg.sender].emission*rate;
		bens[msg.sender].lastClaim = uint32(block.number);
		bens[msg.sender].amount -= uint88(toClaim);
		I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).transfer(msg.sender, toClaim);
	}

// these checks leave less room for deployer to be malicious
	function getRewards(address a,uint amount) external{ //for posters, providers and oracles
		require(msg.sender == 0x109533F9e10d4AEEf6d74F1e2D59a9ed11266f27 || msg.sender == 0xEcCD8639eA31FAfe9e9646Fbf31310Ec489ad1C8 || msg.sender == 0xde97e5a2fAe859ac24F70D1f251B82D6A9B77296);
		if (msg.sender == 0xEcCD8639eA31FAfe9e9646Fbf31310Ec489ad1C8) {// if job market(posters)
				uint withd =  999e24 - I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).balanceOf(address(this));// balanceOf(treasury)
				uint allowed = (block.number - 1264e4)*168e15 - withd;//40% of all emission max
				require(amount <= allowed);
		}
		if (msg.sender == 0xde97e5a2fAe859ac24F70D1f251B82D6A9B77296) {// if oracle registry
				uint withd =  999e24 - I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).balanceOf(address(this));// balanceOf(treasury)
				uint allowed = (block.number - 1264e4)*42e15 - withd;//10% of all emission max, maybe actually should be less, depends on stuff
				require(amount <= allowed);
		}
		I(0x1565616E3994353482Eb032f7583469F5e0bcBEC).transfer(a, amount);
	}

	function setGovernance(address a) public {require(_governanceSet < 3 && msg.sender == _governance);_governanceSet += 1;_governance = a;}
}