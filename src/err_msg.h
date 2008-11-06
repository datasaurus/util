/*
 * errMsg --
 *
 * 	This file declares general purpose functions and macros to
 * 	generate globally visible error messages.
 * 
 * Copyright (c) 2007,2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: err_msg.h,v 1.1 2008/10/02 20:06:30 gcarrie Exp $
 *
 **********************************************************************
 *
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
