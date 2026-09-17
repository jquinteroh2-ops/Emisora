package Business.Exceptions;

/**
 * Se lanza cuando los datos de una emisora no cumplen las reglas de negocio
 * (campos vacíos, números mal escritos, frecuencia fuera de rango, sin banda FM ni AM).
 *
 * @author José Quintero
 */
public class InvalidEmisoraException extends Exception {

    public InvalidEmisoraException(String message) {
        super(message);
    }
}
