# PowerShell script to install SonarScanner CLI on Windows
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
$ScannerBinaries = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
$ScannerZipUrl = "$ScannerBinaries/sonar-scanner-cli-$Version.zip"

Write-Info "Starting SonarScanner CLI installation..."
Write-Info "Version: $Version"
Write-Info "Target directory: $SonarScannerHome"

# Check if SonarScanner is already installed
$ScannerExecutable = "$SonarScannerHome\bin\sonar-scanner.bat"
if (Test-Path $ScannerExecutable) {
    try {
        $InstalledVersionOutput = & $ScannerExecutable --version 2>$null
        $InstalledVersion = ($InstalledVersionOutput | Select-String -Pattern '\d+\.\d+\.\d+\.\d+').Matches[0].Value
        
        if ($InstalledVersion -eq $Version) {
            Write-Success "SonarScanner CLI $Version is already installed"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "version=$Version"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "path=$SonarScannerHome"
            Add-Content -Path $env:GITHUB_PATH -Value "$SonarScannerHome\bin"
            exit 0
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

# Add to PATH
Add-Content -Path $env:GITHUB_PATH -Value "$SonarScannerHome\bin"

# Set outputs
Add-Content -Path $env:GITHUB_OUTPUT -Value "version=$InstalledVersion"
Add-Content -Path $env:GITHUB_OUTPUT -Value "path=$SonarScannerHome"

Write-Success "Installation completed successfully"