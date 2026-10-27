#
# GaiaHelpers.cmake
#
# Helper functions for Gaia.
#

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

# AddExecutable(name srcFile...)
function(AddExecutable name)
  add_executable(${name})
  target_sources(${name} PRIVATE ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
endfunction()

# AddLibrary(name ...), like add_library()
function(AddLibrary name)
  add_library(${name} ${ARGN})
  target_compile_definitions(${name} PRIVATE ${COMPILE_DEFS})
  target_compile_features(${name} PRIVATE ${COMPILE_FEATURES})
  target_compile_options(${name} PRIVATE ${COMPILE_FLAGS})
  target_link_options(${name} PRIVATE ${LINK_FLAGS})
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

# AddVar(name type default doc)
#
# Adds a CMMake variable. If it is already set, it is left unchanged. Otherwise, if there is an environment
# variable with the same name, it is used. As a fallback, the default value is used.
function(AddVar name type default doc)
  if(NOT DEFINED ${name})
    if(NOT $ENV{${name}} STREQUAL "")
      set(${name} $ENV{${name}} CACHE ${type} "${doc}")
      message(STATUS "${PROJECT_NAME}: Setting ${name} by environment: ${${name}}")
    else()
      set(${name} ${default} CACHE ${type} "${doc}")
      message(STATUS "${PROJECT_NAME}: Setting ${name} to default: ${${name}}")
    endif()
  else()
    message(STATUS "${PROJECT_NAME}: Found ${name}: ${${name}}")
  endif()
endfunction()

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
