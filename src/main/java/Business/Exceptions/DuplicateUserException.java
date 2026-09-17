package Business.Exceptions;

/**
 * Se lanza cuando se intenta guardar un usuario con un código o email que ya existe.
 *
 * @author José Quintero
 */
public class DuplicateUserException extends Exception {

    public DuplicateUserException(String message) {
        super(message);
    }
}
