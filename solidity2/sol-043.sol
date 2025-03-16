// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Account} from "sce/sol/Account.sol";

contract Bank {
    Account[] public accounts;

    function createAccount(address owner) external {
        Account account = new Account(owner, 0);
        accounts.push(account);
    }

    function createAccountAndSendEther(address owner) external payable {
        Account account = (new Account){value: msg.value}(owner, 0);
        accounts.push(account);
    }

    function createSavingsAccount(address owner) external {
        // Write your code here
        Account account = new Account(owner, 1000);
        accounts.push(account);
    }
}