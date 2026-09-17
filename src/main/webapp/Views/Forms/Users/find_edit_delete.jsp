<%--
    Document   : find_edit_delete
    Author     : José Quintero
    Vista: buscar, editar o eliminar un usuario con UN solo formulario.
    Recibe (session): searchedUser, el usuario encontrado en la última búsqueda.
    Recibe (request): errorMessage / successMessage.
    El campo oculto "action" cambia con JavaScript (Views/Js/find_edit_delete.js)
    según el botón: search, update o delete.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Domain.Model.User" %>
<%@ page import="Business.Services.UserService" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Buscar, Editar o Eliminar Usuario</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
    <script src="<%= request.getContextPath() %>/Views/Js/find_edit_delete.js"></script>
</head>
<%-- Usuario encontrado en la búsqueda (guardado en la sesión por el controlador) --%>
<% User sessionUser = (User) session.getAttribute("searchedUser"); %>
<body onload="<%= (sessionUser != null) ? "enableButtons()" : "disableButtons()" %>">
<main class="container narrow">
    <h1>Buscar, Editar o Eliminar Usuario</h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Formulario para buscar, editar y eliminar --%>
    <form id="userForm" action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="post">
        <!-- El valor cambiará dinámicamente -->
        <input type="hidden" id="actionInput" name="action" value="search">

        <label for="code">Código del usuario:</label>
        <input type="text" id="code" name="code" value="<%= sessionUser != null ? h(sessionUser.getCode()) : "" %>" required>

        <%-- Detalles del usuario (después de la búsqueda) --%>
        <% if (sessionUser != null) { %>
            <div class="details">
                <h3>Detalles del Usuario</h3>
                <p><strong>Código:</strong> <%= h(sessionUser.getCode()) %></p>
                <p><strong>Nombre:</strong> <%= h(sessionUser.getName()) %></p>
                <p><strong>Email:</strong> <%= h(sessionUser.getEmail()) %></p>
                <p><strong>Rol:</strong> <%= h(sessionUser.getRole()) %></p>
            </div>

            <label for="name">Nuevo Nombre:</label>
            <input type="text" id="name" name="name" maxlength="255" value="<%= h(sessionUser.getName()) %>" required>

            <label for="email">Nuevo Email:</label>
            <input type="email" id="email" name="email" maxlength="255" value="<%= h(sessionUser.getEmail()) %>" required>

            <label for="role">Nuevo Rol:</label>
            <select id="role" name="role" required>
                <% for (String role : UserService.ROLES) { %>
                    <option value="<%= role %>" <%= role.equals(sessionUser.getRole()) ? "selected" : "" %>><%= role %></option>
                <% } %>
            </select>

            <label for="password">Nueva Contraseña:</label>
            <input type="password" id="password" name="password" minlength="8">
            <span class="hint">Déjala vacía para conservar la contraseña actual.</span>
        <% } else { %>
            <p>No se ha buscado ningún usuario aún o el usuario no fue encontrado.</p>
        <% } %>

        <%-- Botones en la misma fila --%>
        <div class="actions">
            <button type="submit" id="searchBtn" formnovalidate onclick="setAction('search')">
                Buscar Usuario
            </button>
            <button type="button" id="editBtn" disabled
                    onclick="setActionAndSubmit('update', '¿Seguro que deseas editar este usuario?')">
                Editar Usuario
            </button>
            <button type="button" id="deleteBtn" class="danger" disabled
                    onclick="setActionAndSubmit('delete', '¿Seguro que deseas eliminar este usuario?')">
                Eliminar Usuario
            </button>
        </div>
    </form>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=listAll">Listar Usuarios</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">MENÚ PRINCIPAL</a>
    </p>
</main>
</body>
</html>
