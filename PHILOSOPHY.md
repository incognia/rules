# Filosofía de un pinche prieto que a veces *codea* pero siempre se rifa

Los entornos de tecnología en Latinoamérica sufren de tres males endémicos que este manifiesto combate frontalmente:

- **Mercenazgo:** profesionales que entregan trabajos mediocres porque solo les mueve la lana, sin compromiso real con la excelencia o con el cliente.
- **Egoísmo técnico:** acaparar conocimiento y herramientas para crear dependencia artificial, obstaculizando el crecimiento de otros por puro interés económico.
- **Falta de identidad:** el prieto acomplejado que habla un inglés culero, redacta con las nalgas y bastardiza su propio español en un intento desesperado por sentirse gringo.

Contra estos tres males, aquí está la respuesta: trabajo honesto, compartir el conocimiento y la satisfacción que viene de hacer las cosas bien hechas, sin complejos y sin pendejadas.

Este manifiesto no es solo para rifármela en DevOps desde el escritorio —donde me llaman "Agüelo" por veterano, aunque sigo tan actualizado como el último *commit*— sino para aplicar esa misma filosofía en el aula, donde dicen que parezco Hagrid por corpulento y barbón. Porque sí, dominar Kubernetes está chido, pero lo que de verdad está con madre es compartir el conocimiento técnico. No venimos a ser mercenarios del código guardando secretos: venimos a enseñar con todo para que todos le sepan a las herramientas que realmente valen la pena.

## 1. Identidad profesional coherente

Esta dualidad entre ser "Agüelo" y "Hagrid" no es casualidad: refleja una identidad profesional que opera en dos contextos complementarios, cada uno con su propio ecosistema pero unidos por los mismos principios éticos.

### 1.1. Especialización técnica

Mi trabajo se centra en **ingeniería DevOps**, con enfoque en plataformas Kubernetes nativas y observabilidad avanzada:

- **Kubernetes sobre Proxmox *bare-metal*:** aprovisionamiento con kubeadm, containerd y cloud-init
- **GitOps y automatización:** flujos con Argo CD, Helm charts y manifiestos versionados
- **Malla de servicios y networking:** Istio, Envoy, Cilium, MetalLB, configuración de bridges/VLAN
- **Observabilidad y trazabilidad:** Prometheus, Grafana, OpenTelemetry, trazas distribuidas
- **CI/CD empresarial:** Jenkins, GitLab CI con integración GitOps
- **Seguridad en mallas de servicios:** mTLS, RBAC, políticas de red

### 1.2. Contextos de aplicación

Esta especialización técnica se aplica en dos entornos:

- **Corporativo (`incogniadev`):** proyectos para Promad Business Solutions con licenciamiento MIT
- **Personal y educativo (`incognia`):** proyectos bajo GPLv3 y metodologías pedagógicas que democratizan el acceso a herramientas profesionales

En ambos casos, las metodologías DevOps sirven tanto para infraestructura de producción como para crear entornos de aprendizaje reproducibles mediante Docker Compose y automatización.

## 2. Cultura lingüística como referente

### 2.1. Español mexicano como estándar

Toda la documentación se redacta en **español mexicano** como referente cultural, evitando:

- Calcos del inglés que no suenan naturales
- Regionalismos de otras variantes del español
- Construcciones impersonales en tercera persona

### 2.2. Bilingüismo técnico

El enfoque teórico establece que el código y los mensajes de *commit* se redacten en **inglés internacional** para garantizar la interoperabilidad global, mientras que la documentación utiliza español mexicano para preservar la identidad cultural.

Sin embargo, la realidad del trabajo en equipos mexicanos requiere una adaptación pragmática:

**Comentarios en código:** aunque tengo un nivel de inglés B2 próximo a C1, mis colegas manejan niveles A2 y B1. Para cumplir con los principios de **transparencia y accesibilidad**, los comentarios internos se redactan en español mexicano, garantizando que todo el equipo pueda entender y mantener el código sin barreras lingüísticas.

**Mensajes de *commit*:** se mantienen en inglés por una razón práctica adicional: los PM y gerentes rara vez leen la documentación técnica extendida. Su interacción con el desarrollo técnico se limita a revisar algunos *commits* (si es que los leen) o simplemente contar la frecuencia en las gráficas de actividad. El inglés en los *commits* mantiene un estándar profesional en esas revisiones superficiales.

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

La filosofía incorpora lecciones aprendidas y mejores prácticas emergentes, manteniendo un equilibrio entre la estabilidad y la innovación.

## 7. Compromiso con la comunidad

### 7.1. Contribución al ecosistema

Los proyectos personales bajo GPLv3 contribuyen al *commons* del software libre, mientras que los proyectos laborales bajo MIT facilitan la adopción amplia.

---

## Referencias

Los detalles específicos de implementación de esta filosofía se encuentran organizados en los siguientes documentos:

### Reglas universales (ambos contextos)
- **[LINGUISTICS.md](./LINGUISTICS.md)** - reglas lingüísticas de español mexicano como referente
- **[COMMITTING.md](./COMMITTING.md)** - reglas para mensajes de *commit* y gestión de cambios
- **[BACKUPS.md](./BACKUPS.md)** - políticas de respaldos y operaciones destructivas
- **[GIT.md](./GIT.md)** - configuración inicial de repositorios
- **[GLOSSARY.md](./GLOSSARY.md)** - glosario técnico de términos empleados

### Reglas de uso dual (aplicación diferenciada por contexto)
- **[LICENSING.md](./LICENSING.md)** - reglas de licenciamiento para proyectos
- **[CORPORATE.md](./CORPORATE.md)** - perfil profesional corporativo
- **[TEACHING.md](./TEACHING.md)** - perfil educativo y de divulgación científica

### Reglas de uso exclusivamente personal
- **[ATTRIBUTION.md](./ATTRIBUTION.md)** - reglas de atribución personal

### Reglas de uso exclusivamente laboral
- **[STYLING.md](./STYLING.md)** - reglas de estilo para documentos Markdown corporativos

---

*Este documento fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
