// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract LotterySmartContract is VRFConsumerBaseV2{
    
    address public owner;
    address payable[] public players;
    address payable public winner;
    uint public balances;
    uint public round;
    uint public numberOfPlayers;
    uint public amount;  //minimum of $100

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier state() {
        require(started == true, "sorry, you can't play at the moment");
        _;
    }
    bool public started = false;
    mapping (uint => address) public WinnersOfEachRounds;
    mapping (uint => uint) public participantsInEachRounds;
     VRFCoordinatorV2Interface COORDINATOR;


  uint64 s_subscriptionId;
  address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
  bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
  uint32 callbackGasLimit = 100000;
  uint16 requestConfirmations = 3;
  uint32 numWords =  2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;

    constructor() VRFConsumerBaseV2(vrfCoordinator){
        amount =100 *(10**18);
        owner =msg.sender;
         s_subscriptionId = 5114;
        round = 1;
          COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
          s_subscriptionId = 5114;
    }
    function getPriceInEth() public state{
        AggregatorV3Interface  priceFeed  = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
       uint newPrice = uint (price) *10**10;
       uint ethAmount  = (amount*10**18)/newPrice;
        amount = ethAmount;
    }

    function startLottery() public onlyOwner{
        require(started  == false, "lottery is already in progress");
        started = true;
    }
    function register() public payable state {
        require(msg.value == amount, "required amount not met");
        balances += address(this).balance;
        players.push(payable(msg.sender));
        numberOfPlayers =players.length;
    }
        function requestRandomWords() external onlyOwner state{
            // Will revert if subscription is not set and funded.
            s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
            );
            started = false;
        }
        
        function fulfillRandomWords(
            uint256, /* requestId */
            uint256[] memory randomWords
        ) internal override {
            s_randomWords = randomWords;
        }

    function selectWinner(uint value) public onlyOwner {
        uint index =  s_randomWords[value]% players.length;
        winner =players[index];
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
