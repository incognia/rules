# Reglas y filosofía profesional de un ingeniero DevOps

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)
[![Spanish](https://img.shields.io/badge/Language-Spanish%20(MX)-green.svg)](https://es.wikipedia.org/wiki/Espa%C3%B1ol_mexicano)

Este repositorio contiene las reglas, estándares y filosofía que guían el trabajo técnico y la colaboración en los proyectos de Rodrigo Álvarez.

## Filosofía principal

Un manifiesto contra tres males endémicos en tecnología latinoamericana:
- **Mercenazgo:** trabajos mediocres sin compromiso real
- **Egoísmo técnico:** acaparar conocimiento para crear dependencia
- **Falta de identidad:** complejos culturales que degradan la calidad

## Documentos incluidos

- **[PHILOSOPHY.md](./PHILOSOPHY.md)** - filosofía principal y manifiesto de desarrollo
- **[DEVOPS.md](./DEVOPS.md)** - perfil profesional y contexto técnico
- **[ATTRIBUTION.md](./ATTRIBUTION.md)** - reglas de atribución personal
- **[COMMITTING.md](./COMMITTING.md)** - reglas para mensajes de *commit* y gestión de cambios
- **[LICENSING.md](./LICENSING.md)** - reglas de licenciamiento para proyectos
- **[LINGUISTICS.md](./LINGUISTICS.md)** - reglas lingüísticas de español mexicano como referente
- **[STYLING.md](./STYLING.md)** - reglas de estilo para documentos Markdown (proyectos laborales)
- **[BACKUPS.md](./BACKUPS.md)** - políticas de respaldos y operaciones destructivas
- **[GLOSSARY.md](./GLOSSARY.md)** - glosario técnico de términos empleados
- **[CHANGELOG.md](./CHANGELOG.md)** - historial de cambios del proyecto

## Especialización técnica

- ingeniería DevOps con enfoque en Kubernetes nativo
- plataformas *bare-metal* sobre Proxmox VE
- GitOps y automatización declarativa
- observabilidad y mallas de servicios
- seguridad en entornos distribuidos

## Flujo de decisión para aplicación de reglas

La mayoría de las reglas en este repositorio tienen una **dualidad de contextos** (personal vs laboral). El flujo de decisión para determinar qué reglas aplicar es el siguiente:

### 1. Identificación del contexto del proyecto

- 💼 **Contexto laboral**: proyectos desarrollados para o bajo contrato con **Promad Business Solutions**
- 📺 **Contexto personal**: proyectos independientes, experimentales o de desarrollo personal

### 2. Aplicación de reglas por contexto

| Aspecto | Personal (`@incognia`) | Laboral (`@incogniadev`) |
|---------|------------------------|---------------------------|
| **Licenciamiento** | GPLv3 (copyleft) | MIT (permisiva) |
| **Autoría** | Rodrigo Álvarez (@incognia) | Rodrigo Álvarez (@incogniadev) |
| **Email** | incognia@gmail.com | ralvarez@promad.com.mx |
| **SSH Key** | ~/.ssh/id_ed25519 | ~/.ssh/promad_ed25519 |
| **Estilo de documentos** | No definido aún | STYLING.md aplicable |
| **Idioma documentación** | Español mexicano | Español mexicano |
| **Idioma código/commits** | Inglés internacional | Inglés internacional |

### 3. Reglas universales (aplican a ambos contextos)

- **LINGUISTICS.md**: español mexicano como estándar cultural
- **COMMITTING.md**: Conventional Commits en inglés
- **PHILOSOPHY.md**: principios generales de trabajo
- **BACKUPS.md**: políticas de respaldos y operaciones destructivas
- **GLOSSARY.md**: términos técnicos estandarizados
- **GIT.md**: configuración inicial de repositorios

### 4. Reglas de uso dual (diferentes aplicaciones según contexto)

- **LICENSING.md**: define qué licencia usar según el contexto (personal: GPLv3, laboral: MIT)
- **DEVOPS.md**: perfil profesional adaptado a cada entorno

### 5. Reglas de uso exclusivamente personal

- **ATTRIBUTION.md**: atribución personal en documentos/scripts individuales

### 6. Reglas de uso exclusivamente laboral

- **STYLING.md**: reglas de estilo para documentos Markdown corporativos

## Uso

Estos documentos sirven como referencia para mantener consistencia en:
- metodologías de trabajo técnico
- estándares de infraestructura y documentación
- políticas de licenciamiento
- convenciones lingüísticas y culturales
- aplicación correcta de reglas según el contexto del proyecto

---

*Este proyecto fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
