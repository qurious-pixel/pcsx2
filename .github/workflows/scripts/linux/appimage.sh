#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

BUILDBIN=/pcsx2/build/pcsx2/
BINFILE=PCSX2-x86_64.AppImage
LOG_FILE=$HOME/curl.log
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
cd $HOME
mkdir -p squashfs-root/usr/bin
ls -al $BUILDBIN
cp -P "$BUILDBIN"/PCSX2 $HOME/squashfs-root/usr/bin/
patchelf --set-rpath /tmp/PCSX2LIBS $HOME/squashfs-root/usr/bin/PCSX2

cp /pcsx2/pcsx2/gui/Resources/AppIcon64.png ./squashfs-root/pcsx2.svg
cp /pcsx2/linux_various/PCSX2.desktop.in ./squashfs-root/pcsx2.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/pcsx2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/
cp /pcsx2/.github/workflows/scripts/linux/AppRun $HOME/squashfs-root/AppRun
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/AppRun-patched-x86_64" -o $HOME/squashfs-root/AppRun-patched
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/exec-x86_64.so" -o $HOME/squashfs-root/usr/optional/exec.so
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched
cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 squashfs-root/usr/optional/libstdc++/
printf "#include <bits/stdc++.h>\nint main(){std::make_exception_ptr(0);std::pmr::get_default_resource();}" | $CXX -x c++ -std=c++2a -o $HOME/squashfs-root/usr/optional/checker -

echo $GITHUB_RUN_ID > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
	cp /usr/lib/x86_64-linux-gnu/libSoundTouch.so.1 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libportaudio.so.2 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libsndio.so.6.1 $HOME/squashfs-root/usr/lib/
mkdir -p $HOME/squashfs-root/usr/lib/plugins
find $BUILDBIN/../plugins -iname '*.so' -exec cp {} $HOME/squashfs-root/usr/lib/plugins \;
arr=( $(ls -d $HOME/squashfs-root/usr/lib/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2LIBS "$i"; done
patchelf --set-rpath /tmp/PCSX2LIBS $HOME/squashfs-root/usr/lib/libSDL2-2.0.so.0
cp /pcsx2/bin/GameIndex.yaml $HOME/squashfs-root/usr/lib/plugins/GameIndex.yaml
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root

mkdir $HOME/artifacts/
mkdir -p /pcsx2/artifacts/
mv PCSX2-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /pcsx2/
cp "$BUILDBIN"/PCSX2 /pcsx2/artifacts/
chmod -R 777 /pcsx2/artifacts
cd /pcsx2/artifacts
ls -al /pcsx2/artifacts/
