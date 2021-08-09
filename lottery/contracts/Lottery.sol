//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Lottery is Ownable {
  mapping (uint => Lotto) public lotteries;
  uint public lottoCount;

  enum Status {
    Open,
    Closed,
    Completed
  }

  struct Lotto {
    Status status;
    address[] tickets;
    uint id;
    uint winnerTicket;
    uint ticketValue;
    uint ticketCount;
    uint funds;
  }

  event LotteryCreated (
    uint id,
    uint ticketValue
  );

  event LotteryDrawn (
    uint lotteryId,
    uint winnerTicketId
  );

  event TicketAcquired (
    uint lotteryId,
    uint id,
    address owner
  );

  modifier onlyStatus(uint _lID, Status status) {
    require(lotteries[_lID].status == status, 'lottery status do not permit this operation');
    _;
  }

  constructor() {}

  function buy(uint _lID) public payable onlyStatus(_lID, Status.Open) {
    require(msg.value >= lotteries[_lID].ticketValue, 'check required ticket value');
    lotteries[_lID].funds += msg.value;

    uint id = lotteries[_lID].ticketCount;
    lotteries[_lID].tickets.push(msg.sender);
    lotteries[_lID].ticketCount++;

    emit TicketAcquired(_lID, id, msg.sender);
  }

  function draw(uint _lID) public onlyOwner onlyStatus(_lID, Status.Open) {
    uint randomNumber = 1; // TODO: call external contract
    lotteries[_lID].winnerTicket = randomNumber;
    lotteries[_lID].status = Status.Closed;

    emit LotteryDrawn(_lID, randomNumber);
  }

  function transfer(uint _lID) public onlyOwner onlyStatus(_lID, Status.Closed) {
    payable(lotteries[_lID].tickets[
      lotteries[_lID].winnerTicket
    ]).transfer(lotteries[_lID].funds);

    lotteries[_lID].funds = 0;
    lotteries[_lID].status = Status.Completed;
  }

  function setTicketValue(uint _lID, uint _value) public onlyOwner {
    lotteries[_lID].ticketValue = _value;
  }

  function createLottery(
    uint _ticketValue
  ) public onlyOwner {
    uint id = lottoCount;
    Lotto memory lotto;
    lotto.id = id;
    lotto.status = Status.Open;
    lotto.ticketValue = _ticketValue;

    lotteries[id] = lotto;

    lottoCount++;
    emit LotteryCreated(id, _ticketValue);
  }
}
