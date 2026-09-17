<%--
    Document   : list_all
    Author     : José Quintero
    Vista: tabla con los usuarios.
    Recibe (request): users (List<User>), searchTerm (texto del filtro, si hay),
    errorMessage / successMessage.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="Domain.Model.User" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Solo el ADMIN gestiona usuarios --%>
<% if (!checkAccess(request, response, session, "ADMIN")) return; %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lista de Usuarios</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container">
    <h1>Lista de Todos los Usuarios</h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Filtro: busca por código, nombre o email (UserService.searchUsers) --%>
    <form class="inline-form" action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="get">
        <input type="hidden" name="action" value="listAll">
        <input type="text" name="q" placeholder="Código, nombre o email" value="<%= h(request.getAttribute("searchTerm")) %>">
        <button type="submit">Filtrar</button>
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=listAll">Ver todos</a>
    </form>

    <%-- Tabla para mostrar la lista de usuarios --%>
    <div class="table-wrapper">
    <table>
        <thead>
            <tr>
                <th>Código</th>
                <th>Nombre</th>
                <th>Email</th>
                <th>Rol</th>
                <th>Registrado</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
        <%
            List<User> users = (List<User>) request.getAttribute("users");
            DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        %>
        <% if (users != null && !users.isEmpty()) { %>
            <% for (User user : users) { %>
                <tr>
                    <td><%= h(user.getCode()) %></td>
                    <td><%= h(user.getName()) %></td>
                    <td>
                        <%-- Enlace mailto: abre el cliente de correo --%>
                        <a href="mailto:<%= h(user.getEmail()) %>"><%= h(user.getEmail()) %></a>
                    </td>
                    <td><%= h(user.getRole()) %></td>
                    <td><%= user.getCreatedAt() != null ? user.getCreatedAt().format(dateFormat) : "" %></td>
                    <td class="actions-cell">
                        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=search&code=<%= h(java.net.URLEncoder.encode(user.getCode(), "UTF-8")) %>">Editar</a> |
                        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=deletefl&code=<%= h(java.net.URLEncoder.encode(user.getCode(), "UTF-8")) %>"
                           onclick="return confirm('¿Seguro que deseas eliminar este usuario?');">Eliminar</a>
                    </td>
                </tr>
            <% } %>
        <% } else { %>
            <tr>
                <td colspan="6">No hay usuarios disponibles</td>
            </tr>
        <% } %>
        </tbody>
    </table>
    </div>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=showCreateForm">Agregar Nuevo Usuario</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
