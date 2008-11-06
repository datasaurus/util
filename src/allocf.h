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
 * $Id: allocf.h,v 1.1 2008/10/30 15:37:27 gcarrie Exp $
 *
 */

#ifndef ALLOC_F_H_
#define ALLOC_F_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include "alloc.h"

float ***Alloc_Arr3(size_t i, size_t j, size_t k);
void Alloc_Free3(float ***d);
float ****Alloc_Arr4(size_t i, size_t j, size_t k, size_t l);
void Alloc_Free4(float ****d);

#ifdef __cplusplus
}
#endif

#endif
