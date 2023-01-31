// ////-License-Identifier: MIT
pragma solidity 0.8.7;

/// @dev Proxy for NFT Factory
contract Proxy {

    // Storage for this proxy
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    bytes32 private constant ADMIN_SLOT          = bytes32(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);

    constructor(address impl) {
        require(impl != address(0));

        _setSlotValue(IMPLEMENTATION_SLOT, bytes32(uint256(uint160(impl))));
        _setSlotValue(ADMIN_SLOT, bytes32(uint256(uint160(msg.sender))));
    }

    function setImplementation(address newImpl) public {
        require(msg.sender == _getAddress(ADMIN_SLOT));
        _setSlotValue(IMPLEMENTATION_SLOT, bytes32(uint256(uint160(newImpl))));
    }
    
    function implementation() public view returns (address impl) {
        impl = address(uint160(uint256(_getSlotValue(IMPLEMENTATION_SLOT))));
    }

    function _getAddress(bytes32 key) internal view returns (address add) {
        add = address(uint160(uint256(_getSlotValue(key))));
    }

    function _getSlotValue(bytes32 slot_) internal view returns (bytes32 value_) {
        assembly {
            value_ := sload(slot_)
        }
    }

    function _setSlotValue(bytes32 slot_, bytes32 value_) internal {
        assembly {
            sstore(slot_, value_)
        }
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

    receive() external payable {}


    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _delegate(_getAddress(IMPLEMENTATION_SLOT));
    }

}

// : MIT
pragma solidity 0.8.7;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// Inspired by Solmate: https://github.com/Rari-Capital/solmate
/// Developed by 0xBasset

contract DAPE {

    /*///////////////////////////////////////////////////////////////
                                  CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 constant public PERIOD = 15 days;
    uint256 constant public BONUS  = 5_000;
    uint256 constant public DAILY_RATE = 1000 ether;

    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*///////////////////////////////////////////////////////////////
                             ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    bool public paused;

    ERC721Like public dapeNft;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public isMinter;

    mapping(uint256 => Claim) public claims;

    struct Claim {
       address owner;
       uint48  start;
       uint48  last;
    }

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    function name() external pure returns (string memory) {
        return "$DAPE";
    }

    function symbol() external pure returns (string memory) {
        return "$DAPE";
    }
    
    function decimals() external pure returns (uint8) {
        return 18;
    }

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    
    function initialize(address dapeNft_) external { 
        require(msg.sender == _owner(), "not allowed");

        dapeNft = ERC721Like(dapeNft_);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        balanceOf[msg.sender] -= value;

        // This is safe because the sum of all user
        // balances can't exceed type(uint256).max!
        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);


        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }

        balanceOf[from] -= value;

        // This is safe because the sum of all user
        // balances can't exceed type(uint256).max!
        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);
        return true;
    }

    /*///////////////////////////////////////////////////////////////
                              STAKING
    //////////////////////////////////////////////////////////////*/

    function claimMany(uint256[] calldata ids_) external {
        for (uint256 i = 0; i < ids_.length; i++) {
            claim(ids_[i]);
        }
    }

    function claim(uint256 id_) public {
        require(!paused, "claims are paused");

        Claim memory cl = claims[id_];

        uint256 amt = _claimable(cl.start, cl.last);

        claims[id_].last = uint48(block.timestamp);
        _mint(cl.owner, amt);
    }

    function claimable(uint256 id_) public view returns (uint256 amt) {
        Claim memory cl = claims[id_];
        return _claimable(cl.start, cl.last);
    }

    function _claimable(uint256 claimStart, uint256 claimLast) internal view returns (uint256 amt) {
        // Get current tranche
        uint256 lastTranche = _tranche(claimStart, claimLast);
        uint256 currTranche = _tranche(claimStart, block.timestamp); 
        
        if (lastTranche != currTranche) {
            // If we are in different tranches, the first step is to get the remaining amount of last tranche
            (,uint256 end) = _boundaries(claimStart, lastTranche);
            amt           += _amountFor(end - claimLast, lastTranche);

            // Now we get the corresponding amount for current tranche
            (uint256 start, ) = _boundaries(claimStart, currTranche);
            amt              += _amountFor(block.timestamp - start, currTranche); 

            // For every thanche between lastTranch and currTranche, we get the full amount
            for (uint256 i = lastTranche + 1; i < currTranche; i++) {
                amt += _amountFor(PERIOD, i);
            }

        } else {
            amt = _amountFor(block.timestamp - claimLast, currTranche);
        }
    }

    function _tranche(uint256 start, uint256 time) internal pure returns (uint256) {
        return (time - start) / PERIOD;
    }

    function _amountFor(uint256 interval, uint256 tranche) internal pure returns (uint256) {
        return interval * _rate(tranche) / 1 days;
    }

    function _boundaries(uint256 start, uint256 tranche) internal pure returns (uint256 beginning, uint256 end) {
        beginning = start + PERIOD * tranche;
        end       = beginning + PERIOD;
    }

    function _rate(uint256 tranche) internal pure returns (uint256 rate) {
        rate = DAILY_RATE + ((tranche > 5 ? 5 : tranche) * BONUS * DAILY_RATE / 100_000);
    }

    function stake(uint256[] calldata ids) external {
        for (uint256 i = 0; i < ids.length; i++) {
            require(ERC721Like(dapeNft).transferFrom(msg.sender, address(this), ids[i]), "Transfer failed");
            claims[ids[i]] = Claim(msg.sender, uint48(block.timestamp), uint48(block.timestamp));
        }
    }

    function unstake(uint256[] calldata ids) external {
        for (uint256 i = 0; i < ids.length; i++) {
            require(claims[ids[i]].owner == msg.sender, "not owner");
            require(ERC721Like(dapeNft).transferFrom(address(this), msg.sender, ids[i]), "Transfer failed");

            claim(ids[i]);

            delete claims[ids[i]];
        }
    }

    function onERC721Received(address,address,uint,bytes calldata) external pure returns(bytes4){
        return 0x150b7a02;
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN PRIVILEGE
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 value) external {
        require(isMinter[msg.sender], "FORBIDDEN TO MINT");
        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(isMinter[msg.sender], "FORBIDDEN TO BURN");
        _burn(from, value);
    }

    /*///////////////////////////////////////////////////////////////
                         Ruler Function
    //////////////////////////////////////////////////////////////*/

    function setMinter(address minter, bool status) external {
        require(msg.sender == _owner(), "not allowed");

        isMinter[minter] = status;
    }

    function setRuler(address ruler_) external {
        require(msg.sender == _owner(), "not allowed");

        bytes32 slot = bytes32(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);
        assembly {
            sstore(slot, ruler_)
        }
    }

    function setPaused(bool paused_) external {
        require(msg.sender == _owner(), "not allowed");

        paused = paused_;
    }

    /*///////////////////////////////////////////////////////////////
                          INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 value) internal {
        totalSupply += value;

        // This is safe because the sum of all user
        // balances can't exceed type(uint256).max!
        unchecked {
            balanceOf[to] += value;
        }

        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] -= value;

        // This is safe because a user won't ever
        // have a balance larger than totalSupply!
        unchecked {
            totalSupply -= value;
        }

        emit Transfer(from, address(0), value);
    }

    function _owner() internal view returns (address owner_) {
        bytes32 slot = bytes32(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);
        assembly {
            owner_ := sload(slot)
        }
    } 
}

interface ERC721Like {
    function transferFrom(address from, address to, uint256 id) external returns (bool success);
    function ownerOf(uint256 id_) external view returns(address);
}



}
