# Gaia

Gaia is a collection of Bash scripts, Python scripts, and Makefiles that help to build projects in a Bash
shell.

## Installation

### Boost

If you want to use a particular Boost version, download it from <https://www.boost.org/users/download/>.

### cpp-unicodelib

Clone from <https://github.com/yhirose/cpp-unicodelib.git>.

### Gaia

Clone from `git@github.com:phkoester/gaia.git` (SSH) or `https://github.com/phkoester/gaia.git` (HTTPS).

Export these variables:

| Variable                  | Required? | Description
| ------------------------- | --------- | -----------
| `GAIA_BOOST_DIR`          | No        | Absolute path to Boost. If not set, the system's default Boost version is used
| `GAIA_BUILD_TYPE`         | No        | Values: `debug` (default), `release`
| `GAIA_CPP_UNICODELIB_DIR` | Yes       | Example: `~/project/cpp-unicodelib`
| `GAIA_CXX_GNU`            | No        | Absolute path to the `g++` executable. If not set, `which g++` is used
| `GAIA_CXX_LLVM`           | No        | Absolute path to the `clang++` executable. If not set, `which clang++` is used
| `GAIA_CXX_TOOLCHAIN`      | No        | Values: `gnu`, `llvm` (default)
| `GAIA_DIR`                | Yes       | Example: `~/project/gaia`
| `GAIA_DOXYGEN`            | No        | Example: `~/download/doxygen-1.12.0/bin/doxygen`
| `GAIA_EDITOR`             | No        | Example: `nano` (default)
| `GAIA_GTEST_DIR`          | Yes       | Example: `~/project/googletest`
| `GAIA_RUSTC_TOOLCHAIN`    | Yes       | Example: `/rustc/f6e511eec7342f59a25f7c0534f1dbea00d01b14`

Then, to initialize Gaia, say

```
$ source "$GAIA_DIR/src/main/bash/gaia/init"
```

The following packages are needed by Gaia. On some systems such as Ubuntu, they may be installed using
`sudo apt install`.

* `clang`
* `cmake`
* `cppcheck`
* `doxygen`
* `g++`
* `graphviz` (needed by `doxygen`)
* `libboost-all-dev`
* `lldb`
* `llvm`
* `openjdk-21-jre-headless` (needed by `doxygen`)
* `python3-pip`
* `rustup`
* `texlive-latex-base`  (needed by `doxygen`)

The following packages are recommended:

* `build-essential gdb`
* `meld`
* `ripgrep`
* `valgrind`

### GoogleTest

Clone from `https://github.com/google/googletest.git`.

To build the libraries, use the script `gaia-make-gtest` for the current platform.

### Rust

After installing the `rustup`package, say `rustup default stable` and `rustup update`.

### Visual Studio Code

The following extensions are recommended:

* Local
  * Microsoft: C/C++ Themes
  * Microsoft: WSL
* WSL
  * GitHub: GitHub Copilot
  * GitKraken: GitLens --- Git supercharged
  * LLVM: clangd
  * LLVM: LLDB DAP
    * Executable-path: `/bin/lldb-dap-18`
  * Microsoft: Makefile Tools
  * Microsoft: Pylance
  * Microsoft: Python
  * Microsoft: Python Debugger
  * The Rust Programming Language: rust-analyzer
