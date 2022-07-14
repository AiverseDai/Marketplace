//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma abicoder v2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC1155/IERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.1/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.1/contracts/utils/EnumerableSet.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC1155/IERC1155Receiver.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface aiverseGenX{

    function getCreator(uint256 tokenId) external view returns(address);
    function royaltyFee(uint256 tokenId)external view returns(uint256);

}
contract Auction is IERC1155Receiver{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    
    IERC1155 public TokenX;
   
    address public kudo;
    
    mapping(address => conductedAuctionList)conductedAuction;
     
    mapping(address => mapping(uint256 =>uint256))participatedAuction;
     
    mapping(address => histo)history;
     
    mapping(address => uint256[])collectedArts;
     
     struct histo{
        uint256[] list;
     }
     
     struct conductedAuctionList{
        uint256[] list;
     }
     
    //mapping(uint256 => auction)auctiondetails;
    
    //mapping(address => mapping(uint256 => uint256))biddersdetails;
    
    uint256 public auctionTime = uint256(5 days);   
    
    Counters.Counter private totalAuctionId;
    
    enum auctionStatus { ACTIVE, OVER }
    
    auction[] internal auctions;
    
    EnumerableSet.UintSet TokenIds;
    
    
    //bidder[] internal bidders;
    
    address payable market;
    
    uint256 marketFeePercent = 2 ;
    
    enum Saletype{AUCTION,FIXED}
    
    struct auction{
        uint256 auctionId;
        uint256 start;
        uint256 end;
        uint256 tokenId;
        uint256 amount;
        address auctioner;
        address highestBidder;
        uint256 highestBid;
        address[] prevBid;
        uint256[] prevBidAmounts;
        address tokenaddress;
        auctionStatus status;
        Saletype sale;
    }
 
    constructor(IERC1155 _tokenx){
        TokenX = _tokenx;
        kudo=address(_tokenx);
    }
    
    function _ownerOf(uint256 tokenId) internal view returns (bool) {
         return TokenX.balanceOf(msg.sender, tokenId) != 0;
    }
    
    
    function createSaleAuction(uint256 _tokenId,uint256 _amount,uint256 _price,address _tokenaddress)public returns(uint256){
	    require(_ownerOf(_tokenId) == true, "Auction your NFT");
	    
	    auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        start: block.timestamp,
        end : block.timestamp.add(auctionTime),
        tokenId: _tokenId,
        amount:_amount,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        tokenaddress:_tokenaddress,
        status: auctionStatus.ACTIVE,
        sale:Saletype.AUCTION
	    });
	    
	    conductedAuctionList storage list = conductedAuction[msg.sender];
	    list.list.push(totalAuctionId.current());
	    auctions.push(_auction);
	    TokenX.safeTransferFrom(address(msg.sender),address(this),_amount,_tokenId,'0x');
	    
	    totalAuctionId.increment();
	    return uint256(totalAuctionId.current());
    }

    function fixedSale(uint256 _tokenId,uint256 _price,address _tokenaddress,uint256 _amount) public{
       require(_ownerOf(_tokenId) == true, "Auction your NFT");
	    
	    auction memory _auction = auction({
	    auctionId : totalAuctionId.current(),
        start: block.timestamp,
        end : block.timestamp.add(auctionTime),
        tokenId: _tokenId,
        amount:_amount,
        auctioner: msg.sender,
        highestBidder: msg.sender,
        highestBid: _price,
        prevBid : new address[](0),
        prevBidAmounts : new uint256[](0),
        tokenaddress:_tokenaddress,
        status: auctionStatus.ACTIVE,
        sale:Saletype.AUCTION
	    });
	    
	    conductedAuctionList storage list = conductedAuction[msg.sender];
	    list.list.push(totalAuctionId.current());
	    auctions.push(_auction);
	    TokenX.safeTransferFrom(address(msg.sender),address(this),_tokenId,_amount,'0x');
	    totalAuctionId.increment();
	}

    function finishFixedSale(uint256 _auctionId) public{
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        auction storage auction = auctions[_auctionId];
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;
        auction.highestBidder=msg.sender;
        uint256 marketFee = auction.highestBid.mul(marketFeePercent).div(100);
        collectedArts[auctions[_auctionId].highestBidder].push(auctions[_auctionId].tokenId);
        IERC20(auctions[_auctionId].tokenaddress).transfer(msg.sender,auctions[_auctionId].highestBid.sub(marketFee));
        IERC20(auctions[_auctionId].tokenaddress).transfer(msg.sender,marketFee);
        TokenX.safeTransferFrom(address(this),auctions[_auctionId].highestBidder,auctions[_auctionId].tokenId,auctions[_auctionId].amount,'0x');
    }
    
    function placeBid(uint256 _auctionId,uint256 _amount)public payable returns(bool){
        require(auctions[_auctionId].highestBid < msg.value,"Place a higher Bid");
        require(auctions[_auctionId].auctioner != msg.sender,"Not allowed");
        require(auctions[_auctionId].end > block.timestamp,"Auction Finished");
       
        auction storage auction = auctions[_auctionId];
        auction.prevBid.push(msg.sender);
        auction.prevBidAmounts.push(_amount);
        if(participatedAuction[auction.highestBidder][_auctionId] > 0){
        participatedAuction[auction.highestBidder][_auctionId] = participatedAuction[auction.highestBidder][_auctionId].add(auction.highestBid); 
        }else{
            participatedAuction[auction.highestBidder][_auctionId] = auction.highestBid;
        }
        
        histo storage history = history[msg.sender];
        history.list.push(_auctionId);
        
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        IERC20(auctions[_auctionId].tokenaddress).transfer(address(this),_amount);
        return true;
    }
    
    function finishAuction(uint256 _auctionId) public{
        require(auctions[_auctionId].auctioner == msg.sender,"only auctioner");
        require(uint256(auctions[_auctionId].end) >= uint256(block.number),"already Finshed");
        
        auction storage auction = auctions[_auctionId];
        auction.end = uint32(block.number);
        auction.status = auctionStatus.OVER;
        
        uint256 marketFee = auction.highestBid.mul(marketFeePercent).div(100);
        
        if(auction.prevBid.length > 0){
            
        for(uint256 i = 1; i < auction.prevBid.length; i++){
            if(participatedAuction[auctions[_auctionId].prevBid[i]][_auctionId] == auctions[_auctionId].prevBidAmounts[i] ){
            IERC20(auctions[_auctionId].tokenaddress).transfer(auctions[_auctionId].prevBid[i],auctions[_auctionId].prevBidAmounts[i]);
            }
        }
        collectedArts[auctions[_auctionId].highestBidder].push(auctions[_auctionId].tokenId);
        IERC20(auctions[_auctionId].tokenaddress).transfer(msg.sender,auctions[_auctionId].highestBid.sub(marketFee));
        IERC20(auctions[_auctionId].tokenaddress).transfer(address(this),marketFee);
        TokenX.safeTransferFrom(address(this),auctions[_auctionId].highestBidder,auctions[_auctionId].tokenId,auctions[_auctionId].amount,'0x');
        }
    }

    function getRoyaltyFee(uint256 _tokenid) public view returns(uint256){
        return aiverseGenX(kudo).royaltyFee(_tokenid);
    }

    function getOwner(uint256 _tokenid) public view returns(address){
        return aiverseGenX(kudo).getCreator(_tokenid);
    }
    
    function auctionStatusCheck(uint256 _auctionId)public view returns(bool){
        if(auctions[_auctionId].end > block.timestamp){
            return true;
        }else{
            return false;
        }
    }
    
    function auctionInfo(uint256 _auctionId)public view returns( uint256 auctionId,
        uint256 start,
        uint256 end,
        uint256 tokenId,
        address auctioner,
        address highestBidder,
        uint256 highestBid,
        uint256 status){
            
            auction storage auction = auctions[_auctionId];
            auctionId = _auctionId;
            start = auction.start;
            end =auction.end;
            tokenId = auction.tokenId;
            auctioner = auction.auctioner;
            highestBidder = auction.highestBidder;
            highestBid = auction.highestBid;
            status = uint256(auction.status);
        }
        
    function bidHistory(uint256 _auctionId) public view returns(address[]memory,uint256[]memory){
            return (auctions[_auctionId].prevBid,auctions[_auctionId].prevBidAmounts);
    }
        
    function participatedAuctions(address _user) public view returns(uint256[]memory){
           return history[_user].list;
    }

      function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external override returns (bytes4) {
    require(msg.sender == address(TokenX), "received from unauthenticated contract");
    TokenIds.add(id);
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }


    
    
    function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external override returns (bytes4) {
    require(msg.sender == address(TokenX), "received from unauthenticated contract");

    return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
  }
    

  function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
    return true;
  }

    function totalAuction() public view returns(uint256){
       return auctions.length;
    }
    
    function conductedAuctions(address _user)public view returns(uint256[]memory){
        return conductedAuction[_user].list;
    }
    
    function collectedArtsList(address _user)public view returns(uint256[] memory){
        return collectedArts[_user];
    }
}