<?php

/**
 * @file
 * Contains \SensorsMigrateBase.
 */

/**
 * Class SensorsMigrateBase.
 */
abstract class SensorsMigrateBase extends Migration {

  /**
   * UnioMigrateBase constructor.
   *
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
  }

  /**
   * Returns the migrate directory.
   *
   * @return string
   *   The migrate directory.
   */
  protected function getMigrateDirectory() {
    return variable_get('sensors_migrate_directory', FALSE) ? variable_get('sensors_migrate_directory') : drupal_get_path('module', 'sensors_migrate');
  }

}
