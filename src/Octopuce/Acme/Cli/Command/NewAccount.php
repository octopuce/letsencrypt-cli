<?php

namespace Octopuce\Acme\Cli\Command;

use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Octopuce\Acme\Client;
use Octopuce\Acme\Cli\Command;

class NewAccount extends Command {

    protected function configure() {

        $this
                ->setName('account:add')
                ->setDescription('Add master account on ACME servers')
                ->addArgument("email", InputArgument::REQUIRED, "Email for validation")
                ->addArgument("tel", InputArgument::OPTIONAL, "tel for validation", "")

        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output) {

        $out = "";
        $email = $input->getArgument("email");
        $tel = $input->getArgument("tel");
        $res = $this->get->newAccount($email, $tel);
        $output->writeln('done');
    }

}
