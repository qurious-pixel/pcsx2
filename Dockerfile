FROM ubuntu:18.04
MAINTAINER quriouspixel

ENV GCCVER=8
ENV GCC_BINARY=gcc-${GCCVER}
ENV GXX_BINARY=g++-${GCCVER}

RUN \
    apt-get update -y && \
    apt-get install -y curl software-properties-common apt-transport-https apt-utils && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y full-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    build-essential \
    dialog \
    dpkg \
    fuse \
    $GCC_BINARY $GXX_BINARY \
    libaio-dev \
    libbz2-dev \
    libcggl \
    libjpeg-dev \
    nvidia-cg-toolkit \
    libasound2-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglew-dev \
    libgtk2.0-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl1.2-dev \
    libasound2-dev \
    libsoundtouch-dev \
    libsamplerate0-dev \
    libwxgtk3.0-dev \
    libgtk-3-dev \
    libwxgtk3.0-gtk3-dev \
    libjack-jackd2-dev \
    libportaudiocpp0 \
    portaudio19-dev \
    libxml2-dev \
    libpcap0.8-dev \
    libglvnd-dev \
    libpng++-dev \
    zlib1g-dev \
    liblzma-dev \
    liblzma5 \
    libxext-dev \
    libxml2-dev \
    x11-common \
    zenity \
    wget \
    curl \
    git \
    gettext \
    ccache \
    make \
    cmake \
    git \
    ninja-build 
    
ENV CMAKEVER=3.18.4
RUN \
	cd /tmp && \
	curl -sLO https://cmake.org/files/v${CMAKEVER%.*}/cmake-${CMAKEVER}-Linux-x86_64.sh && \
	sh cmake-${CMAKEVER}-Linux-x86_64.sh --prefix=/usr --skip-license && \
	rm ./cmake*.sh && \
	cmake --version

RUN\
	cd /tmp && \
	curl -sLO https://github.com/NixOS/patchelf/releases/download/0.12/patchelf-0.12.tar.bz2 && \
	tar xvf patchelf-0.12.tar.bz2 && \
	cd patchelf-0.12*/ && \
	./configure && \
	make && make install

#ENV WXVER=3.1.4
#RUN \
#	cd /tmp && \
#	curl -sLO https://github.com/wxWidgets/wxWidgets/releases/download/v${WXVER}/wxWidgets-${WXVER}.tar.bz2 && \
#	tar xjf wxWidgets-${WXVER}.tar.bz2 && \
#	cd wxWidgets-${WXVER} && \
#	mkdir buildgtk && cd buildgtk && \
#	../configure --with-gtk && \
#	make && make install && \
#	ldconfig && \
#	rm ../../wxWidgets-${WXVER}.tar.bz2 
	
RUN \
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCCVER} 10 && \
	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCCVER} 10 && \
	gcc --version && \
	g++ --version 
  
RUN 	apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt /var/lib/cache /var/lib/log
