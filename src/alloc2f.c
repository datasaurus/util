/*
 - alloc2f.c --
 -	This file defines functions that allocate 2-dimensional
 -	arrays of floating point values.  See alloc2f (3).
 -
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc2f.c,v 1.3 2008/12/02 17:19:39 gcarrie Exp $
 */

#include "alloc.h"
#include "err_msg.h"
#include "alloc2f.h"

float ** calloc2f(long j, long i)
{
    float **dat = NULL;
    long n;
    size_t jj, ii;		/* Addends for pointer arithmetic */
    size_t ji;

    /* Make sure casting to size_t does not overflow anything.  */

    if (j <= 0 || i <= 0) {
	err_append("Array dimensions must be positive.\n");
	return NULL;
    }
    jj = (size_t)j;
    ii = (size_t)i;
    ji = jj * ii;
    if (ji / jj != ii) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }

    dat = (float **)CALLOC(jj + 2, sizeof(float *));
    if ( !dat ) {
	err_append("Could not allocate memory for 1st dimension of two dimensional"
		" array.\n");
	return NULL;
    }
    dat[0] = (float *)CALLOC(ji, sizeof(float));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory for values of two dimensional "
		"array.\n");
	return NULL;
    }
    for (n = 1; n <= j; n++) {
	dat[n] = dat[n - 1] + i;
    }
    return dat;
}

void free2f(float **dat)
{
    if (dat && dat[0]) {
	FREE(dat[0]);
    }
    FREE(dat);
}
