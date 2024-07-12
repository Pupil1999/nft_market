// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SampleERC20.sol";

contract TokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SampleToken nft = new SampleToken("SampleToken", "ST");

        vm.stopBroadcast();
    }
}