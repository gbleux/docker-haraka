#!/bin/bash
#
# a wrapper script for the Haraka server process. when invoked with
# 'haraka' as first argument, it performs two additional steps:
# * ensure proper ownership and permissions of the persistence directories
# * capture the log statements from stdout and writes it to /logs
#
# all other arguments are passed through to the sub-command.
#
# the ownership and permissions flags is required, as docker maintains
# the settings from the host once a volume is mounted. the userid will
# most likely not match and the default bits of 0755 will prevent Haraka
# to write any data. the permission flags can be defined via the
# environment variable DOCKER_VOLUMES_CHMOD and the ownership via
# DOCKER_VOLUMES_CHOWN. if a variable is not defined, its respective
# action is not performed and the volume directories remain unchanged.
#
# logging to file is supported by Haraka, but only in daemon mode. this
# would cause the container to exit immediately. the SMTP server is
# therefor run in the forground, which causes log messages to end up
# in stdout. the wrapper script redirects it to files in /logs. in order
# to preserve log files from previous runs, a new logfile is created,
# together with a symlink pointing to the current file. the name of the
# log file can be configured via the environment variable
# HARAKA_LOG_DATE_FORMAT. its content is expected to be a valid
# date (1) format pattern.
#

set -e

FILENAME_UNIQUE=`date +%s`
HARAKA_LOG="haraka-latest.log"

function haraka_log_rotate() {
    # remove symlink in case of persistent mount
    test -e "$HARAKA_LOGS/haraka.log" && rm -f "$HARAKA_LOGS/haraka.log"
    touch "$HARAKA_LOGS/$1" && ln -s "$HARAKA_LOGS/$1" "$HARAKA_LOGS/haraka.log"
}

function haraka_chown() {
    chown -R "$1" "$HARAKA_LOGS" && \
    chown -R "$1" "$HARAKA_DATA"
}

function haraka_chmod() {
    chmod "$1" "$HARAKA_LOGS" && \
    chmod "$1" "$HARAKA_DATA"
}

function haraka_bootstrap() {
    haraka_log_rotate "$1"

    if test "x$DOCKER_VOLUMES_CHOWN" != "x";then
        haraka_chown "$DOCKER_VOLUMES_CHOWN"
    fi

    if test "x$DOCKER_VOLUMES_CHMOD" != "x";then
        haraka_chmod "$DOCKER_VOLUMES_CHMOD"
    fi
}


if test "$1" = 'haraka' -o "$#" -eq 0; then
    if test "x$HARAKA_LOG_DATE_FORMAT" != "x";then
        FILENAME_UNIQUE=`date +"$HARAKA_LOG_DATE_FORMAT"`
    fi

    HARAKA_LOG="haraka-${FILENAME_UNIQUE}.log"

    haraka_bootstrap "$HARAKA_LOG"

    exec haraka "$@" 2>&1 | tee "$HARAKA_LOGS/$HARAKA_LOG"
else
    exec "$@"
fi