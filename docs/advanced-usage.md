# Advanced Usage Examples

This document provides advanced usage examples for the SonarScanner CLI Action.

## Custom Analysis Configuration

### Basic SonarQube Analysis
```yaml
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1

- name: Run SonarQube Analysis
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
    SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.projectName="My Project" \
      -Dsonar.projectVersion=1.0 \
      -Dsonar.sources=src \
      -Dsonar.exclusions="**/*.test.js,**/node_modules/**" \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN
```

### SonarCloud Analysis
```yaml
- name: Run SonarCloud Analysis
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-org_my-project \
      -Dsonar.organization=my-org \
      -Dsonar.host.url=https://sonarcloud.io \
      -Dsonar.login=$SONAR_TOKEN
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
- name: Setup SonarScanner CLI
  uses: eirisdg/sonarscanner-cli-action@v1

- name: Run Analysis for ${{ matrix.project.key }}
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    cd ${{ matrix.project.path }}
    sonar-scanner \
      -Dsonar.projectKey=${{ matrix.project.key }} \
      -Dsonar.sources=. \
      -Dsonar.exclusions="${{ matrix.project.exclusions }}"
```

### Pull Request Analysis
```yaml
- name: Setup SonarScanner CLI
  id: setup-sonar
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    wait-for-quality-gate: 'false'  # Usually disabled for PRs

- name: Run PR Analysis
  if: github.event_name == 'pull_request'
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.pullrequest.key=${{ github.event.number }} \
      -Dsonar.pullrequest.branch=${{ github.head_ref }} \
      -Dsonar.pullrequest.base=${{ github.base_ref }} \
      -Dsonar.qualitygate.wait=${{ steps.setup-sonar.outputs.quality-gate-wait }}
```

### Quality Gate Enforcement
```yaml
- name: Setup SonarScanner CLI
  id: setup-sonar
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    wait-for-quality-gate: 'true'

- name: Run Analysis with Quality Gate
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.qualitygate.wait=${{ steps.setup-sonar.outputs.quality-gate-wait }} \
      -Dsonar.qualitygate.timeout=300
    
    # The command will fail if quality gate fails
    echo "Quality gate passed successfully!"
```

### Quality Gate with Conditional Logic
```yaml
- name: Setup SonarScanner CLI
  id: setup-sonar
  uses: eirisdg/sonarscanner-cli-action@v1
  with:
    wait-for-quality-gate: ${{ github.ref == 'refs/heads/main' }}

- name: Run Analysis
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    sonar-scanner \
      -Dsonar.projectKey=my-project \
      -Dsonar.qualitygate.wait=${{ steps.setup-sonar.outputs.quality-gate-wait }}
    
    if [ "${{ steps.setup-sonar.outputs.quality-gate-wait }}" = "true" ]; then
      echo "Quality gate enforcement enabled for main branch"
    else
      echo "Quality gate enforcement disabled for feature branches"
    fi
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