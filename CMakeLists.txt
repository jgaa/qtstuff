cmake_minimum_required(VERSION 3.16)

project(QtQmlAndGrpc)

set(APP_VERSION 0.1.0)
add_definitions(-DAPP_VERSION="\""${APP_VERSION}\""")

if(MSVC)
    add_compile_options(/EHsc)
endif()

option(ENABLE_GRPC "Enable gRPC support" ON)
#option(ENABLE_TLS  "Enable TLS support, using OpenSSL" OFF)


set (protofile ${CMAKE_CURRENT_SOURCE_DIR}/proto/stuff.proto)
#set (protofile_dir ${CMAKE_CURRENT_SOURCE_DIR}/proto)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_subdirectory(qtclient)

if (ENABLE_GRPC)
    add_subdirectory(proto)
    add_subdirectory(daemon)
endif()

message(STATUS "CMake system processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMake host system name: ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "Pointer size (CMAKE_SIZEOF_VOID_P): ${CMAKE_SIZEOF_VOID_P}")
message(STATUS "CMake build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMake generator: ${CMAKE_GENERATOR}")

if(WIN32)
    include(InstallRequiredSystemLibraries)

    # List of runtime DLLs to install with the app
    install(FILES
        "${CMAKE_BINARY_DIR}/bin/libssl-3-x64.dll"
        "${CMAKE_BINARY_DIR}/bin/libcrypto-3-x64.dll"
        "${CMAKE_BINARY_DIR}/bin/brotlidec.dll"
        "${CMAKE_BINARY_DIR}/bin/brotlicommon.dll"
        "${CMAKE_BINARY_DIR}/bin/brotlidec.dll"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    set(CPACK_GENERATOR "NSIS")
    set(CPACK_PACKAGE_NAME "qtstuff")
    set(CPACK_PACKAGE_VENDOR "The Last Viking LTD")
    set(CPACK_PACKAGE_CONTACT "tlv@example.com")
    set(CPACK_PACKAGE_VERSION_MAJOR ${APP_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${APP_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${APP_VERSION_PATCH})
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "qtstuff ${APP_VERSION}")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")

    set(CPACK_NSIS_DISPLAY_NAME "QtStuff")
    set(CPACK_NSIS_PACKAGE_NAME "qtstuff ${APP_VERSION}")
    set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/icon.ico")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\qtstuff.exe")
    set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
    set(CPACK_NSIS_MODIFY_PATH ON)

    # Create a Start Menu shortcut
    set(CPACK_NSIS_CREATE_ICONS_EXTRA "
    CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\qtstuff.lnk\\\" \\\"$INSTDIR\\\\bin\\\\qtstuff.exe\\\"
    ")

    # Clean up the shortcut during uninstall
    set(CPACK_NSIS_DELETE_ICONS_EXTRA "
    Delete \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\qtstuff.lnk\\\"
    RMDir \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\"
    ")

    # Define the folder name in the Start Menu
    set(CPACK_NSIS_START_MENU_FOLDER "qtstuff")

    include(CPack)
endif()

if(APPLE)
  include(InstallRequiredSystemLibraries)  # for any system libs (zlib, etc.)

  # Use the DragNDrop generator (produces a .dmg)
  set(CPACK_GENERATOR "DragNDrop")

  # Basic package info
  set(CPACK_PACKAGE_NAME        "qtstuff")
  set(CPACK_PACKAGE_VENDOR      "The Last Viking LTD")
  set(CPACK_PACKAGE_CONTACT     "tlv@example.com")
  set(CPACK_PACKAGE_VERSION_MAJOR ${APP_VERSION_MAJOR})
  set(CPACK_PACKAGE_VERSION_MINOR ${APP_VERSION_MINOR})
  set(CPACK_PACKAGE_VERSION_PATCH ${APP_VERSION_PATCH})

  # The name of the volume when the user mounts the DMG
  set(CPACK_DMG_VOLUME_NAME     "qtstuff ${APP_VERSION_MAJOR}.${APP_VERSION_MINOR}.${APP_VERSION_PATCH}")

  # (Optional) Custom background image & icon positions
  # set(CPACK_DMG_BACKGROUND_IMAGE "${CMAKE_SOURCE_DIR}/mac/dmg_background.png")
  # set(CPACK_DMG_DS_STORE_SETUP  "${CMAKE_SOURCE_DIR}/mac/dmg_dsstore")

  # Make sure we don’t end up with a monolithic installer
  set(CPACK_MONOLITHIC_INSTALL  OFF)

  include(CPack)
endif()

