<?php

/**
 * @file
 * Contains \HedleyMigrateItems.
 */

/**
 * Class HedleyMigrateItems.
 */
class HedleyMigrateItems extends HedleyMigrateBase {

  protected $entityType = 'node';
  protected $bundle = 'item';
  protected $csvColumns = [
    'id',
    'title',
    'field_image',
    'field_private_note',
  ];
  protected $simpleMappings = [
    'field_private_note',
  ];

  /**
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $this->dependencies = [
      'HedleyMigrateUsers',
    ];

    $this->addFieldMapping('field_image', 'field_image');
    $this->addFieldMapping('field_image:file_replace')
      ->defaultValue(FILE_EXISTS_REPLACE);

    $this->addFieldMapping('field_image:source_dir')
      ->defaultValue($this->getMigrateDirectory() . '/images/');
  }

}
