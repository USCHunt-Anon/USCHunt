/** 
 *  SourceUnit: /home/jgcarv/Dev/NFT/Orcs/etherOrcs-contracts/src/testnet/MumbaiAllies.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: AGPL-3.0-only
pragma solidity 0.8.7;

/// @notice Modern and gas efficient ERC-721 + ERC-20/EIP-2612-like implementation,
/// including the MetaData, and partially, Enumerable extensions.
contract PolyERC721 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/
    
    address        implementation_;
    address public admin; //Lame requirement from opensea
    
    /*///////////////////////////////////////////////////////////////
                             ERC-721 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;
    uint256 public oldSupply;
    uint256 public minted;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(uint256 => address) public ownerOf;
        
    mapping(uint256 => address) public getApproved;
 
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*///////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/

    function owner() external view returns (address) {
        return admin;
    }
    
    /*///////////////////////////////////////////////////////////////
                              ERC-20-LIKE LOGIC
    //////////////////////////////////////////////////////////////*/
    
    // function transfer(address to, uint256 tokenId) external {
    //     require(msg.sender == ownerOf[tokenId], "NOT_OWNER");
        
    //     _transfer(msg.sender, to, tokenId);
        
    // }
    
    /*///////////////////////////////////////////////////////////////
                              ERC-721 LOGIC
    //////////////////////////////////////////////////////////////*/
    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {
        supported = interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f;
    }
    
    // function approve(address spender, uint256 tokenId) external {
    //     address owner_ = ownerOf[tokenId];
        
    //     require(msg.sender == owner_ || isApprovedForAll[owner_][msg.sender], "NOT_APPROVED");
        
    //     getApproved[tokenId] = spender;
        
    //     emit Approval(owner_, spender, tokenId); 
    // }
    
    // function setApprovalForAll(address operator, bool approved) external {
    //     isApprovedForAll[msg.sender][operator] = approved;
        
    //     emit ApprovalForAll(msg.sender, operator, approved);
    // }

    // function transferFrom(address, address to, uint256 tokenId) public {
    //     address owner_ = ownerOf[tokenId];
        
    //     require(
    //         msg.sender == owner_ 
    //         || msg.sender == getApproved[tokenId]
    //         || isApprovedForAll[owner_][msg.sender], 
    //         "NOT_APPROVED"
    //     );
        
    //     _transfer(owner_, to, tokenId);
        
    // }
    
    // function safeTransferFrom(address, address to, uint256 tokenId) external {
    //     safeTransferFrom(address(0), to, tokenId, "");
    // }
    
    // function safeTransferFrom(address, address to, uint256 tokenId, bytes memory data) public {
    //     transferFrom(address(0), to, tokenId); 
        
    //     if (to.code.length != 0) {
    //         // selector = `onERC721Received(address,address,uint,bytes)`
    //         (, bytes memory returned) = to.staticcall(abi.encodeWithSelector(0x150b7a02,
    //             msg.sender, address(0), tokenId, data));
                
    //         bytes4 selector = abi.decode(returned, (bytes4));
            
    //         require(selector == 0x150b7a02, "NOT_ERC721_RECEIVER");
    //     }
    // }
    
    /*///////////////////////////////////////////////////////////////
                          INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf[tokenId] == from, "not owner");

        balanceOf[from]--; 
        balanceOf[to]++;
        
        delete getApproved[tokenId];
        
        ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId); 

    }

    function _mint(address to, uint256 tokenId) internal { 
        require(ownerOf[tokenId] == address(0), "ALREADY_MINTED");

        uint supply = oldSupply + minted;
        uint maxSupply = 5050;
        require(supply <= maxSupply, "MAX SUPPLY REACHED");
        totalSupply++;
                
        // This is safe because the sum of all user
        // balances can't exceed type(uint256).max!
        unchecked {
            balanceOf[to]++;
        }
        
        ownerOf[tokenId] = to;
                
        emit Transfer(address(0), to, tokenId); 
    }
    
    function _burn(uint256 tokenId) internal { 
        address owner_ = ownerOf[tokenId];
        
        require(ownerOf[tokenId] != address(0), "NOT_MINTED");
        
        totalSupply--;
        balanceOf[owner_]--;
        
        delete ownerOf[tokenId];
                
        emit Transfer(owner_, address(0), tokenId); 
    }
}




/** 
 *  SourceUnit: /home/jgcarv/Dev/NFT/Orcs/etherOrcs-contracts/src/testnet/MumbaiAllies.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// Taken from Solmate: https://github.com/Rari-Capital/solmate

contract ERC20 {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public constant name     = "ZUG";
    string public constant symbol   = "ZUG";
    uint8  public constant decimals = 18;

    /*///////////////////////////////////////////////////////////////
                             ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public isMinter;

    address public ruler;

    /*///////////////////////////////////////////////////////////////
                              ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    constructor() { ruler = msg.sender;}

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
                             ORC PRIVILEGE
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
        require(msg.sender == ruler, "NOT ALLOWED TO RULE");

        isMinter[minter] = status;
    }

    function setRuler(address ruler_) external {
        require(msg.sender == ruler ||ruler == address(0), "NOT ALLOWED TO RULE");

        ruler = ruler_;
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
}




/** 
 *  SourceUnit: /home/jgcarv/Dev/NFT/Orcs/etherOrcs-contracts/src/testnet/MumbaiAllies.sol
*/
            
////// -FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

//////import"../ERC20.sol";
//////import"./PolyERC721.sol"; 


contract EtherOrcsAlliesPoly is PolyERC721 {

    mapping(uint256 => Shaman)   public shamans;
    mapping(uint256 => uint256)  public reserved_1;
    mapping(uint256 => uint256)  public reserved_2;
    mapping(uint256 => uint256)  public reserved_3;
    mapping(address => bool)     public auth;
    mapping(uint256 => Action)   public activities;
    mapping(uint256 => Location) public locations;

    uint16 shSupply;
    uint16 ogSupply;
    uint16 mgSupply;
    uint16 rgSupply;

    ERC20 zug;
    ERC20 boneShards;
    ERC20 potions;

    MetadataHandlerLike metadaHandler;

    address raids;
    address castle;

    bytes32 internal entropySauce;


    // Action: 0 - Unstaked | 1 - Farming | 2 - Training
    struct Action  { address owner; uint88 timestamp; uint8 action; }

    struct Shaman {uint8 skillCredits; uint16 level; uint32 lvlProgress; uint8 body; uint8 featA; uint8 featB; uint8 helm; uint8 mainhand; uint8 offhand; uint16 herbalism;}

    struct Location { 
        uint8  minLevel; uint8  skillCost; uint16  cost;
        uint8 tier_1Prob;uint8 tier_2Prob; uint8 tier_3Prob; uint tier_1; uint tier_2; uint8 tier_3; 
    }


    event ActionMade(address owner, uint256 id, uint256 timestamp, uint8 activity);

    /*///////////////////////////////////////////////////////////////
                    MODIFIERS 
    //////////////////////////////////////////////////////////////*/

    modifier noCheaters() {
        uint256 size = 0;
        address acc = msg.sender;
        assembly { size := extcodesize(acc)}

        require(auth[msg.sender] || (msg.sender == tx.origin && size == 0), "you're trying to cheat!");
        _;

        // We'll use the last caller hash to add entropy to next caller
        entropySauce = keccak256(abi.encodePacked(acc, block.coinbase));
    }

    modifier ownerOfAlly(uint256 id, address who_) { 
        require(ownerOf[id] == who_ || activities[id].owner == who_, "not your ally");
        _;
    }

    modifier isOwnerOfAlly(uint256 id) {
         require(ownerOf[id] == msg.sender || activities[id].owner == msg.sender, "not your ally");
        _;
    }

    /*///////////////////////////////////////////////////////////////
                    PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function initialize(address zug_, address shr_, address potions_ ) external {
        require(msg.sender == admin);

        zug        = ERC20(zug_);
        boneShards = ERC20(shr_);
        potions    = ERC20(potions_);

        Location memory swampWitchDen    = Location({minLevel:25, skillCost: 5, cost:  0, tier_1Prob:88, tier_2Prob:10, tier_3Prob: 2, tier_1:1, tier_2:2, tier_3:3});
        Location memory ancientFrogPool  = Location({minLevel:27, skillCost: 5, cost:  0, tier_1Prob:70, tier_2Prob:25, tier_3Prob: 5, tier_1:1, tier_2:2, tier_3:3});
        Location memory jungleHealerHut  = Location({minLevel:31, skillCost: 5, cost:  0, tier_1Prob:60, tier_2Prob:30, tier_3Prob:10, tier_1:1, tier_2:2, tier_3:3});
        Location memory forgottenDesert  = Location({minLevel:35, skillCost:25, cost:  0, tier_1Prob:85, tier_2Prob:10, tier_3Prob: 5, tier_1:3, tier_2:4, tier_3:5});
        Location memory monkTemple       = Location({minLevel:35, skillCost:20, cost:  0, tier_1Prob:80, tier_2Prob:20, tier_3Prob: 0, tier_1:2, tier_2:5, tier_3:5});
        Location memory djinOasis        = Location({minLevel:40, skillCost:35, cost:  0, tier_1Prob:85, tier_2Prob:10, tier_3Prob: 5, tier_1:4, tier_2:5, tier_3:6});
        Location memory moldyCitadel     = Location({minLevel:45, skillCost:30, cost:  0, tier_1Prob:75, tier_2Prob:25, tier_3Prob: 0, tier_1:3, tier_2:6, tier_3:6});
        Location memory rogueEnchanter   = Location({minLevel:55, skillCost:45, cost:200, tier_1Prob:40, tier_2Prob:60, tier_3Prob: 0, tier_1:3, tier_2:6, tier_3:6});
        Location memory ancientEnchanter = Location({minLevel:55, skillCost:45, cost:200, tier_1Prob:70, tier_2Prob:30, tier_3Prob: 0, tier_1:4, tier_2:7, tier_3:7});
        Location memory ethereanPlains   = Location({minLevel:60, skillCost:50, cost:200, tier_1Prob:80, tier_2Prob:15, tier_3Prob: 5, tier_1:5, tier_2:6, tier_3:7});
        Location memory groveOfDemise    = Location({minLevel:70, skillCost:60, cost:300, tier_1Prob:30, tier_2Prob:30, tier_3Prob:40, tier_1:5, tier_2:6, tier_3:7});
        Location memory spiritWorld      = Location({minLevel:60, skillCost:10, cost:150, tier_1Prob:70, tier_2Prob:25, tier_3Prob: 5, tier_1:2, tier_2:3, tier_3:4});

        locations[0] = swampWitchDen;
        locations[1] = ancientFrogPool;
        locations[2] = jungleHealerHut;
        locations[3] = forgottenDesert;
        locations[4] = monkTemple;
        locations[5] = djinOasis;
        locations[6] = moldyCitadel;
        locations[7] = rogueEnchanter;
        locations[8] = ancientEnchanter;
        locations[9] = ethereanPlains;
        locations[10] = groveOfDemise;
        locations[11] = spiritWorld;
    }

    function setAuth(address add_, bool status) external {
        require(msg.sender == admin);
        auth[add_] = status;
    }

    function tokenURI(uint256 id) external view returns(string memory) {
        Shaman memory orc = shamans[id];
        // return metadaHandler.getTokenURI(uint16(id), orc.body, orc.helm, orc.mainhand, orc.offhand, orc.level, orc.zugModifier);
    }

    function transfer(address to, uint256 tokenId) external {
        require(auth[msg.sender], "not authorized");
        require(msg.sender == ownerOf[tokenId], "NOT_OWNER");
        
        _transfer(msg.sender, to, tokenId);
        
    }

    function doAction(uint256 id, uint8 action_) public ownerOfAlly(id, msg.sender) noCheaters {
       _doAction(id, msg.sender, action_, msg.sender);
    }

    function _doAction(uint256 id, address allyOwner, uint8 action_, address who_) internal ownerOfAlly(id, who_) {
        require(action_ < 3, "invalid action");
        Action memory action = activities[id];
        require(action.action != action_, "already doing that");

        uint88 timestamp = uint88(block.timestamp > action.timestamp ? block.timestamp : action.timestamp);

        if (action.action == 1)  _transfer(allyOwner, address(this), id);
     
        else {
            if (block.timestamp > action.timestamp) _claim(id);
            timestamp = timestamp > action.timestamp ? timestamp : action.timestamp;
        }

        address owner_ = action_ == 1 ? address(0) : allyOwner;
        if (action_ == 1) _transfer(address(this), allyOwner, id);

        activities[id] = Action({owner: owner_, action: action_,timestamp: timestamp});
        emit ActionMade(allyOwner, id, block.timestamp, uint8(action_));
    }

    function doActionWithManyAllys(uint256[] calldata ids, uint8 action_) external {
        for (uint256 index = 0; index < ids.length; index++) {
            _doAction(ids[index], msg.sender, action_, msg.sender);
        }
    }

    function journeyWithManyAllys(uint256[] calldata ids, uint8 place, uint8 location) external {
        for (uint256 index = 0; index < ids.length; index++) {
            journey(ids[index], place, location);
        }
    }

    function claim(uint256[] calldata ids) external {
        for (uint256 index = 0; index < ids.length; index++) {
            _claim(ids[index]);
        }
    }

    function _claim(uint256 id) internal noCheaters {
        Action memory action = activities[id];
        Shaman memory shaman = shamans[id];

        if(block.timestamp <= action.timestamp) return;

        uint256 timeDiff = uint256(block.timestamp - action.timestamp);

        if (action.action == 1) potions.mint(action.owner, _claimable(timeDiff, shaman.herbalism));
       
        if (action.action == 2) {
            shamans[id].lvlProgress += uint32(timeDiff * 3000 / 1 days);
            shamans[id].level        = uint16(shamans[id].lvlProgress / 1000);
        }

        activities[id].timestamp = uint88(block.timestamp);
    }

    function journey(uint256 id, uint8 place, uint8 equipment) public isOwnerOfAlly(id) noCheaters {
        require(equipment < 3, "invalid equipment");
        if(activities[id].timestamp < block.timestamp) _claim(id); // Need to claim to not have equipment reatroactively multiplying
        Shaman memory sh = shamans[id];

        uint256 rand_ = _rand();
  
        Location memory loc = locations[place];
        require(sh.level >= uint16(loc.minLevel), "below minimum level");

        if (loc.cost > 0) {
            zug.burn(msg.sender, uint256(loc.cost) * 1 ether);
        } 

        shamans[id].skillCredits -= loc.skillCost;

        uint8 item = _getItem(loc, _randomize(rand_,"JOURNEY", id));
        uint8 og;

        if (equipment == 0) {
            og = sh.helm;
            shamans[id].helm = item;
        }

        if (equipment == 1) {
            og = sh.mainhand;
            shamans[id].mainhand = item;
        }

        if (equipment == 2) {
            og = sh.offhand;
            shamans[id].offhand = item;
        }

        (uint8 oldTier, uint8 newTier) = (_tier(og), _tier(item));
        
        if (oldTier != newTier) {
            shamans[id].herbalism = oldTier > newTier ? sh.herbalism - (oldTier - newTier) : sh.herbalism + (newTier - oldTier);
        }
    } 

    function sendToRaid(uint256[] calldata ids, uint8 location_, bool double_) external noCheaters { 
        require(address(raids) != address(0), "raids not set");
        for (uint256 index = 0; index < ids.length; index++) {
            if (activities[ids[index]].action != 0) _doAction(ids[index], msg.sender, 0, msg.sender);
            _transfer(msg.sender, raids, ids[index]);
        }
        RaidsLike(raids).stakeManyAndStartCampaign(ids, msg.sender, location_, double_);
    }

    function startRaidCampaign(uint256[] calldata ids, uint8 location_, bool double_) external noCheaters { 
        require(address(raids) != address(0), "raids not set");
        for (uint256 index = 0; index < ids.length; index++) {
            require(msg.sender == RaidsLike(raids).commanders(ids[index]) && ownerOf[ids[index]] == address(raids), "not staked or not your orc");
        }
        RaidsLike(raids).startCampaignWithMany(ids, location_, double_);
    }

    function returnFromRaid(uint256[] calldata ids, uint8 action_) external noCheaters { 
        require(action_ < 3, "invalid action");
        RaidsLike raidsContract = RaidsLike(raids);
        for (uint256 index = 0; index < ids.length; index++) {
            require(msg.sender == raidsContract.commanders(ids[index]), "not your orc");
            raidsContract.unstake(ids[index]);
            if (action_ != 0) _doAction(ids[index], msg.sender, action_, msg.sender);
        }
    }

    function pull(address owner_, uint256[] calldata ids) external {
        require (msg.sender == castle, "not castle");
        for (uint256 index = 0; index < ids.length; index++) {
            if (activities[ids[index]].action != 0) _doAction(ids[index], owner_, 0, owner_);
            _transfer(owner_, msg.sender, ids[index]);
        }
        CastleLike(msg.sender).pullCallback(owner_, ids);
    }

    function adjustShaman(
        uint256 id,
        uint8 skillCredits_, 
        uint16 level_, 
        uint32 lvlProgress_, 
        uint8 body_, 
        uint8 featA_, 
        uint8 featB_, 
        uint8 helm_, 
        uint8 mainhand_, 
        uint8 offhand_, 
        uint16 herbalism_) external 
    {
        require(auth[msg.sender], "not authorized");
        shamans[id] = Shaman({
            skillCredits: skillCredits_, 
            level: level_, 
            lvlProgress: lvlProgress_, 
            body: body_, 
            featA: featA_, 
            featB:featB_, 
            helm:helm_, 
            mainhand:mainhand_, 
            offhand:offhand_, 
            herbalism: herbalism_});
    }


    /*///////////////////////////////////////////////////////////////
                    INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    function _getItem(Location memory loc, uint256 rand) internal pure returns (uint8 item) {
        uint256 draw = uint256(rand % 100);

        uint8 tier = uint8(draw < loc.tier_3Prob ? loc.tier_3 : draw < loc.tier_2Prob ? loc.tier_2 : loc.tier_1) + 1;
        item = uint8(draw % _tierItems(tier) + _startForTier(tier));
    }

    function _claimable(uint256 timeDiff, uint16 herbalism_) internal pure returns (uint256 potionAmount) {
        potionAmount = timeDiff * (0.5 ether + (herbalism_ * 0.05 ether)) / 1 days;
    }

    function _tier(uint8 item) internal pure returns (uint8 tier) {
        if (item <= 7) return 0;
        if (item <= 12) return 1;
        if (item <= 18) return 2;
        if (item <= 25) return 3;
        if (item <= 32) return 4;
        if (item <= 38) return 5;
        if (item <= 44) return 6;
        return 7;
    } 

    function _tierItems(uint256 tier_) internal pure returns (uint256 numItems) {
        if (tier_ == 0) return 7;
        if (tier_ == 1) return 5;
        if (tier_ == 2) return 6;
        if (tier_ == 3) return 7;
        if (tier_ == 4) return 7;
        if (tier_ == 5) return 6;
        if (tier_ == 6) return 6;
        return 6;
    }

    function _startForTier(uint256 tier_) internal pure returns (uint256 start) {
        if (tier_ == 0) return 1;
        if (tier_ == 1) return 7;
        if (tier_ == 2) return 12;
        if (tier_ == 3) return 18;
        if (tier_ == 4) return 25;
        if (tier_ == 5) return 32;
        if (tier_ == 6) return 38;
        return 44;
    }

    /// @dev Create a bit more of randomness
    function _randomize(uint256 rand, string memory val, uint256 spicy) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(rand, val, spicy)));
    }

    function _rand() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.timestamp, entropySauce)));
    }
}

interface MetadataHandlerLike {
    function getTokenURI(uint16 id, uint8 body, uint8 helm, uint8 mainhand, uint8 offhand, uint16 level, uint16 zugModifier) external view returns (string memory);
}

interface RaidsLike {
    function stakeManyAndStartCampaign(uint256[] calldata ids_, address owner_, uint256 location_, bool double_) external;
    function startCampaignWithMany(uint256[] calldata ids, uint256 location_, bool double_) external;
    function commanders(uint256 id) external returns(address);
    function unstake(uint256 id) external;
}

interface CastleLike {
    function pullCallback(address owner, uint256[] calldata ids) external;
}

/** 
 *  SourceUnit: /home/jgcarv/Dev/NFT/Orcs/etherOrcs-contracts/src/testnet/MumbaiAllies.sol
*/

////// -FLATTEN-SUPPRESS-WARNING: Unlicense
pragma solidity 0.8.7;

//////import"../polygon/EtherOrcsAlliesPoly.sol";

contract MumbaiAllies is EtherOrcsAlliesPoly {

    uint256 constant startId = 5050;

    function mintShaman(uint256 amount) external {
        for (uint256 i = 0; i < amount; i++) {
            mintShaman();
        }
    }

    function mintShaman() public noCheaters {
        boneShards.burn(msg.sender, 60 ether);

        _mintShaman(_rand());
    } 

    function setZug(address z_) external {
        require(msg.sender == admin);
        zug = ERC20(z_);
    }

    function setCastle(address c_) external {
        require(msg.sender == admin);
        castle = c_;
    }

    function setRaids(address r_) external {
        require(msg.sender == admin);
        raids = r_;
    }

    function updateShaman(
        uint256 id,
        uint8 skillCredits_, 
        uint16 level_, 
        uint32 lvlProgress_, 
        uint8 body_, 
        uint8 featA_, 
        uint8 featB_, 
        uint8 helm_, 
        uint8 mainhand_, 
        uint8 offhand_, 
        uint16 herbalism_) external 
    {
        require(auth[msg.sender], "not authorized");
        shamans[id] = Shaman({
            skillCredits: skillCredits_, 
            level: level_, 
            lvlProgress: lvlProgress_, 
            body: body_, 
            featA: featA_, 
            featB:featB_, 
            helm:helm_, 
            mainhand:mainhand_, 
            offhand:offhand_, 
            herbalism: herbalism_});
    }


    function setMetadataHandler(address add) external {
        require(msg.sender == admin);
        metadaHandler = MetadataHandlerLike(add);
    }

    function initMint(address to, uint256 start, uint256 end) external {
        require(msg.sender == admin);
        for (uint256 i = start; i < end; i++) {
            _mint( to, i);
        }
    }

    function _mintShaman(uint256 rand) internal returns (uint16 id) {
        id = uint16(shSupply + 1 + startId); //check that supply is less than 3000
        require(shSupply++ <= 3000, "max supply reached");

        // Getting Random traits
        uint8 body = _getBody(_randomize(rand, "BODY", id));

        uint8 featB     = uint8(_randomize(rand, "featB",     id) % 22) + 1; 
        uint8 featA    = uint8(_randomize(rand, "featA",    id) % 20) + 1; 
        uint8 helm     = uint8(_randomize(rand, "HELM",     id) %  7) + 1;
        uint8 mainhand = uint8(_randomize(rand, "MAINHAND", id) %  7) + 1; 
        uint8 offhand  = uint8(_randomize(rand, "OFFHAND",  id) %  7) + 1;

        _mint(msg.sender, id);

        shamans[id] = Shaman({skillCredits:100, level: 25, lvlProgress: 25000, body: body, featA: featA, featB:featB, helm:helm, mainhand:mainhand, offhand:offhand, herbalism: 0});
    }

    function _getBody(uint256 rand) internal pure returns (uint8) {
        uint256 sixtyFivePct = type(uint16).max / 100 * 62;
        uint256 nineSevenPct = type(uint16).max / 100 * 97;
        uint256 nineNinePct  = type(uint16).max / 100 * 99;

        if (rand < sixtyFivePct) return uint8(rand % 5) + 1;
        if (rand < nineSevenPct) return uint8(rand % 4) + 6;
        if (rand < nineNinePct) return 10;
        return 11;
    } 

}