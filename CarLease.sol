// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

 contract CarLease{
     struct Car{
         bytes brand;
         bytes plateNumber;
         bytes model;
         uint numberOfYears;
     }

     Car public car;

     mapping(address => Car) public carleaser;
     address payable public owner;
     address public leaser;
     bool public available;
     string public feedback;

     modifier onlyOwner(){
         require (msg.sender == owner, "you are not the owner");
         _;
     }

      modifier onlyLeaser(){
         require (msg.sender == leaser, "you are not the leaser");
         _;
     }

     uint public amount;
     event carRequest(address demand, Car car);

     constructor(address payable own, address _leaser){
         owner = own;
         leaser = _leaser;
     }

     function demandCar(bytes memory _brand, bytes memory _plateNumber, bytes memory _model, uint _leaseDuration) public onlyLeaser{
         car = Car(_brand, _plateNumber, _model, _leaseDuration);
         carleaser [msg.sender] = car;
         emit carRequest(msg.sender, car);     
     }

     function setPrice(uint _amount, bool _available, string memory _feed) public onlyOwner returns(string memory){
         available = _available;
         if (available == true){
          amount = _amount;
          feedback = _feed;
         } else{
             amount = 0;
             feedback = _feed;
         }
         return feedback;
     }
     
     function payment() public payable onlyLeaser{
         require (msg.value == amount, "insufficient balance");
         owner.transfer(amount);
     }

 }