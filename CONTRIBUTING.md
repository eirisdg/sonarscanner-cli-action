# Contributing to sonarscanner-cli-action

**CRITICAL PROJECT REQUIREMENT:** This repository MUST be structured and maintained to strict GitHub Marketplace standards for GitHub Actions publication. All contributions must ensure the action meets marketplace guidelines and publication requirements.

This repository provides a thin, cross-platform wrapper to run SonarScanner CLI natively in GitHub Actions. Contributions must keep scripts, documentation, examples, and tests in sync while maintaining marketplace compliance at all times.

Before you open a PR
- Read the `README.md` and `docs/` to understand the project's goals.
- Ensure your change preserves cross-platform behaviour (bash + PowerShell).
- **VERIFY MARKETPLACE COMPLIANCE** - All changes must maintain GitHub Marketplace publication standards.
- Check the SonarScanner CLI repo and releases for breaking changes when you add or change CLI flags:
  - https://github.com/SonarSource/sonar-scanner-cli
  - https://github.com/SonarSource/sonar-scanner-cli/releases

Required for every change
- Add or update unit tests for new logic. Prefer fast, table-driven tests.
- Update `README.md`, `docs/`, and `examples/` for any public-API or input changes.
- Add a `CHANGELOG.md` entry with category (Added/Changed/Fixed) and a short note.
- Run ShellCheck / PSScriptAnalyzer and fix critical warnings.
- **ENSURE MARKETPLACE COMPLIANCE** - Validate cross-platform compatibility and security standards.

Quick checklist (include in your PR description)
- [ ] Tests added/updated
- [ ] Docs/examples updated
- [ ] CHANGELOG.md entry added
- [ ] CI checks passing (lint & tests)
- [ ] **Marketplace compliance verified** (cross-platform, security, documentation)

How to contribute
1. Fork the repo and create a feature branch from `main`.
2. Implement code and tests.
3. Update documentation and `examples/`.
4. Run linters and tests locally.
5. Open a PR using the template and describe motivation, changes, and test steps.

Development notes
- Bash scripts: prefer `#!/usr/bin/env bash`, use `set -euo pipefail`, and run ShellCheck.
- PowerShell scripts: use `param()` blocks, `$ErrorActionPreference='Stop'`, and run PSScriptAnalyzer.
- Workflows: keep matrices reasonable and document required permissions/inputs.
- **Security:** Follow GitHub Actions security best practices for marketplace publication.
- **Cross-platform:** Test on Linux, macOS, and Windows for marketplace compliance.

Testing guidance
- Unit tests first (fast). Use bats/shunit2 for shell, Pester for PowerShell.
- Add a small integration or smoke test that verifies the action invokes the SonarScanner CLI with expected arguments (mocking the scanner binary is acceptable).
- Ensure CI runs on Linux, macOS, and Windows for critical paths.

Release guidance
- Follow semantic versioning.
- Include a `CHANGELOG.md` entry and clear release notes.

Thanks for helping keep this project reliable and well-documented.