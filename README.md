# Gaia

Gaia is an experimental collection of Bash scripts, Python scripts, and Makefiles that help to build projects
in a Bash shell.

**Note:** For the time being, it is not recommended for public use. Use it at your own risk.

Supported project types are Bash, Python, C++, and Rust.

All other `phkoester` projects depend on Gaia. Gaia is supposed to be the building ground of everything.

Recommended readings:

- [Text-File Guidelines](doc/text-file-guidelines.md)
- [Coding Guidelines](doc/coding-guidelines.md)
- [C++ Guidelines](doc/c++-guidelines.md)
- [Rust Guidelines](doc/rust-guidelines.md)
- [Dictionary](doc/dictionary.md)

## Set Up

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

| Environment Variable      | Required? | Description
| :------------------------ | :-------- | :----------
| `GAIA_BUILD_TYPE`         | No        | Values: `debug`, `release` (default)
| `GAIA_CXX_TOOLCHAIN`      | No        | Values: `gnu`, `llvm` (default)
| `GAIA_DIR`                | Yes       | Example: `~/project/gaia`
| `GAIA_EDITOR`             | No        | Example: `nano` (default)
| `GAIA_PROJECT_DIR`        | No        | Fallback directory where `gaia-build` looks for projects

After that, to initialize Gaia, place this line in your `~/.bashrc`:

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
