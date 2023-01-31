/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

// ////-License-Identifier: MIT

pragma solidity 0.8.4;



// Part: IPriceFeed

interface IPriceFeed {
    function initialize(
        uint256 maxSafePriceDifference,
        address stableSwapOracleAddress,
        address curvePoolAddress,
        address admin
    ) external;
}

// Part: OpenZeppelin/[email protected]/Address

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


// Part: StorageSlot

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


// Part: OpenZeppelin/[email protected]/Proxy

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


// Part: OpenZeppelin/[email protected]/ERC1967Proxy

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


// File: PriceFeedProxy.sol

contract PriceFeedProxy is ERC1967Proxy {
    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Initializes the upgradeable proxy with an initial implementation
     *      specified by `priceFeedImpl`, calling its `initialize` function
     *      on the proxy contract state.
     */
    constructor(
        address priceFeedImpl,
        uint256 maxSafePriceDifference,
        address stableSwapOracleAddress,
        address curvePoolAddress,
        address admin
    )
        payable
        ERC1967Proxy(
            priceFeedImpl,
            abi.encodeWithSelector(
                IPriceFeed(address(0)).initialize.selector,
                maxSafePriceDifference,
                stableSwapOracleAddress,
                curvePoolAddress,
                admin
            )
        )
    {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() external view returns (address) {
        return _implementation();
    }

    /**
     * @dev Upgrades the proxy to a new implementation, optionally performing an additional setup call.
     *
     * Emits an {Upgraded} event.
     *
     * @param setupCalldata Data for the setup call. The call is skipped if data is empty.
     */
    function upgradeTo(address newImplementation, bytes memory setupCalldata) external {
        require(msg.sender == _getAdmin(), "ERC1967: unauthorized");
        _upgradeTo(newImplementation);
        if (setupCalldata.length > 0) {
            Address.functionDelegateCall(newImplementation, setupCalldata, "ERC1967: setup failed");
        }
    }

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Returns the current admin of the proxy.
     */
    function getProxyAdmin() external view returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function changeProxyAdmin(address newAdmin) external {
        address admin = _getAdmin();
        require(msg.sender == admin, "ERC1967: unauthorized");
        emit AdminChanged(admin, newAdmin);
        _setAdmin(newAdmin);
    }
}

# : MIT
# @author Lido <info@lido.fi>
# @version 0.2.12


CURVE_ETH_INDEX: constant(uint256) = 0
CURVE_STETH_INDEX: constant(uint256) = 1

# Note: check out the unstructured storage upgrade guide before making changes
# to the variable order after the deployment to prevent storage collisions
# https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#unstructured-storage-proxie

admin: public(address)
max_safe_price_difference: public(uint256)
safe_price_value: public(uint256)
safe_price_timestamp: public(uint256)
curve_pool_address: public(address)
stable_swap_oracle_address: public(address)


interface StableSwap:
    def get_dy(i: int128, j: int128, x: uint256) -> uint256: view


interface StableSwapStateOracle:
    def stethPrice() -> uint256: view


event SafePriceUpdated:
    from_price: uint256
    to_price: uint256

event AdminChanged:
    admin: address

event MaxSafePriceDifferenceChanged:
    max_safe_price_difference: uint256

@external
def initialize(
    max_safe_price_difference: uint256,
    stable_swap_oracle_address: address,
    curve_pool_address: address,
    admin: address
):
    """
    @dev Initializes the feed.

    @param max_safe_price_difference maximum allowed safe price change. 10000 equals to 100%. Max value allowed is 1000 (10%)
    @param admin Contract admin address, that's allowed to change the maximum allowed price change
    @param curve_pool_address Curve stEth/Eth pool address
    @param stable_swap_oracle_address Stable swap oracle address
    """
    assert self.curve_pool_address == ZERO_ADDRESS
    assert max_safe_price_difference <= 1000
    assert stable_swap_oracle_address != ZERO_ADDRESS
    assert curve_pool_address != ZERO_ADDRESS

    self.max_safe_price_difference = max_safe_price_difference
    self.admin = admin
    self.stable_swap_oracle_address = stable_swap_oracle_address
    self.curve_pool_address = curve_pool_address


@view
@internal
def _percentage_diff(new: uint256, old: uint256) -> uint256:
    if new > old :
        return (new - old) * 10000 / old
    else:
        return (old - new) * 10000 / old


@view
@external
def safe_price() -> (uint256, uint256):
    """
    @dev Returns the cached safe price and its timestamp. Reverts if no cached price was set.
    """
    safe_price_timestamp: uint256 = self.safe_price_timestamp
    assert safe_price_timestamp != 0
    return (self.safe_price_value, safe_price_timestamp)


@view
@internal
def _current_price() -> (uint256, bool, uint256):
    pool_price: uint256 = StableSwap(self.curve_pool_address).get_dy(CURVE_STETH_INDEX, CURVE_ETH_INDEX, 10**18)
    oracle_price: uint256 = StableSwapStateOracle(self.stable_swap_oracle_address).stethPrice()
    has_changed_unsafely: bool = self._percentage_diff(pool_price, oracle_price) > self.max_safe_price_difference
    return (pool_price, has_changed_unsafely, oracle_price)


@view
@external
def full_price_info() -> (uint256, bool, uint256):
    """
    @dev Returns the current pool price, whether the price is safe, and the anchor price.
    """
    current_price: uint256 = 0
    has_changed_unsafely: bool = True
    oracle_price: uint256 = 0
    current_price, has_changed_unsafely, oracle_price = self._current_price()
    is_safe: bool = current_price <= 10**18 and not has_changed_unsafely
    return (current_price, is_safe, oracle_price)


@view
@external
def current_price() -> (uint256, bool):
    """
    @dev Returns the current pool price and whether the price is safe.
    """
    current_price: uint256 = 0
    has_changed_unsafely: bool = True
    oracle_price: uint256 = 0
    current_price, has_changed_unsafely, oracle_price = self._current_price()
    is_safe: bool = current_price <= 10**18 and not has_changed_unsafely
    return (current_price, is_safe)


@internal
def _update_safe_price() -> uint256:
    price: uint256 = 0
    has_changed_unsafely: bool = True
    _: uint256 = 0
    price, has_changed_unsafely, _ = self._current_price()
    assert not has_changed_unsafely, "price is not safe"

    price = min(10**18, price)
    log SafePriceUpdated(self.safe_price_value, price)

    self.safe_price_value = price
    self.safe_price_timestamp = block.timestamp

    return price


@external
def update_safe_price() -> uint256:
    """
    @dev Sets the cached safe price to the current pool price.

    If the price is higher than 10**18, sets the cached safe price to 10**18.
    If the price is not safe for any other reason, reverts.
    """
    return self._update_safe_price()


@external
def fetch_safe_price(max_age: uint256) -> (uint256, uint256):
    """
    @dev Returns the cached safe price and its timestamp.

    Calls `update_safe_price()` prior to that if the cached safe price
    is older than `max_age` seconds.
    """
    safe_price_timestamp: uint256 = self.safe_price_timestamp
    if safe_price_timestamp == 0 or block.timestamp - safe_price_timestamp > max_age:
        price: uint256 = self._update_safe_price()
        return (price, block.timestamp)
    else:
        return (self.safe_price_value, safe_price_timestamp)


@external
def set_admin(admin: address):
    """
    @dev Updates the admin address.

    May only be called by the current admin.
    """
    assert msg.sender == self.admin
    self.admin = admin
    log AdminChanged(admin)


@external
def set_max_safe_price_difference(max_safe_price_difference: uint256):
    """
    @dev Updates the maximum difference between the safe price and the time-shifted price.

    May only be called by the admin.
    Maximal difference accepted is 10% (1000)
    """
    assert msg.sender == self.admin
    assert max_safe_price_difference <= 1000
    self.max_safe_price_difference = max_safe_price_difference
    log MaxSafePriceDifferenceChanged(max_safe_price_difference)
}
