# $Id: SAX1toSAX2.pm,v 1.2 2001/05/23 11:52:34 matt Exp $

package XML::Filter::SAX1toSAX2;

use strict;
use vars qw($VERSION @ISA);

use XML::Filter::Base;

@ISA = qw(XML::Filter::Base);

$VERSION = '0.01';

use vars qw/$xmlns_ns/;

$xmlns_ns = "http://www.w3.org/2000/xmlns/";

sub start_document {
    my ($self, $document) = @_;
    
    $self->{InScopeNamespaceStack} = [ { '_Default' => undef,
				         'xmlns' => $xmlns_ns } ];
    
    $self->{Handler}->start_document($document);
}
    
sub start_element {
    my ($self, $element) = @_;
    
    $self->make_sax2_attribs($element);
    
    $element->{Parent} = $self->{Current_Element};
    $self->{Current_Element} = $element;
    
    $self->{Handler}->start_element($element);
}

sub end_element {
    my ($self, $element) = @_;
    
    if ($self->{Is_SAX1}) {
        pop @{ $self->{InScopeNamespaceStack} };
    }
    
    $element = $self->{Current_Element};
    $self->{Current_Element} = $self->{Current_Element}->{Parent};
    
    $self->{Handler}->end_element($element);
}

sub make_sax2_attribs {
    my $self = shift;
    my $element = shift;
    
    if (ref($element->{Attributes}) ne 'HASH') {
        # already SAX2 attribs!
        return;
    }
    
    $self->{Is_SAX1} = 1;
    
    push @{ $self->{InScopeNamespaceStack} },
         { %{ $self->{InScopeNamespaceStack}[-1] } };
    $self->_scan_namespaces(%{$element->{Attributes}});
    
    my @attribs;
    foreach my $key (keys %{$element->{Attributes}}) {
        my $namespace = $self->_namespace($key);
        push @attribs, {
                Name => $key,
                Value => $element->{Attributes}{$key},
                NamespaceURI => $namespace,
                };
    }
    
    $element->{Attributes} = \@attribs;
}

sub _scan_namespaces {
    my ($self, %attributes) = @_;

    while (my ($attr_name, $value) = each %attributes) {
	if ($attr_name =~ /^xmlns(:(.*))?$/) {
            my $prefix = $2 || '_Default';
            $self->{InScopeNamespaceStack}[-1]{$prefix} = $value;
	}
    }
}

sub _namespace {
    my ($self, $name) = @_;

    my ($prefix, $localname) = split(/:/, $name);
    if (!defined($localname)) {
	if ($prefix eq 'xmlns') {
	    return undef;
	} else {
	    return $self->{InScopeNamespaceStack}[-1]{'_Default'};
	}
    } else {
	return $self->{InScopeNamespaceStack}[-1]{$prefix};
    }
}

1;
__END__

=head1 NAME

XML::Filter::SAX1toSAX2 - Convert SAX1 events to SAX2

=head1 SYNOPSIS

  use XML::Filter::SAX1toSAX2;
  # create a SAX2 handler
  my $handler = XML::Handler::SAX2Foo->new();
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

XML::Parser::PerlSAX, XML::Filter::Base, XML::Filter::SAX2toSAX1

=cut
