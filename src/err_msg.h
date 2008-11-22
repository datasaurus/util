/*
 - errMsg.h --
 - 	This header declares general purpose functions and macros to
 - 	generate globally accessible error messages.  See err_msg (3).
 - 
   Copyright (c) 2007,2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to user0@tkgeomap.org
  
   $Id: err_msg.h,v 1.2 2008/11/06 17:09:42 gcarrie Exp $
 */

#ifndef ERR_MSG_H_
#define ERR_MSG_H_

#ifdef __cplusplus
extern "C" {
#endif

void err_append(const char *msg);
char *err_get(void);
void err_destroy(void);
    
#ifdef __cplusplus
}
#endif

#endif
