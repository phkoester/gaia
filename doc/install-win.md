# Windows

- Enable UTF-8 support
- Install Windows Terminal
- Install 64-bit Git: https://git-scm.com/downloads/win
  - Add git.exe to PATH
- Copy .ssh/ and .gitconfig to %USERPROFILE%
- Install Microsoft Visual Studio Community 2022: https://visualstudio.microsoft.com/downloads/
- Install Microsoft Visual Studio Code: https://code.visualstudio.com/
- Install Rust for Windows: https://www.rust-lang.org/tools/install
  - See install-rust.md

## Tauri

- https://v2.tauri.app/start/prerequisites/
- Download OpenSSL for Windows: https://slproweb.com/products/Win32OpenSSL.html
  - Win64 MSI
- cargo install create-tauri-app
  - cargo create-tauri-app
  - cargo tauri dev (test)
- Check what is required
  - cargo install trunk
  - cargo install tauri-cli
- Open Developer Command Prompt in Windows Terminal
  - set OPENSSL_DIR=C:\Program Files\OpenSSL-Win64
  - set OPENSSL_LIB_DIR=C:\Program Files\OpenSSL-Win64\lib\VC\x64\MD
  - cargo install trunk
