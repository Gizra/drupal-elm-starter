<?php

/**
 * @file
 * Restful plugin.
 */

$plugin = array(
  'label' => t('Items'),
  'resource' => 'items',
  'name' => 'items',
  'entity_type' => 'node',
  'bundle' => 'item',
  'description' => t('Exports the Items bundle.'),
  'class' => 'HedleyRestfulItems',
  'authentication_types' => TRUE,
);
