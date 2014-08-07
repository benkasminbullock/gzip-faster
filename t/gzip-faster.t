# This is a test for module Gzip::Faster.

use warnings;
use strict;
use FindBin;
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
like ($@, qr/Data input to gunzip is not in gzip format/,
      "got correct error message");

# TODO: {
#     local $TODO = 'This functionality is disabled due to a FireFox bug';
#     use utf8;
#     my $kujira = '鯨';
#     if (! utf8::is_utf8 ($kujira)) {
# 	die "Sanity check failed";
#     }
#     ok (utf8::is_utf8 (gunzip (gzip ($kujira))), "UTF-8 round trip");

# };

# # This tests the converse of the above.

# no utf8;
# my $iruka = '海豚';
# if (utf8::is_utf8 ($iruka)) {
#     die "Sanity check failed";
# }
# ok (! utf8::is_utf8 (gunzip (gzip ($iruka))), "no UTF-8 round trip");

my $f = "$FindBin::Bin/gzip-faster.t";
my $fgz = "$f.gz";
my $zippedf = gzip_file ($f);
ok ($zippedf);
open my $out, ">:raw", $fgz or die $!;
print $out $zippedf;
close $out or die $!;
my $plain = gunzip_file ($fgz);
ok ($plain);
if (-f $fgz) {
    unlink ($fgz);
}

# This tests that Z_BUF_ERROR is ignored. The file "index.html.gz" is
# deliberately chosen to be a file which trips a Z_BUF_ERROR.

gunzip_file ("$FindBin::Bin/index.html.gz");

done_testing ();

# Local variables:
# mode: perl
# End:
