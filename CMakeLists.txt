cmake_minimum_required(VERSION 3.5)

project(midi-shell VERSION "0.0.1" LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Threads REQUIRED)

## RtMidi library
add_library(RtMidi STATIC "thirdparty/rtmidi/RtMidi.cpp")
target_include_directories(RtMidi PUBLIC "thirdparty/rtmidi")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(RtMidi PUBLIC "__LINUX_ALSA__")
  target_link_libraries(RtMidi PUBLIC "asound")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(RtMidi PUBLIC "__WINDOWS_MM__")
  target_link_libraries(RtMidi PUBLIC "winmm")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  target_compile_definitions(RtMidi PUBLIC "__MACOSX_CORE__")
  find_library(COREMIDI_LIBRARY "CoreMIDI")
  find_library(FOUNDATION_LIBRARY "Foundation")
  target_link_libraries(RtMidi PUBLIC "${COREMIDI_LIBRARY}" "${FOUNDATION_LIBRARY}")
endif()

## Guile library
include(FindPkgConfig)
pkg_check_modules(GUILE "guile-2.2" REQUIRED)

## midi-shell program
add_executable(midi-shell "sources/midi-shell.cc")
target_compile_definitions(midi-shell PRIVATE "PREFIX=\"${CMAKE_INSTALL_PREFIX}\"")
target_include_directories(midi-shell PRIVATE ${GUILE_INCLUDE_DIRS})
target_link_libraries(midi-shell PRIVATE RtMidi ${GUILE_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
link_directories(${GUILE_LIBRARY_DIRS})

## install
install(TARGETS midi-shell DESTINATION "bin")
install(DIRECTORY "lisp" DESTINATION "share/midi-shell")
