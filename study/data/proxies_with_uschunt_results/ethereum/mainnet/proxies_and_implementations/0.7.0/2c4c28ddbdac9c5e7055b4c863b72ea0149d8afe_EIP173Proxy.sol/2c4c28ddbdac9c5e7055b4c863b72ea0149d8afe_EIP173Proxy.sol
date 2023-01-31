
// ////-License-Identifier: MIT
pragma solidity ^0.7.0;

//import "./Proxy.sol";

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














// ////-License-Identifier: MIT
pragma solidity ^0.7.0;

//import "./EIP173Proxy.sol";

///@notice Proxy implementing EIP173 for ownership management that accept ETH via receive
contract EIP173ProxyWithReceive is EIP173Proxy {
    constructor(
        address implementationAddress,
        address ownerAddress,
        bytes memory data
    ) payable EIP173Proxy(implementationAddress, ownerAddress, data) {}

    receive() external payable override {}
}


// : LGPL-3.0-or-later
pragma solidity ^0.7.6;

/// @title Gnosis Protocol v2 Authentication Interface
/// @author Gnosis Developers
interface GPv2Authentication {
    /// @dev determines whether the provided address is an authenticated solver.
    /// @param prospectiveSolver the address of prospective solver.
    /// @return true when prospectiveSolver is an authenticated solver, otherwise false.
    function isSolver(address prospectiveSolver) external view returns (bool);
}


// : LGPL-3.0-or-later
pragma solidity ^0.7.6;

library GPv2EIP1967 {
    /// @dev The storage slot where the proxy administrator is stored, defined
    /// as `keccak256('eip1967.proxy.admin') - 1`.
    bytes32 internal constant ADMIN_SLOT =
        hex"b53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103";

    /// @dev Returns the address stored in the EIP-1967 administrator storage
    /// slot for the current contract. If this method is not called from an
    /// contract behind an EIP-1967 proxy, then it will most likely return
    /// `address(0)`, as the implementation slot is likely to be unset.
    ///
    /// @return admin The administrator address.
    function getAdmin() internal view returns (address admin) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            admin := sload(ADMIN_SLOT)
        }
    }

    /// @dev Sets the storage at the EIP-1967 administrator slot to be the
    /// specified address.
    ///
    /// @param admin The administrator address to set.
    function setAdmin(address admin) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(ADMIN_SLOT, admin)
        }
    }
}


// : MIT

// Vendored from OpenZeppelin contracts with minor modifications:
// - Modified Solidity version
// - Formatted code
// - Shortned revert messages
// - Inlined `Address.isContract` implementation
// <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/proxy/Initializable.sol>

pragma solidity ^0.7.6;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || _isConstructor() || !_initialized,
            "Initializable: initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(address())
        }
        return size == 0;
    }
}


// : LGPL-3.0-only

// Vendored from Gnosis utility contracts with minor modifications:
// - Modified Solidity version
// - Formatted code
// - Added linter directives to ignore low level call and assembly warnings
// <https://github.com/gnosis/util-contracts/blob/v3.1.0-solc-7/contracts/StorageAccessible.sol>

pragma solidity ^0.7.6;

/// @title ViewStorageAccessible - Interface on top of StorageAccessible base class to allow simulations from view functions
interface ViewStorageAccessible {
    /**
     * @dev Same as `simulateDelegatecall` on StorageAccessible. Marked as view so that it can be called from external contracts
     * that want to run simulations from within view functions. Will revert if the invoked simulation attempts to change state.
     */
    function simulateDelegatecall(
        address targetContract,
        bytes memory calldataPayload
    ) external view returns (bytes memory);

    /**
     * @dev Same as `getStorageAt` on StorageAccessible. This method allows reading aribtrary ranges of storage.
     */
    function getStorageAt(uint256 offset, uint256 length)
        external
        view
        returns (bytes memory);
}

/// @title StorageAccessible - generic base contract that allows callers to access all internal storage.
contract StorageAccessible {
    /**
     * @dev Reads `length` bytes of storage in the currents contract
     * @param offset - the offset in the current contract's storage in words to start reading from
     * @param length - the number of words (32 bytes) of data to read
     * @return the bytes that were read.
     */
    function getStorageAt(uint256 offset, uint256 length)
        external
        view
        returns (bytes memory)
    {
        bytes memory result = new bytes(length * 32);
        for (uint256 index = 0; index < length; index++) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let word := sload(add(offset, index))
                mstore(add(add(result, 0x20), mul(index, 0x20)), word)
            }
        }
        return result;
    }

    /**
     * @dev Performs a delegetecall on a targetContract in the context of self.
     * Internally reverts execution to avoid side effects (making it static). Catches revert and returns encoded result as bytes.
     * @param targetContract Address of the contract containing the code to execute.
     * @param calldataPayload Calldata that should be sent to the target contract (encoded method name and arguments).
     */
    function simulateDelegatecall(
        address targetContract,
        bytes memory calldataPayload
    ) public returns (bytes memory response) {
        bytes memory innerCall =
            abi.encodeWithSelector(
                this.simulateDelegatecallInternal.selector,
                targetContract,
                calldataPayload
            );
        // solhint-disable-next-line avoid-low-level-calls
        (, response) = address(this).call(innerCall);
        bool innerSuccess = response[response.length - 1] == 0x01;
        setLength(response, response.length - 1);
        if (innerSuccess) {
            return response;
        } else {
            revertWith(response);
        }
    }

    /**
     * @dev Performs a delegetecall on a targetContract in the context of self.
     * Internally reverts execution to avoid side effects (making it static). Returns encoded result as revert message
     * concatenated with the success flag of the inner call as a last byte.
     * @param targetContract Address of the contract containing the code to execute.
     * @param calldataPayload Calldata that should be sent to the target contract (encoded method name and arguments).
     */
    function simulateDelegatecallInternal(
        address targetContract,
        bytes memory calldataPayload
    ) external returns (bytes memory response) {
        bool success;
        // solhint-disable-next-line avoid-low-level-calls
        (success, response) = targetContract.delegatecall(calldataPayload);
        revertWith(abi.encodePacked(response, success));
    }

    function revertWith(bytes memory response) internal pure {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            revert(add(response, 0x20), mload(response))
        }
    }

    function setLength(bytes memory buffer, uint256 length) internal pure {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(buffer, length)
        }
    }
}


// : LGPL-3.0-or-later
pragma solidity ^0.7.6;

//import"./interfaces/GPv2Authentication.sol";
//import"./libraries/GPv2EIP1967.sol";
//import"./mixins/Initializable.sol";
//import"./mixins/StorageAccessible.sol";

/// @title Gnosis Protocol v2 Access Control Contract
/// @author Gnosis Developers
contract GPv2AllowListAuthentication is
    GPv2Authentication,
    Initializable,
    StorageAccessible
{
    /// @dev The address of the manager that has permissions to add and remove
    /// solvers.
    address public manager;

    /// @dev The set of allowed solvers. Allowed solvers have a value of `true`
    /// in this mapping.
    mapping(address => bool) private solvers;

    /// @dev Event emitted when the manager changes.
    event ManagerChanged(address newManager, address oldManager);

    /// @dev Event emitted when a solver gets added.
    event SolverAdded(address solver);

    /// @dev Event emitted when a solver gets removed.
    event SolverRemoved(address solver);

    /// @dev Initialize the manager to a value.
    ///
    /// This method is a contract initializer that is called exactly once after
    /// creation. An initializer is used instead of a constructor so that this
    /// contract can be used behind a proxy.
    ///
    /// This initializer is idempotent.
    ///
    /// @param manager_ The manager to initialize the contract with.
    function initializeManager(address manager_) external initializer {
        manager = manager_;
        emit ManagerChanged(manager_, address(0));
    }

    /// @dev Modifier that ensures a method can only be called by the contract
    /// manager. Reverts if called by other addresses.
    modifier onlyManager() {
        require(manager == msg.sender, "GPv2: caller not manager");
        _;
    }

    /// @dev Modifier that ensures method can be either called by the contract
    /// manager or the proxy owner.
    ///
    /// This modifier assumes that the proxy uses an EIP-1967 compliant storage
    /// slot for the admin.
    modifier onlyManagerOrOwner() {
        require(
            manager == msg.sender || GPv2EIP1967.getAdmin() == msg.sender,
            "GPv2: not authorized"
        );
        _;
    }

    /// @dev Set the manager for this contract.
    ///
    /// This method can be called by the current manager (if they want to to
    /// reliquish the role and give it to another address) or the contract
    /// owner (i.e. the proxy admin).
    ///
    /// @param manager_ The new contract manager address.
    function setManager(address manager_) external onlyManagerOrOwner {
        address oldManager = manager;
        manager = manager_;
        emit ManagerChanged(manager_, oldManager);
    }

    /// @dev Add an address to the set of allowed solvers. This method can only
    /// be called by the contract manager.
    ///
    /// This function is idempotent.
    ///
    /// @param solver The solver address to add.
    function addSolver(address solver) external onlyManager {
        solvers[solver] = true;
        emit SolverAdded(solver);
    }

    /// @dev Removes an address to the set of allowed solvers. This method can
    /// only be called by the contract manager.
    ///
    /// This function is idempotent.
    ///
    /// @param solver The solver address to remove.
    function removeSolver(address solver) external onlyManager {
        solvers[solver] = false;
        emit SolverRemoved(solver);
    }

    /// @inheritdoc GPv2Authentication
    function isSolver(address prospectiveSolver)
        external
        view
        override
        returns (bool)
    {
        return solvers[prospectiveSolver];
    }
}



}
