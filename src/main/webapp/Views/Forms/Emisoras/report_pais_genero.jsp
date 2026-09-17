<%--
    Document   : report_pais_genero
    Author     : José Quintero
    Vista: REPORTE 1 - emisoras de un país, filtradas opcionalmente por género.
    Recibe (request): paises y generos (List<String>) para los desplegables,
    emisoras (List<Emisora>) cuando ya se generó el reporte, errorMessage.
    Envía a (GET): EmisoraController.jsp?action=reportPaisGenero&pais=...&genero=...
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="Domain.Model.Emisora" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Cualquier usuario con sesión puede consultar los reportes de emisoras --%>
<% if (!checkAccess(request, response, session)) return; %>
<%
    List<String> paises = (List<String>) request.getAttribute("paises");
    List<String> generos = (List<String>) request.getAttribute("generos");
    List<Emisora> emisoras = (List<Emisora>) request.getAttribute("emisoras");
    String paisSeleccionado = request.getParameter("pais");
    String generoSeleccionado = request.getParameter("genero");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reporte: Emisoras por País y Género</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container wide">
    <h1>Reporte: Emisoras por País y Género</h1>
    <p class="report-description">Muestra las emisoras de un país. Si elige un género, solo las de ese género.</p>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Parámetros del reporte: valores tomados de las emisoras registradas --%>
    <form class="report-form" action="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp" method="get">
        <input type="hidden" name="action" value="reportPaisGenero">

        <div class="field">
            <label for="pais">País:</label>
            <select id="pais" name="pais" required>
                <option value="">-- Seleccione --</option>
                <% if (paises != null) { for (String pais : paises) { %>
                    <option value="<%= h(pais) %>" <%= pais.equals(paisSeleccionado) ? "selected" : "" %>><%= h(pais) %></option>
                <% } } %>
            </select>
        </div>

        <div class="field">
            <label for="genero">Género:</label>
            <select id="genero" name="genero">
                <option value="">Todos los géneros</option>
                <% if (generos != null) { for (String genero : generos) { %>
                    <option value="<%= h(genero) %>" <%= genero.equals(generoSeleccionado) ? "selected" : "" %>><%= h(genero) %></option>
                <% } } %>
            </select>
        </div>

        <button type="submit">Generar reporte</button>
    </form>

    <%-- Resultado (solo después de generar el reporte) --%>
    <% if (emisoras != null) { %>
        <h2>Resultado: <%= h(paisSeleccionado) %> —
            <%= (generoSeleccionado == null || generoSeleccionado.isBlank()) ? "todos los géneros" : h(generoSeleccionado) %></h2>
        <%@ include file="/WEB-INF/jspf/emisora_report_table.jspf" %>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=reportCobertura">Reporte por cobertura</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
