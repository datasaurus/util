/*
 * allocf.h --
 *
 *	This header declares functions that allocate multi-dimensional
 *	arrays of floating point values.
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: allocf.h,v 1.2 2008/11/06 17:09:42 gcarrie Exp $
 *
 */

#ifndef ALLOC_F_H_
#define ALLOC_F_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include "alloc.h"

float **mallocf2(size_t j, size_t i);
void freef2(float **d);
float ***mallocf3(size_t k, size_t j, size_t i);
void freef3(float ***d);
float ****mallocf4(size_t l, size_t k, size_t j, size_t i);
void freef4(float ****d);

#ifdef __cplusplus
}
#endif

#endif
