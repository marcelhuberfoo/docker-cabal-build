#!/bin/sh
set -e
umask 002
export PATH=/home/user/.cabal/bin:$PATH

if [ "$1" = 'cabal' ]; then
  exec gosu user "$@"
fi
exec "$@"
