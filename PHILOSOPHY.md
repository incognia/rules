# Filosofía de un pinche prieto que a veces *codea* pero siempre se rifa

*Última modificación: 14 de octubre de 2026, 00:03 (CST)*

> «El desarrollo tecnológico y los descubrimientos científicos no pueden considerarse progreso si no están al alcance de todos.»
>
> —Rodrigo Álvarez

Los entornos de tecnología en Latinoamérica sufren de tres males endémicos que este manifiesto combate frontalmente:

- **Mercenazgo:** profesionales que entregan trabajos mediocres porque solo les mueve la lana, sin compromiso real con la excelencia o con el cliente.
- **Egoísmo técnico:** acaparar conocimiento y herramientas para crear dependencia artificial, obstaculizando el crecimiento de otros por puro interés económico.
- **Falta de identidad:** el prieto acomplejado que habla un inglés culero, redacta con las nalgas y bastardiza su propio español en un intento desesperado por sentirse gringo.

Contra estos tres males, aquí está la respuesta: trabajo honesto, compartir el conocimiento y la satisfacción que viene de hacer las cosas bien hechas, sin complejos y sin pendejadas.

Este manifiesto no es solo para rifármela en DevOps desde el escritorio —donde me llaman «Agüelo» por veterano, aunque sigo tan actualizado como el último *commit*— sino para aplicar esa misma filosofía en el aula, donde dicen que parezco Hagrid por corpulento y barbón. Porque sí, dominar Kubernetes está chido, pero lo que de verdad está con madre es compartir el conocimiento técnico. No venimos a ser mercenarios del código guardando secretos: venimos a enseñar con todo para que todos le sepan a las herramientas que realmente valen la pena.

## 1. Identidad profesional coherente

Esta dualidad entre ser «Agüelo» y «Hagrid» no es casualidad: refleja una identidad profesional que opera en dos contextos complementarios, cada uno con su propio ecosistema pero unidos por los mismos principios éticos.

### 1.1. Especialización técnica

Mi trabajo se centra en **ingeniería DevOps**, con enfoque en plataformas Kubernetes nativas y observabilidad avanzada. Esta lista es la fuente canónica del perfil técnico: README, AGENTS y ATTRIBUTION la enlazan, y [CORPORATE.md](./rulesets/CORPORATE.md) la amplía con el *stack* corporativo detallado.

- **Kubernetes sobre Proxmox *bare-metal*:** aprovisionamiento con kubeadm, containerd y cloud-init
- **GitOps y automatización:** flujos con Argo CD, Helm *charts* y manifiestos versionados
- **Malla de servicios y redes:** Istio, Envoy, Cilium, MetalLB, configuración de *bridges* y VLAN
- **Observabilidad y trazabilidad:** Prometheus, Grafana, OpenTelemetry, Fluentd, Elasticsearch y trazas distribuidas
- **CI/CD empresarial:** Jenkins, GitLab CI con integración GitOps
- **Seguridad en mallas de servicios:** mTLS, RBAC, políticas de red

### 1.2. Contextos de aplicación

Esta especialización técnica se aplica en dos entornos:

- **Corporativo (`incogniadev`):** proyectos para Kabat One con licenciamiento MIT
- **Personal y educativo (`incognia`):** proyectos bajo GPLv3 y metodologías pedagógicas que democratizan el acceso a herramientas profesionales

En ambos casos, las metodologías DevOps sirven tanto para infraestructura de producción como para crear entornos de aprendizaje reproducibles mediante Docker Compose y automatización.

## 2. Cultura lingüística como referente

### 2.1. Español mexicano como estándar

Toda la documentación se redacta en **español mexicano** como referente cultural, evitando:

- Calcos del inglés que no suenan naturales
- Regionalismos de otras variantes del español
- Construcciones impersonales en tercera persona

### 2.2. Bilingüismo técnico

El código, los comentarios en código y los mensajes de *commit* se redactan en **inglés internacional (UK)** para garantizar la interoperabilidad global, mientras que la documentación usa español mexicano para preservar la identidad cultural. La regla detallada vive en [LINGUISTICS.md](./rulesets/LINGUISTICS.md#aplicación).

**Documentación accesible:** aunque tengo un nivel de inglés C1, mis colegas manejan niveles A2 y B1. Para cumplir con los principios de **transparencia y accesibilidad**, todo lo que explica el *porqué* de un cambio (README, guías, CHANGELOG de repositorios en español) va en español mexicano, para que todo el equipo pueda entender y mantener el código sin barreras lingüísticas; los comentarios en código se mantienen breves y en inglés.

**Mensajes de *commit*:** se mantienen en inglés por una razón práctica adicional: los PM y gerentes rara vez leen la documentación técnica extendida. Su interacción con el desarrollo técnico se limita a revisar algunos *commits* (si es que los leen) o simplemente contar la frecuencia en las gráficas de actividad. El inglés en los *commits* mantiene un estándar profesional en esas revisiones superficiales.

**Contexto educativo:** la mayoría de los estudiantes de primaria y secundaria en México, sin importar si vienen de escuelas públicas o privadas, no hablan fluidamente inglés. Somos vecinos muy cercanos de EE.UU. en términos geográficos, pero muy distantes en términos culturales. Esta realidad refuerza la importancia de enseñar en español mexicano: democratizar el conocimiento técnico significa hacerlo accesible en el idioma que realmente dominan nuestros estudiantes, no en el que creemos que deberían dominar.

## 3. Transparencia y trazabilidad

### 3.1. Historial de cambios claro

Cada modificación debe tener un propósito único y estar documentada de forma que permita:

- Entender el *qué* y el *porqué* de cada cambio
- Mantener atomicidad en las contribuciones
- Facilitar la revisión y el mantenimiento futuro

### 3.2. Documentación sincronizada

Actualizar el `CHANGELOG.md` **antes** de cada *commit*, manteniendo la sincronización entre la documentación y el código.

## 4. Licenciamiento ético y pragmático

### 4.1. Filosofía de licencias

- **Proyectos laborales:** MIT para facilitar la integración comercial.
- **Proyectos personales:** GPLv3 para preservar la libertad del software.
- **Hardware:** CERN OHL v2 para diseños abiertos.
- **Documentación:** LGPLv3 o Creative Commons según el contexto.
- **Proyectos privados:** negociación específica con cada cliente.

### 4.2. Responsabilidad social

Las licencias elegidas reflejan un compromiso con el ecosistema de software libre y el respeto por la propiedad intelectual, equilibrando la practicidad comercial con los principios éticos.

## 5. Calidad y consistencia

### 5.1. Estándares técnicos

- Adherencia a especificaciones reconocidas (*Conventional Commits*).
- Uso de herramientas estándar (Mermaid para diagramas).
- Consistencia en la estructura y el formato.

### 5.2. Atención al detalle

Los pequeños detalles manifiestan la excelencia:

- Capitalización correcta en títulos.
- Uso apropiado de comillas angulares en español.
- Cursiva para préstamos técnicos.
- Evitar emojis en contextos profesionales.

## 6. Evolución y adaptabilidad

### 6.1. Documentos vivos

Estas reglas y filosofías son documentos vivos que evolucionan con la experiencia y las necesidades cambiantes del trabajo técnico.

### 6.2. Aprendizaje continuo

La filosofía incorpora lecciones aprendidas y buenas prácticas emergentes, manteniendo un equilibrio entre la estabilidad y la innovación.

## 7. Compromiso con la comunidad

### 7.1. Contribución al ecosistema

Los proyectos personales bajo GPLv3 contribuyen al *commons* del software libre, mientras que los proyectos laborales bajo MIT facilitan la adopción amplia.

## Referencias

Los detalles específicos de esta filosofía están organizados en los *rulesets* del repositorio. La clasificación canónica por contexto (universales, de uso dual, exclusivamente personales y exclusivamente laborales) está en [README.md](./README.md#flujo-de-decisión-para-aplicación-de-reglas); no se duplica aquí para que no diverja.

*Este documento fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2026, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
