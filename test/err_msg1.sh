#!/bin/sh
#
#- err_msg1.sh --
#-	This test application tests the error message facility defined in
#-	src/err_msg.c.  It examines a process that prints error messages.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.4 $ $Date: 2008/12/18 23:02:24 $
#
########################################################################

echo "
err_msg1.sh --

This test application tests the error message functions defined in src/err_msg.c.
See err_msg (1) for information about these functions.

It creates and examines a process that prints some error messages.

Usage suggestions:
./err_msg1.sh 2>&1 | less
To save temporary files:
env RM=: ./err_msg1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

################################################################################
"

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"
MSRC="err_msg1.c"
ASRC="$MSRC src/err_msg.c"
SRC="$ASRC src/alloc.c"
EXEC="err_msg1"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

# Here is the source code for the driver application.
cat > $MSRC << END
#include <stdio.h>
#include <alloc.h>
#include <err_msg.h>

void a(void);
void b(void);

int main(void)
{
    printf("Calling a.\n");
    a();
    printf("Error message is:\n%s\n", err_get());
    printf("Calling b.\n");
    b();
    printf("Error message is\n%s", err_get());

    return 0;
}

void a(void)
{
    b();
    err_append("This is what a has to say about it.\n");
    return;
}

void b(void)
{
    err_append("b has an error.\n");
    return;
}
END

# This is standard output from the test application.
cat > ${EXEC}.out << END
Calling a.
Error message is:
b has an error.
This is what a has to say about it.

Calling b.
Error message is
b has an error.
END

# Build the test application
if ! $CC $CFLAGS -Isrc -o $EXEC $SRC
then
    echo "Could not compile the test application"
    exit 1
fi

# Run the tests
echo "test1: normal run of $EXEC"
result1=success
if ./$EXEC | diff ${EXEC}.out -
then
    echo "$EXEC produced correct output."
else
    echo "$EXEC produced bad output!"
    result1=fail
fi
$RM ${EXEC}.out
echo "test1 result = $result1
Done with test1

################################################################################
"

echo "test2: running $EXEC with memory trace"
result2=success
export MEM_DEBUG=2
if ./$EXEC 2>&1 > /dev/null | $CHKALLOC
then
    echo "No leaks"
else
    echo "$EXEC leaks!"
    result2=fail
fi
unset MEM_DEBUG
echo "test2 result = $result2
Done with test2

################################################################################
"

echo "Summary:
test1 result = $result1
test2 result = $result2
"

$RM $MSRC $EXEC *core*

echo "$0 all done.

################################################################################
################################################################################
"
