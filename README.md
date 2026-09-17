# Emisora — CRUD con JSP sin Servlet

**Aplicación publicada:** <https://emisora-onnt.onrender.com>
(plan gratuito: si nadie la visita en 15 minutos se duerme y la primera carga puede tardar cerca de un minuto).
Las claves de prueba de la aplicación publicada **no** son las de este README; se entregan aparte al docente.

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
| MySQL Server | 8.0 o superior | Probado con MySQL 9.7 (ejecución local) |
| TiDB Cloud Starter | — | Base de datos en la nube compatible con MySQL (despliegue) |
| JavaMail (Jakarta Mail) | 2.1 | Envío del correo de recuperación por SMTP (Brevo) |
| Docker + Render | — | Despliegue en Internet |
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
    │   ├── Infrastructure/Mail/          Envío de correos por SMTP: EmailSender
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

## Arquitectura: el JSP como controlador

No existen clases `HttpServlet`. Cada entidad tiene un **controlador JSP** (`Controllers/UserController.jsp`)
que recibe todas las peticiones con un parámetro `action`:

```
Navegador ──> /Controllers/UserController.jsp?action=create
                 │  scriptlet <% %>: lee "action" y hace switch (action)
                 ▼
              handleCreateUser(...)          método privado declarado con <%! %>
                 │
                 ▼
              UserService.createUser(...)    Business: valida y cifra la clave
                 │
                 ▼
              UserCRUD.addUser(user)         Infrastructure: INSERT con PreparedStatement
                 │
                 ▼
              MySQL (tabla Users)
                 │  (si hay error: DuplicateUserException / InvalidUserException)
                 ▼
              request.setAttribute("successMessage" | "errorMessage", ...)
              forward ──> /Views/Forms/Users/list_all.jsp  (o create.jsp si hubo error)
```

- **¿Por qué funciona sin Servlet?** Tomcat traduce cada JSP a una clase Java que hereda de `HttpJspBase`.
  El código del scriptlet queda dentro del método `_jspService(request, response)` (el equivalente al
  `service()` de un Servlet) y los métodos `<%! %>` quedan como métodos de esa clase. Se puede ver en
  `CATALINA_HOME/work/Catalina/localhost/emisora/org/apache/jsp/Controllers/UserController_jsp.java`.
- **Vistas (`Views/Forms`)**: solo muestran datos. Reciben `errorMessage`, `successMessage` y listas
  (`users`) por `request`, y el registro buscado (`searchedUser`) o el usuario logueado (`loggedInUser`)
  por `session`.
- **`forward` vs `sendRedirect`**: `forward` conserva el `request` (y sus mensajes) dentro del servidor;
  `sendRedirect` le pide al navegador que haga una nueva petición (se usa para abrir formularios vacíos,
  al iniciar y al cerrar sesión).

### Acciones de `UserController.jsp`

| action | Método | Resultado |
|---|---|---|
| `login` | `handleLogin` | Cierra la sesión y redirige a `login.jsp` |
| `authenticate` | `handleAuthenticate` | Valida email y clave; guarda `loggedInUser` en la sesión |
| `showCreateForm` | `showCreateUserForm` | Redirige a `create.jsp` |
| `create` | `handleCreateUser` | Crea el usuario y muestra la lista |
| `showFindForm` | `showFindForm` | Abre `find_edit_delete.jsp` vacío |
| `search` | `handleSearch` | Busca por código y guarda `searchedUser` en la sesión |
| `update` | `handleUpdateUser` | Actualiza el usuario buscado |
| `delete` | `handleDeleteUser` | Elimina el usuario buscado |
| `deletefl` | `handleDeleteUserFromList` | Elimina desde el enlace de la lista |
| `listAll` | `handleListAllUsers` | Lista todos (o filtra con `q`) |
| `reportRol` | `handleReportRol` | Reporte 3: usuarios por rol |
| `reportFechas` | `handleReportFechas` | Reporte 4: usuarios registrados entre dos fechas |
| `logout` | `handleLogout` | Cierra la sesión |

### Acciones de `EmisoraController.jsp`

Mismo patrón. El inicio y cierre de sesión solo los atiende `UserController.jsp`.

| action | Método | Resultado |
|---|---|---|
| `showCreateForm` | `showCreateEmisoraForm` | Redirige a `create.jsp` |
| `create` | `handleCreateEmisora` | Convierte el formulario (`EmisoraService.buildEmisora`), valida, crea y muestra la lista |
| `showFindForm` | `showFindForm` | Abre `find_edit_delete.jsp` vacío |
| `search` | `handleSearch` | Busca por código y guarda `searchedEmisora` en la sesión |
| `update` | `handleUpdateEmisora` | Actualiza la emisora buscada |
| `delete` | `handleDeleteEmisora` | Elimina la emisora buscada |
| `deletefl` | `handleDeleteEmisoraFromList` | Elimina desde el enlace de la lista |
| `listAll` | `handleListAllEmisoras` | Lista todas (o filtra con `q`) |
| `reportPaisGenero` | `handleReportPaisGenero` | Reporte 1: emisoras por país y género |
| `reportCobertura` | `handleReportCobertura` | Reporte 2: emisoras por cobertura |

## Reportes parametrizados

Cada reporte sigue el mismo recorrido por capas: formulario de parámetros (GET) → acción del controlador JSP
→ método `report...` del Service (valida los parámetros) → método del CRUD (`SELECT` con `WHERE` y
`PreparedStatement`) → la misma vista muestra el resultado con un resumen. Sin parámetros, la acción solo
muestra el formulario.

| # | Reporte | Parámetros | Consulta SQL | Quién |
|---|---|---|---|---|
| 1 | Emisoras por país y género | país (desplegable con los países registrados) y género (opcional) | `WHERE pais = ? [AND genero = ?]` | Todos los roles |
| 2 | Emisoras por cobertura | mínimo y máximo de ciudades, mínimo de locutores | `WHERE numCiudades BETWEEN ? AND ? AND numLocutores >= ? ORDER BY numCiudades DESC` | Todos los roles |
| 3 | Usuarios por rol | rol | `WHERE role = ?` | ADMIN |
| 4 | Usuarios por fecha de registro | fecha desde y hasta (ambas incluidas) | `WHERE createdAt >= ? AND createdAt < ?` (hasta + 1 día) | ADMIN |

Ejemplos (con sesión iniciada; resultados con los datos de prueba):

- `.../Controllers/EmisoraController.jsp?action=reportPaisGenero&pais=Colombia&genero=Noticias` → EM002 y EM004
- `.../Controllers/EmisoraController.jsp?action=reportCobertura&minCiudades=10&maxCiudades=50&minLocutores=10` → 5 emisoras
- `.../Controllers/UserController.jsp?action=reportRol&role=OPERADOR` → 2 usuarios
- `.../Controllers/UserController.jsp?action=reportFechas&fromDate=2026-08-01&toDate=2026-08-31` → 3 usuarios

## Sesión, login y control de acceso

1. **Login** (`UserController.jsp?action=authenticate`): `UserService.loginUser` busca el usuario por email y
   compara la clave cifrada con SHA-256. Si es correcta, se renueva el id de sesión y se guarda el objeto
   `User` en la sesión como `loggedInUser`.
2. **Control de acceso** (`WEB-INF/jspf/auth.jspf`): fragmento incluido en los controladores y en las vistas
   internas. Su método `checkAccess(request, response, session, roles...)`:
   - sin `loggedInUser` → muestra el login con *"Debe iniciar sesión para continuar."*;
   - con un rol no permitido → responde **403** y muestra el inicio con *"Su rol no tiene permiso..."*.
   Se aplica **dos veces**: en el controlador (antes del `switch`) y al inicio de cada vista interna, por si
   alguien escribe directamente la URL de una vista.
3. **Menús y botones según el rol** (`hasRole(...)`): `index.jsp`, `list_all.jsp` y `find_edit_delete.jsp`
   solo muestran las opciones permitidas.
4. **Logout** (`action=logout`): invalida la sesión.

| Acción | ADMIN | OPERADOR | CONSULTA | Sin sesión |
|---|:-:|:-:|:-:|:-:|
| Inicio y login | ✅ | ✅ | ✅ | ✅ |
| Listar, buscar y ver emisoras | ✅ | ✅ | ✅ | ❌ |
| Crear, editar y eliminar emisoras | ✅ | ✅ | ❌ | ❌ |
| Gestionar usuarios | ✅ | ❌ | ❌ | ❌ |

Reglas extra: nadie puede **eliminar su propio usuario** ni **cambiar su propio rol**; si un usuario edita sus
propios datos, la sesión se actualiza.

## Recuperación de clave por correo

Como las claves se guardan cifradas (SHA-256), no se pueden "recordar": se envía un **enlace de un solo uso**
para crear una nueva. Todas las acciones son públicas en `UserController.jsp` (quien olvidó su clave no puede
iniciar sesión):

| Paso | action | Qué hace |
|---|---|---|
| 1 | `showForgotForm` → `sendResetLink` | `UserService.requestPasswordReset`: si el email existe, genera un código aleatorio de 64 caracteres (`SecureRandom`), guarda en `Users.resetToken` **su versión cifrada** con vencimiento de 30 minutos (`resetTokenExpires`) y envía el enlace con `Infrastructure.Mail.EmailSender` (JavaMail por SMTP). Siempre responde el mismo mensaje, exista o no el correo. |
| 2 | `showResetForm&token=...` | `validateResetToken`: busca el código cifrado que no haya vencido y muestra `reset_password.jsp`. |
| 3 | `resetPassword` | `resetPassword`: valida la clave nueva (mínimo 8 caracteres y confirmación), la guarda cifrada y **borra el código** para que el enlace no sirva otra vez. |

El enlace del correo se arma con la variable `APP_BASE_URL`; si no existe (ejecución local), se usa la
dirección de la petición (ej. `http://localhost:8080/emisora`).

### Configurar el envío de correo con Brevo (gratis)

Se usa SMTP de [Brevo](https://www.brevo.com) por el **puerto 2525**, porque el plan gratuito de Render bloquea
los puertos SMTP 25, 465 y 587. Plan gratuito: 300 correos al día, sin tarjeta.

1. Crear una cuenta en <https://www.brevo.com>. Brevo puede revisar la cuenta antes de permitir envíos.
2. **Remitente**: en *Configuración → Remitentes, dominios e IP → Remitentes → Añadir un remitente*, poner el
   nombre "Gestión de Emisoras" y el correo propio; verificarlo con el código de 6 dígitos que llega a ese correo.
3. **Clave SMTP**: en *SMTP y API → SMTP*, generar una clave SMTP y copiar el **login SMTP** (suele tener la forma
   `xxxxxx@smtp-brevo.com`) y la **clave**.
4. Guardar las variables (una sola vez) y abrir una terminal nueva:

   ```bat
   setx MAIL_SMTP_USER "login-smtp@smtp-brevo.com"
   setx MAIL_SMTP_PASSWORD "clave-smtp-de-brevo"
   setx MAIL_FROM "correo-verificado-como-remitente"
   ```

> Al usar un remitente de un correo gratuito o institucional sin dominio autenticado, algunos mensajes pueden
> llegar a **spam**. Los buzones públicos de [yopmail.com](https://yopmail.com) de los usuarios de prueba sí los reciben.

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

## Ejecutar localmente (Windows)

### 1. Requisitos

- **JDK 21** (por ejemplo [Eclipse Temurin 21](https://adoptium.net/)).
- **Maven 3.9+** (`mvn -v` debe funcionar en la terminal).
- **MySQL 8.0+** con los scripts de [`db/`](db/) ya ejecutados.
- **Apache Tomcat 11**: descargar el *Windows zip* desde <https://tomcat.apache.org/download-11.cgi> y
  descomprimirlo (no necesita instalación). Ejemplo: `C:\Users\joseq\Tomcat\apache-tomcat-11.0.26`.

### 2. Variables de entorno

| Variable | Obligatoria | Ejemplo / valor por defecto | Para qué sirve |
|---|---|---|---|
| `CATALINA_HOME` | Sí (solo para `run-local.bat`) | `C:\Users\joseq\Tomcat\apache-tomcat-11.0.26` | Carpeta de Tomcat 11 |
| `DB_PASSWORD` | Si MySQL tiene clave | *(vacío)* | Contraseña del usuario de MySQL |
| `DB_USER` | No | `root` | Usuario de MySQL |
| `DB_URL` | No | `jdbc:mysql://localhost:3306/emisora_db?useSSL=false&allowPublicKeyRetrieval=true` | Dirección de la base de datos |
| `MAIL_SMTP_USER` | Para recuperar la clave | `xxxxxx@smtp-brevo.com` | Login SMTP (ver [Brevo](#configurar-el-envío-de-correo-con-brevo-gratis)) |
| `MAIL_SMTP_PASSWORD` | Para recuperar la clave | *(clave SMTP)* | Clave SMTP |
| `MAIL_FROM` | Para recuperar la clave | `correo@verificado.com` | Remitente verificado en Brevo |
| `MAIL_SMTP_HOST` | No | `smtp-relay.brevo.com` | Servidor SMTP |
| `MAIL_SMTP_PORT` | No | `2525` | Puerto SMTP |
| `MAIL_SMTP_STARTTLS` | No | `true` | Cifrar la conexión SMTP |
| `MAIL_FROM_NAME` | No | `Gestión de Emisoras` | Nombre del remitente |
| `APP_BASE_URL` | En Internet | `https://emisora.onrender.com` | Dirección pública usada en el enlace del correo |

Para dejarlas guardadas en Windows (una sola vez; luego **abrir una terminal nueva**):

```bat
setx CATALINA_HOME "C:\Users\joseq\Tomcat\apache-tomcat-11.0.26"
setx DB_PASSWORD "la-clave-de-root-de-mysql"
```

> La contraseña de MySQL **nunca** se escribe en el código: `ConnectionDbMySql` la lee de `DB_PASSWORD`.

### 3. Ejecutar

Desde la carpeta del proyecto:

```bat
scripts\run-local.bat
```

El script compila con Maven, copia `target\emisora.war` a Tomcat y lo inicia en la misma ventana.
Abrir <http://localhost:8080/emisora/> e iniciar sesión con un [usuario de prueba](#usuarios-de-prueba).
Para detener Tomcat: `Ctrl + C`.

**Alternativa con NetBeans:** *File → Open Project* sobre esta carpeta (se abre como proyecto Maven),
agregar Tomcat 11 en *Tools → Servers* y ejecutar con *Run*. Las variables de entorno deben existir antes
de abrir NetBeans.

## Despliegue en Internet (Render + TiDB Cloud Starter)

```
Navegador ──HTTPS──> Render (Docker: Tomcat 11 + ROOT.war) ──JDBC + TLS──> TiDB Cloud Starter (compatible con MySQL)
                               └──SMTP puerto 2525──> Brevo ──> correo de recuperación
```

- **[Dockerfile](Dockerfile)**: compila con Maven y ejecuta en Tomcat 11 (misma versión que en local).
- **[render.yaml](render.yaml)**: define el servicio web gratuito en Render; las claves se escriben en Render, no en GitHub.
- Plan gratuito de Render: si nadie visita la app en 15 minutos se "duerme" y la siguiente visita tarda
  alrededor de 1 minuto en responder.
- TiDB Cloud Starter se reactiva solo al recibir una conexión. TiDB no aplica por defecto las restricciones
  `CHECK` de las tablas; esas reglas también las validan `EmisoraService` y `UserService`.

### 1. Base de datos en TiDB Cloud Starter

1. Crear una cuenta en <https://tidbcloud.com> (se puede entrar con Google o GitHub).
2. Crear una instancia **Starter** (gratis) en **AWS · N. Virginia (us-east-1)**, cerca de Render.
3. En la instancia, pulsar **Connect** y generar la contraseña (**Generate Password** / *Set Root Password*).
   Anotar **Host**, **Port** (4000), **User** (tiene la forma `xxxxxxxx.root`) y **Password**.
4. Cargar los scripts desde la carpeta del proyecto (TiDB exige conexión cifrada):

   ```bat
   "C:\Program Files\MySQL\MySQL Server 9.7\bin\mysql.exe" --host=HOST --port=4000 --user=USUARIO --password --ssl-mode=REQUIRED < db\01_schema.sql
   "C:\Program Files\MySQL\MySQL Server 9.7\bin\mysql.exe" --host=HOST --port=4000 --user=USUARIO --password --ssl-mode=REQUIRED < db\02_data.sql
   ```

   Con el cliente de MySQL 9.x puede aparecer `Unknown column '$$' in 'field list'` al conectarse a TiDB:
   es una consulta interna del cliente y se puede ignorar. Los scripts y toda la aplicación se probaron con
   TiDB v8.5 en Docker.

### 2. Aplicación en Render

1. Crear una cuenta en <https://render.com> entrando con GitHub.
2. **New → Blueprint** y elegir el repositorio `Emisora`. Render lee `render.yaml`.
3. Escribir las variables que pide:

   | Variable | Valor |
   |---|---|
   | `DB_URL` | `jdbc:mysql://HOST:4000/emisora_db?sslMode=VERIFY_IDENTITY&enabledTLSProtocols=TLSv1.2,TLSv1.3&sessionVariables=time_zone='-05:00'` |
   | `DB_USER` | `xxxxxxxx.root` |
   | `DB_PASSWORD` | contraseña de TiDB |
   | `MAIL_SMTP_USER`, `MAIL_SMTP_PASSWORD`, `MAIL_FROM` | datos de [Brevo](#configurar-el-envío-de-correo-con-brevo-gratis) |
   | `APP_BASE_URL` | la dirección que asigne Render, ej. `https://emisora.onrender.com` |

   `sessionVariables=time_zone='-05:00'` hace que las fechas se guarden con la hora de Colombia.
4. Pulsar **Apply**. La primera construcción tarda varios minutos (se ve en *Logs*).
5. Si la dirección asignada es distinta a la escrita en `APP_BASE_URL`, corregirla en **Environment**
   (Render vuelve a desplegar solo).
6. Probar la dirección pública en una ventana de incógnito.

> **Importante:** las claves de los usuarios de prueba están publicadas en este README. En la aplicación
> desplegada conviene cambiarlas (menú *Buscar Usuario → Nueva Contraseña*) y entregar las nuevas solo al
> docente.

## Estado del desarrollo

- [x] Configuración inicial del proyecto (Maven WAR, Tomcat 11, estructura de la guía)
- [x] Base de datos: script de creación y datos iniciales
- [x] Modelo de dominio y conexión a MySQL
- [x] Persistencia y servicio de Usuario (excepciones, `UserCRUD`, `UserService`)
- [x] Controlador JSP y vistas de Usuario (`UserController.jsp`, login, create, find_edit_delete, list_all)
- [x] Persistencia y servicio de Emisora (excepciones, `EmisoraCRUD`, `EmisoraService`)
- [x] Controlador JSP y vistas de Emisora (`EmisoraController.jsp`, create, find_edit_delete, list_all)
- [x] Login, sesión y control de acceso por rol
- [x] Reportes parametrizados (2 por entidad)
- [x] Recuperación de clave por correo (enlace de un solo uso, JavaMail + SMTP de Brevo)
- [x] Despliegue en Internet (Render + TiDB Cloud Starter): <https://emisora-onnt.onrender.com>
