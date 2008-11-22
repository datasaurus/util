/*
 * alloc3f.c --
 *
 *	This file defines functions that allocate 3-dimensional
 *	arrays of floating point values.  See alloc3f (3).
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: $
 *
 **********************************************************************
 *
 */

#include "alloc.h"
#include "err_msg.h"
#include "alloc3f.h"

float *** calloc3f(long k, long j, long i)
{
    float ***dat = NULL;
    long n, ne;
    size_t kk, jj, ii;		/* Addends for pointer arithmetic */
    size_t kj, kji;

    /*
     * Make sure casting to size_t does not overflow anything.
     */

    if (k <= 0 || j <= 0 || i <= 0) {
	err_append("Array dimensions must be positive.\n");
	return NULL;
    }
    kk = (size_t)k;
    jj = (size_t)j;
    ii = (size_t)i;
    kj = kk * jj;
    kji = kj * ii;
    if (kj / kk != jj || kji / kj != ii) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }

    dat = (float ***)CALLOC(kk + 1, sizeof(float **));
    if ( !dat ) {
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0] = (float **)CALLOC(kj + 1, sizeof(float *));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0] = (float *)CALLOC(kji + 1, sizeof(float));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    for (n = 1; n < k; n++) {
	dat[n] = dat[n - 1] + j;
    }
    for (n = 1, ne = k * j; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + i;
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
