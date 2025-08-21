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

# Detect system architecture for macOS optimization
detect_system_architecture() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local arch=$(uname -m)
        case $arch in
            "arm64")
                print_info "Detected macOS Apple Silicon (ARM64)"
                export DETECTED_ARCH="apple-silicon"
                ;;
            "x86_64")
                print_info "Detected macOS Intel (x86_64)" 
                export DETECTED_ARCH="intel"
                ;;
            *)
                print_warning "Unknown macOS architecture: $arch"
                export DETECTED_ARCH="unknown"
                ;;
        esac
        
        # Additional macOS system information
        print_info "macOS Version: $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
        print_info "Hardware Model: $(sysctl -n hw.model 2>/dev/null || echo 'Unknown')"
    else
        export DETECTED_ARCH="not-macos"
    fi
}

print_info "Starting SonarQube Analysis..."
print_info "SonarScanner Version: $SONAR_SCANNER_VERSION"

# Detect system architecture
detect_system_architecture

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
    
    # macOS-specific Java architecture verification
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_info "Verifying Java architecture compatibility on macOS..."
        java_arch_info=$(java -XshowSettings:properties -version 2>&1 | grep -E "(os\.arch|sun\.arch)" || echo "")
        if [[ -n "$java_arch_info" ]]; then
            print_info "Java architecture details: $java_arch_info"
        fi
        
        # Additional verification for Apple Silicon compatibility
        if [[ "$DETECTED_ARCH" == "apple-silicon" ]]; then
            print_info "Verifying Java compatibility with Apple Silicon..."
            # Check if Java runs successfully with basic operations
            if java -version >/dev/null 2>&1; then
                print_success "Java is compatible with Apple Silicon"
            else
                print_warning "Java may have compatibility issues with Apple Silicon"
            fi
        fi
    fi

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

# Auto-detect JaCoCo coverage reports
detect_jacoco() {
    local jacoco_paths=""
    
    # Common JaCoCo report locations
    local possible_paths=(
        "target/site/jacoco/jacoco.xml"
        "build/reports/jacoco/test/jacocoTestReport.xml"
        "jacoco.xml"
        "coverage/jacoco.xml"
        "target/jacoco.exec"
        "build/jacoco/test.exec"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -f "$path" ]; then
            if [[ "$path" == *.xml ]]; then
                jacoco_paths="${jacoco_paths}${jacoco_paths:+,}$path"
            fi
        fi
    done
    
    echo "$jacoco_paths"
}

# Auto-detect ESLint configuration
detect_eslint() {
    local eslint_config_found=false
    
    # Check for ESLint configuration files
    local config_files=(
        ".eslintrc"
        ".eslintrc.js"
        ".eslintrc.json"
        ".eslintrc.yml"
        ".eslintrc.yaml"
        "eslint.config.js"
    )
    
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            eslint_config_found=true
            break
        fi
    done
    
    # Check package.json for eslint dependency
    if [ -f "package.json" ] && grep -q '"eslint"' package.json; then
        eslint_config_found=true
    fi
    
    echo "$eslint_config_found"
}

# Auto-detect Hadolint/Docker files
detect_hadolint() {
    local hadolint_config_found=false
    
    # Check for Dockerfile or Hadolint configuration
    local docker_files=(
        "Dockerfile"
        "Dockerfile.*"
        ".hadolint.yaml"
        ".hadolint.yml"
    )
    
    for pattern in "${docker_files[@]}"; do
        if ls $pattern 1> /dev/null 2>&1; then
            hadolint_config_found=true
            break
        fi
    done
    
    echo "$hadolint_config_found"
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
    
    # Smart analysis integrations with auto-detection
    if [ "${ENABLE_JACOCO:-true}" = "true" ]; then
        jacoco_reports=$(detect_jacoco)
        if [ -n "$jacoco_reports" ]; then
            print_success "JaCoCo integration enabled - detected reports: $jacoco_reports"
            cmd="$cmd -Dsonar.coverage.jacoco.xmlReportPaths=$jacoco_reports"
        else
            print_info "JaCoCo integration enabled but no reports detected"
        fi
    fi
    
    if [ "${ENABLE_ESLINT:-true}" = "true" ]; then
        eslint_detected=$(detect_eslint)
        if [ "$eslint_detected" = "true" ]; then
            print_success "ESLint integration enabled - configuration detected"
            cmd="$cmd -Dsonar.javascript.eslint.reportPaths=eslint-report.json"
        else
            print_info "ESLint integration enabled but no configuration detected"
        fi
    fi
    
    if [ "${ENABLE_HADOLINT:-true}" = "true" ]; then
        hadolint_detected=$(detect_hadolint)
        if [ "$hadolint_detected" = "true" ]; then
            print_success "Hadolint integration enabled - Docker files detected"
            cmd="$cmd -Dsonar.docker.dockerfile.reportPaths=hadolint-report.json"
        else
            print_info "Hadolint integration enabled but no Docker files detected"
        fi
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
    echo "architecture=$DETECTED_ARCH" >> $GITHUB_OUTPUT
    
    print_success "Analysis completed successfully"
}

# Run main function
main