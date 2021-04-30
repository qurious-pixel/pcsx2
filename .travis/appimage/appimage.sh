#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

BUILDBIN=/pcsx2/appimage/pcsx2/build/pcsx2
BINFILE=PCSX2-x86_64.AppImage
CXX=g++-8

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	curl -sLO "https://github.com/qurious-pixel/pcsx2/raw/$branch/.travis/appimage/update.tar.gz"
	tar -xzf update.tar.gz
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
#ls -al $BUILDBIN/
ls -al /pcsx2/appimage/pcsx2/build/
cp -P "$BUILDBIN"/PCSX2 $HOME/squashfs-root/usr/bin/
patchelf --set-rpath /tmp/PCSX2LIBS $HOME/squashfs-root/usr/bin/PCSX2

curl -sL https://github.com/PCSX2/pcsx2/raw/master/pcsx2/gui/Resources/AppIcon64.png -o ./squashfs-root/pcsx2.svg
curl -sL https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/linux_various/PCSX2.desktop -o ./squashfs-root/pcsx2.desktop
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
curl -sL "https://github.com/AppImage/AppImageKit/releases/download/12/AppRun-x86_64" -o $HOME/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/update.sh

echo $GITHUB_RUN_ID > $HOME/squashfs-root/version.txt

unset LD_LIBRARY_PATH

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/pcsx2 -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
	#cp /usr/lib/x86_64-linux-gnu/libSoundTouch.so.1 $HOME/squashfs-root/usr/lib/
	#cp /usr/lib/x86_64-linux-gnu/libportaudio.so.2 $HOME/squashfs-root/usr/lib/
	#cp /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 $HOME/squashfs-root/usr/lib/
	#cp /usr/lib/x86_64-linux-gnu/libsndio.so.6.1 $HOME/squashfs-root/usr/lib/
mv /tmp/update/AppImageUpdate $HOME/squashfs-root/usr/bin/
mv /tmp/update/* $HOME/squashfs-root/usr/lib/
mkdir -p $HOME/squashfs-root/usr/lib/plugins
find $BUILDBIN/../plugins -iname '*.so' -exec cp {} $HOME/squashfs-root/usr/lib/plugins \;
arr=( $(ls -d $HOME/squashfs-root/usr/lib/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2 "$i"; done
#patchelf --set-rpath /tmp/PCSX2 $HOME/squashfs-root/usr/lib/libSDL2-2.0.so.0
#patchelf --set-rpath ../lib $HOME/squashfs-root/usr/lib/libsndio.so.6.1
mkdir -p $HOME/squashfs-root/usr/lib/updater
mv $HOME/squashfs-root/usr/lib/libcurl.so.4 $HOME/squashfs-root/usr/lib/updater
curl -sL "https://raw.githubusercontent.com/PCSX2/pcsx2/master/bin/GameIndex.yaml" -o $HOME/squashfs-root/usr/lib/plugins/GameIndex.yaml
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|qurious-pixel|pcsx2|continuous|PCSX2-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /pcsx2/artifacts/
mv PCSX2-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /pcsx2/
cp "$BUILDBIN"/PCSX2 /pcsx2/artifacts/
chmod -R 777 /pcsx2/artifacts
cd /pcsx2/artifacts
ls -al /pcsx2/artifacts/
