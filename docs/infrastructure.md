# Infrastructure

El módulo de infraestructura describe la jerarquía administrativa y física de las instalaciones de cobro de peaje en México.

## Jerarquía

```
District (Delegación)
└── Plaza de Cobro (P.C.)
    └── Subplaza
        └── Lane (Carril)
            └── Carriageway (Cuerpo)
```

---

## District

Una **delegación** es la división administrativa que agrupa varios tramos carreteros de peaje. Su función es organizar la gestión operativa, de servicios y de responsabilidades sobre las plazas bajo su jurisdicción.

En México las delegaciones son:

| Clave | Nombre |
|---|---|
| I | Noroeste |
| III | Centro-Norte |
| IV | Centro-Sur |
| V | Centro-Oriente |
| VI | Sureste |
| VII | Golfo-Veracruz |
| VIII | Noreste |
| X | Monterrey-Nuevo León |

Cada delegación administra una o más plazas de cobro (P.C.).

---

## Plaza de Cobro

Una **plaza de cobro** es la instalación física destinada a controlar el acceso y recaudar el pago de cuota en autopistas y puentes federales. Es responsable del funcionamiento de todos sus carriles, del mantenimiento y de la operación segura de la infraestructura vial.

Toda plaza pertenece a un district.

---

## Subplaza

Una **subplaza** es una instalación física dependiente de una plaza de cobro, ubicada en un punto geográfico distinto. Generalmente existe cuando una plaza tiene varias entradas y salidas que corresponden al mismo tramo carretero. Todos los eventos generados en una subplaza son reportados a su plaza padre.

Las subplazas también pueden representar los cuerpos (carriageways) de una misma ubicación:

```
P.C. 50 — Ojinaga
├── Subplaza 50A — Ojinaga Cuerpo A
└── Subplaza 50B — Ojinaga Cuerpo B
```

---

## Lane (Carril)

Un **carril** es la vía física de cobro perteneciente a una subplaza. En México los carriles se enumeran de forma secuencial a nivel nacional, sin importar a qué plaza pertenecen:

```
Carril 3385 — P.C. Chichimequillas Cuerpo A, caseta 6A
Carril 3386 — P.C. Chichimequillas Cuerpo B, caseta 7B
```

---

## Carriageway (Cuerpo)

Un **cuerpo** es el sentido de circulación dentro de un carril bidireccional. Cuando el aforo lo requiere, una misma caseta de cobro puede operar en sentido A o sentido B según la demanda de tráfico.

- **Cuerpo A** — sentido principal (ej. dirección Ciudad de México)
- **Cuerpo B** — sentido contrario (ej. dirección San Luis Potosí)

Un carril puede tener 1 o 2 carriageways activos simultáneamente dependiendo de la operación.

---

## Embedded DB — consideración de diseño

La base de datos de Toll.Architect **vive en el dispositivo del carril** (embedded), no en un sistema central. Por este motivo:

- `lane_configuration` almacena exactamente **una fila**: la identidad de este carril específico.
- `carriageways` almacena los cuerpos operativos de ese carril (generalmente 1 o 2 filas).

La normalización completa (districts, plazas, subplazas como tablas separadas) corresponde al sistema central de reportes, no a esta base de datos embebida.

---

## Database Mapping

| Concepto | Tabla | Campos clave |
|---|---|---|
| Identidad del carril | `lane_configuration` | `code_district`, `code_plaza`, `code_subplaza`, `code_lane`, `physical_lanes` |
| Cuerpo operativo | `carriageways` | `code`, `toll_booth`, `direction` |
