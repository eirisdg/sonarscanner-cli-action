# Contributing to SonarScanner CLI Action

Thank you for your interest in contributing to the SonarScanner CLI Action! This document provides guidelines and information for contributors.

## Code of Conduct

This project adheres to a Code of Conduct that we expect all contributors to follow. Please be respectful and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** first to avoid duplicates
2. Use the **Bug Report** template when creating a new issue
3. Provide detailed information about your environment and steps to reproduce
4. Include relevant logs and error messages

### Suggesting Features

1. **Check existing issues** and discussions for similar requests
2. Use the **Feature Request** template
3. Clearly describe the use case and expected behavior
4. Consider backward compatibility and impact on existing users

### Submitting Changes

1. **Fork** the repository
2. **Create a feature branch** from `main`
3. **Make your changes** following the coding standards
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Submit a Pull Request** using the provided template

## Development Setup

### Prerequisites

- Bash (Linux/macOS) or PowerShell (Windows)
- Git
- Java 17+ for testing

### Local Testing

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/sonarscanner-cli-action.git
cd sonarscanner-cli-action

# Test the scripts directly
chmod +x scripts/install-sonar-scanner.sh
SONAR_SCANNER_VERSION=7.2.0.5079 ./scripts/install-sonar-scanner.sh

# On Windows
powershell -ExecutionPolicy Bypass -File scripts/install-sonar-scanner.ps1 -Version "7.2.0.5079"
```

### Testing Changes

1. **Unit Tests**: Test individual script components
2. **Integration Tests**: Test the complete action workflow
3. **Cross-Platform**: Test on Linux, Windows, and macOS
4. **Version Tests**: Test with multiple SonarScanner versions

## Coding Standards

### Shell Scripts (Bash)

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use meaningful variable names
- Add comments for complex logic
- Handle errors gracefully
- Provide colored output for better UX

### PowerShell Scripts

- Use proper error handling with `$ErrorActionPreference = "Stop"`
- Follow PowerShell naming conventions
- Add help comments for functions
- Use Write-Host with colors for output
- Handle edge cases gracefully

### Workflow Files

- Use semantic names for jobs and steps
- Include proper error handling
- Add descriptive comments
- Follow GitHub Actions best practices
- Test on multiple platforms when relevant

## Submitting Pull Requests

### PR Requirements

- [ ] Clear description of changes
- [ ] Tests added/updated for new functionality
- [ ] Documentation updated
- [ ] All CI checks passing
- [ ] No breaking changes (or clearly documented)

### PR Process

1. **Create PR** against the `main` branch
2. **Fill out the template** completely
3. **Wait for CI** to complete
4. **Address feedback** from reviewers
5. **Squash commits** before merge (if requested)

## Release Process

### Version Strategy

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backward-compatible functionality
- **PATCH** version for backward-compatible bug fixes

### Release Steps

1. Update version in relevant files
2. Create release notes
3. Tag the release: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. GitHub Actions will handle the release automation

## Testing Guidelines

### Required Tests

- **Functionality**: Core installation and verification
- **Cross-Platform**: Linux, Windows, macOS
- **Version Handling**: Multiple SonarScanner versions
- **Error Cases**: Invalid versions, network failures
- **Caching**: Cache hit/miss scenarios

### Test Structure

```yaml
# Example test case
- name: Test Feature X
  uses: ./
  with:
    parameter: 'value'
    
- name: Verify Feature X
  run: |
    # Verification commands
    echo "Testing specific behavior..."
```

## Documentation

### Required Documentation

- **README**: Usage examples and configuration
- **Action Metadata**: Proper inputs/outputs in action.yml
- **Code Comments**: Complex logic and important decisions
- **Changelog**: Notable changes for each version

### Documentation Style

- Use clear, concise language
- Provide practical examples
- Include troubleshooting information
- Keep examples up-to-date

## Community

### Getting Help

- **Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions

### Recognition

Contributors will be recognized in:

- Release notes for significant contributions
- README acknowledgments
- GitHub contributor graphs

## Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [SonarScanner CLI Documentation](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

Thank you for contributing to make this action better for everyone! 🎉