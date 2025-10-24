# Handy Model Download and Usage Guide

This document explains how Handy downloads and uses speech-to-text models, specifically Whisper and Parakeet models.

## Table of Contents

1. [Available Models](#available-models)
2. [How Model Downloading Works](#how-model-downloading-works)
3. [How Models Are Used](#how-models-are-used)
4. [Storage Locations](#storage-locations)
5. [Technical Details](#technical-details)
6. [Troubleshooting](#troubleshooting)

## Available Models

Handy offers several speech-to-text models with different trade-offs between speed and accuracy:

### Whisper Models

| Model | Name | Size | Description | Best For |
|-------|------|------|-------------|----------|
| `small` | Whisper Small | 487 MB | Fast and fairly accurate. | General use, quick responses |
| `medium` | Whisper Medium | 492 MB | Good accuracy, medium speed. | Balanced performance |
| `turbo` | Whisper Turbo | 1.6 GB | Balanced accuracy and speed. | Large vocabulary needs |
| `large` | Whisper Large | 1.1 GB | Good accuracy, but slow. | Maximum accuracy needed |

### Parakeet Models

| Model | Name | Size | Description | Best For |
|-------|------|------|-------------|----------|
| `parakeet-tdt-0.6b-v3` | Parakeet V3 | 850 MB | Fast and accurate. | CPU-only systems, automatic language detection |

**Note:** Parakeet V3 is the recommended first model for new users as it's optimized for CPU performance and includes automatic language detection.

## How Model Downloading Works

### Step-by-Step Download Process

1. **Model Selection**: When you first run Handy or click to download a new model in Settings, you select which model you want to use.

2. **Download Initiation**: The app downloads the model from a CDN (blob.handy.computer):
   ```
   https://blob.handy.computer/[model-filename]
   ```

3. **Resume Support**: Downloads can be paused and resumed. If a download is interrupted:
   - A `.partial` file is saved in the models directory
   - When you restart the download, it continues from where it left off using HTTP range requests

4. **Progress Tracking**: The UI displays:
   - Download percentage
   - Current download speed (MB/s)
   - Estimated time remaining
   - Total downloaded / Total size

5. **File Handling**:
   - **File-based models** (Whisper): Downloaded as `.bin` files directly
   - **Directory-based models** (Parakeet): Downloaded as `.tar.gz` archives, then automatically extracted

6. **Extraction** (for Parakeet models):
   - Archive is extracted to a temporary `.extracting` directory
   - Once complete, moved to final location
   - Original `.tar.gz` is deleted
   - UI shows "Extracting..." status during this process

7. **Auto-Selection**: After successful download, the model is automatically selected as the active model

### Frontend Components

The model download UI consists of several React components:

- **ModelSelector**: Main component managing model state and downloads
- **ModelDropdown**: Shows available models and download options
- **DownloadProgressDisplay**: Shows download progress bars
- **ModelCard**: Individual model display (in onboarding flow)

### Backend Architecture

The download process is managed by the Rust backend:

```rust
// Key components:
- ModelManager (src-tauri/src/managers/model.rs)
  - Manages available models
  - Handles download logic with resume support
  - Provides model paths to transcription engine

- Model Commands (src-tauri/src/commands/models.rs)
  - Tauri commands exposed to frontend
  - get_available_models, download_model, delete_model, etc.
```

### Download Events

The backend emits events that the frontend listens to:

- `model-download-progress`: Periodic updates during download
- `model-download-complete`: Download finished successfully
- `model-extraction-started`: Extraction beginning (for archives)
- `model-extraction-completed`: Extraction finished
- `model-extraction-failed`: Extraction error occurred

## How Models Are Used

### Model Loading Process

1. **Model Selection**: User selects a model in Settings or during onboarding

2. **Loading Trigger**: Model is loaded when:
   - User manually selects it in Settings
   - First transcription is requested
   - App starts with a previously selected model

3. **Engine Creation**: Based on model type, appropriate engine is created:
   ```rust
   // For Whisper models:
   WhisperEngine::new() -> load_model(path)
   
   // For Parakeet models:
   ParakeetEngine::new() -> load_model_with_params(path, int8_params)
   ```

4. **Loading States**: The UI shows different states:
   - `loading`: Model is being loaded into memory
   - `ready`: Model loaded and ready for transcription
   - `unloaded`: Model not currently in memory
   - `error`: Loading failed

### Transcription Flow

```
User presses shortcut
    ↓
Audio recording starts
    ↓
Voice Activity Detection (VAD) filters silence
    ↓
Audio sent to transcription engine
    ↓
Model processes audio → text
    ↓
Custom word correction applied (if configured)
    ↓
Text pasted to active application
```

### Engine-Specific Processing

**Whisper Engine:**
```rust
WhisperInferenceParams {
    language: "auto" or specific language code
    translate: true/false (translate to English)
}
```

**Parakeet Engine:**
```rust
ParakeetInferenceParams {
    timestamp_granularity: Segment level
    // Automatic language detection built-in
}
```

### Model Lifecycle

Models can be automatically unloaded to save memory:

- **Immediately**: Unload right after each transcription
- **After 5 minutes**: Unload after 5 minutes of inactivity
- **After 15 minutes**: Unload after 15 minutes of inactivity
- **After 30 minutes**: Unload after 30 minutes of inactivity
- **Never**: Keep model in memory always

This is configured in Settings → Model Unload Timeout.

## Storage Locations

### Model Files Location

Models are stored in the app's data directory:

**macOS:**
```
~/Library/Application Support/com.handy.app/models/
```

**Windows:**
```
%APPDATA%/com.handy.app/models/
```

**Linux:**
```
~/.local/share/com.handy.app/models/
```

### File Structure

```
models/
├── ggml-small.bin              # Whisper Small model
├── whisper-medium-q4_1.bin     # Whisper Medium model
├── ggml-large-v3-turbo.bin     # Whisper Turbo model
├── ggml-large-v3-q5_0.bin      # Whisper Large model
├── parakeet-tdt-0.6b-v3-int8/  # Parakeet V3 (directory)
│   ├── model files...
└── [filename].partial          # Incomplete downloads (if any)
```

### Bundled Models

The app may include a bundled Whisper Small model in:
```
resources/models/ggml-small.bin
```

On first run, bundled models are automatically copied to the user directory if not already present.

## Technical Details

### Model Formats

- **Whisper models**: GGML format (.bin files)
  - Quantized versions for efficient inference
  - GPU acceleration support (Metal on macOS, Vulkan on Windows/Linux)

- **Parakeet models**: ONNX format (directory structure)
  - INT8 quantized for CPU performance
  - ~5x real-time speed on mid-range hardware

### GPU Acceleration

**macOS:**
- Metal acceleration for Whisper models
- Automatic on M-series and Intel Macs

**Windows/Linux:**
- Vulkan acceleration for Whisper models
- OpenBLAS for CPU fallback on Linux

### Network Requirements

- **Bandwidth**: Recommended 10+ Mbps for smooth downloads
- **Servers**: Models hosted on blob.handy.computer
- **Protocol**: HTTPS with resume support (Range requests)

### Code References

**Model Manager Implementation:**
- File: `src-tauri/src/managers/model.rs`
- Key functions:
  - `download_model()`: Handles download with resume
  - `get_model_path()`: Returns path to loaded model
  - `delete_model()`: Removes downloaded model

**Transcription Manager Implementation:**
- File: `src-tauri/src/managers/transcription.rs`
- Key functions:
  - `load_model()`: Loads model into memory
  - `transcribe()`: Processes audio through model
  - `unload_model()`: Frees model from memory

**Frontend Model Selector:**
- File: `src/components/model-selector/ModelSelector.tsx`
- Manages UI state and user interactions

## Troubleshooting

### Download Issues

**Problem: Download fails or is very slow**
- Check internet connection
- Try pausing and resuming the download
- Check if firewall is blocking blob.handy.computer
- Download will automatically resume from where it stopped

**Problem: "Model not downloaded" error**
- Verify the model file exists in the models directory
- Try deleting and re-downloading the model
- Check disk space (models range from 500MB to 1.6GB)

**Problem: Download stuck at 100%**
- For Parakeet models, extraction may take time
- Check if `.extracting` directory exists (may indicate interrupted extraction)
- Restart Handy to retry extraction

### Model Loading Issues

**Problem: Model fails to load**
- Ensure model file is complete (no `.partial` file exists)
- Check system resources (RAM, GPU memory)
- Try a smaller model (e.g., Whisper Small)
- Check app logs for specific error messages

**Problem: "Model is not loaded for transcription" error**
- Wait for model to finish loading (check status indicator)
- Model may have auto-unloaded due to inactivity settings
- Try manually selecting the model in Settings

### Performance Issues

**Problem: Transcription is too slow**
- Try a smaller/faster model (Whisper Small or Parakeet V3)
- Check if GPU acceleration is working (macOS: Metal, Windows/Linux: Vulkan)
- Ensure other heavy applications aren't running
- Adjust Model Unload Timeout to keep model in memory

**Problem: High memory usage**
- Use a smaller model
- Set Model Unload Timeout to "Immediately" or a shorter duration
- Models consume 1-3GB RAM when loaded

### Extraction Issues

**Problem: "Failed to extract archive" error**
- Check disk space
- Ensure you have write permissions to the models directory
- Delete `.extracting` directory manually and retry
- Re-download the model if archive is corrupted

## Additional Resources

- [Build Instructions](BUILD.md): How to build Handy from source
- [Contributing Guide](CONTRIBUTING.md): How to contribute to Handy
- [Main README](README.md): Project overview and quick start
- [Handy Website](https://handy.computer): Demos and documentation
- [GitHub Issues](https://github.com/cjpais/Handy/issues): Report bugs or request features

## Model Download URLs

For reference, models are downloaded from:

```
https://blob.handy.computer/ggml-small.bin
https://blob.handy.computer/whisper-medium-q4_1.bin
https://blob.handy.computer/ggml-large-v3-turbo.bin
https://blob.handy.computer/ggml-large-v3-q5_0.bin
https://blob.handy.computer/parakeet-v3-int8.tar.gz
```

These are quantized, optimized versions specifically prepared for Handy's use case.
