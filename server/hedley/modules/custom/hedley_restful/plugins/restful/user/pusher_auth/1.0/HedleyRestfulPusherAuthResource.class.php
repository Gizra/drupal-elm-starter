<?php

/**
 * @file
 * Contains HedleyRestfulPusherAuthResource.
 */

/**
 * Authenticate pusher connections.
 */
class HedleyRestfulPusherAuthResource extends RestfulEntityBase {

  /**
   * {@inheritdoc}
   */
  public static function controllersInfo() {
    return [
      '' => [
        \RestfulInterface::POST => 'authenticatePusher',
      ],
    ];
  }

  /**
   * Overrides \RestfulEntityBaseUser::publicFieldsInfo().
   */
  public function publicFieldsInfo() {
    $public_fields = parent::publicFieldsInfo();

    $public_fields['auth'] = array(
      'callback' => array($this, 'getPusherAuth'),
    );

    return $public_fields;
  }

  /**
   * Overrides \RestfulEntityBase::viewEntity().
   *
   * Always return the current user.
   */
  public function authenticatePusher() {
    $request = $this->getRequest();

    if (empty($request['socket_id'])) {
      throw new \RestfulBadRequestException('"socket_id" property is missing');
    }

    // Verify the channel name.
    if (empty($request['channel_name'])) {
      throw new \RestfulBadRequestException('"channel_name" property is missing');
    }
    if ($request['channel_name'] != 'private-general') {
      throw new \RestfulBadRequestException(format_string('Unknown channel "@channel"', ['@channel' => $request['channel_name']]));
    }

    $account = $this->getAccount();
    if (!user_access('access private channel', $account)) {
      throw new \RestfulForbiddenException(format_string('User @name is trying to log into the privileged pusher channel "@channel", but has no "access private channel" permission.', ['@name' => $account->name, '@channel' => $request['channel_name']]));
    }

    return $this->view($account->uid);
  }

  /**
   * Get the pusher auth.
   */
  protected function getPusherAuth() {
    $request = $this->getRequest();

    $pusher = hedley_pusher_get_pusher();
    $result = $pusher->socket_auth($request['channel_name'], $request['socket_id']);
    $data = drupal_json_decode($result);

    return $data['auth'];
  }

}
