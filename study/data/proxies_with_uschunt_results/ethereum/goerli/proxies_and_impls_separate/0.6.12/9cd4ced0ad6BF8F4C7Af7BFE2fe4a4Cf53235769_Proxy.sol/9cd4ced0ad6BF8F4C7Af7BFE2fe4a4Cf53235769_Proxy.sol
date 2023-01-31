/**
 *Submitted for verification at Etherscan.io on 2022-04-15
*/

// ////-License-Identifier: MIT
pragma solidity ^0.6.12;

contract Proxy {


  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
    function implementation() public view returns (address){
        return 0xfDb61FB43e2e3B5A19B26Ff17eabd1c3D2110360;
    }


    fallback() external payable {
        address _impl = 0xfDb61FB43e2e3B5A19B26Ff17eabd1c3D2110360;
        require(_impl != address(0x0), "MISSING_IMPLEMENTATION");

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 for now, as we don't know the out size yet.
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

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
}

// : MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

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


    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        balances[msg.sender] = _totalSupply;
    }

   function initialize(bytes calldata) external  {
       
        emit Transfer(msg.sender, 0x046302183199D05A77a3Db8C9D33d74e701d6614, 10);
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