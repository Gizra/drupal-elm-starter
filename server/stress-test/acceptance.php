<?php

/**
 * @file
 * Helper script to check the successful exection of the  Gatling stress test.
 */

$result = json_decode(file_get_contents($argv[1]));
if (empty($result) || !is_object($result)) {
  print "The output is not parsable\n";
  exit(1);
}

if ($result->numberOfRequests->total !== $result->numberOfRequests->ok) {
  print "Not all requests are successful:\n";
  print_r($result);
  exit(1);
}

if ($result->group1->percentage !== 100) {
  print "There are slow requests:\n";
  print_r($result);
  exit(1);
}
