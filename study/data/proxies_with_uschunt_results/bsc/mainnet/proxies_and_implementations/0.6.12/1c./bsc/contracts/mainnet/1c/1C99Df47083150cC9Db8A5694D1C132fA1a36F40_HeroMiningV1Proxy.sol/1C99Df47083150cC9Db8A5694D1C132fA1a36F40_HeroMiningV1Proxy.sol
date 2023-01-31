

// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

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




// ////-License-Identifier: MIT

pragma solidity ^0.6.0;

contract ProxyOwnable  { 

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    constructor() public payable  {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(msg.sender);
    }


    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        require(msg.sender == _admin(), "Ownable: caller is not the admin");
        _;
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


    function changeAdmin(address newAdmin) external ifAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
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

}




// ////-License-Identifier: MIT
pragma solidity ^0.6.12;
//import "../vendor/libraries/proxy/Proxy.sol";
//import "../vendor/libraries/proxy/ProxyOwnable.sol";

contract UpgradableProxy is Proxy, ProxyOwnable{

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;


    constructor(address _implementation) ProxyOwnable() public {
           _setImplementation(_implementation);
    }

    function upgradeDelegate(address newDelegateAddress) public ifAdmin{
        _setImplementation(newDelegateAddress);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }

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


}


// ////-License-Identifier: MIT
pragma solidity ^0.6.12;
//import "./UpgradableProxy.sol";

contract HeroMiningV1Proxy is UpgradableProxy{
    constructor(address _implementation) UpgradableProxy(_implementation) public {
    }
}


// : MIT
pragma solidity 0.6.12;

//import"../vendor/interfaces/IStorage.sol";
//import"../vendor/libraries/proxy/Initializable.sol";
//import"../vendor/libraries/access/Ownable.sol";
//import"../vendor/libraries/math/SafeMath.sol";
//import"../vendor/interfaces/IERC20.sol";
//import"../Constants.sol";
//import"../vendor/interfaces/ITreasury.sol";
//import"../vendor/libraries/transfer/SafeERC20.sol";


// MasterChef is the master of Pact. He can make Pact and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once PACT is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract HeroMiningV1 is Initializable, Ownable, Constants {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 heroesPower; // heroesPower = heroesSumPacts * heroesSumSkills / Heroes Quantity / 100
        uint256 heroesQuantity;
        uint256 heroesSumSkills;
        uint256 heroesSumPacts;
        uint256 rewardDebt;  // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of PACTs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.heroesPower * pool.accPactPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPactPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `heroesPower` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 heroTeamCurrency;  //Hero Team Currency Pool.
        uint256 lastRewardBlock;  // Last block number that PACTs distribution occurs.
        uint256 accPactPerShare;  // Accumulated PACTs per share, times 1e12. See below.
        uint256 totalPowerSupply; // Accumulated PACTs per share, times 1e12. See below.
    }

    // The PACT TOKEN!
    //IERC20 public pact;
    address public pact;
    // The NFT HERO TOKENS STORAGE!
    //IStorage public heroStorage;
    address public heroStorage;
    // The NFT HERO TOKENS TREASURY! (HeroManager)
    //ITreasury public treasury;
    address public treasury;
    // PACT tokens created per block.
    uint256 public pactPerBlock;

    // Info of pool.
    PoolInfo public pool;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    // The block number when PACT mining starts.
    uint256 public startBlock;
    // The block number when PACT mining stop.
    uint256 public endBlock;

    event Deposit(address indexed user, uint256 heroId);
    event Withdraw(address indexed user, uint256 heroId);
    event Harvest(address indexed user, uint256 heroId);
    event EmergencyWithdraw(address indexed user, uint256 heroId);

    function initialize(
        address _pact,
        address _heroStorage,
        address _treasury,
        uint256 _heroTeamCurrency,
        uint256 _startBlock,
        uint256 _endBlock
    ) public payable initializer {
        pact = _pact;
        heroStorage = _heroStorage;
        treasury = _treasury;
        startBlock = _startBlock;
        endBlock = _endBlock;
        uint256 pactBal = IERC20(pact).balanceOf(address(this));
        pactPerBlock = pactBal.div(_endBlock.sub(startBlock));
        pool = PoolInfo({
            heroTeamCurrency: _heroTeamCurrency,
            lastRewardBlock: startBlock,
            accPactPerShare: 0,
            totalPowerSupply: 0
        });
        _initialize();
        require(msg.sender == address(0x3CDF4A92B15C11ce05149C92E1436057b5c6E128),"Only manager address");
    }

    modifier onlyHeroTeamCurrency(uint256 heroId) {
        require(pool.heroTeamCurrency == IStorage(heroStorage).get(heroId, HERO_TYPE));
        _;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }


    // View function to see pending PACTs on frontend.
    function pendingPact(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accPactPerShare = pool.accPactPerShare;
        uint256  blockNumber = block.number;

        if (block.number > endBlock) {
            blockNumber = endBlock;
        }
   

        if (blockNumber > pool.lastRewardBlock && pool.totalPowerSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, blockNumber);
            uint256 pactReward = multiplier.mul(pactPerBlock);
            accPactPerShare = accPactPerShare.add(pactReward.mul(1e12).div(pool.totalPowerSupply));
        }

        return user.heroesPower.mul(accPactPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        uint256 blockNumber = block.number;

        if (blockNumber > endBlock) {
            blockNumber = endBlock;
        }

        if (blockNumber <= pool.lastRewardBlock) {
            return;
        }

        if (pool.totalPowerSupply == 0) {
            pool.lastRewardBlock = blockNumber;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, blockNumber);
        uint256 pactReward = multiplier.mul(pactPerBlock);

        pool.accPactPerShare = pool.accPactPerShare.add(pactReward.mul(1e12).div(pool.totalPowerSupply));
        pool.lastRewardBlock = blockNumber;
    }



    function harvest(uint256 heroId) public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        require(IStorage(heroStorage).ownerOf(heroId) == msg.sender, 'HeroMiningV1::Harvest heroId - only owner');
        uint256 pending = user.heroesPower.mul(pool.accPactPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safePactTransfer(msg.sender, pending);
        }
        user.rewardDebt = user.heroesPower.mul(pool.accPactPerShare).div(1e12);
        emit Harvest(msg.sender, heroId);
    }
    

    // Deposit HeroId for PACT allocation.
    function deposit(uint256 heroId) onlyHeroTeamCurrency(heroId) public {
        UserInfo storage user = userInfo[msg.sender];
        IStorage _heroStorage = IStorage(heroStorage);
        require(_heroStorage.ownerOf(heroId) == msg.sender, 'HeroMiningV1::Deposit heroId - only owner');
        updatePool();
        if (user.heroesPower > 0) {
            uint256 pending = user.heroesPower.mul(pool.accPactPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safePactTransfer(msg.sender, pending);
            }
        }

            // todo assert heroId has correct heroTeam
            
        user.heroesQuantity = user.heroesQuantity.add(1);
        user.heroesSumSkills = user.heroesSumSkills
            .add(_heroStorage.get(heroId, SKILL_WARRIOR))
            .add(_heroStorage.get(heroId, SKILL_FARMER))
            .add(_heroStorage.get(heroId, SKILL_TRADER))
            .add(_heroStorage.get(heroId, SKILL_PREDICTOR));
                
        user.heroesSumPacts = user.heroesSumPacts.add(ITreasury(treasury).getTokenBalance(address(pact), heroId));
        user.heroesPower = user.heroesSumPacts * user.heroesSumSkills / user.heroesQuantity / 100;

        safeSoulTransferFrom(heroId);
        

        user.rewardDebt = user.heroesPower.mul(pool.accPactPerShare).div(1e12);
        pool.totalPowerSupply = pool.totalPowerSupply.add(user.heroesPower);
        emit Deposit(msg.sender, heroId);
    }



    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 heroId) public {
        UserInfo storage user = userInfo[msg.sender];
        IStorage _heroStorage = IStorage(heroStorage);
        require(_heroStorage.ownerOf(heroId) == msg.sender, 'HeroMiningV1::withdraw heroId - only owner');

        updatePool();
        if (user.heroesPower > 0) {
            uint256 pending = user.heroesPower.mul(pool.accPactPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safePactTransfer(msg.sender, pending);
            }
        }
        
            // todo assert heroId has correct heroTeam

        user.heroesQuantity = user.heroesQuantity.sub(1);

        

        if (user.heroesQuantity == 0) {
            user.heroesSumSkills = 0;
            user.heroesSumPacts = 0;
            user.heroesPower = 0;
        } else {
            user.heroesSumSkills = user.heroesSumSkills
                .sub(_heroStorage.get(heroId, SKILL_WARRIOR))
                .sub(_heroStorage.get(heroId, SKILL_FARMER))
                .sub(_heroStorage.get(heroId, SKILL_TRADER))
                .sub(_heroStorage.get(heroId, SKILL_PREDICTOR))
            ;
            user.heroesSumPacts = user.heroesSumPacts.sub(ITreasury(treasury).getTokenBalance(address(pact), heroId));
            user.heroesPower = user.heroesSumPacts * user.heroesSumSkills / user.heroesQuantity / 100;
        }

        safeSoulTransfer(heroId);
        
    
        user.rewardDebt = user.heroesPower.mul(pool.accPactPerShare).div(1e12);
        pool.totalPowerSupply = pool.totalPowerSupply.sub(user.heroesPower);
        emit Withdraw(msg.sender, heroId);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 heroId) public {
        // todo assert heroId is in current dungeon
        require(IStorage(heroStorage).ownerOf(heroId) == msg.sender, 'HeroMiningV1::emergencyWithdraw heroId - only owner');

        UserInfo storage user = userInfo[msg.sender];

        pool.totalPowerSupply = pool.totalPowerSupply.sub(user.heroesPower);

        safeSoulTransfer(heroId);

        
        user.heroesPower = 0;
        user.rewardDebt = 0;
        user.heroesQuantity = 0;

        emit EmergencyWithdraw(msg.sender, heroId);
    }



    function multiWithdraw(uint256[] memory heroesId) external {
        uint256 length = heroesId.length;
        for (uint256 id = 0; id < length; ++id) {
            withdraw(heroesId[id]);
        }
    }
    
    function multiDeposit(uint256[] memory heroesId) external {
        uint256 length = heroesId.length;
        for (uint256 id = 0; id < length; ++id) {
            deposit(heroesId[id]);
        }
    }


    function safeSoulTransferFrom(uint256 heroId) internal {
        IStorage(heroStorage).enterTheDungeon(heroId); 
    }



    function safeSoulTransfer(uint256 heroId) internal {
        IStorage(heroStorage).leaveTheDungeon(heroId); 
    }



    //Safe pact transfer function, just in case if rounding error causes pool to not have enough PACTs.
    function safePactTransfer(address _to, uint256 _amount) internal {
        uint256 pactBal = IERC20(pact).balanceOf(address(this));
        if (_amount > pactBal) {
            IERC20(pact).transfer(_to, pactBal);
        } else {
            IERC20(pact).transfer(_to, _amount);
        }
    }

}


// : MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IBalancesLikeERC1155
{
    event TransferSingle(uint256 indexed tokenIdFrom, uint256 indexed tokenIdTo, uint256 key, uint256 value);

    function burn(uint256 tokenId) external ;
    function mint(address to, uint256[10] memory keys, uint256[10] memory amounts) external  returns (uint256);

    function get(uint256 tokenId, uint256 key) view external  returns(uint256 balance);
    function getListBalancesForSingleId(uint256 tokenId, uint256[] memory keys) view external  returns (uint256[] memory);
    //function getListBalancesForManyIds(uint256[] memory tokenIds, uint256[] memory keys) view external  returns (uint256[][] memory);

    function set(uint256 tokenId, uint256 key, uint256 value) external ;
    function sub(uint256 tokenId, uint256 key, uint256 value) external ;
    function add(uint256 tokenId, uint256 key, uint256 value) external ;

    function setMany(uint256 tokenId, uint256[10] memory keys, uint256[10] memory values) external ;
    function transferSingle(uint256 tokenIdFrom, uint256 tokenIdTo, uint256 key, uint256 value) external ;
}

// : MIT

pragma solidity ^0.6.0;

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


// : MIT
pragma solidity 0.6.12;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// : MIT

pragma solidity ^0.6.2;

//import"./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function getApproved(uint256 tokenId) external view returns (address operator);

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
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


// : MIT

pragma solidity ^0.6.2;

//import"./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// : MIT

pragma solidity ^0.6.2;

//import"./IERC721.sol";

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


// : MIT
pragma solidity ^0.6.12;

//import"./IBalancesLikeERC1155.sol";
//import"./IERC721.sol";
//import"./IERC721Metadata.sol";
//import"./IERC721Enumerable.sol";

interface IStorage is IBalancesLikeERC1155, IERC721, IERC721Metadata, IERC721Enumerable{

   function enterTheDungeon(uint256 heroId) external;

   function leaveTheDungeon(uint256 heroId) external;
   
   function issoul(uint256 tokenId) external returns(bool);
   
}


// : MIT
pragma solidity ^0.6.12;

interface ITreasury {
    function getTokenBalance(address currencyAddress, uint256 tokenId) view external returns(uint256 balance);
}


// : MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// : MIT
pragma solidity 0.6.12;

//import'../GSN/Context.sol';

// Copied from OpenZeppelin code:
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function _initialize() internal { 
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// : MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// : MIT

pragma solidity >=0.4.24 <0.7.0;


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


// : MIT
pragma solidity 0.6.12;

//import"../../interfaces/IERC20.sol";

library SafeERC20 {
    function safeSymbol(IERC20 token) internal view returns(string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns(string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) public view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TRANSFER_FAILED");
    }

    function safeBurn(IERC20 token, uint256 amount) internal {
        // bytes4(keccak256(bytes('burn(uint256)')));
        //require(false, bytes4(keccak256(bytes('burn(uint256)')))); // todo fix it to correct value
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(bytes4(keccak256(bytes('burn(uint256)'))), amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: BURN_FAILED");
    }

    function safeApprove(IERC20 token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SafeERC20: APPROVE_FAILED');
    }

    function safeTransferFrom(IERC20 token, address from, uint256 amount) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, address(this), amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TRANSFER_FROM_FAILED");
    }
}

// : MIT
pragma solidity ^0.6.12;



contract Constants {
    uint256 public constant BLOCK_CREATED_AT = 0;
    uint256 public constant BLOCK_BALANCE_UPDATED_AT = 1;
    uint256 public constant TIME_ALLOW_BURN = 3;

    uint256 public constant HERO_TYPE = 1000;
    uint256 public constant AMOUNT_CYRRENCY_TO_HERO = 1001;

    uint256 public constant AVATAR = 1010;

    uint256 public constant SKILL_WARRIOR = 1100;
    uint256 public constant SKILL_FARMER = 1101;
    uint256 public constant SKILL_TRADER = 1102;
    uint256 public constant SKILL_PREDICTOR = 1103;
}

