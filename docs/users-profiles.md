# Users & Profiles

El módulo de usuarios define quién puede acceder al sistema, qué puede hacer y bajo qué condiciones. Al ser una instalación **on-premise** en el dispositivo del carril, no se requiere un esquema de autenticación distribuida (JWT, SSO). La autenticación es local mediante usuario y contraseña.

---

## Perfiles

Un **perfil** agrupa un conjunto de permisos que define las capacidades operativas de un usuario. Los perfiles son catálogos del sistema y se identifican por un código corto:

| Código | Nombre | Rol operativo |
|---|---|---|
| `ADM` | Administrador de plaza de cobro | APC — administrador del sistema en la plaza |
| `EDT` | Encargado de turno | Shift Leader |
| `CRE` | Cajero receptor | Cashier |
| `MTO` | Mantenimiento | Técnico de mantenimiento |

---

## Permisos

Los permisos se almacenan en `profile_permissions` como una lista de entradas por perfil, lo que permite añadir nuevos permisos sin modificar el schema. Cada permiso habilita un conjunto específico de funcionalidades:

| Permiso | Descripción |
|---|---|
| `Cashier` | Operar la caseta de cobro: abrir/cerrar cortes, procesar transacciones. |
| `Contingency` | Abrir el modo libre (tránsito gratuito por contingencia). Ver [Shifts](shifts.md#shift-cut-corte-de-turno). |
| `Demo` | Acceder al modo demostración. Ver [Modo Demo](#modo-demo). |
| `Maintenance` | Acceder a configuración de carril y ajustes de hardware. |

### Permisos por perfil

| Perfil | Cashier | Contingency | Demo | Maintenance |
|---|---|---|---|---|
| ADM | ✓ | ✓ | ✓ | ✓ |
| EDT | ✓ | ✓ | | |
| CRE | ✓ | | | |
| MTO | | | | ✓ |

---

## Usuarios

Un **usuario** representa a una persona física que opera el sistema. Cada usuario pertenece a un perfil y hereda sus permisos.

Campos relevantes:

| Campo | Descripción |
|---|---|
| `username` | Identificador de login. Único en el sistema. |
| `first_name` / `last_name` | Nombre completo del operador. |
| `employee_id` | Clave de empleado del operador. Único. |
| `password` | Hash de la contraseña (argon2id). Nunca se almacena en texto plano. |
| `expires_at` | Fecha de expiración del acceso. Ver [Expiración de usuario](#expiración-de-usuario). |
| `sys_enabled` | Indica si el usuario está activo. Mecanismo de desactivación sin borrado. |

---

## Administrador de Plaza de Cobro (APC)

El **APC** es el usuario con perfil `ADM`. Es el responsable de la gestión de usuarios en la instalación y el único con autoridad sobre las credenciales de acceso.

### Ciclo de vida de las credenciales

```
APC crea el usuario
    └── Asigna contraseña inicial
            │
            ▼
        Usuario puede cambiar su propia contraseña
            │
            ▼
        Si el usuario olvida/pierde acceso
            └── Solo el APC puede reestablecerla
```

- Las contraseñas son asignadas inicialmente por el APC desde el sistema de plaza.
- El usuario puede cambiar su propia contraseña una vez dentro del sistema.
- El restablecimiento de contraseña es una operación exclusiva del APC — ningún otro perfil puede hacerlo.

---

## Expiración de usuario

El campo `expires_at` define la fecha límite de acceso de un usuario al sistema.

- Cuando se alcanza la fecha de expiración, **el login queda bloqueado automáticamente**.
- El usuario no puede acceder hasta que el APC extienda o modifique manualmente la fecha.
- Los usuarios de sistema (ej. genéricos o de largo plazo) pueden tener `expires_at` en fecha muy lejana (ej. `2099-01-01`).

---

## Modo Demo

El permiso `Demo` habilita un modo especial del aplicativo orientado a entrenamiento y demostraciones con clientes:

- Activa una **botonera de simulación de hardware** que permite reproducir el funcionamiento del sistema sin infraestructura física (TCE, impresoras, lectores de TAG).
- Las transacciones generadas en modo demo **no se sincronizan** con el sistema central ni se contabilizan en reportes reales.
- Útil para capacitación de operadores nuevos y presentaciones comerciales sin necesidad de acceso a una plaza activa.

---

## Database Mapping

| Concepto | Tabla | Campos clave |
|---|---|---|
| Definición de perfil | `profiles` | `code`, `name` |
| Permisos del perfil | `profile_permissions` | `profile_id`, `permission` |
| Usuario operativo | `users` | `username`, `employee_id`, `profile_id`, `expires_at`, `sys_enabled` |
| Credencial | `users` | `password` (argon2id hash, `varchar(255)`) |
