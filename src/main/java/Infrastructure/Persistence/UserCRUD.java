package Infrastructure.Persistence;

import Business.Exceptions.DuplicateUserException;
import Business.Exceptions.UserNotFoundException;
import Domain.Model.User;
import Infrastructure.Database.ConnectionDbMySql;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos de la tabla Users (patrón DAO).
 * Cada método abre una conexión, ejecuta una sentencia SQL con PreparedStatement
 * y convierte las filas en objetos User. Aquí no hay reglas de negocio:
 * eso lo hace UserService.
 *
 * Todas las conexiones se abren con try-with-resources, así se cierran solas
 * aunque ocurra un error.
 *
 * @author José Quintero
 */
public class UserCRUD {

    // Código de error de MySQL para clave duplicada (PRIMARY KEY o UNIQUE)
    private static final int DUPLICATE_KEY_ERROR = 1062;

    // Método para obtener todos los usuarios
    public List<User> getAllUsers() throws SQLException {
        List<User> userList = new ArrayList<>();
        String query = "SELECT * FROM Users ORDER BY code";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                userList.add(mapUser(rs));
            }
        }
        return userList;
    }

    // Método para agregar un nuevo usuario
    public void addUser(User user) throws SQLException, DuplicateUserException {
        String query = "INSERT INTO Users (code, password, name, email, role) VALUES (?, ?, ?, ?, ?)";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, user.getCode());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getName());
            stmt.setString(4, user.getEmail());
            stmt.setString(5, user.getRole());

            stmt.executeUpdate();
        } catch (SQLException e) {
            // Aquí manejamos una posible excepción de clave duplicada
            if (e.getErrorCode() == DUPLICATE_KEY_ERROR) {
                throw new DuplicateUserException("El usuario con el código o email ya existe.");
            } else {
                throw e;  // Propagamos la excepción SQLException para que la maneje el servicio
            }
        }
    }

    // Método para actualizar un usuario (el código no cambia)
    public void updateUser(User user) throws SQLException, UserNotFoundException, DuplicateUserException {
        String query = "UPDATE Users SET password=?, name=?, email=?, role=? WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, user.getPassword());
            stmt.setString(2, user.getName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getRole());
            stmt.setString(5, user.getCode());

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new UserNotFoundException("El usuario con el código " + user.getCode() + " no existe.");
            }
        } catch (SQLException e) {
            // El email es UNIQUE: no puede quedar igual al de otro usuario
            if (e.getErrorCode() == DUPLICATE_KEY_ERROR) {
                throw new DuplicateUserException("Ya existe otro usuario con el email " + user.getEmail() + ".");
            } else {
                throw e;  // Propagamos la excepción SQLException para que la maneje el servicio
            }
        }
    }

    // Método para eliminar un usuario
    public void deleteUser(String code) throws SQLException, UserNotFoundException {
        String query = "DELETE FROM Users WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, code);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new UserNotFoundException("El usuario con el código " + code + " no existe.");
            }
        }
    }

    // Método para obtener un usuario por código
    public User getUserByCode(String code) throws SQLException, UserNotFoundException {
        String query = "SELECT * FROM Users WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, code);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        throw new UserNotFoundException("El usuario con el código " + code + " no existe.");
    }

    // Método para obtener un usuario por email (lo usa el login)
    public User getUserByEmail(String email) throws SQLException, UserNotFoundException {
        String query = "SELECT * FROM Users WHERE email=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        throw new UserNotFoundException("El usuario con el email " + email + " no existe.");
    }

    // Método para buscar usuarios por código, nombre o email (búsqueda parcial)
    public List<User> searchUsers(String searchTerm) throws SQLException {
        List<User> userList = new ArrayList<>();
        String query = "SELECT * "
                + "FROM Users "
                + "WHERE code LIKE ? OR name LIKE ? OR email LIKE ? "
                + "ORDER BY name";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            String pattern = "%" + searchTerm + "%";
            stmt.setString(1, pattern);
            stmt.setString(2, pattern);
            stmt.setString(3, pattern);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    userList.add(mapUser(rs));
                }
            }
        }
        return userList;
    }

    // ---------------------------------------------------------------------
    // RECUPERACIÓN DE CLAVE
    // ---------------------------------------------------------------------

    // Guarda el código de recuperación (ya cifrado) y su fecha de vencimiento
    public void saveResetToken(String code, String resetTokenHash, LocalDateTime expires)
            throws SQLException, UserNotFoundException {
        String query = "UPDATE Users SET resetToken=?, resetTokenExpires=? WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, resetTokenHash);
            stmt.setObject(2, expires);
            stmt.setString(3, code);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new UserNotFoundException("El usuario con el código " + code + " no existe.");
            }
        }
    }

    // Busca el usuario dueño de un código de recuperación que todavía no ha vencido
    public User getUserByValidResetToken(String resetTokenHash, LocalDateTime now)
            throws SQLException, UserNotFoundException {
        String query = "SELECT * FROM Users WHERE resetToken=? AND resetTokenExpires > ?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, resetTokenHash);
            stmt.setObject(2, now);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        throw new UserNotFoundException("El enlace de recuperación no es válido o ya venció. Solicite uno nuevo.");
    }

    // Cambia la clave y borra el código de recuperación para que no se pueda usar otra vez
    public void updatePasswordAndClearToken(String code, String passwordHash)
            throws SQLException, UserNotFoundException {
        String query = "UPDATE Users SET password=?, resetToken=NULL, resetTokenExpires=NULL WHERE code=?";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, passwordHash);
            stmt.setString(2, code);

            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected == 0) {
                throw new UserNotFoundException("El usuario con el código " + code + " no existe.");
            }
        }
    }

    // ---------------------------------------------------------------------
    // REPORTES PARAMETRIZADOS
    // ---------------------------------------------------------------------

    // REPORTE 3: usuarios que tienen un rol
    public List<User> getUsersByRole(String role) throws SQLException {
        List<User> userList = new ArrayList<>();
        String query = "SELECT * FROM Users WHERE role = ? ORDER BY name";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setString(1, role);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    userList.add(mapUser(rs));
                }
            }
        }
        return userList;
    }

    // REPORTE 4: usuarios registrados desde "start" (incluido) hasta "end" (sin incluir),
    // del más antiguo al más reciente
    public List<User> getUsersByCreatedAtRange(LocalDateTime start, LocalDateTime end) throws SQLException {
        List<User> userList = new ArrayList<>();
        String query = "SELECT * FROM Users WHERE createdAt >= ? AND createdAt < ? ORDER BY createdAt";

        try (Connection con = ConnectionDbMySql.getConnection();
             PreparedStatement stmt = con.prepareStatement(query)) {

            stmt.setObject(1, start);
            stmt.setObject(2, end);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    userList.add(mapUser(rs));
                }
            }
        }
        return userList;
    }

    // Convierte la fila actual del ResultSet en un objeto User
    private User mapUser(ResultSet rs) throws SQLException {
        return new User(
                rs.getString("code"),
                rs.getString("password"),
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("role"),
                rs.getObject("createdAt", LocalDateTime.class));
    }
}
