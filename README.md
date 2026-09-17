# Emisora — CRUD con JSP sin Servlet

Actividad académica de **Desarrollo Web – Unidad 1** (Servlets/JSP: segunda generación del desarrollo web).
**Ejercicio 25: Emisora.**

Aplicación web en Java para administrar emisoras de radio (nombre, canal, frecuencias FM/AM, locutores,
género, horario, patrocinador, país, programas y ciudades de cobertura), con gestión de usuarios,
inicio de sesión, reportes parametrizados y recuperación de clave por correo.

La arquitectura sigue la guía del docente **"CRUD con JSP SIN Servlet"**: no hay clases que extiendan
`HttpServlet`; el controlador de cada entidad es un archivo `.jsp` que recibe un parámetro `action`.

## Tecnologías

| Componente | Versión | Nota |
|---|---|---|
| Java (JDK) | 21 | Igual que la guía |
| Apache Tomcat | 11.0.x | Jakarta EE 11 Web |
| JSP + JDBC | — | Sin Spring, Hibernate ni frameworks MVC |
| MySQL Server | 8.0 o superior | Probado con MySQL 9.7 |
| MySQL Connector/J | 9.7.0 | Lo descarga Maven automáticamente |
| Maven | 3.9+ | Solo para compilar y empaquetar el `.war` |

## Estructura del proyecto

El proyecto usa la estructura estándar de Maven. NetBeans la muestra con los mismos nombres de la guía
(**Web Pages** y **Source Packages**):

| Vista en NetBeans (guía) | Carpeta real |
|---|---|
| Source Packages | `src/main/java/` |
| Web Pages | `src/main/webapp/` |
| Libraries (mysql-connector-j) | `pom.xml` |

```
Emisora/
├── pom.xml
├── db/                                   Scripts SQL (creación + datos iniciales)
└── src/main/
    ├── java/                             ← Source Packages
    │   ├── Domain/Model/                 Entidades (POJOs): User, Emisora
    │   ├── Infrastructure/Database/      Conexión JDBC: ConnectionDbMySql
    │   ├── Infrastructure/Persistence/   Acceso a datos (CRUD con PreparedStatement)
    │   ├── Business/Exceptions/          Excepciones de negocio
    │   └── Business/Services/            Lógica de negocio (la usan los controladores)
    └── webapp/                           ← Web Pages
        ├── index.jsp                     Página de inicio
        ├── Controllers/                  Controladores JSP (UserController.jsp, EmisoraController.jsp)
        ├── Views/
        │   ├── Css/  Js/  Img/  Multimedia/
        │   └── Forms/
        │       ├── Users/                login, create, find_edit_delete, list_all
        │       └── Emisoras/             create, find_edit_delete, list_all
        └── WEB-INF/web.xml
```

## Base de datos

Scripts en la carpeta [`db/`](db/) (ejecutarlos en orden, por ejemplo desde MySQL Workbench con
*File → Open SQL Script* y el botón del rayo ⚡):

1. [`db/01_schema.sql`](db/01_schema.sql) — crea la base `emisora_db` y las tablas `Users` y `Emisoras`
   (si ya existían, las borra y las crea de nuevo).
2. [`db/02_data.sql`](db/02_data.sql) — carga 5 usuarios y 14 emisoras de prueba.

Desde la terminal:

```bash
mysql -u root -p < db/01_schema.sql
mysql -u root -p < db/02_data.sql
```

### Tabla `Users`

La guía usa `code`, `password`, `name` y `email`. La actividad pide *id, clave, nombre y rol*, por eso
se agregó `role`:

| Actividad | Columna | Detalle |
|---|---|---|
| id | `code` | Clave primaria (texto), ej. `U001` |
| clave | `password` | Cifrada con SHA-256 (64 caracteres), nunca en texto plano |
| nombre | `name` | |
| rol | `role` | `ADMIN`, `OPERADOR` o `CONSULTA` |
| — | `email` | Único. Se usa para iniciar sesión (como en la guía) y recuperar la clave |
| — | `createdAt` | Fecha de registro (reporte por rango de fechas) |
| — | `resetToken`, `resetTokenExpires` | Código temporal para recuperar la clave por correo |

### Tabla `Emisoras`

Los 12 atributos del ejercicio 25 más `code` como clave primaria (mismo patrón que `Users`):
`code`, `nombre` (único), `canal`, `bandaFm` (MHz, opcional), `bandaAm` (kHz, opcional), `numLocutores`,
`genero`, `horario`, `patrocinador`, `pais`, `descripcion`, `numProgramas`, `numCiudades`.
Toda emisora debe transmitir al menos en FM o en AM.

### Usuarios de prueba

| Email | Clave | Rol |
|---|---|---|
| jquinteroh2@unicartagena.edu.co | `Admin2026*` | ADMIN |
| operador.emisora@yopmail.com | `Operador2026*` | OPERADOR |
| consulta.emisora@yopmail.com | `Consulta2026*` | CONSULTA |

(Los buzones `@yopmail.com` son públicos: se pueden abrir en <https://yopmail.com> para ver el correo
de recuperación de clave.)

## Estado del desarrollo

- [x] Configuración inicial del proyecto (Maven WAR, Tomcat 11, estructura de la guía)
- [x] Base de datos: script de creación y datos iniciales
- [x] Modelo de dominio y conexión a MySQL
- [x] Persistencia y servicio de Usuario (excepciones, `UserCRUD`, `UserService`)
- [ ] Controlador JSP y vistas de Usuario
- [ ] CRUD de Emisora
- [ ] Login, sesión y control de acceso
- [ ] Reportes parametrizados (2 por entidad)
- [ ] Recuperación de clave por correo
- [ ] Despliegue en Internet
