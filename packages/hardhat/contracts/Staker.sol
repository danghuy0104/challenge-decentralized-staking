// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    event Stake(address indexed sender, uint256 amount);

    uint256 public deadline;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);

        deadline = block.timestamp + 72 hours;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    function stake() public payable
    {
        balances[msg.sender] += msg.value;

        console.log(balances[msg.sender]);

        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    bool public openForWithdraw;

    bool public hasExecuted;
    
    function execute() public
    {
        require(!hasExecuted, "already done");
        hasExecuted = true;

        if(block.timestamp > deadline && address(this).balance >= threshold)
        {
            exampleExternalContract.complete{value : address(this).balance}();
        }
        else
        {
            openForWithdraw = true;
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public
    {
        uint256 temp = balances[msg.sender];
        balances[msg.sender] = 0;

        if(temp > 0)
        {
            payable(msg.sender).transfer(temp);
        }
    }

    
    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256)
    {
        if(block.timestamp >= deadline)
        {
            return 0;
        }
        else
        {
            return deadline-block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable
    {
        stake();
    }
}