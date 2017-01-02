<?php

/**
 * @file
 * Restful plugin.
 */

$plugin = array(
  'label' => t('Sensors'),
  'resource' => 'sensors',
  'name' => 'sensors',
  'entity_type' => 'node',
  'bundle' => 'sensor_electricity',
  'description' => t('Exports the Sensors electricity bundle.'),
  'class' => 'SensorsRestfulSensors',
  'authentication_types' => TRUE,
);
