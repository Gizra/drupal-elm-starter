core = 7.x
api = 2

; Modules
projects[admin_menu][subdir] = "contrib"
projects[admin_menu][version] = "3.0-rc5"

projects[admin_views][subdir] = "contrib"
projects[admin_views][version] = "1.6"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.12"
projects[ctools][patch][] = "https://www.drupal.org/files/issues/2067997-reload-plugins-class-7.patch"

projects[composer_manager][subdir] = "contrib"
projects[composer_manager][version] = "1.8"

projects[date][subdir] = "contrib"
projects[date][version] = "2.10"

projects[diff][subdir] = "contrib"
projects[diff][version] = "3.2"

projects[entity][subdir] = "contrib"
projects[entity][version] = "1.8"
projects[entity][patch][] = "https://www.drupal.org/files/issues/2086225-entity-access-check-node-create-3.patch"

projects[entityreference][subdir] = "contrib"
projects[entityreference][version] = "1.5"

projects[entity_validator][subdir] = "contrib"
projects[entity_validator][version] = "1.2"

projects[features][subdir] = "contrib"
projects[features][version] = "2.10"

projects[message][subdir] = "contrib"
projects[message][version] = "1.12"

projects[module_filter][subdir] = "contrib"
projects[module_filter][version] = "2.1"

projects[restful][subdir] = "contrib"
projects[restful][version] = "1.8"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.0"

projects[token][subdir] = "contrib"
projects[token][version] = "1.7"

projects[views][subdir] = "contrib"
projects[views][version] = "3.18"

projects[views_bulk_operations][subdir] = "contrib"
projects[views_bulk_operations][version] = "3.4"

; Libraries
; For the 'hedley_faker' module.
libraries[faker][download][type] = get
libraries[faker][download][url] = https://github.com/fzaninotto/Faker/archive/v1.6.0.tar.gz

; Development
projects[devel][subdir] = "development"
projects[devel][version] = "1.5"

projects[migrate][subdir] = "development"
projects[migrate][version] = "2.8"

projects[migrate_extras][subdir] = "development"
projects[migrate_extras][version] = "2.5"
