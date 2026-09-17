// Funciones del formulario "Buscar, Editar o Eliminar" (se usa en Usuarios y en Emisoras).
// Un solo formulario sirve para las tres operaciones: antes de enviarlo se cambia el
// campo oculto "action" para que el controlador JSP sepa qué método debe ejecutar.

// Función: habilitar los botones Editar y Eliminar (ya hay un registro buscado)
function enableButtons() {
    document.getElementById("editBtn").disabled = false;
    document.getElementById("deleteBtn").disabled = false;
}

// Función para deshabilitar los botones de Editar y Eliminar
function disableButtons() {
    document.getElementById("editBtn").disabled = true;
    document.getElementById("deleteBtn").disabled = true;
}

// Función: cambiar la acción del formulario sin enviarlo (la usa el botón Buscar)
function setAction(action) {
    document.getElementById("actionInput").value = action;
}

// Función: revisar campos obligatorios, pedir confirmación, cambiar la acción y enviar
function setActionAndSubmit(action, confirmMessage) {
    var form = document.getElementById("actionInput").form;

    if (!form.reportValidity()) {
        return;
    }
    if (confirmMessage) {
        if (!confirm(confirmMessage)) {
            return;
        }
    }
    setAction(action);
    form.submit();
}
