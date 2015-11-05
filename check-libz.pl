#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
use POSIX 'uname';
BEGIN {
    use FindBin '$Bin';
    use lib "$Bin/inc";
    use Devel::CheckLib;
};
#my $verbose = 1;

# Flush output so that we can capture the subprocess stderr correctly.
$| = 1;

if (! -f "$Bin/inc/Devel/CheckLib.pm") {
    line ();
    msg ("There should be a file $Bin/inc/Devel/CheckLib.pm but I cannot find it.");
    msg ("This script needs the above to function, so I have to give up.");
    line ();
    exit 1;
}
line ();
my @info = uname ();
msg ("Your system info: @info");
line ();
msg ("I will try to locate libz on your computer.");
msg ("I am now running Devel::CheckLib to find libz.");
msg ("The following is the output from Devel::CheckLib.");
line ();
my $ok = check_lib (lib => 'z', header => 'zlib.h', debug => 1);
line ();
if ($ok) {
    msg ("libz was found by Devel::CheckLib.");
    msg (" Please run Makefile.PL as usual.");
    line ();
    exit;
}
else {
    msg ("libz could not be found by Devel::CheckLib.");
}

exit;

sub line
{
    my (undef, $file, $line) = caller ();
    print "$file:$line: ", ('-' x 50), "\n";
}

sub msg
{
#    if ($verbose) {
#	if ($debug) {
	my (undef, $file, $line) = caller ();
	print "$file:$line: @_\n";
#    }
}
