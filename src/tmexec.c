/*
   -	tmexec.c --
   -		Spawn a child process. Try to kill it later.
   -
   .	Usage:
   .		tmexec seconds command [arg arg ...]
   .
   .	Program will execute command, and send it a SIGTERM signal after
   .	seconds. Return value will be return value of command.
   .
   .	Copyright (c) 2012, Gordon D. Carrie. All rights reserved.
   .	
   .	Redistribution and use in source and binary forms, with or without
   .	modification, are permitted provided that the following conditions
   .	are met:
   .	
   .	    * Redistributions of source code must retain the above copyright
   .	    notice, this list of conditions and the following disclaimer.
   .
   .	    * Redistributions in binary form must reproduce the above copyright
   .	    notice, this list of conditions and the following disclaimer in the
   .	    documentation and/or other materials provided with the distribution.
   .	
   .	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   .	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   .	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   .	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   .	HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   .	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
   .	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   .	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   .	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   .	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   .	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: $ $Date: $
 */

#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static int handle_signals(void);
static void default_handler(int);
static void timeout_handler(int);

int main(int argc, char *argv[])
{
    char *cmd;			/* This command */
    pid_t pid;			/* Child process, specified on command line */
    int tmout;			/* Seconds allowed to child process */
    char *tmout_s;		/* tmout from command line */
    sigset_t set;		/* Signal set with timeout */
    struct sigaction act;	/* Timeout action */
    pid_t p;			/* Return from waitpid */
    int si;			/* Exit status of image generator */

    cmd = argv[0];
    if ( !handle_signals() ) {
	fprintf(stderr, "%s could not set up signal management\n", cmd);
	exit(EXIT_FAILURE);
    }
    if ( argc < 3 ) {
	fprintf(stderr, "Usage: %s seconds command [arg arg ...]\n", cmd);
	exit(EXIT_FAILURE);
    }
    tmout_s = argv[1];
    if ( sscanf(tmout_s, "%d", &tmout) != 1 ) {
	fprintf(stderr, "%s: expected an integer for timeout, got %s\n",
		cmd, tmout_s);
	exit(EXIT_FAILURE);
    }
    pid = fork();
    switch (pid) {
	case -1:
	    /*
	       Fail
	     */

	    perror("fork failed");
	    exit(EXIT_FAILURE);
	    break;
	case 0:
	    /*
	       Child process. Execute program specified on command line.
	     */

	    execvp(argv[2], argv + 2);
	    fprintf(stderr, "exec failed.\n");
	    exit(EXIT_FAILURE);
	    break;
	default:
	    /*
	       Parent. Set an alarm, and then wait for child to exit.
	     */

	    if ( sigfillset(&set) == -1
		    || sigprocmask(SIG_SETMASK, &set, NULL) == -1 ) {
		perror(NULL);
		exit(EXIT_FAILURE);
	    }
	    memset(&act, 0, sizeof(struct sigaction));
	    if ( sigfillset(&act.sa_mask) == -1 ) {
		perror(NULL);
		exit(EXIT_FAILURE);
	    }
	    act.sa_handler = timeout_handler;
	    if ( sigaction(SIGALRM, &act, NULL) == -1 ) {
		perror(NULL);
		exit(EXIT_FAILURE);
	    }
	    if ( sigemptyset(&set) == -1
		    || sigprocmask(SIG_SETMASK, &set, NULL) == -1 ) {
		perror(NULL);
		exit(EXIT_FAILURE);
	    }
	    alarm(tmout);
	    p = waitpid(pid, &si, 0);
	    if ( p == pid ) {
		if ( WIFEXITED(si) ) {
		    exit( WEXITSTATUS(si));
		} else if ( WIFSIGNALED(si) ) {
		    exit(EXIT_FAILURE);
		}
	    } else {
		perror("could not get exit status for child process");
		exit(EXIT_FAILURE);
	    }
	    return EXIT_SUCCESS;
	    break;
    }
}

/*
   For timeout, kill this process group.
 */

void timeout_handler(int signum)
{
    write(STDERR_FILENO, "tmexec and child exiting on timout\n", 35);
    kill(0, SIGKILL);
    _exit(EXIT_FAILURE);
}

/*
   Basic signal management.

   Reference --
   Rochkind, Marc J., "Advanced UNIX Programming, Second Edition",
   2004, Addison-Wesley, Boston.
 */

static int handle_signals(void)
{
    sigset_t set;
    struct sigaction act;

    if ( sigfillset(&set) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigprocmask(SIG_SETMASK, &set, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    memset(&act, 0, sizeof(struct sigaction));
    if ( sigfillset(&act.sa_mask) == -1 ) {
	perror(NULL);
	return 0;
    }

    /*
       Signals to ignore
     */

    act.sa_handler = SIG_IGN;
    if ( sigaction(SIGHUP, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGINT, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGQUIT, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGPIPE, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }

    /*
       Generic action for termination signals
     */

    act.sa_handler = default_handler;
    if ( sigaction(SIGTERM, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGSYS, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGXCPU, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigaction(SIGXFSZ, &act, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigemptyset(&set) == -1 ) {
	perror(NULL);
	return 0;
    }
    if ( sigprocmask(SIG_SETMASK, &set, NULL) == -1 ) {
	perror(NULL);
	return 0;
    }

    return 1;
}

/*
   For most signals, print an error message.
 */

void default_handler(int signum)
{
    char *msg;
    int status = EXIT_FAILURE;

    msg = "tmexec exiting                          \n";
    switch (signum) {
	case SIGQUIT:
	    msg = "tmexec exiting on quit signal           \n";
	    status = EXIT_SUCCESS;
	    break;
	case SIGTERM:
	    msg = "tmexec exiting on termination signal    \n";
	    status = EXIT_SUCCESS;
	    break;
	case SIGSYS:
	    msg = "tmexec exiting on bad system call       \n";
	    status = EXIT_FAILURE;
	    break;
	case SIGXCPU:
	    msg = "tmexec exiting: CPU time limit exceeded \n";
	    status = EXIT_FAILURE;
	    break;
    }
    _exit(write(STDERR_FILENO, msg, 41) == 41 ?  status : EXIT_FAILURE);
}
