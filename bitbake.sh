#!/bin/bash

BITBAKE_MACHINE=intel-x86-64
BITBAKE_TARGET=wrlinux-image-small
BITBAKE_DEPLOY_DIR=$(cd ~; pwd)/build/tmp-glibc/deploy
BITBAKE_RETRY_MAX=4

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUTPUT_DIR=${SCRIPT_DIR}/${DEST_DIR:-deploy}

cd ~

#
# set up the development environment
#
source environment-setup-x86_64-wrlinuxsdk-linux
source oe-init-build-env build

#
# edit local.conf
#
sed -ie "s/BB_NO_NETWORK ?= '1'/BB_NO_NETWORK ?= '0'/" conf/local.conf

#
# bitbake image
#
for i in $(seq ${BITBAKE_RETRY_MAX}) ; do \
  bitbake ${BITBAKE_TARGET} && \
  break
  if [ $i -eq ${BITBAKE_RETRY_MAX} ] ; then exit 1 ; fi
  sleep 1
done

# deploy artifacts
mkdir -p ${OUTPUT_DIR}
cp -r ~/build/conf ${OUTPUT_DIR}

mkdir -p ${OUTPUT_DIR}/images/${BITBAKE_MACHINE}
for file in $(ls -l ${BITBAKE_DEPLOY_DIR}/images/${BITBAKE_MACHINE} | grep '\->' | awk '{print $9}')
do
  cp ${BITBAKE_DEPLOY_DIR}/images/${BITBAKE_MACHINE}/${file} ${OUTPUT_DIR}/images/${BITBAKE_MACHINE}
done

#
# bitbake sdk
#
for i in $(seq ${BITBAKE_RETRY_MAX}) ; do \
  bitbake ${BITBAKE_TARGET} -c populate_sdk && \
  break
  if [ $i -eq ${BITBAKE_RETRY_MAX} ] ; then exit 1 ; fi
  sleep 1
done

# deploy artifacts
cp -r ${BITBAKE_DEPLOY_DIR}/sdk ${OUTPUT_DIR}/sdk
