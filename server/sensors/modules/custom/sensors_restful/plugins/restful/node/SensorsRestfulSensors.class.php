<?php

/**
 * @file
 * Contains SensorsRestfulSensors.
 */

/**
 * Class SensorsRestfulSensors.
 */
class SensorsRestfulSensors extends SensorsRestfulEntityBaseNode {

  /**
   * {@inheritdoc}
   */
  public function publicFieldsInfo() {
    $public_fields = parent::publicFieldsInfo();

    $field_names = [];

    foreach ($field_names as $field_name) {
      $public_name = str_replace('field_', '', $field_name);
      $public_fields[$public_name] = [
        'property' => $field_name,
      ];
    }

    $public_fields['image'] = [
      'property' => 'field_image',
      'process_callbacks' => [
        [$this, 'imageProcess'],
      ],
      'image_styles' => ['large'],
    ];

    return $public_fields;
  }

}
