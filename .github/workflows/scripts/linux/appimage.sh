#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

echo "${PLATFORM}"
if [ "${PLATFORM}" == "x86" ]; then
  	LIBARCH="/usr/lib/i386-linux-gnu"
	APPARCH="i686"
	ARCH="i386"
else
	LIBARCH="/usr/lib/x86_64-linux-gnu" 
	APPARCH="x86_64"
	ARCH="x86_64"
fi

###############
realpath /pcsx2/build/pcsx2 && ls -al /pcsx2/build/pcsx2
###############


BUILDBIN=/pcsx2/build/pcsx2
BINFILE=PCSX2-$ARCH.AppImage
CXX=g++-8

cd /tmp
	curl -sLO "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage"
	chmod a+x linuxdeploy*.AppImage
./linuxdeploy-$ARCH.AppImage --appimage-extract
	mv /tmp/squashfs-root/usr/bin/patchelf /tmp/squashfs-root/usr/bin/patchelf.orig
	cp /usr/local/bin/patchelf /tmp/squashfs-root/usr/bin/patchelf
cd /pcsx2
mkdir -p squashfs-root/usr/bin
ls -al $BUILDBIN
cp -P "$BUILDBIN"/PCSX2 /pcsx2/squashfs-root/usr/bin/
patchelf --set-rpath /tmp/PCSX2 /pcsx2/squashfs-root/usr/bin/PCSX2

cp ./pcsx2/gui/Resources/AppIcon64.png ./squashfs-root/PCSX2.png
cp ./linux_various/PCSX2.desktop.in ./squashfs-root/PCSX2.desktop 
sed -i -e 's|Categories=@PCSX2_MENU_CATEGORIES@|Categories=Game;Emulator;|g' ./squashfs-root/PCSX2.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-$APPARCH -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/PCSX2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/pixmaps
#mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/
mkdir -p squashfs-root/usr/lib/
cp ./.github/workflows/scripts/linux/AppRun /pcsx2/squashfs-root/AppRun
curl -sL "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-$APPARCH" -o /pcsx2/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched

echo $GITHUB_RUN_ID > /pcsx2/squashfs-root/version.txt

#/tmp/squashfs-root/AppRun --appdir=/pcsx2/squashfs-root/ --output appimage
#export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
#	cp $LIBARCH/libSoundTouch.so.1 /pcsx2/squashfs-root/usr/lib/
#	cp $LIBARCH/libportaudio.so.2 /pcsx2/squashfs-root/usr/lib/
#	cp $LIBARCH/libSDL2-2.0.so.0 /pcsx2/squashfs-root/usr/lib/
#	cp $LIBARCH/libsndio.so.6.1 /pcsx2/squashfs-root/usr/lib/
mkdir -p /pcsx2/squashfs-root/usr/bin/plugins
find $BUILDBIN/../plugins -iname '*.so' -exec cp {} /pcsx2/squashfs-root/usr/bin/plugins \;
arr=( $(ls -d /pcsx2/squashfs-root/usr/bin/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2 "$i"; done
#patchelf --set-rpath /tmp/PCSX2 /pcsx2/squashfs-root/usr/lib/libSDL2-2.0.so.0
cp ./bin/GameIndex.yaml /pcsx2/squashfs-root/usr/bin/plugins/GameIndex.yaml
export UPD_INFO="gh-releases-zsync|PCSX2|pcsx2|latest|$name.AppImage.zsync"
export OUTPUT=$name.AppImage
/tmp/squashfs-root/AppRun --appdir=/pcsx2/squashfs-root/ -d /pcsx2/squashfs-root/PCSX2.desktop -i /pcsx2/squashfs-root/PCSX2.png --output appimage

mkdir /pcsx2/artifacts/
#mkdir -p ./artifacts/
mv $name.AppImage* /pcsx2/artifacts
chmod -R 777 ./artifacts
cd ./artifacts
ls -al .
