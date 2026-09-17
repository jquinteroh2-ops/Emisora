<%--
    Document   : list_all (Emisoras)
    Author     : José Quintero
    Vista: tabla con las emisoras.
    Recibe (request): emisoras (List<Emisora>), searchTerm (texto del filtro, si hay),
    errorMessage / successMessage.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="Domain.Model.Emisora" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lista de Emisoras</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container wide">
    <h1>Lista de Todas las Emisoras</h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Filtro: busca por código, nombre, canal, género o país (EmisoraService.searchEmisoras) --%>
    <form class="inline-form" action="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp" method="get">
        <input type="hidden" name="action" value="listAll">
        <input type="text" name="q" placeholder="Código, nombre, canal, género o país" value="<%= h(request.getAttribute("searchTerm")) %>">
        <button type="submit">Filtrar</button>
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=listAll">Ver todas</a>
    </form>

    <%-- Tabla para mostrar la lista de emisoras --%>
    <div class="table-wrapper">
    <table>
        <thead>
            <tr>
                <th>Código</th>
                <th>Nombre</th>
                <th>Canal</th>
                <th>Frecuencias</th>
                <th>Locutores</th>
                <th>Género</th>
                <th>Horario</th>
                <th>Patrocinador</th>
                <th>País</th>
                <th>Programas</th>
                <th>Ciudades</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
        <% List<Emisora> emisoras = (List<Emisora>) request.getAttribute("emisoras"); %>
        <% if (emisoras != null && !emisoras.isEmpty()) { %>
            <% for (Emisora emisora : emisoras) { %>
                <% String codeParam = h(URLEncoder.encode(emisora.getCode(), "UTF-8")); %>
                <tr>
                    <td><%= h(emisora.getCode()) %></td>
                    <td><%= h(emisora.getNombre()) %></td>
                    <td><%= h(emisora.getCanal()) %></td>
                    <td>
                        <% if (emisora.getBandaFm() != null) { %><%= emisora.getBandaFm() %> FM<br><% } %>
                        <% if (emisora.getBandaAm() != null) { %><%= emisora.getBandaAm() %> AM<% } %>
                    </td>
                    <td><%= emisora.getNumLocutores() %></td>
                    <td><%= h(emisora.getGenero()) %></td>
                    <td><%= h(emisora.getHorario()) %></td>
                    <td><%= h(emisora.getPatrocinador()) %></td>
                    <td><%= h(emisora.getPais()) %></td>
                    <td><%= emisora.getNumProgramas() %></td>
                    <td><%= emisora.getNumCiudades() %></td>
                    <td class="actions-cell">
                        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=search&code=<%= codeParam %>">Editar</a> |
                        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=deletefl&code=<%= codeParam %>"
                           onclick="return confirm('¿Seguro que deseas eliminar esta emisora?');">Eliminar</a>
                    </td>
                </tr>
            <% } %>
        <% } else { %>
            <tr>
                <td colspan="12">No hay emisoras disponibles</td>
            </tr>
        <% } %>
        </tbody>
    </table>
    </div>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=showCreateForm">Agregar Nueva Emisora</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
