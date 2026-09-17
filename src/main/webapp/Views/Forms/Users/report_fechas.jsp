<%--
    Document   : report_fechas
    Author     : José Quintero
    Vista: REPORTE 4 - usuarios registrados entre dos fechas (ambas incluidas).
    Recibe (request): users (List<User>) cuando ya se generó el reporte, errorMessage.
    Envía a (GET): UserController.jsp?action=reportFechas&fromDate=AAAA-MM-DD&toDate=AAAA-MM-DD
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Solo el ADMIN consulta reportes de usuarios --%>
<% if (!checkAccess(request, response, session, "ADMIN")) return; %>
<% List<User> users = (List<User>) request.getAttribute("users"); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reporte: Usuarios por Fecha de Registro</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container">
    <h1>Reporte: Usuarios por Fecha de Registro</h1>
    <p class="report-description">Muestra los usuarios registrados entre dos fechas (ambas incluidas).</p>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Parámetros del reporte (type="date" envía el formato AAAA-MM-DD) --%>
    <form class="report-form" action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="get">
        <input type="hidden" name="action" value="reportFechas">

        <div class="field">
            <label for="fromDate">Desde:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%= h(request.getParameter("fromDate")) %>" required>
        </div>

        <div class="field">
            <label for="toDate">Hasta:</label>
            <input type="date" id="toDate" name="toDate" value="<%= h(request.getParameter("toDate")) %>" required>
        </div>

        <button type="submit">Generar reporte</button>
    </form>

    <%-- Resultado (solo después de generar el reporte) --%>
    <% if (users != null) { %>
        <%-- Si hay resultado, las fechas ya fueron validadas por el servicio: se muestran como dd/MM/yyyy --%>
        <% java.time.format.DateTimeFormatter formatoTitulo = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"); %>
        <h2>Resultado: del <%= java.time.LocalDate.parse(request.getParameter("fromDate").trim()).format(formatoTitulo) %>
            al <%= java.time.LocalDate.parse(request.getParameter("toDate").trim()).format(formatoTitulo) %></h2>
        <%@ include file="/WEB-INF/jspf/user_report_table.jspf" %>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=reportRol">Reporte por rol</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
