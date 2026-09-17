<%--
    Document   : UserController
    Author     : José Quintero

    CONTROLADOR DE USUARIOS: hace el trabajo de un Servlet, pero es un archivo JSP.
    1. Todas las peticiones de usuarios llegan aquí:
          /Controllers/UserController.jsp?action=...
    2. El scriptlet lee el parámetro "action" y el switch decide qué método atiende la petición.
    3. Cada método privado (bloque de declaración, más abajo) llama a UserService,
       guarda datos en request o session y hace forward o sendRedirect a una vista
       de /Views/Forms/Users.
    Tomcat convierte este JSP en una clase Java; los métodos de declaración quedan
    como métodos de esa clase.
--%>
<%@page import="java.util.List"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.io.IOException"%>
<%@page import="jakarta.servlet.ServletException"%>
<%@page import="jakarta.servlet.http.HttpServletRequest"%>
<%@page import="jakarta.servlet.http.HttpServletResponse"%>
<%@page import="jakarta.servlet.http.HttpSession"%>
<%@page import="Business.Services.UserService"%>
<%@page import="Domain.Model.User"%>
<%@page import="Business.Exceptions.UserNotFoundException"%>
<%@page import="Business.Exceptions.DuplicateUserException"%>
<%@page import="Business.Exceptions.InvalidUserException"%>
<%@include file="/WEB-INF/jspf/auth.jspf"%>
<%
    UserService userService = new UserService();
    String action = request.getParameter("action");

    if (action == null) {
        action = "list";
    }

    // CONTROL DE ACCESO: login, authenticate y logout son públicas;
    // todo lo demás (gestión de usuarios) exige sesión iniciada con rol ADMIN
    boolean publicAction = action.equals("login") || action.equals("authenticate") || action.equals("logout");
    if (!publicAction && !checkAccess(request, response, session, "ADMIN")) {
        return;
    }

    switch (action) {
        case "login":
            handleLogin(request, response, session);
            break;
        case "authenticate":
            handleAuthenticate(request, response, session, userService);
            break;
        case "showCreateForm":
            showCreateUserForm(request, response);
            break;
        case "create":
            handleCreateUser(request, response, userService);
            break;
        case "showFindForm":
            showFindForm(request, response, session, userService);
            break;
        case "search":
            handleSearch(request, response, session, userService);
            break;
        case "update":
            handleUpdateUser(request, response, session, userService);
            break;
        case "delete":
            handleDeleteUser(request, response, session, userService);
            break;
        case "deletefl":
            handleDeleteUserFromList(request, response, session, userService);
            break;
        case "listAll":
            handleListAllUsers(request, response, userService);
            break;
        case "reportRol":
            handleReportRol(request, response, userService);
            break;
        case "reportFechas":
            handleReportFechas(request, response, userService);
            break;
        case "logout":
            handleLogout(request, response, session);
            break;
        default:
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            break;
    }
%>
<%!
    // Rutas de las vistas de usuarios
    private static final String LOGIN_VIEW = "/Views/Forms/Users/login.jsp";
    private static final String CREATE_VIEW = "/Views/Forms/Users/create.jsp";
    private static final String FIND_EDIT_DELETE_VIEW = "/Views/Forms/Users/find_edit_delete.jsp";
    private static final String LIST_ALL_VIEW = "/Views/Forms/Users/list_all.jsp";
    private static final String REPORT_ROL_VIEW = "/Views/Forms/Users/report_rol.jsp";
    private static final String REPORT_FECHAS_VIEW = "/Views/Forms/Users/report_fechas.jsp";

    // Indica si el código corresponde al usuario que inició sesión
    private boolean isLoggedInUser(HttpSession session, String code) {
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        return loggedInUser != null && code != null && code.trim().equalsIgnoreCase(loggedInUser.getCode());
    }

    // Método para mostrar el formulario de login
    private void handleLogin(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        session.invalidate();  // Cerramos la sesión existente
        response.sendRedirect(request.getContextPath() + LOGIN_VIEW);
    }

    // Método para autenticar el usuario
    private void handleAuthenticate(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User loggedInUser = userService.loginUser(email, password);
            request.changeSessionId();  // Nuevo id de sesión al iniciar sesión (seguridad)
            session.setAttribute("loggedInUser", loggedInUser);  // Guardamos el usuario en la sesión
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        } catch (UserNotFoundException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos. Inténtelo de nuevo.");
            request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
        }
    }

    // Mostrar el formulario para crear un usuario
    private void showCreateUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + CREATE_VIEW);
    }

    // Método para crear un nuevo usuario (después de enviar el formulario)
    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response, UserService userService)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        try {
            userService.createUser(code, name, email, password, role);
            request.setAttribute("successMessage", "Usuario creado exitosamente.");
            handleListAllUsers(request, response, userService);
        } catch (DuplicateUserException | InvalidUserException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos. Inténtelo de nuevo.");
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
        }
    }

    // Mostrar el formulario para buscar, editar o eliminar un usuario
    private void showFindForm(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        session.removeAttribute("searchedUser");  // Empezamos sin usuario buscado
        request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
    }

    // Método para buscar un usuario
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        String searchCode = request.getParameter("code");

        try {
            User user = userService.getUserByCode(searchCode);
            session.setAttribute("searchedUser", user);  // Guardamos el usuario en la sesión
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (UserNotFoundException e) {
            session.removeAttribute("searchedUser");  // Limpiamos la sesión si no se encuentra el usuario
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para actualizar los datos del usuario
    private void handleUpdateUser(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        User searchedUser = (User) session.getAttribute("searchedUser");

        if (searchedUser == null) {
            request.setAttribute("errorMessage", "Primero debe buscar un usuario para editar.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        String code = searchedUser.getCode();  // Usamos el código del usuario buscado
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Nadie puede cambiar su propio rol (así un ADMIN no se quita los permisos por error)
        boolean isOwnUser = isLoggedInUser(session, code);
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        if (isOwnUser && !loggedInUser.getRole().equals(role)) {
            request.setAttribute("errorMessage", "No puede cambiar su propio rol.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        try {
            userService.updateUser(code, name, email, password, role);
            User updatedUser = userService.getUserByCode(code);
            session.setAttribute("searchedUser", updatedUser);  // Mostramos los datos nuevos
            if (isOwnUser) {
                session.setAttribute("loggedInUser", updatedUser);  // Si editó sus propios datos, se actualiza la sesión
            }
            request.setAttribute("successMessage", "Usuario actualizado exitosamente.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (UserNotFoundException e) {
            session.removeAttribute("searchedUser");
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (DuplicateUserException | InvalidUserException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para eliminar un usuario desde el enlace "Eliminar" de la lista
    private void handleDeleteUserFromList(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        var code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("errorMessage", "El código es requerido.");
            handleListAllUsers(request, response, userService);
            return;
        }

        if (isLoggedInUser(session, code)) {
            request.setAttribute("errorMessage", "No puede eliminar su propio usuario.");
            handleListAllUsers(request, response, userService);
            return;
        }

        try {
            userService.deleteUser(code);
            session.removeAttribute("searchedUser");
            request.setAttribute("successMessage", "Usuario eliminado exitosamente.");
            handleListAllUsers(request, response, userService);
        } catch (UserNotFoundException e) {
            request.setAttribute("errorMessage", e.getMessage());
            handleListAllUsers(request, response, userService);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            handleListAllUsers(request, response, userService);
        }
    }

    // Método para eliminar el usuario buscado en el formulario find_edit_delete
    private void handleDeleteUser(HttpServletRequest request, HttpServletResponse response, HttpSession session, UserService userService)
            throws ServletException, IOException {
        User searchedUser = (User) session.getAttribute("searchedUser");

        if (searchedUser == null) {
            request.setAttribute("errorMessage", "Primero debe buscar un usuario para eliminar.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        String code = searchedUser.getCode();  // Usamos el código del usuario buscado

        if (isLoggedInUser(session, code)) {
            request.setAttribute("errorMessage", "No puede eliminar su propio usuario.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        try {
            userService.deleteUser(code);
            session.removeAttribute("searchedUser");
            request.setAttribute("successMessage", "Usuario eliminado exitosamente.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (UserNotFoundException e) {
            session.removeAttribute("searchedUser");
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para listar los usuarios (todos, o filtrados si llega el parámetro q)
    private void handleListAllUsers(HttpServletRequest request, HttpServletResponse response, UserService userService)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("q");

        try {
            List<User> users;
            if (searchTerm == null || searchTerm.isBlank()) {
                users = userService.getAllUsers();
            } else {
                users = userService.searchUsers(searchTerm);
                request.setAttribute("searchTerm", searchTerm);
            }
            request.setAttribute("users", users);
            request.getRequestDispatcher(LIST_ALL_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al listar usuarios.");
            request.getRequestDispatcher(LIST_ALL_VIEW).forward(request, response);
        }
    }

    // REPORTE 3: usuarios que tienen un rol.
    // Sin el parámetro "role" solo muestra el formulario; con él, genera el reporte.
    private void handleReportRol(HttpServletRequest request, HttpServletResponse response, UserService userService)
            throws ServletException, IOException {
        String role = request.getParameter("role");

        if (role == null) {
            request.getRequestDispatcher(REPORT_ROL_VIEW).forward(request, response);
            return;
        }

        try {
            request.setAttribute("users", userService.reportByRole(role));
            request.getRequestDispatcher(REPORT_ROL_VIEW).forward(request, response);
        } catch (InvalidUserException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(REPORT_ROL_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al generar el reporte.");
            request.getRequestDispatcher(REPORT_ROL_VIEW).forward(request, response);
        }
    }

    // REPORTE 4: usuarios registrados entre dos fechas (ambas incluidas).
    // Sin parámetros solo muestra el formulario; con ellos, genera el reporte.
    private void handleReportFechas(HttpServletRequest request, HttpServletResponse response, UserService userService)
            throws ServletException, IOException {
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        if (fromDate == null && toDate == null) {
            request.getRequestDispatcher(REPORT_FECHAS_VIEW).forward(request, response);
            return;
        }

        try {
            request.setAttribute("users", userService.reportByCreatedAtRange(fromDate, toDate));
            request.getRequestDispatcher(REPORT_FECHAS_VIEW).forward(request, response);
        } catch (InvalidUserException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(REPORT_FECHAS_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al generar el reporte.");
            request.getRequestDispatcher(REPORT_FECHAS_VIEW).forward(request, response);
        }
    }

    // Método para cerrar sesión
    private void handleLogout(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        session.invalidate();  // Invalida la sesión actual
        response.sendRedirect(request.getContextPath() + LOGIN_VIEW);
    }
%>
