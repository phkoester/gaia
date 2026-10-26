#
# base.cmake
#
# To be included from a project's root `CMakeLists.txt` file.
#

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
  message(FATAL_ERROR "Unsupported OS ${CMAKE_SYSTEM_NAME}")
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
  message(FATAL_ERROR "Unsupported C compiler ${CMAKE_C_COMPILER_ID}")
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
  message(FATAL_ERROR "Unsupported C++ compiler ${CMAKE_CXX_COMPILER_ID}")
endif()

# CMPs ------------------------------------------------------------------------------------------------------

# Get rid off a warning from libcbor
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
# "More read-only target properties now error when trying to set them."
if(POLICY CMP0160)
  cmake_policy(SET CMP0160 NEW)
endif()

# Configuration ---------------------------------------------------------------------------------------------
#
# - CMake variables take precedence over environment variables.
# - Environment variables take precedence over defaults.
#
# -----------------------------------------------------------------------------------------------------------

function(AddVar name type default doc)
  if(NOT DEFINED ${name})
    if(NOT $ENV{${name}} STREQUAL "")
      set(${name} $ENV{${name}} CACHE ${type} "${doc}")
      message(STATUS "gaia: Setting ${name} by environment: ${${name}}")
    else()
      set(${name} ${default} CACHE ${type} "${doc}")
      message(STATUS "gaia: Setting ${name} to default: ${${name}}")
    endif()
  else()
    message(STATUS "gaia: Found ${name}: ${${name}}")
  endif()
endfunction()

AddVar(BUILD_SHARED_LIBS BOOL OFF "Build shared libraries")
AddVar(BUILD_TESTING     BOOL ON  "Enable testing and build tests")
AddVar(COVERAGE          BOOL OFF "Enable code coverage")

if(NOT DEFINED CMAKE_CONFIGURATION_TYPES)
  AddVar(CMAKE_BUILD_TYPE STRING Release "The build type")
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

# Private functions -----------------------------------------------------------------------------------------

# ParseArgs__(outSrcFiles outEnv srcFile... [ENVIRONMENT name=value]...)
function(ParseArgs__ outSrcFiles outEnv)
  set(srcFiles)
  set(env)
  set(appendTo srcFiles)
  foreach(it IN LISTS ARGN)
    if(it STREQUAL "ENVIRONMENT")
      set(appendTo env)
    else()
      list(APPEND ${appendTo} ${it})
    endif()
  endforeach()

  set(${outSrcFiles} ${srcFiles} PARENT_SCOPE)
  set(${outEnv} ${env} PARENT_SCOPE)
endfunction()

# Functions -------------------------------------------------------------------------------------------------

# CopyRuntimeFiles(name)
function(CopyRuntimeFiles name)
  if(GAIA_OS_WINDOWS AND BUILD_SHARED_LIBS)
    # `copy_if_newer` requires CMake 4.2
    add_custom_command(
      TARGET  ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_newer $<TARGET_RUNTIME_DLLS:${name}> $<TARGET_FILE_DIR:${name}>
      COMMAND_EXPAND_LISTS
    )
  endif()
endfunction()

# AddExecutable(name srcFile...)
function(AddExecutable name)
  add_executable(${name})
  target_sources(${name} PRIVATE ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
endfunction()

# AddBench(name dir srcFile... [ENVIRONMENT name=value...])
function(AddBench name dir)
  ParseArgs__(srcFiles env ${ARGN})

  list(TRANSFORM srcFiles PREPEND "${dir}/")
  AddExecutable(${name} ${srcFiles})
  target_link_libraries(${name} PRIVATE benchmark::benchmark_main Rocket::rocket-bench)
  CopyRuntimeFiles(${name})

  add_test(
    NAME    ${name}
    COMMAND ${name}
  )

  string(JOIN " " configs ${CMAKE_CONFIGURATION_TYPES})

  set_property(TEST ${name}
    PROPERTY ENVIRONMENT
      "BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}"
      "CONFIG=$<CONFIG>"
      "CONFIGS=${configs}"
      "SOURCE_DIR=${CMAKE_SOURCE_DIR}/src/test/${dir}"
      ${env}
  )
endfunction()

# AddTest(name dir srcFile... [ENVIRONMENT name=value...])
function(AddTest name dir)
  ParseArgs__(srcFiles env ${ARGN})

  list(TRANSFORM srcFiles PREPEND "${dir}/")
  AddExecutable(${name} ${srcFiles})
  target_link_libraries(${name} PRIVATE Rocket::rocket-test-main Rocket::rocket-test)
  CopyRuntimeFiles(${name})

  string(JOIN " " configs ${CMAKE_CONFIGURATION_TYPES})

  set(envProps)
  foreach(it IN LISTS env)
    list(APPEND envProps PROPERTIES ENVIRONMENT "${it}")
  endforeach()

  gtest_discover_tests(${name}
    DISCOVERY_MODE PRE_TEST
    EXTRA_ARGS --gtest_catch_exceptions=0
    PROPERTIES ENVIRONMENT "BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}"
    PROPERTIES ENVIRONMENT "CONFIG=$<CONFIG>"
    PROPERTIES ENVIRONMENT "CONFIGS=${configs}"
    PROPERTIES ENVIRONMENT "SOURCE_DIR=${CMAKE_SOURCE_DIR}/src/test/${dir}"
    ${envProps}
  )
endfunction()

# AddLibrary(name ...), like add_library()
function(AddLibrary name)
  add_library(${name} ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
endfunction()

# UnixPath(in out)
function(UnixPath in out)
  if(GAIA_OS_WINDOWS)
    execute_process(COMMAND cygpath -u ${in} OUTPUT_VARIABLE localOut)
    string(STRIP ${localOut} localOut)
    set(${out} ${localOut} PARENT_SCOPE)
  else()
    set(${out} ${in} PARENT_SCOPE)
  endif()
endfunction()

# EOF
