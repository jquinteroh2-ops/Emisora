package Business.Services;

import Business.Exceptions.DuplicateEmisoraException;
import Business.Exceptions.EmisoraNotFoundException;
import Business.Exceptions.InvalidEmisoraException;
import Domain.Model.Emisora;
import Infrastructure.Persistence.EmisoraCRUD;

import java.sql.SQLException;
import java.util.List;

/**
 * Lógica de negocio de Emisora. Es la capa que usa el controlador EmisoraController.jsp.
 * 1. buildEmisora(): convierte el texto del formulario en un objeto Emisora.
 * 2. createEmisora() / updateEmisora(): validan las reglas del negocio y llaman a EmisoraCRUD.
 * El controlador nunca habla directamente con EmisoraCRUD.
 *
 * @author José Quintero
 */
public class EmisoraService {

    // Rangos de frecuencia permitidos (los mismos del CHECK de la tabla Emisoras)
    public static final double FM_MIN = 87.5;
    public static final double FM_MAX = 108.0;
    public static final int AM_MIN = 530;
    public static final int AM_MAX = 1710;

    private EmisoraCRUD emisoraCrud;

    // Constructor
    public EmisoraService() {
        this.emisoraCrud = new EmisoraCRUD();
    }

    // Método para obtener todas las emisoras
    public List<Emisora> getAllEmisoras() throws SQLException {
        return emisoraCrud.getAllEmisoras();
    }

    // Convierte los datos del formulario (todos llegan como texto) en un objeto Emisora.
    // Los campos opcionales vacíos quedan en null; los números se convierten y, si están
    // mal escritos, se lanza InvalidEmisoraException con un mensaje claro.
    public Emisora buildEmisora(String code, String nombre, String canal, String bandaFm, String bandaAm,
            String numLocutores, String genero, String horario, String patrocinador, String pais,
            String descripcion, String numProgramas, String numCiudades) throws InvalidEmisoraException {
        return new Emisora(
                trim(code),
                trim(nombre),
                trim(canal),
                parseFrecuenciaFm(bandaFm),
                parseOptionalInt(bandaAm, "La frecuencia AM"),
                parseRequiredInt(numLocutores, "El número de locutores"),
                trim(genero),
                trim(horario),
                emptyToNull(patrocinador),
                trim(pais),
                emptyToNull(descripcion),
                parseRequiredInt(numProgramas, "El número de programas"),
                parseRequiredInt(numCiudades, "El número de ciudades"));
    }

    // Método para agregar una nueva emisora
    public void createEmisora(Emisora emisora)
            throws DuplicateEmisoraException, InvalidEmisoraException, SQLException {
        validateEmisora(emisora);
        emisoraCrud.addEmisora(emisora);
    }

    // Método para actualizar una emisora (se identifica por su código, que no cambia)
    public void updateEmisora(Emisora emisora)
            throws EmisoraNotFoundException, DuplicateEmisoraException, InvalidEmisoraException, SQLException {
        validateEmisora(emisora);
        emisoraCrud.updateEmisora(emisora);
    }

    // Método para eliminar una emisora
    public void deleteEmisora(String code) throws EmisoraNotFoundException, SQLException {
        if (isBlank(code)) {
            throw new EmisoraNotFoundException("El código es requerido.");
        }
        emisoraCrud.deleteEmisora(code.trim());
    }

    // Método para obtener una emisora por código
    public Emisora getEmisoraByCode(String code) throws EmisoraNotFoundException, SQLException {
        if (isBlank(code)) {
            throw new EmisoraNotFoundException("El código es requerido.");
        }
        return emisoraCrud.getEmisoraByCode(code.trim());
    }

    // Método para buscar emisoras por código, nombre, canal, género o país
    public List<Emisora> searchEmisoras(String searchTerm) throws SQLException {
        return emisoraCrud.searchEmisoras(isBlank(searchTerm) ? "" : searchTerm.trim());
    }

    // ---------------------------------------------------------------------
    // REPORTES PARAMETRIZADOS (los parámetros llegan como texto desde el formulario)
    // ---------------------------------------------------------------------

    // REPORTE 1: emisoras de un país y, opcionalmente, de un género (vacío = todos los géneros)
    public List<Emisora> reportByPaisAndGenero(String pais, String genero)
            throws InvalidEmisoraException, SQLException {
        if (isBlank(pais)) {
            throw new InvalidEmisoraException("Seleccione un país para generar el reporte.");
        }
        return emisoraCrud.getEmisorasByPaisAndGenero(pais.trim(), emptyToNull(genero));
    }

    // REPORTE 2: emisoras que cubren entre minCiudades y maxCiudades y tienen al menos minLocutores
    public List<Emisora> reportByCobertura(String minCiudades, String maxCiudades, String minLocutores)
            throws InvalidEmisoraException, SQLException {
        int min = parseRequiredInt(minCiudades, "El mínimo de ciudades");
        int max = parseRequiredInt(maxCiudades, "El máximo de ciudades");
        int locutores = parseRequiredInt(minLocutores, "El mínimo de locutores");

        if (min < 0 || max < 0 || locutores < 0) {
            throw new InvalidEmisoraException("Los valores del reporte no pueden ser negativos.");
        }
        if (min > max) {
            throw new InvalidEmisoraException("El mínimo de ciudades no puede ser mayor que el máximo.");
        }
        return emisoraCrud.getEmisorasByCobertura(min, max, locutores);
    }

    // Países registrados, para el desplegable del reporte 1
    public List<String> getPaises() throws SQLException {
        return emisoraCrud.getDistinctPaises();
    }

    // Géneros registrados, para el desplegable del reporte 1
    public List<String> getGeneros() throws SQLException {
        return emisoraCrud.getDistinctGeneros();
    }

    // Reglas de negocio de una emisora (al crear y al editar)
    private void validateEmisora(Emisora emisora) throws InvalidEmisoraException {
        if (isBlank(emisora.getCode()) || isBlank(emisora.getNombre()) || isBlank(emisora.getCanal())
                || isBlank(emisora.getGenero()) || isBlank(emisora.getHorario()) || isBlank(emisora.getPais())) {
            throw new InvalidEmisoraException("Código, nombre, canal, género, horario y país son obligatorios.");
        }

        // Longitudes máximas de las columnas de la tabla
        checkMaxLength(emisora.getCode(), 20, "El código");
        checkMaxLength(emisora.getNombre(), 100, "El nombre");
        checkMaxLength(emisora.getCanal(), 100, "El canal");
        checkMaxLength(emisora.getGenero(), 50, "El género");
        checkMaxLength(emisora.getHorario(), 100, "El horario");
        checkMaxLength(emisora.getPatrocinador(), 100, "El patrocinador");
        checkMaxLength(emisora.getPais(), 60, "El país");
        checkMaxLength(emisora.getDescripcion(), 500, "La descripción");

        // Una emisora debe transmitir al menos en una banda
        if (emisora.getBandaFm() == null && emisora.getBandaAm() == null) {
            throw new InvalidEmisoraException("La emisora debe transmitir al menos en FM o en AM.");
        }
        if (emisora.getBandaFm() != null && (emisora.getBandaFm() < FM_MIN || emisora.getBandaFm() > FM_MAX)) {
            throw new InvalidEmisoraException("La frecuencia FM debe estar entre " + FM_MIN + " y " + FM_MAX + " MHz.");
        }
        if (emisora.getBandaAm() != null && (emisora.getBandaAm() < AM_MIN || emisora.getBandaAm() > AM_MAX)) {
            throw new InvalidEmisoraException("La frecuencia AM debe estar entre " + AM_MIN + " y " + AM_MAX + " kHz.");
        }

        if (emisora.getNumLocutores() < 0 || emisora.getNumProgramas() < 0 || emisora.getNumCiudades() < 0) {
            throw new InvalidEmisoraException("El número de locutores, programas y ciudades no puede ser negativo.");
        }
    }

    // Frecuencia FM opcional: acepta coma o punto decimal y la deja con un decimal (ej. 98,5 -> 98.5)
    private Double parseFrecuenciaFm(String value) throws InvalidEmisoraException {
        if (isBlank(value)) {
            return null;
        }
        try {
            double frecuencia = Double.parseDouble(value.trim().replace(',', '.'));
            if (!Double.isFinite(frecuencia)) {
                throw new NumberFormatException();
            }
            return Math.round(frecuencia * 10) / 10.0;
        } catch (NumberFormatException e) {
            throw new InvalidEmisoraException("La frecuencia FM debe ser un número, por ejemplo 98.5.");
        }
    }

    // Número entero opcional (vacío = null)
    private Integer parseOptionalInt(String value, String fieldLabel) throws InvalidEmisoraException {
        if (isBlank(value)) {
            return null;
        }
        return parseRequiredInt(value, fieldLabel);
    }

    // Número entero obligatorio
    private int parseRequiredInt(String value, String fieldLabel) throws InvalidEmisoraException {
        if (isBlank(value)) {
            throw new InvalidEmisoraException(fieldLabel + " es obligatorio.");
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            throw new InvalidEmisoraException(fieldLabel + " debe ser un número entero.");
        }
    }

    private void checkMaxLength(String value, int maxLength, String fieldLabel) throws InvalidEmisoraException {
        if (value != null && value.length() > maxLength) {
            throw new InvalidEmisoraException(fieldLabel + " no puede tener más de " + maxLength + " caracteres.");
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private String emptyToNull(String value) {
        return isBlank(value) ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
