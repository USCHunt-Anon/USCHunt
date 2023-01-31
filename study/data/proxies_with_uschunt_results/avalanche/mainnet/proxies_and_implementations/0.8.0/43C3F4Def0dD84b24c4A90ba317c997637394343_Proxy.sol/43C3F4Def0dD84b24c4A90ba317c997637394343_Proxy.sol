// ////-License-Identifier: MIT
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
contract Proxy {
  address implementation_;
  address public admin;

  constructor(address impl) {
    implementation_ = impl;
    admin = msg.sender;
  }

  receive() external payable {}

  function setImplementation(address newImpl) public {
    require(msg.sender == admin);
    implementation_ = newImpl;
  }

  function implementation() public view returns (address impl) {
    impl = implementation_;
  }

  function transferAdmin(address newAdmin) external {
    require(msg.sender == admin);
    admin = newAdmin;
  }

  /**
   * @dev Delegates the current call to `implementation`.
   *
   * This function does not return to its internall call site, it will return directly to the external caller.
   */
  function _delegate(address implementation__) internal virtual {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation__, 0, calldatasize(), 0, 0)

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
  function _implementation() internal view returns (address) {
    return implementation_;
  }

  /**
   * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
   * function in the contract matches the call data.
   */
  fallback() external payable virtual {
    _delegate(_implementation());
  }
}

// : MIT
pragma solidity ^0.8.0;

interface IUtility {
  function factory() external view returns (address);

  function ownerOf(uint256 tokenId) external view returns (address);

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function isPublic(uint256 tokenId) external view returns (bool);

  function setIndex(uint256 index) external;
}


// : MIT
pragma solidity ^0.8.0;

//import"./interfaces/IUtility.sol";

contract Utilitybia {
  string public constant name = "Utilitybia V2";

  event StoreUpdated(address store);
  event UtilityAdded(uint256 index, address indexed utility);

  address implementation_;
  address public owner;

  bool public initialized;

  address public store;
  address[] public utilities;

  function initialize() external {
    require(msg.sender == owner);
    require(!initialized);
    initialized = true;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setStore(address _store) external onlyOwner {
    store = _store;
    emit StoreUpdated(_store);
  }

  function totalUtilities() external view returns (uint256 total) {
    total = utilities.length;
  }

  function registerUtility(address utility) external onlyOwner {
    require(IUtility(utility).factory() == address(this));
    uint256 utilityIndex = utilities.length;
    IUtility(utility).setIndex(utilityIndex);
    utilities.push(utility);
    emit UtilityAdded(utilityIndex, utility);
  }
}



}
