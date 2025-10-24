# Build Instructions

This guide covers how to set up the development environment and build Handy from source across different platforms.

## Prerequisites

### All Platforms
- [Rust](https://rustup.rs/) (latest stable)
- [Bun](https://bun.sh/) package manager
- [Tauri Prerequisites](https://tauri.app/start/prerequisites/)

### Platform-Specific Requirements

#### macOS
- Xcode Command Line Tools
- Install with: `xcode-select --install`

#### Windows  
- Microsoft C++ Build Tools
- Visual Studio 2019/2022 with C++ development tools
- Or Visual Studio Build Tools 2019/2022

#### Linux
- Build essentials
- ALSA development libraries
- Install with:
  ```bash
  # Ubuntu/Debian
  sudo apt update
  sudo apt install build-essential libasound2-dev pkg-config libssl-dev libvulkan-dev vulkan-tools glslc libgtk-3-dev libwebkit2gtk-4.1-dev libayatana-appindicator3-dev librsvg2-dev patchelf

  # Fedora/RHEL
  sudo dnf groupinstall "Development Tools"
  sudo dnf install alsa-lib-devel pkgconf openssl-devel vulkan-devel \
    gtk3-devel webkit2gtk4.1-devel libappindicator-gtk3-devel librsvg2-devel

  # Arch Linux
  sudo pacman -S base-devel alsa-lib pkgconf openssl vulkan-devel \
    gtk3 webkit2gtk-4.1 libappindicator-gtk3 librsvg
  ```

## Setup Instructions

### 1. Clone the Repository
```bash
git clone git@github.com:cjpais/Handy.git
cd Handy
```

### 2. Install Dependencies
```bash
bun install
```

### 3. Download Required Models

Handy requires models to function. There are two types of models:

#### Required: VAD Model (for voice detection)
```bash
mkdir -p src-tauri/resources/models
curl -o src-tauri/resources/models/silero_vad_v4.onnx https://blob.handy.computer/silero_vad_v4.onnx
```

#### Bundled: Whisper Large Model (included with app)
The Whisper Large model is bundled with the application for offline use. To download it for building:

```bash
# Using the provided script (recommended)
./scripts/download-bundled-models.sh

# Or manually
curl -o src-tauri/resources/models/ggml-large-v3-q5_0.bin https://blob.handy.computer/ggml-large-v3-q5_0.bin
```

**Note:** The Large model is ~1.1 GB and will be included in the application installer. On first run, it will be automatically copied to the user's data directory.
