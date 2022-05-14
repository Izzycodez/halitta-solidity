 // SPDX-License-Identifier: MIT

pragma solidity 0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IzzyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("HALITTA", "HLT") {
        _mint(msg.sender, initialSupply);
    }

}
