// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ILottery.sol";

contract MockRandomGeneratorVRF {
  address requester;
  uint256 lotteryId;

  function draw(uint256 _lottoId) external {
    requester = msg.sender;
    lotteryId = _lottoId;
    fulfillRandomness(bytes32("1"), 1);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal {
    ILottery(requester).fulfillDraw(lotteryId, randomness);
  }
}
