<?php
namespace Octopuce\Acme\Cli;
/**
 * abstract Command
 *
 * @author alban
 */
class Command  extends  \Symfony\Component\Console\Command\Command {
    
    /** @var Octopuce\Acme\Client */
    private $client;

    /**
     * @param Octopuce\Acme\Client client
     */
    public function setClient($client) {
        $this->client = $client;
        return $this;
    }

    /**
     * @return Octopuce\Acme\Client
     */
    public function getClient() {
        return $this->client;
    }

    public function __construct($name = null, $client   ) {

        parent::__construct($name);
        $this->setClient( $client );
        
    }
}
