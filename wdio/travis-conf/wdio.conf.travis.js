// wdio.local.config.js
const merge = require('deepmerge');
const wdioConf = require('../wdio.conf.js');

/**
 * Have a main config file as default but overwrite environment specific
 * information.
 */
exports.config = merge(wdioConf.config, {
  // If you have trouble getting all important capabilities together, check out the
  // Sauce Labs platform configurator - a great tool to configure your capabilities:
  // https://docs.saucelabs.com/reference/platforms-configurator
  capabilities: [{
    // maxInstances can get overwritten per capability. So if you have an in-house Selenium
    // grid with only 5 firefox instances available you can make sure that not more than
    // 5 instances get started at a time.
    maxInstances: 1,
    browserName: 'chrome',
    chromeOptions: {
      binary: '/usr/bin/google-chrome-stable',
      args: [
        'headless',
        // Use --disable-gpu to avoid an error from a missing Mesa
        // library, as per
        // https://chromium.googlesource.com/chromium/src/+/lkgr/headless/README.md
        'disable-gpu'
      ],
    },
    name: '<<SPECNAME>>'
  }],
});
