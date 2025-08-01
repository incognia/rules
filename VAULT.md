# Reglas de Vault CLI

## Contexto y propósito

Estas reglas están diseñadas para operaciones con HashiCorp Vault CLI en entornos controlados por Rodrigo Álvarez, especialmente en tareas relacionadas con autenticación segura, gestión de secretos y operaciones DevOps dentro de infraestructura distribuida.

## Configuración inicial

### Variables de entorno

```bash
# URL del servidor Vault
export VAULT_ADDR="https://vault.example.com:8200"

# Token de autenticación (usar variables seguras)
export VAULT_TOKEN="$(cat ~/.vault-token)"

# Namespace por defecto (si aplica)
export VAULT_NAMESPACE="kv"
```

### Autenticación

```bash
# Autenticación interactiva
vault auth -method=userpass username=incognia

# Verificar estado de autenticación
vault auth -method=token -verify

# Renovar token
vault token renew
```

## Estructura de rutas estándar

### Namespace: kv (Key-Value v2)

| Ruta | Propósito | Formato |
|------|-----------|----------|
| `kv/incognia/passwords` | Credenciales y contraseñas temporales | JSON con campos: `username`, `password`, `expires` |
| `kv/incognia/ssh` | Claves SSH privadas y públicas | JSON con campos: `private_key`, `public_key`, `comment` |
| `kv/incognia/tokens` | Tokens de API y servicios externos | JSON con campos: `token`, `service`, `expires`, `scope` |
| `kv/incognia/certificates` | Certificados SSL/TLS | JSON con campos: `cert`, `key`, `ca`, `expires` |
| `kv/incognia/database` | Credenciales de bases de datos | JSON con campos: `host`, `port`, `username`, `password`, `database` |
| `kv/incognia/kubernetes` | Secretos de Kubernetes | JSON con campos: `kubeconfig`, `token`, `namespace` |

## Operaciones básicas

### Gestión de secretos

```bash
# Listar secretos en una ruta
vault kv list kv/incognia/

# Crear/actualizar secreto
vault kv put kv/incognia/passwords/myapp username="admin" password="secure123" expires="2025-12-31T23:59:59Z"

# Leer secreto (formato tabla)
vault kv get kv/incognia/passwords/myapp

# Leer secreto (formato JSON)
vault kv get -format=json kv/incognia/passwords/myapp

# Eliminar versión específica
vault kv delete -versions=1,2 kv/incognia/passwords/myapp

# Eliminar permanentemente
vault kv destroy -versions=1 kv/incognia/passwords/myapp

# Deshacer eliminación
vault kv undelete -versions=1 kv/incognia/passwords/myapp
```

### Versionado de secretos

```bash
# Ver historial de versiones
vault kv metadata get kv/incognia/passwords/myapp

# Leer versión específica
vault kv get -version=2 kv/incognia/passwords/myapp

# Configurar retención máxima
vault kv metadata put -max-versions=5 kv/incognia/passwords/myapp
```

## Procesamiento de claves SSH

### Descarga y formato de claves SSH

Las claves almacenadas en `kv/incognia/ssh` requieren post-procesamiento con `jq` para extraerlas correctamente desde la salida JSON.

```bash
# Extraer clave privada SSH
vault kv get -format=json kv/incognia/ssh/mykey | jq -r '.data.data.private_key' > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Extraer clave pública SSH
vault kv get -format=json kv/incognia/ssh/mykey | jq -r '.data.data.public_key' > ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/id_rsa.pub

# Extraer ambas claves en un solo comando
vault kv get -format=json kv/incognia/ssh/mykey | \
  jq -r '.data.data | 
    "\(.private_key)" > "~/.ssh/id_rsa",
    "\(.public_key)" > "~/.ssh/id_rsa.pub"'
```

### Validación de claves SSH

```bash
# Validar formato de clave privada
ssh-keygen -y -f ~/.ssh/id_rsa > /dev/null && echo "Clave privada válida" || echo "Clave privada inválida"

# Verificar coincidencia entre clave privada y pública
ssh-keygen -y -f ~/.ssh/id_rsa | diff - ~/.ssh/id_rsa.pub
```

## Gestión de tokens y credenciales

### Tokens de API

```bash
# Almacenar token de API
vault kv put kv/incognia/tokens/github \
  token="ghp_xxxxxxxxxxxxxxxxxxxx" \
  service="GitHub API" \
  expires="2025-12-31T23:59:59Z" \
  scope="repo,admin:org"

# Extraer token para uso en scripts
GITHUB_TOKEN=$(vault kv get -format=json kv/incognia/tokens/github | jq -r '.data.data.token')
export GITHUB_TOKEN
```

### Credenciales de base de datos

```bash
# Almacenar credenciales de PostgreSQL
vault kv put kv/incognia/database/postgresql \
  host="postgres.example.com" \
  port="5432" \
  username="dbadmin" \
  password="secure_password" \
  database="production"

# Extraer credenciales para conexión
DB_HOST=$(vault kv get -format=json kv/incognia/database/postgresql | jq -r '.data.data.host')
DB_USER=$(vault kv get -format=json kv/incognia/database/postgresql | jq -r '.data.data.username')
DB_PASS=$(vault kv get -format=json kv/incognia/database/postgresql | jq -r '.data.data.password')
```

## Integración con Kubernetes

### Configuración de kubeconfig

```bash
# Almacenar kubeconfig
vault kv put kv/incognia/kubernetes/cluster1 \
  kubeconfig="$(cat ~/.kube/config | base64 -w 0)" \
  namespace="production" \
  context="cluster1-admin"

# Restaurar kubeconfig
vault kv get -format=json kv/incognia/kubernetes/cluster1 | \
  jq -r '.data.data.kubeconfig' | base64 -d > ~/.kube/config
chmod 600 ~/.kube/config
```

## Mejores prácticas de seguridad

### Gestión de tokens

1. **Rotación regular**: Rotar tokens cada 30-90 días
2. **Principio de menor privilegio**: Otorgar solo los permisos mínimos necesarios
3. **Auditoría**: Revisar regularmente el acceso a secretos

```bash
# Crear token con TTL limitado
vault token create -ttl=24h -display-name="temp-access"

# Verificar capacidades del token actual
vault token capabilities kv/incognia/passwords/myapp
```

### Políticas de acceso

```bash
# Ver políticas asignadas al token actual
vault token lookup -format=json | jq -r '.data.policies[]'

# Verificar política específica
vault policy read incognia-dev
```

## Automatización y scripting

### Scripts de respaldo

```bash
#!/bin/bash
# backup-vault-secrets.sh

BACKUP_DIR="/backup/vault/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Respaldar todos los secretos del namespace incognia
for path in $(vault kv list -format=json kv/incognia/ | jq -r '.[]'); do
    vault kv get -format=json "kv/incognia/$path" > "$BACKUP_DIR/${path}.json"
done

echo "Respaldo completado en: $BACKUP_DIR"
```

### Validación de secretos

```bash
#!/bin/bash
# validate-secrets.sh

# Verificar que los secretos críticos existen
CRITICAL_SECRETS=(
    "kv/incognia/database/postgresql"
    "kv/incognia/ssh/admin"
    "kv/incognia/tokens/github"
)

for secret in "${CRITICAL_SECRETS[@]}"; do
    if vault kv get "$secret" >/dev/null 2>&1; then
        echo "✓ $secret - OK"
    else
        echo "✗ $secret - MISSING"
        exit 1
    fi
done
```

## Monitoreo y auditoría

### Comandos de diagnóstico

```bash
# Estado del servidor Vault
vault status

# Información del token actual
vault token lookup

# Listar montajes de secretos
vault secrets list

# Ver logs de auditoría (requiere permisos admin)
vault audit list
```

### Métricas y uso

```bash
# Estadísticas de uso del KV store
vault kv metadata get kv/incognia/ | grep -E "(created_time|updated_time|version)"

# Listar secretos por fecha de modificación
vault kv list -format=json kv/incognia/ | \
  jq -r '.[] | select(length > 0)' | \
  while read -r secret; do
    echo "$secret: $(vault kv metadata get kv/incognia/$secret | grep updated_time)"
  done
```

## Resolución de problemas comunes

### Errores de autenticación

```bash
# Token expirado
vault token renew || vault auth -method=userpass username=incognia

# Verificar conectividad
curl -k "$VAULT_ADDR/v1/sys/health"
```

### Problemas de permisos

```bash
# Verificar políticas del usuario actual
vault token lookup -format=json | jq '.data.policies'

# Probar acceso a una ruta específica
vault kv get kv/incognia/test 2>&1 | grep -q "permission denied" && \
  echo "Sin permisos" || echo "Acceso permitido"
```

---

*Este documento fue desarrollado por Rodrigo Álvarez para la gestión segura de secretos en infraestructura DevOps y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*
