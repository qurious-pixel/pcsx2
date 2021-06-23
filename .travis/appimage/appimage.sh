#!/bin/bash 

set -ex

branch=`echo ${GITHUB_REF##*/}`

BUILDPATH=/pcsx2/appimage/pcsx2/build/
BUILDBIN=$BUILDPATH/pcsx2
BINFILE=PCSX2-x86_64.AppImage
CXX=g++-8

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
#ls -al $BUILDBIN/
	set +e
	ls -al /pcsx2/appimage/pcsx2/build/{bin,plugins}
	set -e
cp -P "$BUILDBIN"/PCSX2 $HOME/squashfs-root/usr/bin/
patchelf --set-rpath /tmp/PCSX2LIBS $HOME/squashfs-root/usr/bin/PCSX2

curl -sL https://github.com/PCSX2/pcsx2/raw/master/pcsx2/gui/Resources/AppIcon64.png -o ./squashfs-root/pcsx2.svg
curl -sL https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/linux_various/PCSX2.desktop -o ./squashfs-root/pcsx2.desktop
curl -sL https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64 -o ./squashfs-root/runtime
mkdir -p squashfs-root/usr/share/applications && cp ./squashfs-root/pcsx2.desktop ./squashfs-root/usr/share/applications
mkdir -p squashfs-root/usr/share/icons && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons
mkdir -p squashfs-root/usr/share/icons/hicolor/scalable/apps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/icons/hicolor/scalable/apps
mkdir -p squashfs-root/usr/share/pixmaps && cp ./squashfs-root/pcsx2.svg ./squashfs-root/usr/share/pixmaps

curl -sL "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/AppRun" -o $HOME/squashfs-root/AppRun
curl -sL "https://github.com/AppImage/AppImageKit/releases/download/12/AppRun-x86_64" -o $HOME/squashfs-root/AppRun-patched
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched

echo $GITHUB_RUN_ID > $HOME/squashfs-root/version.txt

unset LD_LIBRARY_PATH

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/pcsx2 -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH

mkdir -p $HOME/squashfs-root/usr/bin/plugins
cp -r /pcsx2/appimage/pcsx2/bin/Langs $HOME/squashfs-root/usr/bin/
cp /pcsx2/appimage/pcsx2/bin/docs/{Configuration_Guide.pdf,PCSX2_FAQ.pdf} $HOME/squashfs-root/usr/bin/plugins
cp /pcsx2/appimage/pcsx2/bin/cheats_ws.zip $HOME/squashfs-root/usr/bin/plugins
if [[ -e "$BUILDPATH/plugins" ]]; then
	find $BUILDPATH/plugins -iname '*.so' -exec cp {} $HOME/squashfs-root/usr/lib/plugins \;
fi
curl -sL "https://raw.githubusercontent.com/PCSX2/pcsx2/master/bin/GameIndex.yaml" -o $HOME/squashfs-root/usr/bin/plugins/GameIndex.yaml
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root 

mkdir $HOME/artifacts/
mkdir -p /pcsx2/artifacts/
mv PCSX2-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /pcsx2/
cp "$BUILDBIN"/PCSX2 /pcsx2/artifacts/
chmod -R 777 /pcsx2/artifacts
cd /pcsx2/artifacts
ls -al /pcsx2/artifacts/
