pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

// Assumption: each finished product is fungible with other finished products. This makes it simpler to settle funds with producers.
contract SupplyChain{
    
    // define roles
    address public producer;
    address public manufacturer;
    address public distributor;
    address public retailer;

    // Constructor
    // manufacturer manages supply chain
    constructor(){
        manufacturer = msg.sender;
        producer = 0x0000000000000000000000000000000000000000;
        distributor = 0x0000000000000000000000000000000000000000;
        retailer = 0x0000000000000000000000000000000000000000;
    }

    // functions
    // manufacturer sets producer
    function setProducer(address _producer) public{
        require(msg.sender == manufacturer,"Only manufacturer can receive finished goods");
        producer = _producer;
    }

    // manufacturer authorizes distributor
    function setDistributor(address _distributor) public{
        require(msg.sender == manufacturer,"Only manufacturer can approve manufacturer");
        distributor = _distributor;
    }

    // distributor sets retailer
    function setRetailer(address _retailer) public{
        require(distributor != 0x0000000000000000000000000000000000000000,"Distributor not assgined");
        require(msg.sender == distributor,"Only distributor can authorize retailer");
        retailer = _retailer;
    }

    // send money to contract
    // function sendMoneyToContract(uint value) public payable{}

    // get balance of contract
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    // settle balances
    function releaseFunds() public{
        require(msg.sender == manufacturer,"Only manufacturer can release funds");
        uint balance = address(this).balance;
        require(balance > 0,"No funds inside contract");
        uint share = balance/4;
        // send funds to parties
        payable(producer).transfer(share);
        payable(manufacturer).transfer(share);
        payable(distributor).transfer(share);
        payable(retailer).transfer(share);
    }

    // fallback
    fallback() external payable {}
    receive() external payable {}
}