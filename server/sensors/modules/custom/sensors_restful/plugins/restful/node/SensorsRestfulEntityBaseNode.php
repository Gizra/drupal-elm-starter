<?php

/**
 * @file
 * Contains \SensorsRestfulEntityBaseNode.
 */

/**
 * Class SensorsRestfulEntityBaseNode.
 */
abstract class SensorsRestfulEntityBaseNode extends \RestfulEntityBaseNode {

  /**
   * Overrides \RestfulEntityBaseNode::publicFieldsInfo().
   */
  public function publicFieldsInfo() {
    $public_fields = parent::publicFieldsInfo();

    $public_fields['created'] = array(
      'property' => 'created',
      'process_callbacks' => [
        [$this, 'convertTimestampToIso8601'],
      ],
    );

    return $public_fields;
  }

  /**
   * Convert Unix timestamp to ISO8601.
   *
   * @param int $timestamp
   *   The Unix timestamp.
   *
   * @return false|string
   *   The converted timestamp.
   */
  protected function convertTimestampToIso8601($timestamp) {
    return date('c', $timestamp);
  }

  /**
   * Process callback, Remove Drupal specific events from the image array.
   *
   * @param array $value
   *   The image array.
   *
   * @return array
   *   A cleaned image array.
   */
  protected function imageProcess(array $value) {
    if (static::isArrayNumeric($value)) {
      $output = array();
      foreach ($value as $item) {
        $output[] = $this->imageProcess($item);
      }
      return $output;
    }
    return array(
      'id' => $value['fid'],
      'self' => file_create_url($value['uri']),
      'filemime' => $value['filemime'],
      'filesize' => $value['filesize'],
      'width' => $value['width'],
      'height' => $value['height'],
      'styles' => $value['image_styles'],
    );
  }

}
