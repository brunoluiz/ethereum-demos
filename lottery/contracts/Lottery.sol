// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./IRandomGeneratorVRF.sol";

contract Lottery is Ownable {
  mapping(uint256 => Lotto) public lotteries;
  uint256 public lottoCount;
  IRandomGeneratorVRF private randomGenerator;

  enum Status {
    Open,
    Closed,
    Drawn,
    Completed
  }

  struct Lotto {
    Status status;
    address[] tickets;
    uint256 id;
    uint256 winnerTicket;
    uint256 ticketValue;
    uint256 ticketCount;
    uint256 funds;
  }

  event LotteryCreated(uint256 id, uint256 ticketValue);
  event LotteryClosed(uint256 lotteryId);
  event LotteryDrawn(uint256 lotteryId, uint256 winnerTicketId);
  event LotteryTransferred(uint256 lotteryId, address winner);
  event TicketAcquired(uint256 lotteryId, uint256 id, address owner);

  modifier onlyStatus(uint256 lottoId, Status status) {
    require(
      lotteries[lottoId].status == status,
      "lottery status do not permit this operation"
    );
    _;
  }

  modifier onlyRandomGeneratorVRF() {
    require(
      msg.sender == address(randomGenerator),
      "call is not from the registered generator"
    );
    _;
  }

  constructor(IRandomGeneratorVRF _randomGenerator) {
    randomGenerator = _randomGenerator;
  }

  function buy(uint256 lottoId)
    external
    payable
    onlyStatus(lottoId, Status.Open)
  {
    require(
      msg.value >= lotteries[lottoId].ticketValue,
      "check required ticket value"
    );
    Lotto storage l = lotteries[lottoId];
    l.funds += msg.value;

    uint256 id = l.ticketCount;
    l.tickets.push(msg.sender);
    l.ticketCount++;
    emit TicketAcquired(lottoId, id, msg.sender);
  }

  function draw(uint256 lottoId)
    external onlyOwner
    onlyStatus(lottoId, Status.Open)
  {
    lotteries[lottoId].status = Status.Closed;
    randomGenerator.draw(lottoId);

    emit LotteryClosed(lottoId);
  }

  function fulfillDraw(uint256 lottoId, uint256 value)
    external
    onlyRandomGeneratorVRF()
    onlyStatus(lottoId, Status.Closed)
  {
    Lotto storage l = lotteries[lottoId];
    l.status = Status.Drawn;
    l.winnerTicket = value % l.ticketCount;

    emit LotteryDrawn(lottoId, value);
  }

  function transfer(uint256 lottoId)
    external
    onlyOwner
    onlyStatus(lottoId, Status.Drawn)
  {
    Lotto storage l = lotteries[lottoId];
    l.status = Status.Completed;

    address winner = l.tickets[l.winnerTicket];
    payable(winner).transfer(l.funds);
    l.funds = 0;

    emit LotteryTransferred(lottoId, winner);
  }

  function setTicketValue(uint256 lottoId, uint256 _value) external onlyOwner {
    lotteries[lottoId].ticketValue = _value;
  }

  function setRandomGenerator(IRandomGeneratorVRF _randomGenerator) external onlyOwner {
    randomGenerator = _randomGenerator;
  }

  function createLottery(uint256 _ticketValue) external onlyOwner {
    uint256 id = lottoCount;
    Lotto memory l;
    l.id = id;
    l.status = Status.Open;
    l.ticketValue = _ticketValue;
    lotteries[id] = l;

    lottoCount++;
    emit LotteryCreated(id, _ticketValue);
  }
}
