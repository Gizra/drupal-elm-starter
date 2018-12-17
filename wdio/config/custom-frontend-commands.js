'use strict';

const assert = require('assert');
const mainCustomCommands = require('./custom-commands.js');

module.exports = function (browser, capabilities, specs) {
  // Add commands to WebdriverIO.
  Object.keys(mainCustomCommands).forEach(key => {
    browser.addCommand(key, mainCustomCommands[key]);
  });

  browser.addCommand('login', (user, password) => {
    password = typeof password !== 'undefined' ? password : user;
    assert(user, "login command must be passed a username");
    browser.url('/#login');
    browser.waitForVisible('.login-form');
    browser.setValueSafe('input[name="username"]', user);
    browser.setValueSafe('input[name="password"]', password);
    browser.submitForm('.login-form');
    browser.waitForVisible('.menu h4');
  });

  browser.addCommand('logout', () => {
      browser.click('.left.menu > a:nth-child(4)');
      browser.waitForVisible('.login-form');
  });
};
