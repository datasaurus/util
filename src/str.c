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
   .	$Revision: 1.7 $ $Date: 2009/12/22 21:44:48 $
 */

#include <stdlib.h>
#include <string.h>
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

char ** Str_Words(char *ln, char **argv, size_t *argc)
{
    char **argv1 = NULL;	/* Arguments from a line of input. */
    size_t max_argc;		/* Allocation at argv1 */
    size_t argc1;		/* Number of arguments on input line */
    char *c1, *c2;		/* Characters from input */
    size_t m;

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
	if ( !(argv1 = (char **)MALLOC(max_argc * sizeof(char *))) ) {
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
			if (m > INT_MAX / sizeof(char *) 
				|| !(argv1 = (char **)REALLOC(argv1,
					m * sizeof(char *))) ) {
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
			if (m > INT_MAX / sizeof(char *) 
				|| !(argv1 = (char **)REALLOC(argv1,
					m * sizeof(char *))) ) {
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
    if ((argc1 + 1) > INT_MAX / sizeof(char *) 
	    || !(argv1 = (char **)REALLOC(argv1, (argc1 + 1) * sizeof(char *))) ) {
	Err_Append("Could not allocate word array.  ");
	return NULL;
    }
    argv1[argc1] = NULL;
    return argv1;
}
