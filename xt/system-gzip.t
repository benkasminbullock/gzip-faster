#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin;
use Test::More;
use Gzip::Faster;

my $guff = <<EOF;
inflate() returns Z_OK if some progress has been made (more input processed
  or more output produced), Z_STREAM_END if the end of the compressed data has
  been reached and all uncompressed output has been produced, Z_NEED_DICT if a
  preset dictionary is needed at this point, Z_DATA_ERROR if the input data was
  corrupted (input stream not conforming to the zlib format or incorrect check
  value), Z_STREAM_ERR
EOF

my $z = gzip $guff;
my $f = "$FindBin::Bin/test";
my $fgz = "$f.gz";
open my $out, ">:raw", $fgz or die $!;
print $out $z;
close $out;
my $status = system ("gzip --force --keep -d $fgz");
ok ($status == 0, "gzip completed OK");
ok (-f $f, "made file $f");
open my $in, "<", $f or die $!;
local $/;
my $guffback = <$in>;
is ($guffback, $guff, "round trip via system gzip");

my $buggles = gunzip_file ($fgz);
is ($buggles, $guff, "gunzip_file returns correct contents");

for my $file ($f, $fgz) {
    if (-f $file) {
	unlink $file;
    }
}

done_testing ();

