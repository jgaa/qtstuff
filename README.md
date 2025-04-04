# qtstuff
For testing and reporting bugs in QT

qtgrpc problem under Windows:
```
C:\build\qtstuff>cmake --build .
MSBuild version 17.13.19+0d9f5a35a for .NET Framework

  1>Checking Build System
  Generating QtProtobuf grpc_stuff sources for qtprotobufgen...
CUSTOMBUILD : CMake warning :  [C:\build\qtstuff\qtclient\grpc_stuff_qtprotobufgen_deps_0.vcxproj]
    No source or binary directory provided.  Both will be assumed to be the
    same as the current working directory, but note that this warning will
    become a fatal error in future CMake releases.


CUSTOMBUILD : CMake error : The source directory "C:/build/qtstuff/qtclient" does not appear to contain CMakeLists.txt. [C:\build\qtstuff\qtclient\grpc_stuff_qtprotobufgen_deps_0.vcxproj]
  Specify --help for usage, or press the help button on the CMake GUI.
C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VC\v170\Microsoft.CppCommon.targets(254,5): error MSB8066: Custom build for 'C:\build\qtstuff\CMakeFiles\2ef21142ea786b78ade2140344f2b0
d7\stuff.qpb.h.rule;C:\build\qtstuff\CMakeFiles\f9eddd6ee52a8313fb47d2a818bb5982\grpc_stuff_qtprotobufgen_deps_0.rule;C:\Users\jgaa\source\repos\qtstuff\qtclient\CMakeLists.txt' exited with code 1. [C:\build\q
tstuff\qtclient\grpc_stuff_qtprotobufgen_deps_0.vcxproj]
  Building Custom Rule C:/Users/jgaa/source/repos/qtstuff/qtclient/CMakeLists.txt
  qrc_qmake_QtGrpcStuff_Proto_init.cpp
  grpc_stuff_resources_1.vcxproj -> C:\build\qtstuff\qtclient\grpc_stuff_resources_1.dir\Debug\grpc_stuff_resources_1.lib
  1>Automatic MOC and UIC for target grpc_stuffplugin_init
  Building Custom Rule C:/Users/jgaa/source/repos/qtstuff/qtclient/CMakeLists.txt
  Running AUTOMOC file extraction for target grpc_stuffplugin_init
  Building Custom Rule C:/Users/jgaa/source/repos/qtstuff/qtclient/CMakeLists.txt
  Running moc --collect-json for target grpc_stuffplugin_init
  Building Custom Rule C:/Users/jgaa/source/repos/qtstuff/qtclient/CMakeLists.txt
  mocs_compilation_Debug.cpp
  grpc_stuffplugin_init.cpp
  Generating Code...
  grpc_stuffplugin_init.vcxproj -> C:\build\qtstuff\qtclient\grpc_stuffplugin_init.dir\Debug\grpc_stuffplugin_init.lib

```

To reproduce: Run **`build-for-windows.bat`**

**Note that**
- I don't use vcpkg bundled with msvc
- vcpkg is installed in `C:\src\vcpkg` If you use another location, you must update `build-for-windows.bat` with its location before running it.
- The build-location in `build-for-windows.bat` is `C:\build\qtstuff`. Change it to suit your preferences.

