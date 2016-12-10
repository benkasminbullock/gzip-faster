# This is a test for module Gzip::Faster.

use warnings;
use strict;
use FindBin;
use Test::More;
use Gzip::Faster ':all';

my $gzipped_empty = gzip ('');
is ($gzipped_empty, undef, "Empty input results in the undefined value");

my $tests = 'test this';
my $zipped = gzip ($tests);
my $unzipped = gunzip ($zipped);
is ($unzipped, $tests, "round trip with gzip and gunzip");
my $deflated = deflate ($tests);
my $inflated = inflate ($deflated);
is ($inflated, $tests, "round trip with deflate and inflate");
is ($unzipped, $tests, "round trip with gzip and gunzip");
my $raw_deflated = deflate_raw ($tests);
my $raw_inflated = inflate_raw ($raw_deflated);
is ($raw_inflated, $tests, "round trip with deflate_raw and inflate_raw");
# Test for ungzipped input in gunzip.
eval {
    gunzip ('ragamuffin');
};
ok ($@, "error with ungzipped input");
like ($@, qr/Data input to inflate is not in libz format/,
      "got correct error message");

use utf8;
my $kujira = '鯨';
if (! utf8::is_utf8 ($kujira)) {
    die "Sanity check failed";
}

my $gf1 = Gzip::Faster->new ();
# round trips involving object and non-object
my $rt;
my $input = 'monkey shines';
eval {
    $rt = gunzip ($gf1->zip ($input));
};
ok (! $@, "zip method doesn't crash");
if ($@) {
    note ("'$@'");
}
ok ($rt, "Got round trip value");
is ($rt, $input, "Round trip is OK");
eval {
    $rt = $gf1->unzip (gzip ($input));
};
ok (! $@, "unzip method doesn't crash");
if ($@) {
    note ($@);
}
ok ($rt, "Got round trip value");
is ($rt, $input, "Round trip is OK");


my $gfraw = Gzip::Faster->new ();
$gfraw->raw (1);
eval {
    $rt = inflate_raw ($gfraw->zip ($input));
};
ok (! $@, "zip method doesn't crash");
if ($@) {
    note ("'$@'");
}
ok ($rt, "Got round trip value");
is ($rt, $input, "Round trip is OK");
eval {
    $rt = $gfraw->unzip (deflate_raw ($input));
};
ok (! $@, "unzip method doesn't crash");
if ($@) {
    note ($@);
}
ok ($rt, "Got round trip value");
is ($rt, $input, "Round trip is OK");

my $gf = Gzip::Faster->new ();
$gf->copy_perl_flags (1);
ok (utf8::is_utf8 ($gf->unzip ($gf->zip ($kujira))), "UTF-8 round trip");

# This tests the converse of the above.

no utf8;
my $iruka = '海豚';
if (utf8::is_utf8 ($iruka)) {
    die "Sanity check failed";
}
ok (! utf8::is_utf8 ($gf->unzip ($gf->zip ($iruka))), "no UTF-8 round trip");

my $f = "$FindBin::Bin/gzip-faster.t";
my $fgz = "$f.gz";
my $zippedf = gzip_file ($f);
ok ($zippedf, "Got gzipped file from $f");
open my $out, ">:raw", $fgz or die $!;
print $out $zippedf;
close $out or die $!;
my $plain = gunzip_file ($fgz);
ok ($plain, "Got back contents from $fgz");
if (-f $fgz) {
    unlink ($fgz);
}

# This tests that Z_BUF_ERROR is ignored. The file "index.html.gz" is
# deliberately chosen to be a file which trips a Z_BUF_ERROR.

gunzip_file ("$FindBin::Bin/index.html.gz");

for my $test (0, 10101) {
    my $binary = pack "N", $test;
    my $gzipped_binary = gzip ($binary);
    my $ungzipped_binary = gunzip ($gzipped_binary);
    is ($ungzipped_binary, $binary, "Round trip with $test as packed");
    my $unpacked_ungzipped_binary = unpack "N", $ungzipped_binary;
    cmp_ok ($unpacked_ungzipped_binary, '==', $test,
	    "Round trip with $test ungzipped and unpacked");
}

# Test adding names.

my $fname = 'Philip Marlowe';
my $text = 'Moose Malloy';
my $gfnamein = Gzip::Faster->new ();
my $gfnameout = Gzip::Faster->new ();
$gfnamein->file_name ($fname);
my $zippedwithname = $gfnamein->zip ($text);
my $outwithname = $gfnameout->unzip ($zippedwithname);
is ($outwithname, $text, "Output text with name is OK");
my $name_out = $gfnameout->file_name ();
is ($name_out, $fname, "Got file name back");
done_testing ();
exit;
