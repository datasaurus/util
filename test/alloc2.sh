#!/bin/sh
#
# This script exercises alloc2.c.
#
# $Id$

EXEC=alloc2
FINDLEAKS=src/findleaks
OUT=alloc2.out
RM='rm -f'

$RM $OUT

echo test1: building and running alloc2
cc -Isrc -o $EXEC src/alloc.c alloc2.c
$EXEC
echo done with test1
$RM $EXEC

echo test2: building and running alloc2 with memory trace.
echo an account of allocations and calls to free should appear on terminal
cc -DMEM_DEBUG -Isrc -o alloc2 src/alloc.c alloc2.c
$EXEC
echo done with test2
$RM $EXEC

echo test3: building and running alloc2.
echo sending memory trace to findleaks, which should report a leak.
cc -DMEM_DEBUG -Isrc -o alloc2 src/alloc.c alloc2.c
$EXEC 2>&1 | $FINDLEAKS
echo done with test3
$RM $EXEC
