#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <zlib.h>

#include "gzip-faster-perl.c"

typedef gzip_faster_t * Gzip__Faster;

MODULE=Gzip::Faster PACKAGE=Gzip::Faster

PROTOTYPES: DISABLE

SV * gzip (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.in = plain;
	gz.is_gzip = 1;
	gz.is_raw = 0;
	RETVAL = gzip_faster (& gz);
OUTPUT:
	RETVAL

SV * gunzip (zipped)
	SV * zipped
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 1;
	gz.is_raw = 0;
	gz.in = zipped;
	RETVAL = gunzip_faster (&gz);
OUTPUT:
	RETVAL

SV * deflate (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.in = plain;
	gz.is_gzip = 0;
	gz.is_raw = 0;
	RETVAL = gzip_faster (& gz);
OUTPUT:
	RETVAL

SV * inflate (deflated)
	SV * deflated
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 0;
	gz.in = deflated;
	RETVAL = gunzip_faster (& gz);
OUTPUT:
	RETVAL

SV * deflate_raw (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.in = plain;
	gz.is_gzip = 0;
	gz.is_raw = 1;
	RETVAL = gzip_faster (& gz);
OUTPUT:
	RETVAL

SV * inflate_raw (deflated)
	SV * deflated
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 1;
	gz.in = deflated;
	RETVAL = gunzip_faster (& gz);
OUTPUT:
	RETVAL

Gzip::Faster
new (class)
    	const char * class;
CODE:
	Newxz (RETVAL, 1, gzip_faster_t);
	RETVAL->is_gzip = 1;
	RETVAL->is_raw = 0;
OUTPUT:
	RETVAL

void
DESTROY (gf)
	Gzip::Faster gf
CODE:
	Safefree (gf);

SV *
zip (gf, plain)
	Gzip::Faster gf
	SV * plain
CODE:
	gf->in = plain;
	RETVAL = gzip_faster (gf);
OUTPUT:
	RETVAL

SV *
unzip (gf, deflated)
	Gzip::Faster gf
	SV * deflated
CODE:
	gf->in = deflated;
	RETVAL = gunzip_faster (gf);
OUTPUT:
	RETVAL

void
copy_perl_flags (gf, on_off)
	Gzip::Faster gf
	SV * on_off
CODE:
	gf->copy_perl_flags = SvTRUE (on_off);
