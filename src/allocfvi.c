/*
 - allocfvi.c --
 -	This file defines an application that prints out memory maps of
 -	multi-dimensional arrays.  The application is for testing,
 -	diagnosis, and edification.
 -
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to user0@tkgeomap.org
  
   $Id: $
 */

/*
   Sample compile line:
   cc -o allocfvi allocfvi.c alloc2f.c alloc.c err_msg.c
 */

#include <stdlib.h>
#include <stdio.h>
#include "alloc2f.h"
#include "err_msg.h"

int main(void)
{
    float **dat;
    long jmax = 2, imax = 3;
    long j, i;

    /* Create an array */

    dat = (float **)calloc2f(jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "%s.\nCould not allocate memory.\n", err_get());
	exit(1);
    }

    /* Assign random values */

    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    dat[j][i] = 8.0 * rand() / RAND_MAX;
	}
    }

    /* Print a picture showing where things are stored */

    printf("           dat       %12p\n", dat);
    for (j = 0; j < jmax + 2; j++) {
	printf("%p dat[%ld]    %12p\n", &dat[j], j, dat[j]);
    }
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    printf("%p dat[%ld][%ld] %12.1f\n", &dat[j][i], j, i, dat[j][i]);
	}
    }
    free2f(dat);
    return 0;
}
