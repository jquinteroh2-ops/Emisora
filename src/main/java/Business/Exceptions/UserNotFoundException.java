package Business.Exceptions;

/**
 * Se lanza cuando un usuario no existe (buscar, editar, eliminar)
 * o cuando las credenciales del login son incorrectas.
 *
 * @author José Quintero
 */
public class UserNotFoundException extends Exception {

    public UserNotFoundException(String message) {
        super(message);
    }
}
