 // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract LotterySmartContract{
    address public owner;
    address payable[] public players;
    address payable public winner;
    uint public balances;
    uint public round;
    uint public numberOfPlayers;
    AggregatorV3Interface internal priceFeed;
    uint public amount;  //minimum of $500

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    bool public started = false;
    mapping (uint => address) public WinnersOfEachRounds;
    mapping (uint => uint) public participantsInEachRounds;

    constructor(){
        amount =500 *(10**18);
        owner =msg.sender;
        round = 1;
         priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }
    function getPriceInEth() public view returns (uint) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
       uint newPrice = uint (price) *10**10;
       uint ethAmount  = (amount*10**18)/newPrice;
        return ethAmount;
    }

    function startLottery() public onlyOwner{
        started = true;
    }
    function register() public payable {
        require(msg.value == amount, "required amount not met");
        require(started == true, "sorry, you can't play at the moment");
        balances += address(this).balance;
        players.push(payable(msg.sender));
        numberOfPlayers =players.length;
    }

    function random() internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function selectWinner() public onlyOwner {
        uint index = random()% players.length;
        winner =players[index];
        started == false;
    }

    function creditWinner() public payable onlyOwner{
        winner.transfer(address(this).balance);
        balances = 0;
        WinnersOfEachRounds[round] = winner;
        participantsInEachRounds[round] = numberOfPlayers;
        players = new address payable[](0);
        numberOfPlayers =players.length;
        round++;
        winner;
    }
}