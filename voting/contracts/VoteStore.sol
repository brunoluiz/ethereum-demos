//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract VoteStore is Ownable {
  // Candidates store
  uint[] public candidates;
  uint public candidatesTotal;

  // Votes store
  uint[] public votes;
  uint public votesTotal;

  // Indexes
  mapping (address => uint) public voteByVoter;
  mapping (uint => uint) public voteCountByCandidate;

  function vote(uint _candidate) public {
    votes.push(_candidate);
    uint voteId = votes.length - 1;
    voteByVoter[msg.sender] = voteId;
    votesTotal++;

    if (voteCountByCandidate[_candidate] == 0) {
      candidates.push(_candidate);
      candidatesTotal++;
    }
    voteCountByCandidate[_candidate]++;
  }

  function winner() public view returns (uint) {
    uint max = 0;
    uint winnerId = 0;

    for (uint i = 0; i < candidatesTotal; i++) {
      // FIXME: not dealing with tie
      uint candidateId = candidates[i];

      if (voteCountByCandidate[candidateId] > max) {
        max = voteCountByCandidate[i];
        winnerId = candidateId;
      }
    }

    return winnerId;
  }
}
