// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BimNFT is ERC721 ("BimNFT", "BNFT"){
    uint256 nextTokenId;

    constructor() {
        nextTokenId = 0;
    }

    function mint() public returns (uint256) {
        nextTokenId ++;
        _mint(msg.sender, nextTokenId);

        return nextTokenId;
    }

    // inherit ERC721 is sufficient to do the other required logistics
    // Specifically, we will use safeTransferFrom, which will internally
    // call the IERC721Receiver.onERC721Receiver
}