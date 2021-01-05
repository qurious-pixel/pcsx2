#!/bin/bash -ex

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

ln -s /home/pcsx2/.conan /root

cd /pcsx2

mkdir appimage && cd appimage

mkdir build
cd build
cmake .. -G Ninja -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ -DCMAKE_BUILD_TYPE=Release -DPACKAGE_MODE=TRUE -DGTK2_API=TRUE -DXDG_STD=TRUE -DDISABLE_ADVANCE_SIMD=TRUE -DCMAKE_INSTALL_LIBDIR="/tmp/" -DCMAKE_INSTALL_DATADIR="/tmp/"
ninja

