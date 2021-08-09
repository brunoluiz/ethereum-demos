// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRandomGeneratorVRF {
  function draw(uint256 lID) external;
}
