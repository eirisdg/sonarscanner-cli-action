# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it by emailing our security team or by creating a private security advisory on GitHub.

**Please do not report security vulnerabilities through public GitHub issues.**

### What to include in your report:

- A description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Any suggested fixes

### Response Timeline:

- We will acknowledge receipt of your vulnerability report within 48 hours
- We will provide a detailed response within 7 days
- We will notify you when the vulnerability is fixed

## Security Best Practices

When using this action:

1. **Store tokens securely** - Always use GitHub Secrets for sensitive data
2. **Use least privilege** - Only grant necessary permissions
3. **Keep updated** - Use the latest version of the action
4. **Review dependencies** - Monitor for security updates

## Security Features

This action implements several security best practices:

- **Input validation** - All user inputs are validated and sanitized
- **Secure credential handling** - Tokens are never logged or exposed
- **Cross-platform security** - Security measures work on Linux, macOS, and Windows
- **Container isolation** - When available, uses container-based execution
- **Dependency scanning** - Regular security scans of all dependencies

## Contact

For security-related questions, please contact the maintainers through GitHub or create a private security advisory.