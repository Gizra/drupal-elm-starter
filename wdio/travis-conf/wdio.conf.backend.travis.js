// wdio.conf.travis.js
const merge = require('deepmerge');
const wdioConf = require('./wdio.conf.travis.js');

/**
 * Have a main config file as default but overwrite environment specific
 * information.
 */
exports.config = merge(wdioConf.config, {
  baseUrl: 'http://127.0.0.1:8080',
  specs: [
    '../specs/backend/*.js'
  ]
});
