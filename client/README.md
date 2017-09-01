## Prerequisites

Make sure the following are installed:

* NodeJs (and npm)
* Elm (e.g. `npm install -g elm@~0.18.0`)
* Compass (for SASS) (`gem update --system && gem install compass`)
* Elm Format (`npm install -g elm-format@0.6.1-alpha`), not strictly required for the development, but the standard must be followed, as Travis checks that. Therefore it's highly suggested to run Elm Format upon save at your IDE (https://github.com/avh4/elm-format#editor-integration).

## Installation

* `npm install`
* `elm-package install -y`
* `cp src/elm/LocalConfig.Example.elm src/elm/LocalConfig.elm`

You may need to update `src/elm/LocalConfig.elm` if your local URLs are different from the default setting.

## Usage

1. Serve locally, and watch file changes: `gulp`
1. Prepare file for publishing (e.g. minify, and rev file names): `gulp publish`
1. Deploy to GitHub's pages (`gh-pages` branch of your repository): `gulp deploy`

## Linting
Travis does linting on the source code, you can find below the details and how to trigger the same check locally.

## Elm

### Setup
`npm install -g elm-format@0.6.1-alpha`

### Execution
For a specific source file, you may execute:
`elm-format --validate src/Example/View.elm`

## SCSS

### Setup

To check the stylesheets, locally, you can initialize the checks:
`bash ../ci-scripts/install_scss.sh`

### Execution
`bash ../ci-scripts/test_scss.sh`

It will include all the SASS files from the client and the server part too.

## Unit Tests

In order to view the tests on the browser Start elm reactor (elm-reactor) and navigate to http://0.0.0.0:8000/src/elm/TestRunner.elm

## WebdriverIO tests

1. Run `gulp`
1. Follow [steps 2-4](http://webdriver.io/guide.html)
1. Execute tests with `./node_modules/.bin/wdio wdio.conf.js`

Note: You will have 3 terminal tabs open: One with `gulp`, the other with the selenium standalone server and the third with the executed tests.
