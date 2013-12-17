%define _unpackaged_files_terminate_build 0

Summary: Protocol Buffers are a way of encoding structured data in an efficient yet extensible format.
Name: protoBuffers
Version: 2.5.0
Release:       1%{?dist}
Group: Applications/System
License: http://opensource.org/licenses/BSD-3-Clause 
URL: https://developers.google.com/protocol-buffers/
Requires: dpiUser, glibc >= 2.0, kernel >= 2.6.0
Requires(post): chkconfig
AutoReq: no
ExclusiveArch: x86_64

%description
Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. Google uses Protocol Buffers for almost all of its internal RPC protocols and file formats. 

%prep
export PATH=/usr/local/probe/bin:$PATH
cd  ~/rpmbuild/BUILD
rm -rf protobuf-%{version}
tar -xjvf ~/rpmbuild/SOURCES/protobuf-%{version}.tar.bz2
cd protobuf-%{version}
chmod -R a+rX,g-w,o-w .
export GLOBAL_CPP_FLAGS="-fPIC"
env CPPFLAGS="$CPPFLAGS $GLOBAL_CPP_FLAGS" ./configure --prefix=/usr/local/probe
cd ..
%build
export PATH=/usr/local/probe/bin:$PATH
cd protobuf-%{version}
make -j8

%install
export PATH=/usr/local/probe/bin:$PATH
cd protobuf-%{version}
make install prefix=$RPM_BUILD_ROOT/usr/local/probe

%post

%preun

%postun

%files
%defattr(-,dpi,dpi,-)
/usr/local/probe/lib
/usr/local/probe/include
/usr/local/probe/bin/protoc

