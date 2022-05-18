// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AggregatorV3Interface.sol";

contract FundMe {

    address public owner;
    
    address[] public funders;

    mapping(address => uint256) public fundedAmount;

    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUsd = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUsd, "Error: You need to spend at least $50");
        fundedAmount[msg.sender] = msg.value;
        funders.push(msg.sender);
    }

    function getAggregatorVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getEthPriceInWei() public view returns (uint256) { 
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer) * 10000000000;
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPriceInWei = getEthPriceInWei();
        uint256 ethAmountInUsd = (ethPriceInWei * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Error: You are not the owner of this contract");
        _;
    }

    function withdraw() payable public onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            fundedAmount[funder] = 0;
        }
        funders = new address[](0);
    }
}