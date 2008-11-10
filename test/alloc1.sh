#!/bin/sh
#
# This script exercises alloc1.c.
#
# $Id: alloc1.sh,v 1.3 2008/11/10 03:12:34 gcarrie Exp $

EXEC=alloc1
FINDLEAKS=src/findleaks
OUT=alloc1.out
RM='rm -f'

$RM $OUT

echo test1: building and running alloc1
cc -Isrc -o $EXEC src/alloc.c alloc1.c
echo Starting test1
$EXEC
echo Done with test1
echo ""
$RM $EXEC

echo test2: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
cc -Isrc -o $EXEC src/alloc.c alloc1.c
echo Starting test2
$EXEC
echo Done with test2
echo ""
$RM $EXEC

echo test3: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear in $OUT
export MEM_DEBUG=$OUT
cc -Isrc -o $EXEC src/alloc.c alloc1.c
echo Starting test3
$EXEC
echo Here are the contents of $OUT
cat $OUT
echo Done with test3
echo ""
$RM $EXEC $OUT

echo test4: building and running alloc1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
cc -Isrc -o $EXEC src/alloc.c alloc1.c
echo Starting test4
$EXEC 2>&1 | $FINDLEAKS
echo Done with test4
echo ""
$RM $EXEC

echo test5: building and running alloc1.
echo Sending memory trace to an unusable file.
echo There should be no diagnostic output, only a warning.
export MEM_DEBUG=$OUT
cc -Isrc -o $EXEC src/alloc.c alloc1.c
touch $OUT
chmod 444 $OUT
echo Starting test5
$EXEC
echo Done with test5
echo ""
$RM $EXEC $OUT

echo test6: simulate allocation failure in alloc1
echo This should produce a warning about failure to allocate x3.
export MEM_FAIL="alloc1.c:28"
cc -Isrc -o $EXEC src/alloc.c alloc1.c
echo Starting test6
$EXEC
echo Done with test6
echo ""
$RM $EXEC
