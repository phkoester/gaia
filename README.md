# Gaia

Gaia is an experimental collection of Bash scripts, Python scripts, and Makefiles that help to build projects
in a Bash shell.

**NOTE:** For the time being, it is not recommended for public use. Use it at your own risk.

Supported project types are Bash, Python, C++, and Rust.

All other `phkoester` projects depend on Gaia. Gaia is supposed to be the building ground of everything.

Recommended readings:

- [Text-File Guidelines](doc/text_file_guidelines.md)
- [C++ Guidelines](doc/c++-guidelines.md)
- [Rust Guidelines](doc/rust-guidelines.md)
- [Dictionary](doc/dictionary.md)

## Set Up

### Required Packages

- `cmake`
- `grcov` (?)
- `lldb` (?)
- `llvm` (?)
- `make`
- `python3`
- `python3-json5`
- `python3-semver`
- `python3-toml`

### Recommended Packages

- `batcat`
- `gedit`
- `meld`
- `ripgrep`
- `valgrind`

### Gaia

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

| Environment Variable      | Required? | Description
| :------------------------ | :-------- | :----------
| `GAIA_BOOST_DIR`          | No        | Absolute path to Boost. If not set, the system's default Boost version is used
| `GAIA_BUILD_TYPE`         | No        | Values: `debug` (default), `release`
| `GAIA_CPP_UNICODELIB_DIR` | Yes       | Example: `~/project/cpp-unicodelib`
| `GAIA_CXX_GNU`            | No        | Absolute path to the `g++` executable. If not set, `which g++` is used
| `GAIA_CXX_LLVM`           | No        | Absolute path to the `clang++` executable. If not set, `which clang++` is used
| `GAIA_CXX_TOOLCHAIN`      | No        | Values: `gnu`, `llvm` (default)
| `GAIA_DIR`                | Yes       | Example: `~/project/gaia`
| `GAIA_DOXYGEN`            | No        | Example: `/usr/local/bin/doxygen-1.12.0/bin/doxygen`
| `GAIA_EDITOR`             | No        | Example: `nano` (default)
| `GAIA_GTEST_DIR`          | Yes       | Example: `~/project/googletest`
| `GAIA_PROJECT_DIR`        | No        | Fallback directory where `gaia-build` looks for projects

After that, to initialize Gaia, place this line in `~/.bashrc`:

```bash
source "$GAIA_DIR/src/main/bash/gaia/init"
```

Now, when opening a terminal that loads your `.bashrc`, you should see a message like the following:

```
########################################
#
# This is Gaia 1.2.0
#
# Detected host: x86_64-pc-linux-gnu
#
########################################
```

This means that Gaia is successfully installed and configured.

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
