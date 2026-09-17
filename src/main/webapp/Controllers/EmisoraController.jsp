<%--
    Document   : EmisoraController
    Author     : José Quintero

    CONTROLADOR DE EMISORAS: mismo patrón que UserController.jsp (hace el trabajo
    de un Servlet, pero es un archivo JSP).
    1. Todas las peticiones de emisoras llegan aquí:
          /Controllers/EmisoraController.jsp?action=...
    2. El scriptlet lee el parámetro "action" y el switch decide qué método atiende la petición.
    3. Cada método privado (bloque de declaración, más abajo) llama a EmisoraService,
       guarda datos en request o session y hace forward o sendRedirect a una vista
       de /Views/Forms/Emisoras.
    El inicio y cierre de sesión (login, authenticate, logout) los atiende UserController.jsp.
--%>
<%@page import="java.util.List"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.io.IOException"%>
<%@page import="jakarta.servlet.ServletException"%>
<%@page import="jakarta.servlet.http.HttpServletRequest"%>
<%@page import="jakarta.servlet.http.HttpServletResponse"%>
<%@page import="jakarta.servlet.http.HttpSession"%>
<%@page import="Business.Services.EmisoraService"%>
<%@page import="Domain.Model.Emisora"%>
<%@page import="Business.Exceptions.EmisoraNotFoundException"%>
<%@page import="Business.Exceptions.DuplicateEmisoraException"%>
<%@page import="Business.Exceptions.InvalidEmisoraException"%>
<%@include file="/WEB-INF/jspf/auth.jspf"%>
<%
    EmisoraService emisoraService = new EmisoraService();
    String action = request.getParameter("action");

    if (action == null) {
        action = "list";
    }

    // CONTROL DE ACCESO: toda acción de emisoras exige sesión iniciada (cualquier rol);
    // las que crean, editan o eliminan datos solo para ADMIN y OPERADOR
    boolean changesData = action.equals("showCreateForm") || action.equals("create")
            || action.equals("update") || action.equals("delete") || action.equals("deletefl");
    boolean hasAccess = changesData
            ? checkAccess(request, response, session, "ADMIN", "OPERADOR")
            : checkAccess(request, response, session);
    if (!hasAccess) {
        return;
    }

    switch (action) {
        case "showCreateForm":
            showCreateEmisoraForm(request, response);
            break;
        case "create":
            handleCreateEmisora(request, response, emisoraService);
            break;
        case "showFindForm":
            showFindForm(request, response, session);
            break;
        case "search":
            handleSearch(request, response, session, emisoraService);
            break;
        case "update":
            handleUpdateEmisora(request, response, session, emisoraService);
            break;
        case "delete":
            handleDeleteEmisora(request, response, session, emisoraService);
            break;
        case "deletefl":
            handleDeleteEmisoraFromList(request, response, session, emisoraService);
            break;
        case "listAll":
            handleListAllEmisoras(request, response, emisoraService);
            break;
        case "reportPaisGenero":
            handleReportPaisGenero(request, response, emisoraService);
            break;
        case "reportCobertura":
            handleReportCobertura(request, response, emisoraService);
            break;
        default:
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            break;
    }
%>
<%!
    // Rutas de las vistas de emisoras
    private static final String CREATE_VIEW = "/Views/Forms/Emisoras/create.jsp";
    private static final String FIND_EDIT_DELETE_VIEW = "/Views/Forms/Emisoras/find_edit_delete.jsp";
    private static final String LIST_ALL_VIEW = "/Views/Forms/Emisoras/list_all.jsp";
    private static final String REPORT_PAIS_GENERO_VIEW = "/Views/Forms/Emisoras/report_pais_genero.jsp";
    private static final String REPORT_COBERTURA_VIEW = "/Views/Forms/Emisoras/report_cobertura.jsp";

    // Lee los campos del formulario y los convierte en un objeto Emisora (EmisoraService.buildEmisora)
    private Emisora readEmisoraForm(HttpServletRequest request, EmisoraService emisoraService, String code)
            throws InvalidEmisoraException {
        return emisoraService.buildEmisora(
                code,
                request.getParameter("nombre"),
                request.getParameter("canal"),
                request.getParameter("bandaFm"),
                request.getParameter("bandaAm"),
                request.getParameter("numLocutores"),
                request.getParameter("genero"),
                request.getParameter("horario"),
                request.getParameter("patrocinador"),
                request.getParameter("pais"),
                request.getParameter("descripcion"),
                request.getParameter("numProgramas"),
                request.getParameter("numCiudades"));
    }

    // Mostrar el formulario para crear una emisora
    private void showCreateEmisoraForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + CREATE_VIEW);
    }

    // Método para crear una nueva emisora (después de enviar el formulario)
    private void handleCreateEmisora(HttpServletRequest request, HttpServletResponse response, EmisoraService emisoraService)
            throws ServletException, IOException {
        try {
            Emisora emisora = readEmisoraForm(request, emisoraService, request.getParameter("code"));
            emisoraService.createEmisora(emisora);
            request.setAttribute("successMessage", "Emisora creada exitosamente.");
            handleListAllEmisoras(request, response, emisoraService);
        } catch (DuplicateEmisoraException | InvalidEmisoraException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos. Inténtelo de nuevo.");
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
        }
    }

    // Mostrar el formulario para buscar, editar o eliminar una emisora
    private void showFindForm(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        session.removeAttribute("searchedEmisora");  // Empezamos sin emisora buscada
        request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
    }

    // Método para buscar una emisora por código
    private void handleSearch(HttpServletRequest request, HttpServletResponse response, HttpSession session, EmisoraService emisoraService)
            throws ServletException, IOException {
        String searchCode = request.getParameter("code");

        try {
            Emisora emisora = emisoraService.getEmisoraByCode(searchCode);
            session.setAttribute("searchedEmisora", emisora);  // Guardamos la emisora en la sesión
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (EmisoraNotFoundException e) {
            session.removeAttribute("searchedEmisora");  // Limpiamos la sesión si no se encuentra
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para actualizar los datos de la emisora buscada
    private void handleUpdateEmisora(HttpServletRequest request, HttpServletResponse response, HttpSession session, EmisoraService emisoraService)
            throws ServletException, IOException {
        Emisora searchedEmisora = (Emisora) session.getAttribute("searchedEmisora");

        if (searchedEmisora == null) {
            request.setAttribute("errorMessage", "Primero debe buscar una emisora para editar.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        String code = searchedEmisora.getCode();  // Usamos el código de la emisora buscada

        try {
            Emisora emisora = readEmisoraForm(request, emisoraService, code);
            emisoraService.updateEmisora(emisora);
            session.setAttribute("searchedEmisora", emisoraService.getEmisoraByCode(code));  // Mostramos los datos nuevos
            request.setAttribute("successMessage", "Emisora actualizada exitosamente.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (EmisoraNotFoundException e) {
            session.removeAttribute("searchedEmisora");
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (DuplicateEmisoraException | InvalidEmisoraException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para eliminar una emisora desde el enlace "Eliminar" de la lista
    private void handleDeleteEmisoraFromList(HttpServletRequest request, HttpServletResponse response, HttpSession session, EmisoraService emisoraService)
            throws ServletException, IOException {
        var code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("errorMessage", "El código es requerido.");
            handleListAllEmisoras(request, response, emisoraService);
            return;
        }

        try {
            emisoraService.deleteEmisora(code);
            session.removeAttribute("searchedEmisora");
            request.setAttribute("successMessage", "Emisora eliminada exitosamente.");
            handleListAllEmisoras(request, response, emisoraService);
        } catch (EmisoraNotFoundException e) {
            request.setAttribute("errorMessage", e.getMessage());
            handleListAllEmisoras(request, response, emisoraService);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            handleListAllEmisoras(request, response, emisoraService);
        }
    }

    // Método para eliminar la emisora buscada en el formulario find_edit_delete
    private void handleDeleteEmisora(HttpServletRequest request, HttpServletResponse response, HttpSession session, EmisoraService emisoraService)
            throws ServletException, IOException {
        Emisora searchedEmisora = (Emisora) session.getAttribute("searchedEmisora");

        if (searchedEmisora == null) {
            request.setAttribute("errorMessage", "Primero debe buscar una emisora para eliminar.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
            return;
        }

        String code = searchedEmisora.getCode();  // Usamos el código de la emisora buscada

        try {
            emisoraService.deleteEmisora(code);
            session.removeAttribute("searchedEmisora");
            request.setAttribute("successMessage", "Emisora eliminada exitosamente.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (EmisoraNotFoundException e) {
            session.removeAttribute("searchedEmisora");
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos.");
            request.getRequestDispatcher(FIND_EDIT_DELETE_VIEW).forward(request, response);
        }
    }

    // Método para listar las emisoras (todas, o filtradas si llega el parámetro q)
    private void handleListAllEmisoras(HttpServletRequest request, HttpServletResponse response, EmisoraService emisoraService)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("q");

        try {
            List<Emisora> emisoras;
            if (searchTerm == null || searchTerm.isBlank()) {
                emisoras = emisoraService.getAllEmisoras();
            } else {
                emisoras = emisoraService.searchEmisoras(searchTerm);
                request.setAttribute("searchTerm", searchTerm);
            }
            request.setAttribute("emisoras", emisoras);
            request.getRequestDispatcher(LIST_ALL_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al listar emisoras.");
            request.getRequestDispatcher(LIST_ALL_VIEW).forward(request, response);
        }
    }

    // REPORTE 1: emisoras de un país, filtradas opcionalmente por género.
    // Sin el parámetro "pais" solo muestra el formulario; con él, genera el reporte.
    private void handleReportPaisGenero(HttpServletRequest request, HttpServletResponse response, EmisoraService emisoraService)
            throws ServletException, IOException {
        String pais = request.getParameter("pais");
        String genero = request.getParameter("genero");

        try {
            // Valores para los desplegables del formulario (países y géneros registrados)
            request.setAttribute("paises", emisoraService.getPaises());
            request.setAttribute("generos", emisoraService.getGeneros());

            if (pais != null) {
                request.setAttribute("emisoras", emisoraService.reportByPaisAndGenero(pais, genero));
            }
            request.getRequestDispatcher(REPORT_PAIS_GENERO_VIEW).forward(request, response);
        } catch (InvalidEmisoraException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(REPORT_PAIS_GENERO_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al generar el reporte.");
            request.getRequestDispatcher(REPORT_PAIS_GENERO_VIEW).forward(request, response);
        }
    }

    // REPORTE 2: emisoras por cobertura (rango de ciudades) con un mínimo de locutores.
    // Sin parámetros solo muestra el formulario; con ellos, genera el reporte.
    private void handleReportCobertura(HttpServletRequest request, HttpServletResponse response, EmisoraService emisoraService)
            throws ServletException, IOException {
        String minCiudades = request.getParameter("minCiudades");
        String maxCiudades = request.getParameter("maxCiudades");
        String minLocutores = request.getParameter("minLocutores");

        if (minCiudades == null && maxCiudades == null && minLocutores == null) {
            request.getRequestDispatcher(REPORT_COBERTURA_VIEW).forward(request, response);
            return;
        }

        try {
            request.setAttribute("emisoras", emisoraService.reportByCobertura(minCiudades, maxCiudades, minLocutores));
            request.getRequestDispatcher(REPORT_COBERTURA_VIEW).forward(request, response);
        } catch (InvalidEmisoraException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher(REPORT_COBERTURA_VIEW).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error de base de datos al generar el reporte.");
            request.getRequestDispatcher(REPORT_COBERTURA_VIEW).forward(request, response);
        }
    }
%>
