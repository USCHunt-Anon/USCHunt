/**
 *Submitted for verification at BscScan.com on 2021-09-04
*/

contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
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
    function _implementation() internal pure returns (address) {
        return 0x2c6344B5410122b9564ED60d175069eaa35c2c38;
    }

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
    fallback() external payable {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal {}
}

contract Vault {
    
    enum Type {
        Deposit,
        Withdrawal
    }
    
    struct Transaction {
        address user;
        uint256 timestamp;
        Type transactionType;
        uint256 amount;
    }
    
    address public lastCaller;
    
    uint256 private numberOne;
    bool private boolean;
    
    uint256 public transactionLastId;
    mapping(uint256 => Transaction) public transactions;
    
    function getNumberOne() external view returns(uint256) {
        return numberOne;
    }
    
    function getBoolean() external view returns(bool) {
        return boolean;
    }
    
    function getTranasction(uint256 id) external view returns(Transaction memory) {
        return transactions[id];
    }
    
    function setNumberOne(uint256 _numberOne) external {
        numberOne = _numberOne;
        lastCaller = msg.sender;
    }
    
    function setBoolean(bool _boolean) external {
        boolean = _boolean;
        lastCaller = msg.sender;
    }
    
    function addNewTransaction(Transaction memory transaction) external {
        transactions[transactionLastId] = transaction;
        
        transactionLastId += 1;
        
        lastCaller = msg.sender;
    }
    
}

contract LogicContract {
    uint public num;
    address public sender;
    uint public value;
    
    Vault public vault;
    
    function initialize(address _vault) external {
        vault = Vault(_vault);
    }
    
    function getNumberOne() external view returns(uint256 numberOne) {
        return vault.getNumberOne();
    }
    
    function getBoolean() external view returns(bool boolean) {
        return vault.getBoolean();
    }
    
    function getTranasction(uint256 id) external view returns(Vault.Transaction memory transaction) {
        return vault.getTranasction(id);
    }
    
    
    function setNumberOne(uint256 _numberOne) external {
        vault.setNumberOne(_numberOne);
    }
    
    function setBoolean(bool _boolean) external {
        vault.setBoolean(_boolean);
    }
    
    function makeTransaction(uint256 amount) external {
        vault.addNewTransaction(Vault.Transaction(msg.sender,block.timestamp, Vault.Type(0), amount));
    }

    function setVars(uint _num) external payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}