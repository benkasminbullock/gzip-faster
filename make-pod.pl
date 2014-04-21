#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use FindBin;

my $pod = "$FindBin::Bin/lib/Gzip/Faster.pod";

# Template toolkit variable holder

my %vars;

my $tt = Template->new (
    ABSOLUTE => 1,
    INCLUDE_PATH => [
    ],
);

my $edir = "$FindBin::Bin/examples";
my $efile = "$edir/benchmarks.output";
if (! -f $efile || -M $efile > -M "$edir/benchmark.pl") {
    die "Rebuild benchmarks file '$efile'";
}
open my $input, "<", $efile or die $!;
my $e;
{
local $/;
$e = <$input>;
}
close $input or die $!;
my @fields = qw/versions load round gzip gunzip/;
@vars{@fields} = split /-{50}/, $e;
$tt->process ("$pod.tmpl", \%vars, $pod) or die '' . $tt->error ();

