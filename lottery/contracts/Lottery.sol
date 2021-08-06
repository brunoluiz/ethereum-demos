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
  LotteryStatus public status;

  struct Ticket {
    address owner;
  }

  struct LotteryStatus {
    uint winnerTicket;
    bool finished;
  }

  event TicketAcquired (
    uint id,
    address owner
  );

  constructor() {
    status = LotteryStatus(0, false);
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

  function roll() public onlyOwner {
    require(!status.finished, 'lottery already finished');
    status.winnerTicket = 1;
    status.finished = true;
  }

  function transfer() public onlyOwner {
    require(status.finished, 'lottery has not finished');
    payable(tickets[status.winnerTicket].owner).transfer(funds);
    funds = 0;
  }

  function setTicketValue(uint _value) public onlyOwner {
    ticketValue = _value;
  }
}
