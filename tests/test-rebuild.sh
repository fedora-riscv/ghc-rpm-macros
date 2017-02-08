#!/bin/sh

# for testing updates to ghc-rpm-macros etc
# In a pkg dir run
#   $ ./test-rebuild.sh
# or clone a pkg branch:
#   $ ./test-rebuild.sh [pkg]

set -e

PKG=${1:-$(fedpkg gimmespec | sed -e "s/.spec//")}

[ -d "$PKG" -o -f "$PKG.spec" ] || fedpkg clone -a $PKG

[ -d "$PKG" ] && cd $PKG

ARCH=$(arch)

#if [ -d $ARCH ]; then
#  echo Please move existing $ARCH/
#  exit 1
#fi

if [ -f /etc/os-release ]; then
    eval $(grep VERSION_ID /etc/os-release)
    case $VERSION_ID in
        26) BRANCH=master ;;
        7.*) BRANCH=epel7 ;;
        *) BRANCH="f$VERSION_ID" ;;
    esac
else
# assume RHEL6
    BRANCH=el6
fi

if [ "* $BRANCH" != "$(git branch | grep '^*')" ]; then
  fedpkg switch-branch $BRANCH
fi

if [ "* $BRANCH" != "$(git branch | grep '^*')" ]; then
  echo "Git branch does not match Fedora installation!"
  exit 1
fi

git pull

echo Running dnf builddep:
sudo dnf builddep $PKG.spec

fedpkg local

VERREL=$(fedpkg verrel | sed -e "s/^$PKG-//")

TMP=test-tmp

mkdir -p $TMP/

PKGS=$(cd $ARCH; rpm -qp $(ls *-$VERREL*.rpm))

for i in $PKGS; do
  # FIXME: should check NVR is same before building
  rpm -q --quiet $i || sudo yum install -q $i
  for k in list requires provides scripts; do
    rpm -qp --$k $ARCH/$i.rpm | grep -v rpmlib > $TMP/$i.$k.test || :
    rpm -q --$k $i | grep -v rpmlib > $TMP/$i.$k.installed || :
    diff -u $TMP/$i.$k.installed $TMP/$i.$k.test || :
  done
done
