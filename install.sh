#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to display usage information
usage() {
    echo -e "${YELLOW}Go Tools Installer${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -a, --all           Install everything (Go + Environment + Tools)"
    echo "  -g, --go            Install Go only"
    echo "  -e, --env           Setup Go environment only"
    echo "  -t, --tools         Install Go tools only"
    echo "  -u, --update        Check and update tools if needed"
    echo "  -h, --help          Display this help message"
    echo
    echo "Examples:"
    echo "  $0 --all            # Install everything"
    echo "  $0 --tools          # Install tools only"
    echo "  $0 -g -e            # Install Go and setup environment"
    echo "  $0 --update         # Check and update tools if needed"
}

# Function to check for tool updates
check_updates() {
    echo -e "${YELLOW}Checking for tool updates...${NC}"
    
    # Ensure Go is installed
    if ! command_exists go; then
        echo -e "${RED}Go is not installed. Please install Go first.${NC}"
        exit 1
    }
    
    # Create a temporary file to store tools that need updates
    temp_file=$(mktemp)
    needs_update=false
    
    # Read tools from tools.txt and check for updates
    while IFS= read -r tool || [ -n "$tool" ]; do
        if [ -n "$tool" ]; then
            # Extract tool name without @latest
            tool_name=$(echo "$tool" | cut -d'@' -f1)
            echo -e "${YELLOW}Checking $tool_name...${NC}"
            
            # Get current version
            current_version=$(go list -m -versions "$tool_name" 2>/dev/null | tail -n1)
            
            # Get latest version
            latest_version=$(go list -m -versions "$tool_name" 2>/dev/null | head -n1)
            
            if [ -z "$current_version" ] || [ -z "$latest_version" ]; then
                echo -e "${RED}Could not determine version for $tool_name${NC}"
                continue
            fi
            
            if [ "$current_version" = "$latest_version" ]; then
                echo -e "${GREEN}$tool_name is up to date (version: $current_version)${NC}"
            else
                echo -e "${YELLOW}$tool_name has an update available:${NC}"
                echo -e "  Current: $current_version"
                echo -e "  Latest:  $latest_version"
                echo "$tool" >> "$temp_file"
                needs_update=true
            fi
        fi
    done < tools.txt
    
    # If any tools need updates, install them
    if [ "$needs_update" = true ]; then
        echo -e "\n${YELLOW}Updating tools that need updates...${NC}"
        while IFS= read -r tool || [ -n "$tool" ]; do
            if [ -n "$tool" ]; then
                echo -e "${YELLOW}Updating $tool...${NC}"
                go install "$tool"
            fi
        done < "$temp_file"
        echo -e "${GREEN}All updates completed!${NC}"
    else
        echo -e "\n${GREEN}All tools are up to date!${NC}"
    fi
    
    # Clean up temporary file
    rm -f "$temp_file"
}

# Function to install Go
install_go() {
    echo -e "${YELLOW}Installing Go...${NC}"
    if command_exists go; then
        echo -e "${GREEN}Go is already installed.${NC}"
        return
    fi

    # Download and install Go
    GO_VERSION="1.22.1"
    GO_ARCH="amd64"
    GO_OS="linux"
    
    wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    # Add Go to PATH if not already present
    if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" ~/.zshrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    fi

    # Source the updated .zshrc
    source ~/.zshrc
    echo -e "${GREEN}Go installed successfully!${NC}"
}

# Function to setup Go environment
setup_go_env() {
    echo -e "${YELLOW}Setting up Go environment...${NC}"
    
    # Create Go workspace if it doesn't exist
    mkdir -p ~/go/{bin,src,pkg}
    
    # Add Go configuration to .zshrc if not present
    if ! grep -q "export GOPATH=\$HOME/go" ~/.zshrc; then
        cat .zsh_append.sh >> ~/.zshrc
        echo -e "${GREEN}Go environment configured in .zshrc${NC}"
    else
        echo -e "${GREEN}Go environment already configured in .zshrc${NC}"
    fi
    
    # Source the updated .zshrc
    source ~/.zshrc
}

# Function to install Go tools
install_tools() {
    echo -e "${YELLOW}Installing Go tools...${NC}"
    
    # Ensure Go is installed
    if ! command_exists go; then
        echo -e "${RED}Go is not installed. Please install Go first.${NC}"
        exit 1
    }
    
    # Read tools from tools.txt and install them
    while IFS= read -r tool || [ -n "$tool" ]; do
        if [ -n "$tool" ]; then
            echo -e "${YELLOW}Installing $tool...${NC}"
            go install "$tool"
        fi
    done < tools.txt
    
    echo -e "${GREEN}All tools installed successfully!${NC}"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -a | --all )
            install_go
            setup_go_env
            install_tools
            exit 0
            ;;
        -g | --go )
            install_go
            ;;
        -e | --env )
            setup_go_env
            ;;
        -t | --tools )
            install_tools
            ;;
        -u | --update )
            check_updates
            ;;
        -h | --help )
            usage
            exit 0
            ;;
        * )
            echo -e "${RED}Invalid option: $1${NC}"
            usage
            exit 1
            ;;
    esac
    shift
done 