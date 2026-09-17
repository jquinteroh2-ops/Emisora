package Business.Exceptions;

/**
 * Se lanza cuando una emisora no existe (buscar, editar, eliminar).
 *
 * @author José Quintero
 */
public class EmisoraNotFoundException extends Exception {

    public EmisoraNotFoundException(String message) {
        super(message);
    }
}
