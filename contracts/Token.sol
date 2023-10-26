// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{
    constructor() ERC20 ('JASON','JSN'){
        _mint(msg.sender, 10000000000000000000000000);
    }
    function _approve(address owner, uint amount) public{
        ERC20.approve(owner, amount);
    }
}