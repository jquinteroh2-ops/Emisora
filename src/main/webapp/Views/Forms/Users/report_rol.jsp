<%--
    Document   : report_rol
    Author     : José Quintero
    Vista: REPORTE 3 - usuarios que tienen un rol.
    Recibe (request): users (List<User>) cuando ya se generó el reporte, errorMessage.
    Envía a (GET): UserController.jsp?action=reportRol&role=...
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Business.Services.UserService" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Solo el ADMIN consulta reportes de usuarios --%>
<% if (!checkAccess(request, response, session, "ADMIN")) return; %>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    String rolSeleccionado = request.getParameter("role");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reporte: Usuarios por Rol</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container">
    <h1>Reporte: Usuarios por Rol</h1>
    <p class="report-description">Muestra los usuarios que tienen el rol seleccionado.</p>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Parámetro del reporte --%>
    <form class="report-form" action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="get">
        <input type="hidden" name="action" value="reportRol">

        <div class="field">
            <label for="role">Rol:</label>
            <select id="role" name="role" required>
                <option value="">-- Seleccione --</option>
                <% for (String role : UserService.ROLES) { %>
                    <option value="<%= role %>" <%= role.equals(rolSeleccionado) ? "selected" : "" %>><%= role %></option>
                <% } %>
            </select>
        </div>

        <button type="submit">Generar reporte</button>
    </form>

    <%-- Resultado (solo después de generar el reporte) --%>
    <% if (users != null) { %>
        <h2>Resultado: rol <%= h(rolSeleccionado) %></h2>
        <%@ include file="/WEB-INF/jspf/user_report_table.jspf" %>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=reportFechas">Reporte por fecha de registro</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
