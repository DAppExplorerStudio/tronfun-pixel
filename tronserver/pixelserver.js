var fs = require('fs');
var path = require('path');
var Service = require('egg').Service;
var TronWeb = require('tronweb');
var _ = require('lodash');


var HttpProvider = TronWeb.providers.HttpProvider;
var fullNode = new HttpProvider('https://api.trongrid.io');
var solidityNode = new HttpProvider('https://api.trongrid.io');
var eventServer = 'https://api.trongrid.io';

var privateKey = '';
var artifacts = ''; // import your contract json file

var tronWeb = new TronWeb(
  fullNode,
  solidityNode,
  eventServer,
  privateKey
);

var pixelContract = tronWeb.contract(artifacts.abi, artifacts['networks']['*'].address);
var SIZE = 500;

var pixels = [];

function initPixelArr() {
  for (let i = 0; i < SIZE; i++) {
    pixels[i] = [];
    for (let j = 0; j < SIZE; j++) {
      pixels[i][j] = 0;
    }
  }
}

function fillPixel(row, column, color) {
  pixels[row][column] = color;
}

var sleep = delay => {
  return new Promise(resolve => {
    setTimeout(resolve, delay)
  })
}


var pixelFileData = fs.readFileSync(path.join(__dirname, 'pixel.txt'));
try {
  var pixelData = JSON.parse(pixelFileData);
  if (pixelData && pixelData.length === SIZE && pixelData[0].length === SIZE) {
    pixels = pixelData;
  } else {
    initPixelArr()
  }
} catch (e) {
  initPixelArr()
}


async function fetchAllColors() {
  while(true) {
    for (var i = 0; i < SIZE; i = i + 4) {
      try {
        var colors = await pixelContract.getColorsByRow(i).call();
        for (var j = 0; j < 4; j++) {
          for (var k = 0; k < colors[j].length; k++) {
            fillPixel(i + j, k, colors[j][k]);
          }
        }
        fs.writeFileSync(path.join(__dirname, 'pixel.txt'), JSON.stringify(pixels))
      } catch (e) {
      }
    }
    await sleep(1000)
  }
}

async function fetchAllPids() {
  while(true) {
    const users = [];
    try {
      const idIndex = await pixelContract.pIDIndex_().call();
      for (let i = 1; i <= idIndex; i++) {
        const u = {};
        let trx = await pixelContract.totalInOf(i).call();
        trx = parseFloat(pixelContract.tronWeb.fromSun(trx.toNumber()));
        const addr = await pixelContract.getAddressByPID(i).call();
        u.t = trx;
        u.a = pixelContract.tronWeb.address.fromHex(addr);
        users.push(u)
      }
      const sortUsers = _.reverse(_.sortBy(users, ['t']));
      fs.writeFileSync(path.join(__dirname, 'users.txt'), JSON.stringify(sortUsers.splice(0, 20)))
      await sleep(1000)
    } catch (e) {
    }
  }
}

console.log('TronWeb Pixel Sever Started ...')

fetchAllColors()
fetchAllPids()





