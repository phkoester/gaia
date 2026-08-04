::
:: gaia-make.cmd
::
:: To be included by a project's `make.cmd` file.
::
:: Usage:
::   gaia-make                  calls `default`
::   gaia-make bench [PATTERN]
::   gaia-make build [TARGET]
::   gaia-make clean
::   gaia-make configure
::   gaia-make default          calls `configure` and `build`
::   gaia-make info
::   gaia-make test [PATTERN]
::   gaia-make test-terminal    for Rocket only
::
:: Parameters:
::
:: - BUILD_TYPE
::     The build type: `debug` or `release` (default)
:: - CXX_TOOLCHAIN
::     The C++ toolchain: `llvm` or `msvc` (default)
:: - VERBOSE
::     Produce verbose output
::

@echo off

setlocal enableextensions
SET NAME=%~n0

:: Configure build type -------------------------------------------------------------------------------------

if not defined BUILD_TYPE set BUILD_TYPE=release
if %BUILD_TYPE% neq debug if %BUILD_TYPE% neq release (
  echo %NAME%: `BUILD_TYPE`: Invalid value `%BUILD_TYPE%`; expected `debug` or `release` 1>&2
  exit /b 2
)

if %BUILD_TYPE% == debug set CONFIG=Debug
if %BUILD_TYPE% == release set CONFIG=Release

:: Configure C++ toolchain ----------------------------------------------------------------------------------

if not defined CXX_TOOLCHAIN set CXX_TOOLCHAIN=msvc
if %CXX_TOOLCHAIN% neq llvm if %CXX_TOOLCHAIN% neq msvc (
  echo %NAME%: `CXX_TOOLCHAIN`: Invalid value `%CXX_TOOLCHAIN%`; expected `llvm` or `msvc` 1>&2
  exit /b 2
)

set CMAKE_TOOLCHAIN_FLAG=
if %CXX_TOOLCHAIN% == llvm set CMAKE_TOOLCHAIN_FLAG=-T ClangCL

:: Configure verbose output ---------------------------------------------------------------------------------

set CMAKE_TRAILING_FLAGS=
set CTEST_FLAGS=

if %VERBOSE% == 1 (
  set CMAKE_TRAILING_FLAGS=-v
  set CTEST_FLAGS=-V
)

:: Parse command --------------------------------------------------------------------------------------------

if "%~1" == "" (
  call :default
  goto :eof
) else if "%1" == "bench" (
  call :bench %2
  goto :eof
) else if "%1" == "build" (
  call :build %2
  goto :eof
) else if "%1" == "clean" (
  call :clean
  goto :eof
) else if "%1" == "configure" (
  call :configure
  goto :eof
) else if "%1" == "default" (
  call :default
  goto :eof
) else if "%1" == "info" (
  call :info
  goto :eof
) else if "%1" == "test" (
  call :test %2
  goto :eof
) else if "%1" == "test-terminal" (
  call :test-terminal
  goto :eof
) else (
  echo %NAME%: Invalid command `%1` 1>&2
  exit /b 2
)

goto :eof

:: bench ----------------------------------------------------------------------------------------------------

:bench

set PATTERN=%1
if not defined PATTERN (
  ctest --test-dir build\src\bench --preset windows-%BUILD_TYPE% -V
) else (
  ctest --test-dir build\src\bench --preset windows-%BUILD_TYPE% -R %PATTERN% -V
)
if %errorlevel% neq 0 exit /b %errorlevel%

goto :eof

:: build ----------------------------------------------------------------------------------------------------

:build

set TARGET=%1
if not defined TARGET (
  cmake --build --preset windows-%BUILD_TYPE% %CMAKE_TRAILING_FLAGS%
) else (
  cmake --build --preset windows-%BUILD_TYPE% --target %TARGET% %CMAKE_TRAILING_FLAGS%
)
if %errorlevel% neq 0 exit /b %errorlevel%

goto :eof

:: clean ----------------------------------------------------------------------------------------------------

:clean

if exist build\ (
  echo Removing build directory. This may take a while ...
  rmdir /q /s build
  if %errorlevel% neq 0 exit /b %errorlevel%
)

goto :eof

:: configure ------------------------------------------------------------------------------------------------

:configure

cmake %CMAKE_TOOLCHAIN_FLAG% --preset windows
if %errorlevel% neq 0 exit /b %errorlevel%

goto :eof

:: default --------------------------------------------------------------------------------------------------

:default

call :configure
call :build

goto :eof

:: info -----------------------------------------------------------------------------------------------------

:info

echo ########################################
echo #
echo # BUILD_TYPE   : %BUILD_TYPE%
echo # CXX_TOOLCHAIN: %CXX_TOOLCHAIN%
echo # VERBOSE      : %VERBOSE%
echo #
echo ########################################

goto :eof

:: test -----------------------------------------------------------------------------------------------------

:test

set PATTERN=%1
if not defined PATTERN (
  ctest --test-dir build\src\test --preset windows-%BUILD_TYPE% %CTEST_FLAGS%
) else (
  ctest --test-dir build\src\test --preset windows-%BUILD_TYPE% -R %PATTERN% %CTEST_FLAGS%
)
if %errorlevel% neq 0 exit /b %errorlevel%

goto :eof

:: test-terminal --------------------------------------------------------------------------------------------

:test-terminal

set ROCKET_TEST_TERMINAL=1

build\src\test\%CONFIG%\test-rocket-system-terminal.exe
build\src\test\%CONFIG%\test-rocket-unicode-Character.exe

goto :eof

:: EOF
