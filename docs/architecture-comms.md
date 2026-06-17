# Arquitectura de Comunicación

Decisión de diseño sobre los mecanismos de transporte y serialización entre los actores del sistema.

## Actores y capas

```
[Dispositivos / Botonera]
        │
        │  gRPC (preferido) / WebSocket / Serial / otro
        ▼
[Go Backend Core]
        │
        │  WebSocket + Protobuf
        ▼
[Angular Frontend]  ──── sesión 1 (cajero)
                    ──── sesión 2 (supervisor / tablet) [futuro]
```

---

## Capa 1 — Dispositivos → Backend

### Decisión

El mecanismo de transporte queda a elección del desarrollador del módulo de dispositivo. **gRPC es el protocolo preferido** cuando el dispositivo corre como proceso Go o servicio nativo.

### Justificación

- Cada dispositivo (impresora, antena/reader, barrera, semáforo, LiDAR, etc.) puede tener restricciones distintas de hardware y lenguaje.
- La arquitectura es extensible por diseño: un nuevo módulo solo necesita cumplir el contrato de mensajes con el core.
- gRPC aporta streaming bidireccional real, contratos fuertes via `.proto`, y código generado en Go sin overhead de browser.
- Para dispositivos con restricciones (serial, firmware embebido) se permite cualquier mecanismo que el módulo pueda implementar.

### Preferencia de protocolo por tipo de dispositivo

| Dispositivo | Protocolo preferido |
|---|---|
| Módulo Go / servicio nativo | gRPC |
| Botonera (simulador demo) | WebSocket |
| Dispositivo serial / embebido | A criterio del módulo |

---

## Capa 2 — Backend → Frontend

### Decisión

**WebSockets como transporte, Protobuf como formato de serialización.**

El backend expone un endpoint WebSocket. El frontend Angular se conecta y el intercambio de mensajes viaja como `ArrayBuffer` (binario) serializado con Protocol Buffers.

### Justificación

**¿Por qué WebSockets y no REST?**

El flujo de eventos en carril es bidireccional e iniciado desde el servidor:

- TCE detecta vehículo → backend procesa → frontend debe reaccionar *inmediatamente*
- Cambios de estado de dispositivos (semáforo, barrera) llegan sin que el cliente los solicite
- El cajero confirma/corrige una clasificación → frontend envía al backend → backend responde

REST requeriría polling o SSE para el push del servidor, y un canal HTTP separado para el push del cliente. WebSockets resuelve ambas direcciones con una sola conexión persistente.

**¿Por qué Protobuf y no JSON?**

- **Contrato único**: los `.proto` son la fuente de verdad. Se define una vez y se generan tipos para Go y TypeScript. No hay N lugares donde actualizar un contrato.
- **Binario nativo**: WebSockets admite `ArrayBuffer` y `Blob` — no hay conversión adicional.
- **Sin overhead de parsing de strings**: JSON serializa a texto y requiere parsing en ambos extremos. Protobuf trabaja directamente en binario.
- La latencia crítica del sistema (≤50ms por evento de clasificación) no se origina en la serialización, pero Protobuf elimina esa variable por completo.

**¿Por qué no gRPC para el frontend?**

Angular corre en browser. Los browsers no tienen acceso a HTTP/2 frames nativos requeridos por gRPC. Las alternativas (gRPC-Web, Connect-RPC) añaden complejidad operativa (proxy Envoy o servidor compatible) que no está justificada cuando WebSockets + Protobuf logra el mismo resultado sin dependencias adicionales.

---

## Contratos de mensajes

Los contratos se definen en archivos `.proto` compartidos entre el backend Go y el frontend Angular.

### Envelope estándar

Todo mensaje entre backend y frontend sigue esta estructura base:

```proto
message Envelope {
  string id        = 1;  // UUID del mensaje
  string type      = 2;  // Tipo de evento o acción
  string ref_id    = 3;  // ID del mensaje al que responde (si aplica)
  bytes  payload   = 4;  // Mensaje específico serializado
  int64  timestamp = 5;  // Unix timestamp en ms
}
```

El campo `type` actúa como el "endpoint" de REST. Los errores viajan en un mensaje `ErrorPayload` estándar referenciando el `ref_id` del mensaje original.

### Flujo de ejemplo — paso de vehículo

```
[TCE / Botonera]                [Backend Core]              [Frontend]
      │                               │                          │
      │── VEHICLE_PRESENT ──────────► │                          │
      │                               │── VEHICLE_DETECTED ────► │
      │── VEHICLE_PRE_CLASS ────────► │                          │
      │                               │── PRE_CLASSIFICATION ──► │
      │                               │ ◄── CASHIER_CONFIRM ─────│
      │── VEHICLE_POST_CLASS ───────► │                          │
      │                               │── POST_CLASSIFICATION ─► │
      │                               │── TRANSACTION_SAVED ───► │
```

---

## Decisiones descartadas

| Opción | Razón de descarte |
|---|---|
| REST puro | No soporta push del servidor sin polling o SSE. Overhead de conexión HTTP por evento. |
| REST + SSE | Dos canales distintos (SSE para server→client, REST para client→server). Mayor complejidad sin ventaja real. |
| gRPC nativo en frontend | Browsers no soportan HTTP/2 frames directamente. Requiere proxy adicional. |
| WebSocket + JSON | JSON válido para MVP, descartado por serialización string y ausencia de contrato tipado generado. |
| WebSocket + MessagePack | Binario sin schema. No resuelve el problema de contrato único. |
