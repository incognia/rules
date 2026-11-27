# Reglas de Vault CLI

## Contexto y propósito

Estas reglas están diseñadas para operaciones con HashiCorp Vault CLI en entornos controlados por Rodrigo Álvarez, especialmente en tareas relacionadas con autenticación segura, gestión de secretos y operaciones DevOps dentro de infraestructura distribuida.

## Configuración inicial

### Variables de entorno

```bash
# Vault server URL
export VAULT_ADDR="https://vault.example.com:8200"

# No VAULT_TOKEN export is needed: `vault login` stores the token in ~/.vault-token
# and the CLI reads it from there.

# Only on Vault Enterprise or HCP, when the secrets live in a namespace:
# export VAULT_NAMESPACE="<namespace>"
```

### Autenticación

```bash
# Interactive login: the password is asked for, never passed as an argument
vault login -method=userpass username=incognia

# Check the current token (identity, policies and time to live)
vault token lookup

# Renew the token
vault token renew
```

## Estructura de rutas estándar

### Montaje `kv` (motor Key-Value v2)

`kv` es el punto de montaje del motor de secretos, no un *namespace* de Vault Enterprise.

| Ruta | Propósito | Formato |
|------|-----------|----------|
| `kv/incognia/passwords` | Credenciales y contraseñas temporales | JSON con campos: `username`, `password`, `expires` |
| `kv/incognia/ssh` | Claves SSH privadas y públicas | JSON con campos: `private_key`, `public_key`, `comment` |
| `kv/incognia/tokens` | *Tokens* de API y servicios externos | JSON con campos: `token`, `service`, `expires`, `scope` |
| `kv/incognia/certificates` | Certificados SSL/TLS | JSON con campos: `cert`, `key`, `ca`, `expires` |
| `kv/incognia/database` | Credenciales de bases de datos | JSON con campos: `host`, `port`, `username`, `password`, `database` |
| `kv/incognia/kubernetes` | Secretos de Kubernetes | JSON con campos: `kubeconfig`, `token`, `namespace` |

## Operaciones básicas

### Gestión de secretos

```bash
# List the secrets under a path
vault kv list kv/incognia/

# Create or update a secret: sensitive fields come from standard input (field=-)
# or from a file (field=@file), never from the command line, which stays in the
# shell history and in the process list
vault kv put kv/incognia/passwords/myapp username="admin" expires="2027-12-31T23:59:59Z" password=-

# Read a secret (table)
vault kv get kv/incognia/passwords/myapp

# Read a secret (JSON)
vault kv get -format=json kv/incognia/passwords/myapp

# Soft-delete specific versions
vault kv delete -versions=1,2 kv/incognia/passwords/myapp

# Destroy a version permanently
vault kv destroy -versions=1 kv/incognia/passwords/myapp

# Undo a soft delete
vault kv undelete -versions=1 kv/incognia/passwords/myapp
```

### Versionado de secretos

```bash
# Show the version history
vault kv metadata get kv/incognia/passwords/myapp

# Read a specific version
vault kv get -version=2 kv/incognia/passwords/myapp

# Set the maximum number of versions kept
vault kv metadata put -max-versions=5 kv/incognia/passwords/myapp
```

## Procesamiento de claves SSH

### Descarga y formato de claves SSH

Las claves almacenadas en `kv/incognia/ssh` se extraen campo por campo con `-field`, que entrega el valor sin comillas ni JSON. Usa un nombre de archivo propio (no `id_rsa`) para no sobrescribir una llave existente.

```bash
# Extract the private key: create the file with mode 600 before writing to it
(umask 077 && vault kv get -field=private_key kv/incognia/ssh/mykey > ~/.ssh/mykey)

# Extract the public key
vault kv get -field=public_key kv/incognia/ssh/mykey > ~/.ssh/mykey.pub
chmod 644 ~/.ssh/mykey.pub
```

### Validación de claves SSH

```bash
# Check that the private key parses
ssh-keygen -y -f ~/.ssh/mykey > /dev/null && echo "Private key is valid" || echo "Private key is invalid"

# Check that the private and public halves match (the comment field may differ)
diff <(ssh-keygen -y -f ~/.ssh/mykey | cut -d' ' -f1,2) <(cut -d' ' -f1,2 ~/.ssh/mykey.pub)
```

## Gestión de *tokens* y credenciales

### *Tokens* de API

```bash
# Store an API token: the token itself is read from standard input
vault kv put kv/incognia/tokens/github \
  service="GitHub API" \
  expires="2027-12-31T23:59:59Z" \
  scope="repo,admin:org" \
  token=-

# Read the token for a script
GITHUB_TOKEN=$(vault kv get -field=token kv/incognia/tokens/github)
export GITHUB_TOKEN
```

### Credenciales de base de datos

```bash
# Store PostgreSQL credentials: the password is read from standard input
vault kv put kv/incognia/database/postgresql \
  host="postgres.example.com" \
  port="5432" \
  username="dbadmin" \
  database="production" \
  password=-

# Read the credentials for a connection
DB_HOST=$(vault kv get -field=host kv/incognia/database/postgresql)
DB_USER=$(vault kv get -field=username kv/incognia/database/postgresql)
DB_PASS=$(vault kv get -field=password kv/incognia/database/postgresql)
```

## Integración con Kubernetes

### Configuración de *kubeconfig*

```bash
# Store a kubeconfig straight from its file (works the same on GNU and BSD, no base64)
vault kv put kv/incognia/kubernetes/cluster1 \
  namespace="production" \
  context="cluster1-admin" \
  kubeconfig=@"$HOME/.kube/config"

# Restore it with mode 600
(umask 077 && vault kv get -field=kubeconfig kv/incognia/kubernetes/cluster1 > ~/.kube/config)
```

## Buenas prácticas de seguridad

### Gestión de *tokens*

1. **Rotación regular**: rotar los *tokens* cada 30 a 90 días
2. **Principio de menor privilegio**: otorgar solo los permisos mínimos necesarios
3. **Auditoría**: revisar con regularidad el acceso a secretos

```bash
# Create a token with a short time to live
vault token create -ttl=24h -display-name="temp-access"

# Check what the current token can do on a path
vault token capabilities kv/incognia/passwords/myapp
```

### Políticas de acceso

```bash
# Show the policies of the current token
vault token lookup -format=json | jq -r '.data.policies[]'

# Read one policy
vault policy read incognia-dev
```

## Automatización y *scripting*

### *Scripts* de respaldo

```bash
#!/usr/bin/env bash
# backup-vault-secrets.sh: back up one level of secrets under kv/incognia/<area>.
# The copies hold secrets in clear text: keep the folder at mode 700 and encrypt
# it before it leaves the machine (see BACKUPS.md, "Cifrado y copia externa").
set -euo pipefail

AREA="${1:?usage: backup-vault-secrets.sh <area, e.g. tokens>}"
BACKUP_DIR="backups/manual/$(TZ=CST6 date +%Y-%m-%d)/vault_${AREA}_$(TZ=CST6 date +%Y-%m-%dT%H-%M-%S)"
(umask 077 && mkdir -p "$BACKUP_DIR")

vault kv list -format=json "kv/incognia/$AREA/" | jq -r '.[]' | grep -v '/$' | while IFS= read -r name; do
    (umask 077 && vault kv get -format=json "kv/incognia/$AREA/$name" > "$BACKUP_DIR/$name.json")
done

echo "Backup written to: $BACKUP_DIR"
```

### Validación de secretos

```bash
#!/usr/bin/env bash
# validate-secrets.sh: check that the critical secrets exist
CRITICAL_SECRETS=(
    "kv/incognia/database/postgresql"
    "kv/incognia/ssh/admin"
    "kv/incognia/tokens/github"
)

for secret in "${CRITICAL_SECRETS[@]}"; do
    if vault kv get "$secret" >/dev/null 2>&1; then
        echo "OK       $secret"
    else
        echo "MISSING  $secret"
        exit 1
    fi
done
```

## Monitoreo y auditoría

### Comandos de diagnóstico

```bash
# Server status
vault status

# Current token
vault token lookup

# List the secrets engines
vault secrets list

# List the audit devices (needs admin permissions)
vault audit list
```

### Métricas y uso

```bash
# Metadata of one secret (creation, last update, versions)
vault kv metadata get kv/incognia/tokens/github

# Last update of every secret in one area
vault kv list -format=json kv/incognia/tokens/ | jq -r '.[]' | grep -v '/$' | \
  while IFS= read -r secret; do
    echo "$secret: $(vault kv metadata get -format=json "kv/incognia/tokens/$secret" | jq -r '.data.updated_time')"
  done
```

## Resolución de problemas comunes

### Errores de autenticación

```bash
# Expired token
vault token renew || vault login -method=userpass username=incognia

# Check connectivity (no -k: a certificate error is a finding, not something to skip)
curl -sS "$VAULT_ADDR/v1/sys/health"
```

### Problemas de permisos

```bash
# Policies of the current token
vault token lookup -format=json | jq '.data.policies'

# What the current token can do on a path (read, list, create, update, delete or deny)
vault token capabilities kv/data/incognia/test
```

---

*Elaborado por Rodrigo Álvarez (@incognia)*
