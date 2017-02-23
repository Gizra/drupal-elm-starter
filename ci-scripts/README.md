# CI

## Test CI execution on local
1. `cd <repository_root>`
2. `docker build -t server -f ci-scripts/docker_files/Dockerfile .`
3. `docker run -it -p 8080:80 -e BUILD_CLIENT=1 server` or other `docker run -it -p 8080:80 -e BUILD_WEBDRIVERIO=1 server`
