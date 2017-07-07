<?php
/**
 * @file
 * Pusher auth plugin definition.
 */
$plugin = array(
  'label' => t('Pusher auth'),
  'description' => t('Authenticate user for the pusher privileged channel.'),
  'resource' => 'pusher_auth',
  'class' => 'HedleyRestfulPusherAuthResource',
  'entity_type' => 'user',
  'bundle' => 'user',
  'authentication_types' => TRUE,
  'formatter' => 'simple',
);
