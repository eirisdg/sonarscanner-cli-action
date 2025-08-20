# Troubleshooting Guide

This guide covers common issues and their solutions when using the SonarScanner CLI Action.

## Common Issues

### Java Not Found

**Error**: `java: command not found` or similar Java-related errors.

**Solution**: 
Ensure Java 17 or higher is installed. Add a Java setup step before the SonarScanner action:

```yaml
- name: Setup Java
  uses: actions/setup-java@v4
  with:
    distribution: 'temurin'
    java-version: '17'

- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
```

### Download Failures

**Error**: Failed to download SonarScanner CLI package.

**Possible Causes**:
1. Invalid version specified
2. Network connectivity issues
3. Binaries not available for the specified version

**Solutions**:
1. Verify the version exists at: https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/
2. Check network connectivity in your runner environment
3. Try a different, known-good version like `7.2.0.5079`

### Permission Denied (Linux/macOS)

**Error**: `Permission denied` when executing sonar-scanner.

**Solution**: 
The action automatically handles permissions, but if issues persist:

1. Ensure the runner has write access to the home directory
2. Check if custom runners have restrictive permissions
3. Try disabling cache temporarily:

```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    cache: 'false'
```

### Cache Issues

**Error**: Problems with cached installations or unexpected versions.

**Solutions**:
1. Disable cache temporarily to verify the issue:
   ```yaml
   with:
     cache: 'false'
   ```

2. Clear cache by changing the version temporarily:
   ```yaml
   with:
     sonar-scanner-version: '6.2.0.4584'  # Different version
     cache: 'true'
   ```

3. If using self-hosted runners, manually clear the cache directory:
   - Linux/macOS: `~/.sonar-scanner`
   - Windows: `%USERPROFILE%\.sonar-scanner`

### Path Issues

**Error**: `sonar-scanner: command not found` after installation.

**Verification**:
```yaml
- name: Debug PATH
  shell: bash
  run: |
    echo "PATH: $PATH"
    which sonar-scanner || echo "sonar-scanner not in PATH"
    ls -la ~/.sonar-scanner/bin/ || ls -la ~/AppData/Local/SonarScanner/bin/
```

**Solution**: 
This usually indicates an installation failure. Check the logs and try:
1. Different SonarScanner version
2. Disable cache
3. Verify Java installation

### Windows-Specific Issues

**Error**: PowerShell execution policy restrictions.

**Solution**: 
The action handles this automatically, but for custom runners:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Version Conflicts

**Error**: Wrong version installed or multiple versions interfering.

**Solution**:
```yaml
- name: Clean installation
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-scanner-version: 'desired-version'
    cache: 'false'  # Force fresh installation
```

## Debugging Steps

### Enable Verbose Logging

Add debugging to your workflow:

```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-scanner-version: '7.2.0.5079'
  env:
    ACTIONS_STEP_DEBUG: true

- name: Debug Installation
  shell: bash
  run: |
    echo "=== Environment ==="
    echo "OS: ${{ runner.os }}"
    echo "Java Version:"
    java -version
    echo ""
    echo "=== SonarScanner ==="
    sonar-scanner --version
    echo ""
    echo "=== Installation Path ==="
    which sonar-scanner
    ls -la $(dirname $(which sonar-scanner))
```

### Check Installation Details

```yaml
- name: Verify Installation Details
  shell: bash
  run: |
    echo "=== Installation Verification ==="
    if command -v sonar-scanner >/dev/null; then
      echo "✅ SonarScanner found in PATH"
      echo "Location: $(which sonar-scanner)"
      echo "Version: $(sonar-scanner --version)"
    else
      echo "❌ SonarScanner not found in PATH"
    fi
    
    echo ""
    echo "=== Directory Contents ==="
    # Linux/macOS
    if [ -d "$HOME/.sonar-scanner" ]; then
      echo "Linux/macOS installation directory:"
      ls -la "$HOME/.sonar-scanner/"
      ls -la "$HOME/.sonar-scanner/bin/" 2>/dev/null || echo "No bin directory"
    fi
    
    # Windows (when running in Git Bash)
    if [ -d "$HOME/AppData/Local/SonarScanner" ]; then
      echo "Windows installation directory:"
      ls -la "$HOME/AppData/Local/SonarScanner/"
      ls -la "$HOME/AppData/Local/SonarScanner/bin/" 2>/dev/null || echo "No bin directory"
    fi
```

## Getting Help

If you're still experiencing issues:

1. **Search existing issues**: Check if someone else has encountered the same problem
2. **Create a bug report**: Use the bug report template with:
   - Your exact workflow configuration
   - Complete error logs
   - Environment details (OS, Java version, etc.)
3. **Minimal reproduction**: Provide a minimal workflow that reproduces the issue

## Environment-Specific Notes

### Self-Hosted Runners

- Ensure runners have internet access to download SonarScanner
- Verify sufficient disk space (at least 100MB free)
- Check that Java 17+ is available
- Consider using persistent storage for cache directories

### Enterprise/Restricted Networks

- Ensure access to `binaries.sonarsource.com`
- Consider caching the SonarScanner binaries in your own infrastructure
- Verify proxy configurations if applicable

### Docker Runners

- Ensure the container has Java installed
- Mount appropriate volumes if using cache
- Consider the container's file system permissions

Remember: The action is designed to work on standard GitHub-hosted runners out of the box. Most issues occur in customized or restricted environments.