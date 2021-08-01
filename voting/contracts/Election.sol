//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Election is Ownable {
  Candidate[] public candidates;
  uint public candidatesTotal;
  mapping (address => Vote) voteByVoter;

  struct Candidate {
    string name;
    uint votes;
  }

  struct Vote {
    uint candidateId;
    bool voted;
  }

  event CandidateAdded (
    uint id
  );

  event VoteAdded (
    uint candidateId
  );

  function addCandidate(string memory name) public onlyOwner {
    uint id = candidatesTotal;
    candidates.push(Candidate(name, 0));
    candidatesTotal++;
    emit CandidateAdded(id);
  }

  function vote(uint _candidate) public {
    require(!voteByVoter[msg.sender].voted, 'already voted');

    // Will throw and revert if out-of-range
    candidates[_candidate].votes++;
    voteByVoter[msg.sender] = Vote(_candidate, true);

    emit VoteAdded(_candidate);
  }

  function winner() public view returns (uint) {
    uint max = 0;
    uint winnerId = 0;
    bool tie = true;

    for (uint i = 0; i < candidatesTotal; i++) {
      if (candidates[i].votes > max) {
        max = candidates[i].votes;
        winnerId = i;
        tie = false;
      } else if (candidates[i].votes == max) {
        tie = true;
      }
    }

    require(!tie, 'tie');
    return winnerId;
  }
}
