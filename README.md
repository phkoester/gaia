# Gaia

Gaia is a collection of Bash scripts, Python scripts, Makefiles, and various other scripts that help you to
build C++ and Rust projects.

It is pre-alpha, a hobby project of mine, and possibly dangerous. **Use it at your own risk.**

## Set Up Bash

### Linux

On Linux, Gaia runs on the standard Bash. There is nothing to set up here.

### Windows

On Windows, Gaia runs on the Bash from the [Git for Windows SDK](https://gitforwindows.org/) on top
of the Developer Command Prompt from [Microsoft Visual Studio](https://visualstudio.microsoft.com/de/).

Install both the Git for Windows SDK and Microsoft Visual Studio. Then, create a file called
`git-bash-dev.cmd` in your Windows home directory:

```cmd
@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat" -startdir=none -arch=x64 -host_arch=x64
C:\git-sdk-64\usr\bin\bash.exe -i -l
```

In Windows Terminal, duplicate the Developer Command Prompt, name the new profile "Git Bash Developer" and
set the command line to `cmd.exe /k %USERPROFILE%\git-bash-dev.cmd`.

## Set Up Gaia

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

## Recommended Readings

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
