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
   .	$Revision: 1.13 $ $Date: 2009/12/30 23:22:04 $
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

char ** Str_Words(char *ln, int *argc)
{
    char **t;			/* Temporary */
    char **argv;		/* Return value */
    int c;			/* Number of words in ln */
    char *p;			/* Point into ln */
    char *e;			/* Point to the end of a word in ln */
    char *ln2 = NULL;		/* Recieves wanted characters from ln */
    size_t l;			/* Number of charaters currently at ln2 */
    size_t lx;			/* Allocation at ln2 */
    int inwd;			/* If true, p points into a word */
    size_t sz;			/* Temporary */

    if ( !ln ) {
	return NULL;
    }
    lx = strlen(ln) + 1;
    l = 0;
    if ( !(ln2 = CALLOC(lx, 1)) ) {
	Err_Append("Could not allocate work string.  ");
	return NULL;
    }

    /* Copy wanted characters from p to ln2 */
    for (p = ln, inwd = 0, c = 0; *p; p++) {
	switch (*p) {
	    case ' ':
	    case '\t':
	    case '\v':
	    case '\n':
	    case '\r':
		if ( inwd && !(ln2 = Str_Append(ln2, &l, &lx, "", (size_t)1)) ) {
		    Err_Append("Failed to terminate string.  ");
		    goto error;
		}
		inwd = 0;
		break;
	    case '"':
	    case '\'':
		e = strchr(p + 1, *p);
		if ( !e ) {
		    Err_Append("Unbalanced quote.  ");
		    goto error;
		}
		if ( !inwd ) {
		    c++;
		    inwd = 1;
		}
		if ( !(ln2 = Str_Append(ln2, &l, &lx, p + 1, e - p - 1)) ) {
		    Err_Append("Failed to append string to string.  ");
		    goto error;
		}
		p = e;
		break;
	    default:
		if ( !inwd ) {
		    c++;
		    inwd = 1;
		}
		if ( !(ln2 = Str_Append(ln2, &l, &lx, p, (size_t)1)) ) {
		    Err_Append("Failed to terminate string.  ");
		    goto error;
		}
	}
    }
    *p = '\0';

    /* Create the array of pointers to strings with string contents appended */
    if ( c + 1 > (INT_MAX - l - 1) / sizeof(char *) ) {
	Err_Append("Word array too large.  ");
	FREE(ln2);
	goto error;
    }
    sz = (c + 1) * sizeof(char *) + l + 1;
    if ( !(t = (char **)REALLOC(ln2, sz)) ) {
	Err_Append("Could not reallocate word array.  ");
	goto error;
    }
    memmove((char **)t + c + 1, ln2, l + 1);
    ln2 = (char *)((char **)t + c + 1);
    for (p = ln2, e = p + l, argv = t, inwd = 0; p < e; p++) {
	if ( (*p && !inwd) || (!*p && !*(p + 1)) ) {
	    *argv++ = p;
	    inwd = 1;
	} else if ( inwd && !*p ) {
	    inwd = 0;
	}
    }
    argv[c] = NULL;
    *argc = c;
    return t;

error:
    FREE(ln2);
    *argc = -1;
    return NULL;
}

char * Str_Append(char *dest, size_t *l, size_t *lx, char *src, size_t n)
{
    char *t;
    size_t lx2;

    lx2 = *l + n + 1;
    if ( lx2 > *lx ) {
	if ( !(t = REALLOC(dest, lx2)) ) {
	    Err_Append("Could not grow string for appending.  ");
	    return NULL;
	}
	dest = t;
	*lx = lx2;
    }
    strncpy(dest + *l, src, n);
    *l += n;
    return dest;
}

char * Str_GetLn(FILE *in, char eol, char *ln, int *l_max)
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
