=encoding UTF-8

=head1 NAME

Gzip::Faster - gzip and gunzip, without the fuss

=head1 SYNOPSIS

    use Gzip::Faster;

=head1 DESCRIPTION

This is just like all those other modules which gzip and gunzip
things, except not nearly as complicated.

=head1 FUNCTIONS

=head2 gzip

    my $zipped = gzip ($stuff);

Compress C<$stuff> like a boss.

=head2 gunzip

    my $stuff = gunzip ($zipped);

Uncompress it. This will cause a fatal error if C<$zipped> is not
compressed.

=head1 COPYRIGHT AND LICENCE

This stofware may be used, modified, distributed under the same
licence as Perl itself.

=cut

package Gzip::Faster;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw/gzip gunzip/;
use warnings;
use strict;
use Carp;
our $VERSION = 0.01;
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);
1;
