// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



error NFTmarketPlace__priceMustBeAbouveZero();
error NFTmarketPlace__NotApprovedForMarketPlace(); 
error NFTmarketPlace__AlreadyListed(address nftAdress, uint256 tokenId);
error NFTmarketPlace__NotOwner();
error NFTmarketPlace__NotListed( address nftAddress, uint256 tokenId);
error NFTmarketPlace__PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error NFTmarketPlace__Noproceeds();
error NFTmarketPlace__TransferFailed();

contract NFTmarketPlace {
    struct Listing {
        uint256 price;
        uint256 tokenId;
        address seller; 
    }
  

     //////////////////
    //  EVENT         //
      //////////////////

    event ItemListed(
        address indexed seller, 
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    
    event ItemBought(
        address indexed buer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 indexed price
    );

    event ItemCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

     ///////////////////
     // Mapping ////////
    ////////////////////

    // Nft Contract address -> NFT Token -> Listing 
    mapping(address => mapping(uint256 => Listing)) private s_listings; 

    // Seller address -> Amount eraned 
    mapping(address => uint256) private s_proceeds;


      ///////////////////
   // Modifiers ////////
    ////////////////////
    modifier notListed(address nftAddress, uint256 tokenId, address owner,) {
        Listing memory listing = s_listing[nftAddress][tokenId];
        if (Listing.price >0) {
            revert NFTmarketPlace__AlreadyListed(nftAdress, tokenId);
        }
        _;
    }
    
    modifier isOwner(
        address nftAddress, 
        uint256 tokenId, 
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NFTmarketPlace__NotOwner();
        }
        _;
    }

     modifier isListed(address nftAddress, uint256 tokenId){
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0 ){
            revert NFTmarketPlace__NotListed(nftAddress, tokenId )
        }
        _;
    }

    
       //////////////////
      // Main Functions //
      //////////////////

        function listItem( 
            address 
            nftAddress, // countract nft
            uint256 
            tokenId, // NFT address
            uint256 
            price // the price of the NFTs
            address
            tokenPrice // 
        )

        external
        not_Listed(nftAdress, tokenId, msg.sender)
         isOwner(nftAdress, tokenId, msg.sender)

        {
            if(price <= 0){
                revert NFTmarketPlace__priceMustBeAbouveZero();
            }
            // 1. Send the NFT to the contract. Transfer -> Contract "hold" the NFT.
            // 2. Owners can still hold their NFT, and give the marktplace approal
            // to sell the NFT For them 
            IERC721 nft = IERC721(nftAddress);
            if (nft.getApproved(tokenId) != address(this)){
                revert NFTmarketPlace__NotApprovedForMarketPlace(); 
            }
            s_listings[nftAddress][tokenId] = Listing[price, msg.sender];
            emit ItemListed(msg.sender, nftAdress, tokenId, price);
        }

        function buyItem(address nftAddress, uint256, tokenId) 
        external payable 
        nonReentrant
        isListed(nftAddress, tokenId)
        {
            Listing memory listedItem = s_listings[nftAddress][tokenId];
            if(msg.value < listedItem.price) {
                revert NFTmarketPlace__PriceNotMet(nftAdress, tokenId, listedItem.price)
            }

            // we just send the seller the mony..?
            // have them withdraw the mony 
            s_proceed[listedItem.seller] = s_proceed[listedItem.seller] + msg.value;
            delete (s_listings[nftAddress][tokenId]); 
            IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
            // cjake make sure the NFT was transfered
            emit ItemBought(msg.sender, nftAddress, tokenId, listed Item.price)
        }


      function cancelListing(address nftaddress, uint256 tokenId) external 
      isOwner(nftaddress, tokenId, 
      msg.sender ) isListed(nftAddress,tokenId) 
      {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
      }

     function updatePrice(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
     ) external isListed
     (nftAddress, tokenId) 
     isOwner(nftAddress, tokenId, 
     msg.sender){
        s_listing[nftAddress][tokenId].price = newprice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
     }

     function WithdrawProceeds() external {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0){
            revert NFTmarketPlace__Noproceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value:proceeds}("")
        if(!success){
            revert NFTmarketPlace__TransferFailed();
        }
     }

      //////////////////////
      // Getter Functions//
      //////////////////////

    function getListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (Listing memory)
    {
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller) external view returns (uint256) {
        return s_proceeds[seller];
    }
}
      



// 1. Create a decentralized NFT Marketplace
//     1. `listItem`: List NFTs on the markteplace 
//     2. `buyItem`: Buy the NFTs 
//     3. `cancelItem`: Cancel a listing 
//     4. `updateListing`: Update Price 
//     5. `withdrawProceeds`: Withdraw payment for my  bought NFTs