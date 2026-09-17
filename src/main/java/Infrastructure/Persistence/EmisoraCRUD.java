package Infrastructure.Persistence;

import Business.Exceptions.DuplicateEmisoraException;
import Business.Exceptions.EmisoraNotFoundException;
import Business.Exceptions.InvalidEmisoraException;
import Domain.Model.Emisora;
import Infrastructure.Database.ConnectionDbMySql;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos de la tabla Emisoras (patrón DAO), igual que UserCRUD.
 * Cada método abre una conexión, ejecuta una sentencia SQL con PreparedStatement
 * y convierte las filas en objetos Emisora. Aquí no hay reglas de negocio:
 * eso lo hace EmisoraService.
 *
 * @author José Quintero
 */
public class EmisoraCRUD {

    // Código de error de MySQL para clave duplicada (PRIMARY KEY o UNIQUE)
    private static final int DUPLICATE_KEY_ERROR = 1062;
    // Código de error de MySQL cuando no se cumple una restricción CHECK de la tabla
    private static final int CHECK_CONSTRAINT_ERROR = 3819;

    // Método para obtener todas las emisoras
    public List<Emisora> getAllEmisoras() throws SQLException {
        List<Emisora> emisoraList = new ArrayList<>();
        String query = "SELECT * FROM Emisoras ORDER BY code";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                emisoraList.add(mapEmisora(rs));
            }
        }
        return emisoraList;
    }

    // Método para agregar una nueva emisora
    public void addEmisora(Emisora emisora)
            throws SQLException, DuplicateEmisoraException, InvalidEmisoraException {
        String query = "INSERT INTO Emisoras (nombre, canal, bandaFm, bandaAm, numLocutores, genero, horario, "
                + "patrocinador, pais, descripcion, numProgramas, numCiudades, code) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            setEmisoraParameters(stmt, emisora);  // Los 13 parámetros, el code va de último
            stmt.executeUpdate();
        } catch (SQLException e) {
            // Aquí manejamos una posible excepción de clave duplicada
            if (e.getErrorCode() == DUPLICATE_KEY_ERROR) {
                throw new DuplicateEmisoraException("La emisora con el código o nombre ya existe.");
            } else if (e.getErrorCode() == CHECK_CONSTRAINT_ERROR) {
                throw new InvalidEmisoraException("Los datos de la emisora no cumplen las reglas de la base de datos.");
            } else {
                throw e;  // Propagamos la excepción SQLException para que la maneje el servicio
            }
        }
    }

    // Método para actualizar una emisora (el código no cambia)
    public void updateEmisora(Emisora emisora)
            throws SQLException, EmisoraNotFoundException, DuplicateEmisoraException, InvalidEmisoraException {
        String query = "UPDATE Emisoras SET nombre=?, canal=?, bandaFm=?, bandaAm=?, numLocutores=?, genero=?, "
                + "horario=?, patrocinador=?, pais=?, descripcion=?, numProgramas=?, numCiudades=? "
                + "WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            setEmisoraParameters(stmt, emisora);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new EmisoraNotFoundException("La emisora con el código " + emisora.getCode() + " no existe.");
            }
        } catch (SQLException e) {
            // El nombre es UNIQUE: no puede quedar igual al de otra emisora
            if (e.getErrorCode() == DUPLICATE_KEY_ERROR) {
                throw new DuplicateEmisoraException("Ya existe otra emisora con el nombre " + emisora.getNombre() + ".");
            } else if (e.getErrorCode() == CHECK_CONSTRAINT_ERROR) {
                throw new InvalidEmisoraException("Los datos de la emisora no cumplen las reglas de la base de datos.");
            } else {
                throw e;  // Propagamos la excepción SQLException para que la maneje el servicio
            }
        }
    }

    // Método para eliminar una emisora
    public void deleteEmisora(String code) throws SQLException, EmisoraNotFoundException {
        String query = "DELETE FROM Emisoras WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, code);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new EmisoraNotFoundException("La emisora con el código " + code + " no existe.");
            }
        }
    }

    // Método para obtener una emisora por código
    public Emisora getEmisoraByCode(String code) throws SQLException, EmisoraNotFoundException {
        String query = "SELECT * FROM Emisoras WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, code);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapEmisora(rs);
                }
            }
        }
        throw new EmisoraNotFoundException("La emisora con el código " + code + " no existe.");
    }

    // Método para buscar emisoras por código, nombre, canal, género o país (búsqueda parcial)
    public List<Emisora> searchEmisoras(String searchTerm) throws SQLException {
        List<Emisora> emisoraList = new ArrayList<>();
        String query = "SELECT * "
                + "FROM Emisoras "
                + "WHERE code LIKE ? OR nombre LIKE ? OR canal LIKE ? OR genero LIKE ? OR pais LIKE ? "
                + "ORDER BY nombre";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            String pattern = "%" + searchTerm + "%";
            for (int i = 1; i <= 5; i++) {
                stmt.setString(i, pattern);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    emisoraList.add(mapEmisora(rs));
                }
            }
        }
        return emisoraList;
    }

    // ---------------------------------------------------------------------
    // REPORTES PARAMETRIZADOS
    // ---------------------------------------------------------------------

    // REPORTE 1: emisoras de un país; si genero es null, de todos los géneros
    public List<Emisora> getEmisorasByPaisAndGenero(String pais, String genero) throws SQLException {
        List<Emisora> emisoraList = new ArrayList<>();
        String query = (genero == null)
                ? "SELECT * FROM Emisoras WHERE pais = ? ORDER BY genero, nombre"
                : "SELECT * FROM Emisoras WHERE pais = ? AND genero = ? ORDER BY nombre";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, pais);
            if (genero != null) {
                stmt.setString(2, genero);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    emisoraList.add(mapEmisora(rs));
                }
            }
        }
        return emisoraList;
    }

    // REPORTE 2: emisoras por cobertura (rango de ciudades) con un mínimo de locutores,
    // de mayor a menor cobertura
    public List<Emisora> getEmisorasByCobertura(int minCiudades, int maxCiudades, int minLocutores)
            throws SQLException {
        List<Emisora> emisoraList = new ArrayList<>();
        String query = "SELECT * FROM Emisoras "
                + "WHERE numCiudades BETWEEN ? AND ? AND numLocutores >= ? "
                + "ORDER BY numCiudades DESC, nombre";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setInt(1, minCiudades);
            stmt.setInt(2, maxCiudades);
            stmt.setInt(3, minLocutores);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    emisoraList.add(mapEmisora(rs));
                }
            }
        }
        return emisoraList;
    }

    // Países registrados (sin repetir), para el desplegable del reporte 1
    public List<String> getDistinctPaises() throws SQLException {
        return getDistinctValues("SELECT DISTINCT pais FROM Emisoras ORDER BY pais");
    }

    // Géneros registrados (sin repetir), para el desplegable del reporte 1
    public List<String> getDistinctGeneros() throws SQLException {
        return getDistinctValues("SELECT DISTINCT genero FROM Emisoras ORDER BY genero");
    }

    // Ejecuta una consulta de una sola columna y devuelve sus valores
    private List<String> getDistinctValues(String query) throws SQLException {
        List<String> values = new ArrayList<>();

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                values.add(rs.getString(1));
            }
        }
        return values;
    }

    // Llena los parámetros ? de INSERT y UPDATE (mismo orden en ambas consultas; code al final)
    private void setEmisoraParameters(PreparedStatement stmt, Emisora emisora) throws SQLException {
        stmt.setString(1, emisora.getNombre());
        stmt.setString(2, emisora.getCanal());

        // Las frecuencias pueden no existir: en ese caso se guarda NULL
        if (emisora.getBandaFm() != null) {
            stmt.setDouble(3, emisora.getBandaFm());
        } else {
            stmt.setNull(3, Types.DECIMAL);
        }
        if (emisora.getBandaAm() != null) {
            stmt.setInt(4, emisora.getBandaAm());
        } else {
            stmt.setNull(4, Types.INTEGER);
        }

        stmt.setInt(5, emisora.getNumLocutores());
        stmt.setString(6, emisora.getGenero());
        stmt.setString(7, emisora.getHorario());
        stmt.setString(8, emisora.getPatrocinador());
        stmt.setString(9, emisora.getPais());
        stmt.setString(10, emisora.getDescripcion());
        stmt.setInt(11, emisora.getNumProgramas());
        stmt.setInt(12, emisora.getNumCiudades());
        stmt.setString(13, emisora.getCode());
    }

    // Convierte la fila actual del ResultSet en un objeto Emisora
    private Emisora mapEmisora(ResultSet rs) throws SQLException {
        return new Emisora(
                rs.getString("code"),
                rs.getString("nombre"),
                rs.getString("canal"),
                rs.getObject("bandaFm", Double.class),   // null si la columna es NULL
                rs.getObject("bandaAm", Integer.class),  // null si la columna es NULL
                rs.getInt("numLocutores"),
                rs.getString("genero"),
                rs.getString("horario"),
                rs.getString("patrocinador"),
                rs.getString("pais"),
                rs.getString("descripcion"),
                rs.getInt("numProgramas"),
                rs.getInt("numCiudades"));
    }
}
