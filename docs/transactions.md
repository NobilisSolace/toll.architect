# Transactions

El módulo de transacciones registra cada evento de tránsito generado en carril. Una transacción representa el paso de un vehículo por la caseta y su cobro asociado, con trazabilidad completa hacia el corte, turno y operador que lo procesó.

## Flujo de un evento de peaje

```
Vehículo se aproxima
    │
    ▼
[TCE] Pre-clasificación ──────────────────────────────── (solo en carriles asistidos)
    │                                                      tce_pre_classification
    ▼
Cajero clasifica y cobra
    │                                                      cashier_classification
    ├── ¿Cambió la clasificación del TCE? ──────────────── is_reclassified = true
    └── ¿No hubo pre-clasificación o TCE no detectó? ───── is_manual = true
    │
    ▼
[TCE] Post-clasificación ────────────────────────────── (obligatoria en todos los carriles)
    │                                                      tce_post_classification
    └── ¿Difiere de la clasificación del cajero? ────────── has_discrepancy = true
    │
    ▼
Transacción registrada
```

---

## Tipos de carril por clasificación

El carril determina qué campos de clasificación están disponibles:

| Tipo de carril | Pre-clasificación TCE | Clasificación cajero | Post-clasificación TCE |
|---|---|---|---|
| **Manual** | No aplica | Siempre manual | Obligatoria |
| **Automático asistido** | Sí — pre-calcula el costo | Confirma o corrige | Obligatoria |

En un **carril automático asistido**, el vehículo llega a la caseta con su costo ya calculado, lo que agiliza el cobro. El cajero solo confirma o corrige si hay error.

En un **carril manual**, toda clasificación la realiza el cajero. `is_manual = true` en todas las transacciones.

---

## Clasificación vehicular en la transacción

Una transacción registra hasta tres puntos de clasificación del mismo vehículo:

| Campo | Origen | Nullable | Descripción |
|---|---|---|---|
| `tce_pre_classification` | TCE | No | Clasificación de entrada. En carriles sin pre, contiene un código de sistema. |
| `cashier_classification` | Cajero | No | Clasificación con la que se procesó el cobro. Es la clasificación definitiva. |
| `tce_post_classification` | TCE | Sí | Clasificación de salida. Lectura más lenta y controlada. Obligatoria pero puede llegar después del registro inicial. |

### Reclasificación (`is_reclassified`)

Se activa cuando el cajero **modifica** la clasificación respecto a la pre-clasificación recibida del TCE:

```
Ejemplo:
  tce_pre_classification  = T01M  (TCE detectó motocicleta)
  cashier_classification  = T01A  (cajero corrige a auto)
  is_reclassified         = true
```

En carriles manuales, la reclasificación ocurre cuando el cajero corrige una clasificación que él mismo ingresó previamente.

### Discrepancia (`has_discrepancy`)

Se activa cuando la **post-clasificación del TCE difiere** de la clasificación con la que se procesó el cobro:

| Escenario | Comparación |
|---|---|
| Carril con pre-clasificación | `tce_pre_classification` ≠ `cashier_classification` ≠ `tce_post_classification` |
| Carril manual | `cashier_classification` ≠ `tce_post_classification` |

Una discrepancia no anula la transacción — queda registrada para auditoría y revisión posterior.

---

## Transacción manual (`is_manual`)

Una transacción es manual cuando el cajero realizó la clasificación sin apoyo del TCE:

- **Carril asistido**: el TCE no detectó el vehículo (fallo de sensor, vehículo fuera de rango). El cajero clasificó manualmente.
- **Carril manual**: no existe pre-clasificación por diseño — todas las transacciones son manuales.

---

## Folio y Ticket

Ver definiciones completas en [Shifts — Folio y Ticket](shifts.md#folio-y-ticket).

| Campo | Incrementa cuando |
|---|---|
| `folio_number` | Todo evento en carril (efectivo, telepeaje, eludido, VSC…) |
| `ticket_number` | Solo cuando se emite boleto físico (pago en efectivo) |

`transaction_sequence` es un contador secuencial **dentro del corte** (`shift_cut`). Se reinicia en cada nuevo corte.

---

## Telepeaje (`tag_number`)

El campo `tag_number` contiene el identificador del transponder (TAG) del vehículo. Solo está presente en transacciones con método de pago `IAV` (Telepeaje). En cualquier otro método de pago su valor es `NULL`.

---

## Trazabilidad de auditoría

Cada transacción permite reconstruir toda la cadena operativa mediante joins:

```
toll_transactions
    └── shift_cut_id → shift_cuts
            ├── cashier_assignment_id → cashier_assignments
            │       ├── user_id → users (cajero)
            │       └── shift_leader_id → shift_leaders
            │               ├── user_id → users (encargado de turno)
            │               └── shift_id → shifts
            ├── carriageway_id → carriageways
            └── lane_state_id → lane_states

    └── billing_configuration_id → billing_configurations
            ├── rate_table_id → rate_tables
            └── payment_method_id → payment_methods

    └── toll_rate_id → toll_rates
            └── vehicle_classification_id → vehicle_classifications
```

La consulta de auditoría típica **parte del shift leader** y desciende hacia los cortes y transacciones asociadas.

---

## Cálculo del monto

```
subtotal   = toll_rates.amount          (monto base antes de IVA)
tax_amount = subtotal × (tax_rates.percentage / 100)
total      = subtotal + tax_amount
```

Ver detalle de tarifas y configuraciones en [Tariffs](tariffs.md).

---

## `sys_synchro`

Indica si la transacción ha sido sincronizada con el sistema central. La base de datos es embebida en el dispositivo del carril — la sincronización hacia el sistema de reportes ocurre de forma asíncrona.

- `false` — pendiente de sincronizar.
- `true` — confirmada en el sistema central.

---

## Database Mapping

| Concepto | Tabla | Campos clave |
|---|---|---|
| Evento de peaje | `toll_transactions` | `folio_number`, `ticket_number`, `transaction_sequence`, `captured_at` |
| Clasificación | `toll_transactions` | `tce_pre_classification`, `cashier_classification`, `tce_post_classification` |
| Flags de auditoría | `toll_transactions` | `is_reclassified`, `is_manual`, `has_discrepancy` |
| Telepeaje | `toll_transactions` | `tag_number` |
| Montos | `toll_transactions` | `subtotal`, `tax_amount` |
| Sincronización | `toll_transactions` | `sys_synchro` |
