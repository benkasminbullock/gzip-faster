use strict;
use warnings;
use ExtUtils::MakeMaker;

use lib qw(inc);
use Devel::CheckLib;

check_lib_or_exit(lib => 'z', header => 'zlib.h');

my $pm = 'lib/Gzip/Faster.pm';
my $pod = 'lib/Gzip/Faster.pod';
my $github = 'github.com/benkasminbullock/gzip-faster';
my $repo = "https://$github";

WriteMakefile (
    NAME => 'Gzip::Faster',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pod,
    AUTHOR => 'Ben Bullock <bkb@cpan.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
    },
    META_MERGE => {
	'meta-spec' => {
	    version => 2,
	},
        resources => {
            repository => {
		type => 'git',
		url => "git://$github.git",
		web => $repo,
	    },
            bugtracker => {
		web => "$repo/issues",
	    },
#	    homepage => 'http://',
        },
    },
    MIN_PERL_VERSION => '5.006001',
    OBJECT => 'Faster.o',
    LIBS => '-lz',
#    OPTIMIZE => '-Wall -g -O',
);
