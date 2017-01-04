<?php

/**
 * @file
 * Contains \HedleyMigrateUsers.
 */

/**
 * Class HedleyMigrateUsers.
 */
class HedleyMigrateUsers extends HedleyMigrateBase {

  public $entityType = 'user';

  /**
   * UnioMigrateUsers constructor.
   *
   * {@inheritdoc}
   */
  public function __construct($arguments) {
    parent::__construct($arguments);
    $this->description = t('Import users from the CSV.');

    $columns = array(
      ['name', t('Username')],
      ['pass', t('User password')],
      ['email', t('User email')],
      ['avatar', t('User avatar')],
    );

    $source_file = $this->getMigrateDirectory() . '/csv/user.csv';
    $options = array('header_rows' => 1);
    $this->source = new MigrateSourceCSV($source_file, $columns, $options);

    $this->destination = new MigrateDestinationUser();

    $this->addFieldMapping('name', 'name');
    $this->addFieldMapping('mail', 'email');
    $this->addFieldMapping('pass', 'pass');

    $this->addFieldMapping('field_avatar', 'avatar');
    $this->addFieldMapping('field_avatar:file_replace')
      ->defaultValue(FILE_EXISTS_REPLACE);

    $this->addFieldMapping('field_avatar:source_dir')
      ->defaultValue($this->getMigrateDirectory() . '/images/');

    $this->addFieldMapping(('status'))
      ->defaultValue(1);

    $this->map = new MigrateSQLMap($this->machineName,
      array(
        'name' => array(
          'type' => 'varchar',
          'length' => 255,
          'not null' => TRUE,
        ),
      ),
      MigrateDestinationUser::getKeySchema()
    );
  }

}
