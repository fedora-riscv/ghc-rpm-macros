#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -ne 2 ] && echo "Usage: $(basename $0) [--provides|--requires] %{buildroot}%{ghclibdir}" && exit 1

set +x

MODE=$1
PKGBASEDIR=$2
PKGCONFDIR=$PKGBASEDIR/package.conf.d

GHC_PKG="/usr/lib/rpm/ghc-pkg-wrapper $PKGBASEDIR"

case $MODE in
    --provides) field=id ;;
    --requires) field=depends ;;
    *) echo "$(basename $0): Need --provides or --requires"
       exit 1
       ;;
esac

files=$(cat)

for i in $files; do
    meta=""
    case $i in
        */libHS*_p.a)
            meta=prof
            ;;
        */libHS*.a)
            meta=devel
            ;;
    esac
    if [ -n "$meta" ]; then
        pkgver=$(basename $(dirname $i))
        ids=$($GHC_PKG field $pkgver $field | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")
        for d in $ids; do
            case $d in
                *-*) echo "ghc-${meta}($d)" ;;
            esac
        done
    fi
done
