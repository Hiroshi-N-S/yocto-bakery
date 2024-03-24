# docker build --no-cache --platform linux/amd64 -t mysticstorage.local:8443/yocto/wrlinux:base23.07 -f wrlinux.dockerfile .
FROM debian:bullseye-20240311-slim

ENV WRL_REPO=https://github.com/WindRiverLinux23/wrlinux-x.git
ENV WRL_BRANCH=WRLINUX_10_23_BASE_UPDATE0007
ENV WRL_DISTRO=wrlinux
ENV WRL_MACHINE=intel-x86-64

ENV DEBIAN_FRONTEND=noninteractive

ENV http_proxy=
ENV https_proxy=
ENV no_proxy=

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

USER root
WORKDIR /root
RUN set -eux ;\
      # proxy config for apt
      echo "Acquire::http::Proxy \"${http_proxy}\";" >> apt-proxy.conf ;\
      echo "Acquire::https::Proxy \"${https_proxy}\";" >> apt-proxy.conf ;\
      mkdir -p /etc/apt/apt.conf.d ;\
      mv apt-proxy.conf /etc/apt/apt.conf.d/apt-proxy.conf ;\
      # install dependencies
      apt update && apt install -y \
        sudo \
        locales \
        expect \
        procps \
        # Required Packages for the Build Host
        # ref: https://docs.yoctoproject.org/4.0.16/ref-manual/system-requirements.html#required-packages-for-the-build-host
        gawk \
        wget \
        git-core \
        diffstat \
        unzip \
        texinfo \
        gcc-multilib \
        build-essential \
        chrpath \
        socat \
        cpio \
        python \
        python3 \
        python3-pip \
        python3-pexpect \
        xz-utils \
        debianutils \
        iputils-ping \
        libsdl1.2-dev \
        xterm \
      ;\
      # change default locale
      echo 'LANG=en_US LC_ALL=en_US.UTF-8' > /etc/default/locale ;\
      echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen ;\
      locale-gen ;\
      # add a user for bitbake.
      useradd -m -s /usr/bin/bash yocto ;\
      # add yocto to sudoers.
      echo 'yocto ALL=(ALL:ALL) NOPASSWD:ALL' >> yocto ;\
      mkdir -p /etc/sudoers.d ;\
      mv yocto /etc/sudoers.d

USER yocto
WORKDIR /home/yocto
RUN set -eux; \
      git clone \
        -b ${WRL_BRANCH} \
        ${WRL_REPO} \
      ;\
      ./wrlinux-x/setup.sh \
        --distros ${WRL_DISTRO} \
        --machines ${WRL_MACHINE} \
        --all-layers \
        --dl-layers \
        --accept-eula yes
