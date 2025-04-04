@echo off

copy build-configs/vcpkg.json . || exit /b

set "SOURCE_DIR=%CD%"
set BUILD_DIR=C:\build\qtstuff
set VCPKG_ROOT=C:\src\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows
set TOOLCHAIN_FILE=C:\src\vcpkg\scripts\buildsystems\vcpkg.cmake

echo "Path is: %PATH%"

rmdir /S /Q "%BUILD_DIR%"
mkdir "%BUILD_DIR%" || exit /b

cmake -S "%SOURCE_DIR%" -B "%BUILD_DIR%" ^
    -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN_FILE% ^
    -DVCPKG_TARGET_TRIPLET=%VCPKG_DEFAULT_TRIPLET% ^
    -DENABLE_GRPC=ON || exit /b

cd "%BUILD_DIR%" || exit /b
set "PATH=%PATH%;%BUILD_DIR%\vcpkg_installed\x64-windows\bin;%BUILD_DIR%\vcpkg_installed\x64-windows\tools\Qt6\bin"

cmake --build . --config Release || exit /b

windeployqt --release --dir %BUILD_DIR%\deploy --qmldir "%SOURCE_DIR%\qtclient\qml" %BUILD_DIR%\bin\Release\qtstuff.exe || exit /b
copy %BUILD_DIR%\bin\Release\qtstuff.exe %BUILD_DIR%\deploy\ || exit /b

del "%SOURCE_DIR%\vcpkg.json"

echo "Remember to set QML_IMPORT_PATH=%BUILD_DIR%\deploy\qml before starting the app."
echo "Start the app: %BUILD_DIR%\deploy\qtstuff.exe"
