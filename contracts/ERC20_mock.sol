// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract MOCK_ERC20 is ERC20 {
    constructor() ERC20("Mold", "MLD") {
        _mint(msg.sender, 10000);
    }
}
