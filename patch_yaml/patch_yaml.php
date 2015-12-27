<?php

/**
 * 
 * 0 "${APP_PATH}/patch_yaml/patch_yaml.php" 
 * 1 "${APP_PATH}/array.yml" 
 * 2 "$MYSQL_DB_NAME" 
 * 3 "$MYSQL_USER_NAME" 
 * 4 "$MYSQL_USER_PASSWORD"`
 * 
 */
try {
    $autoload = require_once( __DIR__ . '/../vendor/autoload.php' );
    $array = Symfony\Component\Yaml\Yaml::parse(file_get_contents($argv[1]));
    $db = $array["db"];
    $db["dbname"] = $argv[2];
    $db["user"] = $argv[3];
    $db["pass"] = $argv[4];
    $array["db"] = $db;
    file_put_contents($argv[1], Symfony\Component\Yaml\Yaml::dump($array, 4, 4, true) );
} catch (\Exception $e) {
    echo "Error: ".$e->getMessage();
    exit(1);
}
echo "OK";
exit( 0 );