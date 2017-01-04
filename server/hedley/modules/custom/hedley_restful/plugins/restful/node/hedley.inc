<?php

/**
 * @file
 * Restful plugin.
 */

$plugin = array(
  'label' => t('Hedley'),
  'resource' => 'hedley',
  'name' => 'hedley',
  'entity_type' => 'node',
  'bundle' => 'item',
  'description' => t('Exports the Hedley electricity bundle.'),
  'class' => 'HedleyRestfulHedley',
  'authentication_types' => TRUE,
);
