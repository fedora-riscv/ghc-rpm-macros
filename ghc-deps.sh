#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -ne 2 ] && echo "Usage: `basename $0` [--provides|--requires] %{buildroot}%{ghclibdir}" && exit 1

set +x

mode=$1
pkgbasedir=$2
pkgconfdir=$pkgbasedir/package.conf.d

ghc_pkg="/usr/lib/rpm/ghc-pkg-wrapper $pkgbasedir"

case $mode in
    --provides) field=id ;;
    --requires) field=depends ;;
    *) echo "`basename $0`: Need --provides or --requires" ; exit 1
esac

files=$(cat)

for i in $files; do
    case $i in
        # exclude builtin_rts.conf
	$pkgconfdir/*-*.conf)
	    id=$(grep "id: " $i | sed -e "s/id: //")
	    ids=$($ghc_pkg field $id $field | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")

	    for d in $ids; do
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
