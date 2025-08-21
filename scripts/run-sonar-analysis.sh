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

print_info "Starting SonarQube Analysis..."
print_info "SonarScanner Version: $SONAR_SCANNER_VERSION"

# Install SonarScanner CLI if not present
install_sonar_scanner() {
    print_info "Installing SonarScanner CLI..."
    
    # Check if SonarScanner is already installed
    if [ -f "$SONAR_SCANNER_HOME/bin/sonar-scanner" ]; then
        installed_version=$("$SONAR_SCANNER_HOME/bin/sonar-scanner" --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo "unknown")
        if [ "$installed_version" = "$SONAR_SCANNER_VERSION" ]; then
            print_success "SonarScanner CLI $SONAR_SCANNER_VERSION is already installed"
            return 0
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
}

# Build sonar-scanner command
build_sonar_command() {
    local cmd="$SONAR_SCANNER_HOME/bin/sonar-scanner"
    
    # Core parameters
    [ -n "${SONAR_HOST_URL:-}" ] && cmd="$cmd -Dsonar.host.url=${SONAR_HOST_URL}"
    [ -n "${SONAR_TOKEN:-}" ] && cmd="$cmd -Dsonar.login=${SONAR_TOKEN}"
    [ -n "${SONAR_PROJECT_KEY:-}" ] && cmd="$cmd -Dsonar.projectKey=${SONAR_PROJECT_KEY}"
    [ -n "${SONAR_PROJECT_NAME:-}" ] && cmd="$cmd -Dsonar.projectName=${SONAR_PROJECT_NAME}"
    [ -n "${SONAR_PROJECT_VERSION:-}" ] && cmd="$cmd -Dsonar.projectVersion=${SONAR_PROJECT_VERSION}"
    [ -n "${SONAR_SOURCES:-}" ] && cmd="$cmd -Dsonar.sources=${SONAR_SOURCES}"
    [ -n "${SONAR_TESTS:-}" ] && cmd="$cmd -Dsonar.tests=${SONAR_TESTS}"
    [ -n "${SONAR_EXCLUSIONS:-}" ] && cmd="$cmd -Dsonar.exclusions=${SONAR_EXCLUSIONS}"
    [ -n "${SONAR_INCLUSIONS:-}" ] && cmd="$cmd -Dsonar.inclusions=${SONAR_INCLUSIONS}"
    [ -n "${SONAR_ENCODING:-}" ] && cmd="$cmd -Dsonar.sourceEncoding=${SONAR_ENCODING}"
    
    # Organization for SonarCloud
    [ -n "${SONAR_ORGANIZATION:-}" ] && cmd="$cmd -Dsonar.organization=${SONAR_ORGANIZATION}"
    
    # Branch analysis
    if [ -n "${SONAR_BRANCH_NAME:-}" ]; then
        cmd="$cmd -Dsonar.branch.name=${SONAR_BRANCH_NAME}"
    elif [ -n "${GITHUB_REF_NAME:-}" ] && [ "${GITHUB_REF_NAME}" != "main" ] && [ "${GITHUB_REF_NAME}" != "master" ]; then
        cmd="$cmd -Dsonar.branch.name=${GITHUB_REF_NAME}"
    fi
    
    # Pull request analysis
    if [ -n "${SONAR_PULL_REQUEST_KEY:-}" ]; then
        cmd="$cmd -Dsonar.pullrequest.key=${SONAR_PULL_REQUEST_KEY}"
        [ -n "${SONAR_PULL_REQUEST_BRANCH:-}" ] && cmd="$cmd -Dsonar.pullrequest.branch=${SONAR_PULL_REQUEST_BRANCH}"
        [ -n "${SONAR_PULL_REQUEST_BASE:-}" ] && cmd="$cmd -Dsonar.pullrequest.base=${SONAR_PULL_REQUEST_BASE}"
    elif [ -n "${GITHUB_PR_NUMBER:-}" ]; then
        cmd="$cmd -Dsonar.pullrequest.key=${GITHUB_PR_NUMBER}"
        [ -n "${GITHUB_HEAD_REF:-}" ] && cmd="$cmd -Dsonar.pullrequest.branch=${GITHUB_HEAD_REF}"
        [ -n "${GITHUB_BASE_REF:-}" ] && cmd="$cmd -Dsonar.pullrequest.base=${GITHUB_BASE_REF}"
        [ -n "${GITHUB_REPOSITORY:-}" ] && cmd="$cmd -Dsonar.pullrequest.github.repository=${GITHUB_REPOSITORY}"
    fi
    
    # Analysis controls
    if [ "${SONAR_VERBOSE:-false}" = "true" ]; then
        cmd="$cmd -X"
    fi
    
    # Analysis integrations
    if [ "${ENABLE_JACOCO:-false}" = "true" ]; then
        print_info "JaCoCo integration enabled"
    fi
    
    if [ "${ENABLE_ESLINT:-false}" = "true" ]; then
        print_info "ESLint integration enabled"
    fi
    
    if [ "${ENABLE_HADOLINT:-false}" = "true" ]; then
        print_info "Hadolint integration enabled"
    fi
    
    # Add extra arguments
    if [ -n "${EXTRA_ARGS:-}" ]; then
        cmd="$cmd ${EXTRA_ARGS}"
    fi
    
    echo "$cmd"
}

# Main execution
main() {
    # Install SonarScanner CLI
    install_sonar_scanner
    
    # Validate required parameters
    if [ -z "${SONAR_HOST_URL:-}" ] || [ -z "${SONAR_TOKEN:-}" ] || [ -z "${SONAR_PROJECT_KEY:-}" ]; then
        print_error "Missing required parameters: sonar-host-url, sonar-token, and sonar-project-key are required"
        exit 1
    fi
    
    # Build and execute sonar-scanner command
    print_info "Building SonarScanner command..."
    sonar_cmd=$(build_sonar_command)
    print_info "Command: $sonar_cmd"
    
    print_info "Starting SonarQube analysis..."
    if eval "$sonar_cmd"; then
        print_success "SonarQube analysis completed successfully"
        analysis_result="success"
    else
        print_error "SonarQube analysis failed"
        analysis_result="failed"
        exit 1
    fi
    
    # Set outputs
    installed_version=$("$SONAR_SCANNER_HOME/bin/sonar-scanner" --version 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    echo "version=$installed_version" >> $GITHUB_OUTPUT
    echo "path=$SONAR_SCANNER_HOME" >> $GITHUB_OUTPUT
    echo "result=$analysis_result" >> $GITHUB_OUTPUT
    
    print_success "Analysis completed successfully"
}

# Run main function
main