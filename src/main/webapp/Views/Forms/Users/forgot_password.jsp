<%--
    Document   : forgot_password
    Author     : José Quintero
    Vista: RECUPERACIÓN DE CLAVE (paso 1) - el usuario escribe su email para recibir el enlace.
    Es pública: no exige sesión.
    Recibe (request): successMessage / errorMessage.
    Envía a: UserController.jsp?action=sendResetLink
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Recuperar Contraseña</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Recuperar Contraseña</h1>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } else { %>
        <p>Escriba el email con el que se registró. Le enviaremos un enlace para crear una nueva contraseña.</p>

        <form action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="post">
            <input type="hidden" name="action" value="sendResetLink">

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" value="<%= h(request.getParameter("email")) %>" required autofocus>

            <input type="submit" value="Enviar enlace">
        </form>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Views/Forms/Users/login.jsp">Volver a Iniciar Sesión</a>
    </p>
</main>
</body>
</html>
