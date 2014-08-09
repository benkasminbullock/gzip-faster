package Gzip::Faster;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw/gzip gunzip gzip_file gunzip_file gzip_to_file/;
use warnings;
use strict;
use Carp;
our $VERSION = '0.08_01';
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);

sub gzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $plain = <$in>;
    close $in or die "Error closing '$file': $!";
    return gzip ($plain);
}

sub gunzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $zipped = <$in>;
    close $in or die "Error closing '$file': $!";
    return gunzip ($zipped);
}

sub gzip_to_file
{
    my ($plain, $file) = @_;
    open my $in, ">:raw", $file or croak "Error opening '$file': $!";
    print $in gzip ($plain);
}

1;
