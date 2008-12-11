#!/bin/sh
#
#- chkalloc.sh --
#-	This script tests the src/chkalloc script.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: chkalloc.sh,v 1.1 2008/12/11 17:37:41 gcarrie Exp $
#
########################################################################

echo "
chkalloc.sh --

This script tests the src/chkalloc application.  See chkalloc (1) for
information on chkalloc.

To save temporary files, set RM to : in environment before running this script.

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

FINDLEAKS=src/chkalloc

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

echo "test1: evaluate output from a normal process."

result=success
correct=0
$FINDLEAKS > test1.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
0x00000002 (000000004) freed at makebelieve.c:20
END
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result=fail
fi
cat /dev/null > correct1.out
if diff test1.out correct1.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result=fail
fi
echo "test1 result = $result"
$RM test1.out correct2.out
echo "Done with test1

--------------------------------------------------------------------------------
"

echo "test2: evaluate output from a process that leaks memory."

result=success
correct=1
$FINDLEAKS > test2.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
END
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result=fail
fi
if egrep -q "Leak at [0-9x]+" test2.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result=fail
fi
echo "test2 result = $result"
$RM test2.out
echo "Done with test2

--------------------------------------------------------------------------------
"

echo "test3: make sure chkalloc complains if there is no input"

result=success
correct=2
: | $FINDLEAKS > test3.out 2>&1
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result=fail
fi
echo "Warning chkalloc did not receive input." > correct3.out
if diff test3.out correct3.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result=fail
fi
echo "test3 result = $result"
$RM test3.out correct3.out
echo "Done with test3

--------------------------------------------------------------------------------
"
