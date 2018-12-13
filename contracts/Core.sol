pragma solidity ^0.4.23;

import "./Player.sol";

contract Core is Player {

  uint256 constant public SIZE = 500;
  uint256 constant public PRICE = 10 trx;

  uint256[SIZE][SIZE] public artists_;
  uint256[SIZE][SIZE] public prices_;
  uint8[SIZE][SIZE] public colors_;

  function getPixel (uint16 _row, uint16 _column) 
    public
    view
    returns (uint256, address, uint256, uint8) 
  {
    uint256 _pID = artists_[_row][_column];

    return
    (
      _pID,
      pID_addr_[_pID],
      _getNewPriceHelper(_row, _column),
      colors_[_row][_column]
    );
  }

  function getColorsByRow (uint16 _row) 
    public
    view
    returns (uint8[SIZE], uint8[SIZE], uint8[SIZE], uint8[SIZE]) 
  {
    return 
    (
      colors_[_row],
      colors_[_row.add(1)],
      colors_[_row.add(2)],
      colors_[_row.add(3)]
    );
  }

  function getPrices (uint16[] _rows, uint16[] _columns) 
    public
    view
    returns (uint256[], uint256)
  {
    uint256[] memory _prices = new uint256[](_rows.length);
    uint256 _totalPrice;

    for (uint16 i = 0; i < _rows.length; i++) {
      uint256 _price = _getNewPriceHelper(_rows[i], _columns[i]);

      _prices[i] = _price;
      _totalPrice = _totalPrice.add(_price);
    }

    return
    (
      _prices,
      _totalPrice
    );
  }

  function buyPixels (uint16[] _rows, uint16[] _columns, uint8[] _colors, uint256 _inviterPID) 
    isActivated
    public
    payable
  {
    _determinePID();

    address _sender = msg.sender;
    uint256 _in = msg.value;
    uint256 _pID = addr_pID_[_sender];

    _determineInviter(_pID, _inviterPID);

    uint256 _leftToCheck = _in;
    uint256 _leftToDistribute = _in;

    for (uint16 i = 0; i < _rows.length; i++) {
      (_leftToCheck, _leftToDistribute) = _buyPixel(_rows[i], _columns[i], _colors[i], _pID, _leftToCheck, _leftToDistribute);
    }

    if (_leftToDistribute > 0) {
      uint256 _inviteRewards = _in.mul(5).div(1000);
      _distributeInviteRewards(pID_inviterPID_[_pID], _inviteRewards);
      _leftToDistribute = _leftToDistribute.sub(_inviteRewards);

      if (_leftToDistribute > 0) {
        uint256 _profits = _leftToDistribute.mul(60).div(100);
        _distributeProfits(_profits);
        pID_payouts_[_pID] = pID_payouts_[_pID].add(profitsPerShare_.mul(_in));

        _distributeToOthers(_leftToDistribute.sub(_profits));
      }
    }

    totalIn_ = totalIn_.add(_in);
    pID_totalIn_[_pID] = pID_totalIn_[_pID].add(_in);

    if (tradingPixelsCount_ >= 10000 && withdrawActivated_ == false) {
      withdrawActivated_ = true;
    }

    emit Events.onBuyPixels
    (
      addr_pID_[_sender],
      _sender,
      _rows.length
    );
  }

  function _buyPixel (uint16 _row, uint16 _column, uint8 _color, uint256 _newArtistPID, uint256 _leftToCheck, uint256 _leftToDistribute)
    internal
    returns (uint256, uint256)
  {
    uint256 _newPrice = _getNewPriceHelper(_row, _column);
    require (_leftToCheck >= _newPrice);    

    uint256 _oldArtistPID = artists_[_row][_column];

    if (_oldArtistPID > 0) {
      uint256 _pot = prices_[_row][_column].mul(120).div(100);
      _distributePot(_oldArtistPID, _pot);

      _leftToDistribute = _leftToDistribute.sub(_pot);
    }

    artists_[_row][_column] = _newArtistPID;
    prices_[_row][_column] = _newPrice;
    colors_[_row][_column] = _color;

    tradingPixelsCount_ = tradingPixelsCount_.add(1);
    if (tradingPixelsCount_ % 1000 == 0) {
      luckyPlayers_.push(_newArtistPID);
    }

    return
    (
      _leftToCheck.sub(_newPrice),
      _leftToDistribute
    );
  }

  function _getNewPriceHelper (uint16 _row, uint16 _column) 
    internal
    view 
    returns (uint256) 
  {
    uint256 _price = prices_[_row][_column];
    return _price == 0 ? PRICE : _price.mul(130).div(100);
  }

}