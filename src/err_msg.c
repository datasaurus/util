/*
 * msg --
 *
 * 	This file defines general purpose functions and macros to
 * 	generate globally visible error messages.
 * 
 * Copyright (c) 2007,2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id$
 *
 **********************************************************************
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alloc.h"
#include "msg.h"

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
    size_t new_len, new_alloc;
    char *e, *e1;
    const char *m;

    if ( !s || strlen(s) == 0 ) {
	return;
    }
    new_len = len + strlen(s);
    new_alloc = new_len + 1;
    if (new_alloc > alloc) {
	msg = REALLOC(msg, new_alloc);
	alloc = new_alloc;
    }
    for (e = msg + len, m = s, e1 = e + strlen(s); e < e1; e++, m++) {
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
