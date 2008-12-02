/*
 - alloc3f.c --
 -	This file defines functions that allocate 3-dimensional
 -	arrays of floating point values.  See alloc3f (3).
 - 
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc3f.c,v 1.4 2008/11/25 22:41:59 gcarrie Exp $
 */

#include "alloc.h"
#include "err_msg.h"
#include "alloc3f.h"

float *** calloc3f(long kmax, long jmax, long imax)
{
    float ***dat = NULL;
    long k, j;
    size_t kk, jj, ii;

    /* CALLOC casts arguments to size_t. Cast explicitly and check for overflows. */
    if (kmax <= 0 || jmax <= 0 || imax <= 0) {
	err_append("Array dimensions must be positive.\n");
	return NULL;
    }
    kk = (size_t)kmax;
    jj = (size_t)jmax;
    ii = (size_t)imax;
    if ((kk * jj) / kk != jj || (kk * jj * ii) / (kk * jj) != ii) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }

    dat = (float ***)CALLOC(kk, sizeof(float **));
    if ( !dat ) {
	err_append("Could not allocate 2nd dimension.\n");
	return NULL;
    }
    dat[0] = (float **)CALLOC(kk * jj, sizeof(float *));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate 1st dimension.\n");
	return NULL;
    }
    dat[0][0] = (float *)CALLOC(kk * jj * ii, sizeof(float));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate array of values.\n");
	return NULL;
    }
    for (k = 1; k < kmax; k++) {
	dat[k] = dat[k - 1] + jmax;
    }
    for (j = 1; j < kmax * jmax; j++) {
	dat[0][j] = dat[0][j - 1] + imax;
    }
    return dat;
}

void free3f(float ***dat)
{
    if (dat) {
	if (dat[0]) {
	    if (dat[0][0]) {
		FREE(dat[0][0]);
	    }
	    FREE(dat[0]);
	}
	FREE(dat);
    }
}
