#
# Copyright (C) 2013 Red Rocket Computing
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# cyclone5.mk
# Created on: 25/10/13
# Author: Stephen Street (stephen@redrocketcomputing.com)
#

where-am-i := ${CURDIR}/$(lastword $(subst $(lastword ${MAKEFILE_LIST}),,${MAKEFILE_LIST}))

# Setup up default goal
ifeq ($(.DEFAULT_GOAL),)
	.DEFAULT_GOAL := all
endif

SOURCE_PATH := ${CURDIR}
BUILD_PATH := $(subst ${PROJECT_ROOT},${BUILD_ROOT},${SOURCE_PATH})

all: ${BUILD_PATH}/build/conf/bblayers.conf ${BUILD_PATH}/build/conf/local.conf
	${SOURCE_PATH}/scripts/run-build ${BUILD_PATH}/poky/oe-init-build-env ${BUILD_PATH}/build linux u-boot altera-image meta-ide-support adt-installer meta-toolchain

clean:  ${BUILD_PATH}/build/conf/bblayers.conf ${BUILD_PATH}/build/conf/local.conf
	rm -rf ${BUILD_PATH}/build/tmp

distclean:
	rm -rf ${BUILD_PATH}

${BUILD_PATH}/poky/LICENSE:
	mkdir -p ${BUILD_PATH}
	git clone ${REPOSITORY_ROOT}/poky ${BUILD_PATH}/poky
	cd ${BUILD_PATH}/poky && git checkout dora-10.0.0
	cd ${BUILD_PATH}/poky && patch -p 1 < ${SOURCE_PATH}/../patches/disable-dpkg-status-removal.patch
	cd ${BUILD_PATH}/poky && patch -p 1 < ${SOURCE_PATH}/../patches/enable-deploy-dir-for-sdk.patch

${BUILD_PATH}/poky/meta-altera/README.md: ${BUILD_PATH}/poky/LICENSE
	git clone ${REPOSITORY_ROOT}/meta-altera ${BUILD_PATH}/poky/meta-altera

${BUILD_PATH}/poky/meta-linaro/README: ${BUILD_PATH}/poky/LICENSE
	git clone ${REPOSITORY_ROOT}/meta-linaro ${BUILD_PATH}/poky/meta-linaro

${BUILD_PATH}/build/conf/bblayers.conf: ${SOURCE_PATH}/conf/template-bblayers.conf ${BUILD_PATH}/poky/meta-linaro/README ${BUILD_PATH}/poky/meta-altera/README.md
	mkdir -p ${BUILD_PATH}/build/conf
	sed 's:##BUILDPATH##:${BUILD_PATH}/poky:g' ${SOURCE_PATH}/conf/template-bblayers.conf > ${BUILD_PATH}/build/conf/bblayers.conf

${BUILD_PATH}/build/conf/local.conf: ${SOURCE_PATH}/conf/template-local.conf ${BUILD_PATH}/poky/meta-linaro/README ${BUILD_PATH}/poky/meta-altera/README.md
	mkdir -p ${BUILD_PATH}/build/conf
	sed -e 's:##NPROCESSORS##:$(shell grep -c processor /proc/cpuinfo):g' \
	    -e 's:##DOWNLOADPATH##:${PROJECT_ROOT}/downloads:g' \
	    -e 's:##DEPLOYPATH##:${PROJECT_ROOT}/images:g' \
	    ${SOURCE_PATH}/conf/template-local.conf > ${BUILD_PATH}/build/conf/local.conf




