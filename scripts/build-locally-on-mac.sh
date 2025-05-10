#!/bin/bash

export SRC_DIR=/Volumes/devel/src/qtstuff
export BUILD_DIR=/Volumes/devel/build/qtstuff
export VCPKG_ROOT=/Volumes/devel/src/vcpkg
export VCPKG_TRIPLET=x64-osx-release
export VCPKG_INSTALL_OPTIONS=--clean-after-build
export VCPKG_MANIFEST_MODE=ON

brew update
brew install automake autoconf libtool pkg-config autoconf-archive ninja

rm -rf $VCPKG_ROOT
git clone https://github.com/microsoft/vcpkg.git $VCPKG_ROOT
pushd $VCPKG_ROOT
./bootstrap-vcpkg.sh

export PATH=$PATH:$VCPKG_ROOT

cp ${SRC_DIR}/build-configs/vcpkg-macos.json ${SRC_DIR}/vcpkg.json
mkdir -p $BUILD_DIR && cd $BUILD_DIR
          cp ${SRC_DIR}/vcpkg.json .
echo installing vcpkg packages
vcpkg install $VCPKG_INSTALL_OPTIONS --triplet $VCPKG_TRIPLET
echo installing vcpkg packages done
echo configuring cmake
cmake -G Ninja \
-DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
-DVCPKG_TARGET_TRIPLET=$VCPKG_TRIPLET \
-DCMAKE_BUILD_TYPE=Release \
-DVCPKG_MANIFEST_MODE=ON \
$SRC_DIR

cd $BUILD_DIR
cmake --build . --config Release
