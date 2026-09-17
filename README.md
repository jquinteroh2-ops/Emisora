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

## Estado del desarrollo

- [x] Configuración inicial del proyecto (Maven WAR, Tomcat 11, estructura de la guía)
- [ ] Base de datos: script de creación y datos iniciales
- [ ] Modelo de dominio y conexión a MySQL
- [ ] CRUD de Usuario (persistencia, servicio, controlador JSP y vistas)
- [ ] CRUD de Emisora
- [ ] Login, sesión y control de acceso
- [ ] Reportes parametrizados (2 por entidad)
- [ ] Recuperación de clave por correo
- [ ] Despliegue en Internet
