//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.0;

// We import this library to be able to use console.log
import "hardhat/console.sol";

contract Transactions {
    address private owner;
    uint256 transactionCounts;
    mapping (address => uint) balanceOf;

    event Transfer(address indexed sender, address indexed receiver, uint256 amount,  uint256 timestamp);

    struct TransferStruct {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
        uint256 projectId;
        string nodeId;
    }
    TransferStruct[] transactions;

    
    mapping(uint => mapping(string => TransferStruct[])) public nested;

    constructor() {
        owner = msg.sender;
        balanceOf[tx.origin] = msg.sender.balance;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function sendMoney(address payable receiver, uint256 amount, uint256 _projectId, string memory _nodeId) public returns(bool success) {
        if (balanceOf[owner] < amount) return false;
        balanceOf[owner] -= amount;
        balanceOf[receiver] += amount;

        transactionCounts += 1;
        transactions.push(
            TransferStruct(
                owner,
                receiver,
                amount,
                block.timestamp,
                _projectId,
                _nodeId
            )
        );

        //maybe load nestedx -> get the array
        TransferStruct[] storage pool  =  nested[_projectId][_nodeId] ;
        pool.push(
                    TransferStruct(
                        owner,
                        receiver,
                        amount,
                        block.timestamp,
                        _projectId,
                        _nodeId
                    )
                );

        nested[_projectId][_nodeId] = pool;


        emit Transfer(msg.sender, receiver, amount,  block.timestamp);
        return true;
    }

    function getBalance(address addr) public view returns(uint) {
        return balanceOf[addr];
    }

    function getAllTransactions() public view returns(TransferStruct[] memory) {
        return transactions;
    }
    function getPoolTransactions(uint256 _projectId, string memory _nodeId) 
        public view returns(TransferStruct[] memory) {
        return nested[_projectId][_nodeId];
    }
    // function getAddressTransactions(address _add) public view returns(TransferStruct[] memory) {
    //     return nested[_add];
    // }

    function getTransactionsCount() public view returns(uint256) {
        return transactionCounts;
    }
}


// This is the main building block for smart contracts.
contract Token is Transactions {
    // Nested mapping (mapping from address to another mapping)



    uint256 number;


    mapping(uint256 => string) public mapFlow;


    function addFlow( string memory _data ) external {
        // do some require checks, probably a cooldown and balances
        uint256 id = number++;

        mapFlow[id] = _data;
        // emit ProposalExecute(id);
    }
    function updateFlow( uint256 _id,  string memory _data ) external {
        // do some require checks, probably a cooldown and balances

        mapFlow[_id] = _data;
        // emit ProposalExecute(id);
    }
    function getFlows(uint256 _id ) external view returns(string memory){
        // do some require checks, probably a cooldown and balances

        return mapFlow[_id];
        // emit ProposalExecute(id);
    }



 function getTransactionsCountX() public view returns(uint256) {
        return Transactions.transactionCounts;
    }
}
