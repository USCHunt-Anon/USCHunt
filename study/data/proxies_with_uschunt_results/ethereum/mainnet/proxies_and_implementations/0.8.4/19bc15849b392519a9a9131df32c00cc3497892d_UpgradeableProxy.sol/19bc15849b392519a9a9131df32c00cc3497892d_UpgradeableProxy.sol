/**
 *Submitted for verification at Etherscan.io on 2021-09-09
*/

// ////-License-Identifier: MIT

pragma solidity 0.8.4;


////////////////////////////////////////////////////////////////////////////////////////////////////
/// PART: OpenZeppelin/[email protected]/contracts/utils/Address.sol ////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

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
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/// PART: OpenZeppelin/[email protected]/contracts/proxy/Proxy.sol //////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

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
        // solhint-disable-next-line no-inline-assembly
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
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
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
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/// PART: OpenZeppelin/[email protected]/contracts/proxy/ERC1967/ERC1967Proxy.sol ///////
////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 *
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract ERC1967Proxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            Address.functionDelegateCall(_logic, _data);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal virtual {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967Proxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
/// PART: UpgradeableProxy.sol /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * @dev Copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/StorageSlot.sol
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev An ossifiable proxy.
 */
contract UpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Storage slot with the admin of the contract.
     *
     * Equals `bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)`.
     */
    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Initializes the upgradeable proxy with the initial implementation and admin.
     */
    constructor(address implementation, address admin)
        ERC1967Proxy(implementation, new bytes(0))
    {
        _setAdmin(admin);
    }

    /**
     * @return Returns the current implementation address.
     */
    function implementation() external view returns (address) {
        return _implementation();
    }

    /**
     * @dev Upgrades the proxy to a new implementation, optionally performing an additional
     * setup call.
     *
     * Can only be called by the proxy admin until the proxy is ossified.
     * Cannot be called after the proxy is ossified.
     *
     * Emits an {Upgraded} event.
     *
     * @param setupCalldata Data for the setup call. The call is skipped if data is empty.
     */
    function proxy_upgradeTo(address newImplementation, bytes memory setupCalldata) external {
        address admin = _getAdmin();
        require(admin != address(0), "proxy: ossified");
        require(msg.sender == admin, "proxy: unauthorized");

        _upgradeTo(newImplementation);

        if (setupCalldata.length > 0) {
            Address.functionDelegateCall(newImplementation, setupCalldata, "proxy: setup failed");
        }
    }

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Returns the current admin of the proxy.
     */
    function proxy_getAdmin() external view returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function proxy_changeAdmin(address newAdmin) external {
        address admin = _getAdmin();
        require(admin != address(0), "proxy: ossified");
        require(msg.sender == admin, "proxy: unauthorized");
        emit AdminChanged(admin, newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Returns whether the implementation is locked forever.
     */
    function proxy_getIsOssified() external view returns (bool) {
        return _getAdmin() == address(0);
    }
}

# @version 0.2.15
# @author skozin
# @licence MIT

interface LidoOracle:
    def getLastCompletedEpochId() -> uint256: view
    def getBeaconSpec() -> (uint256, uint256, uint256, uint256): view

interface LidoNodeOperators:
    def getNodeOperatorsCount() -> uint256: view
    def getNodeOperator(id: uint256, full_info: bool) -> (bool, String[100], address, uint256, uint256, uint256, uint256): view

interface AnchorVault:
    def last_liquidation_time() -> uint256: view

interface WstETH:
    def getStETHByWstETH(wstETHAmount: uint256) -> uint256: view

interface CurveStableSwap:
    def balances(i: uint256) -> uint256: view


LIDO_ORACLE: constant(address) = 0x442af784A788A5bd6F42A01Ebe9F287a871243fb
LIDO_NODE_OPS_REGISTRY: constant(address) = 0x55032650b14df07b85bF18A3a3eC8E0Af2e028d5
ANCHOR_VAULT: constant(address) = 0xA2F987A546D4CD1c607Ee8141276876C26b72Bdf
CURVE_STETH_POOL: constant(address) = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
WSTETH_TOKEN: constant(address) = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0
BALANCER_VAULT: constant(address) = 0xBA12222222228d8Ba445958a75a0704d566BF2C8
BALANCER_POOL_ID: constant(bytes32) = 0x32296969ef14eb0c6d29669c550d4a0449130230000200000000000000000080


admin: public(address)


@external
def __init__():
    self.admin = msg.sender


@external
def set_admin(new_admin: address):
    assert msg.sender == self.admin # dev: unauthorized
    self.admin = new_admin


@external
def kill():
    assert msg.sender == self.admin # dev: unauthorized
    selfdestruct(msg.sender)


@internal
@view
def _get_node_op_spare_keys_count(id: uint256) -> uint256:
    active: bool = False
    name: String[100] = ""
    reward_address: address = ZERO_ADDRESS
    staking_limit: uint256 = 0
    stopped_validators: uint256 = 0
    total_signing_keys: uint256 = 0
    used_signing_keys: uint256 = 0

    (active, name, reward_address, staking_limit,
        stopped_validators,
        total_signing_keys,
        used_signing_keys) = LidoNodeOperators(LIDO_NODE_OPS_REGISTRY).getNodeOperator(id, False)

    if (not active) or (staking_limit <= used_signing_keys):
        return 0

    return min(total_signing_keys, staking_limit) - used_signing_keys

@external
@view
def get_node_op_spare_keys_count(id: uint256) -> uint256:
    return self._get_node_op_spare_keys_count(id)


@external
@view
def spare_signing_keys_count() -> uint256:
    total_ops: uint256 = LidoNodeOperators(LIDO_NODE_OPS_REGISTRY).getNodeOperatorsCount()
    spare_keys: uint256 = 0
    for i in range(300):
        if i >= total_ops:
            break
        spare_keys += self._get_node_op_spare_keys_count(i)
    return spare_keys


@internal
@view
def _last_reported_epoch_time() -> uint256:
    _: uint256 = 0
    slots_per_epoch: uint256 = 0
    seconds_per_slot: uint256 = 0
    genesis_time: uint256 = 0
    (_, slots_per_epoch, seconds_per_slot, genesis_time) = LidoOracle(LIDO_ORACLE).getBeaconSpec()
    epoch_id: uint256 = LidoOracle(LIDO_ORACLE).getLastCompletedEpochId()
    return genesis_time + epoch_id * slots_per_epoch * seconds_per_slot

@external
@view
def last_reported_epoch_time() -> uint256:
    return self._last_reported_epoch_time()

@external
@view
def time_since_last_reported_epoch() -> uint256:
    return block.timestamp - self._last_reported_epoch_time()


@internal
@view
def _last_rewards_liquidation_time() -> uint256:
    return AnchorVault(ANCHOR_VAULT).last_liquidation_time()

@external
@view
def last_rewards_liquidation_time() -> uint256:
    return self._last_rewards_liquidation_time()


@external
@view
def time_since_last_liquidation() -> uint256:
    last_liquidation_at: uint256 = self._last_rewards_liquidation_time()
    return block.timestamp - last_liquidation_at


@internal
@view
def _time_without_liquidation_since_reported_epoch() -> uint256:
    reported_epoch_time: uint256 = self._last_reported_epoch_time()
    last_liquidation_at: uint256 = self._last_rewards_liquidation_time()
    if last_liquidation_at > reported_epoch_time:
        return 0
    return block.timestamp - reported_epoch_time

@external
@view
def time_without_liquidation_since_reported_epoch() -> uint256:
    return self._time_without_liquidation_since_reported_epoch()


@external
@view
def curve_pool_size() -> uint256:
    eth_balance: uint256 = CurveStableSwap(CURVE_STETH_POOL).balances(0)
    steth_balance: uint256 = CurveStableSwap(CURVE_STETH_POOL).balances(1)
    return eth_balance + steth_balance


@internal
@pure
def _calc_imbalance(eth_balance: uint256, steth_balance: uint256) -> int256:
    if steth_balance >= eth_balance:
        return convert((steth_balance * 10**18) / eth_balance - 10**18, int256)
    else:
        return -convert((eth_balance * 10**18) / steth_balance - 10**18, int256)


@external
@view
def curve_pool_imbalance_percent() -> int256:
    """
    @dev Value between -10**18 (only ETH in pool) to 10**18 (only stETH in pool).
    """
    eth_balance: uint256 = CurveStableSwap(CURVE_STETH_POOL).balances(0)
    steth_balance: uint256 = CurveStableSwap(CURVE_STETH_POOL).balances(1)
    return self._calc_imbalance(eth_balance, steth_balance)


@internal
@view
def _balancer_get_balances() -> (uint256, uint256):
    result: Bytes[32 * 9] = raw_call(
        BALANCER_VAULT,
        concat(method_id("getPoolTokens(bytes32)"), BALANCER_POOL_ID),
        max_outsize = 32 * 9,
        is_static_call = True
    )
    # the return type is (tokens address[], balances uint256[], lastChangeBlock uint256)
    # and there are two items in each array
    wsteth_balance: uint256 = convert(extract32(result, 32*7), uint256)
    eth_balance: uint256 = convert(extract32(result, 32*8), uint256)
    return (wsteth_balance, eth_balance)


@external
@view
def balancer_pool_size() -> uint256:
    wsteth_balance: uint256 = 0
    eth_balance: uint256 = 0
    (wsteth_balance, eth_balance) = self._balancer_get_balances()
    return wsteth_balance + eth_balance


@external
@view
def balancer_pool_imbalance_percent() -> int256:
    wsteth_balance: uint256 = 0
    eth_balance: uint256 = 0
    (wsteth_balance, eth_balance) = self._balancer_get_balances()
    steth_balance: uint256 = WstETH(WSTETH_TOKEN).getStETHByWstETH(wsteth_balance)
    return self._calc_imbalance(eth_balance, steth_balance)
}
