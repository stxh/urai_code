# AI Service Configuration Selector

Lightweight cross-platform command-line tools for managing multiple AI service configurations with simple `.conf` files.

## Overview

Claude Code and Qwen Code (a fork based on Gemini Code with support for Qwen3 Code) support custom AI models and third‑party providers. This project includes two scripts to make it easy to switch between third‑party models, including GLM‑4.5, Kimi K2, DeepSeek V3.1, and Qwen3‑Code.

This project provides two main utilities:

- **`ccs`** - For Anthropic claude code
- **`qw`** - For Alibaba qwen code use OpenAI-compatible endpoints

Each tool allows you to manage multiple API configurations through simple configuration files, making it easy to switch between different AI service providers and models.

## Features

- **Cross-platform support**: macOS/Linux (bash) and Windows CMD
- **Simple configuration**: Plain text `.conf` files with key=value pairs
- **Secure**: API keys are masked when displayed
- **Environment variable integration**: Sets standard environment variables for AI CLI tools
- **Automatic config directory creation**: Creates `~/.aiconf/` directory if it doesn't exist

## Installation

### macOS/Linux

1. Download or clone this repository
2. Place the scripts in a directory on your PATH:
   ```bash
   # Example: ~/bin directory
   cp ccs qw ~/bin/

   # Make them executable
   chmod +x ~/bin/ccs ~/bin/qw
   ```

### Windows

1. Download or clone this repository
2. Place the scripts in a directory on your PATH:
   - `ccs.cmd` and `qw.cmd` for Command Prompt

   Example for Command Prompt:
   ```cmd
   copy ccs.cmd %USERPROFILE%\bin\
   copy qw.cmd %USERPROFILE%\bin\
   ```

## Configuration

### Configuration Directory

Create configuration files in:
- **macOS/Linux**: `~/.aiconf/<name>.conf`
- **Windows**: `%USERPROFILE%\.aiconf\<name>.conf`
- Optional override: set `AICONF_DIR` to point to a custom directory

### Configuration File Format

Each `.conf` file contains simple key=value pairs. Lines starting with `#` are comments.

```ini
api_key=sk-your-api-key-here
claude_url=https://api.yourai.com/anthropic  # Used by ccs
openai_url=https://api.yourai.com/v1         # Used by qw
model=claude-3-sonnet-20240229
```

**Important**: Each `.conf` file contains both `claude_url` and `openai_url` fields:
- **`ccs`** uses `claude_url` for Claude/Anthropic-compatible endpoints
- **`qw`** uses `openai_url` for OpenAI-compatible endpoints

### Example Configuration

See the `.conf.example` files in this directory for complete examples:

```bash
# Copy an example configuration
cp k2.conf.example ~/.aiconf/k2.conf
# Edit with your actual API keys and settings
```

## Usage

### Basic Usage

```bash
# macOS/Linux
ccs <config_name> [options]
qw <config_name> [options]

# Windows CMD
ccs.cmd <config_name> [options]
qw.cmd <config_name> [options]
```

Additional commands:

```
ccs --config <config_name> [options]
ccs --list
```

### Examples

```bash
# Use k2 configuration with Claude
ccs k2 --version

# Use k2 configuration with Qwen
qw k2 -v

# Show help
ccs --help
qw --help
```

### Environment Variables

The scripts set standard environment variables that are recognized by most AI CLI tools:

#### For `ccs`:
- `ANTHROPIC_API_KEY` - API key
- `ANTHROPIC_AUTH_TOKEN` - API key (compat)
- `ANTHROPIC_BASE_URL` - Base URL
- `ANTHROPIC_MODEL` - Model name

#### For `qw`:
- `OPENAI_API_KEY` - API key
- `OPENAI_BASE_URL` - Base URL
- `OPENAI_MODEL` - Model name

## Prerequisites

These scripts are wrappers that require the underlying AI CLI tools to be installed:

- For `ccs`: [Claude CLI](https://github.com/anthropics/claude) or compatible tool
- For `qw`: [Qwen CLI](https://github.com/QwenLM/Qwen) or compatible OpenAI CLI tool

Ensure these tools are installed and available in your PATH.

## Troubleshooting

### Common Issues

**Error: claude/qwen not found in PATH**
- Ensure the underlying CLI tool is installed
- Verify the tool is in your PATH: `which claude` or `where claude`

**Config file not found**
- Confirm the file exists in the correct directory
- Check that the filename matches `<config_name>.conf`
- Verify the config directory exists: `ls ~/.aiconf/`

**Model mismatch**
- The "model" field is generic; ensure it matches a model supported by your target provider
- Check your provider's documentation for supported models

### Debug Mode

You can add `set -x` to the bash scripts or enable echo in CMD scripts to see what's happening:

```bash
# Edit the bash script and add at the top:
set -x
```

## File Structure

```
.
├── ccs                 # macOS/Linux bash script for Claude
├── ccs.cmd            # Windows CMD script for Claude
├── qw                 # macOS/Linux bash script for Qwen
├── qw.cmd             # Windows CMD script for Qwen
├── g.cmd              # Additional utility script
├── *.conf.example     # Example configuration files
└── README.md          # This file
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes
4. Test on all platforms (macOS/Linux, Windows CMD)
5. Submit a pull request

### Testing

Please test your changes on:
- macOS/Linux with bash
- Windows with Command Prompt

## License

This project is open source and available under the [MIT License](LICENSE).

## Security

- API keys are stored in plain text files - ensure proper file permissions
- Configuration files should be kept in user-specific directories
- API keys are masked when displayed (only first 8 characters shown)
- Never commit actual API keys to version control

Secrets are never printed in full. The tools only display masked prefixes.

## Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Search existing issues
3. Create a new issue with details about your environment and the problem

---

**Note**: This is a configuration wrapper tool. You still need to install the actual AI CLI tools (Claude, Qwen, etc.) separately.

## Changelog

See `CHANGELOG.md` for detailed release notes.
