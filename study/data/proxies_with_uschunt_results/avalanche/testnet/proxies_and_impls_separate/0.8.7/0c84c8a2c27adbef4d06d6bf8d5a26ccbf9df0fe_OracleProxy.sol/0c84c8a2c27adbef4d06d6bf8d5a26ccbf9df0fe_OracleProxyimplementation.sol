// : UNLICENSED
pragma solidity 0.8.7;

contract Proxiable {

    function updateCodeAddress(address newAddress) internal {
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}


// : UNLICENSED
pragma solidity 0.8.7;

//import"./Proxiable.sol";

contract PriceOracleV2 is Proxiable {

	address _lastContributor;
	address _owner;
	uint256 _price;

	modifier onlyOwner() {
		require(msg.sender == _owner, "Only owner is allowed to perform this action");
		_;
	}

	function setPrice(uint256 price) public {
		_price = price;
		_lastContributor = msg.sender;
	}

	function updateCode(address newCode) onlyOwner public {
		updateCodeAddress(newCode);
	}

	function owner() public view returns (address) {
		return _owner;
	}

	function price() public view returns (uint256) {
		return _price;
	}

}


