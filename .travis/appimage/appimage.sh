#!/bin/bash -ex

branch=$TRAVIS_BRANCH

BUILDBIN=/pcsx2/pcsx2/build/bin
BINFILE=PCSX2-x86_64.AppImage
LOG_FILE=$HOME/curl.log
CXX=g++-9

# QT 5.14.2
# source /opt/qt514/bin/qt514-env.sh
QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	curl -sLO "https://github.com/qurious-pixel/pcsx2/raw/$branch/travis/appimage/update.tar.gz"
	tar -xzf update.tar.gz
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
cp -P "$BUILDBIN"/PCSX2 $HOME/squashfs-root/usr/bin/

curl -sL https://github.com/PCSX2/pcsx2/raw/master/pcsx2/gui/Resources/AppIcon64.png -o ./squashfs-root/pcsx2.svg
curl -sL https://raw.githubusercontent.com/PCSX2/pcsx2/master/linux_various/PCSX2.desktop.in -o ./squashfs-root/pcsx2.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/pcsx2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/pixmaps
mkdir -p squashfs-root/usr/optional/ ; mkdir -p squashfs-root/usr/optional/libstdc++/
mkdir -p squashfs-root/usr/share/zenity 
cp /usr/share/zenity/zenity.ui ./squashfs-root/usr/share/zenity
cp /usr/bin/zenity ./squashfs-root/usr/bin/
curl -sL "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/update.sh" -o $HOME/squashfs-root/update.sh
curl -sL "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/AppRun" -o $HOME/squashfs-root/AppRun
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/AppRun-patched-x86_64" -o $HOME/squashfs-root/AppRun-patched
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/exec-x86_64.so" -o $HOME/squashfs-root/usr/optional/exec.so
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/update.sh
#cp /tmp/libssl.so.47 /tmp/libcrypto.so.45 /usr/lib/x86_64-linux-gnu/
cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 squashfs-root/usr/optional/libstdc++/
printf "#include <bits/stdc++.h>\nint main(){std::make_exception_ptr(0);std::pmr::get_default_resource();}" | $CXX -x c++ -std=c++2a -o $HOME/squashfs-root/usr/optional/checker -


echo $TRAVIS_COMMIT > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/pcsx2 -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
#cp /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 $HOME/squashfs-root/usr/lib/
#cp /usr/lib/x86_64-linux-gnu/libselinux.so* $HOME/squashfs-root/usr/lib/
mv /tmp/update/AppImageUpdate $HOME/squashfs-root/usr/bin/
mv /tmp/update/* $HOME/squashfs-root/usr/lib/
mkdir -p $HOME/squashfs-root/usr/lib/updater
mv $HOME/squashfs-root/usr/lib/libcurl.so.4 $HOME/squashfs-root/usr/lib/updater
rm $HOME/squashfs-root/usr/lib/libOpenGL.so.0
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|qurious-pixel|pcsx2|continuous|PCSX2-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /pcsx2/artifacts/
mv PCSX2-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /pcsx2/
chmod -R 777 /pcsx2/artifacts
cd /pcsx2/artifacts
ls -al /pcsx2/artifacts/
curl --upload-file PCSX2-x86_64.AppImage https://transfersh.com/PCSX2-x86_64.AppImage

# touch $HOME/curl.log
# curl --progress-bar --upload-file $BINFILE https://transfer.sh/$BINFILE | tee -a "$LOG_FILE" ; test ${PIPESTATUS[0]} -eq 0
# echo "" >> $LOG_FILE
# cat $LOG_FILE
