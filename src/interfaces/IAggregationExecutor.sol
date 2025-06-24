// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

interface IAggregationExecutor {
    /// @notice Propagates information about original msg.sender and executes arbitrary data
    /// @param msgSender The address of the original message sender
    /// @return The execution result
    function execute(address msgSender) external payable returns (uint256);
}