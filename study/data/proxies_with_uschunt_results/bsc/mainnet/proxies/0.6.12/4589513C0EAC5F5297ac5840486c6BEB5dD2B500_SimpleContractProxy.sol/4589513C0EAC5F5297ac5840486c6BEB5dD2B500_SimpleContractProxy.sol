/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// ////-License-Identifier: MIT

// File contracts/v1contracts/SimpleContractProxy.sol
// License-Identifier: MIT

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC165 standard as defined in the EIP.
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceID The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     * @return `true` if the contract implements `interfaceID` and
     * `interfaceID` is not 0xffffffff, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/**
 * @dev General proxy contract supporting upgradeability, based on a simplified version of EIP-1822
 */
contract SimpleContractProxy {
    string internal constant proxyName = "Simple Proxy for CAKE-USDT to WEB3";
    string internal constant proxyVersion = "1.0";

    event ImplementationUpdated(address indexed _implementation);

    /**
     * @notice Save the code address
     * @param _implementation The initial code address of the logic implementation contract
     * @dev Code position in storage is
     * keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
     */
    constructor(address _implementation) public {
        /**
         * @dev ERC-165 identifier for the `FeedsContractProxiable` interface support, which is
         * bytes4(keccak256("updateImplementation(address)")) ^ bytes4(keccak256("getImplementation()")) = "0xa8aa2dfe"
         */
        require(IERC165(_implementation).supportsInterface(0xa8aa2dfe), "Contract address not proxiable");

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, _implementation)
        }

        emit ImplementationUpdated(_implementation);
    }

    /**
     * @notice Delegate all function calls to the logic contract
     */
    function _fallback() internal {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let implementation := sload(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7)
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(sub(gas(), 10000), implementation, 0x0, calldatasize(), 0, 0)
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }

    /**
     * @dev Fallback function that delegates calls to the logic contract. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the logic contract. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }
}