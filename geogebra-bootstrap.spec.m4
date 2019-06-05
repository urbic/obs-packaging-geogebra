#
`#' spec file for a build-time dependency of project "__NAME__"
#
# Copyright (c) 2018 tz
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

Name:			__NAME__-bootstrap
Version:		__VERSION__
Release:		0
License:		SUSE-NonFree
Summary:		Build-time dependency of project "%{name}"
Url:			https://github.com/urbic/obs-packaging-geogebra
Group:			Development/Libraries/Java
Source0:		%{name}-%{version}.tar.xz
BuildRoot:		%{_tmppath}/%{name}-%{version}-build
#BuildArch:		noarch
ExclusiveArch:	x86_64

%description
This package has been automatically created in order to satisfy build time
dependencies of Java packages. It should not be used except for rebuilding
other packages, thus it should never be installed on end users' systems.

%prep
%setup -q -T -D -n .

%build
# nothing to do, precompiled by design

%install
export NO_BRP_CHECK_BYTECODE_VERSION=true
install -dm0755 %{buildroot}%{_libdir}/%{name}
install -m0644 %{S:0} %{buildroot}%{_libdir}/%{name}

%files
%defattr(-,root,root)
%{_libdir}/%{name}

%changelog
