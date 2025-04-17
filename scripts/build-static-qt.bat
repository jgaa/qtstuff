@echo off

REM Check for directory "qtclient"
if not exist "qtclient\" (
    echo Error: This script must be run from the root directory containing the 'qtclient' folder.
    exit /b 1
)

if not defined QT_VERSION set QT_VERSION=6.8.3

if not defined BUILD_DIR (
    set "BUILD_DIR=C:\build"
)

if not defined QT_TARGET_DIR (
    set "QT_TARGET_DIR=C:\qt-static"
)

if not defined VCPKG_ROOT (
    set "VCPKG_ROOT=C:\src\vcpkg"
)

if not defined VCPKG_DEFAULT_TRIPLET (
    set "VCPKG_DEFAULT_TRIPLET=x64-windows-release"
)


set QT_BUILD_DIR=%BUILD_DIR%/qt

echo %PATH% | find /I "%VCPKG_ROOT%" >nul
if errorlevel 1 (
    set "PATH=%VCPKG_ROOT%;%PATH%"
)
echo "Path is: %PATH%"

echo "Building static QT for Windows in %QT_BUILD_DIR%"
if exist "%QT_BUILD_DIR%" rmdir /S /Q "%QT_BUILD_DIR%"
if exist "%QT_TARGET_DIR%" rmdir /S /Q "%QT_TARGET_DIR%"
mkdir %QT_TARGET_DIR%
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

git clone --depth=1 --branch %QT_VERSION% git://code.qt.io/qt/qt5.git %QT_BUILD_DIR%
if errorlevel 1 (
    echo Failed clone Qt
    exit /b
)

copy build-configs\qt-static-vcpkg.json "%QT_BUILD_DIR%"\vcpkg.json
if errorlevel 1 (
    echo Failed to copy vcpkg.json
    exit /b
)

cd %QT_BUILD_DIR%
if errorlevel 1 (
    echo Failed to cd to %QT_BUILD_DIR%
    exit /b
)
echo "Ready to install vcpkg dependencies"
dir
vcpkg install --triplet %VCPKG_DEFAULT_TRIPLET%

set BAD_CMAKE_FILE=%QT_BUILD_DIR%\vcpkg_installed\x64-windows\share\openssl\OpenSSLConfig.cmake
powershell -Command "(Get-Content \"%BAD_CMAKE_FILE%\") -replace 'OpenSSL::applink', '' | Set-Content \"%BAD_CMAKE_FILE%\""

call init-repository --module-subset=default,-qtwebengine,-qtmultimedia
if errorlevel 1 (
    echo init-repository failed!
    exit /b
)

call configure.bat ^
  -prefix %QT_TARGET_DIR% ^
  -static ^
  -release ^
  -opensource ^
  -confirm-license ^
  -no-pch ^
  -nomake examples ^
  -nomake tests ^
  -opengl desktop ^
  -openssl-linked ^
  -sql-sqlite ^
  -feature-png ^
  -feature-jpeg ^
  -skip qtwebengine ^
  -skip qtmultimedia ^
  -skip qtsensors ^
  -skip qtconnectivity ^
  -skip qtnetworkauth ^
  -skip qtspeech ^
  -skip qt5compat ^
  -skip qtquick3dphysics ^
  -skip qtremoteobjects ^
  -skip qthttpserver ^
  -skip qtdoc ^
  -vcpkg ^
  -nomake examples -nomake tests ^
  -- ^
  -DFEATURE_system_zlib=OFF ^
  -DFEATURE_system_jpeg=OFF ^
  -DFEATURE_system_doubleconversion=OFF
if errorlevel 1 (
    echo configure Qt failed
    exit /b
)

cmake --build . -j
if errorlevel 1 (
    echo Building Qt failed
    exit /b
)

cmake --install .
if errorlevel 1 (
    echo Installing Qt failed
    exit /b
)

echo "Successfully built and installed static Qt to %QT_TARGET_DIR%"

