<?php

namespace Octopuce\Acme\Cli\Command;

use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Octopuce\Acme\Client;

class RevokeCertificate extends \Symfony\Component\Console\Command\Command {

    /** @var Octopuce\Acme\Client */
    private $agent;

    public function __construct($name = null, Client $agent) {

        parent::__construct($name);

        $this->agent = $agent;
    }

    protected function configure() {

        $this
                ->setName('cert:revoke')
                ->setDescription('revokes a certificate')

        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $output->writeln('to be defined');
    }

}
