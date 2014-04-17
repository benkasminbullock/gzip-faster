#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "gzip-faster-perl.c"

typedef gzip_faster_t * Gzip__Faster;

MODULE=Gzip::Faster PACKAGE=Gzip::Faster

PROTOTYPES: DISABLE

BOOT:
	/* Gzip__Faster_error_handler = perl_error_handler; */

