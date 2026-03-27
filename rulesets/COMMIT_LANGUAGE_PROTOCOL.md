# Protocolo crítico: idioma de commits en inglés

**PRIORIDAD MÁXIMA - NUNCA IGNORAR**

## Regla fundamental

**TODOS los mensajes de commit DEBEN estar en INGLÉS**

```bash
# ✅ CORRECTO
git commit -m "feat: add new functionality"
git commit -m "fix: resolve authentication issue" 
git commit -m "docs: update installation guide"

# ❌ INCORRECTO
git commit -m "feat: agregar nueva funcionalidad"
git commit -m "fix: resolver problema de autenticación"
git commit -m "docs: actualizar guía de instalación"
```

## Referencia

- **Fuente**: `~/cot/committing.md` línea 15
- **Texto exacto**: «CRÍTICO: Mensaje de commit SIEMPRE en inglés internacional con Conventional Commits; documentación en español mexicano.»

## Distribución de idiomas

| Contexto | Idioma |
|----------|--------|
| **Mensajes de commit** | 🇺🇸 **INGLÉS** |
| CHANGELOG.md | 🇲🇽 Español mexicano |
| README.md | 🇲🇽 Español mexicano |
| Documentación | 🇲🇽 Español mexicano |
| Código/comentarios | 🇺🇸 Inglés |

## Protocolo obligatorio para asistente

**Cada vez que se ejecute `~/cot/committing.md`, el asistente DEBE:**

### Paso 0: Checkpoint de idioma (ANTES de cualquier commit)

```
🔍 CHECKPOINT: Verificando idioma de commits...
📋 REGLA: Mensajes de commit en INGLÉS (~/cot/committing.md línea 15)
⚠️  CRÍTICO: NO proceder hasta confirmar idioma correcto
```

### Declaración obligatoria

**El asistente debe declarar explícitamente:**

> «⚠️ LANGUAGE CHECK: All commit messages must be in English per ~/cot/committing.md line 15»

### Verificación previa al commit

**Antes de cada `git commit -m "mensaje"`:**

1. ✅ **Mostrar el mensaje planeado**
2. ✅ **Confirmar que está en inglés**  
3. ✅ **Proceder con el commit**

### Ejemplo de aplicación correcta

```
🔍 CHECKPOINT: Verificando idioma de commits...
📋 REGLA: Mensajes de commit en INGLÉS

Commits planeados:
1. feat: integrate Loki and Promtail for centralized logging
2. docs: update README files with Loki integration details

✅ Ambos mensajes están en inglés - procediendo...
```

## Falla del protocolo

**Si el asistente comete error de idioma:**

1. 🛑 **DETENER** proceso inmediatamente
2. 🔄 **CORREGIR** con reset/amend si es necesario  
3. 📝 **DOCUMENTAR** el error para evitar recurrencia
4. ✅ **REPETIR** proceso con idioma correcto

## Error recurrente identificado

- **Problema**: Tendencia a escribir commits en español
- **Causa**: No verificar idioma antes de commit
- **Solución**: Este protocolo de checkpoint obligatorio