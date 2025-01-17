# Gaia

Gaia is an experimental collection of Bash scripts, Python scripts, and Makefiles that help to build projects
in a Bash shell.

Supported project types are Bash, Python, C++, and Rust.

I decided to make this repository public on GitHub, since all `phkoester` repositories depend on Gaia. This
is where the name comes from: Gaia is supposed to be the building ground of everything.

**NOTE:** For the time being, it is not recommended for public use. Use it at your own risk.

## Installation

- [C++](doc/install-c++.md)
- [Rust](doc/install-rust.md)
- [Visual Studio Code](doc/install-vs-code.md)
- [Windows Development](doc/install-win.md)
- [Windows/WSL/Ubuntu Development](doc/install-win-wsl-ubuntu.md)

### Gaia

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

| Variable                  | Required? | Description
| :------------------------ | :-------- | :----------
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

After that, to initialize Gaia, place this line in `~/.bashrc`:

```bash
source "$GAIA_DIR/src/main/bash/gaia/init"
```

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by
you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or
conditions.
