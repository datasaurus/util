/*
 - alloc4f.c --
 -	This file defines functions that allocate 4-dimensional
 -	arrays of floating point values.  See alloc4f (3).
 - 
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc4f.c,v 1.3 2008/12/02 17:19:39 gcarrie Exp $
 */

#include "alloc.h"
#include "err_msg.h"
#include "alloc4f.h"

float **** calloc4f(long lmax, long kmax, long jmax, long imax)
{
    float ****dat;
    long k, j, l;
    size_t ll, kk, jj, ii;

    if (lmax <= 0 || kmax <= 0 || jmax <= 0 || imax <= 0) {
	err_append("Array dimensions must be positive.\n");
	return NULL;
    }
    ll = (size_t)lmax;
    kk = (size_t)kmax;
    jj = (size_t)jmax;
    ii = (size_t)imax;
    if ((ll * kk) / ll != kk || (ll * kk * jj) / (ll * kk) != jj
	    || (ll * kk * jj * ii) / (ll * kk * jj) != ii) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }
    dat = (float ****)CALLOC(ll + 2, sizeof(float ***));
    if ( !dat ) {
	err_append("Could not allocate 3rd dimension.\n");
	return NULL;
    }
    dat[0] = (float ***)CALLOC(ll * kk + 1, sizeof(float **));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate 2nd dimension.\n");
	return NULL;
    }
    dat[0][0] = (float **)CALLOC(ll * kk * jj + 1, sizeof(float *));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate 1st dimension.\n");
	return NULL;
    }
    dat[0][0][0] = (float *)CALLOC(ll * kk * jj * ii, sizeof(float));
    if ( !dat[0][0][0] ) {
	FREE(dat[0][0]);
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate array of values.\n");
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
