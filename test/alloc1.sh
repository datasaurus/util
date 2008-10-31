#!/bin/sh
#
# This script exercises alloc1.c.
#
# $Id$

EXEC=alloc1
FINDLEAKS=src/findleaks
OUT=alloc1.out
RM='rm -f'

$RM $OUT

echo test1: building and running alloc1
cc -Isrc -o $EXEC src/alloc.c alloc1.c
$EXEC
echo done with test1
$RM $EXEC

echo test2: building and running alloc1 with memory trace.
echo an account of allocations and calls to free should appear on terminal
cc -DMEM_DEBUG -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC
echo done with test2
$RM $EXEC

echo test3: building and running alloc1 with memory trace.
echo an account of allocations and calls to free should appear in $OUT
echo contents of $OUT should resemble output from test2
cc -DMEM_DEBUG -DMEM_DEBUG_OUT=3 -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC 3> $OUT
echo done with test3
$RM $EXEC

echo test4: building and running alloc1.
echo sending memory trace to findleaks, which should not find anything.
cc -DMEM_DEBUG -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC 2>&1 | $FINDLEAKS
echo done with test4
$RM $EXEC
