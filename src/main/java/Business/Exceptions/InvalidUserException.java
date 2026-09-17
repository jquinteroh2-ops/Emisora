package Business.Exceptions;

/**
 * Se lanza cuando los datos de un usuario no cumplen las reglas de negocio
 * (campos vacíos, email mal escrito, rol inexistente, clave muy corta).
 *
 * @author José Quintero
 */
public class InvalidUserException extends Exception {

    public InvalidUserException(String message) {
        super(message);
    }
}
