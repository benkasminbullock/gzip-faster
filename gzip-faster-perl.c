/* Buffer size for inflate/deflate. */

#define CHUNK 0x4000

/* These are magic numbers for zlib, please refer to
   "/usr/include/zlib.h" for the details. */

#define windowBits 15
#define DEFLATE_ENABLE_ZLIB_GZIP 16
#define INFLATE_ENABLE_ZLIB_GZIP 32

#define CALL_ZLIB(x)						 \
	zlib_status = x;					 \
	if (zlib_status < 0) {					 \
	    deflateEnd (& strm);				 \
	    croak ("zlib call %s returned error status %d",	 \
		   #x, zlib_status);				 \
	}							 \

typedef struct
{
    /* Gzip, not deflate or inflate. */
    unsigned int is_gzip : 1;
    /* "Raw" inflate or deflate without adler32 check. */
    unsigned int is_raw : 1;
}
gzip_faster_t;

/* The following code works perfectly OK, but setting the "extra"
   field in a gzip header trips bugs in some browsers (FireFox to be
   precise, Internet Explorer, Opera, and Chrome have no problem with
   this). */

/* #define COPY_PERL */

#ifdef COPY_PERL

/* See "http://www.gzip.org/zlib/rfc-gzip.html". */

#define GZIP_PERL_ID "GF\1\0"
#define GZIP_PERL_ID_LENGTH 4

/* Perl stuff. */

#define GZIP_PERL_LENGTH 1
#define EXTRA_LENGTH GZIP_PERL_ID_LENGTH + GZIP_PERL_LENGTH
#define GZIP_PERL_UTF8 (1<<0)
/* Add more Perl flags here like 

#define SOMETHING (1<<1)

etc. */

#endif /* def COPY_PERL */

static SV *
gzip_faster (gzip_faster_t * gz, SV * plain)
{
    SV * zipped;
    z_stream strm;
    char * plain_char;
    STRLEN plain_length;
    int level;
    int zlib_status;
    /* This holds the stuff. */
    unsigned char out_buffer[CHUNK];
    /* windowBits, adjusted for monkey business. */
    int wb;

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
    wb = windowBits;
    if (gz->is_gzip) {
	if (gz->is_raw) {
	    croak ("Raw deflate and gzip are incompatible");
	}
	wb += DEFLATE_ENABLE_ZLIB_GZIP;
    }
    else {
	if (gz->is_raw) {
	    wb = -wb;
	}
    }
    CALL_ZLIB (deflateInit2 (& strm, level, Z_DEFLATED, wb, 8,
			     Z_DEFAULT_STRATEGY));

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

    zipped = 0;

    do {
	unsigned int have;
	strm.avail_out = CHUNK;
	strm.next_out = out_buffer;
	zlib_status = deflate (& strm, Z_FINISH);
	switch (zlib_status) {
	case Z_OK:
	case Z_STREAM_END:
	case Z_BUF_ERROR:
	    /* Keep on chugging. */
	    break;

	case Z_STREAM_ERROR:
	    deflateEnd (& strm);
	    /* This is supposed to never happen, but just in case it
	       does. */
	    croak ("Z_STREAM_ERROR from zlib during deflate");

	default:
	    deflateEnd (& strm);
	    croak ("Unknown status %d from deflate", zlib_status);
	    break;
	}
	/* The number of bytes we "have". */
	have = CHUNK - strm.avail_out;
	if (! zipped) {
	    zipped = newSVpv ((const char *) out_buffer, have);
	}
	else {
	    sv_catpvn (zipped, (const char *) out_buffer, have);
	}
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
gunzip_faster (gzip_faster_t * gz, SV * zipped)
{
    SV * plain;

    z_stream strm;
    char * zipped_char;
    STRLEN zipped_length;
    /* We are writing the unzipped stuff into this before copying it
       to the end of "zipped". */
    unsigned char out_buffer[CHUNK];
    /* The message from zlib. */
    int zlib_status;
    int wb;

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

    wb = windowBits;
    if (gz->is_gzip) {
	if (gz->is_raw) {
	    croak ("Raw deflate and gzip are incompatible");
	}
	wb += INFLATE_ENABLE_ZLIB_GZIP;
    }
    else {
	if (gz->is_raw) {
	    wb = -wb;
	}
    }
    CALL_ZLIB (inflateInit2 (& strm, wb));

#ifdef COPY_PERL

    header.extra = extra;
    header.extra_max = EXTRA_LENGTH;
    inflateGetHeader (& strm, & header);

#endif

    plain = 0;

    do {
	unsigned int have;
	strm.avail_out = CHUNK;
	strm.next_out = out_buffer;
	zlib_status = inflate (& strm, Z_FINISH);
	switch (zlib_status) {
	case Z_OK:
	case Z_STREAM_END:
	case Z_BUF_ERROR:
	    break;

	case Z_DATA_ERROR:
	    inflateEnd (& strm);
	    croak ("Data input to inflate is not in libz format");
	    break;

	case Z_MEM_ERROR:
	    inflateEnd (& strm);
	    croak ("Out of memory during inflate");

	case Z_STREAM_ERROR:
	    inflateEnd (& strm);
	    croak ("Internal error in zlib");

	default:
	    inflateEnd (& strm);
	    croak ("Unknown status %d from inflate", zlib_status);
	    break;
	}
	have = CHUNK - strm.avail_out;
	if (! plain) {
	    plain = newSVpv ((const char *) out_buffer, have);
	}
	else {
	    sv_catpvn (plain, (const char *) out_buffer, have);
	}
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
