# Drupal Elm Starter - Server project

## Requirements

## Drupal Site installation (DDEV)

 * Preferred, supported.

```bash
./install
```

## Alternative install path (non-DDEV)

The project has an alternative way to install the project, using the native OS. This is preferred if Docker has poor
performance (OSX - virtual machine issues). Also it can be used if the performance is really critical for a certain
task, to avoid the overhead of the containerization.

 * Copy `default.config.sh` to `config.sh`
 * Review the content of `config.sh`
 * Execute:
   ```bash
    ./native-install
   ```

Known issues / cons compared to DDEV:
 - Drush version needs to be at least version 9, no check is made for that.
 - The hostname must be configured properly manually to resolve to 127.0.0.1 .
 - The webserver must be configured properly manually to serve the `web/` directory.
 - You must re-configure WDIO in order to be able to reach your local site, out of the box it tries to connect to DDEV.
   See `/wdio/wdio.local.example.conf.js` for help.

## Configuration management

Import configuration from code:
```
ddev exec drush cim
```

Export active configuration into code:
```
ddev exec drush cex
```

## Theme development

On the host machine, execute:
```
vendor/consolidation/robo/robo watch:theme-debug
```

Then the modifications of the theme will be on-the-fly compiled. The `-debug` suffix ensures that the CSS code remains human-readable.

The directory structure:
 - `assets/` - put everything there that's not stylesheet and needs postprocessing (images, fonts, etc)
 - `dist/` - `.gitignore`-ed path where the compiled / optimized files live, the theme should refer the assets from that directory.

Generally for theme development, it's advisable to entirely turn off caching:
https://www.drupal.org/node/2598914

## Add new modules

With `composer require ...` you can download new dependencies to your 
installation.

```
composer require drupal/devel:~1.0
```

## How can I apply patches to downloaded modules?

If you need to apply patches (depending on the project being modified, a pull 
request is often a better solution), you can do so with the 
[composer-patches](https://github.com/cweagans/composer-patches) plugin.

To add a patch to drupal module foobar insert the patches section in the extra 
section of composer.json:
```json
"extra": {
    "patches": {
        "drupal/foobar": {
            "Patch description": "URL or local path to patch"
        }
    }
}
```
