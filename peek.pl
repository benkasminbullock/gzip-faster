#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Devel::Peek;
use Gzip::Faster;
my $z = gzip ('pals that have sex');
Dump ($z);
my $q = $z;
Dump ($q);

