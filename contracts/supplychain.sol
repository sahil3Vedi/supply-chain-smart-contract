pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

// Assumption: each finished product is fungible with other finished products. This makes it simpler to settle funds with producers.
contract SupplyChain{
    
    // state variables
    address[] public producers;
    mapping(address=>uint32) public raw_dispatches;
    address public manufacturer;
    address public distributor;
    mapping(address=>uint32) public finished_dispatches;
    address public retailer;
    mapping(address=>uint32) public open_orders;
    mapping(address=>uint32) public balances;

    // Constructor
    // manufacturer manages supply chain
    constructor(){
        manufacturer = msg.sender;
        distributor = 0x0000000000000000000000000000000000000000;
        retailer = 0x0000000000000000000000000000000000000000;
    }

    // functions

    // --- PRODUCERS ---
    // check if producer exists
    function checkProducer(address _producer) public view returns (bool) {
        for (uint i = 0; i < producers.length; i++) {
            if (producers[i] == _producer) {
                return true;
            }
        }
        return false;
    }

    // manufacturer adds producer
    function addProducer(address _producer) public{
        // check if _producer exists inside producers[]
        if (!checkProducer(_producer)){
            producers.push(_producer);
        }
    }

    // remove producer
    function removeProducer(address _producer) public{
        bool found = false;
        uint producers_length = producers.length;
        for (uint i = 0; i < producers_length; i++) {
            if (producers[i] == _producer) {
                found = true;
            }
            if (found){
                if (i==producers_length-1){
                    producers.pop();
                } else {
                    producers[i]=producers[i+1];
                }
            }
        }
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
        // payable(producer).transfer(share);
        payable(manufacturer).transfer(share);
        payable(distributor).transfer(share);
        payable(retailer).transfer(share);
    }

    // fallback & receive for tokens to accept funds
    fallback() external payable {}
    receive() external payable {}
}