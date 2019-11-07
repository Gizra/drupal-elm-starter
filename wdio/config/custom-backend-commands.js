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
    browser.url('/user/login');
    browser.waitForVisible('#user-login');
    browser.setValueSafe('input[name="name"]', user);
    browser.setValueSafe('input[name="pass"]', password);
    browser.submitForm('#user-login');
    browser.waitForVisible('#page-title');
  });

  browser.addCommand('logout', () => {
    browser.url('/user/logout');
    browser.waitForVisible('#site-name');
  });

};
