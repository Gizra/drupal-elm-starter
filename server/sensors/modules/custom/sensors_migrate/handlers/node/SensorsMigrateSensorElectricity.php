<?php

/**
 * @file
 * Contains \SensorsMigrateSensorElectricity.
 */

/**
 * Class SensorsMigrateSensorElectricity.
 */
class SensorsMigrateSensorElectricity extends SensorsMigrateBase {

  public $entityType = 'node';
  public $bundle = 'sensor_electricity';

  /**
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $this->description = t('Import Sensor electricity from the CSV.');
    $this->dependencies = [
      'SensorsMigrateUsersMigrate',
    ];

    $column_names = [
      'title',
      'field_image',
    ];

    $columns = [];
    foreach ($column_names as $column_name) {
      $columns[] = [$column_name, $column_name];
    }

    $source_file = $this->getMigrateDirectory() . '/csv/sensor-electricity.csv';
    $options = array('header_rows' => 1);
    $this->source = new MigrateSourceCSV($source_file, $columns, $options);

    $key = array(
      'title' => array(
        'type' => 'varchar',
        'length' => 255,
        'not null' => TRUE,
      ),
    );

    $this->destination = new MigrateDestinationNode($this->bundle);

    $this->map = new MigrateSQLMap($this->machineName, $key, MigrateDestinationNode::getKeySchema());

    $simple_fields = drupal_map_assoc([
      'title',
    ]);

    $this->addSimpleMappings($simple_fields);

    $this->addFieldMapping('field_image', 'field_image');
    $this->addFieldMapping('field_image:file_replace')
      ->defaultValue(FILE_EXISTS_REPLACE);

    $this->addFieldMapping('field_image:source_dir')
      ->defaultValue($this->getMigrateDirectory() . '/images/');

    $this->addFieldMapping('uid', 'author')
      ->sourceMigration('SensorsMigrateUsersMigrate')
      ->defaultValue(1);
  }

}
