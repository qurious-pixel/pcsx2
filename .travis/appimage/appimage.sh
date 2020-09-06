#!/bin/bash -ex

branch=$TRAVIS_BRANCH

BUILDBIN=/pcsx2/appimage/pcsx2/build/pcsx2/
BINFILE=PCSX2-x86_64.AppImage
LOG_FILE=$HOME/curl.log
CXX=g++-10

cd /tmp
	curl -sLO "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
	curl -sLO "https://github.com/AppImage/AppImageUpdate/releases/download/continuous/AppImageUpdate-x86_64.AppImage"
	chmod a+x AppImageUpdate-x86_64.AppImage
	chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
cd $HOME
mkdir -p squashfs-root/usr/bin
ls -al $BUILDBIN
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

curl -sL "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/AppRun" -o $HOME/squashfs-root/AppRun
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/AppRun-patched-x86_64" -o $HOME/squashfs-root/AppRun-patched
curl -sL "https://github.com/RPCS3/AppImageKit-checkrt/releases/download/continuous2/exec-x86_64.so" -o $HOME/squashfs-root/usr/optional/exec.so
chmod a+x ./squashfs-root/AppRun
chmod a+x ./squashfs-root/runtime
chmod a+x ./squashfs-root/AppRun-patched
cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 squashfs-root/usr/optional/libstdc++/
printf "#include <bits/stdc++.h>\nint main(){std::make_exception_ptr(0);std::pmr::get_default_resource();}" | $CXX -x c++ -std=c++2a -o $HOME/squashfs-root/usr/optional/checker -


echo $TRAVIS_COMMIT > $HOME/squashfs-root/version.txt

unset QT_PLUGIN_PATH
unset LD_LIBRARY_PATH
unset QTDIR

# /tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/pcsx2 -appimage -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
/tmp/squashfs-root/AppRun $HOME/squashfs-root/usr/bin/PCSX2 -unsupported-allow-new-glibc -no-copy-copyright-files -no-translations -bundle-non-qt-libs
export PATH=$(readlink -f /tmp/squashfs-root/usr/bin/):$PATH
	cp /usr/lib/x86_64-linux-gnu/libSoundTouch.so.1 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libportaudio.so.2 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 $HOME/squashfs-root/usr/lib/
	cp /usr/lib/x86_64-linux-gnu/libsndio.so.6.1 $HOME/squashfs-root/usr/lib/
# Add dialog as the fallback
cp /usr/bin/dialog ./squashfs-root/usr/bin/
cp /lib/x86_64-linux-gnu/libncursesw.so.5 $HOME/squashfs-root/usr/lib/
cp /lib/x86_64-linux-gnu/libtinfo.so.5 $HOME/squashfs-root/usr/lib/

# Add AppImageUpdate as the internal updater
mv /tmp/AppImageUpdate-x86_64.AppImage $HOME/squashfs-root/usr/bin/AppImageUpdate
mkdir -p $HOME/squashfs-root/usr/lib/plugins
find $BUILDBIN/../plugins -iname '*.so' -exec cp {} $HOME/squashfs-root/usr/lib/plugins \;
arr=( $(ls -d $HOME/squashfs-root/usr/lib/plugins/* ) )
for i in "${arr[@]}"; do patchelf --set-rpath /tmp/PCSX2LIBS "$i"; done
patchelf --set-rpath /tmp/PCSX2LIBS $HOME/squashfs-root/usr/lib/libSDL2-2.0.so.0
/tmp/squashfs-root/usr/bin/appimagetool $HOME/squashfs-root -u "gh-releases-zsync|qurious-pixel|pcsx2|continuous|PCSX2-x86_64.AppImage.zsync"

mkdir $HOME/artifacts/
mkdir -p /pcsx2/artifacts/
mv PCSX2-x86_64.AppImage* $HOME/artifacts
cp -R $HOME/artifacts/ /pcsx2/
cp "$BUILDBIN"/PCSX2 /pcsx2/artifacts/
chmod -R 777 /pcsx2/artifacts
cd /pcsx2/artifacts
ls -al /pcsx2/artifacts/
#curl --upload-file PCSX2 https://transfersh.com/PCSX2
