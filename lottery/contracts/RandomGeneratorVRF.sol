// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./ILottery.sol";

contract RandomGeneratorVRF is VRFConsumerBase, Ownable {
  address controller;
  bytes32 private s_keyHash;
  uint256 private s_fee;
  mapping(bytes32 => Request) requests;
  mapping(uint256 => bool) drawn;

  struct Request {
    uint256 lotteryId;
    address requester;
  }

  modifier onlyController() {
    require(
      msg.sender == controller,
      "call is not from the registered controller"
    );
    _;
  }

  constructor(
    address _controller,
    address _vrfCoordinator,
    address _link,
    bytes32 _keyHash,
    uint256 _fee
  ) VRFConsumerBase(_vrfCoordinator, _link) {
    controller = _controller;
    s_keyHash = _keyHash;
    s_fee = _fee;
  }

  function draw(uint256 lottoId) external onlyController {
    require(
      LINK.balanceOf(address(this)) >= s_fee,
      "not enough LINK to pay fee"
    );
    require(drawn[lottoId] == false, "already drawn");
    bytes32 requestId = requestRandomness(s_keyHash, s_fee);

    requests[requestId] = Request({lotteryId: lottoId, requester: msg.sender});
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal
    override
  {
    drawn[requests[requestId].lotteryId] = true;

    ILottery(requests[requestId].requester).fulfillDraw(
      requests[requestId].lotteryId,
      randomness
    );
  }

  function setController(address _controller) external onlyOwner {
    controller = _controller;
  }
}
