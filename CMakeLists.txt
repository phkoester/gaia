# CMakeLists.txt

cmake_minimum_required(VERSION 4.2)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/gaia-functions.cmake)

# Project ---------------------------------------------------------------------------------------------------

project(gaia VERSION 1.2.5)

# Prerequisites ---------------------------------------------------------------------------------------------

find_package(Python3 3.10 REQUIRED COMPONENTS Interpreter)
gaiaDetectPython()

if(WIN32)
  if(NOT DEFINED ENV{DevEnvDir})
    gaiaFatalError("missing Developer Command Prompt from Microsoft Visual Studio")
  endif()
endif()

# Check host tuple ------------------------------------------------------------------------------------------

if(LINUX)
  set(CACHE{GAIA_OS_LINUX} VALUE ON)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  set(CACHE{GAIA_OS_MACOS} VALUE ON)
elseif(WIN32)
  set(CACHE{GAIA_OS_WINDOWS} VALUE ON)
endif()

if(NOT(GAIA_OS_LINUX) AND NOT(GAIA_OS_MACOS) AND NOT(GAIA_OS_WINDOWS))
  gaiaFatalError("unsupported OS ${CMAKE_SYSTEM_NAME}")
endif()

# Check C/C++ toolchain -------------------------------------------------------------------------------------

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set(CACHE{GAIA_C_COMPILER_GNU} VALUE ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
  set(CACHE{GAIA_C_COMPILER_LLVM} VALUE ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(CACHE{GAIA_C_COMPILER_MSVC} VALUE ON)
endif()

if(NOT(GAIA_C_COMPILER_GNU) AND NOT(GAIA_C_COMPILER_LLVM) AND NOT(GAIA_C_COMPILER_MSVC))
  gaiaFatalError("unsupported C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(CACHE{GAIA_CXX_COMPILER_GNU} VALUE ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  set(CACHE{GAIA_CXX_COMPILER_LLVM} VALUE ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(CACHE{GAIA_CXX_COMPILER_MSVC} VALUE ON)
endif()

if(NOT(GAIA_CXX_COMPILER_GNU) AND NOT(GAIA_CXX_COMPILER_LLVM) AND NOT(GAIA_CXX_COMPILER_MSVC))
  gaiaFatalError("unsupported C++ compiler ${CMAKE_CXX_COMPILER_ID}")
endif()

# General settings ------------------------------------------------------------------------------------------

set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_DISABLE_PRECOMPILE_HEADERS ON) # ccache will benefit from this on Windows
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded) # This makes ccache work on Windows
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS OFF)

set(FETCHCONTENT_QUIET FALSE)

# Configuration ---------------------------------------------------------------------------------------------

gaiaAddVar(BUILD_SHARED_LIBS BOOL OFF "Build shared libraries")
gaiaAddVar(BUILD_TESTING     BOOL ON  "Enable testing: benchmarks and tests")

if(NOT DEFINED CMAKE_CONFIGURATION_TYPES)
  gaiaAddVar(CMAKE_BUILD_TYPE STRING Release "The build type (`Debug` or `Release`)")
endif()

# EOF
