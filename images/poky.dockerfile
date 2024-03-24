# docker build --no-cache --platform linux/amd64 -t mysticstorage.local:8443/yocto/poky:kirkstone -f poky.dockerfile .
FROM debian:bullseye-20240311-slim

ENV POKY_REPO=https://github.com/yoctoproject/poky.git
ENV POKY_BRANCH=kirkstone

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
        file \
        # Required Packages for the Build Host
        # ref: https://docs.yoctoproject.org/4.0.16/ref-manual/system-requirements.html#required-packages-for-the-build-host
        gawk \
        wget \
        git \
        diffstat \
        unzip \
        texinfo \
        gcc \
        build-essential \
        chrpath \
        socat \
        cpio \
        python3 \
        python3-pip \
        python3-pexpect \
        xz-utils \
        debianutils \
        iputils-ping \
        python3-git \
        python3-jinja2 \
        libegl1-mesa \
        libsdl1.2-dev \
        pylint3 \
        xterm \
        python3-subunit \
        mesa-common-dev \
        zstd \
        liblz4-tool \
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
        -b ${POKY_BRANCH} \
        ${POKY_REPO}
