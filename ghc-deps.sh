#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -lt 2 ] && echo "Usage: $(basename $0) [--provides|--requires] %{buildroot}%{ghclibdir} [%{?ghc_name}]" && exit 1

set +x

MODE=$1
PKGBASEDIR=$2
if [ -z "$3" ];
then GHCPREFIX=ghc
else GHCPREFIX=$3
fi
if [ -d $PKGBASEDIR/lib ];
then PKGBASELIB=$PKGBASEDIR/lib
     LIB=lib/
else PKGBASELIB=$PKGBASEDIR
fi
PKGCONFDIR=$PKGBASELIB/package.conf.d

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
        # exclude rts.conf
        $PKGCONFDIR/*-*.conf)
            name=$(grep "^name: " $i | sed -e "s/name: //")
            ids=$($GHC_PKG field $name $field | sed -e "s/ rts / /")
            for d in $ids; do
                case $d in
                    *-*-internal) ;;
                    *-*) echo "$GHCPREFIX-devel($d)" ;;
                    *) ;;
                esac
            done
            ;;
        */libHS*_p.a)
            pkgver=$(basename $(dirname $i))
            ids=$($GHC_PKG field $pkgver $field | sed -e "s/ rts / /" -e "s/bin-package-db-[^ ]\+//")
            for d in $ids; do
                case $d in
                    *-*-internal) ;;
                    *-*)
                        case $field in
                            id)
                                echo "$GHCPREFIX-prof($d)"
                                ;;
                            *)
                                if [ -f /usr/lib*/ghc-*/$LIB*/libHS${d}_p.a -o -f $PKGBASELIB/*/libHS${d}_p.a ]; then
                                    echo "$GHCPREFIX-prof($d)"
                                fi
                                ;;
                        esac
                        ;;
                esac
            done
            ;;
    esac
done
