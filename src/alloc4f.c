/*
 - alloc4f.c --
 -	This file defines functions that allocate 4-dimensional
 -	arrays of floating point values.  See alloc4f (3).
 - 
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc4f.c,v 1.2 2008/11/22 18:41:23 gcarrie Exp $
 */

#include "alloc.h"
#include "err_msg.h"
#include "alloc4f.h"

float **** calloc4f(long l, long k, long j, long i)
{
    float ****dat;
    long n, ne;
    size_t ll, kk, jj, ii;	/* Addends for pointer arithmetic */
    size_t lk, lkj, lkji;

    if (l <= 0 || k <= 0 || j <= 0 || i <= 0) {
	err_append("Array dimensions must be positive.\n");
	return NULL;
    }
    ll = (size_t)l;
    kk = (size_t)k;
    jj = (size_t)j;
    ii = (size_t)i;
    lk = ll * kk;
    lkj = lk * jj;
    lkji = lkj * ii;
    if (lk / ll != kk || lkj / lk != jj || lkji / lkj != ii) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }
    dat = (float ****)CALLOC(ll + 1, sizeof(float ***));
    if ( !dat ) {
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0] = (float ***)CALLOC(lk + 1, sizeof(float **));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0] = (float **)CALLOC(lkj + 1, sizeof(float *));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0][0] = (float *)CALLOC(lkji + 1, sizeof(float));
    if ( !dat[0][0][0] ) {
	FREE(dat[0][0]);
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    for (n = 1; n < l; n++) {
	dat[n] = dat[n - 1] + k;
    }
    for (n = 1, ne = l * k; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + j;
    }
    for (n = 1, ne = l * k * j; n < ne; n++) {
	dat[0][0][n] = dat[0][0][n - 1] + i;
    }
    return dat;
}

void free4f(float ****dat)
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
