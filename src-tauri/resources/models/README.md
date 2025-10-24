# Bundled Models

This directory contains models that are bundled with the Handy application.

## Required Files

### VAD Model (Always Required)
- **File:** `silero_vad_v4.onnx` (1.8 MB)
- **Purpose:** Voice Activity Detection
- **Download:** Already present in repository

### Whisper Large Model (Bundled)
- **File:** `ggml-large-v3-q5_0.bin` (1.1 GB)
- **Purpose:** Speech-to-text transcription
- **Download:** Run `../../scripts/download-bundled-models.sh` or:
  ```bash
  curl -o ggml-large-v3-q5_0.bin https://blob.handy.computer/ggml-large-v3-q5_0.bin
  ```

## Setup

Before building Handy, ensure you have downloaded the Whisper Large model:

```bash
# From the repository root
./scripts/download-bundled-models.sh
```

This model will be bundled with the application installer and automatically copied to the user's data directory on first run.

## Notes

- The Whisper Large model is **not** stored in Git due to its size (~1.1 GB)
- Developers must download it manually before building
- End users will receive it bundled with the application installer
- The model is copied to the user's data directory on first launch
