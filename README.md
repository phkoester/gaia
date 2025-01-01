# Gaia

Gaia is an experimental collection of Bash scripts, Python scripts, and Makefiles that help to build projects
in a Bash shell.

Supported project types are Bash, Python, C++, and Rust. There used to be some Android support, but it's
deprecated now.

I decided to make this repository public on GitHub, since all `phkoester` repositories depend on Gaia. This
is where the name comes from: Gaia is supposed to be the building ground of everything.

**NOTE:** For the time being, it is not recommended for public use. Use it at your own risk.

## Installation

### System Packages

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

In addition, these packages are recommended:

* `build-essential gdb`
* `gedit`
* `grcov`
* `meld`
* `ripgrep`
* `valgrind`

### Boost

If you want to use a particular Boost version, download it from <https://www.boost.org/users/download/>.

Make sure `GAIA_BOOST_DIR` points to the downloaded version of Boost.

### cpp-unicodelib

Clone from <https://github.com/yhirose/cpp-unicodelib.git>.

### GoogleTest

Clone from `https://github.com/google/googletest.git`.

To build the libraries, use the script `gaia-make-gtest` for the current platform.

### Rust

After installing the `rustup`package, say `rustup default stable` and `rustup update`.

Install additional packages using `cargo install`

* `cargo-msrv`
* `create-tauri-app`

### Gaia

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

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
| `GAIA_RUSTUP_TOOLCHAIN`   | Yes       | Example: `stable-x86_64-unknown-linux-gnu`

After that, to initialize Gaia, place this line in `~/.bashrc`:

```bash
source "$GAIA_DIR/src/main/bash/gaia/init"
```

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

### WSL

If you experience problems with `wslg` on WSL/Ubuntu, try the following:

```bash
git clone https://github.com/viruscamp/wslg-links.git
cd wslg-links
sudo cp wslg-tmp-x11.service /usr/lib/systemd/system/
sudo cp wslg-runtime-dir.service /usr/lib/systemd/user/
sudo systemctl --global disable pulseaudio.socket
sudo systemctl enable wslg-tmp-x11
sudo systemctl --global enable wslg-runtime-dir
sudo add-apt-repository ppa:oibaf/graphics-drivers
sudo apt update
sudo apt upgrade
```

Use `gedit` to verify all is well.

## License

Licensed under either of

* Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by
you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or
conditions.
