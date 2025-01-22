# Install Windows/WSL/Ubuntu Development

## WSL

- Activate WSL feature in Windows
- Install Windows Subsystem for Linux (WSL) 2
  - <https://docs.microsoft.com/en-us/windows/wsl/install>
- `wsl --list online`
- Install latest Ubuntu LTS distro
- `wsl --update`

## Ubuntu

- Copy to `~/.bashrc`
- Copy to `~/.cargo/credentials.toml`
- Copy to `~/.gitconfig`
- Copy to `~/.ssh/`
- Locale
  - ```bash
    sudo locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales
    ```
- Google Drive: `sudo mount -t drvfs G: /mnt/g`

## WSLg

- `gedit` must open immediately, native file dialog must work
  - Check if this is really needed ...
    - ```bash
      git clone https://github.com/viruscamp/wslg-links.git
      cd wslg-links
      sudo cp wslg-tmp-x11.service /usr/lib/systemd/system/
      sudo cp wslg-runtime-dir.service /usr/lib/systemd/user/
      sudo systemctl --global disable pulseaudio.socket
      sudo systemctl enable wslg-tmp-x11
      sudo systemctl --global enable wslg-runtime-dir
      ```
  - Check if this is really needed ...
    - ```bash
      sudo add-apt-repository ppa:oibaf/graphics-drivers
      sudo apt update
      sudo apt upgrade
      ```
  - Some old note, does this still apply?
    - `ln -sf /mnt/wslg/runtime-dir/wayland-* $XDG_RUNTIME_DIR/`

## C++

* `clang`
* `cmake`
* `cppcheck`
* `g++`
* `libboost-all-dev`
* `lldb`
* `llvm`
* `make`

### Boost

If you want to use a particular Boost version, download it from <https://www.boost.org/users/download/>.

Make sure `GAIA_BOOST_DIR` points to the downloaded version of Boost.

### cpp-unicodelib

Clone from <https://github.com/yhirose/cpp-unicodelib.git>.

### Doxygen

* `doxygen`
* `graphviz`
* `openjdk-21-jre-headless`
* `texlive-latex-base`

### GoogleTest

Clone from `https://github.com/google/googletest.git`.

To build the libraries, use the script `gaia-make-gtest` for the current platform.

## Rust

- `sudo apt install rustup`
- See [Install Rust](install-rust.md) 
