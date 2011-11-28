/*
   -	dyn_alloc.c --
   -		This file defines dynamic memory allocators. See dyn_alloc (3).
   -	
   .	Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
   .	
   .	Redistribution and use in source and binary forms, with or without
   .	modification, are permitted provided that the following conditions
   .	are met:
   .	
   .	    * Redistributions of source code must retain the above copyright
   .	    notice, this list of conditions and the following disclaimer.
   .
   .	    * Redistributions in binary form must reproduce the above copyright
   .	    notice, this list of conditions and the following disclaimer in the
   .	    documentation and/or other materials provided with the distribution.
   .	
   .	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   .	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   .	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   .	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   .	HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   .	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
   .	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   .	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   .	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   .	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   .	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.3 $ $Date: 2011/01/03 21:03:19 $
 */

#include <string.h>
#include <limits.h>
#include <errno.h>
#include "alloc.h"
#include "dyn_alloc.h"

void *dyn_alloc(void *base, size_t *sz_p, size_t offset, void *src, size_t len,
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
    if ( offset + len <= *sz_p ) {
	return memcpy((char *)base + o, src, len);
    }
    if ( (b1 = REALLOC(base, offset + len + extra)) ) {
	*sz_p = offset + len + extra;
	memcpy((char *)b1 + o, src, len);
    }
    return b1;
}
