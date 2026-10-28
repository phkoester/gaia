#
# gaia.cmake
#
# To be included from a project's root `CMakeLists.txt` file.
#

include(${CMAKE_CURRENT_LIST_DIR}/GaiaHelpers.cmake)

# Prerequisites ---------------------------------------------------------------------------------------------

if(WIN32)
  # On Windows, output compromises the console mode of Git SDK Bash
  set(quiet__ QUIET)
endif()
find_package(Python3 3.8 ${quiet__} REQUIRED COMPONENTS Interpreter)

# Check host tuple ------------------------------------------------------------------------------------------

if(LINUX)
  set(GAIA_OS linux)
  set(GAIA_OS_LINUX ON)
endif()
if(WIN32)
  set(GAIA_OS windows)
  set(GAIA_OS_WINDOWS ON)
endif()

if(NOT(GAIA_OS_LINUX) AND NOT(GAIA_OS_WINDOWS))
  GaiaFatalError("Unsupported OS ${CMAKE_SYSTEM_NAME}")
endif()

# Check C/C++ toolchain -------------------------------------------------------------------------------------

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set(GAIA_C_COMPILER clang)
  set(GAIA_C_COMPILER_CLANG ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  set(GAIA_C_COMPILER gnu)
  set(GAIA_C_COMPILER_GNU ON)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  set(GAIA_C_COMPILER msvc)
  set(GAIA_C_COMPILER_MSVC ON)
endif()

if(NOT(GAIA_C_COMPILER_CLANG) AND NOT(GAIA_C_COMPILER_GNU) AND NOT(GAIA_C_COMPILER_MSVC))
  GaiaFatalError("Unsupported C compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(GAIA_CXX_COMPILER clang)
  set(GAIA_CXX_COMPILER_CLANG ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(GAIA_CXX_COMPILER gnu)
  set(GAIA_CXX_COMPILER_GNU ON)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(GAIA_CXX_COMPILER mesvc)
  set(GAIA_CXX_COMPILER_MSVC ON)
endif()

if(NOT(GAIA_CXX_COMPILER_CLANG) AND NOT(GAIA_CXX_COMPILER_GNU) AND NOT(GAIA_CXX_COMPILER_MSVC))
  GaiaFatalError("Unsupported C++ compiler ${CMAKE_CXX_COMPILER_ID}")
endif()

# CMPs ------------------------------------------------------------------------------------------------------

# Get rid off a warning from libcbor
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
# "More read-only target properties now error when trying to set them."
if(POLICY CMP0160)
  cmake_policy(SET CMP0160 NEW)
endif()

GaiaAddVar(BUILD_SHARED_LIBS BOOL OFF "Build shared libraries")
GaiaAddVar(BUILD_TESTING     BOOL ON  "Enable testing and build tests")
GaiaAddVar(COVERAGE          BOOL OFF "Enable code coverage")

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

set(LINK_FLAGS)

if(COVERAGE)
  list(APPEND COMPILE_FLAGS -coverage)
  list(APPEND LINK_FLAGS -coverage)
endif()

# Set OS-specific compiler options --------------------------------------------------------------------------

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

# EOF
