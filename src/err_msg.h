/*
 - errMsg.h --
 - 	This header declares general purpose functions and macros to
 - 	generate globally accessible error messages.  See err_msg (3).
 - 
   Copyright (c) 2007,2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: err_msg.h,v 1.5 2008/12/14 03:41:14 gcarrie Exp $
 */

#ifndef ERR_MSG_H_
#define ERR_MSG_H_

void err_append(const char *msg);
char *err_get(void);
void err_destroy(void);

#endif
