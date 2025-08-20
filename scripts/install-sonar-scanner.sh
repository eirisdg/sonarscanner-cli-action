#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default values
SONAR_SCANNER_VERSION="${SONAR_SCANNER_VERSION:-7.2.0.5079}"
SONAR_SCANNER_HOME="$HOME/.sonar-scanner"
SCANNER_BINARIES="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
SCANNER_ZIP_URL="${SCANNER_BINARIES}/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip"

print_info "Starting SonarScanner CLI installation..."
print_info "Version: $SONAR_SCANNER_VERSION"
print_info "Target directory: $SONAR_SCANNER_HOME"

# Check if SonarScanner is already installed
if [ -f "$SONAR_SCANNER_HOME/bin/sonar-scanner" ]; then
    installed_version=$("$SONAR_SCANNER_HOME/bin/sonar-scanner" --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
    if [ "$installed_version" = "$SONAR_SCANNER_VERSION" ]; then
        print_success "SonarScanner CLI $SONAR_SCANNER_VERSION is already installed"
        echo "version=$SONAR_SCANNER_VERSION" >> $GITHUB_OUTPUT
        echo "path=$SONAR_SCANNER_HOME" >> $GITHUB_OUTPUT
        echo "$SONAR_SCANNER_HOME/bin" >> $GITHUB_PATH
        exit 0
    else
        print_warning "Different version installed ($installed_version), reinstalling..."
        rm -rf "$SONAR_SCANNER_HOME"
    fi
fi

# Check dependencies
print_info "Checking dependencies..."

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java is not installed or not in PATH"
    print_error "SonarScanner CLI requires Java 17 or higher"
    exit 1
fi

java_version=$(java -version 2>&1 | grep -oP '(?<=version ")([^"]*)')
print_info "Java version: $java_version"

# Check if we have curl or wget
if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -O-"
else
    print_error "Neither curl nor wget is available"
    exit 1
fi

# Create installation directory
print_info "Creating installation directory..."
mkdir -p "$SONAR_SCANNER_HOME"

# Download SonarScanner CLI
print_info "Downloading SonarScanner CLI from $SCANNER_ZIP_URL..."
cd "$(dirname "$SONAR_SCANNER_HOME")"

if ! $DOWNLOAD_CMD "$SCANNER_ZIP_URL" > sonar-scanner-cli.zip; then
    print_error "Failed to download SonarScanner CLI"
    exit 1
fi

# Check if download was successful
if [ ! -f sonar-scanner-cli.zip ] || [ ! -s sonar-scanner-cli.zip ]; then
    print_error "Downloaded file is empty or doesn't exist"
    exit 1
fi

print_success "Download completed"

# Extract the archive
print_info "Extracting SonarScanner CLI..."
if ! unzip -q sonar-scanner-cli.zip; then
    print_error "Failed to extract SonarScanner CLI"
    rm -f sonar-scanner-cli.zip
    exit 1
fi

# Move to the correct directory
mv "sonar-scanner-${SONAR_SCANNER_VERSION}" "$(basename "$SONAR_SCANNER_HOME")"

# Cleanup
rm -f sonar-scanner-cli.zip

# Make the scanner executable
chmod +x "$SONAR_SCANNER_HOME/bin/sonar-scanner"

# Verify installation
print_info "Verifying installation..."
if [ ! -f "$SONAR_SCANNER_HOME/bin/sonar-scanner" ]; then
    print_error "SonarScanner binary not found after installation"
    exit 1
fi

# Test the scanner
if ! "$SONAR_SCANNER_HOME/bin/sonar-scanner" --version &> /dev/null; then
    print_error "SonarScanner installation verification failed"
    exit 1
fi

installed_version=$("$SONAR_SCANNER_HOME/bin/sonar-scanner" --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
print_success "SonarScanner CLI $installed_version installed successfully"

# Add to PATH
echo "$SONAR_SCANNER_HOME/bin" >> $GITHUB_PATH

# Set outputs
echo "version=$installed_version" >> $GITHUB_OUTPUT
echo "path=$SONAR_SCANNER_HOME" >> $GITHUB_OUTPUT

print_success "Installation completed successfully"