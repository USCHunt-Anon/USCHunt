/**
 *Submitted for verification at Etherscan.io on 2022-03-25
*/

// ////-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Logic {
    bool initialized;
    uint256 magicNumber;

    function initialize() public {
        require(!initialized, "already initialized");

        magicNumber = 0x42;
        initialized = true;
    }

    function setMagicNumber(uint256 newMagicNumber) public {
        magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
        return magicNumber;
    }
}

pragma solidity ^0.8.4;

contract LogicV2 {
    bool initialized;
    uint256 magicNumber;

    function initialize() public {
        require(!initialized, "already initialized");

        magicNumber = 0x42;
        initialized = true;
    }

    function setMagicNumber(uint256 newMagicNumber) public {
        magicNumber = newMagicNumber;
    }

    function getMagicNumber() public view returns (uint256) {
        return magicNumber;
    }

    function doMagic() public {
        magicNumber = magicNumber / 2;
    }
}


pragma solidity ^0.8.4;

library StorageSlot {
    function getAddressAt(bytes32 slot) internal view returns (address a) {
        assembly {
            a := sload(slot)
        }
    }

    function setAddressAt(bytes32 slot, address address_) internal {
        assembly {
            sstore(slot, address_)
        }
    }
}

contract Proxy {
    bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function setImplementation(address implementation_) public {
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation_);
    }

    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressAt(_IMPL_SLOT);
    }

    function _delegate(address impl) internal virtual {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    fallback() external {
        _delegate(StorageSlot.getAddressAt(_IMPL_SLOT));
    }
}