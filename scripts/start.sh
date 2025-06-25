#!/usr/bin/env bash
set -euo pipefail

# --- MACHINE-SPECIFIC CONFIGURATION ---
PYTHON_VERSION="3.12"
PYTHON_EXEC="/opt/homebrew/bin/python3"
PYTHON_LIB_PATH="/opt/homebrew/opt/python@${PYTHON_VERSION}/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib"

CONFIG_DEST="${PWD}/moshi-stt.toml"

# --- RUNTIME ENVIRONMENT SETUP ---
# Set environment variables for macOS runtime
export PYTHON_SYS_EXECUTABLE="${PYTHON_EXEC}"
export DYLD_LIBRARY_PATH="${PYTHON_LIB_PATH}"
export DYLD_FALLBACK_LIBRARY_PATH="${PYTHON_LIB_PATH}:/opt/homebrew/lib:/usr/lib"
export LIBRARY_PATH="/opt/homebrew/lib:${LIBRARY_PATH:-}"

# --- START MOSHI SERVER ---
echo "[INFO] Starting Moshi STT server on port 8080"
~/.cargo/bin/moshi-server worker --config "${CONFIG_DEST}" --port 8080