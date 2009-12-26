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
   .	$Revision: 1.11 $ $Date: 2009/12/26 03:19:50 $
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include "alloc.h"
#include "err_msg.h"
#include "str.h"

static char ** growv(char **, int, int *);

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

/*
   Grow v in function below
   v = array to grow
   c = number of elements in use
   cx = number of elements can be stored at v
   If c + 1 > *cx, v is reallocated with more space.
 */
static char ** growv(char **v, int c, int *cx)
{
    int cx2;			/* New value for cx when reallocating */
    size_t sz;			/* Temporary */
    char **t;

    if (c + 1 > *cx) {
	cx2 = 2 * *cx;
	sz = (size_t)cx2 * sizeof(char *);
	if (cx2 > mx || !(t = (char **)REALLOC(v, sz)) ) {
	    FREE(v);
	    return NULL;
	}
	v = t;
	*cx = cx2;
    }
    return v;
}

char ** Str_Words(char *ln, char **argv, int *argc)
{
    char **v = NULL;		/* Array of words from ln. */
    char **t;			/* Temporary */
    int cx;			/* Number of words that can be stored at v */
    int c;			/* Number of words in ln */
    char *p, *q;		/* Pointers into ln */
    int inwd;			/* If true, p points into a word */
    size_t sz;			/* Temporary */

    if (argv) {
	v = argv;
	cx = *argc;
	if (cx < 2) {
	    if ( !(t = (char **)REALLOC(v, 2 * sizeof(char *))) ) {
		FREE(v);
		*argc = -1;
		Err_Append("Could not allocate word array.  ");
		return NULL;
	    }
	    v = t;
	    cx = 2;
	}
    } else {
	cx = 2;
	if ( !(v = (char **)CALLOC((size_t)cx, sizeof(char *))) ) {
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
	} else if ( *p == '"' || *p == '\'' ) {
	    char *e = strchr(p + 1, *p);

	    if ( !e ) {
		Err_Append("Unbalanced quote.  ");
		FREE(v);
		return NULL;
	    }
	    if ( !inwd ) {
		/* Have found start of a new word */
		if ( !(v = growv(v, c, &cx)) ) {
		    Err_Append("Could not allocate word array.  ");
		    return NULL;
		}
		v[c++] = q;
		inwd = 1;
	    }
	    strncpy(q, p + 1, e - p - 1);
	    q += e - p - 1;
	    p = e;
	} else {
	    if ( !inwd ) {
		/* Have found start of a new word */
		if ( !(v = growv(v, c, &cx)) ) {
		    Err_Append("Could not allocate word array.  ");
		    return NULL;
		}
		v[c++] = q;
		inwd = 1;
	    }
	    *q++ = *p;
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

char* Str_GetLn(FILE *in, char eol, char *ln, int *l_max)
{
    int new_ln;			/* If true, this function creates a new
				 * allocation at ln.  Otherwise, is works
				 * with a passed in allocation */
    int m;
    int c;
    int nc;			/* Number of characters in ln */
    char *l;			/* Pointer into line */

    if ( !ln ) {
	*l_max = 4;
	if ( !(ln = (char *)MALLOC((size_t)*l_max)) ) {
	    Err_Append("Could not allocate memory for line.  ");
	    return NULL;
	}
	new_ln = 1;
    } else {
	new_ln = 0;
    }
    for (l = ln, nc = 0; (c = fgetc(in)) != EOF && c != eol; l++, nc++) {
	if (nc + 1 > *l_max) {
	    m = 2 * *l_max;
	    if (m > INT_MAX || !(ln = (char *)REALLOC(ln, (size_t)m)) ) {
		Err_Append("Could not reallocate memory for line.  ");
		return NULL;
	    }
	    l = ln + nc;
	    *l_max = m;
	}
	*l = (char)c;
    }
    if (nc == 0 && feof(in) && new_ln) {
	FREE(ln);
	*l_max = 0;
	return NULL;
    }
    if (nc + 1 > *l_max) {
	m = *l_max + 1;
	if (m > INT_MAX || !(ln = (char *)REALLOC(ln, (size_t)m)) ) {
	    Err_Append("Could not reallocate memory for line.  ");
	    return NULL;
	}
	l = ln + nc;
    }
    *l = '\0';
    *l_max = nc + 1;
    if (*l_max > INT_MAX || !(ln = (char *)REALLOC(ln, (size_t)*l_max)) ) {
	Err_Append("Could not reallocate memory for line.  ");
	return NULL;
    }
    return ln;
}
