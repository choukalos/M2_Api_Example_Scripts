<?php
  // PHP script to create a slew of random customers
  // Use PECL OAuth extension
  // Variables to replace
  $CONSUMERKey     = "fc6c444e70e64febd04f2b23a258f823";
  $CONSUMERSecret  = "47e985772ef6adcf3885478e1ec58476";
  $TOKEN           = "9600cef01273dcafb3f4432cc986d1d4";
  $TOKENSecret     = "4496c61d1f51d81bdbab9769685c816a";

  // Establish Client
  $client = new OAuth($CONSUMERKey,$CONSUMERSecret);
  $client->setToken($TOKEN,$TOKENSecret);
  // Make the call
  $url    = "http://mage2.demo1/index.php/rest/default/V1/customerAccounts/2";
  $method = 'GET';
  $client->fetch($url);
  $output = json_decode($client->getLastResponse());

  echo $output;

?>