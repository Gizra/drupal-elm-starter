<?php

/**
 * @file
 * Contains \HedleyMigrateBase.
 */

/**
 * Class HedleyMigrateBase.
 */
abstract class HedleyMigrateBase extends Migration {

  /**
   * The entity type. e.g. 'node', 'taxonomy_term'.
   *
   * @var string|null
   */
  protected $entityType = NULL;

  /**
   * The entity's bundle. e.g. 'item', 'article'.
   *
   * @var string|null
   */
  protected $bundle = NULL;

  /**
   * Defines the columns in the csv file.
   *
   * (please define in the order they appear in the file)
   *
   * @var array
   */
  protected $csvColumns = [];

  /**
   * Fields for simple mapping.
   *
   * (one value, no reference to other entities in the migration)
   *
   * @var array
   */
  protected $simpleMappings = [];

  /**
   * Fields for multiple simple mapping.
   *
   * (multi value, no reference to other entities in the migration)
   *
   * @var array
   */
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

    // The source file, also can be separated into folders using the
    // "$this->entityType" var.
    $source_file = $this->getMigrateDirectory() . '/csv/' . $this->bundle . '.csv';

    $columns = [];
    foreach ($this->csvColumns as $column_name) {
      $columns[] = [$column_name, $column_name];
    }
    $this->source = new MigrateSourceCSV($source_file, $columns, ['header_rows' => 1]);

    $destination_class = $destination_classes[$this->entityType];

    // The destination class's arguments change between user and the rest of
    // the entities.
    $this->destination = $this->entityType == 'user' ? new $destination_class() : new $destination_class($this->bundle);

    $key = [
      'id' => [
        'type' => 'varchar',
        'length' => 255,
        'not null' => TRUE,
      ],
    ];

    $this->map = new MigrateSQLMap($this->machineName, $key, $this->destination->getKeySchema($this->entityType));

    // Add simple mappings.
    if (!empty($this->simpleMappings)) {
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
      // Set the author, just add "author" column in the CSV and reference the
      // migration ID of the user, if no "author" column is present then it will
      // default to user 1 which is the main admin, not "user1" in the
      // migration.
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
