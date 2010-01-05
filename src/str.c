/*
   -	str.c --
   -		This file defines string manipulation
   -		functions.  See str (3).
   -	
   .	Copyright (c) 2009 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.18 $ $Date: 2010/01/04 22:14:47 $
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include "alloc.h"
#include "err_msg.h"
#include "str.h"

/* Largest possible number of elements in array of strings */
static int mx = INT_MAX / (int)sizeof(char *);

char *Str_Esc(char *str)
{
    char *p, *q, t;
    int n;

    for (p = q = str; *q; p++, q++) {
	if (*q == '\\') {
	    switch (*++q) {
		/* Replace escape sequence with associated character */
		case 'a':
		    *p = '\a';
		    break;
		case 'b':
		    *p = '\b';
		    break;
		case 'f':
		    *p = '\f';
		    break;
		case 'n':
		    *p = '\n';
		    break;
		case 'r':
		    *p = '\r';
		    break;
		case 't':
		    *p = '\t';
		    break;
		case 'v':
		    *p = '\v';
		    break;
		case '\'':
		    *p = '\'';
		    break;
		case '\\':
		    *p = '\\';
		    break;
		case '0':
		    /* Escape sequence is a sequence of octal digits. */
		    n = (int)strspn(++q, "01234567");
		    t = *(q + n);
		    *(q + n) = '\0';
		    *p = (char)strtoul(q, &q, 8);
		    *q-- = t;
		    break;
		default:
		    *p = *q;
	    }
	} else {
	    *p = *q;
	}
    }
    *p = '\0';

    return str;
}

char ** Str_Words(char *ln, char **argv, int *argc)
{
    char **v = NULL;		/* Array of words from ln. */
    char **t;			/* Temporary */
    int cx;			/* Number of words that can be stored at v */
    int cx2;			/* New value for cx when reallocating */
    int c;			/* Number of words in ln */
    char *p, *q;		/* Pointers into ln */
    int inwd;			/* If true, p points into a word */
    size_t sz;			/* Temporary */

    if (argv) {
	v = argv;
	cx = *argc;
	if (cx < 2) {
	    if ( !(t = (char **)REALLOC(v, 2 * sizeof(char *))) ) {	/* re */
		*argc = -1;
		Err_Append("Could not allocate word array.  ");
		return NULL;
	    }
	    v = t;
	    cx = 2;
	}
    } else {
	cx = 2;
	if ( !(v = (char **)CALLOC((size_t)cx, sizeof(char *))) ) {	/* new */
	    *argc = -1;
	    Err_Append("Could not allocate word array.  ");
	    return NULL;
	}
    }
    for (p = q = ln, inwd = 0, c = 0; *p; p++) {
	if ( isspace(*p) ) {
	    if ( inwd ) {
		*q++ = '\0';
	    }
	    inwd = 0;
	} else {
	    if ( !inwd ) {
		/* Have found start of a new word */
		if (c + 1 > cx) {
		    cx2 = 3 * cx / 2 + 4;
		    sz = (size_t)cx2 * sizeof(char *);
		    if (cx2 > mx || !(t = (char **)REALLOC(v, sz)) ) {
			FREE(v);
			*argc = -1;
			Err_Append("Could not allocate word array.  ");
			return NULL;
		    }
		    v = t;
		    cx = cx2;
		}
		v[c++] = q;
		inwd = 1;
	    }

	    if ( *p == '"' || *p == '\'' ) {
		/* Append run of characters bounded by quotes */
		char *e = strchr(p + 1, *p);

		if ( !e ) {
		    Err_Append("Unbalanced quote.  ");
		    FREE(v);
		    *argc = -1;
		    return NULL;
		}
		strncpy(q, p + 1, e - p - 1);
		q += e - p - 1;
		p = e;
	    } else {
		/* Append character */
		*q++ = *p;
	    }
	}
    }
    *q = '\0';
    *argc = c;
    sz = (size_t)(c + 1) * sizeof(char *);
    if ( (c + 1) > mx || !(t = (char **)REALLOC(v, sz)) ) {
	FREE(v);
	*argc = -1;
	Err_Append("Could not allocate word array.  ");
	return NULL;
    }
    v = t;
    v[c] = NULL;
    return v;
}

char * Str_Append(char *dest, size_t *l, size_t *lx, char *src, size_t n)
{
    char *t;
    size_t lx2;

    lx2 = *l + n + 1;
    if ( *lx < lx2 ) {
	size_t tx = *lx;

	while (tx < lx2) {
	    tx = (tx * 3) / 2 + 4;
	}
	if ( !(t = REALLOC(dest, tx)) ) {
	    Err_Append("Could not grow string for appending.  ");
	    return NULL;
	}
	dest = t;
	*lx = tx;
    }
    strncpy(dest + *l, src, n);
    *l += n;
    return dest;
}

int Str_GetLn(FILE *in, char eol, char **ln, int *l_max)
{
    int new_ln;			/* If true, will create new allocation */
    int i;			/* Input character */
    char c;			/* Input character */
    char *t, *t1;		/* Input line*/
    size_t n;			/* Number of characters in ln */
    size_t nx;			/* Temporarily hold value for *l_max */

    if ( !*ln ) {
	nx = 4;
	if ( !(t = (char *)MALLOC((size_t)nx)) ) {
	    Err_Append("Could not allocate memory for line.  ");
	    return 0;
	}
	new_ln = 1;
	} else {
	t = *ln;
	nx = *l_max;
	new_ln = 0;
    }
    n = 0;
    while ( (i = fgetc(in)) != EOF && (i != eol) ) {
	c = i;
	if ( !(t1 = Str_Append(t, &n, &nx, &c, (size_t)1)) ) {
	    FREE(t);
	    Err_Append("Could not append input character to string.  ");
	    return 0;
	}
	t = t1;
    }
    if ( !(*ln = (char *)REALLOC(t, (size_t)(n + 1))) ) {
	FREE(t);
	*ln = NULL;
	*l_max = 0;
	Err_Append("Could not reallocate memory for line.  ");
	return 0;
    }
    *(*ln + n) = '\0';
    *l_max = n + 1;
    return feof(in) ? EOF : 1;
}
