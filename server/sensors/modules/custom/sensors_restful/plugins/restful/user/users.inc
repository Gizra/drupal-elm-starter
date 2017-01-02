<?php

/**
 * @file
 * Uniu users restful plugin.
 */

$plugin = array(
  'label' => t('User'),
  'description' => t('Export the User entity.'),
  'resource' => 'users',
  'class' => 'SensorsRestfulUser',
  'entity_type' => 'user',
  'bundle' => 'user',
  'authentication_types' => TRUE,
  // Setting major version to 2, so it overrides RESTful's own User resource.
  'major_version' => 2,
);
