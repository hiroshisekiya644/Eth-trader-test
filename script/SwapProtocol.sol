// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {SwapProtocol} from "../src/SwapProtocol.sol";

contract SwapProtocolScript is Script {
    SwapProtocol public swapProtocol;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        swapProtocol = new SwapProtocol(0x111111125421cA6dc452d289314280a0f8842A65, 0x11111112542D85B3EF69AE05771c2dCCff4fAa26);

        console.log("SwapProtocol deployed at", address(swapProtocol));

        vm.stopBroadcast();
    }
}