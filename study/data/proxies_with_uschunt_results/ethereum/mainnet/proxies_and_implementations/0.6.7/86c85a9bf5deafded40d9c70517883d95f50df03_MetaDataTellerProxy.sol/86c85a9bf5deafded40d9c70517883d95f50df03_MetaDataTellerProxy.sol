/**
 *Submitted for verification at Etherscan.io on 2021-03-25
*/

// Verified by Darwinia Network

// hevm: flattened sources of src/MetaDataTellerProxy.sol
pragma solidity >=0.6.0 <0.7.0 >=0.6.2 <0.7.0 >=0.6.7 <0.7.0;

////// lib/zeppelin-solidity/src/proxy/Proxy.sol
// ////-License-Identifier: MIT

/* pragma solidity ^0.6.0; */

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
    function _delegate(address implementation) internal {
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
    function _implementation() internal virtual view returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () payable external {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () payable external {
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

////// lib/zeppelin-solidity/src/utils/Address.sol
// ////-License-Identifier: MIT

/* pragma solidity ^0.6.2; */

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
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
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

////// lib/zeppelin-solidity/src/proxy/UpgradeableProxy.sol
// ////-License-Identifier: MIT

/* pragma solidity ^0.6.0; */

/* //import "./Proxy.sol"; */
/* //import "../utils/Address.sol"; */

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 * 
 * Upgradeability is only provided internally through {_upgradeTo}. For an externally upgradeable proxy see
 * {TransparentUpgradeableProxy}.
 */
contract UpgradeableProxy is Proxy {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     * 
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) public payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if(_data.length > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = _logic.delegatecall(_data);
            require(success);
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
    function _implementation() internal override view returns (address impl) {
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
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
}

////// lib/zeppelin-solidity/src/proxy/TransparentUpgradeableProxy.sol
// ////-License-Identifier: MIT

/* pragma solidity ^0.6.0; */

/* //import "./UpgradeableProxy.sol"; */

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 * 
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 * 
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 * 
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 * 
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is UpgradeableProxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {UpgradeableProxy-constructor}.
     */
    constructor(address _logic, address _admin, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
    }

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     * 
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address) {
        return _admin();
    }

    /**
     * @dev Returns the current implementation.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     * 
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address) {
        return _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     * 
     * Emits an {AdminChanged} event.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     * 
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeTo(newImplementation);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = newImplementation.delegatecall(data);
        require(success);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            adm := sload(slot)
        }
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newAdmin)
        }
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal override virtual {
        require(msg.sender != _admin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

////// src/MetaDataTellerProxy.sol
/* pragma solidity ^0.6.7; */

/* //import "zeppelin-solidity/proxy/TransparentUpgradeableProxy.sol"; */

contract MetaDataTellerProxy is TransparentUpgradeableProxy {
	constructor(
		address _logic,
		address _admin,
		bytes memory _data
	) public payable TransparentUpgradeableProxy(_logic, _admin, _data) {}
}

// Verified by Darwinia Network

// hevm: flattened sources of src/MetaDataTeller.sol
pragma solidity >0.4.13 >=0.4.23 >=0.4.24 <0.7.0 >=0.6.7 <0.7.0;

////// lib/ds-auth/src/auth.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >=0.4.23; */

interface DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) external view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// lib/zeppelin-solidity/src/proxy/Initializable.sol
// : MIT

// solhint-disable-next-line compiler-version
/* pragma solidity >=0.4.24 <0.7.0; */


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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

////// src/FurnaceSettingIds.sol
/* pragma solidity ^0.6.7; */

contract FurnaceSettingIds {
	uint256 public constant PREFER_GOLD = 1 << 1;
	uint256 public constant PREFER_WOOD = 1 << 2;
	uint256 public constant PREFER_WATER = 1 << 3;
	uint256 public constant PREFER_FIRE = 1 << 4;
	uint256 public constant PREFER_SOIL = 1 << 5;

	uint8 public constant DRILL_OBJECT_CLASS = 4; // Drill
	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant DARWINIA_OBJECT_CLASS = 254; // Darwinia

	//0x4655524e4143455f415050000000000000000000000000000000000000000000
	bytes32 public constant FURNACE_APP = "FURNACE_APP";

	//0x4655524e4143455f4954454d5f4d494e455f4645450000000000000000000000
	bytes32 public constant FURNACE_ITEM_MINE_FEE = "FURNACE_ITEM_MINE_FEE";

	uint128 public constant RATE_PRECISION = 10**8;

	// 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
	bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER =
		"CONTRACT_INTERSTELLAR_ENCODER";

	// 0x434f4e54524143545f4c414e445f4954454d5f42415200000000000000000000
	bytes32 public constant CONTRACT_LAND_ITEM_BAR = "CONTRACT_LAND_ITEM_BAR";

	// 0x434f4e54524143545f41504f53544c455f4954454d5f42415200000000000000
	bytes32 public constant CONTRACT_APOSTLE_ITEM_BAR =
		"CONTRACT_APOSTLE_ITEM_BAR";

	// 0x434f4e54524143545f4954454d5f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_ITEM_BASE = "CONTRACT_ITEM_BASE";

	// 0x434f4e54524143545f4452494c4c5f4241534500000000000000000000000000
	bytes32 public constant CONTRACT_DRILL_BASE = "CONTRACT_DRILL_BASE";

	// 0x434f4e54524143545f44415257494e49415f49544f5f42415345000000000000
	bytes32 public constant CONTRACT_DARWINIA_ITO_BASE = "CONTRACT_DARWINIA_ITO_BASE";

	// 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
	bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

	// 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
	bytes32 public constant CONTRACT_OBJECT_OWNERSHIP =
		"CONTRACT_OBJECT_OWNERSHIP";

	// 0x434f4e54524143545f4552433732315f4745474f000000000000000000000000
	bytes32 public constant CONTRACT_ERC721_GEGO = "CONTRACT_ERC721_GEGO";

	// 0x434f4e54524143545f464f524d554c4100000000000000000000000000000000
	bytes32 public constant CONTRACT_FORMULA = "CONTRACT_FORMULA";

	// 0x434f4e54524143545f4d455441444154415f54454c4c45520000000000000000
	bytes32 public constant CONTRACT_METADATA_TELLER =
		"CONTRACT_METADATA_TELLER";

	//0x434f4e54524143545f4c505f454c454d454e545f544f4b454e00000000000000
	bytes32 public constant CONTRACT_LP_ELEMENT_TOKEN = 
		"CONTRACT_LP_ELEMENT_TOKEN";

	// 0x434f4e54524143545f4c505f474f4c445f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_GOLD_ERC20_TOKEN =
		"CONTRACT_LP_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f574f4f445f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_WOOD_ERC20_TOKEN =
		"CONTRACT_LP_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f57415445525f45524332305f544f4b454e000000
	bytes32 public constant CONTRACT_LP_WATER_ERC20_TOKEN =
		"CONTRACT_LP_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f464952455f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_FIRE_ERC20_TOKEN =
		"CONTRACT_LP_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f4c505f534f494c5f45524332305f544f4b454e00000000
	bytes32 public constant CONTRACT_LP_SOIL_ERC20_TOKEN =
		"CONTRACT_LP_SOIL_ERC20_TOKEN";

	// 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_RING_ERC20_TOKEN =
		"CONTRACT_RING_ERC20_TOKEN";

	// 0x434f4e54524143545f4b544f4e5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_KTON_ERC20_TOKEN =
		"CONTRACT_KTON_ERC20_TOKEN";

	//0x434f4e54524143545f454c454d454e545f544f4b454e00000000000000000000
	bytes32 public constant CONTRACT_ELEMENT_TOKEN = 
		"CONTRACT_ELEMENT_TOKEN";

	// 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN =
		"CONTRACT_GOLD_ERC20_TOKEN";

	// 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN =
		"CONTRACT_WOOD_ERC20_TOKEN";

	// 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
	bytes32 public constant CONTRACT_WATER_ERC20_TOKEN =
		"CONTRACT_WATER_ERC20_TOKEN";

	// 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN =
		"CONTRACT_FIRE_ERC20_TOKEN";

	// 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
	bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN =
		"CONTRACT_SOIL_ERC20_TOKEN";
}

////// src/interfaces/IELIP002.sol
/* pragma solidity ^0.6.7; */

/**
@title IELIP002
@dev See https://github.com/evolutionlandorg/furnace/blob/main/elip-002.md
@author echo.hu@itering.com
*/
interface IELIP002 {
	struct Item {
		// index of `Formula`
		uint256 index;
		//  strength rate
		uint128 rate;
		uint16 objClassExt;
		uint16 class;
		uint16 grade;
		// element prefer
		uint16 prefer;
		//  major material
		address major;
		uint256 id;
		// amount of minor material
		address minor;
		uint256 amount;
	}

	/**
        @dev `Enchanted` MUST emit when item is enchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the enchant (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is enchanted.
        The `index` argument MUST be index of the `Formula`.
        The `rate` argument MUST be rate of minor material.
        The `objClassExt` argument MUST be extension of `ObjectClass`.
        The `class` argument MUST be class of the item.
        The `grade` argument MUST be grade of the item.
        The `prefer` argument MUST be prefer of the item.
        The `major` argument MUST be token address of major material.
        The `id` argument MUST be token id of major material.
        The `minor` argument MUST be token address of minor material.
        The `amount` argument MUST be token amount of minor material.
        The `now` argument MUST be timestamp of enchant.
    */
	event Enchanced(
		address indexed user,
		uint256 indexed tokenId,
		uint256 index,
		uint128 rate,
		uint16 objClassExt,
		uint16 class,
		uint16 grade,
		uint16 prefer,
		address major,
		uint256 id,
		address minor,
		uint256 amount,
		uint256 now
	);

	/**
        @dev `Disenchanted` MUST emit when item is disenchanted.
        The `user` argument MUST be the address of an account/contract that is approved to make the disenchanted (SHOULD be msg.sender).
        The `tokenId` argument MUST be token Id of the item which it is disenchated.
        The `majors` argument MUST be major token addresses of major material.
        The `id` argument MUST be token ids of major material.
        The `minor` argument MUST be token addresses of minor material.
        The `amount` argument MUST be token amounts of minor material.
    */
	event Disenchanted(
		address indexed user,
		uint256 tokenId,
		address major,
		uint256 id,
		address minor,
		uint256 amount
	);

	/**
        @notice Caller must be owner of tokens to enchant.
        @dev Enchant function, Enchant a new NFT token from ERC721 tokens and ERC20 tokens. Enchant rule is according to `Formula`.
        MUST revert if `_index` is not in `formula`.
        MUST revert on any other error.        
		@param _index  Index of formula to enchant.
        @param _id     ID of NFT tokens.
        @param _token  Address of FT token.
		@return {
			"tokenId": "New Token ID of Enchanting."
		}
    */
	function enchant(
		uint256 _index,
		uint256 _id,
		address _token
	) external returns (uint256);

	// {
	// 	### smelt
	// 	1. check Formula rule by index
	//  2. transfer FT and NFT to address(this)
	// 	3. track FTs NFT to new NFT
	// 	4. mint new NFT to caller
	// }

	/**
        @notice Caller must be owner of token id to disenchat.
        @dev Disenchant function, A enchanted NFT can be disenchanted into origin ERC721 tokens and ERC20 tokens recursively.
        MUST revert on any other error.        
        @param _id     Token ID to disenchant.
        @param _depth   Depth of disenchanting recursively.
    */
	function disenchant(uint256 _id, uint256 _depth) external;

	// {
	// 	### disenchant
	//  1. tranfer _id to address(this)
	// 	2. burn new NFT
	// 	3. delete track FTs NFTs to new NFT
	// 	4. transfer FNs NFTs to owner
	// }

	/**
        @dev Get base info of item.
        @param _tokenId Token id of item.
		@return {
			"objClassExt": "Extension of `ObjectClass`.",
			"class": "Class of the item.",
			"grade": "Grade of the item."
		}
    */
	function getBaseInfo(uint256 _tokenId)
		external
		view
		returns (
			uint16,
			uint16,
			uint16
		);

	/**
        @dev Get rate of item.
        @param _tokenId Token id of item.
        @param _element Element item prefer.
		@return {
			"rate": "strength rate of item."
		}
    */
	function getRate(uint256 _tokenId, uint256 _element)
		external
		view
		returns (uint256);

	function getPrefer(uint256 _tokenId)
		external
		view
		returns (uint16);

	function getObjectClassExt(uint256 _tokenId) 
		external	
		view
		returns (uint16);
}

////// src/interfaces/IInterstellarEncoder.sol
/* pragma solidity ^0.6.7; */

interface IInterstellarEncoder {
	function registerNewObjectClass(address _objectContract, uint8 objectClass)
		external;

	function encodeTokenId(
		address _tokenAddress,
		uint8 _objectClass,
		uint128 _objectIndex
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForObjectContract(
		address _tokenAddress,
		address _objectContract,
		uint128 _objectId
	) external view returns (uint256 _tokenId);

	function encodeTokenIdForOuterObjectContract(
		address _objectContract,
		address nftAddress,
		address _originNftAddress,
		uint128 _objectId,
		uint16 _producerId,
		uint8 _convertType
	) external view returns (uint256);

	function getContractAddress(uint256 _tokenId)
		external
		view
		returns (address);

	function getObjectId(uint256 _tokenId)
		external
		view
		returns (uint128 _objectId);

	function getObjectClass(uint256 _tokenId) external view returns (uint8);

	function getObjectAddress(uint256 _tokenId) external view returns (address);

	function getProducerId(uint256 _tokenId) external view returns (uint16);

	function getOriginAddress(uint256 _tokenId) external view returns (address);
}

////// src/interfaces/ILandBase.sol
/* pragma solidity ^0.6.7; */

interface ILandBase { 
    function resourceToken2RateAttrId(address _resourceToken) external view returns (uint256);
}

////// src/interfaces/ISettingsRegistry.sol
/* pragma solidity ^0.6.7; */

interface ISettingsRegistry {
    function uintOf(bytes32 _propertyName) external view returns (uint256);

    function stringOf(bytes32 _propertyName) external view returns (string memory);

    function addressOf(bytes32 _propertyName) external view returns (address);

    function bytesOf(bytes32 _propertyName) external view returns (bytes memory);

    function boolOf(bytes32 _propertyName) external view returns (bool);

    function intOf(bytes32 _propertyName) external view returns (int);

    function setUintProperty(bytes32 _propertyName, uint _value) external;

    function setStringProperty(bytes32 _propertyName, string calldata _value) external;

    function setAddressProperty(bytes32 _propertyName, address _value) external;

    function setBytesProperty(bytes32 _propertyName, bytes calldata _value) external;

    function setBoolProperty(bytes32 _propertyName, bool _value) external;

    function setIntProperty(bytes32 _propertyName, int _value) external;

    function getValueTypeOf(bytes32 _propertyName) external view returns (uint /* SettingsValueTypes */ );

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}

////// src/interfaces/IUniswapV2Pair.sol
/* pragma solidity ^0.6.7; */

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);


    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    // solhint-disable-next-line func-name-mixedcase
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    // solhint-disable-next-line func-name-mixedcase
    event Sync(uint112 reserve0, uint112 reserve1);

    // solhint-disable-next-line func-name-mixedcase
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

////// src/MetaDataTeller.sol
/* pragma solidity ^0.6.7; */

/* //import"ds-math/math.sol"; */
/* //import"ds-auth/auth.sol"; */
/* //import"zeppelin-solidity/proxy/Initializable.sol"; */
/* //import"./interfaces/ISettingsRegistry.sol"; */
/* //import"./interfaces/IUniswapV2Pair.sol"; */
/* //import"./interfaces/IELIP002.sol"; */
/* //import"./interfaces/IInterstellarEncoder.sol"; */
/* //import"./interfaces/ILandBase.sol"; */
/* //import"./interfaces/IELIP002.sol"; */
/* //import"./FurnaceSettingIds.sol"; */

contract MetaDataTeller is Initializable, DSAuth, DSMath, FurnaceSettingIds {
	event AddLPToken(bytes32 _class, address _lpToken, uint8 _resourceId);
	event AddInternalTokenMeta(
		bytes32 indexed token,
		uint16 grade,
		uint256 trengthRate
	);
	event AddExternalTokenMeta(
		address indexed token,
		uint16 objectClassExt,
		uint16 grade,
		uint256 trengthRate
	);
	event RemoveLPToken(bytes32 _class, address _lpToken);
	event RemoveExternalTokenMeta(address indexed token);
	event RemoveInternalTokenMeta(bytes32 indexed token, uint16 grade);

	struct Meta {
		uint16 objectClassExt;
		mapping(uint16 => uint256) grade2StrengthRate;
	}

	uint16 internal constant _EXTERNAL_DEFAULT_CLASS = 0;
	uint16 internal constant _EXTERNAL_DEFAULT_GRADE = 1;

	ISettingsRegistry public registry;
	/**
	 * @dev mapping from resource lptoken address to resource atrribute rate id.
	 * atrribute rate id starts from 1 to 15, NAN is 0.
	 * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
	 */
	// (ID => (LP_TOKENA_TOKENB => resourceId))
	mapping(bytes32 => mapping(address => uint8))
		public resourceLPToken2RateAttrId;
	mapping(address => Meta) public externalToken2Meta;
	mapping(bytes32 => mapping(uint16 => uint256)) public internalToken2Meta;

	function initialize(address _registry) public initializer {
		owner = msg.sender;
		emit LogSetOwner(msg.sender);
		registry = ISettingsRegistry(_registry);

		resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
			registry.addressOf(CONTRACT_LP_GOLD_ERC20_TOKEN)
		] = 1;
		resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
			registry.addressOf(CONTRACT_LP_WOOD_ERC20_TOKEN)
		] = 2;
		resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
			registry.addressOf(CONTRACT_LP_WATER_ERC20_TOKEN)
		] = 3;
		resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
			registry.addressOf(CONTRACT_LP_FIRE_ERC20_TOKEN)
		] = 4;
		resourceLPToken2RateAttrId[CONTRACT_LP_ELEMENT_TOKEN][
			registry.addressOf(CONTRACT_LP_SOIL_ERC20_TOKEN)
		] = 5;
	}

	function addLPToken(
		bytes32 _id,
		address _lpToken,
		uint8 _resourceId
	) public auth {
		require(
			_resourceId > 0 && _resourceId < 6,
			"Furnace: INVALID_RESOURCEID"
		);
		resourceLPToken2RateAttrId[_id][_lpToken] = _resourceId;
		emit AddLPToken(_id, _lpToken, _resourceId);
	}

	function addInternalTokenMeta(
		bytes32 _token,
		uint16 _grade,
		uint256 _strengthRate
	) public auth {
		internalToken2Meta[_token][_grade] = _strengthRate;
		emit AddInternalTokenMeta(_token, _grade, _strengthRate);
	}

	function addExternalTokenMeta(
		address _token,
		uint16 _objectClassExt,
		uint16 _grade,
		uint256 _strengthRate
	) public auth {
		require(_objectClassExt > 0, "Furnace: INVALID_OBJCLASSEXT");
		externalToken2Meta[_token].objectClassExt = _objectClassExt;
		externalToken2Meta[_token].grade2StrengthRate[_grade] = _strengthRate;
		emit AddExternalTokenMeta(
			_token,
			_objectClassExt,
			_grade,
			_strengthRate
		);
	}

	function removeLPToken(bytes32 _id, address _lpToken) public auth {
		require(
			resourceLPToken2RateAttrId[_id][_lpToken] > 0,
			"Furnace: EMPTY"
		);
		delete resourceLPToken2RateAttrId[_id][_lpToken];
		emit RemoveLPToken(_id, _lpToken);
	}

	function removeExternalTokenMeta(address _token) public auth {
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: EMPTY"
		);
		delete externalToken2Meta[_token];
		emit RemoveExternalTokenMeta(_token);
	}

	function removeInternalTokenMeta(bytes32 _token, uint16 _grade)
		public
		auth
	{
		delete internalToken2Meta[_token][_grade];
		emit RemoveInternalTokenMeta(_token, _grade);
	}

	function getExternalObjectClassExt(address _token)
		public
		view
		returns (uint16)
	{
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: NOT_SUPPORT"
		);
		return externalToken2Meta[_token].objectClassExt;
	}

	function getExternalStrengthRate(address _token, uint16 _grade)
		public
		view
		returns (uint256)
	{
		require(
			externalToken2Meta[_token].objectClassExt > 0,
			"Furnace: NOT_SUPPORT"
		);
		return uint256(externalToken2Meta[_token].grade2StrengthRate[_grade]);
	}

	function getInternalStrengthRate(bytes32 _token, uint16 _grade)
		public
		view
		returns (uint256)
	{
        require(internalToken2Meta[_token][_grade] > 0, "Furnace: NOT_SUPPORT");
		return uint256(internalToken2Meta[_token][_grade]);
	}

	function getMetaData(address _token, uint256 _id)
		public
		view
		returns (
			uint16,
			uint16,
			uint16
		)
	{
		if (_token == registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)) {
			uint8 objectClass =
				IInterstellarEncoder(
					registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)
				)
					.getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return
					IELIP002(registry.addressOf(CONTRACT_ITEM_BASE))
						.getBaseInfo(_id);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				return (
					objectClass,
					_EXTERNAL_DEFAULT_CLASS,
					getDrillGrade(_id)
				);
			} 
		}
		// external token
		return (
			getExternalObjectClassExt(_token),
			_EXTERNAL_DEFAULT_CLASS,
			_EXTERNAL_DEFAULT_GRADE
		);
	}

	function getDrillGrade(uint256 _tokenId) public pure returns (uint16) {
		uint128 objectId = uint128(_tokenId);
		return uint16(objectId >> 112);
	}

	function getPrefer(bytes32 _minor, address _token)
		external
		view
		returns (uint256)
	{
		if (_minor == CONTRACT_ELEMENT_TOKEN) {
			return
				ILandBase(registry.addressOf(CONTRACT_LAND_BASE))
					.resourceToken2RateAttrId(_token);
		} else {
			return resourceLPToken2RateAttrId[_minor][_token];
		}
	}

	function getRate(
		address _token,
		uint256 _id,
		uint256 _element
	) external view returns (uint256) {
		if (_token == address(0)) {
			return 0;
		}
		if (_token == registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)) {
			uint8 objectClass =
				IInterstellarEncoder(
					registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)
				)
					.getObjectClass(_id);
			if (objectClass == ITEM_OBJECT_CLASS) {
				return
					IELIP002(registry.addressOf(CONTRACT_ITEM_BASE)).getRate(
						_id,
						_element
					);
			} else if (objectClass == DRILL_OBJECT_CLASS) {
				uint16 grade = getDrillGrade(_id);
				return getInternalStrengthRate(CONTRACT_DRILL_BASE, grade);
			} 
		}
		return getExternalStrengthRate(_token, _EXTERNAL_DEFAULT_GRADE);
	}
}

}
