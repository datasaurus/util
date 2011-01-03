/*
   -	dyn_alloc.c --
   -		This file defines dynamic memory allocators. See dyn_alloc (3).
   -	
   .	Copyright (c) 2010 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.1 $ $Date: 2011/01/03 20:30:07 $
 */

#include <string.h>
#include <limits.h>
#include <errno.h>
#include "alloc.h"
#include "dyn_alloc.h"

void *dyn_alloc(void *base, size_t sz0, size_t offset, void *src, size_t len,
	size_t extra)
{
    void *b1 = NULL;
    long o;

    if ( !src || len == 0 ) {
	return base;
    }
    if ( offset > LONG_MAX ) {
	errno = EOVERFLOW;
	return NULL;
    }
    o = (long)offset;
    if ( offset + len <= sz0 ) {
	return memcpy((char *)base + o, src, len);
    }
    if ( (b1 = REALLOC(base, offset + len + extra)) ) {
	memcpy((char *)b1 + o, src, len);
    }
    return b1;
}
