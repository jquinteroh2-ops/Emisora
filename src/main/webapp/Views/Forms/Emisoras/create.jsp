<%--
    Document   : create (Emisoras)
    Author     : José Quintero
    Vista: formulario para agregar una emisora (código + los 12 atributos del ejercicio 25).
    Recibe (request): errorMessage. Si hubo error, los parámetros enviados siguen en el
    request y se vuelven a mostrar en los campos.
    Envía a: EmisoraController.jsp?action=create
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Business.Services.EmisoraService" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Crear emisoras: solo ADMIN y OPERADOR --%>
<% if (!checkAccess(request, response, session, "ADMIN", "OPERADOR")) return; %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Agregar Emisora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Agregar Emisora</h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Formulario para agregar emisora --%>
    <form action="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=create" method="post">
        <label for="code">Código:</label>
        <input type="text" id="code" name="code" maxlength="20" placeholder="Ej. EM015"
               value="<%= h(request.getParameter("code")) %>" required>

        <label for="nombre">Nombre:</label>
        <input type="text" id="nombre" name="nombre" maxlength="100"
               value="<%= h(request.getParameter("nombre")) %>" required>

        <label for="canal">Canal o cadena:</label>
        <input type="text" id="canal" name="canal" maxlength="100" placeholder="Ej. Cadena Costa Norte"
               value="<%= h(request.getParameter("canal")) %>" required>

        <label for="bandaFm">Frecuencia FM (MHz):</label>
        <input type="text" id="bandaFm" name="bandaFm" inputmode="decimal" placeholder="Ej. 98.5"
               value="<%= h(request.getParameter("bandaFm")) %>">
        <span class="hint">Entre <%= EmisoraService.FM_MIN %> y <%= EmisoraService.FM_MAX %>. Vacía si no transmite en FM.</span>

        <label for="bandaAm">Frecuencia AM (kHz):</label>
        <input type="number" id="bandaAm" name="bandaAm" step="1" placeholder="Ej. 1040"
               min="<%= EmisoraService.AM_MIN %>" max="<%= EmisoraService.AM_MAX %>"
               value="<%= h(request.getParameter("bandaAm")) %>">
        <span class="hint">Entre <%= EmisoraService.AM_MIN %> y <%= EmisoraService.AM_MAX %>. Vacía si no transmite en AM. Debe tener al menos una banda.</span>

        <label for="numLocutores">Número de locutores:</label>
        <input type="number" id="numLocutores" name="numLocutores" min="0" step="1"
               value="<%= h(request.getParameter("numLocutores")) %>" required>

        <label for="genero">Género:</label>
        <input type="text" id="genero" name="genero" maxlength="50" placeholder="Ej. Noticias, Tropical, Rock"
               value="<%= h(request.getParameter("genero")) %>" required>

        <label for="horario">Horario:</label>
        <input type="text" id="horario" name="horario" maxlength="100" placeholder="Ej. 24 horas o 5:00 a.m. - 10:00 p.m."
               value="<%= h(request.getParameter("horario")) %>" required>

        <label for="patrocinador">Patrocinador (opcional):</label>
        <input type="text" id="patrocinador" name="patrocinador" maxlength="100"
               value="<%= h(request.getParameter("patrocinador")) %>">

        <label for="pais">País:</label>
        <input type="text" id="pais" name="pais" maxlength="60"
               value="<%= h(request.getParameter("pais")) %>" required>

        <label for="descripcion">Descripción (opcional):</label>
        <textarea id="descripcion" name="descripcion" maxlength="500" rows="3"><%= h(request.getParameter("descripcion")) %></textarea>

        <label for="numProgramas">Número de programas:</label>
        <input type="number" id="numProgramas" name="numProgramas" min="0" step="1"
               value="<%= h(request.getParameter("numProgramas")) %>" required>

        <label for="numCiudades">Número de ciudades con cobertura:</label>
        <input type="number" id="numCiudades" name="numCiudades" min="0" step="1"
               value="<%= h(request.getParameter("numCiudades")) %>" required>

        <input type="submit" value="Agregar Emisora">
    </form>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=listAll">Listar Emisoras</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">Menú Principal</a>
    </p>
</main>
</body>
</html>
