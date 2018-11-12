## Requirements

 - npm 2.x or newer
 - Google Chrome stable channel
 
## Test environment
The tests are divided into two directories, `backend` & `frontend`, Travis runs on both directories in two separate 
commands in which each has a dedicated `conf.js` file pointing to the right `baseUrl` and directory under `specs`

### Example of changing your local config to test the backend.
```javascript
exports.config = merge(wdioConf.config, {
  before: function(capabilities, specs) {
    require('./config/custom-backend-commands')(browser, capabilities, specs)
  },
  baseUrl: 'http://localhost/drupal-elm-starter/www',
  specs: [
    './specs/backend/*.js'
  ]
});
```
 
## Execute WebdriverIO tests

1. `npm install`
1. `cp wdio.local.conf.js.example wdio.local.conf.js` and set your local configurations.
1. Choose which tests to execute (backend or frontend) by changing the `baseUrl`, `specs` directory, and `custom-commands`. (Example above)
1. Execute tests with `./node_modules/.bin/wdio wdio.local.conf.js` (or just `npm test` from this directory).

Beware that you do not need to (should not) execute a standalone Selenium Server alongside WDIO to run the tests.
