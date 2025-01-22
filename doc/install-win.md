# Install Windows Development

## System

- Enable UTF-8 support for Windows
- Make sure Windows Terminal is installed

## Git

- Install Git for Windows
  - <https://git-scm.com/downloads/win>
  - Choose latest 64-bit version
  - Add `git.exe` to `PATH`
- Copy `.ssh/` and `.gitconfig` to `%USERPROFILE%`

## C++

- Install Microsoft Visual Studio Community
  - <https://visualstudio.microsoft.com/downloads>
  - Choose Microsoft Visual C++ Build Tools
- Open "Developer Command Prompt" in Windows Terminal
  - Make sure `cl.exe` is found

## Rust

- Install Rust for Windows
  - <https://www.rust-lang.org/tools/install>
- See [Install Rust](install-rust.md) 

## Visual Studio Code

- Install Microsoft Visual Studio Code
  - <https://code.visualstudio.com>
- Copy `settings.json` to `%APPDATA%\Code\User`

### Visual Studio Code Extensions

- GitHub: GitHub Copilot
- GitKraken: GitLens --- Git supercharged
- LLVM: clangd
- LLVM: LLDB DAP
  - WSL
    - Executable-path: `/bin/lldb-dap-18`
- Microsoft: Makefile Tools
- Microsoft: Python
- Microsoft: WSL
- Tauri: Tauri
- The Rust Programming Language: rust-analyzer
