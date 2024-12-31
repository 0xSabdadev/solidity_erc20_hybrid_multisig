// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IMultiSigTA {
    function deposit(string memory ticker, uint amount) external payable;
    function createTransferRequest(string memory ticker, address payable receiver, uint amount) external;
    function approveTransferRequest(string memory ticker, uint id) external;
    function getBalance(string memory ticker) external view returns(uint);
}

contract GasAnalyzer {
    IMultiSigTA public multiSig;
    
    event GasUsed(string operation, uint gasUsed);
    event BalanceLog(string message, uint contractBalance, uint multisigBalance);
    
    constructor(address _multiSig) {
        multiSig = IMultiSigTA(_multiSig);
    }
    
    // Fungsi untuk mencatat gas yang digunakan
    function measureGas(string memory operation, uint startGas) internal {
        uint gasUsed = startGas - gasleft();
        emit GasUsed(operation, gasUsed);
    }

    // Fungsi debug balance
    function debugBalance() external view returns (uint, uint) {
        return (
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
    
    // Deposit ke MultiSig dan ukur gas
    function testDeposit() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        
        emit BalanceLog(
            "Pre-deposit Balance",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
        
        uint startGas = gasleft();
        multiSig.deposit{value: 1 ether}("ETH", 1 ether);
        measureGas("MultiSig Deposit", startGas);
        
        emit BalanceLog(
            "Post-deposit Balance",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
    
    // Test transfer ETH standard
    function testSimpleTransfer(address payable to) external payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        
        uint startGas = gasleft();
        (bool success,) = to.call{value: 1 ether}("");
        require(success, "Transfer failed");
        measureGas("Simple ETH Transfer", startGas);
        
        emit BalanceLog(
            "Post-transfer Balance",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
    
    // Test setiap step di MultiSig
    function testMultiSigCreateTransfer(address payable to) external {
        uint startGas = gasleft();
        multiSig.createTransferRequest("ETH", to, 1 ether);
        measureGas("MultiSig Create Transfer", startGas);
        
        emit BalanceLog(
            "Post-create Balance",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
    
    function testMultiSigApprove(uint id) external {
        uint startGas = gasleft();
        multiSig.approveTransferRequest("ETH", id);
        measureGas("MultiSig Approve", startGas);
        
        emit BalanceLog(
            "Post-approve Balance",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
    
    // Fungsi untuk menerima ETH
    receive() external payable {
        emit BalanceLog(
            "Received ETH",
            address(this).balance,
            multiSig.getBalance("ETH")
        );
    }
}