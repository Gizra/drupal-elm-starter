# Drupal Elm Starter - Server project

## Requirements

## Drupal Site installation

```bash
./install
```

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
