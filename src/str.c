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
   .	$Revision: 1.9 $ $Date: 2009/12/22 22:33:54 $
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <limits.h>
#include "alloc.h"
#include "err_msg.h"
#include "str.h"

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
    char **argv1 = NULL;	/* Arguments from a line of input. */
    int max_argc;		/* Allocation at argv1 */
    int argc1;			/* Number of arguments on input line */
    char *c1, *c2;		/* Characters from input */
    int m;

    if (argv) {
	argv1 = argv;
	max_argc = *argc;
	if (max_argc < 2) {
	    if ( !(argv1 = (char **)REALLOC(argv1, 2 * sizeof(char *))) ) {
		Err_Append("Could not allocate word array.  ");
		return NULL;
	    }
	    max_argc = 2;
	}
    } else {
	max_argc = 2;
	if ( !(argv1 = (char **)MALLOC((size_t)max_argc * sizeof(char *))) ) {
	    Err_Append("Could not allocate word array.  ");
	    return NULL;
	}
    }
    argc1 = 0;
    if (*ln != '\0') {
	if ( !isspace(*ln) ) {
	    argv1[argc1++] = ln;
	}
	for (c1 = ln, c2 = ln + 1; *c2 != '\0'; c1++, c2++) {
	    if (isspace(*c1)) {
		*c1 = '\0';
		if ( !isspace(*c2) ) {
		    /* c2 is the start of a new word.  Append it to argv1. */
		    if (argc1 + 1 > max_argc) {
			m = 2 * max_argc;
			if (m > INT_MAX / (int)sizeof(char *) 
				|| !(argv1 = (char **)REALLOC(argv1,
					(size_t)m * sizeof(char *))) ) {
			    Err_Append("Could not allocate word array.  ");
			    return NULL;
			}
			max_argc = m;
		    }
		    argv1[argc1++] = c2;
		} else if (*c1 == '"') {
		    /* Next word is bounded by double quotes.  */
		    char *endq;

		    if ( !(endq = strchr(c2, '"')) ) {
			Err_Append("Unbalanced \".\n");
			return NULL;
		    }
		    if (argc1 + 1 > max_argc) {
			m = 2 * max_argc;
			if (m > INT_MAX / (int)sizeof(char *) 
				|| !(argv1 = (char **)REALLOC(argv1,
					(size_t)m * sizeof(char *))) ) {
			    Err_Append("Could not allocate word array.  ");
			    return NULL;
			}
			max_argc = m;
		    }
		    argv1[argc1++] = c2;
		    c1 = endq;
		    c2 = c1 + 1;
		}
	    }
	}
    }
    *argc = argc1;
    if ((argc1 + 1) > INT_MAX / (int)sizeof(char *) 
	    || !(argv1 = (char **)REALLOC(argv1,
		    (size_t)(argc1 + 1) * sizeof(char *))) ) {
	Err_Append("Could not allocate word array.  ");
	return NULL;
    }
    argv1[argc1] = NULL;
    return argv1;
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
