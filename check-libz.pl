#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
BEGIN {
    use FindBin '$Bin';
    use lib "$Bin/inc";
    use Devel::CheckLib;
};
#my $verbose = 1;

if (! -f "$Bin/inc/Devel/CheckLib.pm") {
    msg ('-' x 50);
    msg ("There should be a file $Bin/inc/Devel/CheckLib.pm but I cannot find it.");
    msg ("This script needs the above to function, so I have to give up.");
    msg ('-' x 50);
    exit 1;
}

msg ('-' x 50);
msg ("I will try to locate libz on your computer.");
msg ("I am now running Devel::CheckLib to find libz.");
msg ("The following is the output from Devel::CheckLib.");
msg ('-' x 50);
my $ok = check_lib (lib => 'z', header => 'zlib.h', debug => 1);
msg ('-' x 50);
if ($ok) {
    msg ("libz was found by Devel::CheckLib. Please run Makefile.PL as usual.");
    exit;
}
else {
    msg ("libz could not be found by Devel::CheckLib.");
}

exit;

sub msg
{
#    if ($verbose) {
#	if ($debug) {
	my (undef, $file, $line) = caller ();
	print "$file:$line: @_\n";
#    }
}
