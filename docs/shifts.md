# Shifts

El módulo de turnos describe cómo se organiza el personal operativo para garantizar la operación continua 24×7, 365 días al año, y cómo se registran y atribuyen todos los eventos generados en carril.

## Flujo operativo

```
Planeación
└── Shift Leader asignado a turno + fecha   (shift_leaders)
    ├── Cashiers asignados al Shift Leader  (cashier_assignments)
    └── Auto-asignación del SL a sí mismo   (cashier_assignments)
        └── Shift Cuts (cortes)             (shift_cuts)
            └── Toll Transactions           (toll_transactions)
```

---

## Shift (Turno)

Un **turno** define el bloque de tiempo en que un equipo de operadores trabaja. En México, CAPUFE opera con tres turnos rotativos que cubren las 24 horas:

| Código | Nombre | Horario | Nota |
|---|---|---|---|
| 4 | Nocturno | 22:00 → 06:00 | Cruza medianoche |
| 5 | Matutino | 06:00 → 14:00 | |
| 6 | Vespertino | 14:00 → 22:00 | |

> Los códigos 4, 5 y 6 son los identificadores del sistema operador, no una numeración propia del sistema.

---

## Shift Leader (Encargado de turno)

El **encargado de turno** es el responsable operativo durante un turno en una fecha específica. Sus responsabilidades incluyen:

- Supervisar la operación de los cajeros asignados.
- Preliquidar todos los eventos generados en carril al cierre del turno.
- Generar los reportes de auditoría y control de efectivo.
- Operar los cortes de carril cerrado y modo libre.

Un shift leader siempre se asigna a un **turno + fecha** concretos:

```
Usuario:   Juan
Rol:       Shift Leader
Fecha:     12/06/2026
Turno:     4 (Nocturno)

→ Juan opera desde las 22:00 del 12/06/2026
  hasta las 06:00 del 13/06/2026.
```

---

## Cashier Assignment (Asignación de cajero)

Durante la **planeación del turno**, se definen qué cajeros operarán bajo las órdenes del Shift Leader. Esto genera entradas en `cashier_assignments`.

Como parte del mismo proceso, el sistema genera automáticamente una entrada en `cashier_assignments` apuntando al **Shift Leader como su propio cajero**. Este registro es el mecanismo por el cual los cortes de carril cerrado y modo libre quedan atribuidos al SL.

```
Planeación turno 4 — 12/06/2026 — SL: Juan
┌─────────────────────────────────────────────┐
│ cashier_assignment → user: Juan  (SL mismo) │  ← cortes cerrados / modo libre
│ cashier_assignment → user: María (cajera)   │  ← cortes abiertos de María
│ cashier_assignment → user: Carlos (cajero)  │  ← cortes abiertos de Carlos
└─────────────────────────────────────────────┘
```

---

## Shift Cut (Corte de turno)

Un **corte** es el período operativo dentro de un turno durante el cual se registran transacciones de peaje. Cada corte pertenece a un carriageway específico y queda atribuido a una `cashier_assignment`.

Los cortes tienen los siguientes tipos, determinados por el `lane_state` asociado:

| Tipo | lane_states.category | Descripción | Atribuido a |
|---|---|---|---|
| **Carril Abierto** | `NORMAL` | Operación normal de cobro | Cajero que abrió el corte |
| **Carril Cerrado** | `CERRADO` | Sella los gaps entre cortes abiertos | Shift Leader |
| **Modo Libre** | `LIBRE` | Tránsito libre por contingencia | Shift Leader |

### Por qué existen los cortes de carril cerrado

Cuando un cajero sale a comer o a un receso, el carril no se detiene — los vehículos siguen pasando. Los cortes de carril cerrado **sellan el intervalo** entre dos cortes de carril abierto y capturan los eventos que ocurren durante ese período, típicamente **vehículos eludidos** (que pasan sin pagar). Estos eventos se contabilizan y se asignan al Shift Leader.

### Creación automática de cortes cerrados

Cuando un cajero **cierra su corte de carril abierto**, el sistema crea automáticamente el corte de carril cerrado correspondiente. Esto garantiza que no existan huecos en la línea de tiempo operativa del carriageway y que todos los eventos posteriores al cierre queden correctamente capturados y atribuidos al Shift Leader hasta que un nuevo cajero abra su corte.

### Identidad de un corte

Cada corte registra:
- El **carriageway** donde ocurrió.
- El **cashier_assignment** al que se atribuye (cajero o SL).
- El **estado de carril** (`lane_state`) que clasifica el tipo de corte.
- Un **`cut_sequence`** histórico e indefinido — número secuencial que nunca se reinicia y sirve como identificador auditable único del corte a lo largo de la vida del carril.
- El rango de **folios** generados durante el corte (`start_folio` / `end_folio`).

---

## Folio y Ticket

Dentro de un corte se generan dos tipos de numeración secuencial:

| Campo | Cuándo incrementa | Ejemplos de eventos |
|---|---|---|
| **`folio_number`** | En **todo evento** generado en carril | Efectivo, Telepeaje (IAV), Eludido, VSC, Vehículo al servicio de la comunidad |
| **`ticket_number`** | Solo cuando se emite un **boleto físico** | Efectivo (NOR) |

El `folio_number` es el registro universal de tránsito — todo vehículo que activa el sistema genera un folio. El `ticket_number` es un subconjunto que aplica únicamente a los eventos que producen un comprobante impreso.

El rango `start_folio` → `end_folio` en el corte permite auditar qué folios fueron generados durante ese período y detectar huecos o inconsistencias.

---

## Database Mapping

| Concepto | Tabla | Campos clave |
|---|---|---|
| Definición de turno | `shifts` | `code`, `start_time`, `end_time` |
| Asignación SL a turno + fecha | `shift_leaders` | `shift_id`, `user_id`, `assignment_date` |
| Cajero (o SL) asignado al turno | `cashier_assignments` | `user_id`, `shift_leader_id` |
| Corte operativo | `shift_cuts` | `cashier_assignment_id`, `carriageway_id`, `lane_state_id`, `cut_sequence`, `start_folio`, `end_folio` |
| Estado/tipo del corte | `lane_states` | `category` (NORMAL / CERRADO / LIBRE), `code` (incluye cuerpo A/B) |
