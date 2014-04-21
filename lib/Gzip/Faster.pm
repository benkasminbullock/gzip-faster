package Gzip::Faster;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw/gzip gunzip gzip_file gunzip_file/;
use warnings;
use strict;
use Carp;
our $VERSION = 0.06;
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);

sub gzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $plain = <$in>;
    return gzip ($plain);
}

sub gunzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $zipped = <$in>;
    return gunzip ($zipped);
}

1;
