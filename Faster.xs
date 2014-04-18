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
CODE:
	RETVAL = gzip_faster (plain);
OUTPUT:
	RETVAL

SV * gunzip (zipped)
	SV * zipped
CODE:
	RETVAL = gunzip_faster (zipped);
OUTPUT:
	RETVAL
