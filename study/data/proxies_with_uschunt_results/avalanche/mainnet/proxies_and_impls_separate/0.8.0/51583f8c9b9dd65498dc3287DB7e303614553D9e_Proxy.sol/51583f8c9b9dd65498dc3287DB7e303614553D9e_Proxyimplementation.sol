// : MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

//import"./ERC721.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableV2 is ERC721 {
  // Mapping from owner to list of owned token IDs
  mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) private _ownedTokensIndex;

  /**
   * @dev See {IERC721Enumerable-totalSupply}.
   */
  uint256 public totalSupply;

  /**
   * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
   */
  function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
    require(index < balanceOf[owner], "ERC721Enumerable: owner index out of bounds");
    return _ownedTokens[owner][index];
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
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   *
   * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    if (from == address(0)) {
      totalSupply++;
    } else if (from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    }
    if (to == address(0)) {
      totalSupply--;
    } else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }
  }

  /**
   * @dev Private function to add a token to this extension's ownership-tracking data structures.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    uint256 length = balanceOf[to];
    _ownedTokens[to][length] = tokenId;
    _ownedTokensIndex[tokenId] = length;
  }

  /**
   * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
   * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
   * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
   * This has O(1) time complexity, but alters the order of the _ownedTokens array.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
    // then delete the last slot (swap and pop).

    uint256 lastTokenIndex = balanceOf[from] - 1;
    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    // When the token to delete is the last token, the swap operation is unnecessary
    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

      _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
      _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
    }

    // This also deletes the contents at the last position of the array
    delete _ownedTokensIndex[tokenId];
    delete _ownedTokens[from][lastTokenIndex];
  }
}


// : MIT
pragma solidity ^0.8.0;

contract Whitelister {
  mapping(address => bool) public whitelists;

  modifier withinWhitelist() {
    address sender = msg.sender;
    require(whitelists[sender]);
    _beforeUse(sender);
    _;
  }

  function setWhitelists(address[] calldata newWhitelists, bool whitelisted) public virtual {
    for (uint256 i = 0; i < newWhitelists.length; i++) {
      whitelists[newWhitelists[i]] = whitelisted;
    }
  }

  function _beforeUse(address whitelist) internal virtual {}
}


// : MIT
pragma solidity ^0.8.0;

interface ISeeder {
  function get(uint256) external returns (uint256);

  function gets(uint256, uint256) external returns (uint256[] memory);
}


// : MIT
pragma solidity ^0.8.0;

interface IData {
  function registerHunter(uint256 hunterId, uint256 seed) external;

  function nameHunter(uint256 hunterId, string calldata name) external;

  function getData(uint256 hunterId) external view returns (uint256);

  function setRate(uint256 hunterId, uint32 rate) external;

  function setBreed(uint256 hunterId, uint32 breeds) external;

  function infoBreed(uint256 hunterId) external view returns (bool isMale, uint32 breed);

  function infoCenter(uint256 hunterId) external view returns (bool isMale, uint32 rate);

  function infoPool(uint256 hunterId) external view returns (bool isMale, uint16 special);

  function info(uint256 hunterId)
    external
    view
    returns (
      string memory name,
      uint8 generation,
      uint16 tokenIdx,
      bool isMale,
      uint16[] memory pieces,
      uint32[] memory support
    );

  function draw(uint256 tokenId) external view returns (string memory);

  function drawTeam(string memory name, uint256[] memory tokenIds) external view returns (string memory);

  function transferOwnership(address newOwner) external;
}


// : MIT
pragma solidity ^0.8.0;

interface IShop {
  function burn(
    address account,
    uint256 id,
    uint256 value
  ) external;

  function burnBatch(
    address account,
    uint256[] memory ids,
    uint256[] memory values
  ) external;
}


// : MIT
pragma solidity ^0.8.0;

interface ITicket {
  function balanceOf(address account) external view returns (uint256);

  function use(address account) external returns (uint256);
}


// : MIT
pragma solidity ^0.8.0;

interface IRenouncer {
  function transferOwnership(address) external;
}


// : MIT
pragma solidity ^0.8.0;

interface IToken {
  function balanceOf(address account) external view returns (uint256);

  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);

  function burn(address account, uint256 amount) external;
}


// : AGPL-3.0-only
pragma solidity ^0.8.0;

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

/// @notice Modern and gas efficient ERC-721 + ERC-20/EIP-2612-like implementation,
/// including the MetaData, and partially, Enumerable extensions.
contract ERC721 {
  /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /*///////////////////////////////////////////////////////////////
                             METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

  address implementation_;
  address admin;

  string public name;
  string public symbol;

  /*///////////////////////////////////////////////////////////////
                             ERC-721 STORAGE
    //////////////////////////////////////////////////////////////*/

  mapping(address => uint256) public balanceOf;

  mapping(uint256 => address) public ownerOf;

  mapping(uint256 => address) public getApproved;

  mapping(address => mapping(address => bool)) public isApprovedForAll;

  /*///////////////////////////////////////////////////////////////
                             VIEW FUNCTION
    //////////////////////////////////////////////////////////////*/

  modifier onlyOwner() {
    require(msg.sender == admin);
    _;
  }

  function owner() external view returns (address) {
    return admin;
  }

  /*///////////////////////////////////////////////////////////////
                              ERC-20-LIKE LOGIC
    //////////////////////////////////////////////////////////////*/

  function transfer(address to, uint256 tokenId) external {
    require(msg.sender == ownerOf[tokenId], "NOT_OWNER");

    _transfer(msg.sender, to, tokenId);
  }

  /*///////////////////////////////////////////////////////////////
                              ERC-721 LOGIC
    //////////////////////////////////////////////////////////////*/

  function supportsInterface(bytes4 interfaceId) external pure returns (bool supported) {
    // supported = interfaceId == 0x80ac58cd || interfaceId == 0x5b5e139f || interfaceId == 0x2a55205a;
    supported = true;
  }

  function approve(address spender, uint256 tokenId) external {
    address owner_ = ownerOf[tokenId];

    require(msg.sender == owner_ || isApprovedForAll[owner_][msg.sender], "NOT_APPROVED");

    getApproved[tokenId] = spender;

    emit Approval(owner_, spender, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) external {
    isApprovedForAll[msg.sender][operator] = approved;

    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual {
    require(
      msg.sender == from || msg.sender == getApproved[tokenId] || isApprovedForAll[from][msg.sender],
      "NOT_APPROVED"
    );

    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external {
    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public {
    transferFrom(from, to, tokenId);

    if (to.code.length != 0) {
      try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
        require(retval == IERC721Receiver.onERC721Received.selector);
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    }
  }

  /*///////////////////////////////////////////////////////////////
                          INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal {
    require(ownerOf[tokenId] == from);
    _beforeTokenTransfer(from, to, tokenId);

    balanceOf[from]--;
    balanceOf[to]++;

    delete getApproved[tokenId];

    ownerOf[tokenId] = to;
    emit Transfer(from, to, tokenId);

    _afterTokenTransfer(from, to, tokenId);
  }

  function _mint(address to, uint256 tokenId) internal {
    require(ownerOf[tokenId] == address(0), "ALREADY_MINTED");
    _beforeTokenTransfer(address(0), to, tokenId);

    // This is safe because the sum of all user
    // balances can't exceed type(uint256).max!
    unchecked {
      balanceOf[to]++;
    }

    ownerOf[tokenId] = to;

    emit Transfer(address(0), to, tokenId);

    _afterTokenTransfer(address(0), to, tokenId);
  }

  function _burn(uint256 tokenId) internal {
    address owner_ = ownerOf[tokenId];

    require(owner_ != address(0), "NOT_MINTED");
    _beforeTokenTransfer(owner_, address(0), tokenId);

    balanceOf[owner_]--;

    delete ownerOf[tokenId];

    emit Transfer(owner_, address(0), tokenId);

    _afterTokenTransfer(owner_, address(0), tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual {}
}


// : MIT
pragma solidity ^0.8.0;

//import"./bases/ERC721EnumerableV2.sol";
//import"./utils/Whitelister.sol";

//import"./interfaces/ISeeder.sol";
//import"./interfaces/IData.sol";
//import"./interfaces/IShop.sol";
//import"./interfaces/ITicket.sol";
//import"./interfaces/IRenouncer.sol";
//import"./interfaces/IToken.sol";

contract AvaxHuntersV5 is ERC721EnumerableV2, Whitelister {
  uint16 public constant MAX_PER_PRESALE = 5;
  uint16 public constant MAX_PER_MINT = 10;
  uint256 public constant ENERGY_PER_DAY = 3_000_000;
  uint256 public constant MAX_ENERGY = 20_000_000;
  uint256 public constant BREED_ENERGY = 10_000_000;

  uint256 public constant ITEM_GREEN = 2;
  uint256 public constant ITEM_PURPLE = 3;
  uint256 public constant ITEM_BREAD = 7;
  uint256 public constant ITEM_FRIED_EGG = 8;

  struct Hunter {
    string name;
    uint8 generation;
    uint16 tokenIdx;
    bool isMale;
    uint16[] pieces;
    uint32[] support;
  }

  struct Partner {
    address token;
    uint256 price;
    uint256 stock;
    address burnTo;
    uint256 burn;
  }

  struct Order {
    uint256 index;
    uint256 listPrice;
    uint256 offerPrice;
    address offerFrom;
  }

  bool public initialized;

  /**
   * @dev contract states
   * - 0: none
   * - 1: presale (whitelists & free mints)
   * - 2: public (users & free mints)
   * - 4: breed & hunt (hunters)
   * - 8: ...
   */
  uint8 public states;

  /**
   * @dev contract utilities
   * - 0: seeder
   * - 1: data
   * - 2: breeder
   * - 3: center
   * - 4: pool
   * - 5: shop
   */
  address[] public utils;

  /**
   * @dev contract tokens
   * - 0: team (old - ticket)
   * - 1: orb
   * - 2: energy
   * - 3: crystal
   * - 4: ...
   */
  address[] public tokens;

  // Free Minters
  mapping(address => bool) public freeMinters;

  // Treasury of Hunters
  address public treasury;

  // Mint price & supply
  uint256 public mintPrice;
  uint256 public genesisSupply;
  uint256 public mintTicker;

  // Hunter Holders

  /**
   * @dev hunter holders
   * -   0 ~ 127: last claimed timestamp
   * - 128 ~ 255: last remained energy
   */
  mapping(address => uint256) users;

  Partner[] partners;

  // Marketplace
  mapping(uint256 => Order) public orders;
  uint256[] public listedTokens;

  function initialize() external {
    require(msg.sender == admin);
    require(!initialized);
    initialized = true;

    name = "World of Hunters";
    symbol = "WOH";

    mintPrice = 1 ether;
    genesisSupply = 5_000;
  }

  modifier onlyState(uint8 flags) {
    require(states & flags > 0, "Invalid state");
    _;
  }

  function setState(uint8 newStates) external onlyOwner {
    states = newStates;
  }

  function seeds(uint256 updates, uint256 amount) internal returns (uint256[] memory) {
    return ISeeder(utils[0]).gets(updates, amount);
  }

  function data() internal view returns (IData) {
    return IData(utils[1]);
  }

  // function ticket() internal view returns (ITicket) {
  //   return ITicket(tokens[0]);
  // }

  function setUtils(address[] calldata newUtils) external onlyOwner {
    utils = newUtils;
  }

  function updateUtil(uint256 index, address newUtil) external onlyOwner {
    utils[index] = newUtil;
  }

  function setTokens(address[] calldata newTokens) external onlyOwner {
    tokens = newTokens;
  }

  function updateToken(uint256 index, address newToken) external onlyOwner {
    tokens[index] = newToken;
  }

  function setTreasury(address newTreasury) external onlyOwner {
    treasury = newTreasury;
  }

  // function setMintPrice(uint256 newMintPrice) external onlyOwner {
  //   mintPrice = newMintPrice;
  // }

  // function setGenesisSupply(uint256 newGenesisSupply) external onlyOwner {
  //   genesisSupply = newGenesisSupply;
  // }

  // function setOGMinters(address[] calldata newFreeMinters) external onlyOwner {
  //   for (uint256 i = 0; i < newFreeMinters.length; i++) {
  //     freeMinters[newFreeMinters[i]] = true;
  //   }
  // }

  // function mintPublic(uint256 amount) public payable onlyState(2) {
  //   require(amount <= MAX_PER_MINT);
  //   uint256 discount = 9000; // 10%
  //   if (amount >= 5) {
  //     discount = 7500; // 25% - 5+ mints
  //   } else if (amount >= 3) {
  //     discount = 8000; // 20% - 3+ mints
  //   }
  //   require(msg.value >= ((mintPrice * discount) / 10000) * amount);

  //   if (freeMinters[msg.sender] && amount > 1) {
  //     // OG minters = 2 mint + 1 airdrop
  //     delete freeMinters[msg.sender];
  //     amount += 1;
  //   }

  //   mint(amount);
  // }

  // function mint(uint256 amount) internal {
  //   require(msg.sender == tx.origin, "Invalid sender");
  //   require(mintTicker + amount <= genesisSupply, "Insufficient supply");

  //   address to = msg.sender;

  //   uint256[] memory hashes = new uint256[](amount);
  //   hashes = seeds(mintTicker, amount);
  //   for (uint256 i = 0; i < amount; i++) {
  //     uint256 tokenId = mintTicker + i + 1;
  //     data().registerHunter(tokenId, hashes[i]);
  //     _mint(to, tokenId);
  //   }
  //   mintTicker += amount;
  // }

  function setNames(uint256[] calldata tokenIds, string[] calldata names) external {
    for (uint16 i = 0; i < tokenIds.length; i++) {
      require(msg.sender == ownerOf[tokenIds[i]]);
      data().nameHunter(tokenIds[i], names[i]);
    }
  }

  function getHunters(address account) external view returns (Hunter[] memory hunters) {
    uint256 balance = balanceOf[account];
    hunters = new Hunter[](balance);

    IData hunterData = data();

    for (uint16 i = 0; i < balance; i++) {
      (
        string memory name,
        uint8 generation,
        uint16 tokenIdx,
        bool isMale,
        uint16[] memory pieces,
        uint32[] memory support
      ) = hunterData.info(tokenOfOwnerByIndex(account, i));
      hunters[i] = Hunter(name, generation, tokenIdx, isMale, pieces, support);
    }
  }

  function getEnergy(address account) external view returns (uint256 energy) {
    uint256 user = users[account];
    uint256 balance = balanceOf[account];

    uint128 timestamp = uint128(block.timestamp);

    if (uint128(user) > 0) {
      energy = (user >> 128) + ((timestamp - uint128(user)) * ENERGY_PER_DAY * balance) / 1 days;
      if (energy > MAX_ENERGY * balance) {
        energy = MAX_ENERGY * balance;
      }
    }
  }

  function updateEnergyInternal(address account, uint128 energy) internal {
    uint256 user = users[account];
    users[account] = (((user >> 128) + energy) << 128) | uint128(user);
  }

  function fillEnergy(uint128 energy) external {
    address account = msg.sender;
    IToken(tokens[2]).burn(account, energy);
    updateEnergyInternal(account, energy);
  }

  function useEnergy(address account, uint256 use) internal {
    uint256 user = users[account];
    uint256 balance = balanceOf[account];
    uint256 energy;

    uint128 timestamp = uint128(block.timestamp);

    if (timestamp == uint128(user)) {
      // same transaction
      return;
    }

    if (uint128(user) > 0) {
      energy = (user >> 128) + ((timestamp - uint128(user)) * ENERGY_PER_DAY * balance) / 1 days;
      if (energy > MAX_ENERGY * balance) {
        energy = MAX_ENERGY * balance;
      }

      require(energy >= use, "Insufficient energy");
      energy -= use;
      users[account] = (energy << 128) | timestamp;
    } else {
      users[account] = timestamp;
    }
  }

  function useEnergyBehalf(address account, uint256 uses) internal returns (uint256 usage) {
    uint256 user = users[account];
    uint256 balance = balanceOf[account];

    uint128 timestamp = uint128(block.timestamp);

    uint256 energy = (user >> 128) + ((timestamp - uint128(user)) * ENERGY_PER_DAY * balance) / 1 days;
    if (energy > MAX_ENERGY * balance) {
      energy = MAX_ENERGY * balance;
    }

    usage = uses * MAX_ENERGY;
    if (energy > usage) {
      energy -= usage;
      users[account] = (energy << 128) | timestamp;
    } else {
      usage = energy;
      users[account] = timestamp;
    }
  }

  function useBreed(
    address account,
    uint256 female,
    uint256 breeds,
    uint256 breedId,
    uint256 breedHash
  ) external onlyState(4) {
    require(msg.sender == utils[2], "Invalid breeder");
    if (breedId > 0) {
      useEnergy(account, BREED_ENERGY * 2);
      data().setBreed(female, uint32(breeds));
      data().registerHunter(breedId, breedHash);
      _mint(account, breedId);
    } else {
      useEnergy(account, BREED_ENERGY);
    }
  }

  function useBreedWithApple(
    address account,
    uint256 female,
    uint256 breeds,
    uint256 breedId,
    uint256 breedHash
  ) external onlyState(4) {
    require(msg.sender == utils[2], "Invalid breeder");
    // useEnergy(account, BREED_ENERGY * 2);
    data().setBreed(female, uint32(breeds));
    data().registerHunter(breedId, breedHash);
    _mint(account, breedId);
  }

  function useTrain(
    address account,
    uint256[] calldata hunters,
    uint32[] memory rates,
    uint256 use
  ) external {
    require(msg.sender == utils[3], "Invalid center");
    useEnergy(account, use);
    for (uint16 i = 0; i < hunters.length; i++) {
      data().setRate(hunters[i], rates[i]);
    }
  }

  function useHunter(uint256 hunterId, uint32 hunterRate) external {
    require(msg.sender == utils[4], "Invalid pool");
    data().setRate(hunterId, hunterRate);
  }

  function useHunt(address account, uint256[] calldata hunters) external onlyState(4) returns (uint256 energy) {
    require(msg.sender == utils[4], "Invalid pool");
    for (uint16 i = 0; i < hunters.length; i++) {
      require(ownerOf[hunters[i]] == account, "Invalid owner");
    }
    energy = useEnergyBehalf(account, hunters.length);
  }

  function getEnergyPerItem(uint256 id) public pure returns (uint256) {
    if (id == ITEM_GREEN) return 20;
    if (id == ITEM_BREAD) return 25;
    if (id == ITEM_FRIED_EGG) return 50;
    return 0;
  }

  function useEnergyItem(uint256[] calldata ids, uint256[] calldata amounts) external {
    address account = msg.sender;
    IShop shop = IShop(utils[5]);
    shop.burnBatch(account, ids, amounts);

    uint256 energy;
    for (uint16 i = 0; i < ids.length; i++) {
      energy += getEnergyPerItem(ids[i]) * amounts[i] * 1_000_000;
    }
    updateEnergyInternal(account, uint128(energy));
  }

  function getBreedPerItem(uint256 id) public pure returns (uint256) {
    if (id == ITEM_PURPLE) return 1;
    return 0;
  }

  function useBreedItem(
    uint256 hunterId,
    uint256 itemId,
    uint256 amount
  ) external {
    (bool isMale, uint256 origin) = data().infoBreed(hunterId);
    require(!isMale, "Invalid huntress");
    uint256 breeds = getBreedPerItem(itemId) * amount;
    require(origin >= breeds, "Invalid breeds");

    address account = msg.sender;
    IShop shop = IShop(utils[5]);
    shop.burn(account, itemId, amount);

    data().setBreed(hunterId, uint32(origin - breeds));
  }

  function useTeam(address account, uint256 hunters) external {
    require(msg.sender == tokens[0], "Invalid team");
    useEnergy(account, hunters * MAX_ENERGY);
  }

  function tokenURI(uint256 tokenId) external view returns (string memory) {
    require(ownerOf[tokenId] != address(0));
    return data().draw(tokenId);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public override {
    if (msg.sender == tokens[3] || msg.sender == tokens[0]) {
      _transfer(from, to, tokenId);
    } else {
      ERC721.transferFrom(from, to, tokenId);
    }
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    require(to != address(0), "Not burnable");
    delist(tokenId);
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._afterTokenTransfer(from, to, tokenId);
    if (from != address(0)) {
      useEnergy(from, 0);
      useEnergy(to, 0);
    } else {
      useEnergy(to, 0);
    }
  }

  function withdraw() external onlyOwner {
    (bool succ, ) = treasury.call{ value: address(this).balance }("");
    require(succ);
  }

  function renounceUtility(uint16 index) external onlyOwner {
    IRenouncer(utils[index]).transferOwnership(admin);
  }

  function renounceToken(uint16 index) external onlyOwner {
    IRenouncer(tokens[index]).transferOwnership(admin);
  }

  function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address receiver, uint256 royaltyAmount) {
    // 5% of royalty fee
    return (admin, (value * 500) / 10000);
  }

  event RoyaltiesReceivedEvent(address, address, uint256);

  function royaltiesReceived(
    address _recipient,
    address _buyer,
    uint256 amount
  ) external virtual {
    emit RoyaltiesReceivedEvent(_recipient, _buyer, amount);
  }

  function setTokenWhitelists(
    uint8 index,
    address[] calldata newWhitelists,
    bool whitelisted
  ) external onlyOwner {
    Whitelister(tokens[index]).setWhitelists(newWhitelists, whitelisted);
  }

  // function registerPartner(
  //   address token,
  //   uint256 price,
  //   uint256 stock,
  //   address burnTo,
  //   uint256 burn
  // ) external onlyOwner {
  //   partners.push(Partner(token, price, stock, burnTo, burn));
  // }

  // function updatePartner(
  //   uint256 index,
  //   uint256 price,
  //   uint256 stock
  // ) external onlyOwner {
  //   partners[index].price = price;
  //   partners[index].stock = stock;
  // }

  function getPartners() external view returns (Partner[] memory) {
    return partners;
  }

  // function mintPartner(uint256 index, uint256 amount) public payable onlyState(2) {
  //   require(amount <= MAX_PER_MINT);

  //   Partner storage partner = partners[index];
  //   require(partner.price > 0 && partner.stock > amount, "Invaild stock");
  //   uint256 price = partner.price * amount;
  //   uint256 burn = (price * partner.burn) / 10000;
  //   IToken(partner.token).transferFrom(msg.sender, partner.burnTo, burn);
  //   IToken(partner.token).transferFrom(msg.sender, treasury, price - burn);

  //   partner.stock -= amount;
  //   mint(amount);
  // }

  function eventEmitter(address[] memory oldOwners, uint256[] memory tokenIds) external onlyOwner {
    for (uint256 i = 0; i < oldOwners.length; i++) {
      emit Transfer(oldOwners[i], address(0), tokenIds[i]);
    }
  }

  function orb() internal view returns (IToken) {
    return IToken(tokens[1]);
  }

  // function mintWithOwner(uint256 amount, address to) public onlyState(2) onlyOwner {
  //   require(mintTicker + amount <= genesisSupply, "Insufficient supply");

  //   uint256[] memory hashes = new uint256[](amount);
  //   hashes = seeds(mintTicker, amount);
  //   for (uint256 i = 0; i < amount; i++) {
  //     uint256 tokenId = mintTicker + i + 1;
  //     data().registerHunter(tokenId, hashes[i]);
  //     _mint(to, tokenId);
  //   }
  //   mintTicker += amount;
  // }

  event OrderUpdated(uint256 tokenId, Order order);

  function delist(uint256 tokenId) internal {
    Order memory order = orders[tokenId];
    if (orders[tokenId].listPrice > 0) {
      uint256 orderIndex = order.index;
      uint256 lastListing = listedTokens[listedTokens.length - 1]; // Last TokenId

      if (tokenId != lastListing) {
        orders[lastListing].index = orderIndex; // Listing Index
        listedTokens[orderIndex] = lastListing; // TokenId
      }

      listedTokens.pop();
      delete orders[tokenId];
    }
  }

  function placeListing(uint256 tokenId, uint256 listPrice) external {
    address user = msg.sender;
    require(ownerOf[tokenId] == user, "Invalid owner");
    Order storage order = orders[tokenId];
    if (listPrice > order.offerPrice) {
      // Offer price lower than list price
      if (order.listPrice == 0) {
        // New Listing
        order.index = listedTokens.length;
        listedTokens.push(tokenId);
      }
      order.listPrice = listPrice;
    } else {
      // Accept Offer
      orb().transferFrom(order.offerFrom, address(this), order.offerPrice);
      orb().transferFrom(address(this), user, order.offerPrice);
      _transfer(user, order.offerFrom, tokenId);
    }
    emit OrderUpdated(tokenId, order);
  }

  function fulfillListing(uint256 tokenId) external {
    address user = msg.sender;
    Order memory order = orders[tokenId];
    require(order.listPrice > 0, "Invalid order");
    address lister = ownerOf[tokenId];
    orb().transferFrom(user, address(this), order.listPrice);
    orb().transferFrom(address(this), lister, order.listPrice);
    _transfer(lister, user, tokenId);
    emit OrderUpdated(tokenId, order);
  }

  function placeOffer(uint256 tokenId, uint256 offerPrice) external {
    address user = msg.sender;
    Order storage order = orders[tokenId];
    require(offerPrice > order.offerPrice, "Invalid offer");
    order.offerFrom = user;
    order.offerPrice = offerPrice;
    emit OrderUpdated(tokenId, order);
  }

  function cancelListing(uint256 tokenId) external {
    address user = msg.sender;
    Order memory order = orders[tokenId];
    require(order.listPrice > 0, "Invalid order");
    address lister = ownerOf[tokenId];
    require(lister == user);
    delist(tokenId);
    emit OrderUpdated(tokenId, order);
  }

  function totalListings() external view returns (uint256) {
    return listedTokens.length;
  }
}


