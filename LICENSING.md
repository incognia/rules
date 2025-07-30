# Reglas de licenciamiento de proyectos

## 1. Introducción

Este documento define la política de licenciamiento a aplicar según el tipo y contexto de cada proyecto, con el fin de asegurar la coherencia y el cumplimiento legal y filosófico.

## 2. Tipos de proyectos y licencias aplicables

### 2.1. Proyectos laborales

- **Licencia:** MIT
- **Justificación:** se utiliza por su naturaleza permisiva y su amplia compatibilidad en el ecosistema de software, lo que facilita la integración y el uso comercial.

### 2.2. Proyectos personales (software)

- **Licencia:** GNU General Public License v3 (GPLv3)
- **Justificación:** se elige para garantizar que las contribuciones y derivados del software permanezcan libres y abiertos, fomentando un ecosistema de colaboración bajo los principios del *copyleft*.

### 2.3. Proyectos de diseño de hardware

- **Licencia:** CERN Open Hardware Licence v2 (Permissive)
- **Justificación:** esta licencia es un estándar en la comunidad de hardware libre y asegura que los diseños puedan ser estudiados, modificados y distribuidos libremente.

### 2.4. Proyectos de documentación

- **Licencia:** GNU Lesser General Public License v3 (LGPLv3)
- **Justificación:** permite que la documentación sea libremente utilizada y mejorada, pudiendo ser enlazada desde software con otras licencias.
- **Alternativa:** para documentación general no ligada a software, considerar Creative Commons.

### 2.5. Proyectos creativos

- **Licencia:** Creative Commons Atribución 4.0 Internacional (CC BY 4.0)
- **Justificación:** facilita la máxima difusión y reutilización de la obra, requiriendo únicamente la atribución al autor original. Otras variantes de CC pueden ser consideradas según las necesidades específicas del proyecto.

### 2.6. Proyectos privados o para clientes

- **Licencia:** a convenir
- **Justificación:** las condiciones se establecerán mediante un acuerdo o contrato específico con el cliente, definiendo los derechos de uso, distribución y modificación según los requerimientos del proyecto.

## 3. Ejemplos de aplicación

A continuación, se muestran ejemplos de cómo incluir la información de licenciamiento y autoría en diferentes tipos de archivos, utilizando la información definida en el documento de autoría.

### 3.1. Pie de página en Markdown (README.md)

#### Proyecto laboral

---

*Este proyecto fue desarrollado por Rodrigo Álvarez para Promad Business Solutions y se distribuye bajo la licencia MIT. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera (@incogniadev).*

#### Proyecto personal

---

*Este proyecto fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*

### 3.2. Encabezado en script de Bash (.sh)

#### Proyecto laboral

```bash
#!/bin/bash
#
# Script:         k8s-cluster-bootstrap.sh
# Descripción:    Automatiza el aprovisionamiento de clústeres Kubernetes en Proxmox VE.
# Autor:          Rodrigo Álvarez <ralvarez@promad.com.mx>
# Fecha:          2025-07-30
# Licencia:       MIT License
#
# Copyright (c) 2025, Promad Business Solutions
#
# Se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia
# de este software y de los archivos de documentación asociados (el "Software"), para tratar
# en el Software sin restricción, incluyendo sin limitación los derechos
# para usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender
# copias del Software, y para permitir a las personas a las que se les proporcione el Software
# hacerlo, sujeto a las siguientes condiciones:
#
# El aviso de copyright anterior y este aviso de permiso se incluirán en todas
# las copias o porciones sustanciales del Software.

# ... resto del código del script ...
```

#### Proyecto personal

```bash
#!/bin/bash
#
# Script:         istio-observability-stack.sh
# Descripción:    Despliega stack de observabilidad con Prometheus, Grafana y Jaeger en Istio.
# Autor:          Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Fecha:          2025-07-30
# Licencia:       GNU General Public License v3.0 (GPLv3)
#
# Copyright (c) 2025 Rodrigo Ernesto Álvarez Aguilera
#
# Este programa es software libre: usted puede redistribuirlo y/o modificarlo
# bajo los términos de la Licencia Pública General de GNU publicada por
# la Free Software Foundation, ya sea la versión 3 de la Licencia, o
# (a su elección) cualquier versión posterior.
#
# Este programa se distribuye con la esperanza de que sea útil, pero
# SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita de
# COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Consulte la
# Licencia Pública General de GNU para más detalles.
#
# Debería haber recibido una copia de la Licencia Pública General de GNU
# junto con este programa. Si no es así, consulte <https://www.gnu.org/licenses/>.

# ... resto del código del script ...
```

### 3.3. Encabezado en script de Python (.py)

#### Proyecto laboral

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# File:         database_backup.py
# Description:  Automated database backup tool for production environments.
# Author:       Rodrigo Álvarez <ralvarez@promad.com.mx>
# Date:         2025-07-30
# License:      MIT License
#
# Copyright (c) 2025, Promad Business Solutions
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

"""
Automated database backup tool for Promad Business Solutions.

This module provides functionality to create automated backups of
PostgreSQL and MySQL databases with configurable retention policies.
"""

# ... resto del código del script ...
```

#### Proyecto personal

```python
# -*- coding: utf-8 -*-
#
# autor:    Rodrigo Álvarez (incognia)
# correo:   incognia@gmail.com
# fecha:    2025-07-30
# licencia: GNU General Public License v3.0 (GPLv3)
#
# Copyright (c) 2025 Rodrigo Ernesto Álvarez Aguilera
#
# Este programa es software libre: usted puede redistribuirlo y/o modificarlo
# bajo los términos de la Licencia Pública General de GNU publicada por
# la Free Software Foundation, ya sea la versión 3 de la Licencia, o
# (a su elección) cualquier versión posterior.
#
# Este programa se distribuye con la esperanza de que sea útil, pero
# SIN NINGUNA GARANTÍA; ni siquiera la garantía implícita de
# COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Consulte la
# Licencia Pública General de GNU para más detalles.
#
# Debería haber recibido una copia de la Licencia Pública General de GNU
# junto con este programa. Si no es así, consulte <https://www.gnu.org/licenses/>.

"""
Módulo de ejemplo para demostrar la inclusión de la licencia GPLv3.
"""

# ... resto del código del script ...
```

### 3.4. Manifiestos de Kubernetes, GitOps y Helm

#### Proyecto laboral - Argo CD Application

```yaml
# production-app.yaml
# Argo CD Application para desplegar la aplicación 'webapp-backend' en producción
#
# Author: Rodrigo Álvarez <ralvarez@promad.com.mx>
# License: MIT
# Company: Promad Business Solutions
#
# Copyright (c) 2025, Promad Business Solutions

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: webapp-backend-prod
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: production-apps
  source:
    repoURL: 'https://git.promad.com.mx/devops/webapp-backend.git'
    targetRevision: HEAD
    path: helm/
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: prod-services
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

#### Proyecto personal - Helm Chart

```yaml
# Chart.yaml
# Helm chart para stack de observabilidad con OpenTelemetry
#
# Autor: Rodrigo Álvarez (incognia)
# Licencia: GPL-3.0-or-later
# Repositorio: https://github.com/incognia/observability-stack
#
# Copyright (C) 2025 Rodrigo Ernesto Álvarez Aguilera

apiVersion: v2
name: observability-stack
description: |
  Stack completo de observabilidad con Prometheus, Grafana, 
  OpenTelemetry y Jaeger para clústeres Kubernetes.
  
  Este chart está bajo GPL-3.0: software libre para la comunidad.

type: application
version: 0.1.0
appVersion: "1.0.0"
maintainers:
  - name: Rodrigo Álvarez
    email: incognia@gmail.com
    url: https://github.com/incognia
```

## 4. Buenas prácticas

### 4.1. Archivos LICENSE requeridos

- **Proyectos públicos:** incluir siempre un archivo `LICENSE` en la raíz del repositorio con el texto completo de la licencia elegida.
- **Repositorios Git:** asegurar que el archivo `LICENSE` esté versionado y disponible desde el primer *commit*.

### 4.2. Encabezados en archivos fuente

- **Consistencia:** usar el mismo formato de encabezado en todos los archivos del proyecto.
- **Información mínima:** autor, fecha, licencia y *copyright*.
- **Contacto:** incluir correo electrónico o usuario de GitHub/GitLab según el contexto (personal vs laboral).

### 4.3. Documentación

- **README.md:** mencionar explícitamente la licencia utilizada y hacer referencia al archivo `LICENSE`.
- **CHANGELOG.md:** no requiere información de licencia, pero sí debe mantener la atribución de autoría.

### 4.4. Compatibilidad de licencias

- **Proyectos laborales (MIT):** compatible con la mayoría de licencias de código abierto y propietario.
- **Proyectos personales (GPLv3):** requiere que todos los trabajos derivados mantengan la misma licencia (*copyleft*).
- **Dependencias externas:** verificar compatibilidad antes de integrar bibliotecas de terceros.

### 4.5. Atribución en proyectos colaborativos

- **Múltiples autores:** listar todos los contribuyentes en un archivo `AUTHORS` o `CONTRIBUTORS`.
- **Contribuciones menores:** mantener la atribución original, añadir contribuyentes en comentarios o documentación.

---

*Este documento fue desarrollado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2025, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*
