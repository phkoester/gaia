# Windows / WSL / Ubuntu

- Activate WSL feature
- Install Windows Subsystem for Linux (WSL) 2: https://docs.microsoft.com/en-us/windows/wsl/install
- wsl --list online
- Install Ubuntu LTS distro

## Ubuntu

- Copy to ~/.ssh
- Copy to ~/.cargo/credentials.toml
- Copy to ~/.gitconfig
- Copy to ~/.bashrc
- Locale
  - sudo locale-gen en_US.UTF-8
  - sudo dpkg-reconfigure locales
- Google Drive: sudo mount -t drvfs G: /mnt/g

## WSLg

- Some old note
  - ln -sf /mnt/wslg/runtime-dir/wayland-* $XDG_RUNTIME_DIR/ # Stil needed???
- gedit must open immediately, File Open dialog must work
  - Check if this is really needed ...
    - git clone https://github.com/viruscamp/wslg-links.git
    - cd wslg-links
    - sudo cp wslg-tmp-x11.service /usr/lib/systemd/system/
    - sudo cp wslg-runtime-dir.service /usr/lib/systemd/user/
    - sudo systemctl --global disable pulseaudio.socket
    - sudo systemctl enable wslg-tmp-x11
    - sudo systemctl --global enable wslg-runtime-dir
  - Check if this is really needed ...
    - sudo add-apt-repository ppa:oibaf/graphics-drivers
    - sudo apt update
    - sudo apt upgrade

## Tauri

- https://v2.tauri.app/start/prerequisites/
- sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
- export WEBKIT_DISABLE_DMABUF_RENDERER=1 # For Tauri/WSL
- cargo install create-tauri-app
  - cargo create-tauri-app
  - cargo tauri dev (test)
- Check what is required
  - cargo install trunk
  - cargo install tauri-cli
