<?php

/**
 * @file
 * Contains \HedleyMigrateBase.
 */

/**
 * Class HedleyMigrateBase.
 */
abstract class HedleyMigrateBase extends Migration {

  protected $entityType = NULL;
  protected $bundle = NULL;
  protected $csvColumns = [];
  protected $simpleMappings = [];
  protected $simpleMultipleMappings = [];

  /**
   * HedleyMigrateBase constructor.
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $destination_classes = [
      'node' => 'MigrateDestinationNode',
      'taxonomy_term' => 'MigrateDestinationTerm',
      'user' => 'MigrateDestinationUser',
    ];

    // Add default settings, only for nodes, terms and users.
    if (empty($destination_classes[$this->entityType])) {
      return;
    }

    $this->description = t('Import @bundle.', ['@bundle' => $this->bundle]);

    $source_file = $this->getMigrateDirectory() . '/csv/' . $this->bundle . '.csv';

    $columns = [];
    foreach ($this->csvColumns as $column_name) {
      $columns[] = [$column_name, $column_name];
    }
    $this->source = new MigrateSourceCSV($source_file, $columns, ['header_rows' => 1]);

    $destination_class = $destination_classes[$this->entityType];
    $this->destination = $this->entityType == 'user' ? new $destination_class() : new $destination_class($this->bundle);

    $key_field = $this->bundle == 'user' ? 'name' : 'id';

    $key = [
      $key_field => [
        'type' => 'varchar',
        'length' => 255,
        'not null' => TRUE,
      ],
    ];

    $this->map = new MigrateSQLMap($this->machineName, $key, $this->destination->getKeySchema($this->entityType));

    // Add simple mappings.
    if ($this->simpleMappings) {
      $this->addSimpleMappings(drupal_map_assoc($this->simpleMappings));
    }

    // Add multiple simple mappings.
    if (!empty($this->simpleMultipleMappings)) {
      foreach ($this->simpleMultipleMappings as $field) {
        $this
          ->addFieldMapping($field, $field)
          ->separator('|');
      }
    }

    if ($this->entityType == 'node') {
      // Set the first user as the author.
      $this
        ->addFieldMapping('uid', 'author')
        ->sourceMigration('HedleyMigrateUsers')
        ->defaultValue(1);
      // Map the title field to the default title.
      if (in_array('title', $this->csvColumns)) {
        $this->addFieldMapping('title', 'title');
      }
    }
    elseif ($this->entityType == 'taxonomy_term') {
      // Map the translated name field to the default term name.
      if (in_array('name', $this->csvColumns)) {
        $this->addFieldMapping('name', 'name');
      }
    }

  }

  /**
   * Returns the migrate directory.
   *
   * @return string
   *   The migrate directory.
   */
  protected function getMigrateDirectory() {
    return variable_get('hedley_migrate_directory', FALSE) ? variable_get('hedley_migrate_directory') : drupal_get_path('module', 'hedley_migrate');
  }

  /**
   * Convert a date string to a timestamp.
   *
   * @param string $date
   *   A string containing a date.
   *
   * @return int
   *   A timestamp.
   */
  public function dateProcess($date) {
    return strtotime($date);
  }

  /**
   * Add date fields.
   *
   * @param array $field_names
   *   The date related field names.
   */
  public function addDateFields(array $field_names) {
    foreach ($field_names as $field_name) {
      $this->addFieldMapping($field_name, $field_name)
        ->callbacks([$this, 'dateProcess']);
    }
  }

}
