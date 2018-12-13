pragma solidity ^0.4.23;

import "./SafeMath.sol";

contract Admin {
  
  using SafeMath for *;
  
  bool public activated_ = true;

  address public owner_;
  mapping (address => bool) public administrators_;

  uint256 internal _teamPot;
  uint256 internal _othersPot;

  uint256 public log_pot_profits_;
  uint256 public log_pot_others_;

  modifier isActivated () {
    require (activated_ == true); 
    _;
  }
    
  modifier onlyOwner ()
  {
    require (msg.sender == owner_);
    _;
  }
  
  modifier onlyAdministrator ()
  {
    require (administrators_[msg.sender]);
    _;
  }
  
  constructor ()
    public
  {    
    owner_ = msg.sender;
    administrators_[owner_] = true;
  }

  function activate ()
    onlyAdministrator
    public
  {
    activated_ = true;
  }

  function pause ()
    onlyAdministrator
    public
  {
    activated_ = false;
  }
  
  function setAdministrator (address _address, bool _state)
    onlyOwner
    public
  {
    administrators_[_address] = _state;
  }
  
  function withdrawTeamPot (uint256 _value)
    onlyAdministrator
    public
  {
    _teamPot = _teamPot.sub(_value);
    msg.sender.transfer(_value);
  }

  function getTeamPot ()
    onlyAdministrator
    public
    view
    returns (uint256)
  {
    return _teamPot;
  }
  
  function withdrawOthersPot (uint256 _value)
    onlyAdministrator
    public
  {
    _othersPot = _othersPot.sub(_value);
    msg.sender.transfer(_value);
  }

  function getOthersPot ()
    onlyAdministrator
    public
    view
    returns (uint256)
  {
    return _othersPot;
  }
  
  function _distributeToTeam (uint256 _value)
    internal
  {
    _teamPot = _teamPot.add(_value);
  }

  function _distributeToOthers (uint256 _value)
    internal
  {
    _othersPot = _othersPot.add(_value);
    log_pot_others_ = log_pot_others_.add(_value);
  }
  
}