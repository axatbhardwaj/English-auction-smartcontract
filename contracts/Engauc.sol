//spdix-license-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract EnglishAuction {
    event Auctionstart();
    event Bid(address bidder, uint256 amount);
    event Withdraw(address winner, uint256 amount);
    event End();

    IERC721 public nft;
    uint256 public nftID;

    address winner;
    address public seller;
    uint256 public startingPrice;
    uint256 public endTime;

    bool started = false;
    bool ended = false;

    mapping(address => uint256) public bids;

    address highestBidder;

    constructor(
        IERC721 _nft,
        uint256 _nftID,
        address _seller,
        uint256 _startingPrice,
        uint256 _endTime
    ) public {
        nft = _nft;
        nftID = _nftID;
        seller = _seller;
        startingPrice = _startingPrice;
        endTime = _endTime;
    }

    function start() public payable {
        require(!started, "Auction has already started");
        require(msg.sender != seller, "Seller cannot bid");
        nft.safeTransferFrom(msg.sender, address(this), nftID);
        started = true;
    }

    function bid(uint256 _bidAmount) external payable {
        require(started, "Auction has not started");
        require(!ended, "Auction has ended");
        require(_bidAmount > 0, "Bid must be greater than 0");
        require(msg.sender != seller, "Seller cannot bid");
        require(
            _bidAmount > bids[highestBidder],
            "Bid must be greater than or equal to current highest bid"
        );
        require(
            msg.value >= startingPrice,
            "Bid must be greater than or equal to starting price"
        );
        bids[msg.sender] = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    function updateEndTime(uint256 _endTime) public {
        endTime = _endTime;
    }
}
