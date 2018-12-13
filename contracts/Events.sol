pragma solidity ^0.4.23;

contract Events {

  event onBuyPixels
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 pixelsCount
  );
  
}