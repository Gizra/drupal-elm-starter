## Requirements

 - npm 5.x or newer
 - node 8.x
 - [Google Chrome](https://www.google.com/chrome/) stable channel
 - [Chromedriver](http://chromedriver.chromium.org/)
 
## Test environment

The tests are divided into two directories, `backend` & `frontend`, Travis runs on both directories in two separate 
commands in which each has a dedicated `conf.js` file pointing to the right `baseUrl` and directory under `specs`

## Execute WebdriverIO tests

1. `npm install`
1. Start Chromedriver in the background: `nohup ./chromedriver &` or in a separate tab: `./chromedriver`
1. Execute tests with `./node_modules/.bin/wdio wdio.conf.js`.

During the test exexution, both Chromedriver and WDIO processes must be up and running.

Or alternatively via the Travis scripts:
1. `export TRAVIS_BUILD_DIR=/home/user/gizra/unsdg`
1. `ci-scripts/install_webdriverio.sh`
1. `ci-scripts/test_webdriverio.sh`

These scripts work under localhost as well, as long as the `TRAVIS_BUILD_DIR` environment variable is set properly. 
