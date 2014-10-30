/*
   -	alloc2f.c --
   -		This file defines functions that allocate
   -		2-dimensional arrays of floating point values.
   -		See alloc2f (3).
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
   .	$Revision: 1.14 $ $Date: 2013/02/20 18:40:25 $
 */

#include <stdio.h>
#include "alloc.h"
#include "alloc2f.h"

/* See alloc2f (3) */
float ** Calloc2F(long j, long i)
{
    float **dat = NULL;
    long n;
    size_t jj, ii;		/* Addends for pointer arithmetic */
    size_t ji;

    /* Make sure casting to size_t does not overflow anything.  */
    if (j <= 0 || i <= 0) {
	fprintf(stderr, "Array dimensions must be positive.\n");
	return NULL;
    }
    jj = (size_t)j;
    ii = (size_t)i;
    ji = jj * ii;
    if (ji / jj != ii) {
	fprintf(stderr, "Dimensions, [%ld][%ld] too big "
		"for pointer arithmetic.\n", j, i);
	return NULL;
    }

    dat = (float **)CALLOC(jj + 2, sizeof(float *));
    if ( !dat ) {
	fprintf(stderr, "Could not allocate memory for 1st dimension of "
		"two dimensional array.\n");
	return NULL;
    }
    dat[0] = (float *)CALLOC(ji, sizeof(float));
    if ( !dat[0] ) {
	FREE(dat);
	fprintf(stderr, "Could not allocate memory for values "
		"of two dimensional array.\n");
	return NULL;
    }
    for (n = 1; n <= j; n++) {
	dat[n] = dat[n - 1] + i;
    }
    return dat;
}

/* See alloc2f (3) */
void Free2F(float **dat)
{
    if (dat && dat[0]) {
	FREE(dat[0]);
    }
    FREE(dat);
}
