#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -ne 2 ] && echo "Usage: `basename $0` [--provides|--requires] %{buildroot}%{ghclibdir}" && exit 1

set +x

MODE=$1
PKGBASEDIR=$2
PKGCONFDIR=$PKGBASEDIR/package.conf.d
GHC_VER=$(basename $PKGBASEDIR | sed -e s/ghc-//)

GHC_PKG="/usr/lib/rpm/ghc-pkg-wrapper $PKGBASEDIR"

case $MODE in
    --provides) FIELD=id ;;
    --requires) FIELD=depends ;;
    *) echo "`basename $0`: Need --provides or --requires" ; exit 1
esac

files=$(cat)

for i in $files; do
    META=""
    SELF=""
    case $i in
        */libHSrts.*) ;;
        */libHS*_p.a) ;;
        */libHS*.so)
            META=ghc
	    PKGVER=$(echo $i | sed -e "s%$PKGBASEDIR/[^/]\+/libHS\(.\+-[0-9.]\+\)\(-.\+\)\?-ghc${GHC_VER}\.so%\1%")
            ;;
        */libHS*.a)
            META=ghc-devel
	    PKGVER=$(echo $i | sed -e "s%$PKGBASEDIR/[^/]\+/libHS\(.\+-[0-9.]\+\)\(-.\+\)\?\.a%\1%")
	    if [ -f $PKGBASEDIR/$PKGVER/libHS$PKGVER-ghc${GHC_VER}.so ]; then
		SELF=ghc
	    fi
            ;;
    esac
    if [ "$META" -a -d "$PKGCONFDIR" ]; then
	HASHS=$(${GHC_PKG} field $PKGVER $FIELD)
	for i in $HASHS; do
	    case $i in
		*-*) echo "$META($i)" ;;
		*) ;;
	    esac
	done
	if [ "$MODE" = "--requires" -a "$SELF" ]; then
	    HASHS=$(${GHC_PKG} field $PKGVER id | sed -e "s/^id: \+//")
	    for i in $HASHS; do
		echo "$SELF($i)"
	    done
	fi
    elif [ "$MODE" = "--requires" ]; then
	if file $i | grep -q 'executable, .* dynamically linked'; then
	    BIN_DEPS=$(objdump -p $i | grep NEEDED | grep libHS | grep -v libHSrts | sed -e "s%^ *NEEDED *libHS\(.*\)-ghc${GHC_VER}\.so%\1%")
	    for p in ${BIN_DEPS}; do
		HASH=$(${GHC_PKG} field $p id | uniq)
		echo "ghc($HASH)"
	    done
	fi
    fi
done
