<?php

/**
 * @file
 * RESTful plugin definition.
 */

$plugin = array(
  'label' => t('Me'),
  'description' => t('Export the "User" entity of the current user.'),
  'resource' => 'me',
  'class' => 'HedleyRestfulMeResource',
  'entity_type' => 'user',
  'bundle' => 'user',
  // Try to authenticate users with all available authentication types.
  'authentication_types' => TRUE,
);
