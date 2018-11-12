// wdio.conf.travis.js
const merge = require('deepmerge');
const wdioConf = require('./wdio.conf.travis.js');

/**
 * Have a main config file as default but overwrite environment specific
 * information.
 */
exports.config = merge(wdioConf.config, {
  before: function(capabilities, specs) {
    require('./config/custom-frontend-commands')(browser, capabilities, specs)
  },
  baseUrl: 'http://localhost:3000',
  specs: [
    './specs/frontend/*.js'
  ]
});
