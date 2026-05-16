#
# base.cmake
#
# To be included from a project's root `CMakeLists.txt` file.
#

# Check host tuple -------------------------------------------------------------------------------------------

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

# Check C/C++ toolchain --------------------------------------------------------------------------------------

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
      message(STATUS "Setting ${name} by environment: ${${name}}")
    else()
      set(${name} ${default} CACHE ${type} "${doc}")
      message(STATUS "Setting ${name} to default: ${${name}}")
    endif()
  else()
    message(STATUS "Found ${name}: ${${name}}")
  endif()
endfunction()

AddVar(BUILD_SHARED_LIBS BOOL OFF "Build shared libraries")
AddVar(BUILD_TESTING     BOOL ON  "Enable testing and build tests")

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

set(BUILD_SHARED_LIBS_DEFAULT ${BUILD_SHARED_LIBS})

# Set compiler definitions, features, and options -----------------------------------------------------------

set(COMPILE_DEFS)
set(COMPILE_FEATURES cxx_std_23)
set(COMPILE_FLAGS)

# Set OS-specific compiler options --------------------------------------------------------------------------

if(GAIA_OS_LINUX)
  # gcc will not accept `__int128` with `-pedantic`
  list(APPEND COMPILE_FLAGS -Wall -Wextra -Wno-ignored-attributes)
elseif(GAIA_OS_WINDOWS)
  list(APPEND COMPILE_FLAGS /Zc:preprocessor) # /Wall
endif()

# Functions -------------------------------------------------------------------------------------------------

# AddExecutable(name srcFile...)
function(AddExecutable name)
  add_executable(${name})
  target_sources(${name} PRIVATE ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})

  if($<TARGET_RUNTIME_DLLS:${name}>)
    add_custom_command(
      TARGET  ${name} POST_BUILD
      # `copy_if_newer` requires CMake 4.2
      COMMAND ${CMAKE_COMMAND} -E copy_if_newer $<TARGET_RUNTIME_DLLS:${name}> $<TARGET_FILE_DIR:${name}>
      COMMAND_EXPAND_LISTS
    )
  endif()
endfunction()

# ParseArgs__(srcFiles env  srcFile... [ENVIRONMENT name=value...])
function(ParseArgs__ srcFiles__ env__)
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

  set(${srcFiles__} ${srcFiles} PARENT_SCOPE)
  set(${env__} ${env} PARENT_SCOPE)
endfunction()

# AddBench(name dir srcFile... [ENVIRONMENT name=value...])
function(AddBench name dir)
  ParseArgs__(srcFiles env ${ARGN})

  list(TRANSFORM srcFiles PREPEND "${dir}/")
  AddExecutable(${name} ${srcFiles})
  target_link_libraries(${name}
    PRIVATE
      benchmark::benchmark benchmark::benchmark_main Rocket::rocket Rocket::rocket-bench
  )

  add_test(
    NAME              ${name}
    COMMAND           ${name}
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
  target_link_libraries(${name}
    PRIVATE
      Rocket::rocket-test-main Rocket::rocket-test)

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

# Dependency versions ---------------------------------------------------------------------------------------

AddVar(GAIA_BENCHMARK_VERSION STRING 1.9.5  "benchmark version") # https://github.com/google/benchmark
AddVar(GAIA_BOOST_VERSION     STRING 1.90.0 "Boost version")     # https://github.com/boostorg/boost
AddVar(GAIA_FMT_VERSION       STRING 12.1.0 "{fmt} version")     # https://github.com/fmtlib/fmt
AddVar(GAIA_GTEST_VERSION     STRING 1.17.0 "GTest version")     # https://github.com/google/googletest
# XXX 78.2
AddVar(GAIA_ICU_VERSION       STRING 77.1   "ICU version")       # sudo apt install libicu-dev
AddVar(GAIA_ROCKET_VERSION    STRING HEAD   "Rocket version")
AddVar(GAIA_SCNLIB_VERSION    STRING master  "scnlib version")    # https://github.com/eliaskosunen/scnlib

# Dependency declarations -----------------------------------------------------------------------------------

include(FetchContent)

# Benchmark (when used, must follow GTest) ..................................................................

FetchContent_Declare(
  benchmark
  GIT_REPOSITORY https://github.com/google/benchmark.git
  GIT_TAG        v${GAIA_BENCHMARK_VERSION}
  GIT_PROGRESS   TRUE
  SYSTEM
  EXCLUDE_FROM_ALL
)

# Boost .....................................................................................................

FetchContent_Declare(
  Boost
  URL              https://github.com/boostorg/boost/releases/download/boost-${GAIA_BOOST_VERSION}/boost-${GAIA_BOOST_VERSION}-cmake.7z
  SYSTEM
  EXCLUDE_FROM_ALL
)

# fmt .......................................................................................................

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
  GIT_TAG        ${GAIA_FMT_VERSION}
  GIT_PROGRESS   TRUE
  SYSTEM
  EXCLUDE_FROM_ALL
)

# GTest .....................................................................................................

FetchContent_Declare(
  GTest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        v${GAIA_GTEST_VERSION}
  GIT_PROGRESS   TRUE
  SYSTEM
  EXCLUDE_FROM_ALL
)

# ICU .......................................................................................................
#
# ICU is not fully CMake-ready, so it must be installed manually.
#
# On Ubuntu, say
#
#   $ sudo apt install libicu-dev
#
# On Windows,
#
# - download <https://github.com/unicode-org/icu/releases/download/release-VERSION/icu4c-VERSION-Win64-MSVC2022.zip>
# - unpack, copy to `C:\icu4c-VERSION-Win64-MSVC2022`
# - set system variable `ICU_ROOT` to `C:\icu4c-VERSION-Win64-MSVC2022`
# - add `C:\icu4c-VERSION-Win64-MSVC2022\bin64` to the system variable `PATH`
#
# ...........................................................................................................

# Rocket ....................................................................................................

FetchContent_Declare(
  Rocket
  GIT_REPOSITORY https://github.com/phkoester/rocket.git
  GIT_TAG        ${CRANK_ROCKET_VERSION}
  GIT_PROGRESS   TRUE
  SYSTEM
  EXCLUDE_FROM_ALL
)

# scnlib ....................................................................................................

FetchContent_Declare(
  scnlib
  GIT_REPOSITORY https://github.com/eliaskosunen/scnlib.git
  GIT_TAG        ${GAIA_SCNLIB_VERSION}
  GIT_PROGRESS   TRUE
  SYSTEM
  EXCLUDE_FROM_ALL
)

# EOF
