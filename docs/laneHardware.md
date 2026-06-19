## Hardware de Carril

El hardware de un carril de cobro se organiza en seis categorías según su función dentro del flujo de peaje.

---

### 1. Señalización de segmentos de altura — Lane-Use Control Signals

DMS (Dynamic Message Signs) o PMV (Paneles de Mensaje Variable). Puede haber *n* unidades sobre un mismo carril. Su función es indicar al usuario a distancia para que pueda decidir un cambio de carril:

| Señal | Propósito |
|---|---|
| Green Arrow / Steady Red X | Carril abierto o cerrado |
| Cash Signal | El carril acepta pago en efectivo |
| Antena Reading | El carril acepta TAG / telepeaje |

---

### 2. Señalización para el usuario — Lane Control Signals

Señales visibles al conductor cuando ya se encuentra en el carril:

- **Semáforo** — indica alto/siga.
- **Display de usuario** — muestra la tarifa a cobrar o un mensaje de bienvenida.

---

### 3. Equipo Controlador de Tránsito — Transit Equipment Controller (TCE)

El TCE concentra los dispositivos encargados de determinar la clasificación vehicular. Dentro de un carril, el TCE opera en dos etapas:

#### Preclasificación

Sensado que ocurre **antes** de que el vehículo se detenga en el punto de cobro. Los dispositivos de preclasificación alimentan una **fila virtual** con una clasificación preliminar del vehículo.

#### Posclasificación

Sensado que ocurre **después** del punto de cobro (o en el punto de salida). Los dispositivos de posclasificación calculan la **clasificación final** y dan salida a la fila vehicular virtual.

> Las permutaciones de qué dispositivos participan en cada etapa dependen de la lógica de negocio de cada plaza, pero ambas etapas sensan clasificación vehicular.

#### Dispositivos de clasificación

| Dispositivo | Principio de operación |
|---|---|
| Peanas fijas (goma) | Dry contact para sensar ejes |
| Cortinas fotoeléctricas | Clasificación por perfil del vehículo |
| LiDAR | Clasificación vehicular por nube de puntos |
| Sensores láser | Sustituto de peanas fijas para sensar ejes |
| Lazos magnéticos | Detectan presencia de masa metálica |
| IA por visión (cámaras) | Clasificación vehicular por imagen |

Estos dispositivos se concentran hacia **tarjetas de adquisición de datos (DAQ)** o **PLCs**, ya que generalmente se combinan varios para calcular la clasificación final.

#### Barreras de paso

Indican al conductor cuándo puede avanzar o debe detenerse. Según el modelo, se controlan por:

- Dry contact
- Protocolos industriales (ModBus, XMLRPC)

---

### 4. Equipo del operador — Operator Equipment

Hardware que utiliza directamente el cajero/operador de la caseta:

| Dispositivo | Función |
|---|---|
| Impresora de cobro | Emite el comprobante de pago al usuario |
| Pedal de emergencia | Permite al operador abrir la barrera manualmente en caso de emergencia |

---

### 5. Cámaras de video — Video & ANPR

| Cámara | Función |
|---|---|
| Cámara de carril | Capta la zona de la caseta de cobro (videovigilancia del tránsito) |
| Cámara de cabina | Muestra los movimientos del cajero receptor (videovigilancia operativa) |
| Cámara ANPR / lectora de placa | Reconocimiento automático de número de placa (Automatic Number Plate Recognition) |
| Cámara de balizaje | Fotografía la placa y la zona circundante del vehículo para evidencia complementaria |

---

### 6. Lectores RFID — FastTAG

| Tipo | Descripción |
|---|---|
| Fijo | Instalado en el pórtico de la caseta; recupera información de los tags presentes en una zona determinada |
| Portátil / Handheld | Usado cuando el ángulo del parabrisas (p. ej. tráilers con parabrisas >70°) impide la lectura del lector fijo |
