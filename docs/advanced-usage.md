# Advanced Usage Examples

This document provides advanced usage examples for the SonarScanner CLI Action.

## Smart Analysis Features

The action includes intelligent auto-detection capabilities that are enabled by default. These features automatically detect and configure analysis tools when their artifacts are present.

### Default Behavior
- **JaCoCo integration**: Auto-enabled when `jacoco.xml` reports are detected
- **ESLint integration**: Auto-enabled when `.eslintrc*` configuration files are detected  
- **Hadolint integration**: Auto-enabled when `Dockerfile` or `.hadolint.*` configuration is detected

### Customizing Smart Features
```yaml
- name: Customize Smart Features
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: 'my-project'
    # Disable specific auto-detection features
    enable-jacoco: 'false'    # Disable JaCoCo even if reports exist
    enable-eslint: 'true'     # Keep ESLint auto-detection (default)
    enable-hadolint: 'false'  # Disable Hadolint even if Dockerfile exists
```

## Direct Analysis Configuration

### Basic SonarQube Analysis
```yaml
- name: Run SonarQube Analysis
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: 'my-project'
    sonar-project-name: 'My Project'
    sonar-project-version: '1.0'
    sonar-sources: 'src'
    sonar-exclusions: '**/*.test.js,**/node_modules/**'
```

### SonarCloud Analysis
```yaml
- name: Run SonarCloud Analysis
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: 'https://sonarcloud.io'
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-organization: 'my-org'
    sonar-project-key: 'my-org_my-project'
    sonar-sources: 'src'
```

### Matrix Strategy for Multiple Projects
```yaml
strategy:
  matrix:
    project:
      - { key: "frontend", path: "frontend/", exclusions: "**/node_modules/**,**/*.test.js" }
      - { key: "backend", path: "backend/", exclusions: "**/target/**,**/*Test.java" }
      - { key: "mobile", path: "mobile/", exclusions: "**/build/**,**/*Test.kt" }

steps:
- name: Run Analysis for ${{ matrix.project.key }}
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: ${{ matrix.project.key }}
    sonar-sources: '.'
    sonar-exclusions: ${{ matrix.project.exclusions }}
    working-directory: ${{ matrix.project.path }}
```

### Pull Request Analysis
```yaml
- name: Run PR Analysis
  if: github.event_name == 'pull_request'
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: 'my-project'
    sonar-pull-request-key: ${{ github.event.number }}
    sonar-pull-request-branch: ${{ github.head_ref }}
    sonar-pull-request-base: ${{ github.base_ref }}
    extra-args: |
      -Dsonar.pullrequest.provider=github
      -Dsonar.pullrequest.github.repository=${{ github.repository }}
```

### Branch Analysis
```yaml
- name: Run Branch Analysis
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: 'my-project'
    sonar-branch-name: ${{ github.ref_name }}
    sonar-sources: 'src'
```

### Quality Gate Enforcement with Conditional Logic
```yaml
- name: Run Analysis with Quality Gate
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
    sonar-token: ${{ secrets.SONAR_TOKEN }}
    sonar-project-key: 'my-project'
    sonar-sources: 'src'
    extra-args: |
      -Dsonar.qualitygate.wait=${{ github.ref == 'refs/heads/main' && 'true' || 'false' }}
      -Dsonar.qualitygate.timeout=300
```

## Integration with Test Coverage

### JavaScript/TypeScript with Jest
```yaml
- name: Run tests with coverage
  run: npm test -- --coverage

- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1

- name: Run SonarQube analysis
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.sources=src \
      -Dsonar.tests=src \
      -Dsonar.test.inclusions="**/*.test.js,**/*.test.ts" \
      -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
```

### Java with Maven
```yaml
- name: Run tests with coverage
  run: mvn clean test jacoco:report

- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1

- name: Run SonarQube analysis
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.sources=src/main/java \
      -Dsonar.tests=src/test/java \
      -Dsonar.java.binaries=target/classes \
      -Dsonar.java.test.binaries=target/test-classes \
      -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
```

## Troubleshooting

### Debug Mode
```yaml
- name: Setup SonarScanner CLI (Debug)
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    sonar-scanner-version: '7.2.0.5079'

- name: Run Analysis with Debug
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_SCANNER_OPTS: "-Xmx1024m"
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.verbose=true \
      -Dsonar.log.level=DEBUG
```

### Custom Java Memory Settings
```yaml
- name: Run Analysis with Custom Memory
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_SCANNER_OPTS: "-Xmx2048m -XX:MaxPermSize=512m"
  run: sonar-scanner
```