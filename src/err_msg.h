/*
   -	errMsg.h --
   -		This header declares general purpose
   -		functions and macros to generate globally
   -		accessible error messages.  See err_msg (3).
   -	
   .	Copyright (c) 2007 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.9 $ $Date: 2009/09/25 21:33:13 $
 */

#ifndef ERR_MSG_H_
#define ERR_MSG_H_

void err_append(const char *msg);
char *err_get(void);

#endif
