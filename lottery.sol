//SPDX-License-Identifier : MIT

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
        require(msg.sender ==owner);
        _;
    }

    mapping (uint => address payable) public roundsToWinner;
    mapping (uint => uint) public roundsToNumber;

    constructor(){
        owner =msg.sender;
        round = 1;
         priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
    }
     function lotieryPrice() public {
        (,int price, , ,) = priceFeed.latestRoundData();
        uint newPrice = uint (price) *10**10;
        amount  = (50*10**8)/newPrice;
        
    }

    function register() public payable {
        require(msg.value > 0.005 ether);
        balances = address(this).balance;
        players.push(payable(msg.sender));
        numberOfPlayers =players.length;
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function selectWinner() public onlyOwner {
        uint index= random()% players.length;
        winner =players[index];
        

    }

    function creditWinner() public payable onlyOwner{
        winner.transfer(address(this).balance);
        balances = 0;
        roundsToWinner[round] = winner;
        roundsToNumber[round] = numberOfPlayers;
        players = new address payable[](0);
        numberOfPlayers =players.length;
        round++;
        winner;
    }
}