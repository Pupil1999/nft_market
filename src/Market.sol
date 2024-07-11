// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Market is IERC1363Receiver, IERC721Receiver{
    address public currency; // the address of ERC20 contract
    address public goods;    // the address of ERC721 contract
    struct tokenInfo {
        address owner;
        uint256 price;
    }

    event OnMarket(address indexed owner, uint256 indexed tokenId, uint256 indexed price);
    event TokenBought(address indexed oldOwner, address indexed newOwner, uint256 tokenId);

    // the price of some NFT token
    // tokenId => owner => price
    mapping(uint256 => tokenInfo) public tokenInfoOf; 

    constructor(address erc20Addr, address erc721Addr) {
        currency = erc20Addr;
        goods = erc721Addr;
    }

    function _list(
        address owner,
        uint256 tokenId, 
        uint256 price
    ) internal returns (bool) {
        require(
            address(this) == IERC721(goods).ownerOf(tokenId),
            "market is not the owner yet"
        );
        tokenInfo memory newToken = tokenInfo({owner: owner, price: price});
        tokenInfoOf[tokenId] = newToken;
        IERC721(goods).approve(address(this), tokenId);
        emit OnMarket(owner, tokenId, price);

        return true;
    }

    function _buyNFT(
        address buyer,
        uint256 tokenId,
        uint256 payment
    ) internal returns (bool) {
        tokenInfo memory item = tokenInfoOf[tokenId];
        if(item.price == 0)
            revert("no such token");
        require(
            payment >= item.price,
            "Inadequate payment"
        );
        uint256 change = payment - item.price;
        if(change > 0) {
            require(
                IERC20(currency).transfer(buyer, change),
                "change return failed"
            );
        }
        IERC721(goods).transferFrom(address(this), buyer, tokenId);
        IERC20(currency).transfer(item.owner, payment);
        emit TokenBought(item.owner, buyer, tokenId);

        delete tokenInfoOf[tokenId]; // once payment succeeded, the token is out of market
        return true;
    }

    function onTransferReceived(
        address operator,
        address,
        uint256 amount,
        bytes memory data
    ) external returns (bytes4) {
        require(msg.sender == currency, "Invalid ERC20 token source");
        uint256 tokenId = abi.decode(data, (uint256));
        require(
            _buyNFT(operator, tokenId, amount),
            "Buying NFT failed"
        );

        return IERC1363Receiver.onTransferReceived.selector;
    }

    // Once the owner approved this token to this contract, this function
    // will be called to invoke {_list()} to add the token to the public list.
    function onERC721Received(
        address operator, // the address that transfered token in erc721 contract
        address,
        uint256 tokenId,
        bytes calldata data // the price encoded to calldata
    ) external returns (bytes4) {
        require(msg.sender == goods, "Invalid ERC721 token source");
        uint256 price = abi.decode(data, (uint256));
        require(
            _list(operator, tokenId, price),
            "listing failed in erc721 receiver"
        );

        return IERC721Receiver.onERC721Received.selector;
    }
}