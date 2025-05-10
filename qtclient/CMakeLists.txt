project(qtstuff
        DESCRIPTION "POC app"
        VERSION ${APP_VERSION}
        LANGUAGES CXX)

message(STATUS "CMake system processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMake host system name: ${CMAKE_HOST_SYSTEM_NAME}")
message(STATUS "Pointer size (CMAKE_SIZEOF_VOID_P): ${CMAKE_SIZEOF_VOID_P}")
message(STATUS "CMake build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMake generator: ${CMAKE_GENERATOR}")        
message(STATUS "CMake generator platform: ${CMAKE_GENERATOR_PLATFORM}")    
message(STATUS "CMake generator toolset: ${CMAKE_GENERATOR_TOOLSET}")
message(STATUS "CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message(STATUS "VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}")

if (ENABLE_GRPC)
    set(GRPC_PACKAGES Core Protobuf ProtobufQuick Grpc ProtobufQtCoreTypes)
    set(GRPC_TARGETS
        grpc_stuff_grpc
        Qt6::Core
	gRPC::grpc++
    )
    find_package(gRPC CONFIG REQUIRED)
    add_compile_definitions(ENABLE_GRPC)
endif()

# Find the Qt 6 Quick module
find_package(Qt6 REQUIRED COMPONENTS Quick ${GRPC_PACKAGES} REQUIRED)

qt_standard_project_setup(REQUIRES 6.8)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0002 NEW)
qt_policy(SET QTP0003 NEW)
qt_policy(SET QTP0004 NEW)

if (ENABLE_GRPC)
    qt_add_protobuf(grpc_stuff_pb
       QML
       QML_URI QtGrpcStuff.Proto
        PROTO_FILES
            ${protofile}
        PROTO_INCLUDES
            $<TARGET_PROPERTY:Qt6::ProtobufQtCoreTypes,QT_PROTO_INCLUDES>
    )

    qt_add_grpc(grpc_stuff_grpc CLIENT
        PROTO_FILES ${protofile}
    )

    target_link_libraries(grpc_stuff_grpc
        PUBLIC
            grpc_stuff_pb
            Qt6::Protobuf
            Qt6::ProtobufQtCoreTypes
            Qt6::Grpc
    )
endif()

# Create the executable with the necessary source files.
# Make sure that main.cpp and qml.qrc exist in your project.
qt6_add_executable(${PROJECT_NAME}
    main.cpp
)

# Create a QML module.
# 'URI' is used by QML's import statement, and 'VERSION' sets the module version.
# 'QML_FILES' lists the QML files to be bundled.
qt6_add_qml_module(${PROJECT_NAME}
    URI QtStuff
    VERSION 1.0
    QML_FILES
        qml/Main.qml
    SOURCES
        DataModel.h
        DataModel.cpp
)

#add_dependencies(${PROJECT_NAME} GrpcClient StuffProtoLib)

if (APPLE)
    # Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
    # If you are developing for iOS or macOS you should consider setting an
    # explicit, fixed bundle identifier manually though.
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_GUI_IDENTIFIER com.jgaa.${PROJECT_NAME}
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
    )
endif()

if (WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

target_include_directories(${PROJECT_NAME}
    PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>/src
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<BUILD_INTERFACE: ${CMAKE_BINARY_DIR}/generated-include>
    )

target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt6::Quick
            ${GRPC_TARGETS}
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
