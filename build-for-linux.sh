#!/bin/bash

cp -v build-configs/vcpkg-linux.json vcpkg.json

# Linux sucks with europen locale settings
export LC_ALL=C
SOURCE_DIR=`pwd`
BUILD_DIR=${SOURCE_DIR}/build
export VCPKG_ROOT=/opt/vcpkg
export VCPKG_DEFAULT_TRIPLET=x64-linux
# export VCPKG_DEFAULT_TRIPLET=x64-linux-release
TOOLCHAIN_FILE=${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake

# Make qpsql compile, even if we don't want it or need it
export ZIC=/usr/sbin/zic

echo "Path is: $PATH"
export PATH=${PATH}:${VCPKG_ROOT}

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} \
    -DVCPKG_TARGET_TRIPLET=${VCPKG_DEFAULT_TRIPLET} \
    -DENABLE_GRPC=ON

cd "${BUILD_DIR}"
export PATH="${PATH}:${BUILD_DIR}/vcpkg_installed/${VCPKG_DEFAULT_TRIPLET}/bin;${BUILD_DIR}/vcpkg_installed/${VCPKG_DEFAULT_TRIPLET}/tools/Qt6/bin"

cmake --build . -j

#windeployqt --release --dir ${BUILD_DIR}/deploy --qmldir "${SOURCE_DIR}/qtclient/qml" ${BUILD_DIR}/bin/Release/qtstuff.exe || exit /b
#copy ${BUILD_DIR}/bin/Release/qtstuff.exe ${BUILD_DIR}/deploy/ || exit /b

rm "${SOURCE_DIR}/vcpkg.json"

#echo "Remember to set QML_IMPORT_PATH=${BUILD_DIR}/deploy/qml before starting the app."
#echo "Start the app: ${BUILD_DIR}/deploy/qtstuff"

