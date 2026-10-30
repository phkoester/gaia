# Gaia

Gaia is a collection of Bash scripts, Python scripts, Makefiles, and various other scripts that help you to
build C++ and Rust projects on Linux and Windows.

macOS would be a welcome addition and shouldn't be too hard to do, but that's not in the pipeline as of yet.

## CMake Requirements

* CMake 4.2 or higher.
* Python 3.8 or higher. On Windows, both a native Windows Python and an MSYS Python will work.
* The Python package `semver`.
* On Windows, a Developer Command Prompt from Microsoft Visual Studio is required.

## Set Up the Shell

This section is only for developers who want to use Gaia on the shell directly. If you only consume Gaia via
a transitive CMake dependency, you can skip this chapter.

### Linux

On Linux, Gaia runs on the standard Bash. In the following examples, `apt` will be assumed to be the system's
package manager. If you use a different manager, adjust the commands as appropriate.

Run these commands:

```shell
$ sudo apt update
$ sudo apt upgrade
$ sudo apt dist-upgrade
$ sudo apt install python3 python3-json5 python3-semver python3-toml
```

### Windows

First, enable the "Use Unicode UTF-8 for worldwide language support" option Windows. Make sure Windows
Terminal is installed.

On Windows, Gaia runs on the Bash from the [Git for Windows SDK](https://gitforwindows.org/) on top
of the Developer Command Prompt from [Microsoft Visual Studio](https://visualstudio.microsoft.com/de/).

Install both the Git for Windows SDK and Microsoft Visual Studio (with C/C++ and Clang). Add
`C:\git-sdk-64\usr\bin` to the system variable `PATH`.

Then, create a file called `git-bash-dev.cmd` in your Windows user-profile directory:

```cmd
@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat" -startdir=none -arch=x64 -host_arch=x64
C:\git-sdk-64\usr\bin\bash.exe -i -l
```

**Tip:** In the Git for Windows SDK installation directory, rename the `.git` directory to something like
`.git.renamed`. This will speed up the shell significantly.

In Windows Terminal, duplicate the Developer Command Prompt, name the new profile "Git Bash Developer" and
set the command line to `cmd.exe /k %USERPROFILE%\git-bash-dev.cmd`. Set the starting directory to
`%USERPROFILE%`.

Open the "Git Bash Developer" profile in Windows Terminal and run these commands:

```shell
$ pacman -Syu
$ pacman -S procps`
$ pacman -S python-pip
$ pip3 install --break-system-packages json5 semver toml
```

## Set Up Gaia

Clone from `git@github.com:phkoester/gaia.git` (SSH) or <https://github.com/phkoester/gaia.git> (HTTPS).

In your `~/.bashrc`, export these variables:

| Environment Variable      | Required? | Description
| :------------------------ | :-------- | :----------
| `GAIA_BUILD_TYPE`         | No        | Values: `debug`, `release` (default)
| `GAIA_CXX_TOOLCHAIN`      | No        | Values: `gnu` (default on Linux), `llvm`, `msvc` (default on Windows)
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
