/*
   -	dyn_alloc.c --
   -		This file defines dynamic memory allocators.
   -	
   .	Copyright (c) 2010 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: $ $Date: $
 */

#include <string.h>
#include <limits.h>
#include <errno.h>
#include "alloc.h"
#include "dyn_alloc.h"

/*
   Copy len bytes from src to base + offset. base should have space for sz0
   bytes. If offset is too large for pointer arithmetic, the function returns
   NULL with errno will be set to EOVERFLOW. If offset + len <= sz0, the
   function just copies the bytes and returns base. If offset + len > sz0, the
   function attempts to change the allocation at base to offset + len + extra
   bytes with a call to REALLOC. If REALLOC succeeds, it copies the bytes to
   the possibly new address.  If REALLOC is called, this function returns the
   return value from REALLOC, which might also set errno.
 */

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
