# $Id: SAX1toSAX2.pm,v 1.2 2001/05/23 11:52:34 matt Exp $

package XML::Filter::SAX1toSAX2;

use strict;
use vars qw($VERSION @ISA);

use XML::SAX::Base;
use XML::NamespaceSupport;

@ISA = qw(XML::SAX::Base);

$VERSION = '0.02';

sub start_document {
    my ($self, $document) = @_;
    
    $self->{NSSupport} = XML::NamespaceSupport->new();
    $self->SUPER::start_document($document);
}
    
sub start_element {
    my ($self, $element) = @_;
    
    $self->{NSSupoort}->push_context;
    
    $self->make_sax2_attribs($element);
    my ($uri, $lname, $prefix) = $self->{NSSupport}->process_element_name($element->{Name});
    $element->{LocalName} = $lname;
    $element->{Prefix} = $prefix;
    $element->{NamespaceURI} = $uri;
    $self->SUPER::start_element($element);
}

sub end_element {
    my ($self, $element) = @_;
    
    $self->{NSSupport}->pop_context;
    
    delete($self->{Attributes}); # just in case
    
    my ($uri, $lname, $prefix) = $self->{NSSupport}->process_element_name($element->{Name});
    $element->{LocalName} = $lname;
    $element->{Prefix} = $prefix;
    $element->{NamespaceURI} = $uri;
    
    $self->SUPER::end_element($element);
}

sub make_sax2_attribs {
    my $self = shift;
    my $element = shift;
    
    $self->_scan_namespaces(%{$element->{Attributes}});
    
    my %attribs;
    foreach my $key (keys %{$element->{Attributes}}) {
        my ($uri, $lname, $prefix) = $self->{NSSupport}->process_attribute_name($key);
        $attribs{"{$uri}$lname"} = {
            Name => $key,
            Value => $element->{Attributes}{$key},
            Prefix => $prefix,
            NamespaceURI => $uri,
            LocalName => $lname,
        };
    }
    
    $element->{Attributes} = \%attribs;
}

sub _scan_namespaces {
    my ($self, %attributes) = @_;

    while (my ($attr_name, $value) = each %attributes) {
	if ($attr_name =~ /^xmlns(:(.*))?$/) {
            my $prefix = $2 || '';
            $self->{NSSupport}->declare_prefix($prefix, $value)
	}
    }
}

1;
__END__

=head1 NAME

XML::Filter::SAX1toSAX2 - Convert SAX1 events to SAX2

=head1 SYNOPSIS

  use XML::Filter::SAX1toSAX2;
  # create a SAX2 handler
  my $handler = XML::Handler::AxPoint->new();
  # filter from SAX1 to SAX2
  my $filter = XML::Filter::SAX1toSAX2->new(Handler => $handler);
  # SAX1 parser
  my $parser = XML::Parser::PerlSAX->new(Handler => $filter);
  # parse file
  $parser->parse(Source => { SystemId => "file.xml" });

=head1 DESCRIPTION

This module is a very simple module for creating SAX2 events from
SAX1 events. It is useful in the case where you have a SAX1 parser
but want to use a SAX2 handler or filter of some sort.

As an added bonus, it also does namespace processing for you!

=head1 AUTHOR

Matt Sergeant, matt@sergeant.org

=head1 SEE ALSO

XML::Parser::PerlSAX, XML::SAX::Base, XML::Filter::SAX2toSAX1

=cut
