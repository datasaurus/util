/*
   -	str.h --
   -		This header declares string manipulation
   -		functions.  See str (3).
   -	
   .	Copyright (c) 2009 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.5 $ $Date: 2009/12/22 21:42:10 $
 */

#ifndef MSTRING_H_
#define MSTRING_H_

#include <stdlib.h>

char *Str_Esc(char *s);
char ** Str_Words(char *, char **, size_t *);
    
#endif
