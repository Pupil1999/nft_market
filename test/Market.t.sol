// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Market.sol";
import "../src/BimNFT.sol";
import "../src/BimToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MarketTest is Test {
    BimToken public currency;
    BimNFT public goods;
    Market public market;

    constructor() {
        currency = new BimToken(1_000_000_000_000_000_000_000_000);
        goods = new BimNFT();
        market = new Market(address(currency), address(goods));
        deal(address(this), 1000);
    }

    function test_NFTMint() public {
        uint256 tid = goods.mint();
        assertEq(tid, 1);
    }

    function test_onMarket(uint256 tokenPrice) public {
        vm.assume(tokenPrice > 0 && tokenPrice < 1_000_000_000);
        address addr1 = address(0x123);
        vm.startPrank(addr1);
        uint256 tokenId1 = goods.mint();
        assertEq(goods.ownerOf(tokenId1), addr1);

        // Putting tokens onto market is done by the owner calling transfer function
        // in ERC721 contract which has a hook to market
        vm.expectEmit(true, true, true, true, address(market));
        emit Market.OnMarket(addr1, tokenId1, tokenPrice);
        bytes memory data = abi.encode(tokenPrice);
        goods.safeTransferFrom(address(addr1), address(market), tokenId1, data);
        
        // testing whether a non-owner can put token on market.
        uint256 tokenId2 = goods.mint();
        vm.stopPrank();

        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)", 
                address(this), 
                tokenId2
            )
        );
        // It will revert an insufficient approval error, which is defined in
        // interface IERC6093.sol, since I simply use the implementation of ERC721.
        goods.safeTransferFrom(address(this), address(market), tokenId2, data);
    }

    function test_buyNFT(uint256 tokenPrice, address buyer) public {
        vm.assume(tokenPrice > 0 && tokenPrice < 10000);
        vm.assume(buyer != address(0));
        uint256 tokenId = goods.mint();
        bytes memory price = abi.encode(tokenPrice);
        goods.safeTransferFrom(address(this), address(market), tokenId, price);

        currency.transfer(buyer, tokenPrice);

        vm.prank(buyer);
        bytes memory tid = abi.encode(tokenId);
        // Buying should pass.
        assert(currency.transferAndCall(address(market), tokenPrice, tid));
        assertEq(buyer, goods.ownerOf(tokenId));
    }

    function test_repeatedBuy(uint256 tokenPrice, address buyer) public {
        vm.assume(tokenPrice > 0 && tokenPrice < 10000);
        vm.assume(buyer != address(0));
        uint256 tokenId = goods.mint();
        bytes memory price = abi.encode(tokenPrice);
        goods.safeTransferFrom(address(this), address(market), tokenId, price);

        currency.transfer(buyer, tokenPrice);

        address oldOwner = address(this);

        vm.startPrank(buyer);
        
        vm.expectEmit(true, true, true, true, address(market));
        emit Market.TokenBought(oldOwner, buyer, tokenId);
        // Buying should pass.
        bytes memory tid = abi.encode(tokenId);
        assert(currency.transferAndCall(address(market), tokenPrice, tid));
        vm.stopPrank();

        vm.expectRevert("no such token");
        currency.transfer(buyer, tokenPrice);
        vm.startPrank(buyer);
        currency.transferAndCall(address(market), tokenPrice, tid);
        vm.stopPrank();
    }

    function test_inadequatePayment(uint256 tokenPrice, address buyer) public {
        vm.assume(tokenPrice > 0 && tokenPrice < 10000);
        vm.assume(buyer != address(0));
        uint256 tokenId = goods.mint();

        // Put token on market
        bytes memory price = abi.encode(tokenPrice);
        goods.safeTransferFrom(address(this), address(market), tokenId, price);

        currency.transfer(buyer, tokenPrice);

        vm.prank(buyer);
        bytes memory tid = abi.encode(tokenId);
        // Should revert because payment is not enough.
        vm.expectRevert("Inadequate payment");
        currency.transferAndCall(address(market), tokenPrice - 1, tid);
    }


    function test_OverPayment(uint256 tokenPrice, address buyer) public {
        vm.assume(tokenPrice > 0 && tokenPrice < 10000);
        vm.assume(buyer != address(0));
        uint256 tokenId = goods.mint();

        // Put token on market
        bytes memory price = abi.encode(tokenPrice);
        goods.safeTransferFrom(address(this), address(market), tokenId, price);

        currency.transfer(buyer, tokenPrice + 100);

        vm.startPrank(buyer);
        bytes memory tid = abi.encode(tokenId);
        // Shouldn't revert, but will pass invariant test.
        currency.transferAndCall(address(market), tokenPrice + 1, tid);
        assertEq(100, currency.balanceOf(buyer));
        vm.stopPrank();
    }

    function invariant_MarketHasNoERC20() public view{
        assertEq(0, currency.balanceOf(address(market)));
    }
    
}