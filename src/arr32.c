/*
   .	arr32.c --
   .		Print a 2D slice of a 3D array.
   -
   -	Usage:
   -	arr32 nk nj ni orient s
   -
   -	Where:
   -	nk, nj, ni specify the dimension sizes of input array.
   -	orient tells which plane to slice. s specifies offset to the plane.
   -	orient == "xy" => output will give values for xy plane at k = s.
   -	orient == "xz" => output will give values for xz plane at j = s.
   -	orient == "yz" => output will give values for yz plane at i = s.
   -
   -	Values for 3D array are read from standard input.
   -	Values for 2D slice are written to standard output.
   -
   -	Copyright (c) 2013, Gordon D. Carrie. All rights reserved.
   -	
   -	Redistribution and use in source and binary forms, with or without
   -	modification, are permitted provided that the following conditions
   -	are met:
   -	
   -	    * Redistributions of source code must retain the above copyright
   -	    notice, this list of conditions and the following disclaimer.
   -
   -	    * Redistributions in binary form must reproduce the above copyright
   -	    notice, this list of conditions and the following disclaimer in the
   -	    documentation and/or other materials provided with the distribution.
   -	
   -	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   -	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   -	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   -	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   -	HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   -	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
   -	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   -	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   -	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   -	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   -	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   -
   -	Please send feedback to dev0@trekix.net
   -
   -	$Revision: $ $Date: $
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Length of various names and strings */
#define LEN 17
#define LEN_FMT " %18s"

int main(int argc, char *argv[])
{
    char *argv0 = argv[0];
    char *nk_s, *nj_s, *ni_s;		/* String representations of dimension
					   sizes */
    size_t nk, nj, ni;			/* Dimension sizes */
    char *orient;			/* Orientation */
    char *slice_s;			/* String representation of slice
					   index */
    int k_slice, j_slice, i_slice;	/* Slice indeces. Only one used. */
    int k, j, i;			/* Array indeces */
    char ****dat;			/* Array data, dimensioned [k][j][i].
					   Fourth dimensions holds strings. */

    if ( argc != 6 ) {
	fprintf(stderr, "Usage: %s nk nj ni orient s\n", argv0);
	exit(EXIT_FAILURE);
    }
    nk_s = argv[1];
    nj_s = argv[2];
    ni_s = argv[3];
    orient = argv[4];
    slice_s = argv[5];
    if ( sscanf(nk_s, "%zi", &nk) != 1 ) {
	fprintf(stderr, "%s: expected integer for size of k dimension, "
		"got %s.\n", argv0, nk_s);
	exit(EXIT_FAILURE);
    }
    if ( sscanf(nj_s, "%zi", &nj) != 1 ) {
	fprintf(stderr, "%s: expected integer for size of j dimension, "
		"got %s.\n", argv0, nj_s);
	exit(EXIT_FAILURE);
    }
    if ( sscanf(ni_s, "%zi", &ni) != 1 ) {
	fprintf(stderr, "%s: expected integer for size of i dimension, "
		"got %s.\n", argv0, ni_s);
	exit(EXIT_FAILURE);
    }
    k_slice = j_slice = i_slice = -1;
    if ( strcmp(orient, "xy") == 0 ) {
	if ( sscanf(slice_s, "%i", &k_slice) != 1 ) {
	    fprintf(stderr, "%s: expected integer for k, got %s.\n",
		    argv0, slice_s);
	    exit(EXIT_FAILURE);
	}
	if ( k_slice >= nk ) {
	    fprintf(stderr, "%s: slice index %d too big.\n", argv0, k_slice);
	    exit(EXIT_FAILURE);
	}
    } else if ( strcmp(orient, "xz") == 0 ) {
	if ( sscanf(slice_s, "%i", &j_slice) != 1 ) {
	    fprintf(stderr, "%s: expected integer for j, got %s.\n",
		    argv0, slice_s);
	    exit(EXIT_FAILURE);
	}
	if ( j_slice >= nj ) {
	    fprintf(stderr, "%s: slice index %d too big.\n", argv0, j_slice);
	    exit(EXIT_FAILURE);
	}
    } else if ( strcmp(orient, "yz") == 0 ) {
	if ( sscanf(slice_s, "%i", &i_slice) != 1 ) {
	    fprintf(stderr, "%s: expected integer for i, got %s.\n",
		    argv0, slice_s);
	    exit(EXIT_FAILURE);
	}
	if ( i_slice >= ni ) {
	    fprintf(stderr, "%s: slice index %d too big.\n", argv0, i_slice);
	    exit(EXIT_FAILURE);
	}
    } else {
	fprintf(stderr, "%s: slice orientation must be one of \"xy\","
		"\"xz\", or \"yz\".\n", argv0);
	exit(EXIT_FAILURE);
    }

    /*
       Allocate dat array. Read and write strings, to avoid losses due to
       formatting.
     */

    dat = (char ****)calloc(nk, sizeof(char ***));
    if ( !dat ) {
	fprintf(stderr, "%s: could not allocate 3rd dimension "
		"of value array.\n", argv0);
	exit(EXIT_FAILURE);
    }
    dat[0] = (char ***)calloc(nk * nj, sizeof(char **));
    if ( !dat[0] ) {
	fprintf(stderr, "%s: could not allocate 2nd dimension "
		"of value array.\n", argv0);
	exit(EXIT_FAILURE);
    }
    dat[0][0] = (char **)calloc(nk * nj * ni, sizeof(char *));
    if ( !dat[0][0] ) {
	fprintf(stderr, "%s: could not allocate 1st dimension "
		"of value array.\n", argv0);
	exit(EXIT_FAILURE);
    }
    dat[0][0][0] = (char *)calloc(nk * nj * ni * LEN, sizeof(char));
    if ( !dat[0][0][0] ) {
	fprintf(stderr, "%s: could not allocate array of values.\n", argv0);
	exit(EXIT_FAILURE);
    }
    for (k = 1; k <= nk; k++) {
	dat[k] = dat[k - 1] + nj;
    }
    for (j = 1; j <= nk * nj; j++) {
	dat[0][j] = dat[0][j - 1] + ni;
    }
    for (i = 1; i <= nk * nj * ni; i++) {
	dat[0][0][i] = dat[0][0][i - 1] + LEN;
    }

    /* Read 3D array */ 
    for (i = 0; i < nk * nj * ni; i++) {
	if ( scanf(LEN_FMT, dat[0][0][i]) != 1 ) {
	    fprintf(stderr, "%s: read failed after %d elements.\n", argv0, i);
	    exit(EXIT_FAILURE);
	}
    }

    /* Print 2D slice */
    if ( k_slice > 0 ) {
	for (j = 0; j < nj; j++) {
	    for (i = 0; i < ni; i++) {
		printf(" %s", dat[k_slice][j][i]);
	    }
	}
    } else if ( j_slice > 0 ) {
	for (k = 0; k < nk; k++) {
	    for (i = 0; i < ni; i++) {
		printf(" %s", dat[k][j_slice][i]);
	    }
	}
    } else if ( i_slice > 0 ) {
	for (k = 0; k < nk; k++) {
	    for (j = 0; j < nj; j++) {
		printf(" %s", dat[k][j][i_slice]);
	    }
	}
    }

    return 0;
}
