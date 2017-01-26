## Installation

Make sure the following are installed:

* NodeJs (and npm)
* Elm (e.g. `npm install -g elm@~0.18.0`)
* Compass (for SASS) (`gem update --system && gem install compass`)

## Usage

1. Serve locally, and watch file changes: `gulp`
1. Prepare file for publishing (e.g. minify, and rev file names): `gulp publish`
1. Deploy to GitHub's pages (`gh-pages` branch of your repository): `gulp deploy`

## Unit Tests

In order to view the tests on the browser Start elm reactor (elm-reactor) and navigate to http://0.0.0.0:8000/src/elm/TestRunner.elm

## WebdriverIO tests

1. Run `gulp`
1. Follow [steps 2-4](http://webdriver.io/guide.html)
1. Execute tests with `./node_modules/.bin/wdio wdio.conf.js`

Note: You will have 3 terminal tabs open: One with `gulp`, the other with the selenium standalone server and the third with the executed tests.

## License

MIT
