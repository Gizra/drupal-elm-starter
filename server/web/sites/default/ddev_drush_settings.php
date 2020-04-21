<?php

$version = "";
if (defined("\Drupal::VERSION")) {
    $version = \Drupal::VERSION;
} else if (defined("VERSION")) {
    $version = VERSION;
}

// Use the array format for D7+
if (version_compare($version, "7.0") > 0) {
  $databases['default']['default'] = array(
    'database' => "db",
    'username' => "db",
    'password' => "db",
    'host' => "127.0.0.1",
    'driver' => "mysql",
    'port' => 32785,
    'prefix' => "",
  );
} else {
  // or the old db_url format for d6
  $db_url = 'mysqli://db:db@127.0.0.1:32785/db';
}
