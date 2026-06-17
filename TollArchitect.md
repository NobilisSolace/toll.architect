## Toll Architect

Sistema de cobro monolítico para carriles en plazas de cobro.

### Arquitectura carril
- Angular FrontEnd -> Web UI para Operador
- Go Backend -> Backend en GO para lógica de Carriles y dispositivos
- PostgreSQL -> Base de datos de carril

### Arquitectura plaza
- Angular FrontEnd -> Web UI para encargados
- Go Backend -> Backend en GO para reporteria y dashboards.
- PostgreSQL -> Base de datos de carril

---
### MVP

- Backend: Modelo de Carril Manual con Telepeaje, operable a través de botonera
- FrontEnd: EyeCandy con simulación de flujos de cobro a través de botonera [demo]
    - Maqueta lista
    - Flujo de conexión al backend con WebSockets
    - Autenticación local con base de datos de carril.

- Botonera: Aplicación de Test para ejemplificar el modo demo de operación.
- Diseño de base de datos

---
- [x] Definir Tecnologías
- [X] Modelado Base de Datos en PostgreSQL
- [X] Definición de arquitectura para comunicación Backend Frontend
- [] Modelado de Maqueta
    - [] Modelado de LogIn
    - [] Pantalla de cobro
    - [] Barra de dispositivos
    - [] Histórico eventos
    - [] Action bar
- [] Modelado FrontEnd
- [] Definición de logIn en Carril

