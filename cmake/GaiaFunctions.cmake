#
# GaiaFunctions.cmake
#
# Helper functions for Gaia.
#

# Private functions -----------------------------------------------------------------------------------------

# GaiaParseArgs__(outSrcFiles outEnv srcFile... [ENVIRONMENT name=value]...)
function(GaiaParseArgs__ outSrcFiles outEnv)
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

# GaiaAddBench(name dir srcFile... [ENVIRONMENT name=value...])
function(GaiaAddBench name dir)
  GaiaParseArgs__(srcFiles env ${ARGN})

  list(TRANSFORM srcFiles PREPEND "${dir}/")
  GaiaAddExecutable(${name} ${srcFiles})
  target_link_libraries(${name} PRIVATE benchmark::benchmark_main Rocket::rocket-bench)
  GaiaCopyRuntimeFiles(${name})

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

# GaiaAddExecutable(name srcFile...)
function(GaiaAddExecutable name)
  add_executable(${name})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
  target_sources(${name} PRIVATE ${ARGN})
endfunction()

# GaiaAddLibrary(name ...), like add_library()
function(GaiaAddLibrary name)
  add_library(${name} ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
endfunction()

# GaiaAddTest(name dir srcFile... [ENVIRONMENT name=value...])
function(GaiaAddTest name dir)
  GaiaParseArgs__(srcFiles env ${ARGN})

  list(TRANSFORM srcFiles PREPEND "${dir}/")
  GaiaAddExecutable(${name} ${srcFiles})
  target_link_libraries(${name} PRIVATE Rocket::rocket-test-main Rocket::rocket-test)
  GaiaCopyRuntimeFiles(${name})

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

# GaiaAddVar(name type default doc)
#
# Adds a CMake cache variable. If it is already set, it is left unchanged. Otherwise, if there is an
# environment variable with the same name, it is used. As a fallback, the default value is used.
function(GaiaAddVar name type default doc)
  if(NOT DEFINED CACHE{name})
    if(DEFINED ENV{${name}})
      set(${name} $ENV{${name}} CACHE ${type} "${doc}")
      GaiaStatus("Setting ${name} by environment: ${${name}}")
    else()
      set(${name} ${default} CACHE ${type} "${doc}")
      GaiaStatus("Setting ${name} to default: ${${name}}")
    endif()
  else()
    GaiaStatus("Found ${name}: ${${name}}")
  endif()
endfunction()

# GaiaCopyRuntimeFiles(name)
function(GaiaCopyRuntimeFiles name)
  if(GAIA_OS_WINDOWS AND BUILD_SHARED_LIBS)
    # `copy_if_newer` requires CMake 4.2
    add_custom_command(
      TARGET  ${name} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_newer $<TARGET_RUNTIME_DLLS:${name}> $<TARGET_FILE_DIR:${name}>
      COMMAND_EXPAND_LISTS
    )
  endif()
endfunction()

# GaiaDetectPython()
#
# Sets the cache variable `Python3_EXECUTABLE`. Then sets the cache variable `GAIA_PYTHON_NATIVE_WINDOWS`
# from the path separator returned by `Python3_EXECUTABLE`. A native Windows Python interpreter reports `\`.
# Other Python interpreters report `/`.
function(GaiaDetectPython)
  if(DEFINED CACHE{Python3_EXECUTABLE})
    return()
  endif()

  set(CACHE{Python3_EXECUTABLE} VALUE ${Python3_EXECUTABLE})
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
    GaiaFatalError("Could not run `${Python3_EXECUTABLE}`: ${error}")
  endif()

  if(sep STREQUAL "backslash")
    set(CACHE{GAIA_PYTHON_NATIVE_WINDOWS} VALUE ON)
    GaiaStatus("Python 3 uses Windows paths: `${Python3_EXECUTABLE}`")
  elseif(sep STREQUAL "slash")
    set(CACHE{GAIA_PYTHON_NATIVE_WINDOWS} VALUE OFF)
    GaiaStatus("Python 3 uses Unix paths: `${Python3_EXECUTABLE}`")
  else()
    GaiaFatalError("Invalid path separator from `${Python3_EXECUTABLE}`: `${sep}`")
  endif()
endfunction()

# GaiaFatalError(msg)
function(GaiaFatalError msg)
  message(FATAL_ERROR "${PROJECT_NAME}: ${msg}")
endfunction()

# GaiaPythonPath(in out)
#
# Converts `in` into a path that the configured Python 3 understands. Native Windows Python gets a Windows
# path. MSYS Python gets a Unix path from `cygpath -u`. Other Python interpreters get the path as is.
function(GaiaPythonPath in out)
  if(GAIA_PYTHON_NATIVE_WINDOWS)
    file(TO_NATIVE_PATH "${in}" localOut)
    set(${out} "${localOut}" PARENT_SCOPE)
  elseif(GAIA_OS_WINDOWS)
    GaiaWindowsUnixPath(${in} localOut)
    set(${out} "${localOut}" PARENT_SCOPE)
  else()
    set(${out} "${in}" PARENT_SCOPE)
  endif()
endfunction()

# GaiaStatus(msg)
function(GaiaStatus msg)
  message(STATUS "${PROJECT_NAME}: ${msg}")
endfunction()

# Windows functions -----------------------------------------------------------------------------------------

if(WIN32) # `GAIA_OS_WINDOWS` isn't available yet

# GaiaWindowsUnixPath(in out)
function(GaiaWindowsUnixPath in out)
  execute_process(COMMAND cygpath -u "${in}" OUTPUT_VARIABLE localOut)
  string(STRIP ${localOut} localOut)
  set(${out} "${localOut}" PARENT_SCOPE)
endfunction()

endif() # WIN32

# EOF
