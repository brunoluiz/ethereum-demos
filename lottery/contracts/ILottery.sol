// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILottery {
  function fulfillDraw(uint256 _lID, uint256 _value) external;
}
