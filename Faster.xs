#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <zlib.h>

#include "gzip-faster-perl.c"

MODULE=Gzip::Faster PACKAGE=Gzip::Faster

PROTOTYPES: DISABLE

SV * gzip (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 1;
	gz.is_raw = 0;
	RETVAL = gzip_faster (& gz, plain);
OUTPUT:
	RETVAL

SV * gunzip (zipped)
	SV * zipped
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 1;
	gz.is_raw = 0;
	RETVAL = gunzip_faster (&gz, zipped);
OUTPUT:
	RETVAL

SV * deflate (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 0;
	RETVAL = gzip_faster (& gz, plain);
OUTPUT:
	RETVAL

SV * inflate (deflated)
	SV * deflated
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 0;
	RETVAL = gunzip_faster (& gz, deflated);
OUTPUT:
	RETVAL

SV * deflate_raw (plain)
	SV * plain
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 1;
	RETVAL = gzip_faster (& gz, plain);
OUTPUT:
	RETVAL

SV * inflate_raw (deflated)
	SV * deflated
PREINIT:
	gzip_faster_t gz;
CODE:
	gz.is_gzip = 0;
	gz.is_raw = 1;
	RETVAL = gunzip_faster (& gz, deflated);
OUTPUT:
	RETVAL
