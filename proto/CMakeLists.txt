
project (proto)

find_package(gRPC CONFIG REQUIRED)
find_package(Protobuf REQUIRED)
add_library(${PROJECT_NAME} STATIC stuff.proto)
target_link_libraries(${PROJECT_NAME} PUBLIC gRPC::grpc++)
protobuf_generate(TARGET ${PROJECT_NAME})
protobuf_generate(
    TARGET ${PROJECT_NAME}
    LANGUAGE grpc
    PLUGIN protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
    PLUGIN_OPTIONS generate_mock_code=true
    GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc)

set(PROTO_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
