# Sistema de Monitoreo de SonarScanner CLI

Este repositorio incluye un sistema automatizado de monitoreo de las releases del SonarScanner CLI oficial.

## Funcionamiento

### Workflow Automático
- **Archivo**: `.github/workflows/monitor-sonar-scanner-releases.yml`
- **Frecuencia**: Diario a las 09:00 UTC
- **Ejecución manual**: Disponible a través de `workflow_dispatch`

### Proceso de Monitoreo

1. **Verificación de nuevas releases**: El workflow consulta la API de GitHub del repositorio oficial `SonarSource/sonar-scanner-cli`
2. **Comparación de versiones**: Compara la última versión disponible con la versión almacenada en `.sonar-scanner-version`
3. **Creación de issues**: Si se detecta una nueva versión, crea automáticamente una issue con:
   - Información detallada de la nueva versión
   - Notas de la release completas
   - Lista de tareas a realizar para la actualización
   - Labels apropiados para facilitar el filtrado

4. **Actualización del tracking**: Actualiza el archivo `.sonar-scanner-version` con la nueva versión

### Archivo de Tracking

- **Ubicación**: `.sonar-scanner-version`
- **Propósito**: Almacena la última versión procesada para evitar duplicados
- **Formato**: Texto plano con el número de versión (ejemplo: `7.2.0.5079`)

### Template de Issues

- **Ubicación**: `.github/ISSUE_TEMPLATE/sonar-scanner-update.md`
- **Propósito**: Proporciona estructura consistente para las issues de actualización
- **Contenido**: Checklist de tareas, información de la versión, y notas importantes

## Configuración

### Permisos Requeridos
El workflow requiere los siguientes permisos:
- `issues: write` - Para crear nuevas issues
- `contents: write` - Para actualizar el archivo de tracking

### Labels Automáticos
Las issues creadas automáticamente incluyen:
- `sonar-scanner-update` - Identifica actualizaciones de SonarScanner
- `automation` - Marca contenido generado automáticamente

## Uso Manual

### Ejecutar el Workflow Manualmente
1. Ve a la pestaña "Actions" del repositorio
2. Selecciona "Monitor SonarScanner CLI Releases"
3. Haz clic en "Run workflow"

### Modificar la Frecuencia
Para cambiar la frecuencia de ejecución, edita la expresión cron en el workflow:
```yaml
schedule:
  - cron: '0 9 * * *'  # Actual: diario a las 09:00 UTC
```

## Mantenimiento

### Verificación Manual de Versiones
```bash
# Ver la versión actualmente trackeada
cat .sonar-scanner-version

# Obtener la última versión disponible
curl -s https://api.github.com/repos/SonarSource/sonar-scanner-cli/releases/latest | jq -r '.tag_name'
```

### Resolución de Problemas

1. **Issues duplicadas**: Verificar que el archivo `.sonar-scanner-version` esté actualizado
2. **Fallos del workflow**: Revisar los logs en la pestaña Actions
3. **Permisos insuficientes**: Verificar la configuración de permisos del repositorio

## Beneficios

- **Automatización completa**: No requiere intervención manual para detectar nuevas versiones
- **Información detallada**: Incluye todas las notas de release y cambios importantes
- **Proceso estructurado**: Proporciona una lista de tareas clara para cada actualización
- **Historial completo**: Mantiene un registro de todas las actualizaciones a través de issues
- **Filtrado fácil**: Usa labels consistentes para facilitar la búsqueda y filtrado