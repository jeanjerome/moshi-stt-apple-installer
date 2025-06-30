# Moshi STT Server - Installation Script

An automated installation script for deploying Kyutai's Moshi STT server on macOS Apple Silicon. This project complements the official [Kyutai Delayed Streams Modeling](https://github.com/kyutai-labs/delayed-streams-modeling) repository by providing a streamlined setup process.

## Overview

This installation script provides an automated setup for running Kyutai's high-performance STT (Speech-to-Text) server using:
- **Kyutai's STT model** (`kyutai/stt-1b-en_fr-candle`) with 1B parameters supporting English and French
- **Rust-based server** with Metal acceleration optimized for Apple Silicon
- **Streaming inference** for real-time transcription with word-level timestamps
- **WebSocket API** with `/api/asr-streaming` endpoint
- **Semantic Voice Activity Detection (VAD)** capabilities

> **Note**: This is a deployment script based on the official [Kyutai Labs Delayed Streams Modeling](https://github.com/kyutai-labs/delayed-streams-modeling) project. For the complete research project, model details, and alternative installation methods, please visit the original repository.

## Prerequisites

### System Requirements
- **macOS** with Apple Silicon (M series) - Metal acceleration support
- **Homebrew** package manager ([install here](https://brew.sh/))
- **Xcode Command Line Tools** (for `clang` compiler)
- **~2GB disk space** for model weights download

### Install Dependencies
```bash
# Install required system packages
brew install rust cmake python@3.12
```

**Dependencies breakdown:**
- **Rust**: Compiles the moshi-server binary with Metal acceleration
- **CMake**: Build system for native dependencies
- **Python 3.12**: Required for PyO3 bindings and tokenization components

## Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/jeanjerome/moshi-stt-apple-installer.git
```

### 2. Run the Server
```bash
cd moshi-stt-apple-silicon
./scripts/install.sh
```

The build script will:
1. Install missing system dependencies
2. Compile `moshi-server` with Metal support (binary installed to `~/.cargo/bin/moshi-server`)
3. Download the STT configuration for English/French (if not already present)
4. Start the server on port 8080

### 3. Verify Installation (optional)

First, install `uv` (Python package manager, independent of Moshi server):
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then test the Moshi server with the WebSocket client:
```bash
# Test Moshi server using WebSocket client
uv run test_client.py
```

Expected output:
```
Installed 4 packages in 7ms
received: {'type': 'Ready'}
received: {'type': 'Word', 'text': 'Bonjour,', 'start_time': 1.68}
received: {'type': 'Marker', 'id': 0}
Received marker, stopping stream.
exiting
Transcription: Bonjour,
```

## Usage

### Starting the Server

Use the provided startup script (recommended):
```bash
./scripts/start.sh
```

This script initializes the required environment variables for macOS:
- **Python runtime**: `PYTHON_SYS_EXECUTABLE`, `DYLD_LIBRARY_PATH`
- **Library paths**: Required for PyO3 bindings and native dependencies
- **Homebrew paths**: Ensures system libraries are found correctly

Or start manually (requires setting environment variables):
```bash
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --port 8080
```

### WebSocket Audio Transcription

The Moshi server uses WebSocket for real-time audio streaming transcription:

```
ws://localhost:8080/api/asr-streaming
Header: kyutai-api-key: public_token
Protocol: MessagePack binary format
```

### Audio Format Requirements
- **Format**: WAV, 16-bit PCM
- **Sample Rate**: 24kHz (resampled automatically)
- **Channels**: Mono
- **Duration**: Up to 10 minutes recommended for optimal performance

### Response Format

The server sends MessagePack-encoded responses with these message types:

```python
# Connection ready
{"type": "Ready"}

# Processing step (can be ignored)
{"type": "Step"}

# Word detected with timestamp
{"type": "Word", "text": "Bonjour,", "start_time": 1.68}

# Word end timestamp
{"type": "EndWord", "stop_time": 2.1}

# Stream end marker
{"type": "Marker", "id": 0}
```

### Client Example

Use the provided WebSocket client:
```bash
uv run test_client.py
```

Or implement your own using the same MessagePack protocol for sending audio chunks and receiving transcription events.

For additional client implementations (Python, MLX), see [Kyutai's streaming client examples](https://github.com/kyutai-labs/delayed-streams-modeling/tree/main/scripts).

## Configuration

### Command Line Options

```bash
~/.cargo/bin/moshi-server worker [OPTIONS] --config <CONFIG>
```

| Option | Default | Description |
|--------|---------|-------------|
| `--config <CONFIG>` | Required | Path to TOML configuration file |
| `--port <PORT>` | 8080 | Server port |
| `--addr <ADDR>` | 0.0.0.0 | Server address |
| `--log <LOG_LEVEL>` | info | Log level (error, warn, info, debug, trace) |
| `--cpu` | - | Force CPU mode (disable Metal acceleration) |
| `--silent` | - | Suppress output |

### Configuration File (`moshi-stt.toml`)

| Setting | Value | Description |
|---------|-------|-------------|
| **API Path** | `/api/asr-streaming` | WebSocket endpoint |
| **Model** | `kyutai/stt-1b-en_fr-candle` | Bilingual STT model |
| **Languages** | EN, FR | Supported languages |
| **Delay (tokens)** | 6 | ASR delay in tokens |
| **Batch Size** | 64 | Processing batch size |
| **Temperature** | 0.0 | Deterministic output |
| **Auth Token** | `public_token` | WebSocket authentication |

### Examples

```bash
# Custom port
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --port 8081

# Debug logging
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --log debug

# CPU-only mode
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --cpu
```

## Server Management

### Manual Start
```bash
# If already installed
./scripts/start.sh
```

### Stop Server
```bash
# Ctrl+C in terminal, or:
pkill -f moshi-server
```

### Check Resource
```bash
# Check resource usage
top -pid $(pgrep moshi-server)
```

### Restart
```bash
pkill -f moshi-server && ./scripts/start.sh
```

## Troubleshooting

### Common Issues

#### Normal WebSocket Closing Error
```
ERROR: WebSocket protocol error: Sending after closing is not allowed
```
This error is normal when the client closes the connection. The server continues processing briefly after the client disconnects.

#### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080

# Use different port
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --port 8081
```

#### Rust Compilation Error
```bash
# Clean and rebuild
cargo clean
rustup update
./scripts/install.sh
```

#### Python/PyTorch Issues
```bash
# Check Python version
/opt/homebrew/bin/python3 --version

# Reinstall if needed
brew reinstall python@3.12
```

#### Models Not Downloaded
The models download automatically on first run. If this fails:
- Check your internet connection
- Ensure sufficient disk space (~2GB for models)

### Performance

| Metric | Expected Value |
|--------|----------------|
| **RAM Usage** | 4-8 GB |
| **Processing Speed** | ~94ms per step |
| **GPU Acceleration** | Metal (Apple Silicon) |
| **Latency** | Real-time streaming with 6-token delay |

**Tested on M4 Max**: Short audio clips process in a few seconds with word-level timestamps.

### Limitations

- **Languages**: English and French only (per model tokenizer)
- **Installation Script**: This installer is macOS Apple Silicon specific
- **Model Size**: Requires ~2GB disk space and 4-8GB RAM
- **Audio Length**: Optimal performance up to 10 minutes (model training limitations) 

### Technology Stack

- **Backend**: Rust with Candle ML framework
- **Model**: Kyutai STT 1B parameters transformer
- **Acceleration**: Metal Performance Shaders
- **Protocol**: WebSocket with MessagePack binary format
- **Audio Processing**: Real-time streaming with PCM float32

## Advanced Usage

### Custom Model Configuration
Edit `moshi-stt.toml` to modify:
- Model parameters
- Processing delays
- Batch sizes
- Audio tokenizer settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This installation script is provided as-is. The underlying components have different licenses:

- **Kyutai STT Model Weights**: [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Moshi Rust Server**: Apache 2.0
- **Python Components**: MIT License

For complete license information, please refer to the [original Kyutai repository](https://github.com/kyutai-labs/delayed-streams-modeling).

## Related Projects

- **[Kyutai Delayed Streams Modeling](https://github.com/kyutai-labs/delayed-streams-modeling)** - Original research project and models
- **[Kyutai Labs](https://github.com/kyutai-labs)** - AI research laboratory
- **[Candle Framework](https://github.com/huggingface/candle)** - Rust ML framework
- **[Moshi Project](https://github.com/kyutai-labs/moshi)** - Complete multimodal AI project

## Alternative Installation Methods

If this script doesn't meet your needs, consider these alternatives from the original repo:

### PyTorch (Python)
```bash
pip install moshi
python -m moshi.run_inference --hf-repo kyutai/stt-1b-en_fr audio.wav
```

### MLX (Apple Silicon - Alternative)
```bash
pip install moshi-mlx
python -m moshi_mlx.run_inference --hf-repo kyutai/stt-1b-en_fr-mlx audio.wav
```

### Manual Rust Installation
```bash
cargo install --features metal moshi-server
```

---

**Need more help?** Open an issue or check the troubleshooting section above.