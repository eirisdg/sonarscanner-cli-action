# SonarScanner CLI Action

Una GitHub Action que utiliza SonarScanner CLI de SonarSource para analizar código en cualquier lenguaje de programación, con la flexibilidad de agregar argumentos personalizados.

## 📋 Descripción

Esta acción se encarga de ejecutar análisis de código usando **sonarscanner-cli** de SonarSource, independientemente del lenguaje de programación en el que esté escrito el proyecto. 

### 🚀 Característica Diferencial

El punto diferencial con otras acciones similares es que **permite añadir argumentos extra que no estén predefinidos**, lo que amplía enormemente las posibilidades de configuración y personalización del análisis.

## ✨ Características Principales

- 🔍 **Análisis Universal**: Funciona con cualquier lenguaje de programación soportado por SonarQube
- ⚙️ **Configuración Flexible**: Acepta múltiples parámetros predefinidos
- 🛠️ **Argumentos Personalizados**: Permite agregar argumentos adicionales no predefinidos
- 📊 **Integración Completa**: Se integra perfectamente con flujos de GitHub Actions
- 🔒 **Seguro**: Manejo seguro de tokens y credenciales

## 📥 Inputs

### Parámetros Principales

| Parámetro | Descripción | Requerido | Valor por Defecto |
|-----------|-------------|-----------|-------------------|
| `sonar-host-url` | URL del servidor SonarQube | ✅ | - |
| `sonar-token` | Token de autenticación para SonarQube | ✅ | - |
| `sonar-project-key` | Clave única del proyecto en SonarQube | ✅ | - |
| `sonar-project-name` | Nombre del proyecto | ❌ | Nombre del repositorio |
| `sonar-project-version` | Versión del proyecto | ❌ | `1.0` |
| `sonar-sources` | Directorios de código fuente | ❌ | `.` |
| `sonar-exclusions` | Archivos/directorios a excluir | ❌ | - |
| `sonar-inclusions` | Archivos/directorios a incluir específicamente | ❌ | - |
| `working-directory` | Directorio de trabajo | ❌ | `.` |

### Parámetros Avanzados

| Parámetro | Descripción | Requerido | Valor por Defecto |
|-----------|-------------|-----------|-------------------|
| `sonar-organization` | Organización en SonarCloud | ❌ | - |
| `sonar-branch-name` | Nombre de la rama a analizar | ❌ | - |
| `sonar-pull-request-key` | Número del Pull Request | ❌ | - |
| `sonar-pull-request-branch` | Rama del Pull Request | ❌ | - |
| `sonar-pull-request-base` | Rama base del Pull Request | ❌ | - |

### 🛠️ Argumentos Personalizados

| Parámetro | Descripción | Requerido | Ejemplo |
|-----------|-------------|-----------|---------|
| `extra-args` | Argumentos adicionales para sonar-scanner | ❌ | `-Dsonar.java.binaries=target/classes -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml` |

## 🔧 Uso

### Ejemplo Básico

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
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarQube Analysis
        uses: eirisdg/sonarscanner-cli-action@v1
        with:
          sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
          sonar-token: ${{ secrets.SONAR_TOKEN }}
          sonar-project-key: 'mi-proyecto-clave'
          sonar-project-name: 'Mi Proyecto'
```

### Ejemplo con Configuración Avanzada

```yaml
name: SonarQube Analysis with Custom Args

on:
  push:
    branches: [ main ]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarQube Analysis
        uses: eirisdg/sonarscanner-cli-action@v1
        with:
          sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
          sonar-token: ${{ secrets.SONAR_TOKEN }}
          sonar-project-key: 'mi-proyecto-avanzado'
          sonar-project-name: 'Mi Proyecto Avanzado'
          sonar-project-version: ${{ github.sha }}
          sonar-sources: 'src,lib'
          sonar-exclusions: '**/*test*/**,**/*.spec.ts,**/node_modules/**'
          extra-args: |
            -Dsonar.java.binaries=target/classes
            -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            -Dsonar.typescript.lcov.reportPaths=coverage/lcov.info
            -Dsonar.eslint.reportPaths=eslint-report.json
```

### Ejemplo para Pull Requests

```yaml
name: SonarQube PR Analysis

on:
  pull_request:
    branches: [ main ]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarQube PR Analysis
        uses: eirisdg/sonarscanner-cli-action@v1
        with:
          sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
          sonar-token: ${{ secrets.SONAR_TOKEN }}
          sonar-project-key: 'mi-proyecto'
          sonar-pull-request-key: ${{ github.event.number }}
          sonar-pull-request-branch: ${{ github.head_ref }}
          sonar-pull-request-base: ${{ github.base_ref }}
          extra-args: '-Dsonar.pullrequest.provider=github'
```

### Ejemplo para SonarCloud

```yaml
name: SonarCloud Analysis

on:
  push:
    branches: [ main ]

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: SonarCloud Analysis
        uses: eirisdg/sonarscanner-cli-action@v1
        with:
          sonar-host-url: 'https://sonarcloud.io'
          sonar-token: ${{ secrets.SONAR_TOKEN }}
          sonar-organization: 'mi-organizacion'
          sonar-project-key: 'mi-organizacion_mi-proyecto'
          extra-args: |
            -Dsonar.branch.name=${{ github.ref_name }}
            -Dsonar.scm.provider=git
```

## 🔒 Configuración de Secrets

Asegúrate de configurar los siguientes secrets en tu repositorio:

| Secret | Descripción |
|--------|-------------|
| `SONAR_HOST_URL` | URL de tu servidor SonarQube/SonarCloud |
| `SONAR_TOKEN` | Token de autenticación generado en SonarQube |

### Cómo obtener el SONAR_TOKEN:

1. **SonarQube**: Ve a User → My Account → Security → Generate Token
2. **SonarCloud**: Ve a Account → Security → Generate Token

## 📝 Configuración del Proyecto

### sonar-project.properties (Opcional)

Puedes usar un archivo `sonar-project.properties` en la raíz de tu proyecto:

```properties
sonar.projectKey=mi-proyecto-clave
sonar.projectName=Mi Proyecto
sonar.projectVersion=1.0
sonar.sources=src
sonar.exclusions=**/*test*/**,**/node_modules/**
sonar.sourceEncoding=UTF-8
```

## 🌐 Lenguajes Soportados

Esta acción funciona con todos los lenguajes soportados por SonarQube, incluyendo:

- Java
- JavaScript/TypeScript
- Python
- C#/.NET
- C/C++
- Go
- PHP
- Ruby
- Kotlin
- Scala
- Swift
- Y muchos más...

## ⚡ Argumentos Personalizados Avanzados

La funcionalidad de `extra-args` permite una configuración extremadamente flexible:

```yaml
extra-args: |
  -Dsonar.java.binaries=target/classes,build/classes
  -Dsonar.java.libraries=lib/**/*.jar
  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
  -Dsonar.typescript.lcov.reportPaths=coverage/lcov.info
  -Dsonar.eslint.reportPaths=eslint-report.json
  -Dsonar.python.coverage.reportPaths=coverage.xml
  -Dsonar.go.coverage.reportPaths=coverage.out
  -Dsonar.php.coverage.reportPaths=coverage.xml
  -Dsonar.dotnet.coverage.reportPaths=coverage.xml
  -Dsonar.scm.provider=git
  -Dsonar.pullrequest.github.repository=${{ github.repository }}
```

## 🔧 Requisitos

- SonarQube 7.9+ o SonarCloud
- Token de autenticación válido
- Permisos de lectura en el repositorio

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la [documentación oficial de SonarScanner](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
2. Busca en los [Issues](https://github.com/eirisdg/sonarscanner-cli-action/issues) existentes
3. Crea un nuevo Issue si no encuentras una solución

## 📚 Enlaces Útiles

- [Documentación de SonarQube](https://docs.sonarqube.org/)
- [SonarCloud](https://sonarcloud.io/)
- [SonarScanner CLI](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
- [GitHub Actions](https://docs.github.com/en/actions)
