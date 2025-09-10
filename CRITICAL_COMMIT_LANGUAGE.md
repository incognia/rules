# ⚠️ REGLA CRÍTICA - IDIOMA DE COMMITS ⚠️

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

- **Fuente:** ~/cot/committing.md línea 15
- **Texto exacto:** "CRÍTICO: Mensaje de commit SIEMPRE en inglés internacional con Conventional Commits; documentación en español mexicano."

## Checkpoint obligatorio

**ANTES de ejecutar cualquier `git commit`:**

1. ⚠️ **PARAR** - Verificar idioma del mensaje
2. 🔍 **CONFIRMAR** - ¿Está en inglés?  
3. ✅ **PROCEDER** - Solo si está en inglés

## Distribución de idiomas

| Contexto | Idioma |
|----------|---------|
| **Mensajes de commit** | 🇺🇸 **INGLÉS** |
| CHANGELOG.md | 🇲🇽 Español mexicano |
| README.md | 🇲🇽 Español mexicano |
| Documentación | 🇲🇽 Español mexicano |
| Código/comentarios | 🇺🇸 Inglés |

## Error recurrente identificado

- **Problema:** Tendencia a escribir commits en español
- **Causa:** No verificar idioma antes de commit
- **Solución:** Esta regla de checkpoint obligatorio
