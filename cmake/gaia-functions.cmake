#
# gaia-functions.cmake
#
# Helper functions for Gaia.
#

# Functions -------------------------------------------------------------------------------------------------

# gaiaAddExecutable(name srcFile...)
function(gaiaAddExecutable name)
  add_executable(${name})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
  target_sources(${name} PRIVATE ${ARGN})
  gaiaCopyRuntimeFiles(${name})
endfunction()

# gaiaAddLibrary(name ...)
function(gaiaAddLibrary name)
  add_library(${name} ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
endfunction()

# gaiaAddVar(name type default doc)
#
# Adds a CMake cache variable. If it is already set, it is left unchanged. Otherwise, if there is an
# environment variable with the same name, it is used. As a fallback, the default value is used.
function(gaiaAddVar name type default doc)
  if(NOT DEFINED ${name})
    if(DEFINED ENV{${name}})
      set(${name} $ENV{${name}} CACHE ${type} "${doc}")
      gaiaStatus("setting ${name} by environment: ${${name}}")
    else()
      set(${name} ${default} CACHE ${type} "${doc}")
      gaiaStatus("setting ${name} to default: ${${name}}")
    endif()
  else()
    gaiaStatus("found ${name}: ${${name}}")
  endif()
endfunction()

# gaiaCopyRuntimeFiles(name)
function(gaiaCopyRuntimeFiles name)
  if(GAIA_OS_WINDOWS AND BUILD_SHARED_LIBS)
    # `copy_if_newer` requires CMake 4.2. The command is empty, and thus does nothing, if there are no
    # runtime DLLs
    set(dlls $<TARGET_RUNTIME_DLLS:${name}>)
    add_custom_command(
      TARGET  ${name} POST_BUILD
      COMMAND "$<$<BOOL:${dlls}>:${CMAKE_COMMAND};-E;copy_if_newer;${dlls};$<TARGET_FILE_DIR:${name}>>"
      COMMAND_EXPAND_LISTS
      VERBATIM
    )
  endif()
endfunction()

# gaiaDetectPython()
#
# Sets the cache variable `Python3_EXECUTABLE`, unless the user has already set it. Then sets the cache
# variable `GAIA_PYTHON_NATIVE_WINDOWS` from the path separator returned by `Python3_EXECUTABLE`. A native
# Windows Python interpreter reports `\`. Other Python interpreters report `/`.
function(gaiaDetectPython)
  # Do not test `Python3_EXECUTABLE` here. It is already in the cache on the first run if the user passes
  # `-DPython3_EXECUTABLE=...`, and the detection below must not be skipped then
  if(DEFINED CACHE{GAIA_PYTHON_NATIVE_WINDOWS})
    return()
  endif()

  if(NOT DEFINED CACHE{Python3_EXECUTABLE})
    set(CACHE{Python3_EXECUTABLE} VALUE ${Python3_EXECUTABLE})
  endif()
  if(NOT WIN32)
    set(CACHE{GAIA_PYTHON_NATIVE_WINDOWS} VALUE OFF)
    return()
  endif()

  execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import os; print('backslash' if os.sep == chr(92) else 'slash')"
    OUTPUT_VARIABLE sep
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE error
    RESULT_VARIABLE result
  )
  if(NOT result EQUAL 0)
    gaiaFatalError("cannot run `${Python3_EXECUTABLE}`: ${error}")
  endif()

  if(sep STREQUAL "backslash")
    set(CACHE{GAIA_PYTHON_NATIVE_WINDOWS} VALUE ON)
    gaiaStatus("Python 3 uses Windows paths: `${Python3_EXECUTABLE}`")
  elseif(sep STREQUAL "slash")
    set(CACHE{GAIA_PYTHON_NATIVE_WINDOWS} VALUE OFF)
    gaiaStatus("Python 3 uses Unix paths: `${Python3_EXECUTABLE}`")
  else()
    gaiaFatalError("invalid path separator `${sep}` from `${Python3_EXECUTABLE}`")
  endif()
endfunction()

# gaiaFatalError(msg)
function(gaiaFatalError msg)
  message(FATAL_ERROR "${PROJECT_NAME}: ${msg}")
endfunction()

# gaiaGenerateVersionHeader(dir file namespace version)
#
# Generates a C++ version header at configure time.
#
# - `dir`: the base directory, typically one on the include path
# - `file`: the header path relative to `dir`, e.g., `my-app/version.h`
# - `namespace`: the C++ namespace for the constants. May be nested, e.g., `a::b`
# - `version`: the version. Must be a SemVer 2.0.0 string
#
# The header defines these `constexpr` constants in `namespace`:
#
# - `VERSION_NAME`: the full version string (`std::string_view`)
# - `VERSION_MAJOR`, `VERSION_MINOR`, `VERSION_PATCH`: the numeric components (`int`)
# - `VERSION_PRERELEASE`, `VERSION_BUILD_METADATA`: the optional parts, or empty (`std::string_view`)
# - `VERSION`: a comparable value, 1,000,000 * major + 1,000 * minor + patch (`int`)
#
# The header is only rewritten if its contents change, so an unchanged version does not trigger a rebuild.
function(gaiaGenerateVersionHeader dir file namespace version)
  # SemVer 2.0.0, see `https://semver.org`. CMake regexes have no non-capturing groups, so the groups are:
  # 1 major, 2 minor, 3 patch, 5 prerelease, 8 build metadata
  set(ident "[0-9A-Za-z-]+")
  set(re "^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)")
  string(APPEND re "(-(${ident}(\\.${ident})*))?(\\+(${ident}(\\.${ident})*))?$")
  if(NOT version MATCHES "${re}")
    gaiaFatalError("`${version}` is not a valid SemVer string")
  endif()
  set(major ${CMAKE_MATCH_1})
  set(minor ${CMAKE_MATCH_2})
  set(patch ${CMAKE_MATCH_3})
  set(prerelease "${CMAKE_MATCH_5}")
  set(buildMetadata "${CMAKE_MATCH_8}")
  # Numeric prerelease identifiers must not have leading zeros
  if(prerelease MATCHES "(^|\\.)0[0-9]+(\\.|$)")
    gaiaFatalError("`${version}` is not a valid SemVer string")
  endif()
  math(EXPR value "${major} * 1000000 + ${minor} * 1000 + ${patch}")
  cmake_path(GET file FILENAME fileName)

  file(CONFIGURE
    OUTPUT ${dir}/${file}
    CONTENT [=[/**
 * @file @fileName@
 *
 * This is a generated file. Do not edit.
 */

#pragma once

#include <string_view>

namespace @namespace@ {

constexpr std::string_view VERSION_NAME = "@version@"; ///< SemVer string.

constexpr int VERSION_MAJOR = @major@; ///< Major.
constexpr int VERSION_MINOR = @minor@; ///< Minor.
constexpr int VERSION_PATCH = @patch@; ///< Patch.
constexpr std::string_view VERSION_PRERELEASE = "@prerelease@"; ///< Prerelease, or empty.
constexpr std::string_view VERSION_BUILD_METADATA = "@buildMetadata@"; ///< Build metadata, or empty.

/// Comparable version value (1,000,000 * major + 1,000 * minor + patch).
constexpr int VERSION = @value@;

} // namespace @namespace@

// EOF
]=]
    @ONLY
  )
endfunction()

# gaiaPythonPath(in out)
#
# Converts `in` into a path that the configured Python 3 understands. Native Windows Python gets a Windows
# path. MSYS Python gets a Unix path from `cygpath -u`. Other Python interpreters get the path as is.
function(gaiaPythonPath in out)
  if(GAIA_PYTHON_NATIVE_WINDOWS)
    file(TO_NATIVE_PATH "${in}" localOut)
    set(${out} "${localOut}" PARENT_SCOPE)
  elseif(GAIA_OS_WINDOWS)
    gaiaWindowsUnixPath(${in} localOut)
    set(${out} "${localOut}" PARENT_SCOPE)
  else()
    set(${out} "${in}" PARENT_SCOPE)
  endif()
endfunction()

# gaiaStatus(msg)
function(gaiaStatus msg)
  message(STATUS "${PROJECT_NAME}: ${msg}")
endfunction()

# Windows functions -----------------------------------------------------------------------------------------

if(WIN32) # `GAIA_OS_WINDOWS` isn’t available yet

# gaiaWindowsUnixPath(in out)
#
# Converts the Windows path `in` into a Unix path using `cygpath -u`. Fails if `cygpath` cannot be run,
# fails, or prints nothing.
function(gaiaWindowsUnixPath in out)
  execute_process(
    COMMAND cygpath -u "${in}"
    OUTPUT_VARIABLE localOut
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE error
    ERROR_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE result
  )
  # `result` is the exit status, or an error message if `cygpath` cannot be run at all
  if(NOT result EQUAL 0)
    gaiaFatalError("cannot convert `${in}` with `cygpath`: ${result}: ${error}")
  endif()
  if(localOut STREQUAL "")
    gaiaFatalError("cannot convert `${in}` with `cygpath`: empty output")
  endif()
  set(${out} "${localOut}" PARENT_SCOPE)
endfunction()

endif() # WIN32

# EOF
