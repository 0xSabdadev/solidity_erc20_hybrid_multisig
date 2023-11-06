// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{
    constructor() ERC20 ('DIYUT','DYT'){
        _mint(msg.sender, 10000000000000000000000000);
    }
    function _approve(address owner, uint amount) public{
        ERC20.approve(owner, amount);
    }
}