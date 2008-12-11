#!/bin/sh
#
#- findleaks.sh --
#-	This script tests the src/findleaks script.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: findleaks.sh,v 1.2 2008/12/11 02:24:35 gcarrie Exp $
#
########################################################################

echo "
findleaks.sh --

This script tests the src/findleaks application.  See findleaks (1) for
information on findleaks.

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

FINDLEAKS=src/findleaks

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

echo "test1: evaluate output from a normal process."

$FINDLEAKS > test1.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
0x00000002 (000000004) freed at makebelieve.c:20
END
case $? in
    0)
	echo "findleaks reported leaks when there were not any."
	result=fail
	;;
    1)
	echo "findleaks reported no leaks."
	result=success
	;;
    2)
	echo "findleaks did not see input."
	result=fail
	;;
esac
cat /dev/null > correct2.out
if diff test1.out correct2.out
then
    echo "findleaks produced correct output."
    result=success
else
    echo "findleaks produced incorrect output."
    result=fail
fi
echo "test1 result = $result"
$RM test1.out correct2.out
echo "Done with test1

--------------------------------------------------------------------------------
"

echo "test2: evaluate output from a process that leaks memory."

$FINDLEAKS > test2.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
END
case $? in
    0)
	echo "findleaks reported leaks."
	result=success
	;;
    1)
	echo "findleaks failed to report a leak."
	result=fail
	;;
    2)
	echo "findleaks did not see input."
	result=fail
	;;
esac
if egrep -q "Leak at [0-9x]+" test2.out
then
    echo "findleaks produced correct output."
    result=success
else
    echo "findleaks produced incorrect output."
    result=fail
fi
echo "test1 result = $result"
$RM test2.out
echo "Done with test2

--------------------------------------------------------------------------------
"

echo "test3: make sure findleaks complains if there is no input"

: | $FINDLEAKS > test3.out 2>&1
case $? in
    0)
	echo "findleaks reported leak status with no input."
	result=fail
	;;
    1)
	echo  "findleaks reported leak status with no input."
	result=fail
	;;
    2)
	echo "findleaks did not see input."
	;;
esac
echo "Warning findleaks did not receive input." > correct3.out
if diff test3.out correct3.out
then
    echo "findleaks produced correct output."
else
    echo "findleaks produced incorrect output."
    result=fail
fi
echo "test1 result = $result"
$RM test3.out correct3.out
echo "Done with test3

--------------------------------------------------------------------------------
"