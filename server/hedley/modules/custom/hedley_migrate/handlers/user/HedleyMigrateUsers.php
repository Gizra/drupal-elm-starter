<?php

/**
 * @file
 * Contains \HedleyMigrateUsers.
 */

/**
 * Class HedleyMigrateUsers.
 */
class HedleyMigrateUsers extends HedleyMigrateBase {

  protected $entityType = 'user';
  protected $bundle = 'user';
  protected $csvColumns = [
    'id',
    'name',
    'pass',
    'email',
    'avatar',
  ];
  protected $simpleMappings = [
    'name',
    'pass',
    'email',
  ];

  /**
   * HedleyMigrateUsers constructor.
   *
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);

    $this->addFieldMapping('field_avatar', 'avatar');
    $this->addFieldMapping('field_avatar:file_replace')
      ->defaultValue(FILE_EXISTS_REPLACE);

    $this->addFieldMapping('field_avatar:source_dir')
      ->defaultValue($this->getMigrateDirectory() . '/images/');

    $this->addFieldMapping(('status'))
      ->defaultValue(1);
  }

}
