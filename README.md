# Moshi STT Server - Installation Script

An automated installation script for deploying Kyutai's Moshi STT server on macOS Apple Silicon. This project complements the official [Kyutai Delayed Streams Modeling](https://github.com/kyutai-labs/delayed-streams-modeling) repository by providing a streamlined setup process.

## Overview

This installation script provides an automated setup for running Kyutai's high-performance STT (Speech-to-Text) server using:
- **Kyutai's STT model** (`kyutai/stt-1b-en_fr-candle`) with 1B parameters supporting English and French
- **Rust-based server** with Metal acceleration optimized for Apple Silicon
- **Streaming inference** for real-time transcription with word-level timestamps
- **REST API** with `/api/asr-streaming` endpoint
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
./scripts/build.sh
```

The build script will:
1. Install missing system dependencies
2. Compile `moshi-server` with Metal support (binary installed to `~/.cargo/bin/moshi-server`)
3. Download the STT configuration for English/French (if not already present)
4. Start the server on port 8080

### 3. Verify Installation
```bash
# Check if server is running
curl -I http://localhost:8080/api/asr-streaming
```

You should see a `200 OK` response.

## Usage

### Basic Audio Transcription
```bash
# Transcribe an audio file
curl -X POST http://localhost:8080/api/asr-streaming \
  -H "Authorization: Bearer open_token" \
  -H "Content-Type: audio/wav" \
  --data-binary @your_audio_file.wav
```

### Supported Audio Formats
- **Formats**: WAV, MP3, FLAC, M4A (via FFmpeg)
- **Sample Rate**: 16kHz recommended (auto-resampled)
- **Channels**: Mono or Stereo
- **Duration**: Up to 10 minutes recommended for optimal performance
- **Real-time**: Streaming support for live audio

### API Endpoint
```
POST /api/asr-streaming
Authorization: Bearer open_token
Content-Type: audio/*
```

**Response**: JSON with transcribed text

## Configuration

The server uses `moshi-stt.toml` for configuration:

| Setting | Value | Description |
|---------|-------|-------------|
| **Port** | 8080 | Server port (customizable with `--port`) |
| **Languages** | EN, FR | Supported languages |
| **Model** | `kyutai/stt-1b-en_fr-candle` | Bilingual STT model |
| **Model Size** | 1B params | Streaming optimized |
| **Delay** | 0.5s | Real-time processing delay |
| **Batch Size** | 64 | Processing batch size |
| **Temperature** | 0.0 | Deterministic output |
| **Features** | Timestamps, VAD | Word-level timing + voice detection |

### Custom Port
```bash
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --port 8081
```

## Server Management

### Manual Start
```bash
# If already compiled
~/.cargo/bin/moshi-server worker --config moshi-stt.toml --port 8080
```

### Stop Server
```bash
# Ctrl+C in terminal, or:
pkill -f moshi-server
```

### View Logs
```bash
# Monitor server logs
tail -f ~/tmp/tts-logs/*.log

# Check resource usage
top -pid $(pgrep moshi-server)
```

### Restart
```bash
pkill -f moshi-server && ./scripts/build.sh
```

## Troubleshooting

### Common Issues

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
./scripts/build.sh
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
| **Processing Speed** | ~0.1x real-time |
| **GPU Acceleration** | Metal (Apple Silicon) |

**Example**: A 10-second audio file processes in ~1 second.

### Limitations

- **Concurrent Requests**: 1 request at a time (default)
- **Languages**: English and French only
- **Platform**: macOS Apple Silicon only
- **Audio Length**: 10 minutes maximum recommended

## Technical Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Audio Input   │───▶│   Moshi Server   │───▶│  Transcribed    │
│  (WAV/MP3/etc)  │    │   (Rust/Candle)  │    │     Text        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  Kyutai STT 1B   │
                       │ (EN/FR Support)  │
                       └──────────────────┘
```

### Technology Stack
- **Backend**: Rust with Candle ML framework
- **Model**: Kyutai STT 1B parameters transformer
- **Acceleration**: Metal Performance Shaders
- **Audio Processing**: FFmpeg
- **API**: HTTP REST with streaming capability

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