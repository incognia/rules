# Reglas de autoría y atribución personal

## 1. Propósito

Este documento establece cómo darme crédito y atribución en documentos individuales, scripts o archivos que no requieren un archivo LICENSE completo. Para proyectos con múltiples archivos que requieren licenciamiento formal, consulta **[LICENSING.md](./LICENSING.md)**.

## 2. Identidad del autor

### 2.1. Nombre completo
- **Nombre legal:** Rodrigo Ernesto Álvarez Aguilera

### 2.2. Nombres de uso común
- **Nombre abreviado:** Rodrigo Álvarez
- **Apellido principal para indexación:** Álvarez

### 2.3. Convención de nombres
- **Contexto hispanohablante:** se utilizan dos apellidos, siendo el paterno «Álvarez» y el materno «Aguilera».
- **Contexto técnico e internacional:** para garantizar una correcta atribución en sistemas que no manejan nombres compuestos, usar como apellido principal «Álvarez».
- **Alternativa sin caracteres especiales:** en sistemas que no soporten la `á`, utilizar la versión «Alvarez».

## 3. Especialización profesional

El rol de Rodrigo se centra en **ingeniería DevOps avanzada**, especializado en plataformas Kubernetes nativas y arquitecturas de observabilidad. Sus contribuciones principales abarcan:

- **Plataformas Kubernetes bare-metal:** construcción y operación de clústeres sobre Proxmox VE, aprovisionamiento con kubeadm y cloud-init.
- **GitOps y automatización declarativa:** implementación de flujos con Argo CD, gestión de Helm charts y manifiestos versionados.
- **Service mesh y networking avanzado:** configuración de Istio, Envoy, Cilium, MetalLB, bridges y VLANs.
- **Observabilidad y trazabilidad distribuida:** instrumentación con OpenTelemetry, Prometheus, Grafana, Fluentd y Elasticsearch.
- **CI/CD empresarial:** diseño de *pipelines* con Jenkins y GitLab CI integrados a flujos GitOps.
- **Seguridad en mallas de servicios:** implementación de mTLS, RBAC y políticas de red en entornos productivos.

## 4. Identificadores digitales

### 4.1. Personales
- **GitHub:** `incognia`
- **GitLab:** `incognia`
- **Correo electrónico:** `incognia@gmail.com`

### 4.2. Laborales (Promad Business Solutions)
- **GitHub:** `incogniadev`
- **GitLab:** `incogniadev`
- **Correo electrónico:** `ralvarez@promad.com.mx`

## 5. Atribución y menciones

### 5.1. Formatos sugeridos
- **Contribución personal:** «desarrollado por Rodrigo Álvarez (@incognia)»
- **Documentación técnica:** «documentado por Rodrigo Ernesto Álvarez Aguilera (GitHub: @incognia)»
- **Contribución laboral:** «este trabajo fue realizado por Rodrigo Álvarez en su calidad de Ingeniero DevOps para Promad Business Solutions (@incogniadev)»

### 5.2. Firma en commits de Git
- **Para proyectos personales:**
  ```bash
  git config user.name "Rodrigo Álvarez"
  git config user.email "incognia@gmail.com"
  ```
- **Para proyectos laborales (Promad):**
  ```bash
  git config user.name "Rodrigo Álvarez"
  git config user.email "ralvarez@promad.com.mx"
  ```

## 6. Licenciamiento y firma de contribuciones

### 6.1. Filosofía de licenciamiento
- **Proyectos profesionales/laborales:** la licencia a utilizar es **MIT**, por su permisividad y compatibilidad.
- **Proyectos personales:** el licenciamiento puede variar, pero la preferencia es por licencias de código abierto como MIT o Apache 2.0.

### 6.2. Firma de contribuciones (alias)
- **Contribuciones personales:** firmar bajo el alias `incognia`.
- **Contribuciones laborales o bajo contrato:** firmar bajo el alias `incogniadev`.
- **Requerimientos legales:** en encabezados de licencia o documentos legales que lo requieran, utilizar el nombre completo: `Rodrigo Ernesto Álvarez Aguilera`.

## 7. Estándares de codificación y documentación

### 7.1. Idioma
- **Mensajes de *commit* y código:** los mensajes de *commit* y los comentarios dentro del código deben estar en **inglés internacional**.
- **Documentación (README, CHANGELOG, etc.):** el idioma será **español mexicano**, a menos que el contexto del proyecto exija explícitamente el inglés. Los títulos y encabezados en español seguirán la capitalización de frase (solo la primera palabra en mayúscula).
- **Nombres de archivos y directorios:** siempre en **inglés internacional** para mantener la consistencia técnica.

### 7.2. Mensajes de *commit*
- **Convención:** seguir la convención de *Conventional Commits*.
- **Idioma:** redactar los mensajes en inglés.
- **Formato:** estructurarlos con un prefijo (`feat`, `fix`, `docs`, `refactor`, etc.).
- **Emojis:** no usar emojis.

### 7.3. Diagramas
Para la creación de diagramas en archivos Markdown, usar exclusivamente **Mermaid**.

---

*Este documento está diseñado para su uso en proyectos personales, detallando cómo dar atribución adecuada sin requerir un archivo de licencia completo. Para proyectos laborales o con múltiples scripts/documentos, consulta **[LICENSING.md](./LICENSING.md)**.

Este documento fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
