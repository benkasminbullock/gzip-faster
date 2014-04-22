#!/home/ben/software/install/perl
use warnings;
use strict;
# Make a random input string
my $input = join '', map {int (rand (10))} 0..0x1000;
use Gzip::Faster;
my $gzipped = gzip ($input);
my $roundtrip = gunzip ($gzipped);
if ($roundtrip ne $input) { die; }
gzip_to_file ($input, 'file.gz');
$roundtrip = gunzip_file ('file.gz');
if ($roundtrip ne $input) { die; }
