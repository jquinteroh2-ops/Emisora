<%--
    Document   : create
    Author     : José Quintero
    Vista: formulario para agregar un usuario.
    Recibe (request): errorMessage / successMessage. Si hubo error, los parámetros
    enviados siguen en el request y se vuelven a mostrar en los campos.
    Envía a: UserController.jsp?action=create
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Business.Services.UserService" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Agregar Usuario</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Agregar Usuario</h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Rol elegido antes (si hubo error); por defecto el de menos permisos --%>
    <% String selectedRole = request.getParameter("role") != null ? request.getParameter("role") : "CONSULTA"; %>

    <%-- Formulario para agregar usuario --%>
    <form action="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=create" method="post">
        <label for="code">Código:</label>
        <input type="text" id="code" name="code" maxlength="50" value="<%= h(request.getParameter("code")) %>" required>

        <label for="name">Nombre:</label>
        <input type="text" id="name" name="name" maxlength="255" value="<%= h(request.getParameter("name")) %>" required>

        <label for="email">Email:</label>
        <input type="email" id="email" name="email" maxlength="255" value="<%= h(request.getParameter("email")) %>" required>

        <label for="password">Contraseña:</label>
        <input type="password" id="password" name="password" minlength="8" required>
        <span class="hint">Mínimo 8 caracteres.</span>

        <label for="role">Rol:</label>
        <select id="role" name="role" required>
            <% for (String role : UserService.ROLES) { %>
                <option value="<%= role %>" <%= role.equals(selectedRole) ? "selected" : "" %>><%= role %></option>
            <% } %>
        </select>

        <input type="submit" value="Agregar Usuario">
    </form>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=listAll">Listar Usuarios</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
