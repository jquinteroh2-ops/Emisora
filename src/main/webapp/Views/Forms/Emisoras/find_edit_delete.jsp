<%--
    Document   : find_edit_delete (Emisoras)
    Author     : José Quintero
    Vista: buscar, editar o eliminar una emisora con UN solo formulario.
    Recibe (session): searchedEmisora, la emisora encontrada en la última búsqueda.
    Recibe (request): errorMessage / successMessage.
    El campo oculto "action" cambia con JavaScript (Views/Js/find_edit_delete.js)
    según el botón: search, update o delete.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Domain.Model.Emisora" %>
<%@ page import="Business.Services.EmisoraService" %>
<%@ include file="/WEB-INF/jspf/html.jspf" %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%-- Cualquier usuario con sesión puede consultar; editar y eliminar solo ADMIN y OPERADOR --%>
<% if (!checkAccess(request, response, session)) return; %>
<% boolean canEdit = hasRole(session, "ADMIN", "OPERADOR"); %>
<%!
    // Valor que se muestra en un campo del formulario de edición:
    // si al editar hubo un error, lo que el usuario acababa de escribir;
    // si no, el valor guardado de la emisora buscada.
    private String fieldValue(HttpServletRequest request, String param, Object savedValue) {
        String sentValue = request.getParameter(param);
        if (request.getAttribute("errorMessage") != null && sentValue != null) {
            return h(sentValue);
        }
        return h(savedValue);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Buscar, Editar o Eliminar Emisora</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/Views/Css/styles.css">
    <script src="<%= request.getContextPath() %>/Views/Js/find_edit_delete.js"></script>
</head>
<%-- Emisora encontrada en la búsqueda (guardada en la sesión por el controlador) --%>
<% Emisora sessionEmisora = (Emisora) session.getAttribute("searchedEmisora"); %>
<%-- Los botones Editar/Eliminar solo existen para ADMIN y OPERADOR --%>
<body onload="<%= !canEdit ? "" : (sessionEmisora != null) ? "enableButtons()" : "disableButtons()" %>">
<main class="container narrow">
    <h1><%= canEdit ? "Buscar, Editar o Eliminar Emisora" : "Consultar Emisora" %></h1>

    <%-- Mensajes de error o éxito --%>
    <% if (request.getAttribute("errorMessage") != null) { %>
        <p class="message error"><%= h(request.getAttribute("errorMessage")) %></p>
    <% } %>

    <% if (request.getAttribute("successMessage") != null) { %>
        <p class="message success"><%= h(request.getAttribute("successMessage")) %></p>
    <% } %>

    <%-- Formulario para buscar, editar y eliminar --%>
    <form id="emisoraForm" action="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp" method="post">
        <!-- El valor cambiará dinámicamente -->
        <input type="hidden" id="actionInput" name="action" value="search">

        <label for="code">Código de la emisora:</label>
        <input type="text" id="code" name="code" value="<%= sessionEmisora != null ? h(sessionEmisora.getCode()) : "" %>" required>

        <%-- Detalles de la emisora (después de la búsqueda) --%>
        <% if (sessionEmisora != null) { %>
            <div class="details">
                <h3>Detalles de la Emisora</h3>
                <p><strong>Código:</strong> <%= h(sessionEmisora.getCode()) %></p>
                <p><strong>Nombre:</strong> <%= h(sessionEmisora.getNombre()) %></p>
                <p><strong>Canal:</strong> <%= h(sessionEmisora.getCanal()) %></p>
                <p><strong>FM:</strong> <%= sessionEmisora.getBandaFm() != null ? sessionEmisora.getBandaFm() + " MHz" : "No transmite" %></p>
                <p><strong>AM:</strong> <%= sessionEmisora.getBandaAm() != null ? sessionEmisora.getBandaAm() + " kHz" : "No transmite" %></p>
                <p><strong>Locutores:</strong> <%= sessionEmisora.getNumLocutores() %></p>
                <p><strong>Género:</strong> <%= h(sessionEmisora.getGenero()) %></p>
                <p><strong>Horario:</strong> <%= h(sessionEmisora.getHorario()) %></p>
                <p><strong>Patrocinador:</strong> <%= sessionEmisora.getPatrocinador() != null ? h(sessionEmisora.getPatrocinador()) : "Sin patrocinador" %></p>
                <p><strong>País:</strong> <%= h(sessionEmisora.getPais()) %></p>
                <p><strong>Descripción:</strong> <%= h(sessionEmisora.getDescripcion()) %></p>
                <p><strong>Programas:</strong> <%= sessionEmisora.getNumProgramas() %></p>
                <p><strong>Ciudades:</strong> <%= sessionEmisora.getNumCiudades() %></p>
            </div>

            <%-- Campos de edición: solo ADMIN y OPERADOR (CONSULTA solo ve los detalles) --%>
            <% if (canEdit) { %>

            <label for="nombre">Nuevo Nombre:</label>
            <input type="text" id="nombre" name="nombre" maxlength="100"
                   value="<%= fieldValue(request, "nombre", sessionEmisora.getNombre()) %>" required>

            <label for="canal">Nuevo Canal o cadena:</label>
            <input type="text" id="canal" name="canal" maxlength="100"
                   value="<%= fieldValue(request, "canal", sessionEmisora.getCanal()) %>" required>

            <label for="bandaFm">Nueva Frecuencia FM (MHz):</label>
            <input type="text" id="bandaFm" name="bandaFm" inputmode="decimal"
                   value="<%= fieldValue(request, "bandaFm", sessionEmisora.getBandaFm()) %>">
            <span class="hint">Entre <%= EmisoraService.FM_MIN %> y <%= EmisoraService.FM_MAX %>. Vacía si no transmite en FM.</span>

            <label for="bandaAm">Nueva Frecuencia AM (kHz):</label>
            <input type="number" id="bandaAm" name="bandaAm" step="1"
                   min="<%= EmisoraService.AM_MIN %>" max="<%= EmisoraService.AM_MAX %>"
                   value="<%= fieldValue(request, "bandaAm", sessionEmisora.getBandaAm()) %>">
            <span class="hint">Entre <%= EmisoraService.AM_MIN %> y <%= EmisoraService.AM_MAX %>. Vacía si no transmite en AM.</span>

            <label for="numLocutores">Nuevo Número de locutores:</label>
            <input type="number" id="numLocutores" name="numLocutores" min="0" step="1"
                   value="<%= fieldValue(request, "numLocutores", sessionEmisora.getNumLocutores()) %>" required>

            <label for="genero">Nuevo Género:</label>
            <input type="text" id="genero" name="genero" maxlength="50"
                   value="<%= fieldValue(request, "genero", sessionEmisora.getGenero()) %>" required>

            <label for="horario">Nuevo Horario:</label>
            <input type="text" id="horario" name="horario" maxlength="100"
                   value="<%= fieldValue(request, "horario", sessionEmisora.getHorario()) %>" required>

            <label for="patrocinador">Nuevo Patrocinador (opcional):</label>
            <input type="text" id="patrocinador" name="patrocinador" maxlength="100"
                   value="<%= fieldValue(request, "patrocinador", sessionEmisora.getPatrocinador()) %>">

            <label for="pais">Nuevo País:</label>
            <input type="text" id="pais" name="pais" maxlength="60"
                   value="<%= fieldValue(request, "pais", sessionEmisora.getPais()) %>" required>

            <label for="descripcion">Nueva Descripción (opcional):</label>
            <textarea id="descripcion" name="descripcion" maxlength="500" rows="3"><%= fieldValue(request, "descripcion", sessionEmisora.getDescripcion()) %></textarea>

            <label for="numProgramas">Nuevo Número de programas:</label>
            <input type="number" id="numProgramas" name="numProgramas" min="0" step="1"
                   value="<%= fieldValue(request, "numProgramas", sessionEmisora.getNumProgramas()) %>" required>

            <label for="numCiudades">Nuevo Número de ciudades:</label>
            <input type="number" id="numCiudades" name="numCiudades" min="0" step="1"
                   value="<%= fieldValue(request, "numCiudades", sessionEmisora.getNumCiudades()) %>" required>
            <% } %>
        <% } else { %>
            <p>No se ha buscado ninguna emisora aún o la emisora no fue encontrada.</p>
        <% } %>

        <%-- Botones en la misma fila --%>
        <div class="actions">
            <button type="submit" id="searchBtn" formnovalidate onclick="setAction('search')">
                Buscar Emisora
            </button>
            <% if (canEdit) { %>
                <button type="button" id="editBtn" disabled
                        onclick="setActionAndSubmit('update', '¿Seguro que deseas editar esta emisora?')">
                    Editar Emisora
                </button>
                <button type="button" id="deleteBtn" class="danger" disabled
                        onclick="setActionAndSubmit('delete', '¿Seguro que deseas eliminar esta emisora?')">
                    Eliminar Emisora
                </button>
            <% } %>
        </div>
    </form>

    <p class="nav-links">
        <a href="<%= request.getContextPath() %>/Controllers/EmisoraController.jsp?action=listAll">Listar Emisoras</a> |
        <a href="<%= request.getContextPath() %>/index.jsp">MENÚ PRINCIPAL</a>
    </p>
</main>
</body>
</html>
