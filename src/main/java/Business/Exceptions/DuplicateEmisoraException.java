package Business.Exceptions;

/**
 * Se lanza cuando se intenta guardar una emisora con un código o nombre que ya existe.
 *
 * @author José Quintero
 */
public class DuplicateEmisoraException extends Exception {

    public DuplicateEmisoraException(String message) {
        super(message);
    }
}
