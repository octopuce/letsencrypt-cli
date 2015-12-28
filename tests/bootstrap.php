<?php

define( "APP_PATH",realpath( __DIR__."/../"));
$autoload = require APP_PATH.'/vendor/autoload.php';

// Load configuration file or attempt to build a new one
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
        "Letsencrypt SSL CLI", // NAME
        "0.1" // VERSION
        );


$console->add(new \Symfony\Component\Console\Command\HelpCommand());
$console->add(new \Symfony\Component\Console\Command\ListCommand());
//$console->add(new \Octopuce\Acme\Cli\Command\Enumerate(null, $client));
$console->add(new \Octopuce\Acme\Cli\Command\NewAccount(null, $client));
$console->add(new \Octopuce\Acme\Cli\Command\NewOwnership(null, $client));
//$console->add(new \Octopuce\Acme\Cli\Command\ChallengeOwnership(null, $client));
$console->add(new \Octopuce\Acme\Cli\Command\SignCertificate(null, $client));
$console->add(new \Octopuce\Acme\Cli\Command\RevokeCertificate(null, $client));
$console->add(new \Octopuce\Acme\Cli\Command\UpdateCertificate(null, $client));
