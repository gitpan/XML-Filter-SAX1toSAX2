require 5.00503;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'XML::Filter::SAX1toSAX2',
    'VERSION_FROM' => 'SAX1toSAX2.pm', # finds $VERSION
    'PREREQ_PM' => { 'XML::SAX::Base' => 0, XML::NamespaceSupport => 0 },
    'AUTHOR' => 'Matt Sergeant',
    'ABSTRACT_FROM' => 'SAX1toSAX2.pm',
);
