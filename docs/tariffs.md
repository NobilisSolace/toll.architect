# Tariffs

El módulo de tarifas define cómo se clasifica un vehículo y cuánto paga según su tipo, el método de pago y la configuración tarifaria vigente.

## Estructura

```
vehicle_classifications  ←───────────────────────────── ─┐
(tariff_code + class_code)                               │
                                                         │
rate_tables                                              │
(moneda + IVA + vigencia)                                │
    └── toll_rates ──────────────────────────────────────┘
        (amount por clasificación)

payment_methods
    └── billing_configurations ── rate_tables
        (qué método de pago usa qué tarifa)
```

---

## Vehicle Classifications (Clasificación vehicular)

La clasificación de un vehículo combina dos códigos definidos por la SCT/CAPUFE:

### `tariff_code` — categoría tarifaria por ejes

Define el número de ejes del vehículo. Establece la categoría tarifaria oficial:

| Código | Ejes | Descripción |
|---|---|---|
| T01 | 1 eje | Vehículo ligero |
| T02 | 2 ejes | Vehículo mediano |
| T03 | 3 ejes | Vehículo pesado |
| T04 | 4 ejes | |
| T05 | 5 ejes | |
| T06 | 6 ejes | |
| T07 | 7 ejes | |
| T08 | 8 ejes | |
| T09 | 9 ejes | Máximo estándar |

### `vehicle_class_code` — clase de vehículo

Complementa el `tariff_code` para identificar el tipo de vehículo dentro de la categoría. Catálogo propio de SCT/CAPUFE:

| Código | Descripción |
|---|---|
| A | Auto (vehículo ligero de ejes sencillos) |
| M | Motocicleta |
| B | Autobús |
| C | Camión |

### Combinación `tariff_code` + `vehicle_class_code`

La clasificación completa de un vehículo se forma con ambos códigos:

| Combinación | Descripción |
|---|---|
| T01 + M | Motocicleta |
| T01 + A | Automóvil |
| T02 + B | Autobús de 2 ejes |
| T02 + C | Camión de 2 ejes |
| T09 + C | Camión de 9 ejes |

---

## Ejes excedentes (EEL / EEP)

Cuando un vehículo supera los ejes contemplados en su clasificación base, se generan cargos adicionales por cada eje excedente. Existen dos tipos:

| Código | Tipo | Aplica a |
|---|---|---|
| EEL | Eje ligero excedente | Vehículos ligeros con ejes adicionales |
| EEP | Eje pesado excedente | Vehículos de más de 9 ejes (T09+) |

Estos cargos son **aditivos** — se suman al cargo de la tarifa base del vehículo.

### Notación extendida

La clasificación con excedentes sigue la convención:

```
{tariff_code}{tipo_excedente}{cantidad}{class_code}

T01L01M  →  Motocicleta con 1 eje ligero excedente
T01L01A  →  Auto con 1 eje ligero excedente
T09P01C  →  Camión de 9 ejes con 1 eje pesado excedente
```

---

## Rate Tables (Tablas tarifarias)

Una **tabla tarifaria** agrupa las tarifas vigentes para un conjunto de condiciones específicas: moneda, tasa de IVA y período de vigencia. Puede existir más de una tabla activa simultáneamente para contemplar distintos segmentos (tarifa normal, residentes, exenciones, etc.).

Cada tabla tarifaria define:
- **Moneda** (`currency_id`) — ISO 4217, ej. MXN.
- **Tasa de IVA** (`tax_rate_id`) — porcentaje aplicable, ej. 16%.
- **Vigencia** (`expires_at`) — fecha en que la tabla deja de ser válida.

---

## Toll Rates (Tarifas por clasificación)

Cada `toll_rate` establece el **monto base antes de IVA** que corresponde a una clasificación vehicular dentro de una tabla tarifaria.

```
subtotal   = toll_rates.amount
tax_amount = subtotal × (tax_rates.percentage / 100)
total      = subtotal + tax_amount
```

Ejemplo con tarifa normal MXN + IVA 16%:

| Clasificación | Monto base | IVA 16% | Total |
|---|---|---|---|
| T01/A — Auto | $31.00 | $4.96 | $35.96 |
| T01/M — Motocicleta | $15.50 | $2.48 | $17.98 |
| T02/B — Autobús | $102.00 | $16.32 | $118.32 |

---

## Billing Configurations (Configuraciones de cobro)

`billing_configurations` es la tabla que determina **qué método de pago puede cobrar bajo qué tabla tarifaria**. Este es el mecanismo de flexibilidad del modelo.

Un mismo carril puede tener múltiples configuraciones activas:

| Método de pago | Tabla tarifaria | Escenario |
|---|---|---|
| NOR (Efectivo) | Tarifa normal | Cobro estándar |
| IAV (Telepeaje) | Tarifa normal | Cobro electrónico mismo precio |
| RPI (Residentes) | Tarifa residentes (-20%) | Descuento por convenio local |
| ELU (Eludido) | Tarifa normal | Sin recaudación, solo reportería |

Esto permite configurar de forma independiente:
- **Descuentos por segmento** — residentes, empleados, convenios.
- **Divisas distintas** — un carril fronterizo podría tener una tabla en USD.
- **Configuraciones de IVA distintas** — zonas de frontera con IVA diferenciado.

Cada `toll_transaction` apunta a una `billing_configuration`, lo que determina implícitamente la tabla tarifaria y el método de pago usados.

---

## Eludido (ELU)

Un **eludido** es un vehículo que cruza la caseta sin pagar. Se registra como una transacción con `payment_method = ELU` para fines de **reportería y control de pérdidas**.

- No genera recaudación de efectivo.
- La tarifa aplicada corresponde a la clasificación que reportó el TCE.
- Los reportes de auditoría muestran el número de eludidos y el monto de pérdida estimada por turno y carriageway.

---

## Database Mapping

| Concepto | Tabla | Campos clave |
|---|---|---|
| Clasificación vehicular SCT | `vehicle_classifications` | `tariff_code`, `vehicle_class_code`, `description` |
| Tabla tarifaria | `rate_tables` | `code`, `currency_id`, `tax_rate_id`, `expires_at` |
| Monto base por clasificación | `toll_rates` | `rate_table_id`, `vehicle_classification_id`, `amount` |
| Métodos de pago disponibles | `payment_methods` | `code`, `name` |
| Qué método usa qué tarifa | `billing_configurations` | `rate_table_id`, `payment_method_id` |
| Tasa de impuesto | `tax_rates` | `code`, `percentage` |
| Moneda | `currencies` | `code` (ISO 4217), `expires_at` |
