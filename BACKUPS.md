# Políticas de respaldos

## Convención de nomenclatura

### Estructura del nombre de respaldo

Cada archivo de respaldo sigue esta estructura de nomenclatura:

```
[nombre_sin_extensión]_[timestamp].[extensión_original].bkp
```

**Componentes:**
- **Nombre base:** el nombre del archivo original sin su extensión
- **Separador:** guion bajo (_)
- **Timestamp:** fecha y hora en formato ISO: `YYYY-MM-DDTHH-MM-SS` (zona horaria CST Ciudad de México)
- **Extensión original:** se preserva la extensión del archivo original
- **Extensión de respaldo:** se añade `.bkp` al final

**Ejemplos de nomenclatura:**
- `archivo.txt` → `archivo_2025-08-01T04-38-18.txt.bkp`
- `config.yaml` → `config_2025-08-01T04-38-18.yaml.bkp`
- `script.sh` → `script_2025-08-01T04-38-18.sh.bkp`
- `database.sql` → `database_2025-08-01T04-38-18.sql.bkp`

### Ubicación de respaldos

Los respaldos deben almacenarse en una carpeta llamada «backups», creada según el contexto del proyecto o sistema.

Si se encuentra un archivo con extensión «.bak» o «.bkp» que no cumpla con los estándares establecidos, revisa su timestamp y actualiza el nombre para alinearlo con esta convención.

La inclusión de la hora garantiza nombres únicos y trazabilidad precisa, independientemente de la frecuencia de respaldos en el día.

Evita sobrescribir respaldos previos. La convención de fecha y hora permite conservar la secuencia histórica de cada copia.

**Zona horaria obligatoria:** todos los timestamps deben generarse usando la zona horaria CST de Ciudad de México (UTC-6). Nunca usar UTC ni la zona horaria local del sistema si es diferente a CST.

## Política de respaldos antes de operaciones destructivas

### Definición
Esta política aplica a cualquier script o comando que realice operaciones de eliminación permanente de archivos, registros, configuraciones o cualquier otro tipo de datos.

### Ejecución manual
Si la ejecución del script o comando es manual (iniciada por un usuario), el sistema deberá:

1. Mostrar un mensaje de advertencia que indique que se realizará un borrado irreversible
2. Preguntar explícitamente si se desea realizar un respaldo antes de continuar
3. Permitir al usuario elegir entre las siguientes opciones:
   - Realizar respaldo automático siguiendo la política de respaldos establecida
   - Cancelar la ejecución
   - Continuar sin respaldo (solo si se confirma dos veces)

### Ejecución automática
Si la ejecución es automatizada (por cron jobs, pipelines, bots u otros procesos no interactivos):

1. El script deberá verificar si existe una política de respaldo activa
2. Deberá realizar un respaldo completo conforme a dicha política antes de iniciar cualquier operación destructiva
3. Si el respaldo falla, el script no deberá continuar con el borrado. Deberá registrar el error y salir de forma segura

### Registro y auditoría
Toda acción de borrado deberá ser registrada con:
- Fecha y hora (formato 24 horas, zona horaria CST Ciudad de México)
- Usuario o proceso que inició la ejecución
- Resultado del respaldo
- Elementos afectados por el borrado

### Buenas prácticas recomendadas
- Implementar funciones de respaldo reutilizables en los scripts
- Utilizar variables de entorno para definir rutas de respaldo
- Incluir pruebas en entornos de staging antes de aplicar en producción

## Estructura de directorios de respaldos

```
backups/
├── daily/          # Respaldos diarios automáticos
├── manual/         # Respaldos manuales por demanda
├── pre-deploy/     # Respaldos antes de despliegues
├── pre-delete/     # Respaldos antes de operaciones destructivas
└── archive/        # Respaldos antiguos comprimidos
```

## Ejemplos de implementación

### Script de respaldo básico
```bash
#!/bin/bash

# Función para crear respaldo con timestamp
create_backup() {
    local source_file="$1"
    local backup_dir="${2:-backups}"
    local timestamp=$(TZ="America/Mexico_City" date +"%Y-%m-%dT%H-%M-%S")
    local filename=$(basename "$source_file")
    local name_without_ext="${filename%.*}"
    local extension="${filename##*.}"
    
    # Si el archivo no tiene extensión, usar solo el nombre
    if [[ "$filename" == "$extension" ]]; then
        local backup_name="${filename}_${timestamp}.bkp"
    else
        local backup_name="${name_without_ext}_${timestamp}.${extension}.bkp"
    fi
    
    mkdir -p "$backup_dir"
    cp "$source_file" "$backup_dir/$backup_name"
    echo "Respaldo creado: $backup_dir/$backup_name"
}

# Función para operaciones destructivas con confirmación
safe_delete() {
    local target="$1"
    
    echo "ADVERTENCIA: Se eliminará permanentemente: $target"
    read -p "¿Desea crear un respaldo antes de continuar? (s/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        create_backup "$target" "backups/pre-delete"
    else
        read -p "¿Está seguro de continuar sin respaldo? (escriba 'CONFIRMAR'): " confirm
        if [[ $confirm != "CONFIRMAR" ]]; then
            echo "Operación cancelada"
            return 1
        fi
    fi
    
    # Proceder con la eliminación
    rm -f "$target"
    echo "$(TZ="America/Mexico_City" date '+%Y-%m-%d %H:%M:%S') - Eliminado: $target" >> backups/deletion.log
}
```

### Variables de entorno recomendadas
```bash
export BACKUP_DIR="/path/to/backups"
export BACKUP_RETENTION_DAYS="30"
export BACKUP_COMPRESS_AFTER_DAYS="7"
export BACKUP_LOG_FILE="$BACKUP_DIR/backup.log"
```

## Mantenimiento de respaldos

### Retención de archivos
- Respaldos diarios: conservar por 30 días
- Respaldos manuales: conservar por 90 días
- Respaldos pre-deploy: conservar por 180 días
- Respaldos pre-delete: conservar permanentemente (archivar después de 1 año)

### Compresión automática
Respaldos mayores a 7 días deben comprimirse automáticamente para optimizar el espacio de almacenamiento:

```bash
# Comprimir respaldos antiguos
find backups/ -name "*.bkp" -mtime +7 -exec gzip {} \;
```

### Limpieza automática
```bash
# Eliminar respaldos expirados
find backups/daily/ -name "*.bkp*" -mtime +30 -delete
find backups/manual/ -name "*.bkp*" -mtime +90 -delete
```

---

*Elaborado por Rodrigo Álvarez (@incognia)*

