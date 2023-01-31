/**
 *Submitted for verification at polygonscan.com on 2021-08-26
*/

// Verified by Darwinia Network

// hevm: flattened sources of src/proxy/LandBaseProxy.sol

pragma solidity >=0.6.0 <0.8.0 >=0.6.2 <0.8.0 >=0.6.7 <0.7.0;

////// lib/zeppelin-solidity/contracts/proxy/Proxy.sol

/* pragma solidity >=0.6.0 <0.8.0; */

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
    fallback () external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable {
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

////// lib/zeppelin-solidity/contracts/utils/Address.sol

/* pragma solidity >=0.6.2 <0.8.0; */

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

////// lib/zeppelin-solidity/contracts/proxy/UpgradeableProxy.sol

/* pragma solidity >=0.6.0 <0.8.0; */

/* ////import "./Proxy.sol"; */
/* ////import "../utils/Address.sol"; */

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

////// lib/zeppelin-solidity/contracts/proxy/TransparentUpgradeableProxy.sol

/* pragma solidity >=0.6.0 <0.8.0; */

/* ////import "./UpgradeableProxy.sol"; */

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
    constructor(address _logic, address admin_, bytes memory _data) public payable UpgradeableProxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(admin_);
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
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _admin();
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
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
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

////// src/proxy/LandBaseProxy.sol
/* pragma solidity ^0.6.7; */

/* ////import "zeppelin-solidity/proxy/TransparentUpgradeableProxy.sol"; */

contract LandBaseProxy is TransparentUpgradeableProxy {
	constructor(
		address _logic,
		address _admin,
		bytes memory _data
	) public payable TransparentUpgradeableProxy(_logic, _admin, _data) {}
}

// Verified by Darwinia Network

// hevm: flattened sources of contracts/LandBaseV2.sol

pragma solidity >=0.4.24 <0.5.0;

////// contracts/interfaces/ILandBase.sol
/* pragma solidity ^0.4.24; */

contract ILandBase {

    /*
     *  Event
     */
    event ModifiedResourceRate(uint indexed tokenId, address resourceToken, uint16 newResourceRate);
    event HasboxSetted(uint indexed tokenId, bool hasBox);

    event ChangedReourceRateAttr(uint indexed tokenId, uint256 attr);

    event ChangedFlagMask(uint indexed tokenId, uint256 newFlagMask);

    event CreatedNewLand(uint indexed tokenId, int x, int y, address beneficiary, uint256 resourceRateAttr, uint256 mask);

    function defineResouceTokenRateAttrId(address _resourceToken, uint8 _attrId) public;

    function setHasBox(uint _landTokenID, bool isHasBox) public;
    function isReserved(uint256 _tokenId) public view returns (bool);
    function isSpecial(uint256 _tokenId) public view returns (bool);
    function isHasBox(uint256 _tokenId) public view returns (bool);

    function getResourceRateAttr(uint _landTokenId) public view returns (uint256);
    function setResourceRateAttr(uint _landTokenId, uint256 _newResourceRateAttr) public;

    function getResourceRate(uint _landTokenId, address _resouceToken) public view returns (uint16);
    function setResourceRate(uint _landTokenID, address _resourceToken, uint16 _newResouceRate) public;

    function getFlagMask(uint _landTokenId) public view returns (uint256);

    function setFlagMask(uint _landTokenId, uint256 _newFlagMask) public;

}

////// lib/common-contracts/contracts/interfaces/IAuthority.sol
/* pragma solidity ^0.4.24; */

contract IAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

////// lib/common-contracts/contracts/DSAuth.sol
/* pragma solidity ^0.4.24; */

/* //import'./interfaces/IAuthority.sol'; */

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

/**
 * @title DSAuth
 * @dev The DSAuth contract is reference implement of https://github.com/dapphub/ds-auth
 * But in the isAuthorized method, the src from address(this) is remove for safty concern.
 */
contract DSAuth is DSAuthEvents {
    IAuthority   public  authority;
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

    function setAuthority(IAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == owner) {
            return true;
        } else if (authority == IAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

////// lib/common-contracts/contracts/LocationCoder.sol
/* pragma solidity ^0.4.24; */

library LocationCoder {
    // the allocation of the [x, y, z] is [0<1>, x<21>, y<21>, z<21>]
    uint256 constant CLEAR_YZ = 0x0fffffffffffffffffffff000000000000000000000000000000000000000000;
    uint256 constant CLEAR_XZ = 0x0000000000000000000000fffffffffffffffffffff000000000000000000000;
    uint256 constant CLEAR_XY = 0x0000000000000000000000000000000000000000000fffffffffffffffffffff;

    uint256 constant NOT_ZERO = 0x1000000000000000000000000000000000000000000000000000000000000000;
    uint256 constant APPEND_HIGH =  0xfffffffffffffffffffffffffffffffffffffffffff000000000000000000000;

    uint256 constant MAX_LOCATION_ID =    0x2000000000000000000000000000000000000000000000000000000000000000;

    int256 constant HMETER_DECIMAL  = 10 ** 8;

    // x, y, z should between -2^83 (-9671406556917033397649408) and 2^83 - 1 (9671406556917033397649407).
    int256 constant MIN_Location_XYZ = -9671406556917033397649408;
    int256 constant MAX_Location_XYZ = 9671406556917033397649407;
    // 96714065569170334.50000000
    int256 constant MAX_HM_DECIMAL  = 9671406556917033450000000;
    int256 constant MAX_HM  = 96714065569170334;

    function encodeLocationIdXY(int _x, int _y) internal pure  returns (uint result) {
        return encodeLocationId3D(_x, _y, 0);
    }

    function decodeLocationIdXY(uint _positionId) internal pure  returns (int _x, int _y) {
        (_x, _y, ) = decodeLocationId3D(_positionId);
    }

    function encodeLocationId3D(int _x, int _y, int _z) internal pure  returns (uint result) {
        return _unsafeEncodeLocationId3D(_x, _y, _z);
    }

    function _unsafeEncodeLocationId3D(int _x, int _y, int _z) internal pure returns (uint) {
        require(_x >= MIN_Location_XYZ && _x <= MAX_Location_XYZ, "Invalid value.");
        require(_y >= MIN_Location_XYZ && _y <= MAX_Location_XYZ, "Invalid value.");
        require(_z >= MIN_Location_XYZ && _z <= MAX_Location_XYZ, "Invalid value.");

        // uint256 constant FACTOR_2 = 0x1000000000000000000000000000000000000000000; // <16 ** 42> or <2 ** 168>
        // uint256 constant FACTOR = 0x1000000000000000000000; // <16 ** 21> or <2 ** 84>
        return ((uint(_x) << 168) & CLEAR_YZ) | (uint(_y << 84) & CLEAR_XZ) | (uint(_z) & CLEAR_XY) | NOT_ZERO;
    }

    function decodeLocationId3D(uint _positionId) internal pure  returns (int, int, int) {
        return _unsafeDecodeLocationId3D(_positionId);
    }

    function _unsafeDecodeLocationId3D(uint _value) internal pure  returns (int x, int y, int z) {
        require(_value >= NOT_ZERO && _value < MAX_LOCATION_ID, "Invalid Location Id");

        x = expandNegative84BitCast((_value & CLEAR_YZ) >> 168);
        y = expandNegative84BitCast((_value & CLEAR_XZ) >> 84);
        z = expandNegative84BitCast(_value & CLEAR_XY);
    }

    function toHM(int _x) internal pure returns (int) {
        return (_x + MAX_HM_DECIMAL)/HMETER_DECIMAL - MAX_HM;
    }

    function toUM(int _x) internal pure returns (int) {
        return _x * LocationCoder.HMETER_DECIMAL;
    }

    function expandNegative84BitCast(uint _value) internal pure  returns (int) {
        if (_value & (1<<83) != 0) {
            return int(_value | APPEND_HIGH);
        }
        return int(_value);
    }

    function encodeLocationIdHM(int _x, int _y) internal pure  returns (uint result) {
        return encodeLocationIdXY(toUM(_x), toUM(_y));
    }

    function decodeLocationIdHM(uint _positionId) internal pure  returns (int, int) {
        (int _x, int _y) = decodeLocationIdXY(_positionId);
        return (toHM(_x), toHM(_y));
    }
}

////// lib/common-contracts/contracts/SettingIds.sol
/* pragma solidity ^0.4.24; */

/**
    Id definitions for SettingsRegistry.sol
    Can be used in conjunction with the settings registry to get properties
*/
contract SettingIds {
    // 0x434f4e54524143545f52494e475f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    // 0x434f4e54524143545f4b544f4e5f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_KTON_ERC20_TOKEN = "CONTRACT_KTON_ERC20_TOKEN";

    // 0x434f4e54524143545f474f4c445f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";

    // 0x434f4e54524143545f574f4f445f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";

    // 0x434f4e54524143545f57415445525f45524332305f544f4b454e000000000000
    bytes32 public constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";

    // 0x434f4e54524143545f464952455f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";

    // 0x434f4e54524143545f534f494c5f45524332305f544f4b454e00000000000000
    bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";

    // 0x434f4e54524143545f4f424a4543545f4f574e45525348495000000000000000
    bytes32 public constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";

    // 0x434f4e54524143545f544f4b454e5f4c4f434154494f4e000000000000000000
    bytes32 public constant CONTRACT_TOKEN_LOCATION = "CONTRACT_TOKEN_LOCATION";

    // 0x434f4e54524143545f4c414e445f424153450000000000000000000000000000
    bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

    // 0x434f4e54524143545f555345525f504f494e5453000000000000000000000000
    bytes32 public constant CONTRACT_USER_POINTS = "CONTRACT_USER_POINTS";

    // 0x434f4e54524143545f494e5445525354454c4c41525f454e434f444552000000
    bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";

    // 0x434f4e54524143545f4449564944454e44535f504f4f4c000000000000000000
    bytes32 public constant CONTRACT_DIVIDENDS_POOL = "CONTRACT_DIVIDENDS_POOL";

    // 0x434f4e54524143545f544f4b454e5f5553450000000000000000000000000000
    bytes32 public constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    // 0x434f4e54524143545f524556454e55455f504f4f4c0000000000000000000000
    bytes32 public constant CONTRACT_REVENUE_POOL = "CONTRACT_REVENUE_POOL";

    // 0x434f4e54524143545f4252494447455f504f4f4c000000000000000000000000
    bytes32 public constant CONTRACT_BRIDGE_POOL = "CONTRACT_BRIDGE_POOL";

    // 0x434f4e54524143545f4552433732315f42524944474500000000000000000000
    bytes32 public constant CONTRACT_ERC721_BRIDGE = "CONTRACT_ERC721_BRIDGE";

    // 0x434f4e54524143545f5045545f42415345000000000000000000000000000000
    bytes32 public constant CONTRACT_PET_BASE = "CONTRACT_PET_BASE";

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // this can be considered as transaction fee.
    // Values 0-10,000 map to 0%-100%
    // set ownerCut to 4%
    // ownerCut = 400;
    // 0x55494e545f41554354494f4e5f43555400000000000000000000000000000000
    bytes32 public constant UINT_AUCTION_CUT = "UINT_AUCTION_CUT";  // Denominator is 10000

    // 0x55494e545f544f4b454e5f4f464645525f435554000000000000000000000000
    bytes32 public constant UINT_TOKEN_OFFER_CUT = "UINT_TOKEN_OFFER_CUT";  // Denominator is 10000

    // Cut referer takes on each auction, measured in basis points (1/100 of a percent).
    // which cut from transaction fee.
    // Values 0-10,000 map to 0%-100%
    // set refererCut to 4%
    // refererCut = 400;
    // 0x55494e545f524546455245525f43555400000000000000000000000000000000
    bytes32 public constant UINT_REFERER_CUT = "UINT_REFERER_CUT";

    // 0x55494e545f4252494447455f4645450000000000000000000000000000000000
    bytes32 public constant UINT_BRIDGE_FEE = "UINT_BRIDGE_FEE";

    // 0x434f4e54524143545f4c414e445f5245534f5552434500000000000000000000
    bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";
}

////// lib/common-contracts/contracts/interfaces/IObjectOwnership.sol
/* pragma solidity ^0.4.24; */

contract IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);

    function burnObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);
}

////// lib/common-contracts/contracts/interfaces/ISettingsRegistry.sol
/* pragma solidity ^0.4.24; */

contract ISettingsRegistry {
    enum SettingsValueTypes { NONE, UINT, STRING, ADDRESS, BYTES, BOOL, INT }

    function uintOf(bytes32 _propertyName) public view returns (uint256);

    function stringOf(bytes32 _propertyName) public view returns (string);

    function addressOf(bytes32 _propertyName) public view returns (address);

    function bytesOf(bytes32 _propertyName) public view returns (bytes);

    function boolOf(bytes32 _propertyName) public view returns (bool);

    function intOf(bytes32 _propertyName) public view returns (int);

    function setUintProperty(bytes32 _propertyName, uint _value) public;

    function setStringProperty(bytes32 _propertyName, string _value) public;

    function setAddressProperty(bytes32 _propertyName, address _value) public;

    function setBytesProperty(bytes32 _propertyName, bytes _value) public;

    function setBoolProperty(bytes32 _propertyName, bool _value) public;

    function setIntProperty(bytes32 _propertyName, int _value) public;

    function getValueTypeOf(bytes32 _propertyName) public view returns (uint /* SettingsValueTypes */ );

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}

////// lib/common-contracts/contracts/interfaces/ITokenLocation.sol
/* pragma solidity ^0.4.24; */

contract ITokenLocation {

    function hasLocation(uint256 _tokenId) public view returns (bool);

    function getTokenLocation(uint256 _tokenId) public view returns (int, int);

    function setTokenLocation(uint256 _tokenId, int _x, int _y) public;

    function getTokenLocationHM(uint256 _tokenId) public view returns (int, int);

    function setTokenLocationHM(uint256 _tokenId, int _x, int _y) public;
}

////// lib/zeppelin-solidity/contracts/introspection/ERC165.sol
/* pragma solidity ^0.4.24; */


/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

////// lib/zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol
/* pragma solidity ^0.4.24; */

/* //import"../../introspection/ERC165.sol"; */


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {

  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
  /*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;
  /*
   * 0x4f558e79 ===
   *   bytes4(keccak256('exists(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

////// lib/zeppelin-solidity/contracts/token/ERC721/ERC721.sol
/* pragma solidity ^0.4.24; */

/* //import"./ERC721Basic.sol"; */


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

////// contracts/LandBaseV2.sol
/* pragma solidity ^0.4.24; */

/* //import"./interfaces/ILandBase.sol"; */
/* //import"openzeppelin-solidity/contracts/token/ERC721/ERC721.sol"; */
/* //import"@evolutionland/common/contracts/interfaces/IObjectOwnership.sol"; */
/* //import"@evolutionland/common/contracts/interfaces/ITokenLocation.sol"; */
/* //import"@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol"; */
/* //import"@evolutionland/common/contracts/DSAuth.sol"; */
/* //import"@evolutionland/common/contracts/SettingIds.sol"; */
/* //import"@evolutionland/common/contracts/LocationCoder.sol"; */

contract LandBaseV2 is DSAuth, ILandBase, SettingIds {
    using LocationCoder for *;

    uint256 constant internal RESERVED = uint256(1);
    uint256 constant internal SPECIAL = uint256(2);
    uint256 constant internal HASBOX = uint256(4);

    uint256 constant internal CLEAR_RATE_HIGH = 0x000000000000000000000000000000000000000000000000000000000000ffff;

    struct LandAttr {
        uint256 resourceRateAttr;
        uint256 mask;
    }

    bool private singletonLock = false;

    ISettingsRegistry public registry;

    /**
     * @dev mapping from resource token address to resource atrribute rate id.
     * atrribute rate id starts from 1 to 16, NAN is 0.
     * goldrate is 1, woodrate is 2, waterrate is 3, firerate is 4, soilrate is 5
     */
    mapping (address => uint8) public resourceToken2RateAttrId;

    /**
     * @dev mapping from token id to land resource atrribute.
     */
    mapping (uint256 => LandAttr) public tokenId2LandAttr;

    // mapping from position in map to token id.
    mapping (uint256 => uint256) public locationId2TokenId;

    uint256 public lastLandObjectId;

    int256 public xLow;
    int256 public xHigh;
    int256 public yLow;
    int256 public yHigh;

    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    modifier xAtlantisRangeLimit(int _x) {
        require(_x >= xLow && _x <= xHigh, "Invalid range.");
        _;
    }

    modifier yAtlantisRangeLimit(int _y) {
        require(_y >= yLow && _y <= yHigh, "Invalid range.");
        _;
    }

    /**
     * @dev Same with constructor, but is used and called by storage proxy as logic contract.
     */
    function initializeContract(address _registry, int256 _xLow, int256 _xHigh, int256 _yLow, int256 _yHigh) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);

         // update attributes.
        resourceToken2RateAttrId[registry.addressOf(CONTRACT_GOLD_ERC20_TOKEN)] = 1;
        resourceToken2RateAttrId[registry.addressOf(CONTRACT_WOOD_ERC20_TOKEN)] = 2;
        resourceToken2RateAttrId[registry.addressOf(CONTRACT_WATER_ERC20_TOKEN)] = 3;
        resourceToken2RateAttrId[registry.addressOf(CONTRACT_FIRE_ERC20_TOKEN)] = 4;
        resourceToken2RateAttrId[registry.addressOf(CONTRACT_SOIL_ERC20_TOKEN)] = 5;

        xLow = _xLow;
        xHigh = _xHigh;
        yLow = _yLow;
        yHigh = _yHigh;
    }

    /*
     * @dev assign new land
     */
    function assignNewLand(
        int _x, int _y, address _beneficiary, uint256 _resourceRateAttr, uint256 _mask
        ) public auth xAtlantisRangeLimit(_x) yAtlantisRangeLimit(_y) returns (uint _tokenId) {

        // auto increase object id, start from 1
        lastLandObjectId += 1;
        require(lastLandObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");

        _tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_beneficiary, uint128(lastLandObjectId));

        // update locations.
        uint256 locationId = LocationCoder.encodeLocationIdHM(_x, _y);
        require(locationId2TokenId[locationId] == 0, "Land in this position already been mint.");
        locationId2TokenId[locationId] = _tokenId;
        ITokenLocation(registry.addressOf(CONTRACT_TOKEN_LOCATION)).setTokenLocationHM(_tokenId, _x, _y);

        tokenId2LandAttr[_tokenId].resourceRateAttr = _resourceRateAttr;
        tokenId2LandAttr[_tokenId].mask = _mask;

        emit CreatedNewLand(_tokenId, _x, _y, _beneficiary, _resourceRateAttr, _mask);
    }

    function assignMultipleLands(
        int[] _xs, int[] _ys, address _beneficiary, uint256[] _resourceRateAttrs, uint256[] _masks
        ) public auth returns (uint[]){
        require(_xs.length == _ys.length, "Length of xs didn't match length of ys");
        require(_xs.length == _resourceRateAttrs.length, "Length of postions didn't match length of land attributes");
        require(_xs.length == _masks.length, "Length of masks didn't match length of ys");

        uint[] memory _tokenIds = new uint[](_xs.length);

        for (uint i = 0; i < _xs.length; i++) {
            _tokenIds[i] = assignNewLand(_xs[i], _ys[i], _beneficiary, _resourceRateAttrs[i], _masks[i]);
        }

        return _tokenIds;
    }

    function defineResouceTokenRateAttrId(address _resourceToken, uint8 _attrId) public auth {
        require(_attrId > 0 && _attrId <= 16, "Invalid Attr Id.");

        resourceToken2RateAttrId[_resourceToken] = _attrId;
    }

    // encode (x,y) to get tokenId
    function getTokenIdByLocation(int _x, int _y) public view returns (uint256) {
        uint locationId = LocationCoder.encodeLocationIdHM(_x, _y);
        return locationId2TokenId[locationId];
    }

    function exists(int _x, int _y) public view returns (bool) {
        uint locationId = LocationCoder.encodeLocationIdHM(_x, _y);
        uint tokenId = locationId2TokenId[locationId];
        return ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).exists(tokenId);
    }

    function ownerOfLand(int _x, int _y) public view returns (address) {
        uint locationId = LocationCoder.encodeLocationIdHM(_x, _y);
        uint tokenId = locationId2TokenId[locationId];
        return ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(tokenId);
    }

    function ownerOfLandMany(int[] _xs, int[] _ys) public view returns (address[]) {
        require(_xs.length > 0);
        require(_xs.length == _ys.length);

        address[] memory addrs = new address[](_xs.length);
        for (uint i = 0; i < _xs.length; i++) {
            addrs[i] = ownerOfLand(_xs[i], _ys[i]);
        }

        return addrs;
    }

    function landOf(address _landholder) public view returns (int[], int[]) {
        address objectOwnership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
        uint256 length = ERC721(objectOwnership).balanceOf(_landholder);
        int[] memory x = new int[](length);
        int[] memory y = new int[](length);

        ITokenLocation tokenLocation = ITokenLocation(registry.addressOf(CONTRACT_TOKEN_LOCATION));

        for(uint i = 0; i < length; i++) {
            uint tokenId = ERC721(objectOwnership).tokenOfOwnerByIndex(_landholder, i);
            (x[i], y[i]) = tokenLocation.getTokenLocationHM(tokenId);
        }

        return (x, y);
    }

    function isHasBox(uint256 _landTokenID) public view returns (bool) {
        return (tokenId2LandAttr[_landTokenID].mask & HASBOX) != 0;
    }

    function isReserved(uint256 _landTokenID) public view returns (bool) {
        return (tokenId2LandAttr[_landTokenID].mask & RESERVED) != 0;
    }

    function isSpecial(uint256 _landTokenID) public view returns (bool) {
        return (tokenId2LandAttr[_landTokenID].mask & SPECIAL) != 0;
    }

    function setHasBox(uint _landTokenID, bool _isHasBox) public auth {
        if (_isHasBox) {
            tokenId2LandAttr[_landTokenID].mask |= HASBOX;
        } else {
            tokenId2LandAttr[_landTokenID].mask &= ~HASBOX;
        }

        emit HasboxSetted(_landTokenID, _isHasBox);
    }

    function getResourceRateAttr(uint _landTokenId) public view returns (uint256) {
        return tokenId2LandAttr[_landTokenId].resourceRateAttr;
    }

    function setResourceRateAttr(uint _landTokenId, uint256 _newResourceRateAttr) public auth {
        tokenId2LandAttr[_landTokenId].resourceRateAttr = _newResourceRateAttr;

        emit ChangedReourceRateAttr(_landTokenId, _newResourceRateAttr);
    }

    function getFlagMask(uint _landTokenId) public view returns (uint256) {
        return tokenId2LandAttr[_landTokenId].mask;
    }

    function setFlagMask(uint _landTokenId, uint256 _newFlagMask) public auth {
        tokenId2LandAttr[_landTokenId].mask = _newFlagMask;
        emit ChangedFlagMask(_landTokenId, _newFlagMask);
    }

    function getResourceRate(uint _landTokenId, address _resourceToken) public view returns (uint16) {
        require(resourceToken2RateAttrId[_resourceToken] > 0, "Resource token doesn't exist.");

        uint moveRight = (16 * (resourceToken2RateAttrId[_resourceToken] - 1));
        return uint16((tokenId2LandAttr[_landTokenId].resourceRateAttr >> moveRight) & CLEAR_RATE_HIGH);
    }

    function setResourceRate(uint _landTokenId, address _resourceToken, uint16 _newResouceRate) public auth {
        require(resourceToken2RateAttrId[_resourceToken] > 0, "Reource token doesn't exist.");
        uint moveLeft = 16 * (resourceToken2RateAttrId[_resourceToken] - 1);
        tokenId2LandAttr[_landTokenId].resourceRateAttr &= (~(CLEAR_RATE_HIGH << moveLeft));
        tokenId2LandAttr[_landTokenId].resourceRateAttr |= (uint256(_newResouceRate) << moveLeft);
        emit ModifiedResourceRate(_landTokenId, _resourceToken, _newResouceRate);
    }
}

}
