#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

echo "Working Directory: $GITHUB_WORKSPACE"
#cd $GITHUB_WORKSPACE/
PWD


mkdir build
cd build
cmake .. -G Ninja -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ -DCMAKE_BUILD_TYPE=Release -DPACKAGE_MODE=TRUE -DGTK2_API=TRUE -DXDG_STD=TRUE -DDISABLE_ADVANCE_SIMD=TRUE -DCMAKE_INSTALL_LIBDIR="/tmp/" -DCMAKE_INSTALL_DATADIR="/tmp/"
ninja


cp ../.github/workflows/scripts/linux/appimage.sh /tmp
cd /tmp
chmod a+x appimage.sh
./appimage.sh
