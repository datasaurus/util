/*
 - mstring.c --
 - 	This file defines string manipulation functions.  See mstring (3).
 - 
   Copyright (c) 2009 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Revision: $ $Date: $
 */

#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "mstring.h"

static int isodigit(int);

static int isodigit(int c)
{
    return isdigit(c) && (c - '0' < 8);
}

/* Copy a string. See mstrcpy (3) */
char *stresc(char *str)
{
    char *p, *q;
    char n[4], *n1;

    for (p = q = str; *q; p++, q++) {
	if (*q == '\\') {
	    q++;
	    switch (*q) {
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
		    /* Escape sequence is a sequence of octal digits.  Copy the
		     * digits into n and convert */
		    memset(n, '\0', 4);
		    q++;
		    for (n1 = n; *q && isodigit(*q) && n1 < n + 4; q++, n1++) {
			*n1 = *q;
		    }
		    *p = (char)strtoul(n, NULL, 8);
		    q--;
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
