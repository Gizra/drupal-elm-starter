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

## Unit Tests
The unit tests are written in Elm via [Elm Test](https://github.com/elm-community/elm-test) and it's invoked at the Travis builds.

### Local execution

```
npm test
```

## WebdriverIO tests

1. Run `gulp`
1. Follow [steps 2-4](http://webdriver.io/guide.html)
1. Execute tests with `./node_modules/.bin/wdio wdio.conf.js`

Note: You will have 3 terminal tabs open: One with `gulp`, the other with the selenium standalone server and the third with the executed tests.

## Galen tests

1. Run `gulp`
1. Copy `./test/galen/galen.config` to `./test/galen/galen.local.config`
1. Make sure your `$.webdriver.chrome.driver` path is correct (Line 32).
1. Run the Galen tests:

`npm run galen -- check ./test/galen/login.gspec --url http://localhost:3000 --size 640x480 --htmlreport ./test/galen/report --config ./test/galen/galen.local.config`

Note: You can see the galen reports by opening the following file in your browser:
`file:///{PATH_TO_PROJECT}/drupal-elm-starter/client/test/galen/report/report.html` 
