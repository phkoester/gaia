# Gaia

Gaia is a collection of Bash scripts, Python scripts, and Makefiles that helps you to build C++ and Rust
projects in a Bash shell.

It is pre-alpha, a hobby project of mine, and possibly dangerous. **Use it at your own risk.**

Recommended readings:

- [Text-File Guidelines](doc/text-file-guidelines.md)
- [Coding Guidelines](doc/coding-guidelines.md)
- [C++ Guidelines](doc/c++-guidelines.md)
- [Rust Guidelines](doc/rust-guidelines.md)
- [Dictionary](doc/dictionary.md)

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Set Up

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

| Environment Variable      | Required? | Description
| :------------------------ | :-------- | :----------
| `GAIA_BUILD_TYPE`         | No        | Values: `debug`, `release` (default)
| `GAIA_CXX_TOOLCHAIN`      | No        | Values: `gnu` (default on Linux), `llvm` (default on Windows), `msvc`
| `GAIA_DIR`                | Yes       | Example: `~/project/gaia`
| `GAIA_PROJECT_DIR`        | No        | Fallback directory where `gaia-build` looks for projects

After that, to initialize Gaia, place this line in your `~/.bashrc`:

```bash
source "$GAIA_DIR/src/main/bash/gaia/init"
```

Now, when opening a terminal that loads your `.bashrc`, you should see a "This is Gaia" message. This means
that Gaia is successfully installed and configured.
