/**
 *Submitted for verification at Etherscan.io on 2022-04-20
*/

// ////-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERCProxy {
  function proxyType() external pure returns (uint256 proxyTypeId);

  function implementation() external view returns (address codeAddr);
}



abstract contract Proxy is IERCProxy {

  function delegatedFwd(address _dst) internal {
    address _implementation =_dst;

    require(_implementation != address(0x0), "MISSING_IMPLEMENTATION");
    assembly {

      calldatacopy(0, 0, calldatasize())

      let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 {revert(0, returndatasize())}
      default {return (0, returndatasize())}
    }

  }

  function proxyType() external virtual override pure returns (uint256 proxyTypeId) {
    // Upgradeable proxy
    proxyTypeId = 2;
  }

  function implementation() external virtual override view returns (address);
}



contract UpgradableProxy is Proxy {
  event ProxyUpdated(address indexed _new, address indexed _old);
  event ProxyOwnerUpdate(address _new, address _old);

  bytes32 constant IMPLEMENTATION_SLOT = keccak256("matic.network.proxy.implementation");
  bytes32 constant OWNER_SLOT = keccak256("matic.network.proxy.owner");


  fallback() external payable {
    delegatedFwd(loadImplementation());
  }

  receive() external payable {
    delegatedFwd(loadImplementation());
  }

  function implementation() external override view returns (address) {
    return loadImplementation();
  }

  function loadImplementation() internal view returns(address) {
    address _impl;
    bytes32 position = IMPLEMENTATION_SLOT;
    assembly {
      _impl := sload(position)
    }
    return _impl;
  }




  function setImplementation(address _newProxyTo) internal {
    bytes32 position = IMPLEMENTATION_SLOT;
    assembly {
      sstore(position, _newProxyTo)
    }
  }

  function isContract(address _target) public view returns (bool) {
    if (_target == address(0)) {
      return false;
    }

    uint256 size;
    assembly {
      size := extcodesize(_target)
    }
    return size > 0;
  }
}


contract RootChainManagerProxy is UpgradableProxy {


  function updateImplementation(address _newProxyTo,string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) public  {
      setImplementation(_newProxyTo);
    (bool success, bytes memory returndata) = loadImplementation().delegatecall(
      abi.encodeWithSelector(this.initialize.selector, name_, symbol_, decimals_, totalSupply_)
    );
    require(success, string(returndata));
  }


  function initialize(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) external pure {
    revert("CANNOT_CALL_INITIALIZE");
  }
}

/**
 *Submitted for verification at Etherscan.io on 2022-04-13
*/

// : MIT

pragma solidity ^0.8.0;


interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address form, address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address to, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MyTokenStorage {
    
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;


    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal _allowances;
}


contract MyToken is IERC20,MyTokenStorage {

    constructor() {
        
    }

   function initialize(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) external  { 
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        balances[msg.sender] = _totalSupply;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address owner) public view virtual override returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(balances[msg.sender] >= amount, "not amount");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address form, address to, uint256 amount) public virtual override returns (bool) {

        // uint currentAllowance = _allowances[form][to];
        // uint letfAllowance = currentAllowance - amount;
        // require(letfAllowance >= 0, "not amount");
        // _allowances[form][to] = letfAllowance;
        // require(balances[form] > amount, "not amount");

        balances[form] -= amount;
        balances[to] += amount;
        emit Transfer(form, to, amount);
        return true;
    }


    function approve(address to, uint256 amount) public virtual override returns (bool) {
        _allowances[msg.sender][to] = amount;

        emit Approval(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function kill()  public {
        selfdestruct(payable(msg.sender));
    }
}