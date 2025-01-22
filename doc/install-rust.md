# Install Rust

- rustup default stable
- rustup toolchain install nightly
- cargo install cargo-msrv
- rustup target add wasm32-unknown-unknown
- rustup +nightly component add miri
- rustup update

## Install Tauri

### Install Tauri in Ubuntu

- See https://v2.tauri.app/start/prerequisites/
- cargo install create-tauri-app
- cargo install tauri-cli
- Check what is really needed
  - sudo apt install libwebkit2gtk-4.1-dev build-essential curl wget file libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
  - sudo apt-get install javascriptcoregtk-4.1 libsoup-3.0
  - sudo apt install libglib2.0-dev
  - sudo apt-get install libgtk-3-dev
- cargo install trunk
- In .bashrc, .profile, or /etc/environment: export WEBKIT_DISABLE_DMABUF_RENDERER=1 # For Tauri/WSL

### Install Tauri in Windows

- See https://v2.tauri.app/start/prerequisites/
- cargo install create-tauri-app
- cargo install tauri-cli
- Download OpenSSL for Windows: https://slproweb.com/products/Win32OpenSSL.html
  - Choose Win64 MSI, Install
- Open Developer Console
  - set OPENSSL_DIR=C:\Program Files\OpenSSL-Win64
  - set OPENSSL_LIB_DIR=C:\Program Files\OpenSSL-Win64\lib\VC\x64\MD
  - cargo install trunk

### Test Tauri

- cargo create-tauri-app
  - Choose defaults and Leptos
- cd tauri-app
- cargo tauri dev
  - App must open and render correctly
