# SonarScanner CLI Version Monitoring

Este documento describe el sistema automático de monitoreo de versiones de SonarScanner CLI implementado en este repositorio.

## 🎯 Objetivo

El sistema monitorea automáticamente las nuevas releases del [SonarSource/sonar-scanner-cli](https://github.com/SonarSource/sonar-scanner-cli) y crea issues automáticamente cuando una nueva versión está disponible, facilitando el proceso de actualización y asegurando que siempre tengamos la versión más reciente.

## 🔄 Funcionamiento

### Workflow de Monitoreo

El archivo `.github/workflows/monitor-sonar-scanner-versions.yml` ejecuta las siguientes tareas:

1. **Programación**: Se ejecuta diariamente a las 8:00 AM UTC
2. **Extracción de versión actual**: Lee la versión actual desde `action.yml`
3. **Consulta de última versión**: Consulta la API de GitHub para obtener la última release
4. **Comparación**: Compara las versiones para determinar si hay una actualización disponible
5. **Creación de issue**: Si hay una nueva versión, crea un issue detallado con checklist

### Tipos de Actualización

El sistema clasifica las actualizaciones por prioridad:

- **🔴 MAJOR**: Cambios en la versión mayor (e.g., 6.x.x → 7.x.x)
- **🟡 MINOR**: Cambios en la versión menor (e.g., 7.1.x → 7.2.x)  
- **🟢 PATCH**: Cambios en la versión de parche (e.g., 7.2.0 → 7.2.1)

## 📋 Checklist de Actualización

Cuando se crea un issue automáticamente, incluye un checklist completo con las siguientes categorías:

### Actualización de código
- [ ] Actualizar versión en `action.yml` (`sonar-scanner-version` default)
- [ ] Actualizar versión en ejemplos de documentación si es necesario
- [ ] Verificar compatibilidad con versiones anteriores

### Testing
- [ ] Ejecutar todos los tests existentes con la nueva versión
- [ ] Probar instalación en Linux, Windows y macOS
- [ ] Verificar que la nueva versión funciona con proyectos de ejemplo
- [ ] Probar con diferentes versiones de Java (17+)
- [ ] Verificar que el caching funciona correctamente

### Documentación
- [ ] Actualizar README.md con nueva versión por defecto
- [ ] Actualizar CHANGELOG.md con los cambios
- [ ] Actualizar documentación de ejemplos si hay cambios
- [ ] Verificar que los ejemplos de uso siguen funcionando

### Análisis de cambios importantes
- [ ] Revisar las release notes para cambios que rompan compatibilidad
- [ ] Identificar nuevas funcionalidades importantes
- [ ] Determinar si se necesitan cambios en el action
- [ ] Evaluar si se necesita actualizar la versión mayor/menor del action

### Validación final
- [ ] Todos los tests pasan en CI/CD
- [ ] Documentación actualizada y revisada
- [ ] Se ha probado en al menos 2 proyectos diferentes
- [ ] Release notes del action actualizadas

## 🚀 Ejecución Manual

El workflow se puede ejecutar manualmente desde la interfaz de GitHub Actions:

1. Ve a la pestaña "Actions" del repositorio
2. Selecciona "Monitor SonarScanner CLI Versions"
3. Haz clic en "Run workflow"
4. Opcionalmente, marca "Force version check" para forzar la verificación

## 🔧 Configuración

### Variables de Entorno

El workflow utiliza las siguientes variables:

- `GITHUB_TOKEN`: Token automático de GitHub (proporcionado por GitHub Actions)
- No se requieren tokens adicionales o configuración manual

### Permisos Requeridos

El workflow requiere los siguientes permisos:

- `contents: read` - Para leer el repositorio
- `issues: write` - Para crear issues automáticamente

## 📊 Información del Issue

Cada issue automático incluye:

- **Metadatos**: Versión actual, nueva versión, tipo de actualización, prioridad
- **Release notes**: Notas completas de la nueva release
- **Checklist detallado**: Pasos específicos para la actualización
- **Labels**: `version-update`, `enhancement`, `{type}-update`
- **Asignación**: Al propietario del repositorio

## 🔍 Monitoreo y Logs

Para revisar el funcionamiento del sistema:

1. Ve a la pestaña "Actions"
2. Busca las ejecuciones de "Monitor SonarScanner CLI Versions"
3. Revisa los logs para ver el estado de las verificaciones

### Estados Posibles

- **✅ Up to date**: La versión actual está actualizada
- **🔔 Update needed**: Nueva versión disponible, issue creado
- **ℹ️ Issue already exists**: Nueva versión detectada pero ya existe un issue

## 🛠 Mantenimiento

### Actualización del Workflow

Si necesitas modificar el comportamiento del monitoreo:

1. Edita `.github/workflows/monitor-sonar-scanner-versions.yml`
2. Prueba los cambios ejecutando manualmente el workflow
3. Confirma que la lógica funciona correctamente

### Resolución de Problemas

**El workflow no se ejecuta:**
- Verifica que el cron esté configurado correctamente
- Asegúrate de que el repositorio tenga permisos para ejecutar Actions

**No se crean issues:**
- Verifica los permisos `issues: write`
- Revisa los logs del workflow para errores
- Confirma que no existe ya un issue para la versión

**Extracción de versión incorrecta:**
- Verifica que el formato en `action.yml` no haya cambiado
- Prueba la expresión `awk` manualmente

## 📚 Referencias

- [SonarSource/sonar-scanner-cli releases](https://github.com/SonarSource/sonar-scanner-cli/releases)
- [GitHub Actions documentation](https://docs.github.com/actions)
- [GitHub CLI documentation](https://cli.github.com/)