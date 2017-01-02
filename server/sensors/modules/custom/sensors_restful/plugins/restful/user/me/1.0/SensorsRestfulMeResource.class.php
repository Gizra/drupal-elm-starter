<?php

/**
 * @file
 * Contains SensorsRestfulMeResource.
 */

/**
 * Class SensorsRestfulMeResource.
 */
class SensorsRestfulMeResource extends \RestfulEntityBaseUser {

  /**
   * {@inheritdoc}
   */
  protected $controllers = [
    '' => [
      \RestfulInterface::GET => 'viewEntity',
    ],
  ];

  /**
   * {@inheritdoc}
   */
  public function publicFieldsInfo() {
    $public_fields = parent::publicFieldsInfo();

    unset($public_fields['self']);
    return $public_fields;
  }

  /**
   * Overrides \RestfulEntityBase::viewEntity().
   *
   * Always return the current user.
   */
  public function viewEntity($entity_id) {
    $account = $this->getAccount();
    return array(parent::viewEntity($account->uid));
  }

}
