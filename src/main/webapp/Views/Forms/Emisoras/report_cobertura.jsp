<%--
    Document   : report_cobertura
    Author     : José Quintero
    Vista: REPORTE 2 - emisoras por cobertura: número de ciudades dentro de un rango
    y con un mínimo de locutores, de mayor a menor cobertura.
    Recibe (request): emisoras (List<Emisora>) cuando ya se generó el reporte, errorMessage.
    Envía a (GET): EmisoraController.jsp?action=reportCobertura&minCiudades=...&maxCiudades=...&minLocutores=...
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Domain.Model.Emisora" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Cualquier usuario con sesión puede consultar los reportes de emisoras --%>
<% if (!checkAccess(request, response, session)) return; %>
<%!
    // Valor del campo: el enviado por el usuario o, la primera vez, un valor de ejemplo
    private String paramOrDefault(HttpServletRequest request, String param, String defaultValue) {
        String value = request.getParameter(param);
        return h(value != null ? value : defaultValue);
    }
%>
<% List<Emisora> emisoras = (List<Emisora>) request.getAttribute("emisoras"); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reporte: Emisoras por Cobertura</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container wide">
    <h1>Reporte: Emisoras por Cobertura</h1>
    <p class="report-description">Emisoras que llegan a un rango de ciudades y tienen al menos cierta cantidad
        de locutores, ordenadas de mayor a menor cobertura.</p>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Parámetros del reporte --%>
    <form class="report-form" action="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp" method="get">
        <input type="hidden" name="action" value="reportCobertura">

        <div class="field">
            <label for="minCiudades">Mínimo de ciudades:</label>
            <input type="number" id="minCiudades" name="minCiudades" min="0" step="1"
                   value="<%= paramOrDefault(request, "minCiudades", "10") %>" required>
        </div>

        <div class="field">
            <label for="maxCiudades">Máximo de ciudades:</label>
            <input type="number" id="maxCiudades" name="maxCiudades" min="0" step="1"
                   value="<%= paramOrDefault(request, "maxCiudades", "50") %>" required>
        </div>

        <div class="field">
            <label for="minLocutores">Mínimo de locutores:</label>
            <input type="number" id="minLocutores" name="minLocutores" min="0" step="1"
                   value="<%= paramOrDefault(request, "minLocutores", "10") %>" required>
        </div>

        <button type="submit">Generar reporte</button>
    </form>

    <%-- Resultado (solo después de generar el reporte) --%>
    <% if (emisoras != null) { %>
        <h2>Resultado: entre <%= h(request.getParameter("minCiudades")) %> y <%= h(request.getParameter("maxCiudades")) %>
            ciudades, con <%= h(request.getParameter("minLocutores")) %> locutores o más</h2>
        <%@ include file="/WEB-INF/jspf/emisora_report_table.jspf" %>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=reportPaisGenero">Reporte por país y género</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
