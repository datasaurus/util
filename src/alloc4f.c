/*
   -	alloc4f.c --
   -		This file defines functions that
   -		allocate 4-dimensional arrays of
   -		floating point values.  See alloc4f (3).
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
   .	$Revision: 1.12 $ $Date: 2013/02/20 18:40:25 $
 */

#include <stdio.h>
#include "alloc.h"
#include "alloc4f.h"

/* See alloc4f (3) */
float **** Calloc4F(long lmax, long kmax, long jmax, long imax)
{
    float ****dat;
    long k, j, l;
    size_t ll, kk, jj, ii;

    /* Make sure casting to size_t does not overflow anything.  */
    if (lmax <= 0 || kmax <= 0 || jmax <= 0 || imax <= 0) {
	fprintf(stderr, "Array dimensions must be positive.\n");
	return NULL;
    }
    ll = (size_t)lmax;
    kk = (size_t)kmax;
    jj = (size_t)jmax;
    ii = (size_t)imax;
    if ((ll * kk) / ll != kk || (ll * kk * jj) / (ll * kk) != jj
	    || (ll * kk * jj * ii) / (ll * kk * jj) != ii) {
	fprintf(stderr, "Dimensions [%ld][%ld][%ld][%ld]  too big "
		"for pointer arithmetic.\n", lmax, kmax, jmax, imax);
	return NULL;
    }

    dat = (float ****)CALLOC(ll + 2, sizeof(float ***));
    if ( !dat ) {
	fprintf(stderr, "Could not allocate 3rd dimension.\n");
	return NULL;
    }
    dat[0] = (float ***)CALLOC(ll * kk + 1, sizeof(float **));
    if ( !dat[0] ) {
	FREE(dat);
	fprintf(stderr, "Could not allocate 2nd dimension.\n");
	return NULL;
    }
    dat[0][0] = (float **)CALLOC(ll * kk * jj + 1, sizeof(float *));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	fprintf(stderr, "Could not allocate 1st dimension.\n");
	return NULL;
    }
    dat[0][0][0] = (float *)CALLOC(ll * kk * jj * ii, sizeof(float));
    if ( !dat[0][0][0] ) {
	FREE(dat[0][0]);
	FREE(dat[0]);
	FREE(dat);
	fprintf(stderr, "Could not allocate array of values.\n");
	return NULL;
    }
    for (l = 1; l <= lmax; l++) {
	dat[l] = dat[l - 1] + kmax;
    }
    for (k = 1; k <= lmax * kmax; k++) {
	dat[0][k] = dat[0][k - 1] + jmax;
    }
    for (j = 1; j <= lmax * kmax * jmax; j++) {
	dat[0][0][j] = dat[0][0][j - 1] + imax;
    }
    return dat;
}

/* See alloc4f (3) */
void Free4F(float ****dat)
{
    if (dat) {
	if (dat[0]) {
	    if (dat[0][0]) {
		if (dat[0][0][0]) {
		    FREE(dat[0][0][0]);
		}
		FREE(dat[0][0]);
	    }
	    FREE(dat[0]);
	}
	FREE(dat);
    }
}
