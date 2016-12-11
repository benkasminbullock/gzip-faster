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
	    deflateEnd (& gf->strm);				 \
	    croak ("zlib call %s returned error status %d",	 \
		   #x, zlib_status);				 \
	}							 \

typedef struct
{
    /* Input. */
    SV * in;
    char * in_char;
    STRLEN in_length;
    /* Compression structure. */
    z_stream strm;
    /* Compression level. */
    int level;
    /* This holds the stuff. */
    unsigned char out_buffer[CHUNK];
    /* windowBits, adjusted for monkey business. */
    int wb;
    /* Optional file name for gzip format.  This can only take values
       for user-visible objects. */
    SV * file_name;
    /* Gzip, not deflate or inflate. */
    unsigned int is_gzip : 1;
    /* "Raw" inflate or deflate without adler32 check. */
    unsigned int is_raw : 1;
    /* Copy Perl flags like UTF8 flag? */
    unsigned int copy_perl_flags : 1;
    /* User can see this object? */
    unsigned int user_object : 1;
}
gzip_faster_t;

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

static void
gf_set_up (gzip_faster_t * gf)
{
    /* Extract the information from "gf->in". */
    gf->in_char = SvPV (gf->in, gf->in_length);
    gf->strm.next_in = (unsigned char *) gf->in_char;
    gf->strm.avail_in = gf->in_length;
    gf->strm.zalloc = Z_NULL;
    gf->strm.zfree = Z_NULL;
    gf->strm.opaque = Z_NULL;
    if (! gf->user_object) {
	gf->level = Z_DEFAULT_COMPRESSION;
    }
    gf->wb = windowBits;
}

static void
gf_delete_file_name (gzip_faster_t * gf)
{
    if (! gf->user_object) {
	croak ("THIS IS NOT A USER OBJECT");
    }
    if (gf->file_name) {
	SvREFCNT_dec (gf->file_name);
	gf->file_name = 0;
    }
}

static void
gf_set_file_name (gzip_faster_t * gf, SV * file_name)
{
    if (! gf->user_object) {
	croak ("THIS IS NOT A USER OBJECT");
    }
    if (gf->file_name) {
	gf_delete_file_name (gf);
    }
    SvREFCNT_inc (file_name);
    gf->file_name = file_name;
}

static SV *
gf_get_file_name (gzip_faster_t * gf)
{
    if (! gf->user_object) {
	croak ("THIS IS NOT A USER OBJECT");
    }
    if (gf->file_name) {
	return gf->file_name;
    }
    return & PL_sv_undef;
}

static SV *
gzip_faster (gzip_faster_t * gf)
{
    /* The output. */
    SV * zipped;
    /* The message from zlib. */
    int zlib_status;

    gf_set_up (gf);
    if (gf->in_length == 0) {
	return & PL_sv_undef;
    }

    if (gf->is_gzip) {
	if (gf->is_raw) {
	    croak ("Raw deflate and gzip are incompatible");
	}
	gf->wb += DEFLATE_ENABLE_ZLIB_GZIP;
    }
    else {
	if (gf->is_raw) {
	    gf->wb = -gf->wb;
	}
    }
    CALL_ZLIB (deflateInit2 (& gf->strm, gf->level, Z_DEFLATED,
			     gf->wb, 8,
			     Z_DEFAULT_STRATEGY));

    if (gf->user_object) {
	if (gf->is_gzip) {
	    gz_header header = {0};
	    unsigned char extra[EXTRA_LENGTH];
	    /* Have at least one of the fields in the header been set? */
	    int set_header;
	    set_header = 0;
	    if (gf->copy_perl_flags) {
		memcpy (extra, GZIP_PERL_ID, GZIP_PERL_ID_LENGTH);
		extra[GZIP_PERL_ID_LENGTH] = 0;
		if (SvUTF8 (gf->in)) {
		    extra[GZIP_PERL_ID_LENGTH] |= GZIP_PERL_UTF8;
		}
		header.extra = extra;
		header.extra_len = EXTRA_LENGTH;
		set_header++;
	    }
	    if (gf->file_name) {
		char * fn;
		fn = SvPV_nolen (gf->file_name);
		header.name = (Bytef *) fn;
		set_header++;
	    }
	    if (set_header) {
		CALL_ZLIB (deflateSetHeader (& gf->strm, & header));
	    }
	}
	else {
	    if (gf->copy_perl_flags) {
		warn ("wrong format: perl flags not copied: use gzip_format(1)");
	    }
	    if (gf->file_name) {
		warn ("wrong format: file name ignored: use gzip_format(1)");
	    }
	}
    }
    zipped = 0;

    do {
	unsigned int have;
	gf->strm.avail_out = CHUNK;
	gf->strm.next_out = gf->out_buffer;
	zlib_status = deflate (& gf->strm, Z_FINISH);
	switch (zlib_status) {
	case Z_OK:
	case Z_STREAM_END:
	case Z_BUF_ERROR:
	    /* Keep on chugging. */
	    break;

	case Z_STREAM_ERROR:
	    deflateEnd (& gf->strm);
	    /* This is supposed to never happen, but just in case it
	       does. */
	    croak ("Z_STREAM_ERROR from zlib during deflate");

	default:
	    deflateEnd (& gf->strm);
	    croak ("Unknown status %d from deflate", zlib_status);
	    break;
	}
	/* The number of bytes we "have". */
	have = CHUNK - gf->strm.avail_out;
	if (! zipped) {
	    zipped = newSVpv ((const char *) gf->out_buffer, have);
	}
	else {
	    sv_catpvn (zipped, (const char *) gf->out_buffer, have);
	}
    }
    while (gf->strm.avail_out == 0);
    if (gf->strm.avail_in != 0) {
	croak ("Zlib did not finish processing the string");
    }
    if (zlib_status != Z_STREAM_END) {
	croak ("Zlib did not come to the end of the string");
    }
    deflateEnd (& gf->strm);
    if (gf->user_object) {
	if (gf->file_name) {
	    gf_delete_file_name (gf);
	}
    }
    return zipped;
}

#define GF_FILE_NAME_MAX 0x400

static SV *
gunzip_faster (gzip_faster_t * gf)
{
    SV * plain;

    /* The message from zlib. */
    int zlib_status;

    gz_header header;
    unsigned char name[GF_FILE_NAME_MAX];
    unsigned char extra[EXTRA_LENGTH];

    gf_set_up (gf);

    if (gf->is_gzip) {
	if (gf->is_raw) {
	    croak ("Raw deflate and gzip are incompatible");
	}
	gf->wb += INFLATE_ENABLE_ZLIB_GZIP;
    }
    else {
	if (gf->is_raw) {
	    gf->wb = -gf->wb;
	}
    }
    CALL_ZLIB (inflateInit2 (& gf->strm, gf->wb));
    if (gf->user_object) {
	if (gf->is_gzip) {
	    if (gf->copy_perl_flags) {
		header.extra = extra;
		header.extra_max = EXTRA_LENGTH;
	    }
	    if (gf->file_name) {
		gf_delete_file_name (gf);
	    }
	    header.name = name;
	    header.name_max = GF_FILE_NAME_MAX;
	    inflateGetHeader (& gf->strm, & header);
	}
    }
    plain = 0;

    do {
	unsigned int have;
	gf->strm.avail_out = CHUNK;
	gf->strm.next_out = gf->out_buffer;
	zlib_status = inflate (& gf->strm, Z_FINISH);
	switch (zlib_status) {
	case Z_OK:
	case Z_STREAM_END:
	case Z_BUF_ERROR:
	    break;

	case Z_DATA_ERROR:
	    inflateEnd (& gf->strm);
	    croak ("Data input to inflate is not in libz format");
	    break;

	case Z_MEM_ERROR:
	    inflateEnd (& gf->strm);
	    croak ("Out of memory during inflate");

	case Z_STREAM_ERROR:
	    inflateEnd (& gf->strm);
	    croak ("Internal error in zlib");

	default:
	    inflateEnd (& gf->strm);
	    croak ("Unknown status %d from inflate", zlib_status);
	    break;
	}
	have = CHUNK - gf->strm.avail_out;
	if (! plain) {
	    plain = newSVpv ((const char *) gf->out_buffer, have);
	}
	else {
	    sv_catpvn (plain, (const char *) gf->out_buffer, have);
	}
    }
    while (gf->strm.avail_out == 0);
    if (gf->strm.avail_in != 0) {
	croak ("Zlib did not finish processing the string");
    }
    if (zlib_status != Z_STREAM_END) {
	croak ("Zlib did not come to the end of the string");
    }
    inflateEnd (& gf->strm);
    if (gf->user_object && gf->is_gzip && header.done == 1) {
	if (gf->copy_perl_flags) {
	    if (strncmp ((const char *) header.extra, GZIP_PERL_ID,
			 GZIP_PERL_ID_LENGTH) == 0) {
		unsigned is_utf8;
		is_utf8 = header.extra[GZIP_PERL_ID_LENGTH] & GZIP_PERL_UTF8;
		if (is_utf8) {
		    SvUTF8_on (plain);
		}
	    }
	}
	if (header.name && header.name_max > 0) {
	    gf->file_name = newSVpv ((const char *) header.name, 0);
	    SvREFCNT_inc (gf->file_name);
	}
	else {
	    gf_delete_file_name (gf);
	}
    }
    return plain;
}

static void
new_user_object (gzip_faster_t * gf)
{
    gf->file_name = 0;
    gf->is_gzip = 1;
    gf->is_raw = 0;
    gf->user_object = 1;
    gf->level = Z_DEFAULT_COMPRESSION;
}

static void
set_compression_level (gzip_faster_t * gf, int level)
{
    if (level < Z_NO_COMPRESSION) {
	warn ("Cannot set compression level to less than %d",
	      Z_NO_COMPRESSION);
	gf->level = Z_NO_COMPRESSION;
    }
    else if (level > Z_BEST_COMPRESSION) {
	warn ("Cannot set compression level to more than %d",
	      Z_BEST_COMPRESSION);
	gf->level = Z_BEST_COMPRESSION;
    }
    else {
	gf->level = level;
    }
}
