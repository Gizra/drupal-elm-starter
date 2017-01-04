<?php

/**
 * @file
 * Contains \HedleyMigrateItems.
 */

/**
 * Class HedleyMigrateItems.
 */
class HedleyMigrateItems extends HedleyMigrateBase {

  public $entityType = 'node';
  public $bundle = 'item';

  /**
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $this->description = t('Import Item from the CSV.');
    $this->dependencies = [
      'HedleyMigrateUsers',
    ];

    $column_names = [
      'title',
      'field_image',
    ];

    $columns = [];
    foreach ($column_names as $column_name) {
      $columns[] = [$column_name, $column_name];
    }

    $source_file = $this->getMigrateDirectory() . '/csv/item.csv';
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
      ->sourceMigration('HedleyMigrateUsers')
      ->defaultValue(1);
  }

}
