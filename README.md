# Go Tools Installer

A simple script to install and configure Go along with popular security and reconnaissance tools.

## Features

- Installs Go (if not already installed)
- Configures Go environment variables in your `.zshrc`
- Installs selected Go tools from `tools.txt`
- Command-line flag based options for flexible installation

## Prerequisites

- Linux-based operating system
- `wget` for downloading Go
- `sudo` privileges for installing Go
- zsh shell

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/zer0coolhax/web-go-tools.git
   cd web-go-tools
   ```

2. Make the installer executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installer with desired options:
   ```bash
   ./install.sh [OPTIONS]
   ```

## Usage

The installer provides the following command-line options:

```
Options:
  -a, --all           Install everything (Go + Environment + Tools)
  -g, --go            Install Go only
  -e, --env           Setup Go environment only
  -t, --tools         Install Go tools only
  -h, --help          Display help message
```

### Examples

```bash
# Install everything
./install.sh --all

# Install tools only
./install.sh --tools

# Install Go and setup environment
./install.sh -g -e

# Show help
./install.sh --help
```

## Included Tools

The following tools are included in the installation:

- [assetfinder](https://github.com/tomnomnom/assetfinder) - Find domains and subdomains
- [httprobe](https://github.com/tomnomnom/httprobe) - Take a list of domains and probe for working HTTP and HTTPS servers
- [gowitness](https://github.com/sensepost/gowitness) - A web screenshot utility using Chrome Headless

## Important Note About Package Managers

While some of these tools are available through package managers (like apt), this installer provides the following advantages:

1. **Latest Versions**: The tools are installed directly from their source repositories, ensuring you get the most recent features and bug fixes.
2. **Manual Updates**: You can update the tools manually by running the installer again or using `go install` directly.
3. **Consistent Installation**: All tools are installed in your Go workspace, making them easier to manage and update.

To update the tools manually, you can run:
```bash
go install github.com/tomnomnom/assetfinder@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/sensepost/gowitness@latest
```

## Troubleshooting

If you encounter any issues:

1. Ensure you have the required permissions
2. Check if Go is properly installed: `go version`
3. Verify your Go environment: `echo $GOPATH`
4. Make sure your `.zshrc` is properly sourced: `source ~/.zshrc`

## License

MIT License 
