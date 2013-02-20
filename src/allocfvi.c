/*
   -	allocfvi.c --
   -		This file defines an application that prints
   -		out memory maps of multi-dimensional arrays.
   -		The application is for testing, diagnosis,
   -		and edification.  See allocfvi (1).
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
   .	$Revision: 1.17 $ $Date: 2011/11/28 16:09:55 $
 */

#include <stdlib.h>
#include <stdio.h>
#include "alloc2f.h"
#include "alloc3f.h"
#include "alloc4f.h"
#include "err_msg.h"

int main(void)
{
    float **dat2, ***dat3, ****dat4;
    long lmax, kmax, jmax, imax;
    long l, k, j, i;

    /* Create an array with 2 dimensions */
    jmax = 2;
    imax = 3;
    dat2 = Calloc2F(jmax, imax);
    if ( !dat2 ) {
	fprintf(stderr, "Could not allocate memory.\n");
	exit(1);
    }

    /* Assign random values */
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    dat2[j][i] = 8.0 * rand() / RAND_MAX;
	}
    }

    /* Print a picture showing where things are stored */
    printf("\njmax = %ld.  imax = %ld\n\n", jmax, imax);
    printf("           dat2       %12p\n", dat2);
    printf("\n");
    for (j = 0; j < jmax + 2; j++) {
	printf("%p dat2[%ld]    %12p\n", &dat2[j], j, dat2[j]);
    }
    printf("\n");
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    printf("%p dat2[%ld][%ld] %12.1f\n", &dat2[j][i], j, i, dat2[j][i]);
	}
    }
    Free2F(dat2);

    /* Create an array with 3 dimensions */
    kmax = 2;
    jmax = 3;
    imax = 4;
    dat3 = Calloc3F(kmax, jmax, imax);
    if ( !dat3 ) {
	fprintf(stderr, "Could not allocate memory.\n");
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
    printf("\n------------------------------------------------\n");
    printf("\nkmax = %ld.  jmax = %ld.  imax = %ld\n\n", kmax, jmax, imax);
    printf("           dat3          %12p\n", dat3);
    printf("\n");
    for (k = 0; k < kmax + 2; k++) {
	printf("%p dat3[%ld]       %12p\n", &dat3[k], k, dat3[k]);
    }
    printf("\n");
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    printf("%p dat3[%ld][%ld]    %12p\n", &dat3[k][j], k, j, dat3[k][j]);
	}
    }
    printf("%p dat3[%ld][%ld]    %12p\n",
	    &dat3[kmax-1][jmax], kmax-1, jmax, dat3[kmax-1][jmax]);
    printf("\n");
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		printf("%p dat3[%ld][%ld][%ld] %12.1f\n",
			&dat3[k][j][i], k, j, i, dat3[k][j][i]);
	    }
	}
    }
    Free3F(dat3);

    /* Create an array with 4 dimensions */
    lmax = 2;
    kmax = 3;
    jmax = 4;
    imax = 5;
    dat4 = Calloc4F(lmax, kmax, jmax, imax);
    if ( !dat4 ) {
	fprintf(stderr, "Could not allocate memory.\n");
	exit(1);
    }

    /* Assign random values */
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    for (j = 0; j < jmax; j++) {
		for (i = 0; i < imax; i++) {
		    dat4[l][k][j][i] = 8.0 * rand() / RAND_MAX;
		}
	    }
	}
    }

    /* Print a picture showing where things are stored */
    printf("\n------------------------------------------------\n");
    printf("\nlmax = %ld.  kmax = %ld.  jmax = %ld.  imax = %ld\n\n",
	    lmax, kmax, jmax, imax);
    printf("           dat4             %12p\n", dat4);
    printf("\n");
    for (l = 0; l < lmax + 2; l++) {
	printf("%p dat4[%ld]          %12p\n", &dat4[l], l, dat4[l]);
    }
    printf("\n");
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    printf("%p dat4[%ld][%ld]       %12p\n",
		    &dat4[l][k],
		    l, k,
		    dat4[l][k]);
	}
    }
    printf("%p dat4[%ld][%ld]       %12p\n",
	    &dat4[lmax-1][kmax], lmax-1, kmax, dat4[lmax-1][kmax]);
    printf("\n");
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    for (j = 0; j < jmax; j++) {
		printf("%p dat4[%ld][%ld][%ld]    %12p\n",
			&dat4[l][k][j],
			l, k, j,
			dat4[l][k][j]);
	    }
	}
    }
    printf("%p dat4[%ld][%ld][%ld]    %12p\n",
	    &dat4[lmax-1][kmax-1][jmax],
	    lmax-1, kmax-1, jmax,
	    dat4[lmax-1][kmax-1][jmax]);
    printf("\n");
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    for (j = 0; j < jmax; j++) {
		for (i = 0; i < imax; i++) {
		    printf("%p dat4[%ld][%ld][%ld][%ld] %12.1f\n",
			    &dat4[l][k][j][i], l, k, j, i, dat4[l][k][j][i]);
		}
	    }
	}
    }
    Free4F(dat4);
    return 0;
}
