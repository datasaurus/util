/*
 - err_msg.c --
 - 	This file defines general purpose functions and macros to
 - 	generate globally visible error messages.  See err_msg (3).
 - 
   Copyright (c) 2007,2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Revision$ $Date$
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "alloc.h"
#include "err_msg.h"

static char *msg;		/* Current error message */
static size_t alloc;		/* Allocation at msg */
static size_t len;		/* strlen(msg) */

void err_append(const char *s)
{
    size_t l, new_len, new_alloc;
    long ll, llen;
    char *e, *e1;
    const char *m;

    if ( !s ) {
	return;
    }
    l = strlen(s);
    if (l == 0) {
	return;
    }
    new_len = len + l;
    new_alloc = new_len + 1;
    if (new_alloc > alloc) {
	msg = REALLOC(msg, new_alloc);
	assert(msg);
	alloc = new_alloc;
    }
    ll = (long)l;
    llen = (long)len;
    assert((double)l == (double)ll && (double)len == (double)llen);
    for (e = msg + llen, m = s, e1 = e + ll; e < e1; e++, m++) {
	*e  = *m;
    }
    *e = '\0';
    len = new_len;
}

char *err_get(void)
{
    if (msg) {
	len = 0;
	return msg;
    } else {
	return "";
    }
}

void err_destroy(void)
{
    if (msg) {
	FREE(msg);
    }
    msg = NULL;
    len = 0;
}
