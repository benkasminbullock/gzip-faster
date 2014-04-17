=encoding UTF-8

=head1 NAME

Gzip::Faster - abstract here.

=head1 SYNOPSIS

    use Gzip::Faster;

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut
package Gzip::Faster;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw//;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
our $VERSION = 0.01;
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);
1;
