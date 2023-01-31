

// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// ////-FileCopyrightText: 2021 ShardLabs
// ////-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

interface IValidatorProxy {
    /// @notice Allows to set a new validator implementation.
    /// @param _newImplementation new address.
    function setValidatorImplementation(address _newImplementation) external;

    /// @notice Allows to set a new operator.
    /// @param _newOperator new address.
    function setOperator(address _newOperator) external;
}


// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

//import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// ////-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}
// ////-FileCopyrightText: 2021 ShardLabs
// ////-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

//import "@openzeppelin/contracts/proxy/Proxy.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//import "./interfaces/IValidatorProxy.sol";

/// @title ValidatorProxy
/// @author 2021 ShardLabs.
/// @notice The validator proxy contract is a proxy used as a validator owner in the
/// stakeManager. Each time a new operator is added a new validator proxy is created
/// by the validator factory and assigned to the operator. Later we can use it to
/// stake the validator on the stakeManager and manage it.
contract ValidatorProxy is IValidatorProxy, Proxy {
    /// @notice the validator implementation address.
    address public implementation;
    /// @notice the operator address.
    address public operator;
    /// @notice validator factory address.
    address public validatorFactory;

    constructor(
        address _newImplementation,
        address _operator,
        address _validatorFactory
    ) {
        implementation = _newImplementation;
        operator = _operator;
        validatorFactory = _validatorFactory;
    }

    /// @notice check if the msg.sender is the validator factory.
    modifier isValidatorFactory() {
        require(
            msg.sender == validatorFactory,
            "Caller is not the validator factory"
        );
        _;
    }

    /// @notice Allows the validatorFactory to set the validator implementation.
    /// @param _newValidatorImplementation set a new implementation
    function setValidatorImplementation(address _newValidatorImplementation)
        external
        override
        isValidatorFactory
    {
        implementation = _newValidatorImplementation;
    }

    /// @notice Allows the validatorFactory to set the operator implementation.
    /// @param _newOperator set a new operator.
    function setOperator(address _newOperator)
        external
        override
        isValidatorFactory
    {
        operator = _newOperator;
    }

    /// @notice Allows to get the contract implementation address.
    /// @return Returns the address of the implementation
    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {
        return implementation;
    }
}
