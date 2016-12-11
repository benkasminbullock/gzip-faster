package Gzip::Faster;
use warnings;
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/gzip gunzip gzip_file gunzip_file gzip_to_file/;
our @EXPORT_OK = qw/deflate inflate deflate_raw inflate_raw/;
our %EXPORT_TAGS = ('all' => [@EXPORT, @EXPORT_OK]);
use Carp;
our $VERSION = '0.17';
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);

sub gzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $plain = <$in>;
    close $in or croak "Error closing '$file': $!";
    return gzip ($plain);
}

sub gunzip_file
{
    my ($file) = @_;
    open my $in, "<:raw", $file or croak "Error opening '$file': $!";
    local $/;
    my $zipped = <$in>;
    close $in or croak "Error closing '$file': $!";
    return gunzip ($zipped);
}

sub gzip_to_file
{
    my ($plain, $file) = @_;
    open my $in, ">:raw", $file or croak "Error opening '$file': $!";
    print $in gzip ($plain);
}

1;
