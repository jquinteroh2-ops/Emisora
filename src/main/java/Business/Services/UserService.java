package Business.Services;

import Business.Exceptions.DuplicateUserException;
import Business.Exceptions.InvalidUserException;
import Business.Exceptions.UserNotFoundException;
import Domain.Model.User;
import Infrastructure.Persistence.UserCRUD;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.HexFormat;
import java.util.List;

/**
 * Lógica de negocio de Usuario. Es la capa que usa el controlador UserController.jsp.
 * Valida los datos, cifra las claves y le pide a UserCRUD que lea o escriba en la BD.
 * El controlador nunca habla directamente con UserCRUD.
 *
 * @author José Quintero
 */
public class UserService {

    // Roles permitidos (los mismos del CHECK de la tabla Users)
    public static final List<String> ROLES = List.of("ADMIN", "OPERADOR", "CONSULTA");

    // Longitud mínima de una clave nueva
    private static final int MIN_PASSWORD_LENGTH = 8;

    private static final String LOGIN_ERROR =
            "Credenciales incorrectas. No se encontró el usuario o la contraseña es incorrecta.";

    private UserCRUD userCrud;

    // Constructor
    public UserService() {
        this.userCrud = new UserCRUD();
    }

    // Método para obtener todos los usuarios
    public List<User> getAllUsers() throws SQLException {
        return userCrud.getAllUsers();
    }

    // Método para agregar un nuevo usuario
    public void createUser(String code, String name, String email, String password, String role)
            throws DuplicateUserException, InvalidUserException, SQLException {
        validateUserData(code, name, email, role);
        validatePassword(password);

        User user = new User(code.trim(), hashPassword(password), name.trim(), normalizeEmail(email), role);
        userCrud.addUser(user);
    }

    // Método para actualizar un usuario. Si la clave nueva viene vacía, se conserva la actual.
    public void updateUser(String code, String name, String email, String password, String role)
            throws UserNotFoundException, DuplicateUserException, InvalidUserException, SQLException {
        validateUserData(code, name, email, role);
        User currentUser = userCrud.getUserByCode(code.trim());

        String passwordHash;
        if (isBlank(password)) {
            passwordHash = currentUser.getPassword();
        } else {
            validatePassword(password);
            passwordHash = hashPassword(password);
        }

        User user = new User(currentUser.getCode(), passwordHash, name.trim(), normalizeEmail(email), role);
        userCrud.updateUser(user);
    }

    // Método para eliminar un usuario
    public void deleteUser(String code) throws UserNotFoundException, SQLException {
        if (isBlank(code)) {
            throw new UserNotFoundException("El código es requerido.");
        }
        userCrud.deleteUser(code.trim());
    }

    // Método para obtener un usuario por código
    public User getUserByCode(String code) throws UserNotFoundException, SQLException {
        if (isBlank(code)) {
            throw new UserNotFoundException("El código es requerido.");
        }
        return userCrud.getUserByCode(code.trim());
    }

    // Método para autenticar un usuario (login) con email y clave
    public User loginUser(String email, String password) throws UserNotFoundException, SQLException {
        if (isBlank(email) || isBlank(password)) {
            throw new UserNotFoundException(LOGIN_ERROR);
        }

        User user;
        try {
            user = userCrud.getUserByEmail(normalizeEmail(email));
        } catch (UserNotFoundException e) {
            // Mismo mensaje si el email no existe o si la clave está mal:
            // así no se revela qué correos están registrados
            throw new UserNotFoundException(LOGIN_ERROR);
        }

        // En la BD está la clave cifrada: se cifra la clave escrita y se comparan los resultados
        if (user.getPassword().equals(hashPassword(password))) {
            return user;
        } else {
            throw new UserNotFoundException(LOGIN_ERROR);
        }
    }

    // Método para buscar usuarios por código, nombre o email
    public List<User> searchUsers(String searchTerm) throws SQLException {
        return userCrud.searchUsers(isBlank(searchTerm) ? "" : searchTerm.trim());
    }

    // Cifra la clave con SHA-256 y la devuelve en hexadecimal (64 caracteres).
    // Da el mismo resultado que SHA2('clave', 256) de MySQL, usado en db/02_data.sql
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("El algoritmo SHA-256 no está disponible.", e);
        }
    }

    // Reglas para los datos de un usuario (al crear y al editar)
    private void validateUserData(String code, String name, String email, String role)
            throws InvalidUserException {
        if (isBlank(code) || isBlank(name) || isBlank(email) || isBlank(role)) {
            throw new InvalidUserException("Código, nombre, email y rol son obligatorios.");
        }
        if (code.trim().length() > 50) {
            throw new InvalidUserException("El código no puede tener más de 50 caracteres.");
        }
        if (!email.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw new InvalidUserException("El email " + email + " no tiene un formato válido.");
        }
        if (!ROLES.contains(role)) {
            throw new InvalidUserException("Rol no válido. Los roles permitidos son: " + String.join(", ", ROLES) + ".");
        }
    }

    // Regla para una clave nueva
    private void validatePassword(String password) throws InvalidUserException {
        if (isBlank(password) || password.length() < MIN_PASSWORD_LENGTH) {
            throw new InvalidUserException("La contraseña debe tener al menos " + MIN_PASSWORD_LENGTH + " caracteres.");
        }
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
