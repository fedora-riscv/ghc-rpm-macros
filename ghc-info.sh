#!/bin/sh

[ $# -lt 2 ] && echo "Usage: $(basename "$0") GHCVERSION INFOFIELD"

GHCVER=$1
FIELD=$2

/usr/bin/ghc-${GHCVER} --info | grep \"$FIELD\" | sed -e 's/.*","\(.*\)")/\1/'
