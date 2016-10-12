#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -ne 2 ] && echo "Usage: `basename $0` [--provides|--requires] %{buildroot}%{ghclibdir}" && exit 1

set +x

MODE=$1
PKGBASEDIR=$2
PKGCONFDIR=$PKGBASEDIR/package.conf.d

GHC_PKG="/usr/lib/rpm/ghc-pkg-wrapper $PKGBASEDIR"

case $MODE in
    --provides) FIELD=id ;;
    --requires) FIELD=depends ;;
    *) echo "`basename $0`: Need --provides or --requires" ; exit 1
esac

files=$(cat)

for i in $files; do
    case $i in
        # exclude builtin_rts.conf
	$PKGCONFDIR/*-*.conf)
	    PKGVER=$(echo $i | sed -e "s%$PKGCONFDIR/\(.\+\)-.\+.conf%\1%")
	    OUT=$($GHC_PKG field $PKGVER $FIELD | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")
	    for d in $OUT; do
		case $d in
		    *-*) echo "ghc-devel($d)" ;;
		    *) ;;
		esac
	    done
	    ;;
        *)
            ;;
    esac
done
