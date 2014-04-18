# This is a test for module Gzip::Faster.

use warnings;
use strict;
use Test::More;
use Gzip::Faster;

my $gzipped_empty = gzip ('');
is ($gzipped_empty, undef, "Empty input results in the undefined value");

my $tests = 'test this';
my $zipped = gzip ($tests);
my $unzipped = gunzip ($zipped);
is ($unzipped, $tests, "round trip");
# Test for ungzipped input in gunzip.
eval {
    gunzip ('ragamuffin');
};
ok ($@, "error with ungzipped input");
like ($@, qr/not gzipped/, "got correct error message");

TODO: {
    local $TODO = 'not implemented yet';
    use utf8;
    my $kujira = '鯨';
    if (! utf8::is_utf8 ($kujira)) {
	die;
    }
    ok (utf8::is_utf8 (gunzip (gzip ($kujira))), "UTF-8 round trip");
};

done_testing ();
# Local variables:
# mode: perl
# End:
