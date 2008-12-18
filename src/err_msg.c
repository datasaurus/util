/*
 - err_msg.c --
 - 	This file defines general purpose functions and macros to
 - 	generate globally visible error messages.  See err_msg (3).
 - 
   Copyright (c) 2007,2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Revision: 1.13 $ $Date: 2008/12/17 22:55:56 $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "err_msg.h"

#define LEN 65535
static char msg[LEN];		/* Current error message */
static size_t msg_len;		/* strlen(msg) */

void err_append(const char *s)
{
    size_t s_len, new_len;
    char *e, *e1;
    const char *m;

    if ( !s ) {
	return;
    }
    s_len = strlen(s);
    if (s_len == 0) {
	return;
    }
    new_len = msg_len + s_len;
    if (new_len + 1 > LEN || msg_len > LONG_MAX || s_len > LONG_MAX) {
	fprintf(stderr, "Ran out of space for error messages.\n");
	if (msg_len > 0) {
	    fprintf(stderr, "Last error message was %s", msg);
	}
	exit(1);
    }
    for (e = msg + (long)msg_len, m = s, e1 = e + (long)s_len; e < e1; e++, m++) {
	*e  = *m;
    }
    *e = '\0';
    msg_len = new_len;
}

char *err_get(void)
{
    if (msg) {
	msg_len = 0;
	return msg;
    } else {
	return "";
    }
}
