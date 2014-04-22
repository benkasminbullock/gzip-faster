#!/home/ben/software/install/perl
use warnings;
use strict;
use Gzip::Faster;
my $gzipped = gzip ($input);
my $roundtrip = gunzip ($gzipped);
# $roundtrip is the same as $input
my $plain = gunzip_file ('file.gz');
gzip_to_file ($plain, 'file.gz');
