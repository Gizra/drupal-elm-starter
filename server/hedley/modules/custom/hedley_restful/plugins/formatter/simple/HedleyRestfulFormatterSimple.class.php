<?php

/**
 * @file
 * Contains HedleyRestfulFormatterSimple.
 */

/**
 * Class HedleyRestfulFormatterSimple.
 */
class HedleyRestfulFormatterSimple extends \RestfulFormatterBase implements \RestfulFormatterInterface {

  /**
   * Content type.
   *
   * @var string
   */
  protected $contentType = 'application/json; charset=utf-8';

  /**
   * {@inheritdoc}
   */
  public function prepare(array $data) {
    // If we're returning an error then set the content type to
    // 'application/problem+json; charset=utf-8'.
    if (!empty($data['status']) && floor($data['status'] / 100) != 2) {
      $this->contentType = 'application/problem+json; charset=utf-8';
      return $data;
    }

    $output = ['data' => $data];

    return $output;
  }

  /**
   * {@inheritdoc}
   */
  public function render(array $structured_data) {
    return drupal_json_encode($structured_data);
  }

}
