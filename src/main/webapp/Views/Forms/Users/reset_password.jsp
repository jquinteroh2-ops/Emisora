<%--
    Document   : reset_password
    Author     : José Quintero
    Vista: RECUPERACIÓN DE CLAVE (paso 2) - formulario para crear la nueva contraseña.
    Se llega desde el enlace del correo (UserController.jsp?action=showResetForm&token=...).
    Es pública: no exige sesión; la protección es el código (token) del enlace.
    Recibe (request): token (código ya validado), resetUser (dueño de la cuenta), errorMessage.
    Envía a: UserController.jsp?action=resetPassword
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Business.Services.UserService" %>
<%@ page import="Domain.Model.User" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%
    String token = (String) request.getAttribute("token");
    User resetUser = (User) request.getAttribute("resetUser");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%-- El enlace lleva el código en la URL: no se envía a otros sitios como "referer" --%>
    <meta name="referrer" content="no-referrer">
    <title>Nueva Contraseña</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Nueva Contraseña</h1>

    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (token == null) { %>
        <%-- Se abrió la vista sin pasar por el enlace del correo --%>
        <p>Para cambiar la contraseña abra el enlace que le enviamos por correo.</p>
        <p><a href="<%= request.getContextPath() %>/Controllers/UserController.jsp?action=showForgotForm">Solicitar un enlace</a></p>
    <% } else { %>
        <% if (resetUser != null) { %>
            <p>Cuenta: <strong><%= h(resetUser.getEmail()) %></strong></p>
        <% } %>

        <form action="<%= request.getContextPath() %>/Controllers/UserController.jsp" method="post">
            <input type="hidden" name="action" value="resetPassword">
            <input type="hidden" name="token" value="<%= h(token) %>">

            <label for="password">Nueva contraseña:</label>
            <input type="password" id="password" name="password" minlength="8" autocomplete="new-password" required autofocus>
            <span class="hint">Mínimo 8 caracteres.</span>

            <label for="confirmPassword">Repita la nueva contraseña:</label>
            <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" autocomplete="new-password" required>

            <input type="submit" value="Guardar contraseña">
        </form>
        <p class="hint">El enlace vence <%= UserService.RESET_TOKEN_MINUTES %> minutos después de solicitarlo y solo sirve una vez.</p>
    <% } %>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Views/Forms/Users/login.jsp">Volver a Iniciar Sesión</a>
    </p>
</main>
</body>
</html>
