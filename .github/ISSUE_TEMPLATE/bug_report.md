---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: ['bug', 'triage']
assignees: ['eirisdg']
---

## Bug Description
A clear and concise description of what the bug is.

## Environment
- **Operating System**: [e.g., ubuntu-latest, windows-latest, macos-latest]
- **SonarScanner Version**: [e.g., 7.2.0.5079]
- **Action Version**: [e.g., v1.0.0]
- **Java Version**: [e.g., 17]

## Steps to Reproduce
```yaml
# Include your workflow configuration
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-scanner-version: 'X.X.X.X'
    cache: 'true'
```

1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Logs
```
Paste relevant logs here
```

## Additional Context
Add any other context about the problem here.

## Checklist
- [ ] I have searched existing issues to ensure this is not a duplicate
- [ ] I have provided all required environment information
- [ ] I have included relevant logs and error messages
- [ ] I have tested with the latest version of the action