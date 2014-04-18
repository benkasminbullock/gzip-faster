# This is a test for module Gzip::Faster.

use warnings;
use strict;
use Test::More;
use Gzip::Faster qw/gzip gunzip/;

my $gzipped_empty = gzip ('');
is ($gzipped_empty, undef, "Empty input results in the undefined value");

my $zipped2 = gzip ('buggles');
my $tests = 'test this';
my $zipped = gzip ($tests);
my $unzipped = gunzip ($zipped);
is ($unzipped, $tests, "round trip");

TODO: {
    local $TODO = 'not implemented yet';
};

done_testing ();
# Local variables:
# mode: perl
# End:
