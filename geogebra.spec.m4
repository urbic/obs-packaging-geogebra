#
`#' spec file for "__NAME__"
#
# Copyright (c) 2019 tz
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           __NAME__
Version:        __VERSION__
Release:        1
License:        SUSE-NonFree AND GPL-3.0-or-later
Summary:        Free mathematics software for learning and teaching
Url:            https://www.geogebra.org/
Group:          Productivity/Scientific/Math
Source0:        %{name}-%{version}.tar.xz
Source1:        %{name}.desktop
Source2:        %{name}.mime
Patch0:         %{name}-001.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  xz
BuildRequires:  java-devel >= 11
BuildRequires:  openjfx
BuildRequires:  unzip
BuildRequires:  %{name}-bootstrap == %{version}
#Provides:       mvn(:) == 
ExclusiveArch:  x86_64
Requires:       java >= 11
Requires:       jlatexmath
Requires:       jna
Requires:		openjfx

BuildRequires:	update-desktop-files
Requires(post):	update-desktop-files
Requires(postun):	update-desktop-files
Requires(post):	hicolor-icon-theme
Requires(postun):	hicolor-icon-theme

%description
GeoGebra is free dynamic mathematics software for all levels of education that
joins geometry, algebra, graphing, and calculus in one easy-to-use package.

Quick Facts:
* Graphics, algebra and spreadsheet are connected and fully dynamic.
* Easy-to-use interface, yet many powerful features.
* Authoring tool to create and share interactive online learning materials.
* Available in many languages for our millions of users around the world.
* Free and open source math/maths software.


%prep
%setup -q -c -n %{name}-%{version}
cd %{name}-%{version}
%patch0 -p1
tar -C ../.. -xvf %{_libdir}/%{name}-bootstrap/%{name}-bootstrap-%{version}.tar.xz

%build
cp -aR ../%{name}-bootstrap-%{version}/* /tmp
cd %{name}-%{version}
./gradlew --offline --gradle-user-home /tmp/gradle --project-cache-dir /tmp/gradle-project \
	-x test -x check \
	-x pmdMain -x pmdTest \
	-x checkstyleGpl -x checkstyleMain -x checkstyleNonfree -x checkstyleTest \
	build

%install
export NO_BRP_CHECK_BYTECODE_VERSION=true
cd %{name}-%{version}

mkdir -p %{buildroot}%{_javadir}

%{__mkdir} dist
pushd dist
unzip ../desktop/build/distributions/desktop.zip -x 'desktop/lib/*-macosx-*.jar' -x 'desktop/lib/*-windows-*.jar' -x 'desktop/lib/*-i586.jar'

# JAR archives
%{__install} -dm0755 %{buildroot}%{_javadir}/%{name}
%{__install} -dm0755 %{buildroot}%{_jnidir}/%{name}
%{__install} -m0644 desktop/lib/{common{,-jre},desktop,{editor,renderer}-{base-*,desktop},giac-jni,impl,jogl2,jsobject-*,OpenGeoProver-*}.jar %{buildroot}%{_javadir}/%{name}
%{__install} -m0644 desktop/lib/{javagiac,jogl-all,gluegen-rt}-*.jar %{buildroot}%{_jnidir}/%{name}
for jar in %{buildroot}%{_jnidir}/%{name}/*.jar; do %{__ln_s} %{_jnidir}/%{name}/${jar##*/} %{buildroot}%{_javadir}/%{name}; done

popd

# Start script
%jpackage_script org.geogebra.desktop.GeoGebra3D "" %{quote:"-p %{_jvmlibdir}/openjfx/rt/lib --add-modules javafx.base,javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.swing,javafx.web"} %{name}:jlatexmath:jna %{name} true

# Config file
%{__install} -dm0755 %{buildroot}%{_sysconfdir}/java
%{__cat} >%{buildroot}%{_sysconfdir}/java/%{name}.conf <<__CONF__
JAVA_HOME=%{_jvmdir}/java-11
GG_SYS_CONFIG_PATH=%{_javaconfdir}
__CONF__

# Desktop file
%{__install} -dm0755 %{buildroot}%{_datadir}/applications
%{__install} -m0644 %{S:1} %{buildroot}%{_datadir}/applications

# MIME file
%{__install} -dm0755 %{buildroot}%{_datadir}/mime/packages
%{__install} -Dm0644 %{S:2} %{buildroot}%{_datadir}/mime/packages/%{name}.xml

# Icon file
%{__install} -dm0755 %{buildroot}%{_datadir}/icons/hicolor/scalable/{apps,mimetypes}
%{__install} -Dm0644 common/build/resources/main/org/geogebra/common/icons/svg/web/matDesignIcons/burgerMenu/geogebra_color.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg
%{__ln_s} ../apps/%{name}.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/mimetypes/application-vnd.geogebra.file.svg
%{__ln_s} ../apps/%{name}.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/mimetypes/application-vnd.geogebra.tool.svg

%post
%desktop_database_post
%icon_theme_cache_post
%mime_database_post
:

%postun
%desktop_database_postun
%icon_theme_cache_postun
%mime_database_postun
:

%files
%defattr(-,root,root)
%{_javadir}/%{name}
%{_jnidir}/%{name}
%config %{_sysconfdir}/java/*
%{_bindir}/*
%{_datadir}/applications/*
%{_datadir}/icons/hicolor
%{_datadir}/mime/packages/%{name}.xml
%license desktop/src/nonfree/resources/org/geogebra/desktop/_license.txt

%changelog
