// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "./Multisig.sol";

contract MultiSigFactory{

    struct UserWallets{
        address walletAdress;
    }

    UserWallets[] userWallets;
    MultiSigTA[] multisigWalletInstances;

    mapping(address => UserWallets[]) ownersWallets;

    event walletCreated(address createdBy, address newWalletContractAddress, uint timeOfTransaction);

    function createNewWallet() public{
        MultiSigTA newMultisigWalletContract = new MultiSigTA();
        multisigWalletInstances.push(newMultisigWalletContract);
        UserWallets[] storage newWallet = ownersWallets[msg.sender];
        newWallet.push(UserWallets(address(newMultisigWalletContract)));

        emit walletCreated(msg.sender, address(newMultisigWalletContract), block.timestamp);
    }

    function addNewWalletInstance(address owner, address walletAddress) public{
        UserWallets[] storage newWallet = ownersWallets[owner];
        newWallet.push(UserWallets(walletAddress));
    }
    function removeNewWalletInstance(address _owner, address _walletAddress) public{
        UserWallets[] storage newWallet = ownersWallets[_owner];
        bool hasBeenFound = false;
        uint walletIndex;
        for (uint i = 0; i < newWallet.length; i++) {
            if(newWallet[i].walletAdress == _walletAddress) {
                hasBeenFound = true;
                walletIndex = i;
                break;
            }
        }
        require(hasBeenFound == true, "wallet owner tidak terdetect");
        newWallet[walletIndex] = newWallet[newWallet.length - 1];
        newWallet.pop();
    }

    function getOwnerWallets(address owner) public view returns(UserWallets[] memory){
        return ownersWallets[owner];
    }
    
}