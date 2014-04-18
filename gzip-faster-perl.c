/* Buffer size for inflate/deflate. */

#define CHUNK 0x4000

/* These are magic numbers for zlib, please refer to
   "/usr/include/zlib.h" for the details. */

#define windowBits 15
#define DEFLATE_ENABLE_ZLIB_GZIP 16
#define INFLATE_ENABLE_ZLIB_GZIP 32

#define CALL_ZLIB(x)						 \
	zlib_status = x;					 \
	if (zlib_status == -3) {				 \
	    croak ("input data is not gzipped");		 \
	}							 \
	if (zlib_status < 0) {					 \
	    croak ("zlib call %s returned a bad status %d",	 \
		   #x, zlib_status);				 \
	}							 \

#define COPY_PERL

#ifdef COPY_PERL

/* See "http://www.gzip.org/zlib/rfc-gzip.html". */

#define GZIP_PERL_ID "GF\1\0"
#define GZIP_PERL_ID_LENGTH 4

/* Perl stuff. */

#define GZIP_PERL_LENGTH 1
#define EXTRA_LENGTH GZIP_PERL_ID_LENGTH + GZIP_PERL_LENGTH
#define GZIP_PERL_UTF8 (1<<0)

#endif /* def COPY_PERL */

static SV *
gzip_faster (SV * plain)
{
    SV * zipped;
    z_stream strm;
    char * plain_char;
    unsigned plain_length;
    int level;
    int zlib_status;
    /* This holds the stuff. */
    unsigned char out_buffer[CHUNK];

#ifdef COPY_PERL

    gz_header header = {0};
    unsigned char extra[EXTRA_LENGTH];

#endif /* COPY_PERL */

    plain_char = SvPV (plain, plain_length);

    if (plain_length == 0) {
	return & PL_sv_undef;
    }

    strm.next_in = (unsigned char *) plain_char;
    strm.avail_in = plain_length;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;

    level = Z_DEFAULT_COMPRESSION;
    CALL_ZLIB (deflateInit2 (& strm, level, Z_DEFLATED,
			     windowBits + DEFLATE_ENABLE_ZLIB_GZIP,
			     8, Z_DEFAULT_STRATEGY));

#ifdef COPY_PERL
    memcpy (extra, GZIP_PERL_ID, GZIP_PERL_ID_LENGTH);
    extra[GZIP_PERL_ID_LENGTH] = 0;
    if (SvUTF8 (plain)) {
	extra[GZIP_PERL_ID_LENGTH] |= GZIP_PERL_UTF8;
    }
    header.extra = extra;
    header.extra_len = EXTRA_LENGTH;
    CALL_ZLIB (deflateSetHeader (& strm, & header));
#endif /* def COPY_PERL */
    /* newSV (0) gets us "uninitialized in subroutine entry" stuff. */

    zipped = newSVpv ("", 0);

    do {
	unsigned int have;
	strm.avail_out = CHUNK;
	strm.next_out = out_buffer;
	CALL_ZLIB (deflate (& strm, Z_FINISH));
	have = CHUNK - strm.avail_out;
	sv_catpvn (zipped, (const char *) out_buffer, have);
    }
    while (strm.avail_out == 0);
    if (strm.avail_in != 0) {
	croak ("Zlib did not finish processing the string");
    }
    if (zlib_status != Z_STREAM_END) {
	croak ("Zlib did not come to the end of the string");
    }
    deflateEnd (& strm);
    return zipped;
}

static SV *
gunzip_faster (SV * zipped)
{
    SV * plain;

    z_stream strm;
    char * zipped_char;
    unsigned zipped_length;
    /* We are writing the unzipped stuff into this before copying it
       to the end of "zipped". */
    unsigned char out_buffer[CHUNK];
    /* The message from zlib. */
    int zlib_status;

#ifdef COPY_PERL

    gz_header header;
    unsigned char extra[EXTRA_LENGTH];

#endif /* def COPY_PERL */

    zipped_char = SvPV (zipped, zipped_length);

    if (zipped_length == 0) {
	return & PL_sv_undef;
    }

    strm.next_in = (unsigned char *) zipped_char;
    strm.avail_in = zipped_length;

    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;

    CALL_ZLIB (inflateInit2 (& strm, windowBits + INFLATE_ENABLE_ZLIB_GZIP));

#ifdef COPY_PERL

    header.extra = extra;
    header.extra_max = EXTRA_LENGTH;
    inflateGetHeader (& strm, & header);

#endif

    /* newSV (0) gets us "uninitialized in subroutine entry" stuff. */

    plain = newSVpv ("", 0);

    do {
	unsigned int have;
	strm.avail_out = CHUNK;
	strm.next_out = out_buffer;
	CALL_ZLIB (inflate (& strm, Z_FINISH));
	have = CHUNK - strm.avail_out;
	sv_catpvn (plain, (const char *) out_buffer, have);
    }
    while (strm.avail_out == 0);
    if (strm.avail_in != 0) {
	croak ("Zlib did not finish processing the string");
    }
    if (zlib_status != Z_STREAM_END) {
	croak ("Zlib did not come to the end of the string");
    }
    inflateEnd (& strm);

#ifdef COPY_PERL

    if (strncmp ((const char *) header.extra, GZIP_PERL_ID,
		 GZIP_PERL_ID_LENGTH) == 0) {
	unsigned is_utf8;
	is_utf8 = header.extra[GZIP_PERL_ID_LENGTH] & GZIP_PERL_UTF8;
	if (is_utf8) {
	    SvUTF8_on (plain);
	}
    }

#endif /* def COPY_PERL */

    return plain;
}


