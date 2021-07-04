#!/bin/bash 

set -ex

echo "${PLATFORM}"
if [ "${PLATFORM}" == "x86" ]; then
	APPARCH="i686"
	ARCH="i386"
else
	APPARCH="x86_64"
	ARCH="x86_64"
fi

BUILDPATH=/pcsx2/build
BUILDBIN=$BUILDPATH/pcsx2

cd /tmp
	curl -sSfLO "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage"
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
sed -i -e 's|__GL_THREADED_OPTIMIZATIONS=1|__GL_THREADED_OPTIMIZATIONS=0|g' ./squashfs-root/PCSX2.desktop
curl -sSfL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-$APPARCH -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/PCSX2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/PCSX2.png ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/lib/
cp ./.github/workflows/scripts/linux/AppRun /pcsx2/squashfs-root/AppRun
curl -sSfL "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-$APPARCH" -o /pcsx2/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched

echo "$name" > /pcsx2/squashfs-root/version.txt

mkdir -p /pcsx2/squashfs-root/usr/bin/{plugins,vm}
cp -r /pcsx2/bin/Langs /pcsx2/squashfs-root/usr/bin/
cp /pcsx2/bin/docs/{Configuration_Guide.pdf,PCSX2_FAQ.pdf} /pcsx2/squashfs-root/usr/bin/plugins
cp /pcsx2/bin/cheats_ws.zip /pcsx2/squashfs-root/usr/bin/plugins
if [[ -e "$BUILDPATH/plugins" ]]; then
	find "$BUILDPATH/plugins" -iname '*.so' -exec cp {} /pcsx2/squashfs-root/usr/bin/plugins \;
fi
cp ./bin/GameIndex.yaml /pcsx2/squashfs-root/usr/bin/plugins/GameIndex.yaml
export UPD_INFO="gh-releases-zsync|PCSX2|pcsx2|latest|$name.AppImage.zsync"
export OUTPUT=$name.AppImage
/tmp/squashfs-root/AppRun --appdir=/pcsx2/squashfs-root/ -d /pcsx2/squashfs-root/PCSX2.desktop -i /pcsx2/squashfs-root/PCSX2.png --output appimage

mkdir -p /pcsx2/artifacts/
ls -al .
mv "$name.AppImage" /pcsx2/artifacts # && mv "$name.AppImage.zsync" /pcsx2/artifacts
chmod -R 777 ./artifacts
cd ./artifacts
ls -al .
