# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Smart Auto-Detection**: Intelligent detection and configuration of analysis tools
  - JaCoCo coverage analysis auto-enabled when reports are detected
  - ESLint integration auto-enabled when configuration files are detected  
  - Hadolint Docker linting auto-enabled when Dockerfile is detected
- Comprehensive CI/CD workflows for marketplace readiness
- Security scanning with CodeQL and Trivy
- Dependabot configuration for automated dependency updates
- Issue and PR templates for better community engagement
- Contributing guidelines and troubleshooting documentation
- Status badges in README for build status and quality metrics
- Enhanced test coverage with edge cases and integration tests
- Release automation workflow for marketplace publishing

### Changed
- **Default Behavior**: Analysis integrations now default to `true` with smart auto-detection
  - `enable-jacoco` default changed from `false` to `true`
  - `enable-eslint` default changed from `false` to `true` 
  - `enable-hadolint` default changed from `false` to `true`
- Enhanced action.yml metadata for better marketplace presentation
- Improved README with professional badges and structure
- Updated test workflow with comprehensive cross-platform testing
- Updated documentation to reflect smart detection capabilities

### Security
- Added security scanning workflows
- Implemented secrets scanning with TruffleHog
- Added dependency review for pull requests

## [1.0.0] - 2024-01-XX (Planned Initial Release)

### Added
- Cross-platform SonarScanner CLI installation (Windows, Linux, macOS)
- Automatic platform detection and script routing
- Configurable SonarScanner CLI version support
- Built-in caching with `actions/cache@v4` integration
- Installation verification and Java dependency checking
- Colored output and comprehensive error handling
- Complete documentation with usage examples
- Basic test workflow for cross-platform validation

### Features
- **Platform Support**: Automatic detection of Windows (PowerShell), Linux/macOS (Bash)
- **Version Management**: Configurable SonarScanner CLI version (default: 7.2.0.5079)
- **Performance**: Intelligent caching to avoid repeated downloads
- **Reliability**: Installation verification and dependency checking
- **Developer Experience**: Colored output and clear error messages

### Supported Versions
- SonarScanner CLI 7.2.0.5079 (default)
- SonarScanner CLI 6.2.0.4584
- SonarScanner CLI 5.0.1.3006
- Any available version from SonarSource binaries

### Requirements
- Java 17 or higher (most GitHub runners have this pre-installed)
- Internet access to download SonarScanner CLI binaries
- Approximately 50MB disk space for installation

---

## Version History

### Pre-release Development
- Initial project structure and planning
- Cross-platform script development
- Action metadata definition
- Documentation creation