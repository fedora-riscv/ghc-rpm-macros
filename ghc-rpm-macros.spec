%global debug_package %{nil}

%global macros_file %{_sysconfdir}/rpm/macros.ghc

Name:           ghc-rpm-macros
Version:        0.15.5
Release:        1%{?dist}
Summary:        Macros for building packages for GHC

Group:          Development/Libraries
License:        GPLv3
URL:            https://fedoraproject.org/wiki/Haskell_SIG

# This is a Fedora maintained package which is specific to
# our distribution.  Thus the source is only available from
# within this srpm.
Source0:        ghc-rpm-macros.ghc
Source1:        COPYING
Source2:        AUTHORS
Source3:        ghc-deps.sh
Requires:       redhat-rpm-config

%description
A set of macros for building GHC packages following the Haskell Guidelines
of the Fedora Haskell SIG.  ghc needs to be installed in order to make use of
these macros.


%prep
%setup -c -T
cp %{SOURCE1} %{SOURCE2} .


%build
echo no build stage needed


%install
install -p -D -m 0644 %{SOURCE0} ${RPM_BUILD_ROOT}/%{macros_file}

install -p -D -m 0755 %{SOURCE3} %{buildroot}/%{_prefix}/lib/rpm/ghc-deps.sh

# this is why this package is now arch-dependent:
# turn off shared libs and dynamic linking on secondary archs
%ifnarch %{ix86} x86_64
cat >> %{buildroot}/%{macros_file} <<EOF

# shared libraries are only supported on primary intel archs
%%ghc_without_dynamic 1
%%ghc_without_shared 1
EOF
%endif


%files
%doc COPYING AUTHORS
%config(noreplace) %{macros_file}
%{_prefix}/lib/rpm/ghc-deps.sh


%changelog
* Thu Feb 23 2012 Jens Petersen <petersen@redhat.com> - 0.15.5-1
- fix handling of devel docdir for non-shared builds
- simplify ghc_bootstrap

* Thu Jan 19 2012 Jens Petersen <petersen@redhat.com> - 0.15.4-1
- allow dynamic linking of Setup with ghc_without_shared set

* Fri Jan  6 2012 Jens Petersen <petersen@redhat.com> - 0.15.3-1
- new ghc_add_basepkg_file to add a path to base lib package filelist

* Wed Dec 28 2011 Jens Petersen <petersen@redhat.com> - 0.15.2-1
- add ghc_devel_post_postun to help koji/mock with new macros

* Tue Dec 27 2011 Jens Petersen <petersen@redhat.com> - 0.15.1-1
- add ghc_package, ghc_description, ghc_devel_package, ghc_devel_description

* Tue Dec 27 2011 Jens Petersen <petersen@redhat.com> - 0.15-1
- new ghc_files wrapper macro for files which takes base doc files as args
  and uses new ghc_shared_files and ghc_devel_files macros
- when building for non-shared archs move installed docfiles to devel docdir

* Fri Dec  2 2011 Jens Petersen <petersen@redhat.com> - 0.14.3-1
- do not use ghc user config by default when compiling Setup
- do not setup hscolour if without_hscolour defined

* Thu Nov 17 2011 Jens Petersen <petersen@redhat.com> - 0.14.2-1
- test for HsColour directly when running "cabal haddock" instead of
  check hscolour is available (reported by Giam Teck Choon, #753833)

* Sat Nov 12 2011 Jens Petersen <petersen@redhat.com> - 0.14.1-1
- fix double listing of docdir in base lib package

* Tue Nov  1 2011 Jens Petersen <petersen@redhat.com> - 0.14-1
- replace devel ghc requires with ghc-compiler
- disable testsuite in ghc_bootstrap

* Mon Oct 17 2011 Jens Petersen <petersen@redhat.com> - 0.13.13-1
- add ghc_bootstrapping to ghc_bootstrap for packages other than ghc
- make ghc-deps.sh also work when bootstrapping a new ghc version

* Sat Oct 15 2011 Jens Petersen <petersen@redhat.com> - 0.13.12-1
- add ghc_exclude_docdir to exclude docdir from filelists

* Fri Sep 30 2011 Jens Petersen <petersen@redhat.com> - 0.13.11-1
- fix devel subpackage's prof and doc obsoletes and provides versions
  for multiple lib packages like ghc (reported by Henrik Nordström)

* Tue Sep 13 2011 Jens Petersen <petersen@redhat.com> - 0.13.10-1
- do not setup ghc-deps.sh when ghc_bootstrapping
- add ghc_test build config

* Wed Aug  3 2011 Jens Petersen <petersen@redhat.com> - 0.13.9-1
- drop without_testsuite from ghc_bootstrap since it breaks koji

* Fri Jul  1 2011 Jens Petersen <petersen@redhat.com> - 0.13.8-1
- drop redundant defattr from filelists
- move dependency generator setup from ghc_package_devel to ghc_lib_install
  in line with ghc_bin_install

* Mon Jun 27 2011 Jens Petersen <petersen@redhat.com> - 0.13.7-1
- add requires for redhat-rpm-config for ghc_arches
- drop ghc_bootstrapping from ghc_bootstrap: doesn't work for koji

* Fri Jun 17 2011 Jens Petersen <petersen@redhat.com> - 0.13.6-1
- also set ghc_without_dynamic for ghc_bootstrap
- drop without_hscolour from ghc_bootstrap: doesn't work for koji

* Fri Jun 17 2011 Jens Petersen <petersen@redhat.com> - 0.13.5-1
- ghc_bootstrap is now a macro which sets ghc_bootstrapping,
  ghc_without_shared, without_prof, without_haddock, without_hscolour,
  without_manual, without_testsuite
- tweaks to ghc_check_bootstrap

* Fri Jun 17 2011 Jens Petersen <petersen@redhat.com> - 0.13.4-1
- add ghc_check_bootstrap

* Thu Jun  2 2011 Jens Petersen <petersen@redhat.com> - 0.13.3-1
- rename macros.ghc-pkg back to macros.ghc
- move the devel summary prefix back to a suffix

* Sat May 28 2011 Jens Petersen <petersen@redhat.com> - 0.13.2-1
- macros need to live in /etc/rpm
- use macro_file for macros.ghc filepath

* Sat May 28 2011 Jens Petersen <petersen@redhat.com> - 0.13.1-1
- move macros.ghc to /usr/lib/rpm to avoid conflict with redhat-rpm-config

* Wed May 11 2011 Jens Petersen <petersen@redhat.com> - 0.13-1
- merge prof subpackages into devel to simplify packaging

* Mon May  9 2011 Jens Petersen <petersen@redhat.com> - 0.12.1-1
- include ghc_pkg_c_deps even when -c option used

* Sat May  7 2011 Jens Petersen <petersen@redhat.com> - 0.12.0-1
- drop ghc_pkg_deps from ghc_package_devel and ghc_package_prof since
  ghc-deps.sh generates better inter-package dependencies already
- condition --htmldir on pkg_name

* Fri Apr  1 2011 Jens Petersen <petersen@redhat.com> - 0.11.14-1
- provides ghc-*-doc still needed for current lib templates

* Mon Mar 28 2011 Jens Petersen <petersen@redhat.com> - 0.11.13-1
- ghc-deps.sh: check PKGBASEDIR exists to avoid warning for bin package
- abort cabal_configure if ghc is not self-bootstrapped
- make ghc_reindex_haddock a safe no-op
- no longer provide ghc-*-doc
- no longer run ghc_reindex_haddock in ghc-*-devel scripts

* Wed Mar 16 2011 Jens Petersen <petersen@redhat.com> - 0.10.52-1
- backport ghc fixes and secondary arch support from 0.11.12:
- add ghc_pkg_obsoletes to binlib base lib package too
- add docdir when subpackaging packages too
- this package is now arch-dependent
- rename without_shared to ghc_without_shared and without_dynamic
  to ghc_without_dynamic so that they can be globally defined for
  secondary archs without shared libs
- use %%undefined macro
- disable debug_package in ghc_bin_build and ghc_lib_build
- set ghc_without_shared and ghc_without_dynamic on secondary
  (ie non main intel) archs
- disable debuginfo for self
- only link Setup dynamically if without_shared and without_dynamic not set
- add cabal_configure_options to pass extra options to cabal_configure

* Fri Feb  4 2011 Jens Petersen <petersen@redhat.com> - 0.10.51-1
- ghc_binlib_package's -x option does not take an arg

* Sat Jan 29 2011 Jens Petersen <petersen@redhat.com> - 0.10.50-1
- merge subpackaging support from 0.11.4:
- drop ghcdocdir and ghcpkgdir
- new ghclibdocdir
- improve prof summary and description
- add without_prof and without_haddock option macros
- add ghc_binlib_package option to exclude package from ghc_packages_list
- condition lib base package additional description for srpm
- use buildroot instead of RPM_BUILD_ROOT
- rename ghcpkgbasedir to ghclibdir
- move name and version macro options (-n and -v) to optional args
- ghc_gen_filelists, ghc_lib_build, ghc_lib_install, cabal_pkg_conf
  now take optional "[name] [version]" args
- drop with_devhelp since --html-help option gone from haddock-2.8.0
- rename ghc_requires to ghc_devel_requires
- drop ghc_doc_requires

* Wed Dec 29 2010 Jens Petersen <petersen@redhat.com> - 0.8.3-1
- revert disabling debug_package, since with redhat-rpm-config installed
  the behaviour depended on the position of ghc_lib_package in the spec file
  (reported by narasim)

* Thu Sep 30 2010 Jens Petersen <petersen@redhat.com> - 0.8.2-1
- add ghc_pkg_obsoletes for obsoleting old packages
- always obsolete -doc packages, but keep -o for now for backward compatibility
- disable debuginfo by default
- make shared and hscolour default
- use without_shared and without_hscolour to disable them
- fix without_shared build so it actually works
- use ghcpkgbasedir

* Fri Jul 16 2010 Jens Petersen <petersen@redhat.com> - 0.8.1-1
- fix ghc_strip_dynlinked when no dynlinked files
- devel should provide doc also when not obsoleting

* Fri Jul 16 2010 Jens Petersen <petersen@redhat.com> - 0.8.0-1
- merge -doc into -devel and provide -o obsoletes doc subpackage option

* Mon Jun 28 2010 Jens Petersen <petersen@redhat.com> - 0.7.1-1
- support hscolour'ing of src from haddock
- really remove redundant summary and description option flags

* Sat Jun 26 2010 Jens Petersen <petersen@redhat.com> - 0.7.0-1
- new ghc_bin_build, ghc_bin_install, ghc_lib_build, ghc_lib_install

* Thu Jun 24 2010 Jens Petersen <petersen@redhat.com> - 0.6.2-1
- a couple more fallback summary tweaks

* Thu Jun 24 2010 Jens Petersen <petersen@redhat.com> - 0.6.1-1
- drop the summary -s and description -d package options since rpm does not
  seem to allow white\ space in macro option args anyway

* Wed Jun 23 2010 Jens Petersen <petersen@redhat.com> - 0.6.0-1
- make ghc_strip_dynlinked conditional on no debug_package

* Wed Jun 23 2010 Jens Petersen <petersen@redhat.com> - 0.5.9-1
- replace ghc_strip_shared with ghc_strip_dynlinked

* Sun Jun 20 2010 Jens Petersen <petersen@redhat.com> - 0.5.8-1
- add ghc_strip_shared to strip shared libraries

* Sun Jun 20 2010 Jens Petersen <petersen@redhat.com> - 0.5.7-1
- add comments over macros
- drop unused cabal_makefile

* Mon Apr 12 2010 Jens Petersen <petersen@redhat.com> - 0.5.6-1
- drop unused ghc_pkg_ver macro
- add ghc_pkg_recache macro

* Fri Jan 15 2010 Jens Petersen <petersen@redhat.com> - 0.5.5-1
- drop optional 2nd version arg from ghcdocdir, ghcpkgdir, and
  ghc_gen_filelists: multiversion subpackages are not supported
- add ghcpkgbasedir
- bring back some shared conditions which were dropped temporarily
- test for ghcpkgdir and ghcdocdir in ghc_gen_filelists
- allow optional pkgname arg for cabal_pkg_conf
- can now package gtk2hs

* Mon Jan 11 2010 Jens Petersen <petersen@redhat.com> - 0.5.4-1
- use -v in ghc_requires and ghc_prof_requires for version

* Mon Jan 11 2010 Jens Petersen <petersen@redhat.com> - 0.5.3-1
- drop "Library for" from base lib summary

* Mon Jan 11 2010 Jens Petersen <petersen@redhat.com> - 0.5.2-1
- use -n in ghc_requires and ghc_prof_requires for when no pkg_name

* Mon Jan 11 2010 Jens Petersen <petersen@redhat.com> - 0.5.1-1
- add ghcdocbasedir
- revert ghcdocdir to match upstream ghc
- ghcdocdir and ghcpkgdir now take optional name version args
- update ghc_gen_filelists to new optional name version args
- handle docdir in ghc_gen_filelists
- ghc_reindex_haddock uses ghcdocbasedir
- summary and description options to ghc_binlib_package, ghc_package_devel,
  ghc_package_doc, and ghc_package_prof

* Sun Jan 10 2010 Jens Petersen <petersen@redhat.com> - 0.5.0-1
- pkg_name must be set now for binlib packages too
- new ghc_lib_package and ghc_binlib_package macros make packaging too easy
- ghc_package_devel, ghc_package_doc, and ghc_package_prof helper macros
- ghc_gen_filelists now defaults to ghc-%%{pkg_name}
- add dynamic bcond to cabal_configure instead of cabal_configure_dynamic

* Thu Dec 24 2009 Jens Petersen <petersen@redhat.com> - 0.4.0-1
- add cabal_configure_dynamic
- add ghc_requires, ghc_doc_requires, ghc_prof_requires

* Tue Dec 15 2009 Jens Petersen <petersen@redhat.com> - 0.3.1-1
- use ghc_version_override to override ghc_version
- fix pkg .conf filelist match

* Sat Dec 12 2009 Jens Petersen <petersen@redhat.com> - 0.3.0-1
- major updates for ghc-6.12, package.conf.d, and shared libraries
- add shared support to cabal_configure, ghc_gen_filelists
- version ghcdocdir
- replace ghc_gen_scripts, ghc_install_scripts, ghc_register_pkg, ghc_unregister_pkg
  with cabal_pkg_conf
- allow (ghc to) override ghc_version

* Mon Nov 16 2009 Jens Petersen <petersen@redhat.com> - 0.2.5-1
- make ghc_pkg_ver only return pkg version

* Mon Nov 16 2009 Jens Petersen <petersen@redhat.com> - 0.2.4-1
- change GHCRequires to ghc_pkg_ver

* Mon Nov 16 2009 Jens Petersen <petersen@redhat.com> - 0.2.3-1
- use the latest installed pkg version for %%GHCRequires

* Mon Nov 16 2009 Jens Petersen <petersen@redhat.com> - 0.2.2-1
- add %%GHCRequires for automatically versioned library deps

* Tue Sep 22 2009 Jens Petersen <petersen@redhat.com> - 0.2.1-2
- no, revert versioned ghcdocdir again!

* Tue Sep 22 2009 Jens Petersen <petersen@redhat.com> - 0.2.1-1
- version ghcdocdir to allow multiple doc versions like ghcpkgdir

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Tue Jun  9 2009 Jens Petersen <petersen@redhat.com> - 0.2-1
- drop version from ghcdocdir since it breaks haddock indexing

* Wed May 13 2009 Yaakov M. Nemoy <ynemoy@fedoraproject.org> - 0.1-7
- specifies the macros file as a %%conf

* Sat May  9 2009 Yaakov M. Nemoy <ynemoy@fedoraproject.org> - 0.1-6
- removes archs and replaces with noarch
- bumps to avoid conflicts with jens

* Fri May  8 2009 Jens Petersen <petersen@redhat.com> - 0.1-5
- make it arch specific to fedora ghc archs
- setup a build dir so it can build from the current working dir

* Wed May  6 2009 Yaakov M. Nemoy <ynemoy@fedoraproject.org> - 0.1-4
- renamed license file
- removed some extraneous comments needed only at review time

* Wed May  6 2009 Yaakov M. Nemoy <ynemoy@fedoraproject.org> - 0.1-3
- updated license to GPLv3
- added AUTHORS file

* Tue May  5 2009 Yaakov M. Nemoy <ghc@hexago.nl> - 0.1-2
- moved copying license from %%build to %%prep

* Mon May  4 2009 Yaakov M. Nemoy <ghc@hexago.nl> - 0.1-1
- creation of package

