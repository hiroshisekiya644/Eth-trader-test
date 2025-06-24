// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IAggregationExecutor} from "./interfaces/IAggregationExecutor.sol";
import {IAggregationRouterV6, SwapDescription} from "./interfaces/IAggregationRouterV6.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

struct UserInfo {
    uint256 buyCount;
    uint256 sellCount;
}

contract SwapProtocol is Ownable {
    IAggregationRouterV6 public router;
    IERC20 public stablecoin;

    mapping(address => UserInfo) public userToInfo;

    event SellEth(
        address indexed user,
        uint256 ethAmount,
        uint256 tokenAmount
    );

    event BuyEth(
        address indexed user,
        uint256 tokenAmount,
        uint256 ethAmount
    );

    constructor(
        address _router,
        address _stablecoin
    ) Ownable(msg.sender) {
        router = IAggregationRouterV6(_router);
        stablecoin = IERC20(_stablecoin);
    }

    receive() external payable {}

    function sellEth(
        uint256 ethAmount,
        uint256 desirePrice,
        address executor,
        bytes calldata data,
        uint256 expirationTime
    ) external payable returns (uint256 returnAmount, uint256 spentAmount) {
        require(msg.value >= ethAmount, "Insufficient ETH sent");
        require(block.timestamp < expirationTime, "Trade expired");

        SwapDescription memory desc = SwapDescription({
            srcToken: IERC20(address(0)),
            dstToken: stablecoin,
            srcReceiver: payable(executor),
            dstReceiver: payable(msg.sender),
            amount: ethAmount,
            minReturnAmount: desirePrice,
            flags: 0
        });

        (returnAmount, spentAmount) = _executeSwap(executor, desc, data);

        require(returnAmount >= desirePrice, "Insufficient return amount");
        require(spentAmount <= ethAmount, "Insufficient spent amount");

        userToInfo[msg.sender].sellCount++;

        emit SellEth(msg.sender, ethAmount, returnAmount);
    }

    function buyEth(
        uint256 tokenAmount,
        uint256 desireAmount,
        address executor,
        bytes calldata data,
        uint256 expirationTime
    ) external payable returns (uint256 returnAmount, uint256 spentAmount) {
        require(block.timestamp < expirationTime, "Trade expired");

        require(stablecoin.transferFrom(msg.sender, address(this), tokenAmount), "Transfer failed");

        stablecoin.approve(address(router), tokenAmount);

        SwapDescription memory desc = SwapDescription({
            srcToken: stablecoin,
            dstToken: IERC20(address(0)),
            srcReceiver: payable(executor),
            dstReceiver: payable(msg.sender),
            amount: tokenAmount,
            minReturnAmount: desireAmount,
            flags: 0
        });

        (returnAmount, spentAmount) = _executeSwap(executor, desc, data);

        require(returnAmount >= desireAmount, "Insufficient return amount");
        require(spentAmount <= tokenAmount, "Insufficient spent amount");

        userToInfo[msg.sender].buyCount++;

        emit BuyEth(msg.sender, tokenAmount, returnAmount);
    }

    function _executeSwap(
        address executor,
        SwapDescription memory desc,
        bytes calldata data
    ) internal returns (uint256 returnAmount, uint256 spentAmount) {
        (returnAmount, spentAmount) = router.swap{value: msg.value}(
            IAggregationExecutor(executor),
            desc,
            data
        );
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    function setRouter(address _router) external onlyOwner {
        router = IAggregationRouterV6(_router);
    }
}
