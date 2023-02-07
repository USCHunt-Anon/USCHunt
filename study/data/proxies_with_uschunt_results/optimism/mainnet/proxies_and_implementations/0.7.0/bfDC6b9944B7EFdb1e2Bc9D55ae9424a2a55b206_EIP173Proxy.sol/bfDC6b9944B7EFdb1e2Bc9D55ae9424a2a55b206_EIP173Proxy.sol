// ////-License-Identifier: MIT
pragma solidity ^0.7.0;

////import "./Proxy.sol";

interface ERC165 {
    function supportsInterface(bytes4 id) external view returns (bool);
}




// ////-License-Identifier: MIT
pragma solidity ^0.7.0;

// EIP-1967
abstract contract Proxy {
    // /////////////////////// EVENTS ///////////////////////////////////////////////////////////////////////////

    event ProxyImplementationUpdated(address indexed previousImplementation, address indexed newImplementation);

    // ///////////////////// EXTERNAL ///////////////////////////////////////////////////////////////////////////

    receive() external payable virtual {
        revert("ETHER_REJECTED"); // explicit reject by default
    }

    fallback() external payable {
        _fallback();
    }

    // ///////////////////////// INTERNAL //////////////////////////////////////////////////////////////////////

    function _fallback() internal {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            let implementationAddress := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(gas(), implementationAddress, 0x0, calldatasize(), 0, 0)
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

    function _setImplementation(address newImplementation, bytes memory data) internal {
        address previousImplementation;
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            previousImplementation := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }

        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            sstore(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc, newImplementation)
        }

        emit ProxyImplementationUpdated(previousImplementation, newImplementation);

        if (data.length > 0) {
            (bool success, ) = newImplementation.delegatecall(data);
            if (!success) {
                assembly {
                    // This assembly ensure the revert contains the exact string data
                    let returnDataSize := returndatasize()
                    returndatacopy(0, 0, returnDataSize)
                    revert(0, returnDataSize)
                }
            }
        }
    }
}




///@notice Proxy implementing EIP173 for ownership management
contract EIP173Proxy is Proxy {
    // ////////////////////////// EVENTS ///////////////////////////////////////////////////////////////////////

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // /////////////////////// CONSTRUCTOR //////////////////////////////////////////////////////////////////////

    constructor(
        address implementationAddress,
        address ownerAddress,
        bytes memory data
    ) payable {
        _setImplementation(implementationAddress, data);
        _setOwner(ownerAddress);
    }

    // ///////////////////// EXTERNAL ///////////////////////////////////////////////////////////////////////////

    function owner() external view returns (address) {
        return _owner();
    }

    function supportsInterface(bytes4 id) external view returns (bool) {
        if (id == 0x01ffc9a7 || id == 0x7f5828d0) {
            return true;
        }
        if (id == 0xFFFFFFFF) {
            return false;
        }

        ERC165 implementation;
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            implementation := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }

        // Technically this is not standard compliant as ERC-165 require 30,000 gas which that call cannot ensure
        // because it is itself inside `supportsInterface` that might only get 30,000 gas.
        // In practise this is unlikely to be an issue.
        try implementation.supportsInterface(id) returns (bool support) {
            return support;
        } catch {
            return false;
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _setOwner(newOwner);
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        _setImplementation(newImplementation, "");
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable onlyOwner {
        _setImplementation(newImplementation, data);
    }

    // /////////////////////// MODIFIERS ////////////////////////////////////////////////////////////////////////

    modifier onlyOwner() {
        require(msg.sender == _owner(), "NOT_AUTHORIZED");
        _;
    }

    // ///////////////////////// INTERNAL //////////////////////////////////////////////////////////////////////

    function _owner() internal view returns (address adminAddress) {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            adminAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }

    function _setOwner(address newOwner) internal {
        address previousOwner = _owner();
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            sstore(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103, newOwner)
        }
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}


// : UNLICENSED
pragma solidity 0.8.13;

interface IFeePool {
  function feesAvailable(address account)
    external
    view
    returns (uint256, uint256);

  function isFeesClaimable(address account) external view returns (bool);

  function claimOnBehalf(address claimingForAddress) external returns (bool);
}

interface IDelegateApprovals {
  function canClaimFor(address authoriser, address delegate)
    external
    view
    returns (bool);
}

interface IProxy {
  function target() external view returns (address);
}

contract SnxResolver {
  address public constant OPS =
    address(0x340759c8346A1E6Ed92035FB8B6ec57cE1D82c2c);
  address public constant APPROVALS =
    address(0x2A23bc0EA97A89abD91214E8e4d20F02Fe14743f);
  address public constant FEE_POOL_PROXY =
    address(0x4a16A42407AA491564643E1dfc1fd50af29794eF);

  function checker(address _account)
    external
    view
    returns (bool, bytes memory execPayload)
  {
    IFeePool feePool = IFeePool(IProxy(FEE_POOL_PROXY).target());
    IDelegateApprovals approvals = IDelegateApprovals(APPROVALS);

    (uint256 totalFees, uint256 totalRewards) = feePool.feesAvailable(_account);
    if (totalFees == 0 && totalRewards == 0) {
      execPayload = bytes("No fees to claim");
      return (false, execPayload);
    }

    if (!feePool.isFeesClaimable(_account)) {
      execPayload = bytes("Not claimable, cRatio too low");
      return (false, execPayload);
    }

    if (!approvals.canClaimFor(_account, OPS)) {
      execPayload = bytes("Not approved for claiming");
      return (false, execPayload);
    }

    execPayload = abi.encodeWithSelector(
      feePool.claimOnBehalf.selector,
      _account
    );

    return (true, execPayload);
  }
}



}
