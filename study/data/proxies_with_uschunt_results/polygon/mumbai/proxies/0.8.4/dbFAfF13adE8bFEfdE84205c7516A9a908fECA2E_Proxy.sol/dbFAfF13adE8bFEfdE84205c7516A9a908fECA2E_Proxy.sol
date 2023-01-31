/**
 *Submitted for verification at polygonscan.com on 2021-07-30
*/

// ////-License-Identifier: GPL-3.0-onlly
pragma solidity ^0.8.4;

contract Proxy {
    address public immutable implementation;

    constructor(address impl) {
        implementation = impl;
    }

    fallback() external payable {
        _delegateCall(implementation);
    }

    receive() external payable {
        _delegateCall(implementation);
    }

    function _delegateCall(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

// : GPL-3.0-onlly
pragma solidity ^0.8.4;

interface IIdentity {
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    event Executed(
        address indexed module,
        address indexed to,
        uint256 value,
        bytes data
    );

    function init(address initialOwner) external;

    function owner() external view returns (address);

    function setOwner(address newOwner) external;

    function isModuleEnabled(address module) external view returns (bool);

    function isStaticCallSupported(bytes4 methodID)
        external
        view
        returns (bool);

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bytes memory);
}


// : GPL-3.0-onlly
pragma solidity ^0.8.4;

interface IModuleManager {
    event Enabled(address indexed module);
    event Disabled(address indexed module);
    event StaticCallExecutorChanged(address indexed module);

    function isEnabled(address module) external view returns (bool);

    function enable(address module) external;

    function disable(address module) external;

    function staticCallExecutor() external view returns (address);

    function setStaticCallExecutor(address module) external;
}


// : GPL-3.0-onlly
pragma solidity ^0.8.4;

interface IStaticCallExecutor {
    function supportsStaticCall(bytes4 methodID) external view returns (bool);
}


// : GPL-3.0-onlly
pragma solidity ^0.8.4;

//import"IModuleManager.sol";
//import"IStaticCallExecutor.sol";
//import"IIdentity.sol";

contract Identity is IIdentity {
    IModuleManager internal immutable _moduleManager;

    address public override owner;

    modifier onlyModule() {
        require(
            _moduleManager.isEnabled(msg.sender),
            "Identity: module not enabled"
        );
        _;
    }

    constructor(address moduleManager) {
        require(
            moduleManager != address(0),
            "Identity: module manager is zero address"
        );

        _moduleManager = IModuleManager(moduleManager);
    }

    function init(address initialOwner) external override {
        require(owner == address(0), "Identity: already initialized");

        owner = initialOwner;
    }

    function setOwner(address newOwner) external override onlyModule {
        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function isModuleEnabled(address module)
        external
        view
        override
        returns (bool)
    {
        return _moduleManager.isEnabled(module);
    }

    function isStaticCallSupported(bytes4 methodID)
        public
        view
        override
        returns (bool)
    {
        address staticCallExecutor = _moduleManager.staticCallExecutor();

        return
            staticCallExecutor != address(0) &&
            IStaticCallExecutor(staticCallExecutor).supportsStaticCall(
                methodID
            );
    }

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external override onlyModule returns (bytes memory) {
        (bool success, bytes memory result) = to.call{value: value}(data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        emit Executed(msg.sender, to, value, data);

        return result;
    }

    fallback() external payable {
        if (!isStaticCallSupported(msg.sig)) {
            return;
        }

        _staticCall(_moduleManager.staticCallExecutor());
    }

    receive() external payable {}

    function _staticCall(address executor) internal view {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := staticcall(gas(), executor, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}



}
