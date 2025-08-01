# Glosario técnico para proyectos de Rodrigo Álvarez

Este glosario recoge términos clave utilizados en los documentos de reglas y filosofía de desarrollo para proyectos personales y laborales. Su propósito es reforzar la coherencia y claridad en el uso de conceptos dentro del entorno profesional de Rodrigo Álvarez y su comunidad.

---

**Átomo / Atomicidad**
: principio por el cual cada *commit* o contribución debe tener un solo propósito y ser autosuficiente, de manera que pueda ser aislada, comprendida y revertida sin afectar otros cambios.

**Argo CD**
: herramienta de *GitOps* para la gestión de despliegue continuo en clústeres Kubernetes. Automatiza la sincronización de la configuración declarativa del repositorio con el estado real del clúster.

**Bare-metal** (en *bare-metal*)
: infraestructura física directa, sin virtualización; comúnmente referido a servidores dedicados que no están bajo una capa de hipervisor.

**CI/CD** (*Integración Continua / Entrega Continua*)
: prácticas y herramientas para automatizar el ciclo de integración y entrega de software. Incluye pruebas, compilación, y despliegue automáticos de código en diversos entornos.

**ChangeLog**
: archivo donde se registra cronológicamente cada cambio relevante en el proyecto, asegurando trazabilidad y transparencia para todos los involucrados.

**Chart (Helm Chart)**
: plantillas y archivos de configuración usados con la herramienta Helm para describir, gestionar e instalar aplicaciones en Kubernetes.

**Cloud-init**
: sistema de inicialización automatizada para instancias de nube y máquinas virtuales, que personaliza la configuración en el arranque.

**Commit** (en *commit*)
: unidad básica de contribución o registro de cambio en un sistema de control de versiones. Debe escribirse en inglés internacional y describir de forma concisa el propósito de la modificación.

**Commons** (*commons*)
: recursos y conocimientos compartidos y mantenidos colectivamente por una comunidad, aquí se refiere especialmente al ecosistema de software libre.

**Containerd**
: motor de ejecución de contenedores utilizado por Kubernetes y otras plataformas para gestionar contenedores Linux de forma estándar y eficiente.

**Copyleft**
: filosofía y práctica de licenciamiento (por ejemplo, GPLv3) que requiere que las obras derivadas mantengan la misma licencia y derechos de libertad que la original.

**Declarativo / automatización declarativa**
: paradigma donde el estado deseado del sistema es descrito explícitamente, y las herramientas lo implementan automáticamente (ej. flujos GitOps, manifiestos YAML).

**DevOps**
: cultura y conjunto de prácticas que buscan integrar equipos de desarrollo y operaciones para entregar software de manera más ágil, estable y segura.

**Dualidad de contextos (personal/laboral)**
: distinción entre proyectos personales (licencia GPLv3, alias incognia) y laborales (licencia MIT, alias incogniadev), cada uno con reglas y atribución específicas.

**Emojis (en commits)**
: iconos gráficos que se desaconsejan totalmente en mensajes de *commit* y documentación profesional dentro de este sistema.

**Flujo GitOps**
: modelo donde todo el estado del entorno se describe y controla vía Git (versionamiento de infraestructura), de tal forma que los cambios a configuraciones se efectúan mediante *pull requests* y revisiones trazables.

**Helm**
: gestor de paquetes para Kubernetes que simplifica la implementación y actualización de aplicaciones complejas mediante plantillas llamadas *charts*.

**Istio**
: malla de servicios o *service mesh* para Kubernetes que proporciona enrutamiento, balanceo, seguridad, política y observabilidad avanzada para microservicios.

**Kubernetes**
: plataforma de orquestación de contenedores para automatizar el despliegue, gestión y escalado de aplicaciones en clústeres distribuidos.

**Manifiesto (manifest, manifiestos YAML)**
: archivo de configuración en formato YAML/JSON que describe el estado deseado de los recursos en Kubernetes, GitOps u otra herramienta declarativa.

**Mermaid**
: lenguaje de texto y herramienta para crear diagramas dinámicos y gráficos incrustados en archivos Markdown.

**OpenTelemetry**
: estándar para instrumentar, recopilar y exportar métricas, logs y trazas distribuidas en sistemas modernos.

**Pipeline** (*pipeline*)
: flujo automatizado de pasos para construir, probar o desplegar software; gestionado por herramientas de CI/CD.

**Políticas de red**
: reglas implementadas en Kubernetes, Istio u otros sistemas para controlar el tráfico entre aplicaciones y evitar accesos no autorizados.

**Proxmox VE**
: plataforma de virtualización de código abierto basada en KVM y LXC, usada para desplegar infraestructuras privadas y clústeres Kubernetes *bare-metal*.

**Promad Business Solutions**
: entidad laboral asociada a proyectos bajo licencia MIT y el alias profesional incogniadev.

**RBAC (Control de Acceso Basado en Roles)**
: mecanismo de seguridad que restringe el acceso a recursos en Kubernetes y aplicaciones según los roles asignados a usuarios/grupos.

**Service mesh (malla de servicios)**
: arquitectura que introduce una capa de red dedicada entre microservicios para gestionar tráfico, métricas y seguridad sin modificar los servicios originales.

**Trazabilidad**
: capacidad de rastrear el origen, motivo y responsable de cada cambio realizado en el código, configuraciones y documentación.

**YAML**
: lenguaje de serialización de datos ampliamente usado para archivos de configuración, especialmente en DevOps y Kubernetes.

---

*Elaborado por Rodrigo Álvarez (@incognia)*

**Para términos lingüísticos, consulta también [`~/rules/LINGUISTICS.md`](./LINGUISTICS.md)**

