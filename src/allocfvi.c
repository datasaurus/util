/*
 - allocfvi.c --
 -	This file defines an application that prints out memory maps of
 -	multi-dimensional arrays.  The application is for testing,
 -	diagnosis, and edification.
 -
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: allocfvi.c,v 1.6 2008/12/02 17:19:39 gcarrie Exp $
 */

#include <stdlib.h>
#include <stdio.h>
#include "alloc2f.h"
#include "alloc3f.h"
#include "err_msg.h"

int main(void)
{
    float **dat2, ***dat3;
    long kmax = 2, jmax = 3, imax = 4;
    long k, j, i;

    /* Create an array with 2 dimensions */
    dat2 = calloc2f(jmax, imax);
    if ( !dat2 ) {
	fprintf(stderr, "%s.\nCould not allocate memory.\n", err_get());
	exit(1);
    }

    /* Assign random values */
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    dat2[j][i] = 8.0 * rand() / RAND_MAX;
	}
    }

    /* Print a picture showing where things are stored */
    printf("\njmax = %ld.  imax = %ld\n", jmax, imax);
    printf("           dat2       %12p\n", dat2);
    for (j = 0; j < jmax; j++) {
	printf("%p dat2[%ld]    %12p\n", &dat2[j], j, dat2[j]);
    }
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    printf("%p dat2[%ld][%ld] %12.1f\n", &dat2[j][i], j, i, dat2[j][i]);
	}
    }
    free2f(dat2);

    /* Create an array with 3 dimensions */
    dat3 = calloc3f(kmax, jmax, imax);
    if ( !dat3 ) {
	fprintf(stderr, "%s.\nCould not allocate memory.\n", err_get());
	exit(1);
    }

    /* Assign random values */
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		dat3[k][j][i] = 8.0 * rand() / RAND_MAX;
	    }
	}
    }

    /* Print a picture showing where things are stored */
    printf("\nkmax = %ld.  jmax = %ld.  imax = %ld\n", kmax, jmax, imax);
    printf("           dat3          %12p\n", dat3);
    for (k = 0; k < kmax; k++) {
	printf("%p dat3[%ld]       %12p\n", &dat3[k], k, dat3[k]);
    }
    printf("%p dat3[%ld]       %12p\n", &dat3[kmax], kmax, dat3[kmax]);
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    printf("%p dat3[%ld][%ld]    %12p\n", &dat3[k][j], k, j, dat3[k][j]);
	}
    }
    printf("%p dat3[%ld][%ld]    %12p\n",
	    &dat3[kmax-1][jmax], kmax-1, jmax, dat3[kmax-1][jmax]);
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		printf("%p dat3[%ld][%ld][%ld] %12.1f\n",
			&dat3[k][j][i], k, j, i, dat3[k][j][i]);
	    }
	}
    }
    free3f(dat3);
    return 0;
}
