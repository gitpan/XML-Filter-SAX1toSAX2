# $Id: SAX2toSAX1.pm,v 1.1 2001/05/23 11:52:34 matt Exp $

package XML::Filter::SAX2toSAX1;

use strict;
use vars qw($VERSION @ISA);

use XML::Filter::Base;

@ISA = qw(XML::Filter::Base);

$VERSION = '0.01';

sub start_document {
    my ($self, $document) = @_;
    
    $self->{Handler}->start_document($document);
}
    
sub start_element {
    my ($self, $element) = @_;
    
    $self->make_sax1_attribs($element);
    
    $self->{Handler}->start_element($element);
}

sub end_element {
    my ($self, $element) = @_;
    
    $self->make_sax1_attribs($element);
    
    $self->{Handler}->end_element($element);
}

sub make_sax1_attribs {
    my ($self, $element) = @_;
    
    if (ref($element->{Attributes}) eq 'HASH') {
        # already SAX2 attribs!
        return;
    }
    
    my %attribs;
    
    foreach my $attrib (@{$element->{Attributes}}) {
        $attribs{$attrib->{Name}} = $attrib->{Value};
    }
    
    $element->{Attributes} = \%attribs;
    
    return;
}

1;
__END__

=head1 NAME

XML::Filter::SAX2toSAX1 - Convert SAX2 events to SAX1

=head1 SYNOPSIS

  use XML::Filter::SAX2toSAX1;
  # create a SAX1 handler
  my $handler = XML::Handler::YAWriter->new();
  # filter from SAX2 to SAX1
  my $filter = XML::Filter::SAX2toSAX1->new(Handler => $handler);
  # SAX2 parser
  my $parser = Orchard::SAXDriver::Expat->new(Handler => $filter);
  # parse file
  $parser->parse( "file.xml" );

=head1 DESCRIPTION

This module is a very simple module for creating SAX1 events from
SAX2 events. It is useful in the case where you have a SAX2 parser
but want to use a SAX1 handler or filter of some sort.

=head1 AUTHOR

Matt Sergeant, matt@sergeant.org

=head1 SEE ALSO

XML::Parser::PerlSAX, XML::Filter::Base, XML::Filter::SAX1toSAX2

=cut
