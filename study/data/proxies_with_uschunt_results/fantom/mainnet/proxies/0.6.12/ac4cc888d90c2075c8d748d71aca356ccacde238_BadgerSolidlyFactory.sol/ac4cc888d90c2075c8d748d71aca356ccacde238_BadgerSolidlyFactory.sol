/**
 *Submitted for verification at FtmScan.com on 2022-02-21
*/

// ////-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/**
 *Submitted for verification at Etherscan.io on 2020-10-09
 */



/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
abstract contract Proxy {
    /**
     * @dev Fallback function.
     * Implemented entirely in `_fallback`.
     */
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Receive function.
     * Implemented entirely in `_fallback`.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @return The Address of the implementation.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates execution to an implementation contract.
     * This is a low level function that doesn't return to its internal call site.
     * It will return to the external caller whatever the implementation returns.
     * @param implementation Address to delegate.
     */
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

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
     * @dev Function that is run as the first thing in the fallback function.
     * Can be redefined in derived contracts to add functionality.
     * Redefinitions must call super._willFallback().
     */
    function _willFallback() internal virtual {}

    /**
     * @dev fallback implementation.
     * Extracted to enable manual triggering.
     */
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

/**
 * @title UpgradeabilityProxy
 * @dev This contract implements a proxy that allows to change the
 * implementation address to which it will delegate.
 * Such a change is called an implementation upgrade.
 */
contract UpgradeabilityProxy is Proxy {
    /**
     * @dev Contract constructor.
     * @param _logic Address of the initial implementation.
     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
     */
    constructor(address _logic, bytes memory _data) public payable {
        assert(
            IMPLEMENTATION_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
        );
        _setImplementation(_logic);
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     * @param implementation Address of the new implementation.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation.
     * @return impl Address of the current implementation
     */
    function _implementation() internal view override returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     * @param newImplementation Address of the new implementation.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation address of the proxy.
     * @param newImplementation Address of the new implementation.
     */
    function _setImplementation(address newImplementation) internal {
        require(
            Address.isContract(newImplementation),
            "Cannot set a proxy implementation to a non-contract address"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

/**
 * @title AdminUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with an authorization
 * mechanism for administrative tasks.
 * All external functions in this contract must be guarded by the
 * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity
 * feature proposal that would enable this to be done automatically.
 */
contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
    /**
     * Contract constructor.
     * @param _logic address of the initial implementation.
     * @param _admin Address of the proxy administrator.
     * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
     */
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) public payable UpgradeabilityProxy(_logic, _data) {
        assert(
            ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)
        );
        _setAdmin(_admin);
    }

    /**
     * @dev Emitted when the administration has been transferred.
     * @param previousAdmin Address of the previous admin.
     * @param newAdmin Address of the new admin.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */

    bytes32 internal constant ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier to check whether the `msg.sender` is the admin.
     * If it is, it will run the function. Otherwise, it will delegate the call
     * to the implementation.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @return The address of the proxy admin.
     */
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

    /**
     * @return The address of the implementation.
     */
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     * Only the current admin can call this function.
     * @param newAdmin Address to transfer proxy administration to.
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(
            newAdmin != address(0),
            "Cannot change the admin of a proxy to the zero address"
        );
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the backing implementation of the proxy.
     * Only the admin can call this function.
     * @param newImplementation Address of the new implementation.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the backing implementation of the proxy and call a function
     * on the new implementation.
     * This is useful to initialize the proxied contract.
     * @param newImplementation Address of the new implementation.
     * @param data Data to send as msg.data in the low level call.
     * It should include the signature and the parameters of the function to be called, as described in
     * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable
        ifAdmin
    {
        _upgradeTo(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success);
    }

    /**
     * @return adm The admin slot.
     */
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Sets the address of the proxy admin.
     * @param newAdmin Address of the new proxy admin.
     */
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
     * @dev Only fall back when the sender is not the admin.
     */
    function _willFallback() internal virtual override {
        require(
            msg.sender != _admin(),
            "Cannot call fallback function from the proxy admin"
        );
        super._willFallback();
    }
}
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
            "Initializable: contract is already initialized"
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
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}
interface IController {
    function initialize(
        address _governance,
        address _strategist,
        address _keeper,
        address _rewards
    ) external;

    function withdraw(address, uint256) external;

    function strategies(address) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function earn(address, uint256) external;

    function want(address) external view returns (address);

    function rewards() external view returns (address);

    function vaults(address) external view returns (address);

    function approveStrategy(address _token, address _strategy) external;

    function setStrategy(address _token, address _strategy) external;

    function setVault(address _token, address _vault) external;
}

interface IBadgerRegistry {
    event AddKey(string key);
    event AddVersion(string version);
    event DemoteVault(
        address author,
        string version,
        address vault,
        uint8 status
    );
    event NewVault(address author, string version, address vault);
    event PromoteVault(
        address author,
        string version,
        address vault,
        uint8 status
    );
    event RemoveVault(address author, string version, address vault);
    event Set(string key, address at);

    function add(string memory version, address vault) external;

    function addVersions(string memory version) external;

    function addresses(string memory) external view returns (address);

    function demote(
        string memory version,
        address vault,
        uint8 status
    ) external;

    function devGovernance() external view returns (address);

    function get(string memory key) external view returns (address);

    function getFilteredProductionVaults(string memory version, uint8 status)
        external
        view
        returns (address[] memory);

    function getProductionVaults()
        external
        view
        returns (BadgerRegistry.VaultData[] memory);

    function getVaults(string memory version, address author)
        external
        view
        returns (address[] memory);

    function governance() external view returns (address);

    function initialize(address newGovernance) external;

    function keys(uint256) external view returns (string memory);

    function promote(
        string memory version,
        address vault,
        uint8 status
    ) external;

    function remove(string memory version, address vault) external;

    function set(string memory key, address at) external;

    function setDev(address newDev) external;

    function setGovernance(address _newGov) external;

    function versions(uint256) external view returns (string memory);
}

interface BadgerRegistry {
    struct VaultData {
        string version;
        uint8 status;
        address[] list;
    }
}

interface IBaseV1Voter {
    function claimBribes(
        address[] memory _bribes,
        address[][] memory _tokens,
        uint256 _tokenId
    ) external;

    function claimFees(
        address[] memory _bribes,
        address[][] memory _tokens,
        uint256 _tokenId
    ) external;

    function distribute() external;

    function vote(
        uint256 tokenId,
        address[] calldata _poolVote,
        int256[] calldata _weights
    ) external;

    function claimable(address gauge) external view returns (uint256);

    function claimRewards(address[] memory _gauges, address[][] memory _tokens)
        external;

    function pools(uint256) external view returns (address);

    function gauges(address) external view returns (address);

    function poolForGauge(address) external view returns (address);

    function bribes(address) external view returns (address);

    function weights(address) external view returns (uint256);

    function votes(uint256, address) external view returns (uint256);

    function poolVote(uint256) external view returns (address[] memory);
}

contract BadgerSolidlyFactory is Initializable {
    // =====================
    // ===== Constants =====
    // =====================

    // TODO: Maybe make settable and not constants
    uint256 public constant PERFORMANCE_FEE_GOVERNANCE = 1000;
    uint256 public constant PERFORMANCE_FEE_STRATEGIST = 1000;
    uint256 public constant WITHDRAWAL_FEE = 100;

    address public constant SOLID = 0x888EF71766ca594DED1F0FA3AE64eD2941740A20;

    IBaseV1Voter public constant SOLIDLY_VOTER =
        IBaseV1Voter(0xdC819F5d05a6859D2faCbB4A44E5aB105762dbaE);

    IBadgerRegistry public constant REGISTRY =
        IBadgerRegistry(0xFda7eB6f8b7a9e9fCFd348042ae675d1d652454f);

    // =================
    // ===== State =====
    // =================

    address public governance;
    address public strategist;
    address public keeper;
    address public rewards;
    address public guardian;
    address public proxyAdmin;

    address public strategyLogic;
    address public vaultLogic;

    IController public controller;

    // ==================
    // ===== Events =====
    // ==================

    event Deployed(
        address indexed want,
        address indexed strategy,
        address indexed vault
    );

    function initialize(
        address _controllerLogic,
        address _strategyLogic,
        address _vaultLogic
    ) public initializer {
        address _governance = REGISTRY.get("governance");
        address _keeper = REGISTRY.get("keeperAccessControl");
        address _guardian = REGISTRY.get("guardian");
        address _proxyAdminTimelock = REGISTRY.get("proxyAdminTimelock");

        require(_governance != address(0), "ZERO ADDRESS");
        require(_keeper != address(0), "ZERO ADDRESS");
        require(_guardian != address(0), "ZERO ADDRESS");
        require(_proxyAdminTimelock != address(0), "ZERO ADDRESS");

        governance = _governance;
        strategist = _governance;
        keeper = _keeper;
        guardian = _guardian;
        rewards = _governance;
        proxyAdmin = _proxyAdminTimelock;

        strategyLogic = _strategyLogic;
        vaultLogic = _vaultLogic;

        controller = IController(
            deployProxy(
                _controllerLogic,
                _proxyAdminTimelock,
                abi.encodeWithSelector(
                    IController.initialize.selector,
                    address(this), // governance
                    _governance, // strategist
                    _keeper,
                    _governance // rewards
                )
            )
        );
    }

    // ====================
    // ===== External =====
    // ====================

    function deploy(address _want)
        external
        returns (address strategy_, address vault_)
    {
        strategy_ = deployStrategy(_want);
        vault_ = deployVault(_want);

        emit Deployed(_want, strategy_, vault_);
    }

    // ============================
    // ===== Internal helpers =====
    // ============================

    function deployStrategy(address _token)
        internal
        returns (address strategy_)
    {
        require(
            controller.strategies(_token) == address(0),
            "already deployed"
        );
        address gauge = SOLIDLY_VOTER.gauges(_token);
        require(gauge != address(0), "no gauge");

        strategy_ = deployProxy(
            strategyLogic,
            proxyAdmin,
            abi.encodeWithSignature(
                "initialize(address,address,address,address,address,address[3],uint256[3])",
                governance,
                strategist,
                address(controller),
                keeper,
                guardian,
                [_token, gauge, SOLID],
                [
                    PERFORMANCE_FEE_GOVERNANCE,
                    PERFORMANCE_FEE_STRATEGIST,
                    WITHDRAWAL_FEE
                ]
            )
        );

        controller.approveStrategy(_token, strategy_);
        controller.setStrategy(_token, strategy_);
    }

    function deployVault(address _token) internal returns (address vault_) {
        require(controller.vaults(_token) == address(0), "already deployed");

        vault_ = deployProxy(
            vaultLogic,
            proxyAdmin,
            abi.encodeWithSignature(
                "initialize(address,address,address,address,address,bool,string,string)",
                _token,
                address(controller),
                governance,
                keeper,
                guardian,
                false,
                "",
                ""
            )
        );
        controller.setVault(_token, vault_);
    }

    function deployProxy(
        address _logic,
        address _admin,
        bytes memory _data
    ) internal returns (address proxy_) {
        proxy_ = address(new AdminUpgradeabilityProxy(_logic, _admin, _data));
    }
}