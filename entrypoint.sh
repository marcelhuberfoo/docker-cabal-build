#!/bin/sh
set -e
umask 002
export PATH=/home/$UNAME/.cabal/bin:$PATH

if [ "$1" = 'cabal' ]; then
  exec gosu $UNAME "$@"
fi
exec "$@"
