<?php

/**
 * @file
 * Contains HedleyRestfulMeResource.
 */

/**
 * Class HedleyRestfulMeResource.
 */
class HedleyRestfulMeResource extends \RestfulEntityBaseUser {

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

    $public_fields['pusher_channel'] = array(
      'property' => 'uid',
      'process_callbacks' => [
        [$this, 'getPusherChannel'],
      ],
    );

    return $public_fields;
  }

  /**
   * Overrides \RestfulEntityBase::viewEntity().
   *
   * Always return the current user.
   */
  public function viewEntity($entity_id) {
    $account = $this->getAccount();
    return parent::viewEntity($account->uid);
  }

  /**
   * Get pusher channel for user.
   *
   * @param int $uid
   *   User ID.
   *
   * @return string
   *   The pusher channel name: 'general' or 'private-general'.
   */
  protected function getPusherChannel($uid) {
    return user_access('access private pusher channel', user_load($uid)) ? 'private-general' : 'general';
  }

}
