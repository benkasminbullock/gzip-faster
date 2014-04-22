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
    FILTERS => {
        xtidy => [
            \& xtidy,
            0,
        ],
    },
    INCLUDE_PATH => [
	"$FindBin::Bin/examples",
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
chmod 0644, $pod;
$tt->process ("$pod.tmpl", \%vars, $pod) or die '' . $tt->error ();
chmod 0444, $pod;
exit;

sub xtidy
{
    my ($text) = @_;

    # Remove shebang.

    $text =~ s/^#!.*$//m;

    # Remove sobvious.

    $text =~ s/use\s+(strict|warnings);\s+//g;

    # Replace tabs with spaces.

    $text =~ s/ {0,7}\t/        /g;

    # Add indentation.

    $text =~ s/^(.*)/    $1/gm;

    return $text;
}
