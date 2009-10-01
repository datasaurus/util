/*
   -	mstring.c --
   -		This file defines string manipulation
   -		functions.  See mstring (3).
   -	
   .	Copyright (c) 2009 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.3 $ $Date: 2009/09/25 21:33:13 $
 */

#include <stdlib.h>
#include <string.h>
#include "mstring.h"

char *stresc(char *str)
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
