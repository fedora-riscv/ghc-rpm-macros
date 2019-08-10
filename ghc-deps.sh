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
        # exclude rts.conf
        $pkgconfdir/*-*.conf)
            name=$(grep "^name: " $i | sed -e "s/name: //")
            ids=$($GHC_PKG field $name $field | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")
            for d in $ids; do
                case $d in
                    *-*) echo "ghc-devel($d)" ;;
                    *) ;;
                esac
            done
            ;;
        */libHS*_p.a)
            pkgver=$(basename $(dirname $i))
            ids=$($GHC_PKG field $pkgver $field | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")
            for d in $ids; do
                case $d in
                    *-*)
                        case $field in
                            id)
                                echo "ghc-prof($d)"
                                ;;
                            *)
                                if [ -f "$PKGBASEDIR/$pkgver/libHS${d}_p.a" -o -f "/usr/lib*/ghc-*/$pkgver/libHS${d}_p.a" ]; then
                                    echo "ghc-prof($d)"
                                fi
                                ;;
                        esac
                        ;;
                esac
            done
            ;;
    esac
done
