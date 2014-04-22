#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin;
use Test::More;
my $synopsis = "$FindBin::Bin/../examples/synopsis.pl";
ok (-f $synopsis);
my $status = system ("perl -I ../blib/lib -I ../blib/arch $synopsis");
is ($status, 0, "exit status ok");
done_testing ();
exit;
