#!/bin/sh

set -e

arg=$1
[ -z "$arg" ] && arg="build"

die() {
	echo "$@"
	exit 1
}

name=rudder-contrib-backup
control=$name/DEBIAN/control
version=`perl -ne 'if(/^Version:\s+(.*)/) {print "$1\n";exit;}' $control`
arch=`perl -ne 'if(/^Architecture:\s+(.*)/) {print "$1\n";exit;}' $control`
build_RPM=YES

[ -d $name/DEBIAN ] || die "Please cd to the toplevel directory first"
cd $name

cd ..

mkdir .tmp && cd .tmp || die ".tmp already exists, investigate why the previous run of $0 failed!"
cp -pr ../${name} .
(find ${name} -name .svn -o -name '.git*' -print0|xargs -0 rm -rf)
size=`du -ks $name|awk '{print $1}'`
echo "Installed-Size: $size" >>$control
fakeroot dpkg-deb -Zgzip --build ${name}
mv ${name}.deb ../${name}_${version}_${arch}.deb
cd .. && rm -rf .tmp

if [ "$build_RPM" = "YES" ]; then
	# Convert to rpm, massaging out the Debian-only bits
	mkdir .tmp && cd .tmp
	fakeroot alien --generate --scripts --to-rpm --bump=0 ../${name}_${version}_${arch}.deb
	specfile=`find . -name '*.spec'|head -1`
	sed -i -e '/^%dir/d' -e '/^Buildroot:/aBuildArch: noarch' $specfile
	cat >> $specfile <<EOF
	%dir "/etc/rudder-backup/"
EOF
	rpmbuild -bb --buildroot $PWD/${name}-* $specfile
	cd .. && rm -rf .tmp
fi
