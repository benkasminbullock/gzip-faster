#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Template;
use FindBin '$Bin';
use Path::Tiny;
use Perl::Build 'get_version';

my $pod = "$Bin/lib/Gzip/Faster.pod";

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
    if (! -f $file || -M $file > -M "$edir/benchmark.pl") {
	die "Rebuild benchmarks file '$file'";
    }
    my $p = path ($file);
    my $input = $p->slurp ();
    my @stuff = split /-{50}/, $input;
    for my $field (@fields) {
	my $n = shift @stuff;
#	print "$n\n";
	$vars{$type}{$field} = $n;
    }
}
$vars{version} = get_version ();
chmod 0644, $pod;
$tt->process ("$pod.tmpl", \%vars, $pod) or die '' . $tt->error ();
chmod 0444, $pod;
exit;

sub xtidy
{
    my ($text) = @_;

    # Remove shebang.

    $text =~ s/^#!.*$//m;

    # Remove comments

    $text =~ s/^#.*$//m;

    # Remove random generator

    $text =~ s/^my \$input.*$//m;

    # Remove sobvious.

    $text =~ s/use\s+(strict|warnings);\s+//g;

    # Replace tabs with spaces.

    $text =~ s/ {0,7}\t/        /g;

    # Add indentation.

    $text =~ s/^(.*)/    $1/gm;

    return $text;
}
