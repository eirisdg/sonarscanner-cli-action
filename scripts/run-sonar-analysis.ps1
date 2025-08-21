# PowerShell script to run SonarQube Analysis on Windows
param(
    [string]$Version = $env:SONAR_SCANNER_VERSION
)

# Error handling
$ErrorActionPreference = "Stop"

# Functions for colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Default values
if (-not $Version) {
    $Version = "7.2.0.5079"
}

$SonarScannerHome = "$env:USERPROFILE\.sonar-scanner"
$ScannerZipUrl = "https://github.com/SonarSource/sonar-scanner-cli/releases/download/$Version/sonar-scanner-cli-$Version.zip"

# Detect system architecture (primarily for documentation/logging)
function Detect-SystemArchitecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    Write-Info "Windows Architecture: $arch"
    return $arch
}

Write-Info "Starting SonarQube Analysis..."
Write-Info "SonarScanner Version: $Version"

# Detect system architecture
$DetectedArch = Detect-SystemArchitecture

# Function to install SonarScanner CLI
function Install-SonarScanner {
    Write-Info "Installing SonarScanner CLI..."
    
    # Check if SonarScanner is already installed
    $ScannerExecutable = "$SonarScannerHome\bin\sonar-scanner.bat"
    if (Test-Path $ScannerExecutable) {
        try {
            $InstalledVersionOutput = & $ScannerExecutable --version 2>$null
            $InstalledVersion = ($InstalledVersionOutput | Select-String -Pattern '\d+\.\d+\.\d+\.\d+').Matches[0].Value
            
            if ($InstalledVersion -eq $Version) {
                Write-Success "SonarScanner CLI $Version is already installed"
                return
            } else {
                Write-Warning "Different version installed ($InstalledVersion), reinstalling..."
                Remove-Item -Path $SonarScannerHome -Recurse -Force -ErrorAction SilentlyContinue
            }
        } catch {
            Write-Warning "Cannot determine installed version, reinstalling..."
            Remove-Item -Path $SonarScannerHome -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Check dependencies
    Write-Info "Checking dependencies..."

    # Check Java
    try {
        $JavaVersion = & java -version 2>&1 | Select-String -Pattern 'version'
        Write-Info "Java version: $($JavaVersion.Line)"
    } catch {
        Write-Error "Java is not installed or not in PATH"
        Write-Error "SonarScanner CLI requires Java 17 or higher"
        exit 1
    }

    # Create installation directory
    Write-Info "Creating installation directory..."
    New-Item -Path $SonarScannerHome -ItemType Directory -Force | Out-Null

    # Download SonarScanner CLI
    Write-Info "Downloading SonarScanner CLI from $ScannerZipUrl..."
    $TempZip = "$env:TEMP\sonar-scanner-cli.zip"

    try {
        # Use System.Net.WebClient for better compatibility
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($ScannerZipUrl, $TempZip)
        $WebClient.Dispose()
    } catch {
        Write-Error "Failed to download SonarScanner CLI: $($_.Exception.Message)"
        exit 1
    }

    # Check if download was successful
    if (-not (Test-Path $TempZip) -or (Get-Item $TempZip).Length -eq 0) {
        Write-Error "Downloaded file is empty or doesn't exist"
        exit 1
    }

    Write-Success "Download completed"

    # Extract the archive
    Write-Info "Extracting SonarScanner CLI..."
    try {
        # Use .NET methods for extraction
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $ExtractPath = Split-Path $SonarScannerHome -Parent
        [System.IO.Compression.ZipFile]::ExtractToDirectory($TempZip, $ExtractPath)
    } catch {
        Write-Error "Failed to extract SonarScanner CLI: $($_.Exception.Message)"
        Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Move to the correct directory
    $ExtractedDir = "$ExtractPath\sonar-scanner-$Version"
    if (Test-Path $ExtractedDir) {
        if (Test-Path $SonarScannerHome) {
            Remove-Item -Path $SonarScannerHome -Recurse -Force
        }
        Move-Item -Path $ExtractedDir -Destination $SonarScannerHome
    } else {
        Write-Error "Extracted directory not found: $ExtractedDir"
        exit 1
    }

    # Cleanup
    Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue

    # Verify installation
    Write-Info "Verifying installation..."
    if (-not (Test-Path $ScannerExecutable)) {
        Write-Error "SonarScanner binary not found after installation: $ScannerExecutable"
        exit 1
    }

    # Test the scanner
    try {
        $VersionOutput = & $ScannerExecutable --version 2>$null
        $InstalledVersion = ($VersionOutput | Select-String -Pattern '\d+\.\d+\.\d+\.\d+').Matches[0].Value
        Write-Success "SonarScanner CLI $InstalledVersion installed successfully"
    } catch {
        Write-Error "SonarScanner installation verification failed: $($_.Exception.Message)"
        exit 1
    }
}

# Function to auto-detect JaCoCo coverage reports
function Detect-JaCoCo {
    $JaCoCoReports = @()
    
    # Common JaCoCo report locations
    $PossiblePaths = @(
        "target\site\jacoco\jacoco.xml",
        "build\reports\jacoco\test\jacocoTestReport.xml",
        "jacoco.xml",
        "coverage\jacoco.xml"
    )
    
    foreach ($Path in $PossiblePaths) {
        if (Test-Path $Path) {
            $JaCoCoReports += $Path
        }
    }
    
    return $JaCoCoReports -join ","
}

# Function to auto-detect ESLint configuration
function Detect-ESLint {
    # Check for ESLint configuration files
    $ConfigFiles = @(
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.json",
        ".eslintrc.yml",
        ".eslintrc.yaml",
        "eslint.config.js"
    )
    
    foreach ($Config in $ConfigFiles) {
        if (Test-Path $Config) {
            return $true
        }
    }
    
    # Check package.json for eslint dependency
    if ((Test-Path "package.json")) {
        $PackageContent = Get-Content "package.json" -Raw
        if ($PackageContent -match '"eslint"') {
            return $true
        }
    }
    
    return $false
}

# Function to auto-detect Hadolint/Docker files
function Detect-Hadolint {
    # Check for Dockerfile or Hadolint configuration
    $DockerFiles = @(
        "Dockerfile*",
        ".hadolint.yaml",
        ".hadolint.yml"
    )
    
    foreach ($Pattern in $DockerFiles) {
        if (Get-ChildItem -Path . -Name $Pattern -ErrorAction SilentlyContinue) {
            return $true
        }
    }
    
    return $false
}

# Function to build SonarScanner command
function Build-SonarCommand {
    $ScannerExecutable = "$SonarScannerHome\bin\sonar-scanner.bat"
    $cmd = @($ScannerExecutable)
    
    # Core parameters
    if ($env:SONAR_HOST_URL) { $cmd += "-Dsonar.host.url=$($env:SONAR_HOST_URL)" }
    if ($env:SONAR_TOKEN) { $cmd += "-Dsonar.login=$($env:SONAR_TOKEN)" }
    if ($env:SONAR_PROJECT_KEY) { $cmd += "-Dsonar.projectKey=$($env:SONAR_PROJECT_KEY)" }
    if ($env:SONAR_PROJECT_NAME) { $cmd += "-Dsonar.projectName=$($env:SONAR_PROJECT_NAME)" }
    if ($env:SONAR_PROJECT_VERSION) { $cmd += "-Dsonar.projectVersion=$($env:SONAR_PROJECT_VERSION)" }
    if ($env:SONAR_SOURCES) { $cmd += "-Dsonar.sources=$($env:SONAR_SOURCES)" }
    if ($env:SONAR_TESTS) { $cmd += "-Dsonar.tests=$($env:SONAR_TESTS)" }
    if ($env:SONAR_EXCLUSIONS) { $cmd += "-Dsonar.exclusions=$($env:SONAR_EXCLUSIONS)" }
    if ($env:SONAR_INCLUSIONS) { $cmd += "-Dsonar.inclusions=$($env:SONAR_INCLUSIONS)" }
    if ($env:SONAR_ENCODING) { $cmd += "-Dsonar.sourceEncoding=$($env:SONAR_ENCODING)" }
    
    # Organization for SonarCloud
    if ($env:SONAR_ORGANIZATION) { $cmd += "-Dsonar.organization=$($env:SONAR_ORGANIZATION)" }
    
    # Branch analysis
    if ($env:SONAR_BRANCH_NAME) {
        $cmd += "-Dsonar.branch.name=$($env:SONAR_BRANCH_NAME)"
    } elseif ($env:GITHUB_REF_NAME -and $env:GITHUB_REF_NAME -ne "main" -and $env:GITHUB_REF_NAME -ne "master") {
        $cmd += "-Dsonar.branch.name=$($env:GITHUB_REF_NAME)"
    }
    
    # Pull request analysis
    if ($env:SONAR_PULL_REQUEST_KEY) {
        $cmd += "-Dsonar.pullrequest.key=$($env:SONAR_PULL_REQUEST_KEY)"
        if ($env:SONAR_PULL_REQUEST_BRANCH) { $cmd += "-Dsonar.pullrequest.branch=$($env:SONAR_PULL_REQUEST_BRANCH)" }
        if ($env:SONAR_PULL_REQUEST_BASE) { $cmd += "-Dsonar.pullrequest.base=$($env:SONAR_PULL_REQUEST_BASE)" }
    } elseif ($env:GITHUB_PR_NUMBER) {
        $cmd += "-Dsonar.pullrequest.key=$($env:GITHUB_PR_NUMBER)"
        if ($env:GITHUB_HEAD_REF) { $cmd += "-Dsonar.pullrequest.branch=$($env:GITHUB_HEAD_REF)" }
        if ($env:GITHUB_BASE_REF) { $cmd += "-Dsonar.pullrequest.base=$($env:GITHUB_BASE_REF)" }
        if ($env:GITHUB_REPOSITORY) { $cmd += "-Dsonar.pullrequest.github.repository=$($env:GITHUB_REPOSITORY)" }
    }
    
    # Analysis controls
    if ($env:SONAR_VERBOSE -eq "true") {
        $cmd += "-X"
    }
    
    # Smart analysis integrations with auto-detection
    if ($env:ENABLE_JACOCO -ne "false") {
        $JaCoCoReports = Detect-JaCoCo
        if ($JaCoCoReports) {
            Write-Success "JaCoCo integration enabled - detected reports: $JaCoCoReports"
            $cmd += "-Dsonar.coverage.jacoco.xmlReportPaths=$JaCoCoReports"
        } else {
            Write-Info "JaCoCo integration enabled but no reports detected"
        }
    }
    
    if ($env:ENABLE_ESLINT -ne "false") {
        $ESLintDetected = Detect-ESLint
        if ($ESLintDetected) {
            Write-Success "ESLint integration enabled - configuration detected"
            $cmd += "-Dsonar.javascript.eslint.reportPaths=eslint-report.json"
        } else {
            Write-Info "ESLint integration enabled but no configuration detected"
        }
    }
    
    if ($env:ENABLE_HADOLINT -ne "false") {
        $HadolintDetected = Detect-Hadolint
        if ($HadolintDetected) {
            Write-Success "Hadolint integration enabled - Docker files detected"
            $cmd += "-Dsonar.docker.dockerfile.reportPaths=hadolint-report.json"
        } else {
            Write-Info "Hadolint integration enabled but no Docker files detected"
        }
    }
    
    # Add extra arguments
    if ($env:EXTRA_ARGS) {
        $extraArgsArray = $env:EXTRA_ARGS -split '\s+'
        $cmd += $extraArgsArray
    }
    
    return $cmd
}

# Main execution
function Main {
    # Install SonarScanner CLI
    Install-SonarScanner
    
    # Validate required parameters
    if (-not $env:SONAR_HOST_URL -or -not $env:SONAR_TOKEN -or -not $env:SONAR_PROJECT_KEY) {
        Write-Error "Missing required parameters: sonar-host-url, sonar-token, and sonar-project-key are required"
        exit 1
    }
    
    # Build and execute sonar-scanner command
    Write-Info "Building SonarScanner command..."
    $sonarCmd = Build-SonarCommand
    Write-Info "Command: $($sonarCmd -join ' ')"
    
    Write-Info "Starting SonarQube analysis..."
    try {
        & $sonarCmd[0] $sonarCmd[1..($sonarCmd.Length-1)]
        Write-Success "SonarQube analysis completed successfully"
        $analysisResult = "success"
    } catch {
        Write-Error "SonarQube analysis failed: $($_.Exception.Message)"
        $analysisResult = "failed"
        exit 1
    }
    
    # Set outputs
    $ScannerExecutable = "$SonarScannerHome\bin\sonar-scanner.bat"
    $VersionOutput = & $ScannerExecutable --version 2>$null
    $InstalledVersion = ($VersionOutput | Select-String -Pattern '\d+\.\d+\.\d+\.\d+').Matches[0].Value
    
    Add-Content -Path $env:GITHUB_OUTPUT -Value "version=$InstalledVersion"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "path=$SonarScannerHome"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "result=$analysisResult"
    Add-Content -Path $env:GITHUB_OUTPUT -Value "architecture=$DetectedArch"
    
    Write-Success "Analysis completed successfully"
}

# Run main function
Main