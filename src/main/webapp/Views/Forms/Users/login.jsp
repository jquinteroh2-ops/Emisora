<%--
    Document   : login
    Author     : José Quintero
    Vista: formulario de inicio de sesión.
    Recibe (request): errorMessage si las credenciales son incorrectas.
    Envía a: UserController.jsp?action=authenticate
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Iniciar Sesión</h1>

    <%-- Mensaje de error en caso de credenciales incorrectas --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <%-- Formulario de Login --%>
    <form action="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=authenticate" method="post">
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" value="<%= h(request.getParameter("email")) %>" required autofocus>

        <label for="password">Contraseña:</label>
        <input type="password" id="password" name="password" required>

        <input type="submit" value="Iniciar Sesión">
    </form>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/index.jsp">Volver a la página de inicio</a>
    </p>
</main>
</body>
</html>
