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
   .	$Revision: 1.10 $ $Date: 2009/10/01 22:15:22 $
 */

#ifndef ERR_MSG_H_
#define ERR_MSG_H_

void Err_Append(const char *msg);
char *Err_Get(void);

#endif
