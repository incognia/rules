# Glosario técnico para proyectos de Rodrigo Álvarez

Este glosario recoge términos clave utilizados en los documentos de reglas y filosofía de desarrollo para proyectos personales y laborales. Su propósito es reforzar la coherencia y claridad en el uso de conceptos dentro del entorno profesional de Rodrigo Álvarez y su comunidad.

---

**Átomo / Atomicidad**
: Principio por el cual cada *commit* o contribución debe tener un solo propósito y ser autosuficiente, de manera que pueda ser aislada, comprendida y revertida sin afectar otros cambios.

**Argo CD**
: Herramienta de *GitOps* para la gestión de despliegue continuo en clústeres Kubernetes. Automatiza la sincronización de la configuración declarativa del repositorio con el estado real del clúster.

**Bare-metal** (en *bare-metal*)
: Infraestructura física directa, sin virtualización; comúnmente referido a servidores dedicados que no están bajo una capa de hipervisor.

**CI/CD** (*Integración Continua / Entrega Continua*)
: Prácticas y herramientas para automatizar el ciclo de integración y entrega de software. Incluye pruebas, compilación, y despliegue automáticos de código en diversos entornos.

**ChangeLog**
: Archivo donde se registra cronológicamente cada cambio relevante en el proyecto, asegurando trazabilidad y transparencia para todos los involucrados.

**Chart (Helm Chart)**
: Plantillas y archivos de configuración usados con la herramienta Helm para describir, gestionar e instalar aplicaciones en Kubernetes.

**Cloud-init**
: Sistema de inicialización automatizada para instancias de nube y máquinas virtuales, que personaliza la configuración en el arranque.

**Commit** (en *commit*)
: Unidad básica de contribución o registro de cambio en un sistema de control de versiones. Debe escribirse en inglés internacional y describir de forma concisa el propósito de la modificación.

**Commons** (*commons*)
: Recursos y conocimientos compartidos y mantenidos colectivamente por una comunidad, aquí se refiere especialmente al ecosistema de software libre.

**Containerd**
: Motor de ejecución de contenedores utilizado por Kubernetes y otras plataformas para gestionar contenedores Linux de forma estándar y eficiente.

**Copyleft**
: Filosofía y práctica de licenciamiento (por ejemplo, GPLv3) que requiere que las obras derivadas mantengan la misma licencia y derechos de libertad que la original.

**Declarativo / automatización declarativa**
: Paradigma donde el estado deseado del sistema es descrito explícitamente, y las herramientas lo implementan automáticamente (ej. flujos GitOps, manifiestos YAML).

**DevOps**
: Cultura y conjunto de prácticas que buscan integrar equipos de desarrollo y operaciones para entregar software de manera más ágil, estable y segura.

**Dualidad de contextos (personal/laboral)**
: Distinción entre proyectos personales (licencia GPLv3, alias incognia) y laborales (licencia MIT, alias incogniadev), cada uno con reglas y atribución específicas.

**Emojis (en commits)**
: Iconos gráficos que se desaconsejan totalmente en mensajes de *commit* y documentación profesional dentro de este sistema.

**Flujo GitOps**
: Modelo donde todo el estado del entorno se describe y controla vía Git (versionamiento de infraestructura), de tal forma que los cambios a configuraciones se efectúan mediante *pull requests* y revisiones trazables.

**Helm**
: Gestor de paquetes para Kubernetes que simplifica la implementación y actualización de aplicaciones complejas mediante plantillas llamadas *charts*.

**Istio**
: Malla de servicios o *service mesh* para Kubernetes que proporciona enrutamiento, balanceo, seguridad, política y observabilidad avanzada para microservicios.

**Kubernetes**
: Plataforma de orquestación de contenedores para automatizar el despliegue, gestión y escalado de aplicaciones en clústeres distribuidos.

**Manifiesto (manifest, manifiestos YAML)**
: Archivo de configuración en formato YAML/JSON que describe el estado deseado de los recursos en Kubernetes, GitOps u otra herramienta declarativa.

**Mermaid**
: Lenguaje de texto y herramienta para crear diagramas dinámicos y gráficos incrustados en archivos Markdown.

**OpenTelemetry**
: Estándar para instrumentar, recopilar y exportar métricas, logs y trazas distribuidas en sistemas modernos.

**Pipeline** (*pipeline*)
: Flujo automatizado de pasos para construir, probar o desplegar software; gestionado por herramientas de CI/CD.

**Políticas de red**
: Reglas implementadas en Kubernetes, Istio u otros sistemas para controlar el tráfico entre aplicaciones y evitar accesos no autorizados.

**Proxmox VE**
: Plataforma de virtualización de código abierto basada en KVM y LXC, usada para desplegar infraestructuras privadas y clústeres Kubernetes *bare-metal*.

**Promad Business Solutions**
: Entidad laboral asociada a proyectos bajo licencia MIT y el alias profesional incogniadev.

**RBAC (Control de Acceso Basado en Roles)**
: Mecanismo de seguridad que restringe el acceso a recursos en Kubernetes y aplicaciones según los roles asignados a usuarios/grupos.

**Service mesh (malla de servicios)**
: Arquitectura que introduce una capa de red dedicada entre microservicios para gestionar tráfico, métricas y seguridad sin modificar los servicios originales.

**Trazabilidad**
: Capacidad de rastrear el origen, motivo y responsable de cada cambio realizado en el código, configuraciones y documentación.

**YAML**
: Lenguaje de serialización de datos ampliamente usado para archivos de configuración, especialmente en DevOps y Kubernetes.

---

*Este documento fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*

**Para términos lingüísticos, consulta también [`~/rules/LINGUISTICS.md`](./LINGUISTICS.md)**

