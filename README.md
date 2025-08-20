# SonarScanner CLI Action

[![CI](https://github.com/eirisdg/sonarscanner-cli-action/actions/workflows/ci.yml/badge.svg)](https://github.com/eirisdg/sonarscanner-cli-action/actions/workflows/ci.yml)
[![Security](https://github.com/eirisdg/sonarscanner-cli-action/actions/workflows/security.yml/badge.svg)](https://github.com/eirisdg/sonarscanner-cli-action/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/eirisdg/sonarscanner-cli-action.svg)](https://github.com/eirisdg/sonarscanner-cli-action/releases)
[![GitHub marketplace](https://img.shields.io/badge/marketplace-sonarscanner--cli--action-blue?logo=github)](https://github.com/marketplace/actions/sonarscanner-cli-action)

A cross-platform GitHub Action that installs the SonarScanner CLI for use with SonarQube and SonarCloud analysis.

## Quick Start

```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1

- name: Run SonarQube Analysis
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: sonar-scanner -Dsonar.projectKey=my-project -Dsonar.sources=.
```

## Why Use This Action?

- ✅ **Zero Configuration**: Works out of the box on all GitHub runners
- ✅ **Fast**: Intelligent caching reduces setup time to seconds
- ✅ **Reliable**: Comprehensive error handling and validation
- ✅ **Current**: Always supports the latest SonarScanner CLI versions
- ✅ **Secure**: Regular security scanning and dependency updates

## Features

- ✅ **Cross-platform support** - Works on Windows, Linux, and macOS runners
- ✅ **Configurable version** - Install any available SonarScanner CLI version
- ✅ **Caching support** - Optional caching to speed up subsequent runs
- ✅ **Automatic PATH setup** - SonarScanner CLI is automatically added to PATH
- ✅ **Verification** - Installation is verified before completion

## Usage

### Basic Usage

```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
```

### Advanced Usage

```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-scanner-version: '7.2.0.5079'
    cache: 'true'
```

### Complete Example

```yaml
name: SonarQube Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Shallow clones should be disabled for better analysis

    - name: Setup SonarScanner CLI
      uses: eirisdg/sonarscanner-cli-action@v1
      with:
        sonar-scanner-version: '7.2.0.5079'

    - name: Run SonarQube analysis
      env:
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
      run: |
        sonar-scanner \
          -Dsonar.projectKey=my-project \
          -Dsonar.sources=. \
          -Dsonar.host.url=$SONAR_HOST_URL \
          -Dsonar.login=$SONAR_TOKEN
```

### Multi-platform Example

```yaml
name: Cross-Platform SonarQube Analysis

on: [push, pull_request]

jobs:
  analysis:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        
    runs-on: ${{ matrix.os }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup SonarScanner CLI
      uses: eirisdg/sonarscanner-cli-action@v1

    - name: Run analysis
      env:
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      run: |
        sonar-scanner -Dsonar.projectKey=my-project -Dsonar.sources=.
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `sonar-scanner-version` | Version of SonarScanner CLI to install | No | `7.2.0.5079` |
| `cache` | Enable caching of SonarScanner CLI installation | No | `true` |

## Outputs

| Output | Description |
|--------|-------------|
| `sonar-scanner-version` | The version of SonarScanner CLI that was installed |
| `sonar-scanner-path` | Path to the SonarScanner CLI installation |

## Requirements

- **Java 17 or higher** - SonarScanner CLI requires Java to run (most GitHub runners have Java pre-installed)
- The action downloads approximately 50MB for the SonarScanner CLI package

## Supported Platforms

| Platform | Runner | Status |
|----------|--------|--------|
| Linux | `ubuntu-latest`, `ubuntu-20.04`, `ubuntu-22.04` | ✅ Supported |
| Windows | `windows-latest`, `windows-2019`, `windows-2022` | ✅ Supported |
| macOS | `macos-latest`, `macos-11`, `macos-12`, `macos-13` | ✅ Supported |

## Caching

The action supports caching to improve performance on subsequent runs. Caching is enabled by default but can be disabled:

```yaml
- name: Setup SonarScanner CLI (no cache)
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    cache: 'false'
```

The cache key includes the OS and SonarScanner version, ensuring proper cache invalidation when needed.

## Available Versions

You can find available SonarScanner CLI versions at:
https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/

Common versions:
- `7.2.0.5079` (latest)
- `6.2.0.4584`
- `5.0.1.3006`

## Troubleshooting

### Java not found
Ensure Java 17 or higher is installed. You can add a Java setup step before this action:

```yaml
- name: Setup Java
  uses: actions/setup-java@v3
  with:
    distribution: 'temurin'
    java-version: '17'

- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
```

### Permission denied on Linux/macOS
The action automatically handles file permissions, but if you encounter issues, ensure the runner has write access to the home directory.

### Download failures
If downloads fail, check:
1. Network connectivity to `binaries.sonarsource.com`
2. The specified version exists
3. GitHub runner has sufficient disk space

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) and submit pull requests to the main repository.

## Documentation

- [Advanced Usage Examples](docs/advanced-usage.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Changelog](CHANGELOG.md)

## Support

- 🐛 [Report a bug](https://github.com/eirisdg/sonarscanner-cli-action/issues/new?template=bug_report.md)
- 💡 [Request a feature](https://github.com/eirisdg/sonarscanner-cli-action/issues/new?template=feature_request.md)
- ❓ [Ask a question](https://github.com/eirisdg/sonarscanner-cli-action/issues/new?template=question.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Based on the official [SonarSource sonar-scanner-cli-docker](https://github.com/SonarSource/sonar-scanner-cli-docker) project
- Developed by Mario Adrián Domínguez González de Eiris
