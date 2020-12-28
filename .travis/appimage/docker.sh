#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/pcsx2/.conan /root

cd /pcsx2

mkdir appimage && cd appimage
#git clone --single-branch --branch x86_64-support https://github.com/beaumanvienna/pcsx2.git
git clone --recursive https://github.com/PCSX2/pcsx2.git
cd pcsx2/
#git submodule update --init --recursive




mkdir build
cd build
cmake .. -G Ninja -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ -DCMAKE_BUILD_TYPE=Release -DPACKAGE_MODE=TRUE -DGTK2_API=TRUE -DXDG_STD=TRUE -DDISABLE_ADVANCE_SIMD=TRUE -DPLUGIN_DIR="/tmp/PCSX2LIBS/plugins/" -DGAMEINDEX_DIR="./bin/"
#\ -DDISABLE_ADVANCE_SIMD=TRUE -DGSDX_LEGACY=TRUE -DGTK3_API=TRUE 
ninja

#cat /pcsx2/appimage/pcsx2/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh

