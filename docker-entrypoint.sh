#!/bin/sh
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

HARAKA_LOG="haraka-latest.log"
HARAKA_BIN="haraka"

# create a new log file and a symbolic link named 'haraka.log'
# to that file in the same directory. the symbolic link is
# overwritten if it exists.
# @param $1 {String} log filename (without directory path)
haraka_log_rotate() {
    # remove symlink in case of persistent mount
    test -e "$HARAKA_LOGS/haraka.log" && rm -f "$HARAKA_LOGS/haraka.log"
    touch "$HARAKA_LOGS/$1" && ln -s "$HARAKA_LOGS/$1" "$HARAKA_LOGS/haraka.log"
}

# change the ownership of the haraka persistence volumes.
# @param $1 {String} chown ownership rule
haraka_chown() {
    chown -R "$1" "$HARAKA_LOGS" && \
    chown -R "$1" "$HARAKA_DATA"
}

# change the permission flags of the haraka persistence volumes.
# @param $1 {String} chmod permission flags
haraka_chmod() {
    chmod "$1" "$HARAKA_LOGS" && \
    chmod "$1" "$HARAKA_DATA"
}

# set the filename of the log output. if the environment variable
# 'HARAKA_LOG_DATE_FORMAT' is set, it is used to generate the filename
# postfix using the 'date' command. the default is to use 'date +%s' as
# the filename postfix.
configure_log_filename() {
    HARAKA_LOG_IDENT=`date +%s`

    if test "x$HARAKA_LOG_DATE_FORMAT" != "x";then
        HARAKA_LOG_IDENT=`date +"$HARAKA_LOG_DATE_FORMAT"`
    fi

    HARAKA_LOG="haraka-${HARAKA_LOG_IDENT}.log"
}

# perform pre-boot actions before the SMTP server starts.
haraka_bootstrap() {
    configure_log_filename
    haraka_log_rotate "$HARAKA_LOG"

    if test "x$DOCKER_VOLUMES_CHOWN" != "x";then
        haraka_chown "$DOCKER_VOLUMES_CHOWN" || return 1
    fi

    if test "x$DOCKER_VOLUMES_CHMOD" != "x";then
        haraka_chmod "$DOCKER_VOLUMES_CHMOD" || return 1
    fi

    return 0
}

# ensure the environment has been set up correctly.
# @return {Number} a value greater than zero if anything is not OK
validate_haraka_env() {
    if test "x$HARAKA_LOGS" = "x";then
        echo "Haraka logs directory has not been set." 1>&2

        return 1
    fi

    if test "x$HARAKA_DATA" = "x";then
        echo "Haraka data directory has not been set." 1>&2

        return 1
    fi

    return 0
}

# script entry point
main() {
    if test "$1" = 'haraka' -o $# -eq 0; then
        validate_haraka_env || exit 1
        haraka_bootstrap || exit 2

        exec "$HARAKA_BIN" "$@" 2>&1 | tee "$HARAKA_LOGS/$HARAKA_LOG"
    else
        exec "$@"
    fi
}

main "$@"