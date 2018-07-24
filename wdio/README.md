## Requirements

 - npm 2.x or newer
 - Google Chrome stable channel
 
## Execute WebdriverIO tests

1. `npm install`
1. `cp wdio.local.conf.js.example wdio.local.conf.js` and set your local configurations.
1. Execute tests with `./node_modules/.bin/wdio wdio.local.conf.js` (or just `npm test` from this directory).

Beware that you do not need to (should not) execute a standalone Selenium Server alongside WDIO to run the tests.
