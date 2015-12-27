<?php


$autoload = require __DIR__.'/vendor/autoload.php';


// Load configuration file or attempt to build a new one
define( "APP_PATH", __DIR__ );
define( "CONFIG_FILE", APP_PATH."/"."config.yml" );
if( ! is_file( CONFIG_FILE ) ) {

    echo "Please run the installer first: './install.sh'.\n";
    exit(1);
    
}

// Build ACME client
$config = Symfony\Component\Yaml\Yaml::parse(file_get_contents(CONFIG_FILE));
$db = $config["db"];
$dsn = "${db["driver"]}://${db["user"]}:${db["pass"]}@${db["host"]}/${db["dbname"]}";
$params = array(
    'params' => array(
        'database' => $dsn,
        'api' => $config["api"],
        'challenge' => $config["challenge"]
    ),
);
$client = new \Octopuce\Acme\Client($params);

// Build Console
$console = new Symfony\Component\Console\Application(
        "ACME Certificate Client", // NAME
        "0.1" // VERSION
        );

// Make your calls !
$client->newAccount('test107@sonntag.fr');

// $client->newOwnership(23, 'sonntag.fr');

//$client->challengeOwnership(23, 'sonntag.fr');
