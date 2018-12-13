pragma solidity ^0.4.23;

import "./Core.sol";

/// @title Contract of TronFun Pixel (https://tronfun.io/pixel)
/// @author DApp Explorer Studio (https://github.com/DAppExplorerStudio)
/// @dev See the TronFun Pixel documentation to understand everything
contract TronFunPixel is Core {

  constructor ()
    public 
  {
    _determinePID();
  }
  
}