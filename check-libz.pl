#!/usr/bin/env perl

# This is a script for debugging installation problems for the
# underlying compression library zlib. Instructions for running this
# script may be found in lib/Gzip/Faster.pod. It's easy to read it
# like this:
#
# perldoc lib/Gzip/Faster.pod
#
# This script is intended to be run by a user to analyze the problem
# with installation on their computer. The script will be extended as
# various issues are found and resolved. Please use this script to
# communicate with the module author at <bkb@cpan.org>.

use warnings;
use strict;
use utf8;
use POSIX 'uname';
BEGIN {
    use FindBin '$Bin';
    use lib "$Bin/inc";
    use Devel::CheckLib;
};

# Flush output so that we can capture the subprocess stderr correctly.

$| = 1;

# Make 100% sure that the user has run the script in the correct
# directory.

if (! -f "$Bin/inc/Devel/CheckLib.pm") {
    line ();
    msg ("There should be a file $Bin/inc/Devel/CheckLib.pm but I cannot find it.");
    msg ("This script needs the above to function, so I have to give up.");
    line ();
    exit 1;
}

# Get the user's operating system.

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

# All of this program's output goes via line and msg. Their
# "file:line:" format ensures that we can distinguish this program's
# output from the Devel::CheckLib output or other subprocess output.

sub line
{
    my (undef, $file, $line) = caller ();
    print "$file:$line: ", ('-' x 50), "\n";
}

sub msg
{
    my (undef, $file, $line) = caller ();
    print "$file:$line: @_\n";
}
