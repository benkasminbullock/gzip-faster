=encoding UTF-8

=head1 NAME

Gzip::Faster - gzip and gunzip, without the fuss

=head1 SYNOPSIS

    use Gzip::Faster;
    my $gzipped = gzip ($input);
    my $roundtrip = gunzip ($gzipped);
    # $roundtrip is the same as $input

=head1 DESCRIPTION

This module compresses to and decompresses from the gzip format.

=head1 FUNCTIONS

=head2 gzip

    my $zipped = gzip ($stuff);

Compress C<$stuff>.

=head2 gunzip

    my $stuff = gunzip ($zipped);

Uncompress C<$zipped>. This will cause a fatal error if C<$zipped> is
not compressed.

=head1 PERFORMANCE

This section compares the performance of Gzip::Faster with
L<IO::Compress::Gzip> and L<IO::Uncompress::Gunzip>. Here is a
comparison of a round-trip:

                          Rate IO::Compress::Gzip       Gzip::Faster
    IO::Compress::Gzip  1199/s                 --               -91%
    Gzip::Faster       12800/s               968%                 --

Here is a comparison of gzip (compression) only:

                          Rate IO::Compress::Gzip       Gzip::Faster
    IO::Compress::Gzip  2355/s                 --               -87%
    Gzip::Faster       17582/s               647%                 --


Here is a comparison of gunzip (decompression) only:

                              Rate IO::Uncompress::Gunzip           Gzip::Faster
    IO::Uncompress::Gunzip  2739/s                     --                   -96%
    Gzip::Faster           67368/s                  2360%                     --

The test file is in "examples/benchmark.pl" in the distribution.

There is also a module called L<Compress::Raw::Zlib> which offers
access to zlib itself. It may offer improved performance, however I
have not figured out what it does yet. Its documented way of making a
gzip compressed object returns something I cannot understand so I was
unable to include it in the benchmark.

=head1 BUGS

The module includes functionality to round-trip various Perl flags. I
applied this to preserving Perl's "utf8" flag. However, the mechanism
I used trips a browser bug in the Firefox web browser where it
produces a content encoding error message. Thus this functionality is
disabled.

=head1 AUTHOR, COPYRIGHT AND LICENCE

Ben Bullock <bkb@cpan.org>. Copyright (C) 2014 Ben Bullock. This
software may be used, modified, distributed under the same licence as
Perl itself.

=cut

package Gzip::Faster;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw/gzip gunzip/;
use warnings;
use strict;
use Carp;
our $VERSION = 0.03;
require XSLoader;
XSLoader::load ('Gzip::Faster', $VERSION);
1;
