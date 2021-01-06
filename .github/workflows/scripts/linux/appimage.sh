#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

echo $GITHUB_WORKSPACE

BUILDBIN=$GITHUB_WORKSPACE/bin/
BINFILE=PCSX2-x86_64.AppImage
CXX=g++-10

# QT 5.14.2
# source /opt/qt514/bin/qt514-env.sh
QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
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
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/pcsx2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/
cp ./.github/workflows/scripts/linux/AppRun $GITHUB_WORKSPACE/squashfs-root/AppRun
curl -sL "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64" -o $GITHUB_WORKSPACE/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched

echo $GITHUB_RUN_ID > $GITHUB_WORKSPACE/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

/tmp/squashfs-root/AppRun $GITHUB_WORKSPACE/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
	cp /usr/lib/x86_64-linux-gnu/libSoundTouch.so.1 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libportaudio.so.2 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libsndio.so.6.1 $GITHUB_WORKSPACE/squashfs-root/usr/lib/
mkdir -p $GITHUB_WORKSPACE/squashfs-root/usr/lib/plugins
find $BUILDBIN/plugins -iname '*.so' -exec cp {} $GITHUB_WORKSPACE/squashfs-root/usr/lib/plugins \;
arr=( $(ls -d $GITHUB_WORKSPACE/squashfs-root/usr/lib/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2LIBS "$i"; done
patchelf --set-rpath /tmp/PCSX2 $GITHUB_WORKSPACE/squashfs-root/usr/lib/libSDL2-2.0.so.0
cp ./bin/GameIndex.yaml $GITHUB_WORKSPACE/squashfs-root/usr/lib/plugins/GameIndex.yaml
/tmp/squashfs-root/usr/bin/appimagetool $GITHUB_WORKSPACE/squashfs-root

mkdir $GITHUB_WORKSPACE/artifacts/
mkdir -p ./artifacts/
mv PCSX2-x86_64.AppImage* $GITHUB_WORKSPACE/artifacts
chmod -R 777 ./artifacts
cd ./artifacts
ls -al ./artifacts/
