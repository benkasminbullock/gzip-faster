#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use FindBin '$Bin';
use Path::Tiny;
use Perl::Build qw/get_info get_commit/;
use Perl::Build::Pod ':all';

make_examples ("$Bin/examples", undef, undef);

my $pod = "$Bin/lib/Gzip/Faster.pod";
my $c = "$Bin/gzip-faster-perl.c";
my $xs = "$Bin/Faster.xs";

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
	"/home/ben/projects/Perl-Build/lib/Perl/Build/templates",
    ],
    STRICT => 1,
);

my $edir = "$Bin/bench";
my @fields = qw/versions size load round gzip gunzip/;
for my $type (qw/short long/) {
    my $file = "$edir/$type.output";
    if (! -f $file) {
	die "Rebuild benchmarks file '$file'";
    }
#    if (-M $file > -M "$edir/benchmark.pl") {
#	warn "Outdated benchmarks file '$file'";
#    }
    my $p = path ($file);
    my $input = $p->slurp ();
    my @stuff = split /-{50}/, $input;
    for my $field (@fields) {
	my $n = shift @stuff;
#	print "$n\n";
	$vars{$type}{$field} = $n;
    }
}
$vars{info} = get_info ();
$vars{commit} = get_commit ();
chmod 0644, $pod;
$tt->process ("$pod.tmpl", \%vars, $pod) or die '' . $tt->error ();
chmod 0444, $pod;
exit;

