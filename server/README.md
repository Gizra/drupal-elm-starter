# Drupal 7 - Install Profile Hedley

This is a starting base to create Drupal 7 websites using an install profile.


## Installation

**Warning:** you need to setup [Drush](https://github.com/drush-ops/drush)
first or the installation and update scripts will not work.

Clone the project from [GitHub](https://github.com/Gizra/drupal-elm-stater).


#### Create config file

Copy the example configuration file to config.sh:

	$ cp default.config.sh config.sh

Edit the configuration file, fill in the blanks.


#### Run the install script

Run the install script from within the root of the repository:

	$ ./install

You can login automatically when the installation is done. Add the -l argument
when you run the install script.

  $ ./install -l


#### Configure web server

Create a vhost for your webserver, point it to the `REPOSITORY/ROOT/www` folder.
(Restart/reload your webserver).

Add the local domain to your ```/etc/hosts``` file.

Open the URL in your favorite browser.



## Reinstall

You can Reinstall the platform any type by running the install script.

	$ ./install


#### The install script will perform following steps:

1. Delete the /www folder.
2. Recreate the /www folder.
3. Download and extract all contrib modules, themes & libraries to the proper
   subfolders of the profile.
4. Download and extract Drupal 7 core in the /www folder
5. Create an empty sites/default/files directory
6. Makes a symlink within the /www/profiles directory to the /hedley
   directory.
7. Run the Drupal installer (Drush) using the Hedley profile.

#### Warning!

* The install script will not preserve the data located in the
  sites/default/files directory.
* The install script will clear the database during the installation.

**You need to take backups before you run the install script!**



## Upgrade

It is also possible to upgrade Drupal core and contributed modules and themes
without destroying the data in tha database and the sites/default directory.

Run the upgrade script:

	$ ./upgrade

You can login automatically when the upgrade is finished. Add the -l argument
when you run the upgrade script.

  $ ./upgrade -l


#### The upgrade script will perform following steps:

1. Create a backup of the sites/default folder.
2. Delete the /www folder.
3. Recreate the /www folder.
4. Download and extract all contrib modules, themes & libraries to the proper
   subfolders of the profile.
5. Download and extract Drupal 7 core in the /www folder.
6. Makes a symlink within the /www/profiles directory to the
   /hedley 7. directory.
7. Restore the backup of the sites/default folder.

## Start a new project based on Drupal Elm Starter

### In a nutshell
 * Edit `server/travis.config.sh` and actualize `GH_REPO` variable based on
   the new URL
 * Actualize/re-encrypt Google Drive credentials in `gdrive-service-account.json.enc`
 * Actualize/re-ecrypt GitHub credentials in `.travis.yml`

For the last two point, see the longer version below.

### Google Drive integration
WDIO test failures are automatically uploaded to Google Drive. The credentials
in this public repository are encrypted by Travis. If you don't fork the
project, but copy it, you need to re-add and encrypt your credentials,
the process of updating `gdrive-service-account.json.enc` is described at
https://github.com/prasmussen/gdrive/#service-account
and https://developers.google.com/identity/protocols/OAuth2ServiceAccount .
Encrypting the retrieved JSON file can be done via `travis encrypt-file`.
In the end, you can commit the changes to the repository.

### GitHub integration
The uploaded WDIO test failure videos are exposed via GitHub comment. For
this purpose, you need personal access token of a user who is able to comment
on the related pull requests.
Get an access token with basic repository, issue and pull request access
granted:
https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/

Then:
```
travis encrypt GH_TOKEN="<personaltoken>"
```
In the end, you can commit the changes to the repository.
