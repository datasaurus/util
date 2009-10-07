/*
   -	alloc2f.c --
   -		This file defines functions that allocate
   -		2-dimensional arrays of floating point values.
   -		See alloc2f (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.11 $ $Date: 2009/10/01 22:15:22 $
 */

#include "alloc.h"
#include "err_msg.h"
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
	Err_Append("Array dimensions must be positive.\n");
	return NULL;
    }
    jj = (size_t)j;
    ii = (size_t)i;
    ji = jj * ii;
    if (ji / jj != ii) {
	Err_Append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }

    dat = (float **)CALLOC(jj + 2, sizeof(float *));
    if ( !dat ) {
	Err_Append("Could not allocate memory for 1st dimension of two dimensional"
		" array.\n");
	return NULL;
    }
    dat[0] = (float *)CALLOC(ji, sizeof(float));
    if ( !dat[0] ) {
	FREE(dat);
	Err_Append("Could not allocate memory for values of two dimensional "
		"array.\n");
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
