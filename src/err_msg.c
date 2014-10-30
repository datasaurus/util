/*
   -	err_msg.c --
   -		This file defines general purpose functions
   -		and macros to generate globally visible error
   -		messages.  See err_msg (3).
   -	
   .	Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
   .	
   .	Redistribution and use in source and binary forms, with or without
   .	modification, are permitted provided that the following conditions
   .	are met:
   .	
   .	    * Redistributions of source code must retain the above copyright
   .	    notice, this list of conditions and the following disclaimer.
   .
   .	    * Redistributions in binary form must reproduce the above copyright
   .	    notice, this list of conditions and the following disclaimer in the
   .	    documentation and/or other materials provided with the distribution.
   .	
   .	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   .	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   .	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   .	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   .	HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   .	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
   .	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   .	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   .	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   .	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   .	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.23 $ $Date: 2012/11/08 21:17:54 $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "err_msg.h"

#define LEN 65535
static char msg[LEN];		/* Current error message */
static char msg1[LEN];		/* Copy of msg */
static size_t msg_len;		/* strlen(msg) */

/* See err_msg (3) */
void Err_Append(const char *s)
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
    for (e = msg + (long)msg_len, m = s, e1 = e + (long)s_len; e < e1; e++, m++)
    {
	*e  = *m;
    }
    *e = '\0';
    msg_len = new_len;
}

/* See err_msg (3) */
char *Err_Get(void)
{
    memcpy(msg1, msg, LEN - 1);
    msg_len = 0;
    *msg = '\0';
    return msg1;
}
