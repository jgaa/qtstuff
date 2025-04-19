@echo off

REM Check for directory "qtclient"
if not exist "qtclient\" (
    echo Error: This script must be run from the project's root directory containing the 'qtclient' folder.
    exit /b 1
)

set "SOURCE_DIR=%CD%"

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

echo Preparing to build qtstuff...
echo SOURCE_DIR is: %SOURCE_DIR%    
echo BUILD_DIR is: %BUILD_DIR%
echo QT_TARGET_DIR is: %QT_TARGET_DIR%
echo VCPKG_ROOT is: %VCPKG_ROOT%
echo VCPKG_DEFAULT_TRIPLET is: %VCPKG_DEFAULT_TRIPLET%

echo Static Qt target dir is: %QT_TARGET_DIR%
if not exist "%QT_TARGET_DIR%\" (
    echo Qt static build not found. Running build-static-qt.bat...
    call .\scripts\build-static-qt.bat
    if errorlevel 1 (
        echo Error: Failed to build static Qt.
        exit /b 1
    )
)

echo
echo -------------------------------------------
echo Building qtstuff using statically linked Qt
echo

set "MY_BUILD_DIR=%BUILD_DIR%\qtstuff"
set "TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake"
echo MY_BUILD_DIR is: %MY_BUILD_DIR%
echo TOOLCHAIN_FILE is: %TOOLCHAIN_FILE%
echo Building qtstuff in %MY_BUILD_DIR%

rmdir /S /Q "%MY_BUILD_DIR%"
mkdir "%MY_BUILD_DIR%"
if errorlevel 1 (
    echo Failed to create %MY_BUILD_DIR%
    exit /b
)

pushd "%MY_BUILD_DIR%"
if errorlevel 1 (
    echo Failed to pushd into %MY_BUILD_DIR%
    exit /b
)

echo %PATH% | find /I "%VCPKG_ROOT%" >nul
if errorlevel 1 (
    set "PATH=%VCPKG_ROOT%;%PATH%"
)
echo Path is: %PATH%

echo copy /Y %SOURCE_DIR%\build-configs\vcpkg-noqt.json %MY_BUILD_DIR%\vcpkg.json
copy /Y "%SOURCE_DIR%\build-configs\vcpkg-noqt.json" vcpkg.json
if errorlevel 1 (
    echo Failed to copy %SOURCE_DIR%\build-configs\vcpkg-noqt.json to vcpkg.json
    exit /b
)

echo Running vcpkg install for qtstuff
vcpkg install --triplet "%VCPKG_DEFAULT_TRIPLET%"

echo Listing vcpkg packages
vcpkg list

echo "Calling cmake for qtstuff"
cmake -S "%SOURCE_DIR%" -B "%MY_BUILD_DIR%" ^
    -DCMAKE_TOOLCHAIN_FILE="%TOOLCHAIN_FILE%" ^
    -DVCPKG_TARGET_TRIPLET="%VCPKG_DEFAULT_TRIPLET%" ^
    -DENABLE_GRPC=ON ^
    -DCMAKE_PREFIX_PATH="%QT_TARGET_DIR%" ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo Failed to run cmake
    exit /b
)

set "PATH=%MY_BUILD_DIR%\vcpkg_installed\%VCPKG_DEFAULT_TRIPLET%\tools\brotli;%MY_BUILD_DIR%\vcpkg_installed\%VCPKG_DEFAULT_TRIPLET%\bin;%MY_BUILD_DIR%\bin;%PATH%"

cmake --build . --config Release
if errorlevel 1 (
    echo Failed to build the project
    exit /b
)

cpack -G NSIS

copy /Y "%MY_BUILD_DIR%\*.exe" "%BUILD_DIR%\"
if errorlevel 1 (
    echo Failed to copy the executable installer
    exit /b
)

popd
