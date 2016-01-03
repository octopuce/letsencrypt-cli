<?php

namespace Octopuce\Acme\Cli\Command;

use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Octopuce\Acme\Client;

class Enumerate extends \Octopuce\Acme\Cli\Command {


    protected function configure() {

        $this
                ->setName('test')
                ->setDescription('Connects to API endpoint')

        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        try {
            /** @var Guzzle\Http\Message\Response */
            $res = $this->getClient()->enumerate();

            $out = current(current( $res->getHeader("Replay-Nonce") ));
            if(! is_string($out) || is_null($out) || empty($out)){
                throw new \Exception("Failed to retrieve a valid answer.");
            }
            $returnCode = 0;
            $returnMessage = $out;
            
        } catch (\Exception $e) {
            $returnCode = 1;
            $returnMessage = $e->getMessage();
        }
        
        $output->writeln($returnMessage);
        return $returnCode;

    }

}
