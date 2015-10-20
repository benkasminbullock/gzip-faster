#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Benchmark qw(:all);
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Gzip::Faster;
use Compress::Raw::Zlib;
use FindBin '$Bin';
use Path::Tiny;
my $path = path ("$Bin/chinese.txt");

# Don't slurp_utf8 this because the UTF-8 flag will not survive the
# round-trip.

my $in = $path->slurp ();
my $out;
my $round;

splitline ();

splitline ();

my $count = 50;

cmpthese ($count, {
    'IO::Compress::Gzip' => 'io_comp_gzip ()',
    'Compress::Raw::Zlib' => 'comp_raw_zlib ()',
    'Gzip::Faster' => 'gzip_faster ()',
});

sub io_comp_gzip
{
    IO::Compress::Gzip::gzip \$in, \$out;
    IO::Uncompress::Gunzip::gunzip \$out, \$round;
# Comment out to get better benchmark. Uncomment to check validity.
#    die if $in ne $round;
}

sub comp_raw_zlib
{
    my $buf;
    my $dx = Compress::Raw::Zlib::Deflate->new( -WindowBits => WANT_GZIP )
        or die "Cannot create a deflation stream\n";
    ( $dx->deflate($in, $buf) == Z_OK ) ? $out = $buf : die "deflation failed\n";
    ( $dx->flush($buf) == Z_OK ) ? $out .= $buf : die "deflation failed\n";
    my $ix = Compress::Raw::Zlib::Inflate->new( -WindowBits => WANT_GZIP )
        or die "Cannot create a inflation stream\n";
    $_ == Z_OK or $_ == Z_STREAM_END or die "inflation failed\n" for $ix->inflate($out, $round);
# Comment out to get better benchmark. Uncomment to check validity.
#    die if $in ne $round;
}

sub gzip_faster
{
    $out = Gzip::Faster::gzip ($in);
    $round = Gzip::Faster::gunzip ($out);
# Comment out to get better benchmark. Uncomment to check validity.
#    die if $in ne $round;
}

splitline ();

cmpthese ($count, {
    'IO::Compress::Gzip' => 'io_comp_gzip_only ()',
    'Compress::Raw::Zlib::Deflate' => 'comp_raw_zlib_def_only ()',
    'Gzip::Faster' => 'gzip_faster_gzip_only ()',
});

sub io_comp_gzip_only
{
    IO::Compress::Gzip::gzip \$in, \$out;
}

sub comp_raw_zlib_def_only
{
    my $buf;
    my $dx = Compress::Raw::Zlib::Deflate->new( -WindowBits => WANT_GZIP )
        or die "Cannot create a deflation stream\n";
    ( $dx->deflate($in, $buf) == Z_OK ) ? $out = $buf : die "deflation failed\n";
    ( $dx->flush($buf) == Z_OK ) ? $out .= $buf : die "deflation failed\n";
}

sub gzip_faster_gzip_only
{
    $out = Gzip::Faster::gzip ($in);
}

splitline ();

cmpthese ($count, {
    'IO::Uncompress::Gunzip' => 'io_comp_gunzip_only ()',
    'Compress::Raw::Zlib::Inflate' => 'comp_raw_zlib_inf_only ()',
    'Gzip::Faster' => 'gzip_faster_gunzip_only ()',
});

sub io_comp_gunzip_only
{
    IO::Uncompress::Gunzip::gunzip \$out, \$round;
}

sub comp_raw_zlib_inf_only
{
    my $copy = $out;
    my $ix = Compress::Raw::Zlib::Inflate->new( -WindowBits => WANT_GZIP )
        or die "Cannot create a inflation stream\n";
    $_ == Z_OK or $_ == Z_STREAM_END or die "inflation failed: $_\n" for $ix->inflate($copy, $round);
}

sub gzip_faster_gunzip_only
{
    my $round = Gzip::Faster::gunzip ($out);
}

sub splitline
{
    print "-" x 50;
    print "\n";
}
