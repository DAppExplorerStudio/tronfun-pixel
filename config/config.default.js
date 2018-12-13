'use strict';

const path = require('path');
const fs = require('fs');

module.exports = appInfo => ({
  tokenRadio: 2000,
  tokenAddress: '',
  keys: 'keys',
  notfound: {
    pageUrl: '/index.html',
  },
  static: {
    maxAge: 31536000,
    gzip: true,
  },
  siteFile: {
    '/favicon.ico': fs.readFileSync(path.join(appInfo.baseDir, 'app/assets/favicon.ico')),
  },
  assets: {
    publicPath: '/dist/',
  },
  view: {
    defaultViewEngine: 'nunjucks',
    mapping: {
      '.nj': 'nunjucks',
    },
  },
  session: {
    key: 'key',
    maxAge: 2 * 3600 * 1000,
    httpOnly: true,
    encrypt: true,
  },

  security: {
    csrf: {
      queryName: '_',
      bodyName: '_',
    },
  },
});
