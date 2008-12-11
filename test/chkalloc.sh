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
# $Id: chkalloc.sh,v 1.3 2008/12/11 19:53:43 gcarrie Exp $
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
result1=success
correct=0
cat /dev/null > correct1.out
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
    result1=fail
fi
if diff test1.out correct1.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result1=fail
fi
$RM test1.out correct2.out
echo "test1 result = $result1
Done with test1

--------------------------------------------------------------------------------
"

echo "test2: evaluate output from a process that leaks memory."
result2=success
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
    result2=fail
fi
if egrep -q "Leak at [0-9x]+" test2.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result2=fail
fi
$RM test2.out
echo "test2 result = $result2
Done with test2

--------------------------------------------------------------------------------
"

echo "test3: make sure chkalloc complains if there is no input"

result3=success
correct=2
echo "Warning chkalloc did not receive input." > correct3.out
: | $FINDLEAKS > test3.out 2>&1
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result3=fail
fi
if diff test3.out correct3.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result3=fail
fi
$RM test3.out correct3.out
echo "test3 result = $result3
Done with test3

--------------------------------------------------------------------------------
"

echo "Summary:
test1 result = $result1
test2 result = $result2
test3 result = $result3
"
