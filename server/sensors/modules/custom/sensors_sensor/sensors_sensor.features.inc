<?php
/**
 * @file
 * sensors_sensor.features.inc
 */

/**
 * Implements hook_ctools_plugin_api().
 */
function sensors_sensor_ctools_plugin_api($module = NULL, $api = NULL) {
  if ($module == "strongarm" && $api == "strongarm") {
    return array("version" => "1");
  }
}

/**
 * Implements hook_node_info().
 */
function sensors_sensor_node_info() {
  $items = array(
    'sensor_electricity' => array(
      'name' => t('Sensor electricity'),
      'base' => 'node_content',
      'description' => '',
      'has_title' => '1',
      'title_label' => t('Title'),
      'help' => '',
    ),
  );
  drupal_alter('node_info', $items);
  return $items;
}
