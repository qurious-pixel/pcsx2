#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

cd /pcsx2
realpath . && ls -al .

mkdir build
cd build
cmake ..                                        \
    -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc      \
    -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++    \
    -DCMAKE_BUILD_TYPE=Release                  \
    -DPACKAGE_MODE=TRUE                         \      
    -DGTK3_API=TRUE                             \
    -DXDG_STD=TRUE                              \
    -DDISABLE_ADVANCE_SIMD=TRUE                 \
    -DCMAKE_INSTALL_LIBDIR="/tmp/"              \          
    #-DCMAKE_INSTALL_DATADIR="/tmp/"            \
    -G Ninja
ninja


cp ../.github/workflows/scripts/linux/appimage.sh /tmp
cd /tmp
chmod a+x appimage.sh
./appimage.sh
