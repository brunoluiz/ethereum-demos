// //SPDX-License-Identifier: Unlicense
// pragma solidity ^0.8.0;
//
// import "./VoteStorage.sol";
// import "hardhat/console.sol";
//
// contract VoteController {
//   VoteStorage store;
//
//   constructor() {
//     store.setControllerAddress(this);
//   }
//
//   function vote(uint _candidate) public {
//     require(store.voteByHolder(msg.sender) == 0);
//     store.vote(_candidate);
//   }
//
//   function winner() public returns (uint) {
//     uint max = 0;
//     uint winnerId = 0;
//
//     for (uint i = 0; i < store.candidatesTotal(); i++) {
//       // FIXME: not dealing with tie
//       uint candidateId = store.candidates(i);
//
//       if (store.voteByCandidate(candidateId) > max) {
//         max = store.voteByCandidate(i);
//         winnerId = candidateId;
//       }
//     }
//
//     return winnerId;
//   }
// }
