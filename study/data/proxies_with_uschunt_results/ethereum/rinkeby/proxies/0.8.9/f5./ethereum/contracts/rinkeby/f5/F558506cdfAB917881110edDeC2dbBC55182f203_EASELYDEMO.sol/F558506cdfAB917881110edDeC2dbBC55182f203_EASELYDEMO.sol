/**
 *Submitted for verification at Etherscan.io on 2022-02-06
*/

// ////-License-Identifier: MIT
pragma solidity ^0.8.9;

/////////////////////
//                 //
//                 //
//    SIGNATURE    //
//                 //
//                 //
/////////////////////

/**
  * @dev Library for reading and writing primitive types to specific storage slots.
  *
  * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
  * This library helps with reading and writing to such slots without the need for inline assembly.
  *
  * The functions in this library return Slot structs that contain a "value" member that can be used to read or write.
  *
  * Example usage to set ERC1967 implementation slot:
  * 
  * contract ERC1967 {
  *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
  *
  *     function _getImplementation() internal view returns (address) {
  *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
  *     }
  *
  *     function _setImplementation(address newImplementation) internal {
  *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
  *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
  *     }
  * }
  *
  *
  * _Available since v4.1 for address, bool, bytes32, and uint256._
  */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
      * @dev Returns an AddressSlot with member value located at slot.
      */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
      * @dev Returns an BooleanSlot with member value located at slot.
      */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
      * @dev Returns an Bytes32Slot with member value located at slot.
      */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
      * @dev Returns an Uint256Slot with member value located at slot.
      */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

/**
  * @dev Collection of functions related to the address type
  */
library Address {
    /**
      * @dev Returns true if account is a contract.
      *
      * [IMPORTANT]
      * ====
      * It is unsafe to assume that an address for which this function returns
      * false is an externally-owned account (EOA) and not a contract.
      *
      * Among others, {isContract} will return false for the following
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
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
      * @dev Replacement for Solidity's {transfer}: sends "amount" wei to
      * "recipient", forwarding all available gas and reverting on errors.
      *
      * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
      * of certain opcodes, possibly making contracts go over the 2300 gas limit
      * imposed by {transfer}, making them unable to receive funds via
      * {transfer}. {sendValue} removes this limitation.
      *
      * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
      *
      * IMPORTANT: because control is transferred to "recipient", care must be
      * taken to not create reentrancy vulnerabilities. Consider using
      * {ReentrancyGuard} or the
      * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
      */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
      * @dev Performs a Solidity function call using a low level "call". A
      * plain "call" is an unsafe replacement for a function call: use this
      * function instead.
      *
      * If "target" reverts with a revert reason, it is bubbled up by this
      * function (like regular Solidity function calls).
      *
      * Returns the raw returned data. To convert to the expected return value,
      * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[abi.decode].
      *
      * Requirements:
      *
      * - "target" must be a contract.
      * - calling "target" with "data" must not revert.
      *
      * _Available since v3.1._
      */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-}[functionCall], but with
      * "errorMessage" as a fallback revert reason when "target" reverts.
      *
      * _Available since v3.1._
      */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-}[functionCall],
      * but also transferring "value" wei to "target".
      *
      * Requirements:
      *
      * - the calling contract must have an ETH balance of at least "value".
      * - the called Solidity function must be {payable}.
      *
      * _Available since v3.1._
      */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
      * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[functionCallWithValue], but
      * with "errorMessage" as a fallback revert reason when "target" reverts.
      *
      * _Available since v3.1._
      */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-}[functionCall],
      * but performing a static call.
      *
      * _Available since v3.3._
      */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-string-}[functionCall],
      * but performing a static call.
      *
      * _Available since v3.3._
      */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-}[functionCall],
      * but performing a delegate call.
      *
      * _Available since v3.4._
      */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
      * @dev Same as {xref-Address-functionCall-address-bytes-string-}[functionCall],
      * but performing a delegate call.
      *
      * _Available since v3.4._
      */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
      * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
      * revert reason using the provided one.
      *
      * _Available since v4.3._
      */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

/**
  * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
  * instruction {delegatecall}. We refer to the second contract as the _implementation_ behind the proxy, and it has to
  * be specified by overriding the virtual {_implementation} function.
  *
  * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
  * different contract through the {_delegate} function.
  *
  * The success and return data of the delegated call will be returned back to the caller of the proxy.
  */
abstract contract Proxy {
    /**
      * @dev Delegates the current call to {implementation}.
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
      * @dev Delegates the current call to the address returned by _implementation().
      *
      * This function does not return to its internall call site, it will return directly to the external caller.
      */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
      * @dev Fallback function that delegates calls to the address returned by _implementation(). Will run if no other
      * function in the contract matches the call data.
      */
    fallback() external payable virtual {
        _fallback();
    }

    /**
      * @dev Fallback function that delegates calls to the address returned by _implementation(). Will run if call data
      * is empty.
      */
    receive() external payable virtual {
        _fallback();
    }

    /**
      * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual {_fallback}
      * call, or as part of the Solidity {fallback} or {receive} functions.
      *
      * If overriden should call super._beforeFallback().
      */
    function _beforeFallback() internal virtual {}
}

contract EASELYDEMO is Proxy {
    /**
      * @dev Emitted when the implementation is upgraded.
      */
    event Upgraded(address indexed implementation);
    
    constructor() {

        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = 0x77dE74F4B9B6d13c6E7dbB67fB9F0eFd7b1B5620;
        emit Upgraded(0x77dE74F4B9B6d13c6E7dbB67fB9F0eFd7b1B5620);
        Address.functionDelegateCall(
            0x77dE74F4B9B6d13c6E7dbB67fB9F0eFd7b1B5620,
            abi.encodeWithSignature(
                "init(bool[2],address[3],uint256[6],string[3])",
                [false,true],
                [0x0000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000,0x1BAAd9BFa20Eb279d2E3f3e859e3ae9ddE666c52],
                [300,0,0,1000,5,10],
                ["EASELY DEMO","EASE","QmTozqMZv2dJrRwwc8QmVBYyGs7CBgamNo1Qfa7Gq7vp55"]
            )
        );
    
    }
        
    /**
      * @dev Storage slot with the address of the current implementation.
      * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
      * validated in the constructor.
      */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
      * @dev Returns the current implementation address.
      */
    function implementation() public view returns (address) {
        return _implementation();
    }

    function _implementation() internal override view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
      * @dev Perform implementation upgrade
      *
      * Emits an {Upgraded} event.
      */
    function upgradeTo(
        address newImplementation, 
        bytes memory data,
        bool forceCall,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(msg.sender == 0x0ddD338bA7A3Fcf571837611bE2DAfBDe5166EEA);
        bytes32 base = keccak256(abi.encode(address(this), newImplementation));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", base));
        
        require(ecrecover(hash, v, r, s) == 0x1BAAd9BFa20Eb279d2E3f3e859e3ae9ddE666c52);

        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
        if (data.length > 0 || forceCall) {
          Address.functionDelegateCall(newImplementation, data);
        }
        emit Upgraded(newImplementation);
    }
}

// : MIT
pragma solidity ^0.8.9;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                         //
//                                                                                                                                                         //
//       .;dkkkkkkkkkkkkkkkkkkd'      .:xkkkkkkkkd,           .:dk0XXXXXXXK0xdl,.    .lxkkkkkkkkkkkkkkkkkk:.,okkkkkkko.    .cxkkkkkkxc.      ;dkkkkkko.    //
//      ;xNMMMMMMMMMMMMMMMMMMMX:    .:kNWMMMMMMMMWx.        .l0NWWWWWMMMMMMMMMWNO;..lKWMMMMMMMMMMMMMMMMMMMKkKWMMMMMMMK,  .c0WMMMMMMMMX:   .;xXWMMMMMNo.    //
//    .,lddddddddddddddddxKMMMK;   .,lddddddx0WMMMX;      .;llc::;;::cox0XWMMMMMWXdcoddddddddddddddddONMW0ddddddxXMMMK, .:odddddONMMMMO' .,lddddd0WWd.     //
//    ..                 .dWWKl.   .         :XMMMWx.    ...            .,oKWMMMMWx.                 ,KMNc      .kMMM0, ..      .xWMMMWx'.      'kNk.      //
//    ..                 .dKo'    ..         .xWMMMK;  ..       .'..       ,OWWMMWx.                 ,Okc'      .kMMMK,  ..      ,0MMMMXl.     .dNO'       //
//    ..      .:ooo;......,'      .           :XMMMWd. .      .l0XXOc.      ;xKMWNo.      ,looc'......'...      .kMMMK,   ..      cXMMM0,     .oNK;        //
//    ..      '0MMMk.            ..           .kWMMMK,.'      ;KMMMWNo.     .;kNkc,.     .dWMMK:        ..      .kMMMK,    ..     .dWMXc      cXK:         //
//    ..      '0MMMXkxxxxxxxxd'  .     .:.     cXMMMWd,'      '0MMMMM0l;;;;;;:c;. ..     .dWMMW0xxxxxxxxx;      .kMMMK,     ..     'ONd.     :KXc          //
//    ..      '0MMMMMMMMMMMMMNc ..     :O:     .kMMMMK:.       'd0NWMWWWWWWWNXOl'...     .dWMMMMMMMMMMMMWl      .kMMMK,      .      :d'     ;0No.          //
//    ..      .lkkkkkkkkkKWMMNc .     .dNd.     cNMMMWo..        .':dOXWMMMMMMMWXk:.      :xkkkkkkkk0NMMWl      .kMMMK,       .      .     'ONd.           //
//    ..                .oNMXd...     '0M0'     .kMMMM0, ..           .;o0NMMMMMMWx.                ,0MN0:      .kMMMK,       ..          .kW0'            //
//    ..                 cKk,  .      lNMNl      cNMMMNo  .',..          .;xXWMMMWx.                'O0c'.      .kMMMK,        ..        .xWMO.            //
//    ..      .,ccc,.....,,.  ..     .kMMMk.     .OMMMW0;'d0XX0xc,.         :d0MMWx.      ':cc:'....';. ..      .kMMMK,         ..      .oNMMO.            //
//    ..      '0MMMk.         ..     ,kKKKk'      lNMMMN0KWWWMMMWNKl.         cXMWx.     .dWMMX:        ..      .kMMMK,         ..      .OMMMO.            //
//    ..      '0MMMk'..........       .....       'OMMKo:::::cxNMMMKl'.       .OMWx.     .dWMMXc..........      .kMMMK:.........,'      .OMMMO.            //
//    ..      '0MMMNXKKKKKKKKd.                    lNM0'      ;XMMMWN0c       .OMWd.     .dWMMWXKKKKKKKK0c      .kMMMWXKKKKKKKKK0:      .OMMMO.            //
//    ..      'OWWWWWWWWWWMMNc      'llc'   .      '0MNc      .kWMMMMX:       ,KXx:.     .oNWWWWWWWWWWMMWl      .xWWWWWWWWWWWMMMN:      .OMMMO.            //
//    ..       ,:::::::::cOWO.     .xWWO'   .       oNMO'      .lkOOx;.     .'cd,...      .::::::::::dXMWl       '::::::::::xWMMX:      .OMMWx.            //
//    ..                  dNl      ,0Xd.    ..      ,0MNo.        .        ..'.   ..                 ,0WK:                  :NWOo,      .OWKo.             //
//    .'                 .oO,     .co,       ..     .oOc....             ...      ..                 ,xo,..                 ckl..'.     'dd'               //
//     .............................         ..........       .   ..   .          .....................  .....................   .........                 //
//                                                                                                                                                         //
//                                                                                                                                                         //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

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
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
        assembly {
            size := extcodesize(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 *
 * This ERC721 Has been adjusted from OpenZepplins to have a totalSupply method. It also is set up to better handle
 * batch transactions. Namely it does not update _balances on a call to {_mint} and expects the minting method to do so.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    // Token name
    string internal _name;

    // Token symbol
    string internal _symbol;

    // Tracking total minted
    // Only used when `_isSequential` is false
    uint256 internal _totalMinted;

    // Tracking total burned
    uint256 internal _totalBurned;

    // Tracking the next sequential mint
    uint256 internal _nextSequential;

    // This ensures that ownerOf() can still run in constant time
    // With a max runtime of checking 10 variables, but saves on batch mints tremendously.
    uint256 internal constant MAX_OWNER_SEQUENCE = 10;

    // Tracking if the collection is still sequentially minted
    bool internal _notSequentialMint;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping from token ID to burned
    // This is necessary because to optimize gas fees for multiple mints a token with
    // `_owners[tokenId] = address(0)` is not necessarily a token with no owner.
    mapping(uint256 => bool) internal _burned;

    // Mapping owner address to token count
    mapping(address => AddressData) internal _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner].balance;
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(_exists(tokenId), "ERC721: owner query for nonexistent token");

        if (tokenId < _nextSequential) {
            uint256 lowestTokenToCheck;
            if (tokenId >= MAX_OWNER_SEQUENCE) {
                lowestTokenToCheck = tokenId - MAX_OWNER_SEQUENCE + 1;
            }

            for (uint256 i = tokenId; i >= lowestTokenToCheck; i--) {
                if (_owners[i] != address(0)) {
                    return _owners[i];
                }
            }
        }

        return _owners[tokenId];
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the total current supply of the contract.
     *
     * WARNING - Underlying variables do NOT get automatically updated on mints
     * so that we can save gas on transactions that mint multiple tokens.
     *
     */
    function totalSupply() public view virtual returns (uint256) {
        return totalMinted() - _totalBurned;
    }

    /**
     * @dev Returns the total ever minted from this contract.
     *
     * WARNING - Underlying variable do NOT get automatically updated on mints
     * so that we can save gas on transactions that mint multiple tokens.
     *
     */
    function totalMinted() public view virtual returns (uint256) {
        if (_notSequentialMint) {
            return _totalMinted;
        }

        return _nextSequential;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(
            _isApprovedOrOwner(_msgSender(), tokenId, owner),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * This was modified to not call _safeTransfer because that would require fetching
     * ownerOf() twice which is more expensive than doing it together.
     * _safeTransfer was not modified to take in owner because functions using that
     * method should be able to assume that it will check for the tokenOwner.
     *
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(
            _isApprovedOrOwner(_msgSender(), tokenId, owner),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId, owner);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId, ERC721.ownerOf(tokenId));
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        if (_burned[tokenId]) {
            return false;
        }

        if (tokenId < _nextSequential) {
            return true;
        }

        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId,
        address owner
    ) internal view virtual returns (bool) {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * WARNING - this method does not update totalSupply or _balances, please update that externally. Doing so
     * will allow us to save gas on transactions that mint more than one NFT
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     * WARNING: This method does not update totalSupply, please update that externally. Doing so
     * will allow us to save gas on transactions
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     * WARNING: This method does not update totalSupply or _balances, please update that externally. Doing so
     * will allow us to save gas on transactions that mint more than one NFT
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(_notSequentialMint, "_notSequentialMint must be true");
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Mints from `_nextSequential` to `_nextSequential + quantity` and transfers it to `to`.
     *
     * WARNING: This method does not update totalSupply or _balances, please update that externally. Doing so
     * will allow us to save gas on transactions that mint more than one NFT
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _safeMintSequential(address to, uint256 quantity)
        internal
        virtual
    {
        require(!_notSequentialMint, "_notSequentialMint must be false");
        require(to != address(0), "ERC721: mint to the zero address");

        uint256 lastNum = _nextSequential + quantity;
        // ensures ownerOf runs quickly even if user is minting a large number like 100
        for (
            uint256 i = _nextSequential;
            i < lastNum;
            i += MAX_OWNER_SEQUENCE
        ) {
            _owners[i] = to;
        }

        // Gas is cheaper to have two separate for loops
        for (uint256 i = _nextSequential; i < lastNum; i++) {
            emit Transfer(address(0), to, i);
            require(
                _checkOnERC721Received(address(0), to, i, ""),
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        }

        _balances[to] = AddressData(
            _balances[to].balance + uint128(quantity),
            _balances[to].numberMinted + uint128(quantity)
        );
        _nextSequential = lastNum;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        require(owner == _msgSender(), "Cannot burn a token you do not own");

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId, owner);

        _balances[owner].balance -= 1;
        _totalBurned += 1;
        _burned[tokenId] = true;

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * WARNING this method assumes the passed in owner is the token owner. This is done because with the gas optimization
     * calling ownerOf can be an expensive calculation and should only be done once (in the outer most layer)
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId,
        address owner
    ) internal virtual {
        require(owner == from, "ERC721:  transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        _balances[from].balance -= 1;
        _balances[to].balance += 1;
        _owners[tokenId] = to;

        uint256 nextTokenId = tokenId + 1;
        if (nextTokenId < _nextSequential) {
            if (_owners[nextTokenId] == address(0)) {
                _owners[nextTokenId] = from;
            }
        }

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) internal virtual {
        if (_tokenApprovals[tokenId] != to) {
            _tokenApprovals[tokenId] = to;
            emit Approval(owner, to, tokenId);
        }
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

/**
 * @dev Interface for the NFT Royalty Standard
 */
interface IERC2981 is IERC165 {
    /**
     * ERC165 bytes to add to interface array - set in parent contract
     * implementing this standard
     *
     * bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
     * bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
     * _registerInterface(_INTERFACE_ID_ERC2981);
     */

    /**
     * @notice Called with the sale price to determine how much royalty
     *          is owed and to whom.
     * @param _tokenId - the NFT asset queried for royalty information
     * @param _salePrice - the sale price of the NFT asset specified by _tokenId
     * @return receiver - address of who should be sent the royalty payment
     * @return royaltyAmount - the royalty payment amount for _salePrice
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(
                vs,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}

/**
 * @dev External interface of the EaselyPayout contract
 */
interface IEaselyPayout {
    /**
     * @dev Takes in a payable amount and splits it among the given royalties.
     * Also takes a cut of the payable amount depending on the sender and the primaryPayout address.
     * Ensures that this method never splits over 100% of the payin amount.
     */
    function splitPayable(
        address primaryPayout,
        address[] memory royalties,
        uint256[] memory bps
    ) external payable;
}

/**
 * @dev Extension of the ERC721Enumerable contract that integrates a marketplace so that simple lazy-sales
 * do not have to be done on another contract. This saves gas fees on secondary sales because
 * buyers will not have to pay a gas fee to setApprovalForAll for another marketplace contract after buying.
 *
 * Easely will help power the lazy-selling as well as lazy minting that take place on
 * directly on the collection, which is why we take a cut of these transactions. Our cut can
 * be publically seen in the connected EaselyPayout contract and cannot exceed 5%.
 *
 * Owners also set an alternate signer which they can change at any time. This alternate signer helps enable
 * sales for large batches of addresses without needing to manually sign hundreds or thousands of hashes.
 */
abstract contract ERC721Marketplace is ERC721, Ownable {
    using ECDSA for bytes32;
    using Strings for uint256;

    /* see {IEaselyPayout} for more */
    address public constant PAYOUT_CONTRACT_ADDRESS =
        0xc495c35C7220D93aA3CA77E8D394bdf7241257d6;
    uint256 public constant TIME_PER_DECREMENT = 300;

    uint256 public constant MAX_ROYALTIES_BPS = 9500;
    /* Optional basis points for the owner for secondary sales of this collection */
    uint256 public constant MAX_SECONDARY_BPS = 1000;

    /* Let's the owner enable another address to lazy mint */
    address public alternateSignerAddress;
    /* Optional basis points for the owner for secondary sales of this collection */
    uint256 public ownerRoyaltyBPS;
    /* Optional addresses to distribute revenue of primary sales of this collection */
    address[] public revenueShare;
    /* Optional basis points for revenue share for primary sales of this collection */
    uint256[] public revenueShareBPS;

    /* Mapping to the active version for all signed transactions */
    mapping(address => uint256) internal _addressToActiveVersion;
    /* Cancelled or finalized sales by hash to determine buyabliity */
    mapping(bytes32 => bool) internal _cancelledOrFinalizedSales;

    // Events related to lazy selling
    event SaleCancelled(address indexed seller, bytes32 hash);
    event SaleCompleted(
        uint256 indexed tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer,
        bytes32 hash
    );

    // Miscellaneous events
    event VersionChanged(address indexed seller, uint256 version);
    event AltSignerChanged(address newSigner);
    event BalanceWithdrawn(uint256 balance);
    event RoyaltyUpdated(uint256 bps);
    event RevenueShareUpdated(
        address address1,
        address address2,
        uint256 bps1,
        uint256 bps2
    );

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(Ownable).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev see {IERC2981-supportsInterface}
     */
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        uint256 royalty = (_salePrice * ownerRoyaltyBPS) / 10000;
        return (owner(), royalty);
    }

    /**
     * @dev See {_currentPrice}
     */
    function getCurrentPrice(uint256[4] memory pricesAndTimestamps)
        external
        view
        returns (uint256)
    {
        return _currentPrice(pricesAndTimestamps);
    }

    /**
     * @dev Returns the current activeVersion of an address both used to create signatures
     * and to verify signatures of {buyToken} and {buyNewToken}
     */
    function getActiveVersion(address address_)
        external
        view
        returns (uint256)
    {
        return _addressToActiveVersion[address_];
    }

    /**
     * This function, while callable by anybody will always ONLY withdraw the
     * contract's balance to:
     *
     * the owner's account
     * the addresses the owner has set up for revenue share
     * the easely payout contract cut - capped at 5% but can be lower for some users
     *
     * This is callable by anybody so that Easely can set up automatic payouts
     * after a contract has reached a certain minimum to save creators the gas fees
     * involved in withdrawing balances.
     */
    function withdrawBalance(uint256 withdrawAmount) external {
        require(withdrawAmount <= address(this).balance);
        IEaselyPayout payoutContract = IEaselyPayout(PAYOUT_CONTRACT_ADDRESS);
        payoutContract.splitPayable{value: withdrawAmount}(
            owner(),
            revenueShare,
            revenueShareBPS
        );
        emit BalanceWithdrawn(withdrawAmount);
    }

    /**
     * @dev Allows the owner to change who the alternate signer is
     */
    function setAltSigner(address alt) external onlyOwner {
        alternateSignerAddress = alt;
        emit AltSignerChanged(alt);
    }

    /**
     * @dev see {_setRoyalties}
     */
    function setRevenueShare(
        address[2] memory newAddresses,
        uint256[2] memory newBPS
    ) external onlyOwner {
        _setRevenueShare(newAddresses, newBPS);
        emit RevenueShareUpdated(
            newAddresses[0],
            newAddresses[1],
            newBPS[0],
            newBPS[1]
        );
    }

    /**
     * @dev see {_setSecondary}
     */
    function setRoyaltiesBPS(uint256 newBPS) external onlyOwner {
        _setRoyaltiesBPS(newBPS);
        emit RoyaltyUpdated(newBPS);
    }

    /**
     * @dev Usable by any user to update the version that they want their signatures to check. This is helpful if
     * an address wants to mass invalidate their signatures without having to call cancelSale on each one.
     */
    function updateVersion(uint256 version) external {
        _addressToActiveVersion[_msgSender()] = version;
        emit VersionChanged(_msgSender(), version);
    }

    /**
     * @dev returns how many tokens the given address has minted.
     */
    function mintCount(address addr) external view returns (uint256) {
        return _balances[addr].numberMinted;
    }

    /**
     * @dev Usable by the owner of any token initiate a sale for their token. This does not
     * lock the tokenId and the owner can freely trade their token, but doing so will
     * invalidate the ability for others to buy.
     */
    function hashToSignToSellToken(
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps
    ) external view returns (bytes32) {
        require(
            _msgSender() == ERC721.ownerOf(tokenId),
            "Not the owner of the token"
        );
        return
            _hashForSale(
                _msgSender(),
                version,
                nonce,
                tokenId,
                pricesAndTimestamps
            );
    }

    /**
     * @dev With a hash signed by the method {hashToSignToSellToken} any user sending enough value can buy
     * the token from the seller. Tokens not owned by the contract owner are all considered secondary sales and
     * will give a cut to the owner of the contract based on the secondaryOwnerBPS.
     */
    function buyToken(
        address seller,
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps,
        bytes memory signature
    ) external payable {
        uint256 currentPrice = _currentPrice(pricesAndTimestamps);

        require(
            _addressToActiveVersion[seller] == version,
            "Incorrect signature version"
        );
        require(msg.value >= currentPrice, "Not enough ETH to buy");

        _markHashSold(
            seller,
            version,
            nonce,
            tokenId,
            pricesAndTimestamps,
            currentPrice,
            signature
        );
        _safeTransfer(seller, _msgSender(), tokenId, "");

        if (seller != owner()) {
            IEaselyPayout(PAYOUT_CONTRACT_ADDRESS).splitPayable{
                value: currentPrice
            }(seller, _ownerRoyalties(), _ownerBPS());
        }
        payable(_msgSender()).transfer(msg.value - currentPrice);
    }

    /**
     * @dev Usable to cancel hashes generated from {hashToSignToSellToken}
     */
    function cancelSale(
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps
    ) external {
        bytes32 hash = _hashToCheckForSale(
            _msgSender(),
            version,
            nonce,
            tokenId,
            pricesAndTimestamps
        );
        _cancelledOrFinalizedSales[hash] = true;
        emit SaleCancelled(_msgSender(), hash);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://";
    }

    /**
     * @dev helper method get ownerRoyalties into an array form
     */
    function _ownerRoyalties() internal view returns (address[] memory) {
        address[] memory ownerRoyalties = new address[](1);
        ownerRoyalties[0] = owner();
        return ownerRoyalties;
    }

    /**
     * @dev helper method get secondary BPS into array form
     */
    function _ownerBPS() internal view returns (uint256[] memory) {
        uint256[] memory ownerBPS = new uint256[](1);
        ownerBPS[0] = ownerRoyaltyBPS;
        return ownerBPS;
    }

    /**
     * @dev Current price for a sale which is calculated for the case of a descending sale. So
     * the ending price must be less than the starting price and the timestamp is active.
     * Standard single fare sales will have a matching starting and ending price.
     */
    function _currentPrice(uint256[4] memory pricesAndTimestamps)
        internal
        view
        returns (uint256)
    {
        uint256 startingPrice = pricesAndTimestamps[0];
        uint256 endingPrice = pricesAndTimestamps[1];
        uint256 startingTimestamp = pricesAndTimestamps[2];
        uint256 endingTimestamp = pricesAndTimestamps[3];

        uint256 currTime = block.timestamp;
        require(currTime >= startingTimestamp, "Has not started yet");
        require(
            startingTimestamp < endingTimestamp,
            "Must end after it starts"
        );
        require(startingPrice >= endingPrice, "Ending price cannot be bigger");

        if (startingPrice == endingPrice || currTime > endingTimestamp) {
            return endingPrice;
        }

        uint256 diff = startingPrice - endingPrice;
        uint256 decrements = (currTime - startingTimestamp) /
            TIME_PER_DECREMENT;
        if (decrements == 0) {
            return startingPrice;
        }

        // decrements will equal 0 before totalDecrements does so we will not divide by 0
        uint256 totalDecrements = (endingTimestamp - startingTimestamp) /
            TIME_PER_DECREMENT;

        return startingPrice - (diff / totalDecrements) * decrements;
    }

    /**
     * @dev Sets secondary BPS amount
     */
    function _setRoyaltiesBPS(uint256 newBPS) internal {
        require(
            ownerRoyaltyBPS <= MAX_SECONDARY_BPS,
            "Cannot take more than 10% of secondaries"
        );
        ownerRoyaltyBPS = newBPS;
    }

    /**
     * @dev Sets primary revenue share
     */
    function _setRevenueShare(
        address[2] memory newAddresses,
        uint256[2] memory newBPS
    ) internal {
        require(
            newBPS[0] + newBPS[1] <= MAX_ROYALTIES_BPS,
            "Revenue share too high"
        );
        revenueShare = newAddresses;
        revenueShareBPS = newBPS;
    }

    /**
     * @dev Checks if an address is either the owner, or the approved alternate signer.
     */
    function _checkValidSigner(address signer) internal view {
        require(
            signer == owner() || signer == alternateSignerAddress,
            "Not valid signer."
        );
    }

    /**
     * @dev First checks if a sale is valid by checking that the hash has not been cancelled or already completed
     * and that the correct address has given the signature. If both checks pass we mark the hash as complete and
     * emit an event.
     */
    function _markHashSold(
        address seller,
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps,
        uint256 salePrice,
        bytes memory signature
    ) internal {
        bytes32 hash = _hashToCheckForSale(
            seller,
            version,
            nonce,
            tokenId,
            pricesAndTimestamps
        );
        require(!_cancelledOrFinalizedSales[hash], "Sale no longer active");
        require(
            hash.recover(signature) == seller,
            "Not signed by current seller"
        );
        _cancelledOrFinalizedSales[hash] = true;

        emit SaleCompleted(tokenId, salePrice, seller, _msgSender(), hash);
    }

    /**
     * @dev Hash an order, returning the hash that a client must sign, including the standard message prefix
     * @return Hash of message prefix and order hash per Ethereum format
     */
    function _hashToCheckForSale(
        address owner,
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps
    ) internal view returns (bytes32) {
        return
            ECDSA.toEthSignedMessageHash(
                _hashForSale(
                    owner,
                    version,
                    nonce,
                    tokenId,
                    pricesAndTimestamps
                )
            );
    }

    /**
     * @dev Hash an order, returning the hash that a client must sign, including the standard message prefix
     * @return Hash of message prefix and order hash per Ethereum format
     */
    function _hashForSale(
        address owner,
        uint256 version,
        uint256 nonce,
        uint256 tokenId,
        uint256[4] memory pricesAndTimestamps
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    address(this),
                    block.chainid,
                    owner,
                    version,
                    nonce,
                    tokenId,
                    pricesAndTimestamps
                )
            );
    }
}

/**
 * @dev This implements a lazy-minted, randomized collection of ERC721Marketplace.
 * It requires that the creator knows the total number of NFTs they want and has an IPFS
 * hash that is a directory with all the tokenIds from 0 to the #NFTs - 1.
 *
 * It has two main methods to lazy-mint, one allows the owner or alternate signer to approve single use signatures
 * for specific wallet addresses and the other allows a general mint signature that anyone can use.
 *
 * Minting from this collection is always random, this can be done either with a reveal
 * mechanism that has a random offset, or on-chain randomness if the collection is already revealed.
 */
contract ERC721RandomizedCollectionV2 is ERC721Marketplace {
    using ECDSA for bytes32;
    using Strings for uint256;

    bool public burnable;
    bool private hasInit = false;

    uint256 public constant MAX_SUPPLY_LIMIT = 10**9;
    uint256 public maxSupply;
    // Limits how much any single transaction can be
    uint256 public transactionMax;
    // Limits how much any single wallet can mint on a collection.
    uint256 public maxMint;

    // Used to shuffle tokenURI upon reveal
    uint256 public offset;

    // Mapping to enable constant time onchain randomness
    uint256[MAX_SUPPLY_LIMIT] private indices;
    string private ipfsHash;

    // Randomized Collection Events
    event Minted(
        address indexed buyer,
        uint256 amount,
        uint256 unitPrice,
        bytes32 hash
    );
    event IpfsRevealed(string ipfsHash, bool locked);

    /**
     * @dev Constructor function
     */
    constructor(
        bool[2] memory bools,
        address[3] memory addresses,
        uint256[6] memory uints,
        string[3] memory strings
    ) ERC721(strings[0], strings[1]) {
        addresses[0] = _msgSender();
        _init(bools, addresses, uints, strings);
    }

    function init(
        bool[2] memory bools,
        address[3] memory addresses,
        uint256[6] memory uints,
        string[3] memory strings
    ) external {
        _init(bools, addresses, uints, strings);
    }

    function _init(
        bool[2] memory bools,
        address[3] memory addresses,
        uint256[6] memory uints,
        string[3] memory strings
    ) internal {
        require(!hasInit, "Already has be initiated");
        hasInit = true;

        burnable = bools[0];
        _notSequentialMint = bools[1];

        _owner = msg.sender;
        address[2] memory revenueShare = [addresses[0], addresses[1]];
        alternateSignerAddress = addresses[2];

        _setRoyaltiesBPS(uints[0]);
        _setRevenueShare(revenueShare, [uints[1], uints[2]]);
        maxSupply = uints[3];
        require(maxSupply < MAX_SUPPLY_LIMIT, "Collection is too big");

        // Do not allow more than 100 mints a transaction so users cannot exceed gas limit
        if (uints[4] == 0 || uints[4] >= 25000) {
            transactionMax = 25000;
        } else {
            transactionMax = uints[4];
        }
        maxMint = uints[5];

        _name = strings[0];
        _symbol = strings[1];
        ipfsHash = strings[2];
        if (_notSequentialMint) {
            emit IpfsRevealed(ipfsHash, false);
        }
    }

    function isRevealed() external view returns (bool) {
        return _notSequentialMint;
    }

    /**
     * @dev If this collection was created with burnable on, owners of tokens
     * can use this method to burn their tokens. Easely will keep track of
     * burns in case creators want to reward users for burning tokens.
     */
    function burn(uint256 tokenId) external {
        require(burnable, "Tokens from this collection are not burnable");
        _burn(tokenId);
    }

    /**
     * @dev Method used if the creator wants to keep their collection hidden until
     * a later release date. On reveal, a creator can decide if they want to
     * lock the unminted tokens or enable them for on-chain randomness minting.
     *
     * IMPORTANT - this function can only be called ONCE, if a wrong IPFS hash
     * is submitted by the owner, it cannot ever be switched to a different one.
     */
    function lockTokenURI(string calldata revealIPFSHash, bool lockOnReveal)
        external
        onlyOwner
    {
        require(!_notSequentialMint, "The token URI has already been set");
        offset = _random(maxSupply);
        ipfsHash = revealIPFSHash;
        _notSequentialMint = true;

        if (lockOnReveal) {
            // This will lock the unminted tokens at reveal time
            maxSupply = _nextSequential;
        }

        _totalMinted = _nextSequential;
        emit IpfsRevealed(revealIPFSHash, lockOnReveal);
    }

    /**
     * @dev tokenURI of a tokenId, will change to include the tokeId and an offset in
     * the URI once the collection has been revealed.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_notSequentialMint) {
            return string(abi.encodePacked(_baseURI(), ipfsHash));
        }

        require(_exists(tokenId), "URI query for nonexistent token");

        uint256 offsetId = (tokenId + offset) % maxSupply;
        return
            string(
                abi.encodePacked(_baseURI(), ipfsHash, "/", offsetId.toString())
            );
    }

    /**
     * @dev Hash that the owner or approved alternate signer then sign that the approved buyer
     * can use in order to call the {mintAllow} method.
     */
    function hashToSignForAllowList(
        address allowedAddress,
        uint256 version,
        uint256 nonce,
        uint256 price,
        uint256 amount
    ) external view returns (bytes32) {
        _checkValidSigner(_msgSender());
        return _hashForAllowList(allowedAddress, version, nonce, price, amount);
    }

    /**
     * @dev A way to invalidate a signature so the given params cannot be used in the {mintAllow} method.
     */
    function cancelAllowList(
        address allowedAddress,
        uint256 version,
        uint256 nonce,
        uint256 price,
        uint256 amount
    ) external {
        _checkValidSigner(_msgSender());
        bytes32 hash = _hashToCheckForAllowList(
            allowedAddress,
            version,
            nonce,
            price,
            amount
        );
        _cancelledOrFinalizedSales[hash] = true;
        emit SaleCancelled(_msgSender(), hash);
    }

    /**
     * @dev Allows a user with an approved signature to mint at a price and quantity specified by the
     * contract. A user is still limited by totalSupply, transactionMax, and mintMax if populated.
     * signing with amount = 0 will allow any buyAmount less than the other limits.
     */
    function mintAllow(
        address allowedAddress,
        uint256 version,
        uint256 nonce,
        uint256 price,
        uint256 amount,
        uint256 buyAmount,
        bytes memory signature
    ) external payable {
        require(
            totalMinted() + buyAmount <= maxSupply,
            "Over token supply limit"
        );
        require(buyAmount == amount || amount == 0, "Over signature amount");
        require(buyAmount <= transactionMax, "Over transaction limit");
        require(
            version == _addressToActiveVersion[owner()],
            "This presale version is disabled"
        );
        require(allowedAddress == _msgSender(), "Invalid sender");

        uint256 totalPrice = price * buyAmount;
        require(msg.value >= totalPrice, "Msg value too small");

        bytes32 hash = _hashToCheckForAllowList(
            allowedAddress,
            version,
            nonce,
            price,
            amount
        );
        require(
            !_cancelledOrFinalizedSales[hash],
            "Signature no longer active"
        );
        address signer = hash.recover(signature);
        _checkValidSigner(signer);
        _cancelledOrFinalizedSales[hash] = true;

        _mintRandom(_msgSender(), buyAmount);
        emit Minted(_msgSender(), buyAmount, price, hash);
        payable(_msgSender()).transfer(msg.value - totalPrice);
    }

    /**
     * @dev Hash that the owner or approved alternate signer then sign that buyers use
     * in order to call the {mint} method.
     */
    function hashToSignForMint(
        uint256 version,
        uint256 amount,
        uint256[4] memory pricesAndTimestamps
    ) external view returns (bytes32) {
        _checkValidSigner(_msgSender());
        require(amount <= transactionMax, "Over transaction limit");

        return _hashForMint(version, amount, pricesAndTimestamps);
    }

    /**
     * @dev A way to invalidate a signature so the given params cannot be used in the {mint} method.
     */
    function cancelMint(
        uint256 version,
        uint256 amount,
        uint256[4] memory pricesAndTimestamps
    ) external {
        _checkValidSigner(_msgSender());
        bytes32 hash = _hashToCheckForMint(
            version,
            amount,
            pricesAndTimestamps
        );
        _cancelledOrFinalizedSales[hash] = true;
        emit SaleCancelled(_msgSender(), hash);
    }

    /**
     * @dev Allows anyone to buy an amount of tokens at a price which matches
     * the signature that the owner or alternate signer has approved
     */
    function mint(
        uint256 version,
        uint256 amount,
        uint256 buyAmount,
        uint256[4] memory pricesAndTimestamps,
        bytes memory signature
    ) external payable {
        require(
            totalMinted() + buyAmount <= maxSupply,
            "Over token supply limit"
        );
        require(buyAmount == amount || amount == 0, "Over signature amount");
        require(buyAmount <= transactionMax, "Over transaction limit");
        require(version == _addressToActiveVersion[owner()], "Invalid version");

        uint256 unitPrice = _currentPrice(pricesAndTimestamps);
        uint256 totalPrice = buyAmount * unitPrice;
        require(msg.value >= totalPrice, "Msg value too small");

        bytes32 hash = _hashToCheckForMint(
            version,
            amount,
            pricesAndTimestamps
        );
        require(
            !_cancelledOrFinalizedSales[hash],
            "Signature no longer active"
        );
        address signer = hash.recover(signature);
        _checkValidSigner(signer);

        _mintRandom(_msgSender(), buyAmount);
        emit Minted(_msgSender(), buyAmount, totalPrice, hash);

        payable(_msgSender()).transfer(msg.value - totalPrice);
    }

    /**
     * @dev Hash an order that we need to check against the signature to see who the signer is.
     * see {_hashForAllowList} to see the hash that needs to be signed.
     */
    function _hashToCheckForAllowList(
        address allowedAddress,
        uint256 nonce,
        uint256 version,
        uint256 price,
        uint256 amount
    ) internal view returns (bytes32) {
        return
            ECDSA.toEthSignedMessageHash(
                _hashForAllowList(allowedAddress, nonce, version, price, amount)
            );
    }

    /**
     * @dev Hash that the owner or alternate wallet must sign to enable a {mintAllow} for a user
     * @return Hash of message prefix and order hash per Ethereum format
     */
    function _hashForAllowList(
        address allowedAddress,
        uint256 nonce,
        uint256 version,
        uint256 price,
        uint256 amount
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    address(this),
                    block.chainid,
                    owner(),
                    allowedAddress,
                    nonce,
                    version,
                    price,
                    amount
                )
            );
    }

    /**
     * @dev Hash an order that we need to check against the signature to see who the signer is.
     * see {_hashForMint} to see the hash that needs to be signed.
     */
    function _hashToCheckForMint(
        uint256 version,
        uint256 amount,
        uint256[4] memory pricesAndTimestamps
    ) internal view returns (bytes32) {
        return
            ECDSA.toEthSignedMessageHash(
                _hashForMint(version, amount, pricesAndTimestamps)
            );
    }

    /**
     * @dev Hash that the owner or alternate wallet must sign to enable {mint} for all users
     */
    function _hashForMint(
        uint256 version,
        uint256 amount,
        uint256[4] memory pricesAndTimestamps
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    address(this),
                    block.chainid,
                    owner(),
                    amount,
                    pricesAndTimestamps,
                    version
                )
            );
    }

    /// @notice Generates a pseudo random index of our tokens that has not been used so far
    function _mintRandomIndex(address buyer, uint256 amount) internal {
        //  number of tokens left to create
        uint256 supplyLeft = maxSupply - _totalMinted;

        for (uint256 i = 0; i < amount; i++) {
            // generate a random index
            uint256 index = _random(supplyLeft);
            uint256 tokenAtPlace = indices[index];

            uint256 tokenId;
            // if we havent stored a replacement token...
            if (tokenAtPlace == 0) {
                //... we just return the current index
                tokenId = index;
            } else {
                // else we take the replace we stored with logic below
                tokenId = tokenAtPlace;
            }

            // get the highest token id we havent handed out
            uint256 lastTokenAvailable = indices[supplyLeft - 1];
            // we need to store a replacement token for the next time we roll the same index
            // if the last token is still unused...
            if (lastTokenAvailable == 0) {
                // ... we store the last token as index
                indices[index] = supplyLeft - 1;
            } else {
                // ... we store the token that was stored for the last token
                indices[index] = lastTokenAvailable;
            }

            _safeMint(buyer, tokenId + _nextSequential);
            supplyLeft--;
        }

        _balances[buyer] = AddressData(
            _balances[buyer].balance + uint128(amount),
            _balances[buyer].numberMinted + uint128(amount)
        );
    }

    /// @notice Generates a pseudo random number based on arguments with decent entropy
    /// @param max The maximum value we want to receive
    /// @return A random number less than the max
    function _random(uint256 max) internal view returns (uint256) {
        if (max == 0) {
            return 0;
        }

        uint256 rand = uint256(
            keccak256(
                abi.encode(
                    msg.sender,
                    block.difficulty,
                    block.timestamp,
                    blockhash(block.number - 1)
                )
            )
        );
        return rand % max;
    }

    /**
     * @dev Wrapper around {_mintRandomIndex} that incrementally if the collection has not
     * been revealed yet, which also checks the buyer has not exceeded maxMint count
     */
    function _mintRandom(address buyer, uint256 amount) internal {
        require(
            maxMint == 0 || _balances[buyer].numberMinted + amount <= maxMint,
            "Buyer over mint maximum"
        );
        if (_notSequentialMint) {
            _mintRandomIndex(buyer, amount);
            _totalMinted += amount;
        } else {
            _safeMintSequential(buyer, amount);
        }
    }
}



}
