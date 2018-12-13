pragma solidity ^0.4.23;

import "./Admin.sol";
import "./Events.sol";

contract Player is Admin, Events {

  uint256 constant internal MAGNITUDE = 2**64;

  uint256 public pIDIndex_;
  mapping (address => uint256) public addr_pID_;
  mapping (uint256 => address) public pID_addr_;

  mapping (uint256 => uint256) public pID_pot_;

  mapping (uint256 => uint256) public pID_inviterPID_;
  mapping (uint256 => uint256) public pID_inviteRewards_;

  uint256 public profitsPerShare_;
  mapping (uint256 => uint256) internal pID_payouts_;


  uint256 public totalIn_;
  mapping (uint256 => uint256) public pID_totalIn_;

  uint256 public tradingPixelsCount_;
  uint256[] public luckyPlayers_;

  bool public withdrawActivated_ = false;

  modifier withdrawActivated () {
    require (withdrawActivated_ == true); 
    _;
  }

  function getPIDByAddress(address _address)
    view
    public
    returns (uint256)
  {
    return addr_pID_[_address];
  }

  function getAddressByPID(uint256 _pID)
    view
    public
    returns (address)
  {
    return pID_addr_[_pID];
  }

  function potOf(uint256 _pID)
    view
    public
    returns (uint256)
  {
    return pID_pot_[_pID];
  }

  function potOfByCurrentUser()
    view
    public
    returns (uint256)
  {
    return potOf(addr_pID_[msg.sender]);
  }

  function inviteRewardsOf(uint256 _pID)
    view
    public
    returns (uint256)
  {
    return pID_inviteRewards_[_pID];
  }

  function inviteRewardsOfByCurrentUser()
    view
    public
    returns (uint256)
  {
    return inviteRewardsOf(addr_pID_[msg.sender]);
  }

  function profitsOf(uint256 _pID)
    view
    public
    returns (uint256)
  {
    return profitsPerShare_.mul(pID_totalIn_[_pID])
            .sub(pID_payouts_[_pID])
            .div(MAGNITUDE);
  }

  function profitsOfByCurrentUser()
    view
    public
    returns (uint256)
  {
    return profitsOf(addr_pID_[msg.sender]);
  }

  function totalInOf(uint256 _pID)
    view
    public
    returns (uint256)
  {
    return pID_totalIn_[_pID];
  }

  function totalInOfByCurrentUser()
    view
    public
    returns (uint256)
  {
    return totalInOf(addr_pID_[msg.sender]);
  }

  function getLuckyPlayers()
    view
    public
    returns (uint256[])
  {
    return luckyPlayers_;
  }

  function withdrawPot ()
    isActivated 
    public 
  { 
    _determinePID();

    address _sender = msg.sender;
    uint256 _pID = addr_pID_[_sender];

    uint256 _allToWithdraw;

    if (pID_pot_[_pID] > 0) {
      _allToWithdraw = _allToWithdraw.add(pID_pot_[_pID]);

      pID_pot_[_pID] = 0;
    }

    require (_allToWithdraw > 0);
    _sender.transfer(_allToWithdraw);
  }

  function withdrawAll ()
    isActivated
    withdrawActivated
    public 
  {
    _determinePID();

    address _sender = msg.sender;
    uint256 _pID = addr_pID_[_sender];

    uint256 _allToWithdraw;

    if (pID_inviteRewards_[_pID] > 0) {
      _allToWithdraw = _allToWithdraw.add(pID_inviteRewards_[_pID]);

      pID_inviteRewards_[_pID] = 0;
    }

    uint256 _profits = profitsOf(_pID);
    if (_profits > 0) {
      _allToWithdraw = _allToWithdraw.add(_profits);

      pID_payouts_[_pID] = pID_payouts_[_pID].add(_profits.mul(MAGNITUDE));
    }

    require (_allToWithdraw > 0);
    _sender.transfer(_allToWithdraw);
  }

  function _determinePID ()
    internal
  {
    address _sender = msg.sender;

    if (addr_pID_[_sender] != 0) {
      return;
    }

    pIDIndex_ = pIDIndex_.add(1);
    
    pID_addr_[pIDIndex_] = _sender;
    addr_pID_[_sender] = pIDIndex_;
  }

  function _distributePot (uint256 _pID, uint256 _pot) 
    internal
  {
    pID_pot_[_pID] = pID_pot_[_pID].add(_pot);
  }

  function _determineInviter (uint256 _pID, uint256 _inviterPID) 
    internal
  {
    if (pID_totalIn_[_pID] > 0) {
      return;
    }

    pID_inviterPID_[_pID] = _inviterPID;
  }

  function _distributeInviteRewards (uint256 _pID, uint256 _inviteRewards) 
    internal
  {
    if (_pID == 0) {
      _pID = 1;
    }

    pID_inviteRewards_[_pID] = pID_inviteRewards_[_pID].add(_inviteRewards);
  }

  function _distributeProfits (uint256 _profits) 
    internal
  {
    if (totalIn_ > 0) {
      profitsPerShare_ = profitsPerShare_.add(_profits.mul(MAGNITUDE).div(totalIn_));
      log_pot_profits_ = log_pot_profits_.add(_profits);
    } else {
      _distributeToOthers(_profits);
    }
  }
  
}