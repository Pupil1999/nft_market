// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

contract BimToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("BimToken", "BTK") {
        _mint(msg.sender, initialSupply);
    }

    function transferAndCall(
        address to, // the address that receives BTK
        uint256 amount, // the amount of BTK transfered
        bytes memory data // the calldata that will be used in contract at address to_
    ) external returns (bool){
        // transfer tokens in this contract
        require(
            transfer(to, amount),
            "token transfer failed"
        );

        // invoke the callback function of contract at address to
        bytes4 ret = IERC1363Receiver(to).onTransferReceived(
            msg.sender, 
            address(this),
            amount,
            data
        );

        return ret == IERC1363Receiver.onTransferReceived.selector;
    }
}
