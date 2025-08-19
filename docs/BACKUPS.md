# Políticas de respaldos

## Convención de nomenclatura

### Estructura del nombre de respaldo

Cada archivo de respaldo sigue esta estructura de nomenclatura:

```text
[nombre_sin_extensión]_[timestamp].[extensión_original].bkp
```

**Componentes:**

- **Nombre base:** el nombre del archivo original sin su extensión
- **Separador:** guion bajo (_)
- **Timestamp:** fecha y hora en formato ISO: `YYYY-MM-DDTHH-MM-SS` (zona horaria CST Ciudad de México, UTC-6)
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

⚠️ **ADVERTENCIA CRÍTICA:** No es suficiente añadir el sufijo "CST" a una fecha UTC. Debes restar 6 horas a la fecha UTC para obtener la fecha CST correcta. Usar `TZ="America/Mexico_City"` en comandos `date` garantiza la conversión automática.

## Política de respaldos antes de operaciones destructivas

### Definición

Esta política aplica a cualquier script o comando que realice operaciones de eliminación permanente de archivos, registros, configuraciones o cualquier otro tipo de datos.

### Ejecución manual

Si la ejecución del script o comando es manual (iniciada por un usuario), el sistema deberá:

1. Mostrar un mensaje de advertencia que indique que se realizará un borrado irreversible
1. Preguntar explícitamente si se desea realizar un respaldo antes de continuar
1. Permitir al usuario elegir entre las siguientes opciones:
   - Realizar respaldo automático siguiendo la política de respaldos establecida
   - Cancelar la ejecución
   - Continuar sin respaldo (solo si se confirma dos veces)

### Ejecución automática

Si la ejecución es automatizada (por cron jobs, pipelines, bots u otros procesos no interactivos):

1. El script deberá verificar si existe una política de respaldo activa
1. Deberá realizar un respaldo completo conforme a dicha política antes de iniciar cualquier operación destructiva
1. Si el respaldo falla, el script no deberá continuar con el borrado. Deberá registrar el error y salir de forma segura

### Registro y auditoría

Toda acción de borrado deberá ser registrada con:

- Fecha y hora (formato 24 horas, zona horaria CST Ciudad de México, UTC-6)
- Usuario o proceso que inició la ejecución
- Resultado del respaldo
- Elementos afectados por el borrado

⚠️ **IMPORTANTE:** Para el registro de auditoría, usar siempre `TZ="America/Mexico_City" date` para garantizar que la fecha se calcule correctamente en CST (restando 6 horas a UTC), no solo agregando el sufijo CST.

### Buenas prácticas recomendadas

- Implementar funciones de respaldo reutilizables en los scripts
- Utilizar variables de entorno para definir rutas de respaldo
- Incluir pruebas en entornos de staging antes de aplicar en producción

## Estructura de directorios de respaldos

```text
backups/
├── daily/          # Respaldos diarios automáticos (subcarpetas por fecha YYYY-MM-DD)
├── manual/         # Respaldos manuales por demanda (subcarpetas por fecha)
├── pre-deploy/     # Respaldos antes de despliegues
├── pre-delete/     # Respaldos antes de operaciones destructivas
└── archive/        # Respaldos antiguos comprimidos
```

Ejemplo con fecha del día (CST):

```bash
DATE_CST=$(TZ="America/Mexico_City" date +"%Y-%m-%d")
mkdir -p "backups/daily/${DATE_CST}"
```

## Restauración

- Localiza el respaldo a restaurar y su archivo de checksum (.sha256 si existe).
- Verifica integridad antes de restaurar.
- Restaura preservando permisos cuando aplique y valida el resultado.

Ejemplo (archivo suelto):

```bash
# Verificación previa (si hay checksum)
sha256sum -c backups/daily/2025-08-18/archivo_2025-08-18T12-00-00.txt.bkp.sha256

# Restauración
cp backups/daily/2025-08-18/archivo_2025-08-18T12-00-00.txt.bkp ./archivo.txt

# Validación posterior (opcional)
sha256sum ./archivo.txt
```

Ejemplo (tar.zst):

```bash
# Verificar e inspeccionar
zstd -t archivo_2025-08-18T12-00-00.tar.zst
unzstd -c archivo_2025-08-18T12-00-00.tar.zst | tar -tvf -
# Restaurar en ruta destino
unzstd -c archivo_2025-08-18T12-00-00.tar.zst | tar -xvf - -C /ruta/destino
```

## Verificación e integridad (checksums)

- Política: generar .sha256 solo para respaldos grandes (tamaño >= 100 MB) para optimizar costo/tiempo.
  - Umbral configurable: `BACKUP_SHA_THRESHOLD_BYTES` (por defecto 104857600 = 100 MB).
- Los archivos con .sha256 deben verificarse siempre; los menores al umbral pueden verificarse bajo demanda.
- Verificación masiva:

```bash
find backups -type f -name "*.sha256" -exec sha256sum -c {} \;
```

## Compresión recomendada (zstd)

- Mejor relación/velocidad que gzip en muchos casos.
- Ejemplo para empaquetar y comprimir un archivo/directorio:

```bash
TS=$(TZ=America/Mexico_City date +"%Y-%m-%dT%H-%M-%S")
TARGET="mi_carpeta"
tar --mtime="$(date -d "$TS" +%Y-%m-%d)" --owner=0 --group=0 --numeric-owner -cf - "$TARGET" | zstd -T0 -19 -o "${TARGET}_${TS}.tar.zst"
```

## Incrementales eficientes con rsync (--link-dest)

- Permite snapshots diarios con hardlinks a archivos no cambiados.
- Esquema:

```bash
BASE="/datos"
DEST="backups/daily"
DATE_CST=$(TZ=America/Mexico_City date +"%Y-%m-%d")
SNAP="$DEST/$DATE_CST"
LAST=$(ls -1 "$DEST" | sort | tail -n1)
mkdir -p "$SNAP"
if [ -n "$LAST" ] && [ "$LAST" != "$DATE_CST" ]; then
  rsync -a --delete --link-dest="$DEST/$LAST" "$BASE/" "$SNAP/"
else
  rsync -a --delete "$BASE/" "$SNAP/"
fi
```

## Cifrado y offsite

- Cifrado con age (recomendado) o gpg antes de enviar offsite.
- Ejemplo age:

```bash
age -r RECIPIENT -o backup.tar.zst.age backup.tar.zst
```

- Subida offsite con rclone (S3/Backblaze/SSH):

```bash
rclone copy backups remote:bucket/path
```

- Política 3-2-1: 3 copias, 2 medios, 1 offsite.

## Programación (Fedora, systemd)

Ejemplo de unidades (ver carpeta systemd/backups/):

- `backup@.service`
- `backup@daily.timer`

Variables recomendadas en el servicio:

- Environment=TZ=America/Mexico_City
- Logs a ruta fija en CST.

## Registro y auditoría

Formato sugerido de línea de log:

```text
YYYY-MM-DD HH:MM:SS | acción | archivo | resultado | checksum
```

- Rotar backup.log y deletion.log periódicamente.

## Seguridad y permisos

- Propietario/grupo: root:root para respaldos sensibles; permisos 0640.
- Añade backups/ al .gitignore del repositorio.
- SELinux: al restaurar en sistemas con SELinux, reetiquetar contextos: `restorecon -R /ruta/restaurada`.

## Bases de datos (ejemplos)

PostgreSQL (dump/restore):

```bash
# Dump
pg_dump --format=custom --no-owner --no-privileges "${PGDATABASE}" > "backups/daily/${DATE_CST}/db_${DATE_CST}.dump"
# Restore
pg_restore --clean --no-owner --no-privileges -d "${PGDATABASE}" "db_${DATE_CST}.dump"
```

MySQL/MariaDB (dump/restore):

```bash
# Dump
mysqldump --single-transaction --routines --events "$MYSQL_DATABASE" > "backups/daily/${DATE_CST}/db_${DATE_CST}.sql"
# Restore
mysql "$MYSQL_DATABASE" < "db_${DATE_CST}.sql"
```

## Ejemplos de implementación

### Script de respaldo básico

#### Respaldo rápido en el mismo directorio (archivos pequeños)

```bash
# Uso: quick_bkp.sh archivo1 [archivo2 ...]
# Ejemplo: archivo.txt -> archivo_YYYY-MM-DD.txt.bkp
bash ~/rules/scripts/quick_bkp.sh archivo.txt
```

```bash
#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "%s | %s\n" "$(TZ=America/Mexico_City date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "${BACKUP_LOG_FILE:-backups/backup.log}"
}

# Función para crear respaldo con timestamp y checksum
create_backup() {
  local source_file="$1"
  local backup_dir="${2:-backups}"
  local timestamp=$(TZ="America/Mexico_City" date +"%Y-%m-%dT%H-%M-%S")
  local filename=$(basename "$source_file")
  local name_without_ext="${filename%.*}"
  local extension="${filename##*.}"

  if [[ "$filename" == "$extension" ]]; then
    local backup_name="${filename}_${timestamp}.bkp"
  else
    local backup_name="${name_without_ext}_${timestamp}.${extension}.bkp"
  fi

  mkdir -p "$backup_dir"
  cp -a "$source_file" "$backup_dir/$backup_name"
  (cd "$backup_dir" && sha256sum "$backup_name" > "$backup_name.sha256")
  log "backup | $backup_dir/$backup_name | ok | $(awk '{print $1}' "$backup_dir/$backup_name.sha256")"
}

# Función para operaciones destructivas con confirmación
safe_delete() {
  local target="$1"
  echo "ADVERTENCIA: Se eliminará permanentemente: $target"
  read -p "¿Desea crear un respaldo antes de continuar? (s/n): " -n 1 -r; echo
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    create_backup "$target" "backups/pre-delete"
  else
    read -p "¿Está seguro de continuar sin respaldo? (escriba 'CONFIRMAR'): " confirm
    if [[ ${confirm:-} != "CONFIRMAR" ]]; then
      echo "Operación cancelada"; return 1
    fi
  fi
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

