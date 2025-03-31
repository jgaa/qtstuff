project(grpc_daemon
        DESCRIPTION "POC app backend"
        VERSION ${APP_VERSION}
        LANGUAGES CXX)

include(FetchContent)

FetchContent_Declare(
  logfault
  GIT_REPOSITORY https://github.com/jgaa/logfault.git
  GIT_TAG        master
)
FetchContent_MakeAvailable(logfault)

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost REQUIRED CONFIG COMPONENTS
    program_options
)

add_executable(${PROJECT_NAME}
    main.cpp
    config.h
    GrpcServer.h GrpcServer.cpp
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${Boost_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${PROTO_BINARY_DIR}
)

message(STATUS "CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")
message(STATUS "PROTO_BINARY_DIR: ${PROTO_BINARY_DIR}")

target_link_libraries(${PROJECT_NAME}
    ${Boost_LIBRARIES}
    proto
    logfault
)
