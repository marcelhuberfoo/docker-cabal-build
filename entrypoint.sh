#!/bin/sh
set -e
umask 002
export PATH=$HOME/.cabal/bin:$PATH

exec "$@"
