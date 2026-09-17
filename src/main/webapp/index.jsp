<%--
    Document   : index
    Author     : José Quintero
    Página de inicio. Revisa si hay un usuario en la sesión (loggedInUser):
    - si no hay, muestra solo el enlace para iniciar sesión;
    - si hay, muestra el menú de opciones.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Domain.Model.User" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gestión de Emisoras</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Bienvenido a la Gestión de Emisoras</h1>
    <p>Ejercicio 25 - Emisora</p>

    <%-- Mensaje del control de acceso (ej. rol sin permiso) --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Verificamos si el usuario ha iniciado sesión --%>
    <% User loggedInUser = (User) session.getAttribute("loggedInUser"); %>

    <% if (loggedInUser == null) { %>
        <%-- Si no ha iniciado sesión, mostramos la opción de login --%>
        <h3>No has iniciado sesión</h3>
        <a class="button" href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=login">Iniciar Sesión</a>
    <% } else { %>
        <%-- Si ha iniciado sesión, mostramos el menú según su rol --%>
        <% String role = loggedInUser.getRole(); %>
        <% boolean canEditEmisoras = role.equals("ADMIN") || role.equals("OPERADOR"); %>
        <h3>Hola, <%= h(loggedInUser.getName()) %> (Has iniciado sesión como <%= h(role) %>)</h3>

        <h2>Emisoras</h2>
        <ul class="menu">
            <% if (canEditEmisoras) { %>
                <li><a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=showCreateForm">Agregar Emisora</a></li>
                <li><a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=showFindForm">Buscar, Editar o Eliminar Emisora</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=showFindForm">Consultar Emisora</a></li>
            <% } %>
            <li><a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=listAll">Listar Todas las Emisoras</a></li>
        </ul>

        <%-- La gestión de usuarios solo se muestra al ADMIN --%>
        <% if (role.equals("ADMIN")) { %>
            <h2>Usuarios</h2>
            <ul class="menu">
                <li><a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=showCreateForm">Agregar Usuario</a></li>
                <li><a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=showFindForm">Buscar Usuario</a></li>
                <li><a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=listAll">Listar Todos los Usuarios</a></li>
            </ul>
        <% } %>

        <p class="nav-links">
            <a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=logout">Cerrar Sesión</a>
        </p>
    <% } %>
</main>
</body>
</html>
