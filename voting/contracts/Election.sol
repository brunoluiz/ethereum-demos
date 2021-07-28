//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Election is Ownable {
  struct Candidate {
    string name;
    uint votes;
  }

  struct Vote {
    uint candidateId;
    bool voted;
  }

  Candidate[] public candidates;
  uint public candidatesTotal;
  mapping (address => Vote) voteByVoter;

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
    require(!voteByVoter[msg.sender].voted, 'Already voted');

    // Will throw and revert if out-of-range
    candidates[_candidate].votes++;
    voteByVoter[msg.sender] = Vote(_candidate, true);

    emit VoteAdded(_candidate);
  }
}
