//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Lottery is Ownable {
  uint public ticketValue;
  Ticket[] public tickets;
  uint public ticketsTotal;
  mapping (address => uint[]) public ticketByWallet;
  mapping (address => uint) public ticketByWalletTotal;
  uint public funds;
  Info public info;

  enum Status {
    NotStarted,
    Open,
    Closed,
    Completed
  }

  struct Ticket {
    address owner;
  }

  struct Info {
    uint winnerTicket;
    bool finished;
  }

  event TicketAcquired (
    uint id,
    address owner
  );

  constructor() {
    info = Info(0, false);
  }

  function buy() public payable {
    require(msg.value >= ticketValue, 'check required ticket value');
    funds += msg.value;

    uint id = ticketsTotal;
    tickets.push(Ticket(msg.sender));

    ticketByWallet[msg.sender].push(id);
    ticketByWalletTotal[msg.sender]++;

    ticketsTotal++;
    emit TicketAcquired(id, msg.sender);
  }

  function draw() public onlyOwner {
    require(!info.finished, 'lottery already finished');
    info.winnerTicket = 1;
    info.finished = true;
  }

  function transfer() public onlyOwner {
    require(info.finished, 'lottery has not finished');
    payable(tickets[info.winnerTicket].owner).transfer(funds);
    funds = 0;
  }

  function setTicketValue(uint _value) public onlyOwner {
    ticketValue = _value;
  }
}
