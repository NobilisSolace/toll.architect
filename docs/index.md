# Toll.Architect — Documentation

Business logic and domain knowledge reference for the Toll.Architect project.

## Domain

| File | Topics | Description |
|---|---|---|
| [Infrastructure](infrastructure.md) | District, plaza, subplaza, lane, carriageway | Jerarquía administrativa y física de las instalaciones de cobro. Incluye la razón detrás del diseño embebido de la BD por carril. |
| [Shifts](shifts.md) | Shift, shift leader, cashier, shift cut | Organización del personal operativo 24×7, asignación de turnos, tipos de corte y el concepto de folio vs ticket. |
| [Tariffs](tariffs.md) | Rate tables, vehicle classifications, toll rates | Clasificación vehicular SCT/CAPUFE, cálculo de IVA, ejes excedentes y el modelo flexible de billing configurations. |
| [Transactions](transactions.md) | Toll transaction, TCE, classifications | Ciclo de vida de un evento de peaje: pre/post clasificación TCE, reclasificación, discrepancias y trazabilidad de auditoría. |
| [Users & Profiles](users-profiles.md) | Profiles, permissions, users | Perfiles, permisos por perfil, ciclo de credenciales administrado por el APC y modo demo. |
| [Lane Hardware](laneHardware.md) | DMS/PMV, TCE, cámaras, RFID, operador | Hardware de carril: señalización, TCE (pre/posclasificación), cámaras (ANPR, balizaje, cabina), lectores RFID, equipo del operador. |
| [Architecture — Comms](architecture-comms.md) | WebSocket, Protobuf, gRPC, message envelope | Decisión de transporte y serialización entre dispositivos, backend y frontend. |

## Reference

- [Glossary](glossary.md) *(pendiente)*
