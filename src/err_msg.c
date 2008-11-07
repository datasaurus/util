/*
 * msg --
 *
 * 	This file defines general purpose functions and macros to
 * 	generate globally visible error messages.
 * 
 * Copyright (c) 2007,2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: err_msg.c,v 1.3 2008/11/06 17:09:42 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "alloc.h"
#include "err_msg.h"

static char *msg;	/* Current error message */
static size_t alloc;	/* Allocation at msg */
static size_t len;	/* strlen(msg) */

/*
 *------------------------------------------------------------------------
 *
 * err_append --
 *
 * 	This function appends a string to the current error message.
 *
 * Arguments:
 *	const char *s	- string to append to the error message.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	A string is appended to the string at msg, if any.  Memory is
 * 	reallocated if necessary.  If allocation fails, the application exits.
 *
 *------------------------------------------------------------------------
 */

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

/*
 *------------------------------------------------------------------------
 *
 * err_get --
 *
 * 	This function returns the current error message.
 *
 *
 * Results:
 *	Return value is the address of the error message.  User should not
 *	modify it.

 * Side effects:
 *	Error message is set to zero length, although it remains allocated.
 *
 *------------------------------------------------------------------------
 */

char *err_get(void)
{
    if (msg) {
	len = 0;
	return msg;
    } else {
	return "";
    }
}

/*
 *------------------------------------------------------------------------
 *
 * err_destroy --
 *
 * 	This clean up function frees memory allocated in this file.
 *	It should be used when the application exits.
 *
 * Side effects:
 *	The error message is freed.
 *
 *------------------------------------------------------------------------
 */

void err_destroy(void)
{
    if (msg) {
	FREE(msg);
    }
    msg = NULL;
    len = 0;
}
