'use strict';

const Controller = require('egg').Controller;
const fs = require('fs');
const path = require('path');


class HomeController extends Controller {
  async index() {
    await this.ctx.render('index.nj');
  }

  async fetchAllColors() {
    let totalIn = 0;
    try {
      totalIn = fs.readFileSync(path.join(__dirname, './totalIn.txt'), 'utf-8');
    } catch(e) {}
    try {
      const data = fs.readFileSync(path.join(__dirname, './../../tronserver/pixel.txt'), 'utf-8');
      const pixels = JSON.parse(data);

      this.ctx.body = {
        error: 0,
        totalIn,
        data: ''
      }
    } catch (e) {
      this.ctx.body = {
        error: 1,
        totalIn: 0,
        data: []
      }
    }

    const pixelService = this.ctx.service.pixel;
  }

  async fetchAllUsers() {
    try {
      const data = fs.readFileSync(path.join(__dirname, './../../tronserver/users.txt'), 'utf-8');

      this.ctx.body = {
        error: 0,
        data: ''
      }
    } catch (e) {
      this.ctx.body = {
        error: 1,
        data: []
      }
    }

    const pixelService = this.ctx.service.pixel;
  }
}

module.exports = HomeController;
