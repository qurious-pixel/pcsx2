FROM ubuntu:18.04
MAINTAINER quriouspixel

ENV QTVER=5.14.2
ENV QTVERMIN=514
ENV LLVMVER=10
ENV GCCVER=9

ENV CLANG_BINARY=clang-${LLVMVER}
ENV CLANGXX_BINARY=clang++-${LLVMVER}
ENV LLD_BINARY=lld-${LLVMVER}
ENV GCC_BINARY=gcc-${GCCVER}
ENV GXX_BINARY=g++-${GCCVER}

RUN \
    apt-get update -y && \
    apt-get install -y curl software-properties-common apt-transport-https apt-utils && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    add-apt-repository -y ppa:beineri/opt-qt-${QTVER}-bionic && \
    DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y full-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    build-essential \
    dpkg \
    fuse \
    $GCC_BINARY $GXX_BINARY \
    libaio-dev \
    libasound2-dev \
    libegl1-mesa-dev \
    libgtk2.0-dev \
    libpng-dev \
    libsdl2-dev \
    libsoundtouch-dev \
    libwxgtk3.0-dev \
    portaudio19-dev \
    libxml2-dev \
    libpcap0.8-dev \
    libglvnd-dev \
    libpng++-dev \
    zlib1g-dev \
    liblzma-dev \
    liblzma5 \
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
    
ENV CMAKEVER=3.18.1
RUN \
	cd /tmp && \
	curl -sLO https://cmake.org/files/v${CMAKEVER%.*}/cmake-${CMAKEVER}-Linux-x86_64.sh && \
	sh cmake-${CMAKEVER}-Linux-x86_64.sh --prefix=/usr --skip-license && \
	rm ./cmake*.sh && \
	cmake --version
  
RUN 	apt-get clean autoclean && apt-get autoremove --yes && rm -rf /var/lib/apt /var/lib/cache /var/lib/log
