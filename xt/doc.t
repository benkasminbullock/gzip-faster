#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use FindBin '$Bin';
use Test::More;
my $synopsis = "$Bin/../examples/synopsis.pl";
ok (-f $synopsis);
my $status = system ("perl -I ../blib/lib -I ../blib/arch $synopsis");
is ($status, 0, "exit status ok");
if (-f 'file.gz') {
    unlink 'file.gz';
}
done_testing ();
exit;
