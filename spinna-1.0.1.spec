Summary:	Spinna website framework
License:	Boost V1.0
Name:		spinna
Version:	1.0.1
Release:	1

%description
Framework for writing websites in D.

%prep
rm -rf *
cp -Rp %{_sourcedir}/%{name}-%{version}/* .

%build
make build

%install
make DESTDIR=%{buildroot} rpminstall

%files
%defattr(-,root,root)
%{_bindir}/makerouter
%{_bindir}/makefixdb
%{_includedir}/spinna
