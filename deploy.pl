#!/home/ben/software/install/bin/perl
use Z;
use Perl::Build 'get_info';
my $info = get_info (base => $Bin);
if (! $info) { die; }
my $v = $info->{version};
if (! $v) { die; }
my $n = $info->{name};
if (! $n) {die; }
chdir $Bin or die $!;
do_system ("./build.pl -p");
my $tf = "$n-$v.tar.gz";
if (! -f $tf) { die; }
do_system ("faq-module-build.pl $tf");
do_system ("lemoda-module-build.pl $tf");
do_system ("kanji-module-build.pl $tf");
do_system ("nxmnpg-module-build.pl $tf");
do_system ("./build.pl -i");
