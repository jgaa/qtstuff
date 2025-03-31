cmake_minimum_required(VERSION 3.16)

project(QtQmlAndGrpc)

set(APP_VERSION 0.1.0)
add_definitions(-DAPP_VERSION="\""${APP_VERSION}\""")

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
