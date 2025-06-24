// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { IAggregationExecutor } from "./IAggregationExecutor.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice The description of the swap to be executed
/// @param srcToken The token to be swapped from
/// @param dstToken The token to be swapped to
/// @param srcReceiver The address to receive the swapped tokens
/// @param dstReceiver The address to receive the swapped tokens
/// @param amount The amount of tokens to be swapped
/// @param minReturnAmount The minimum amount of tokens to be returned
/// @param flags The flags for the swap

struct SwapDescription {
    IERC20 srcToken;
    IERC20 dstToken;
    address payable srcReceiver;
    address payable dstReceiver;
    uint256 amount;
    uint256 minReturnAmount;
    uint256 flags;
}

interface IAggregationRouterV6 {

    /// @notice Swaps tokens using the 1inch Aggregation Router V6
    /// @param executor The executor of the swap
    /// @param desc The description of the swap
    /// @param data The data for the swap
    /// @return returnAmount The amount of tokens returned
    /// @return spentAmount The amount of tokens spent

    function swap(
        IAggregationExecutor executor,
        SwapDescription calldata desc,
        bytes calldata data
    ) external payable returns (uint256 returnAmount, uint256 spentAmount);
}
