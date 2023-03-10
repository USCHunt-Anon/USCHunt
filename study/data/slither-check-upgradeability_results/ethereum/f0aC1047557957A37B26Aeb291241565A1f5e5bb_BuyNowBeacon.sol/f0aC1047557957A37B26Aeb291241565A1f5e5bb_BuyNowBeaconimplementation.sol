


// : MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}


// : UNLICENSED

pragma solidity >=0.8.0 <0.9.0;

//import"@openzeppelin/contracts/proxy/utils/Initializable.sol";

abstract contract MonegraphAuction is Initializable {
    address payable public beneficiary;
    string public metadata;

    address public highestBidder;
    uint256 public highestBid;

    uint256 public initialBidAmount;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public finalizedTime;

    uint256 public constant duration = 86400;
    uint256 public constant extensionPeriod = 900;

    struct Bid {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Bid[]) public bids;

    modifier notZeroAddress(address addr) {
        require(addr != address(0));
        _;
    }

    modifier onlyBefore(uint256 _time) {
        require(block.timestamp < _time);
        _;
    }

    modifier onlyAfter(uint256 _time) {
        require(block.timestamp > _time);
        _;
    }

    modifier auctionHasStarted() {
        require(startTime <= block.timestamp, "Auction has not started yet");
        _;
    }

    modifier auctionNotClosed() {
        require(
            endTime == 0 || endTime >= block.timestamp,
            "Auction already ended."
        );
        _;
    }

    modifier auctionClosed() {
        require(
            endTime != 0 && endTime <= block.timestamp,
            "This auction is still active"
        );
        _;
    }

    modifier auctionNotFinalized() {
        require(finalizedTime == 0, "Auction has already been finalized");
        _;
    }

    function initialize(
        address payable _beneficiary,
        string memory _metadata,
        uint256 _initialBidAmount,
        uint256 _startTime,
        uint256 _endTime
    ) public virtual initializer {
        _startTime = _startTime > 0 && _startTime > block.timestamp
            ? _startTime
            : block.timestamp;

        endTime = _endTime > 0 && _endTime > block.timestamp ? _endTime : 0;

        beneficiary = _beneficiary;
        metadata = _metadata;
        initialBidAmount = _initialBidAmount;
        startTime = _startTime;
    }

    function bid() public payable virtual;
}





// : UNLICENSED

pragma solidity >=0.8.0 <0.9.0;

//import"./abstract/Auction.sol";

contract BuyNowAuction is MonegraphAuction {
    event AuctionCreated(string metadata);
    event BidReceived(address bidder);

    modifier minimumBid() {
        require(
            msg.value >= initialBidAmount,
            "Incorrect purchase price received"
        );
        _;
    }

    function initialize(
        address payable _beneficiary,
        string memory _metadata,
        uint256 _initialBidAmount
    ) public notZeroAddress(_beneficiary) {
        super.initialize(
            _beneficiary,
            _metadata,
            _initialBidAmount,
            block.timestamp,
            0
        );

        emit AuctionCreated(metadata);
    }

    function bid()
        public
        payable
        override
        auctionHasStarted
        auctionNotClosed
        minimumBid
    {
        beneficiary.transfer(msg.value);

        highestBidder = msg.sender;
        highestBid = msg.value;
        endTime = block.timestamp;
        finalizedTime = block.timestamp;

        bids[msg.sender].push(
            Bid({amount: msg.value, timestamp: block.timestamp})
        );

        emit BidReceived(msg.sender);
    }
}
