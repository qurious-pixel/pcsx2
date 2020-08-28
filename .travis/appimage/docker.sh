#!/bin/bash -ex

branch=$TRAVIS_BRANCH

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/dolphin/.conan /root

cd /pcsx2

mkdir appimage && cd appimage
git clone https://github.com/beaumanvienna/pcsx2.git
git submodule update --init --recursive

cd pcsx2/


mkdir build
cd build
cmake .. -G Ninja -DLINUX_LOCAL_DEV=true -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++
ninja

#cat /pcsx2/appimage/pcsx2/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
#curl -sLO "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/appimage.sh"
#chmod a+x appimage.sh
#./appimage.sh
ls -al /pcsx2
ls -al /pcsx2/appimage/pcsx2/build
ls -al /pcsx2/appimage/pcsx2/build/bin
