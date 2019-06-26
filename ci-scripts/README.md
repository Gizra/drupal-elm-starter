# CI

## Debug CI execution

https://docs.travis-ci.com/user/running-build-in-debug-mode/

Apart from this, the recommended way to debug a certain part, is to setup the environment variables and execute it natively at localhost.
Examples:

```
export BUILD_SERVER=1 && TRAVIS_BUILD_DIR=/path/to/repo && bash ci/test_server.sh
```
