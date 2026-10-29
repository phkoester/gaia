#
# CMakeLists.txt
#

cmake_minimum_required(VERSION 4.2)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/GaiaFunctions.cmake)

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

find_package(Python3 3.8 REQUIRED COMPONENTS Interpreter)
GaiaDetectPython()

if(WIN32)
  if("$ENV{DevEnvDir}" STREQUAL "")
    GaiaFatalError("Developer Command Prompt for Microsoft Visual Studio is required")
  endif()
endif()

# Check host tuple ------------------------------------------------------------------------------------------

if(LINUX)
  set(CACHE{GAIA_OS} VALUE linux)
  set(CACHE{GAIA_OS_LINUX} VALUE ON)
endif()
if(WIN32)
  set(CACHE{GAIA_OS} VALUE windows)
  set(CACHE{GAIA_OS_WINDOWS} VALUE ON)
endif()

if(NOT(GAIA_OS_LINUX) AND NOT(GAIA_OS_WINDOWS))
  GaiaFatalError("Unsupported OS ${CMAKE_SYSTEM_NAME}")
endif()

# Check C/C++ toolchain -------------------------------------------------------------------------------------

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set(CACHE{GAIA_C_COMPILER} VALUE clang)
  set(CACHE{GAIA_C_COMPILER_CLANG} VALUE ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set(CACHE{GAIA_C_COMPILER} VALUE gnu)
  set(CACHE{GAIA_C_COMPILER_GNU} VALUE ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(CACHE{GAIA_C_COMPILER} VALUE msvc)
  set(CACHE{GAIA_C_COMPILER_MSVC} VALUE ON)
endif()

if(NOT(GAIA_C_COMPILER_CLANG) AND NOT(GAIA_C_COMPILER_GNU) AND NOT(GAIA_C_COMPILER_MSVC))
  GaiaFatalError("Unsupported C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CACHE{GAIA_CXX_COMPILER} VALUE clang)
  set(CACHE{GAIA_CXX_COMPILER_CLANG} VALUE ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(CACHE{GAIA_CXX_COMPILER} VALUE gnu)
  set(CACHE{GAIA_CXX_COMPILER_GNU} VALUE ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(CACHE{GAIA_CXX_COMPILER} VALUE msvc)
  set(CACHE{GAIA_CXX_COMPILER_MSVC} VALUE ON)
endif()

if(NOT(GAIA_CXX_COMPILER_CLANG) AND NOT(GAIA_CXX_COMPILER_GNU) AND NOT(GAIA_CXX_COMPILER_MSVC))
  GaiaFatalError("Unsupported C++ compiler ${CMAKE_CXX_COMPILER_ID}")
endif()

# Configuration ---------------------------------------------------------------------------------------------

if(NOT DEFINED CMAKE_CONFIGURATION_TYPES)
  GaiaAddVar(CMAKE_BUILD_TYPE STRING Release "The build type")
endif()

# EOF
