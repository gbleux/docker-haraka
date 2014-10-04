#!/bin/sh
#
# wrapper script for haraka which fixes the permissions of the
# persistence layer of the docker container
#

HARAKA_USER=haraka
HARAKA_GROUP=haraka

for HARAKA_PERSISTENCE in /app /data /logs;do
    chown -R "$HARAKA_USER:$HARAKA_GROUP" "$HARAKA_PERSISTENCE"
done
unset HARAKA_PERSISTENCE
unset HARAKA_USER
unset HARAKA_GROUP

exec /usr/local/bin/haraka --configs "/app" "$@"