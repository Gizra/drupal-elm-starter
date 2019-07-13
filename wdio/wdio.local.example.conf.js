// wdio.local.conf.js
// only for native installations
// for DDEV, simply use wdio.conf.js

var merge = require('deepmerge');
var wdioConf = require('./wdio.conf.js');

/**
 * Have a main config file as default but overwrite environment specific
 * information.
 */
exports.config = merge(wdioConf.config, {
  // Set a base URL in order to shorten url command calls.
  baseUrl: 'http://drupal-elm-starter.local',
});
