#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -lt 3 ] && echo "Usage: $(basename "$0") [--provides|--requires] %{buildroot} %{ghclibdir} [ghc-version]" && exit 1

set +x -e

MODE=$1
BUILDROOT=$2
PKGBASEDIR=$3
if [ -z "$4" ];
then GHCPREFIX=ghc
else GHCPREFIX=$4
fi
if [ -d "$BUILDROOT$PKGBASEDIR/lib" ];
then PKGBASELIB=$PKGBASEDIR/lib
else PKGBASELIB=$PKGBASEDIR
fi
PKGCONFDIR=$PKGBASELIB/package.conf.d

GHC_PKG="/usr/lib/rpm/ghc-pkg-wrapper $BUILDROOT$PKGBASEDIR"

case $MODE in
    --provides) field=id ;;
    --requires) field=depends ;;
    *) echo "$(basename "$0"): Need --provides or --requires"
       exit 1
       ;;
esac

files=$(cat)

(
for i in $files; do
    case $i in
        # exclude rts.conf
        $BUILDROOT$PKGCONFDIR/*-*.conf)
            name=$(grep "^name: " "$i" | sed -e "s/name: *//")
            ids=$($GHC_PKG field "$name" "$field" | sed -e "s/\(^\| \)rts\( \|$\)/ /")
            for d in $ids; do
                case $d in
                    *-*-internal) ;;
                    *-*) echo "$GHCPREFIX-devel($d)" ;;
                    *) ;;
                esac
            done
            ;;
        */libHS*_p.a)
            pkgver=$(basename "$(dirname "$i")")
            if [ -e "$BUILDROOT$PKGCONFDIR/$pkgver.conf" ]; then
                ids=$($GHC_PKG field "$pkgver" "$field" | sed -e "s/\(^\| \)rts\( \|$\)/ /" -e "s/bin-package-db-[^ ]\+//")
            else
                conf=$(basename "$i" | sed -e "s%libHS%$BUILDROOT$PKGCONFDIR/%" -e 's%_p.a%.conf%')
                name=$(grep "^name: " "$conf" | sed -e "s/name: *//")
                ids=$($GHC_PKG field "$name" "$field" | sed -e "s/\(^\| \)rts\( \|$\)/ /" -e "s/bin-package-db-[^ ]\+//")
            fi
            for d in $ids; do
                case $d in
                    *-*-internal) ;;
                    *-*)
                        case $field in
                            id)
                                echo "$GHCPREFIX-prof($d)"
                                ;;
                            *)
                                if [ -f "$PKGBASELIB"/*/libHS"${d}"_p.a -o -f "$BUILDROOT$PKGBASELIB"/*/libHS"${d}"_p.a -o -f "$PKGBASELIB"/*/*/libHS"${d}"_p.a -o -f "$BUILDROOT$PKGBASELIB"/*/*/libHS"${d}"_p.a ]; then
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
) | sort | uniq
