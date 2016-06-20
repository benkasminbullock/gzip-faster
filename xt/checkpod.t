use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
use Perl::Build::Pod ':all';
my $filepath = "$Bin/../lib/Gzip/Faster.pod";
my $errors = pod_checker ($filepath);
ok (scalar (@$errors) == 0, "No errors");
ok (pod_no_cut ($filepath));
ok (pod_encoding_ok ($filepath));
done_testing ();
