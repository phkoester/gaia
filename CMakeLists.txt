#
# CMakeLists.txt
#

cmake_minimum_required(VERSION 4.2)

include(${CMAKE_CURRENT_LIST_DIR}/GaiaFunctions.cmake)

# Project ---------------------------------------------------------------------------------------------------

# Is this the master project?
if(NOT DEFINED GAIA_MASTER_PROJECT)
  set(GAIA_MASTER_PROJECT OFF)
  if(NOT DEFINED PROJECT_NAME)
    set(GAIA_MASTER_PROJECT ON)
  endif()
endif()

project(gaia VERSION 1.2.0)

# Prerequisites ---------------------------------------------------------------------------------------------

if(WIN32)
  if("$ENV{DevEnvDir}" STREQUAL "")
    GaiaFatalError("Developer Command Prompt for Microsoft Visual Studio is required")
  endif()
endif()

find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
GaiaDetectPython()

# Check host tuple ------------------------------------------------------------------------------------------

if(LINUX)
  GaiaSet(GAIA_OS STRING linux)
  GaiaSet(GAIA_OS_LINUX BOOL ON)
endif()
if(WIN32)
  GaiaSet(GAIA_OS STRING windows)
  GaiaSet(GAIA_OS_WINDOWS BOOL ON)
endif()

if(NOT(GAIA_OS_LINUX) AND NOT(GAIA_OS_WINDOWS))
  GaiaFatalError("Unsupported OS ${CMAKE_SYSTEM_NAME}")
endif()

# Check C/C++ toolchain -------------------------------------------------------------------------------------

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  GaiaSet(GAIA_C_COMPILER STRING clang)
  GaiaSet(GAIA_C_COMPILER_CLANG BOOL ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  GaiaSet(GAIA_C_COMPILER STRING gnu)
  GaiaSet(GAIA_C_COMPILER_GNU BOOL ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  GaiaSet(GAIA_C_COMPILER STRING msvc)
  GaiaSet(GAIA_C_COMPILER_MSVC BOOL ON)
endif()

if(NOT(GAIA_C_COMPILER_CLANG) AND NOT(GAIA_C_COMPILER_GNU) AND NOT(GAIA_C_COMPILER_MSVC))
  GaiaFatalError("Unsupported C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  GaiaSet(GAIA_CXX_COMPILER STRING clang)
  GaiaSet(GAIA_CXX_COMPILER_CLANG BOOL ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  GaiaSet(GAIA_CXX_COMPILER STRING gnu)
  GaiaSet(GAIA_CXX_COMPILER_GNU BOOL ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  GaiaSet(GAIA_CXX_COMPILER STRING msvc)
  GaiaSet(GAIA_CXX_COMPILER_MSVC BOOL ON)
endif()

if(NOT(GAIA_CXX_COMPILER_CLANG) AND NOT(GAIA_CXX_COMPILER_GNU) AND NOT(GAIA_CXX_COMPILER_MSVC))
  GaiaFatalError("Unsupported C++ compiler ${CMAKE_CXX_COMPILER_ID}")
endif()

# Configuration ---------------------------------------------------------------------------------------------

if(NOT DEFINED CMAKE_CONFIGURATION_TYPES)
  GaiaAddVar(CMAKE_BUILD_TYPE STRING Release "The build type")
endif()

# General settings ------------------------------------------------------------------------------------------

set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(FETCHCONTENT_QUIET FALSE)

# Set compiler and linker options ---------------------------------------------------------------------------

set(COMPILE_DEFS)

set(COMPILE_FEATURES cxx_std_23)

set(COMPILE_FLAGS)
if(GAIA_OS_LINUX)
  # Linux
  list(APPEND COMPILE_FLAGS -Wall -Werror -Wextra)
  if(GAIA_CXX_COMPILER_GNU)
    # Linux, GNU
    list(APPEND COMPILE_FLAGS -Wno-ignored-attributes)
  endif()
elseif(GAIA_OS_WINDOWS)
  # Windows
  if(GAIA_CXX_COMPILER_CLANG)
    # Windows, Clang
    list(APPEND COMPILE_FLAGS -Werror) # `-Wall` and `-Wextra` seem to be too much noise on Windows
  endif()
  if(GAIA_CXX_COMPILER_MSVC)
    # Windows, MSVC
    list(APPEND COMPILE_FLAGS /bigobj /Zc:preprocessor)
  endif()
endif()

set(LINK_FLAGS)

if(COVERAGE)
  list(APPEND COMPILE_FLAGS -coverage)
  list(APPEND LINK_FLAGS -coverage)
endif()

# EOF
