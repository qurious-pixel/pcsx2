#!/bin/bash -ex

branch=`echo ${GITHUB_REF##*/}`

QT_BASE_DIR=/opt/qt514
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#DEBIAN_FRONTEND=noninteractive apt update
#DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y libfmt-dev

ln -s /home/pcsx2/.conan /root

cd /pcsx2

mkdir appimage && cd appimage
git clone --recursive --single-branch --branch gs-merge https://github.com/PCSX2/pcsx2.git
#git clone --recursive https://github.com/PCSX2/pcsx2.git
cd pcsx2/
git reset --hard ff3af8be1876630dc2bca8202e628263de67eb67

# ADD CUSTOM MAPPING TO GAMECONTROLLERDB
echo -e '\n# Custom

050000004c050000e60c000000810000,DualSense,a:b0,b:b1,x:b3,y:b2,back:b8,guide:b10,start:b9,leftstick:b11,rightstick:b12,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,platform:Linux,' >> ./pcsx2/PAD/Linux/res/game_controller_db.txt


mkdir build
cd build
cmake ..                                        \
-G Ninja                                        \
-DCMAKE_C_COMPILER=/usr/lib/ccache/gcc          \
-DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++        \
-DCMAKE_BUILD_TYPE=Release -DPACKAGE_MODE=TRUE  \
-DDISABLE_ADVANCE_SIMD=TRUE                     \
-DXDG_STD=TRUE                                  \
-DOpenGL_GL_PREFERENCE="LEGACY"                 \
-DOPENGL_opengl_LIBRARY=""                      \
-DCMAKE_INSTALL_DATADIR="/tmp/"                 \
-DCMAKE_INSTALL_DOCDIR="/tmp/PCSX2"
#\ -DDISABLE_ADVANCE_SIMD=TRUE -DGSDX_LEGACY=TRUE -DGTK2_API=TRUE -DPLUGIN_DIR= -DGAMEINDEX_DIR= -DEGL_API=TRUE -DGTK3_API=TRUE  -DCMAKE_INSTALL_LIBDIR="/tmp/" -DCMAKE_INSTALL_DATADIR="/tmp/"

ninja
#cat /pcsx2/appimage/pcsx2/build/CMakeFiles/CMakeError.log | curl -F 'f:1=<-' ix.io

cd /tmp
curl -sLO "https://raw.githubusercontent.com/qurious-pixel/pcsx2/$branch/.travis/appimage/appimage.sh"
chmod a+x appimage.sh
./appimage.sh
