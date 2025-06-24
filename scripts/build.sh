#!/usr/bin/env bash
set -euo pipefail

# --- MACHINE-SPECIFIC CONFIGURATION ---
# Configure these variables according to your machine setup
PYTHON_VERSION="3.12"
PYTHON_EXEC="/opt/homebrew/bin/python3"
PYTHON_LIB_PATH="/opt/homebrew/opt/python@${PYTHON_VERSION}/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib"

CONFIG_DEST="${PWD}/moshi-stt.toml"

# --- SYSTEM DEPENDENCIES (macOS/Homebrew) ---
# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "Please install Homebrew first!"
  exit 1
fi
# Install required system packages
brew install rust ffmpeg cmake python@${PYTHON_VERSION}

# --- BUILD ENVIRONMENT SETUP ---
# Set compiler and Python environment variables for macOS compilation
export CC=clang
export CXX=clang++
export PYTHON_SYS_EXECUTABLE="${PYTHON_EXEC}"
export DYLD_LIBRARY_PATH="${PYTHON_LIB_PATH}"
export DYLD_FALLBACK_LIBRARY_PATH="${PYTHON_LIB_PATH}:/opt/homebrew/lib:/usr/lib"
export LIBRARY_PATH="/opt/homebrew/lib:${LIBRARY_PATH:-}"
export C_INCLUDE_PATH="/opt/homebrew/include:${C_INCLUDE_PATH:-}"
export CPATH="/opt/homebrew/include:${CPATH:-}"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export CMAKE_POLICY_VERSION_MINIMUM=3.5

# --- MOSHI SERVER COMPILATION ---
# Compile and install moshi-server with Metal acceleration support
cargo install --force --locked --features metal moshi-server

# --- STT CONFIGURATION FILE DOWNLOAD ---
# Download the STT configuration file if it doesn't already exist
if [ ! -f "${CONFIG_DEST}" ]; then
  curl -L "https://raw.githubusercontent.com/kyutai-labs/delayed-streams-modeling/main/configs/config-stt-en_fr-hf.toml" -o "${CONFIG_DEST}"
fi

echo "[INFO] Starting Moshi STT server on port 8080"
~/.cargo/bin/moshi-server worker --config "${CONFIG_DEST}" --port 8080
