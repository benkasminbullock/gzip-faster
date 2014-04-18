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

#define CHUNK 0x4000

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
    return plain;
}


