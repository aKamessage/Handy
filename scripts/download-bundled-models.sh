#!/bin/bash
# Script to download bundled models for Handy
# This script downloads the Whisper Large model to be bundled with the application

set -e

MODELS_DIR="src-tauri/resources/models"
LARGE_MODEL_URL="https://blob.handy.computer/ggml-large-v3-q5_0.bin"
LARGE_MODEL_FILE="ggml-large-v3-q5_0.bin"

echo "Downloading bundled models for Handy..."
echo "========================================="

# Create models directory if it doesn't exist
mkdir -p "$MODELS_DIR"

# Download Whisper Large model if not already present
if [ -f "$MODELS_DIR/$LARGE_MODEL_FILE" ]; then
    echo "✓ Whisper Large model already exists"
else
    echo "Downloading Whisper Large model (~1.1 GB)..."
    curl -L -o "$MODELS_DIR/$LARGE_MODEL_FILE" "$LARGE_MODEL_URL" --progress-bar
    echo "✓ Whisper Large model downloaded successfully"
fi

echo ""
echo "========================================="
echo "All bundled models are ready!"
echo "The following models will be included in the application:"
echo "  - Whisper Large (ggml-large-v3-q5_0.bin)"
echo ""
echo "Note: These models will be copied to the user's data directory on first run."
