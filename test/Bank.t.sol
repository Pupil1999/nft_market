// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;

    function setUp() public {
        bank = new Bank();
    }

    function test_depositAndEmit() public {
        bytes memory data = abi.encodeWithSignature("depositETH()");
    
        vm.expectEmit(address(bank)); // expect the bank contract to emit the following event
        emit Bank.Deposit(address(this), 1 ether);

        (bool suc1, ) = address(bank).call{value: 1 ether}(data);
        assert(suc1);
        assertEq(address(bank).balance, 1 ether);
        assertEq(bank.balanceOf(address(this)), 1 ether);
    }
}