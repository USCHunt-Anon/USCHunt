/**
 *Submitted for verification at snowtrace.io on 2021-12-28
*/

pragma solidity >=0.7.6 <0.8.0;

// EIP-3561 trust minimized proxy implementation https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3561.md

contract SnowflakeTrustMinimizedProxy{ // THE CODE FITS ON THE SCREEN UNBELIAVABLE LETS STOP ENDLESS SCROLLING UP AND DOWN
	event Upgraded(address indexed toLogic);
	event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
	event NextLogicDefined(address indexed nextLogic, uint earliestArrivalBlock);
	event ProposingUpgradesRestrictedUntil(uint block, uint nextProposedLogicEarliestArrival);
	event NextLogicCanceled();
	event TrustRemoved();

	bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
	bytes32 internal constant LOGIC_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
	bytes32 internal constant NEXT_LOGIC_SLOT = 0xb182d207b11df9fb38eec1e3fe4966cf344774ba58fb0e9d88ea35ad46f3601e;
	bytes32 internal constant NEXT_LOGIC_BLOCK_SLOT = 0x96de003e85302815fe026bddb9630a50a1d4dc51c5c355def172204c3fd1c733;
	bytes32 internal constant PROPOSE_BLOCK_SLOT = 0xbc9d35b69e82e85049be70f91154051f5e20e574471195334bde02d1a9974c90;
	bytes32 internal constant TRUST_MINIMIZED_SLOT = 0xa0ea182b754772c4f5848349cff27d3431643ba25790e0c61a8e4bdf4cec9201;

	constructor() payable {
		require(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1) && LOGIC_SLOT==bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) // this require is simply against human error, can be removed if you know what you are doing
		&& NEXT_LOGIC_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogic')) - 1) && NEXT_LOGIC_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.nextLogicBlock')) - 1)
		&& PROPOSE_BLOCK_SLOT == bytes32(uint256(keccak256('eip1984.proxy.proposeBlock')) - 1)/* && DEADLINE_SLOT == bytes32(uint256(keccak256('eip1984.proxy.deadline')) - 1)*/
		&& TRUST_MINIMIZED_SLOT == bytes32(uint256(keccak256('eip1984.proxy.trustMinimized')) - 1));
		_setAdmin(msg.sender);
	}

	modifier ifAdmin() {if (msg.sender == _admin()) {_;} else {_fallback();}}
	function _logic() internal view returns (address logic) {assembly { logic := sload(LOGIC_SLOT) }}
	function _nextLogic() internal view returns (address nextLogic) {assembly { nextLogic := sload(NEXT_LOGIC_SLOT) }}
	function _proposeBlock() internal view returns (uint bl) {assembly { bl := sload(PROPOSE_BLOCK_SLOT) }}
	function _nextLogicBlock() internal view returns (uint bl) {assembly { bl := sload(NEXT_LOGIC_BLOCK_SLOT) }}
	function _trustMinimized() internal view returns (uint tm) {assembly { tm := sload(TRUST_MINIMIZED_SLOT) }}
	function _admin() internal view returns (address adm) {assembly { adm := sload(ADMIN_SLOT) }}
	function _setAdmin(address newAdm) internal {assembly {sstore(ADMIN_SLOT, newAdm)}}
	function changeAdmin(address newAdm) external ifAdmin {emit AdminChanged(_admin(), newAdm);_setAdmin(newAdm);}
	function upgrade() external ifAdmin {require(block.number>=_nextLogicBlock(),"too soon");address logic;assembly {logic := sload(NEXT_LOGIC_SLOT) sstore(LOGIC_SLOT,logic)}emit Upgraded(logic);}
	fallback () external payable {_fallback();}
	receive () external payable {_fallback();}
	function _fallback() internal {require(msg.sender != _admin());_delegate(_logic());}
	function cancelUpgrade() external ifAdmin {address logic; assembly {logic := sload(LOGIC_SLOT)sstore(NEXT_LOGIC_SLOT, logic)}emit NextLogicCanceled();}
	function prolongLock(uint b) external ifAdmin {require(b > _proposeBlock(),"get maxxed"); assembly {sstore(PROPOSE_BLOCK_SLOT,b)} emit ProposingUpgradesRestrictedUntil(b,b+1296000);}
	function removeTrust() external ifAdmin {assembly{ sstore(TRUST_MINIMIZED_SLOT, 1) }emit TrustRemoved();} // before this called acts like a normal eip 1967 transparent proxy. after the deployer confirms everything is deployed correctly must be called
	function _updateBlockSlot() internal {uint nlb = block.number + 1296000; assembly {sstore(NEXT_LOGIC_BLOCK_SLOT,nlb)}}
	function _setNextLogic(address nl) internal {require(block.number >= _proposeBlock(),"too soon");_updateBlockSlot();assembly { sstore(NEXT_LOGIC_SLOT, nl)}emit NextLogicDefined(nl,block.number + 1296000);}

	function proposeToAndCall(address newLogic, bytes calldata data) payable external ifAdmin {
		if (_trustMinimized() == 0) {_updateBlockSlot();assembly {sstore(LOGIC_SLOT,newLogic)}emit Upgraded(newLogic);}	else{ _setNextLogic(newLogic);}
		(bool success,) = newLogic.delegatecall(data);require(success,"failed to call");
	}

    function viewSlots() external ifAdmin returns(address logic, address nextLogic, uint proposeBlock, uint nextLogicBlock, uint trustMinimized, address admin) {
        return (_logic(),_nextLogic(),_proposeBlock(),_nextLogicBlock(),_trustMinimized(),_admin());
    }

	function _delegate(address logic_) internal {
		assembly {
			calldatacopy(0, 0, calldatasize())
			let result := delegatecall(gas(), logic_, 0, calldatasize(), 0, 0)
			returndatacopy(0, 0, returndatasize())
			switch result
			case 0 { revert(0, returndatasize()) }
			default { return(0, returndatasize()) }
		}
	}
}

/**
 *Submitted for verification at snowtrace.io on 2022-01-07
*/

/**
 *Submitted for verification at snowtrace.io on 2021-12-30
*/

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Snowflake is Context, IERC20, IERC20Metadata {

    struct NodeEntity {
        string name;
        uint creationTime;
        uint epoch;
        uint bonus;
    }

    struct Epoch {
        uint reward;
        uint end;
    }

    mapping(address => NodeEntity[]) private _nodesOfUser;
    mapping(uint => Epoch) public epochs;
    uint256 public nodePrice;
    uint256 public rewardPerNode;
    uint256 public epochDuration;
    uint256 public maxNodes;

    bool public paused;
    bool public sniperTrap;
    bool public _init;

    uint256 public lastCreatedEpoch;

    uint256 public totalNodesCreated;
    uint256 public totalRewardStaked;

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    address public distributionPool;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;

    uint256 public cashoutFee;

    bool public swapping;
    bool private swapLiquify;

    address public MIM;
    address public liquidityManager;
    address public paymentSplitter;
    address private _owner;

    mapping(address => bool) private automatedMarketMakerPairs;
    mapping(address => bool) public isBlacklisted;
    mapping(address => uint) public initialMIM;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bool public tradingDisabled;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);


//============================open zeppelin only owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
//====================================================


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()]-amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender]-subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        //require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted address");
        if(paused){
            require(sender==owner()||recipient==owner());//migration to aletheo
        }
        if(sniperTrap==true&&sender==uniswapV2Pair){
            isBlacklisted[recipient] = true;
        }
        if(tradingDisabled){
            if (sender==uniswapV2Pair||recipient==uniswapV2Pair){
                require(sender==owner());//to add liquidity
            }
        }
        _balances[sender] = _balances[sender]-amount;
        _balances[recipient] = _balances[recipient]+amount;
        emit Transfer(sender, recipient, amount);
    }

    function setPaused(bool b) public onlyOwner {
        paused = b;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account]-amount;
        _totalSupply = _totalSupply-amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function init() public {
        //require(_init==true);
        //_init = false;
        //_name = "Snowflake";
        //_symbol = "SNOW";
        //_owner = 0xB23b6201D1799b0E8e209a402daaEFaC78c356Dc;
        //emit OwnershipTransferred(address(0), 0xB23b6201D1799b0E8e209a402daaEFaC78c356Dc);
        //nodePrice = 10e18;
        //rewardPerNode = 1e18;
        //epochDuration = 43200;// a day if a block is 2 seconds long
        //epochs[0].end = block.number+epochDuration;
        //epochs[0].reward = rewardPerNode;
        //liquidityPoolFee = 80;
        //rewardsFee = 0;
        //cashoutFee = 10;
        //maxNodes = 100;
        //address uniV2Router = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;//joe router
        //MIM = 0x130966628846BFd36ff31a822705796e8cb8C18D;//MIM
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniV2Router);
        //address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), MIM);
        //uniswapV2Router = _uniswapV2Router;
        //uniswapV2Pair = _uniswapV2Pair;
        //_setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        //_balances[owner()] = 5000000e18;
        //_totalSupply = 5000000e18;
        //emit Transfer(address(0), owner(), 5000000e18);
        //sniperTrap = true;
        //_approve(address(this), address(uniswapV2Router), 2**256-1);
        //IERC20(MIM).approve(address(uniswapV2Router), 2**256-1);
        //tradingDisabled = true;
    }

// private view
/*
    function _isNameAvailable(address account, string memory nodeName) private view returns (bool) {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        for (uint256 i = 0; i < nodes.length; i++) {
            if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
                return false;
            }
        }
        return true;
    }

    function _getNodeWithCreatime(NodeEntity[] storage nodes, uint256 _creationTime) private view returns (NodeEntity storage) {
        uint256 numberOfNodes = nodes.length;
        require(numberOfNodes > 0, "CASHOUT ERROR: You don't have nodes to cash-out");
        bool found = false;
        int256 index = _binary_search(nodes, 0, numberOfNodes, _creationTime);
        uint256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = uint256(index);
        }
        require(found, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[validIndex];
    }

    function _binary_search(NodeEntity[] memory arr, uint256 low, uint256 high, uint256 x) private view returns (int256) {
        if (high >= low) {
            uint256 mid = (high + low)/2;
            if (arr[mid].creationTime == x) {
                return int256(mid);
            } else if (arr[mid].creationTime > x) {
                return _binary_search(arr, low, mid - 1, x);
            } else {
                return _binary_search(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }

    function _uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
*/
    function _calculateReward(uint e) private view returns (uint reward, uint lastRewardedEpoch) {
        for(uint i = e; i<=lastCreatedEpoch; i++){
            if(block.number > epochs[i].end) {
                reward += epochs[i].reward;
                lastRewardedEpoch = i;
            }
        }
        return (reward, lastRewardedEpoch);
    }

// public view

    function getRewardAmountOf(address account) public view returns (uint256,uint lastRewardedEpoch) {
        uint256 rewardCount;
        uint r;
        NodeEntity[] storage nodes = _nodesOfUser[account];
        for (uint256 i = 0; i < nodes.length; i++) {
            (r,lastRewardedEpoch) = _calculateReward(nodes[i].epoch);
            rewardCount += r;
        }
        return (rewardCount,lastRewardedEpoch);
    }
/*
    function getRewardAmountOf(address account, uint256 _creationTime) public view returns (uint256,uint) {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(numberOfNodes > 0, "not enough nodes to cash-out");
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        (uint256 rewardNode,uint lastRewardedEpoch) = _calculateReward(node.epoch);
        return (rewardNode,lastRewardedEpoch);
    }

    function getNodesNames(address account) public view returns (string memory) {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory names = nodes[0].name;
        string memory separator = "#";
        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];
            names = string(abi.encodePacked(names, separator, _node.name));
        }
        return names;
    }

    function getNodesCreationTime(address account) public view returns (string memory) {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _creationTimes = _uint2str(nodes[0].creationTime);
        string memory separator = "#";
        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];
            _creationTimes = string(
                abi.encodePacked(
                    _creationTimes,
                    separator,
                    _uint2str(_node.creationTime)
                )
            );
        }
        return _creationTimes;
    }

    function getNodesRewardAvailable(address account) public view returns (string memory) {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        (uint r,)=_calculateReward(nodes[0].epoch);
        string memory _rewardsAvailable = _uint2str(r);
        string memory separator = "#";
        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];
            (r,)=_calculateReward(nodes[0].epoch);
            _rewardsAvailable = string(
                abi.encodePacked(
                    _rewardsAvailable,
                    separator,
                    _uint2str(r)
                )
            );
        }
        return _rewardsAvailable;
    }
/*
    function getNodesLastEpochs(address account) public view returns (string memory) {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _epochs = _uint2str(nodes[0].epoch);
        string memory separator = "#";
        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];
            _epochs = string(
                abi.encodePacked(_epochs, separator, _uint2str(_node.epoch))
            );
        }
        return _epochs;
    }
*/
    function getNodeNumberOf(address account) public view returns (uint256) {
        return _nodesOfUser[account].length;
    }
/*
// onlyOwner

    function changeNodePrice(uint256 newNodePrice) public onlyOwner {
        nodePrice = newNodePrice;
    }

    function changeRewardPerNode(uint256 newPrice) public onlyOwner {
        rewardPerNode = newPrice;
    }

    function changeEpochDuration(uint256 amountOfBlocks) public onlyOwner {
        epochDuration = amountOfBlocks;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router),"TKN: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), MIM);
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updateRewardsWallet(address wallet) external onlyOwner {
        distributionPool = wallet;
    }

    function setLiqudityManager(address wallet) external onlyOwner {
        liquidityManager = wallet;
    }

    function updateRewardsFee(uint256 value) external onlyOwner {
        rewardsFee = value;
    }

    function updateLiquiditFee(uint256 value) external onlyOwner {
        liquidityPoolFee = value;
    }

    function updateCashoutFee(uint256 value) external onlyOwner {
        cashoutFee = value;
    }

    function updateMaxNodes(uint256 value) external onlyOwner {
        maxNodes = value;
    }

    function disableSniperTrap() external onlyOwner {
        sniperTrap = false;
    }

    function enableTrading() external onlyOwner {
        tradingDisabled = false;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair,"TKN: TraderJoe pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistMalicious(address account, bool value) external onlyOwner {
        isBlacklisted[account] = value;
    }

    function changeSwapLiquify(bool newVal) public onlyOwner {
        swapLiquify = newVal;
    }



    function setPaymentSplitter(address a) public onlyOwner {
        paymentSplitter = a;
    }

    function setMIM(address a) public onlyOwner {
        MIM = a;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value,"TKN: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function createNodeWithTokens(string memory name_) public {
        require(bytes(name_).length > 3 && bytes(name_).length < 32,"NODE CREATION: NAME SIZE INVALID");
        address sender = _msgSender();
        require(sender != address(0),"NODE CREATION: creation from the zero address");
        require(sender != distributionPool,"NODE CREATION: rewardsPool cannot create node");
        require(balanceOf(sender) >= nodePrice,"NODE CREATION: Balance too low for creation.");
        require(_nodesOfUser[sender].length<maxNodes,"NODE CREATION: maxNodes reached");
        require(sender != owner(),"NODE CREATION: owner can't create a node");
        _transfer(sender, address(this), nodePrice);
        uint256 contractTokenBalance = balanceOf(address(this));
        // somehow fails on mainnet, very strange
        if (swapLiquify && !swapping && !automatedMarketMakerPairs[sender]) {
            swapping = true;
            if(rewardsFee>0){
                uint256 rewardsPoolTokens = contractTokenBalance*rewardsFee/100;
                _transfer(address(this), distributionPool, rewardsPoolTokens);
            }
            if(liquidityPoolFee>0){
                uint256 liquidityPoolTokens = contractTokenBalance*liquidityPoolFee/100;
                _swapAndLiquify(liquidityPoolTokens);
            }
            contractTokenBalance = balanceOf(address(this));
            _swapTokensForMIM(contractTokenBalance,paymentSplitter);
            swapping = false;
        }
        require(_isNameAvailable(sender, name_), "CREATE NODE: Name not available");
        _nodesOfUser[sender].push(
            NodeEntity({
                name: name_,
                creationTime: block.timestamp,
                epoch: lastCreatedEpoch,// rewards won't be available immediately
                bonus: 0
            })
        );
        totalNodesCreated++;
    }

    function _getPrice(uint amountA) private view returns(uint) {
        (uint resA, uint resB,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        return uniswapV2Router.quote(amountA,resA,resB);
    }

    function _swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens/2;
        uint256 otherHalf = tokens-half;
        uint256 initialMIMBalance = IERC20(MIM).balanceOf(address(this));
        _swapTokensForMIM(half,address(this));
        uint256 newBalance = IERC20(MIM).balanceOf(address(this))-initialMIMBalance;
        _addLiquidity(otherHalf, newBalance);
    }

    function _addLiquidity(uint256 tokenAmount1, uint256 tokenAmount2) private {
        uniswapV2Router.addLiquidity(
            address(this),
            MIM,
            tokenAmount1,
            tokenAmount2,
            0,
            0,
            liquidityManager,
            2**256-1
        );
    }

    function _swapTokensForMIM(uint256 tokenAmount,address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = MIM;
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            2**256-1
        );
    }

    function cashoutReward(uint256 blocktime) public {
        address sender = _msgSender();
        require(sender != address(0), "CSHT:  creation from the zero address");
        require(sender != distributionPool,"CSHT: rewardsPool cannot cashout rewards");
        (uint256 rewardAmount, uint lastRewardedEpoch) = getRewardAmountOf(sender,blocktime);
        require(rewardAmount > 0,"CSHT: You don't have enough reward to cash out");
        uint256 feeAmount;
        if (cashoutFee > 0){
            feeAmount = rewardAmount*cashoutFee/100;
            _transfer(distributionPool, address(this), feeAmount);
        }
        rewardAmount -= feeAmount;
        _transfer(distributionPool, sender, rewardAmount);
        require(blocktime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[sender];
        uint256 numberOfNodes = nodes.length;
        require(numberOfNodes > 0, "CASHOUT ERROR: You don't have nodes to cash-out");
        NodeEntity storage node = _getNodeWithCreatime(nodes, blocktime);
        node.epoch = lastRewardedEpoch+1;
        _updateEpochs(lastRewardedEpoch);
    }

    function cashoutAll() public {
        address sender = _msgSender();
        require(sender != address(0),"MANIA CSHT: creation from the zero address");
        //require(!isBlacklisted[sender], "MANIA CSHT: Blacklisted address");
        require(sender != distributionPool,"MANIA CSHT: rewardsPool cannot cashout rewards");
        (uint256 rewardAmount, uint lastRewardedEpoch) = getRewardAmountOf(sender);
        require(rewardAmount > 0,"MANIA CSHT: You don't have enough reward to cash out");
        uint256 feeAmount;
        if (cashoutFee > 0) {
            feeAmount = rewardAmount*cashoutFee/100;
            _transfer(distributionPool, address(this), feeAmount);
        }
        rewardAmount -= feeAmount;
        _transfer(distributionPool, sender, rewardAmount);
        NodeEntity[] storage nodes = _nodesOfUser[sender];
        require(nodes.length > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        for (uint256 i = 0; i < nodes.length; i++) {
            _node = nodes[i];
            _node.epoch = lastRewardedEpoch+1;
        }
        _updateEpochs(lastRewardedEpoch);
    }

    function _updateEpochs(uint e) private {
        if(epochs[e+1].end==0){// wish i could perfect the code, but would take too much time, and people are waiting. this will do for now, what's important is that it's safe
            lastCreatedEpoch++;// most compulsive claimers will create epochs
        }
        if(epochs[e].end+epochDuration!=epochs[e+1].end){// if rewards variables were updated, update next epoch too
            epochs[e+1].end = epochs[e].end+epochDuration;
        }
        if(epochs[e+1].reward!=rewardPerNode){
            epochs[e+1].reward = rewardPerNode;
        }
    }*/
}