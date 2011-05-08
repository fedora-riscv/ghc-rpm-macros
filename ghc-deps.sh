#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

# To use add the following lines to spec file:
#   %define _use_internal_dependency_generator 0
#   %define __find_requires /usr/lib/rpm/ghc-deps.sh --requires %{buildroot}%{ghcpkgbasedir}

[ $# -ne 2 ] && echo "Usage: `basename $0` --requires %{buildroot}" && exit 1

MODE=$1
PKGBASEDIR=$2
PKGCONFDIR=$PKGBASEDIR/package.conf.d

case $MODE in
    --requires) FIELD=depends ;;
    *) echo "`basename $0`: Need --requires" ; exit 1
esac

if [ -d "$PKGBASEDIR" ]; then
  SHARED=$(find $PKGBASEDIR -type f -name '*.so')
fi

GHCVERSION=$(ghc --numeric-version)

files=$(cat)

#set -x

for i in $files; do
    LIB_FILE=$(echo $i | grep /libHS | egrep -v "$PKGBASEDIR/libHS")
    if [ "$LIB_FILE" ]; then
	if [ -d "$PKGCONFDIR" ]; then
	    DEP=""
	    case $LIB_FILE in
		*.so) ;;
		*_p.a) DEP=ghc-\\1-prof ;;
		*.a) DEP=ghc-\\1-devel ;;
	    esac
	    if [ "$DEP" ]; then
		PKGVER=$(echo $LIB_FILE | sed -e "s%$PKGBASEDIR/\([^/]\+\)/libHS.*%\1%")
		HASHS=$(ghc-pkg -f $PKGCONFDIR field $PKGVER $FIELD | sed -e "s/^$FIELD: \+//")
		for i in $HASHS; do
		    case $i in
			*-*) echo $i | sed -e "s/\(.*\)-\(.*\)-.*/$DEP = \2/" ;;
			*) ;;
		    esac
		done
	    fi
	fi
    fi
done

echo $files | tr [:blank:] '\n' | /usr/lib/rpm/rpmdeps $MODE
