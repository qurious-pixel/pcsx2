#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

echo $GITHUB_WORKSPACE

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

BUILDBIN=$GITHUB_WORKSPACE/bin/
BINFILE=PCSX2-$ARCH.AppImage
CXX=g++-10

cd /tmp
	curl -sLO "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage"
	chmod a+x linuxdeploy*.AppImage
./linuxdeploy-$ARCH.AppImage --appimage-extract
cd $GITHUB_WORKSPACE
mkdir -p squashfs-root/usr/bin
ls -al $BUILDBIN
cp -P "$BUILDBIN"/PCSX2 $GITHUB_WORKSPACE/squashfs-root/usr/bin/
patchelf --set-rpath /tmp/PCSX2 $GITHUB_WORKSPACE/squashfs-root/usr/bin/PCSX2

pwd
ls -al
echo $GITHUB_WORKSPACE

cp ./pcsx2/gui/Resources/AppIcon64.png ./squashfs-root/pcsx2.svg
cp ./linux_various/PCSX2.desktop ./squashfs-root/pcsx2.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-$APPARCH -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/pcsx2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/
cp ./.github/workflows/scripts/linux/AppRun $GITHUB_WORKSPACE/squashfs-root/AppRun
curl -sL "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-$APPARCH" -o $GITHUB_WORKSPACE/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched

echo $GITHUB_RUN_ID > $GITHUB_WORKSPACE/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

#/tmp/squashfs-root/AppRun --appdir=$GITHUB_WORKSPACE/squashfs-root/ --output appimage
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
	cp $LIBARCH/libSoundTouch.so.1 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp $LIBARCH/libportaudio.so.2 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp $LIBARCH/libSDL2-2.0.so.0 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp $LIBARCH/libsndio.so.6.1 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
mkdir -p $GITHUB_WORKSPACE/squashfs-root/usr/bin/plugins
find $BUILDBIN/plugins -iname '*.so' -exec cp {} $GITHUB_WORKSPACE/squashfs-root/usr/bin/plugins \;
arr=( $(ls -d $GITHUB_WORKSPACE/squashfs-root/usr/bin/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2 "$i"; done
patchelf --set-rpath /tmp/PCSX2 $GITHUB_WORKSPACE/squashfs-root/usr/lib/libSDL2-2.0.so.0
cp ./bin/GameIndex.yaml $GITHUB_WORKSPACE/squashfs-root/usr/bin/GameIndex.yaml
/tmp/linuxdeploy-$ARCH.AppImage --appdir=$GITHUB_WORKSPACE/squashfs-root/ --output appimage

mkdir $GITHUB_WORKSPACE/artifacts/
mkdir -p ./artifacts/
mv PCSX2-$ARCH.AppImage* $GITHUB_WORKSPACE/artifacts
chmod -R 777 ./artifacts
cd ./artifacts
ls -al .
