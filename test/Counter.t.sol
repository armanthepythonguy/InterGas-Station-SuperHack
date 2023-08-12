// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/RemoteStation.sol";

contract CounterTest is Test {
    RemoteStation public remote;

    function setUp() public {
        remote = new RemoteStation(0xd38F25af941423cFB776eb63CE5F5Da7b3C4f315, 0xd38F25af941423cFB776eb63CE5F5Da7b3C4f315, 0xd38F25af941423cFB776eb63CE5F5Da7b3C4f315);
    }

    function test() public{
        address owner = 0xd38F25af941423cFB776eb63CE5F5Da7b3C4f315;
        vm.prank(owner);
        
    }
}
