package Business.Services;

import Business.Exceptions.DuplicateUserException;
import Business.Exceptions.InvalidUserException;
import Business.Exceptions.UserNotFoundException;
import Domain.Model.User;
import Infrastructure.Mail.EmailSender;
import Infrastructure.Persistence.UserCRUD;
import jakarta.mail.MessagingException;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
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

    // Minutos que dura vigente un enlace de recuperación de clave
    public static final int RESET_TOKEN_MINUTES = 30;

    // Generador de números aleatorios apto para seguridad (códigos de recuperación)
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

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

        User user = new User(code.trim(), sha256(password), name.trim(), normalizeEmail(email), role);
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
            passwordHash = sha256(password);
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
        if (user.getPassword().equals(sha256(password))) {
            return user;
        } else {
            throw new UserNotFoundException(LOGIN_ERROR);
        }
    }

    // Método para buscar usuarios por código, nombre o email
    public List<User> searchUsers(String searchTerm) throws SQLException {
        return userCrud.searchUsers(isBlank(searchTerm) ? "" : searchTerm.trim());
    }

    // ---------------------------------------------------------------------
    // RECUPERACIÓN DE CLAVE POR CORREO
    // ---------------------------------------------------------------------

    // PASO 1: si el email está registrado, genera un código aleatorio, guarda su versión
    // cifrada con vencimiento y envía por correo el enlace para crear una clave nueva.
    // resetLinkPrefix es la dirección del formulario a la que se le agrega el código.
    // Si el email no existe no hace nada ni lanza error: así no se revela qué correos existen.
    public void requestPasswordReset(String email, String resetLinkPrefix)
            throws InvalidUserException, SQLException, MessagingException {
        if (isBlank(email) || !email.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw new InvalidUserException("Escriba un email válido.");
        }

        User user;
        try {
            user = userCrud.getUserByEmail(normalizeEmail(email));
        } catch (UserNotFoundException e) {
            return;
        }

        // Código de un solo uso: 32 bytes aleatorios seguros en hexadecimal (64 caracteres).
        // En la BD solo se guarda cifrado; el código original solo viaja en el correo.
        byte[] randomBytes = new byte[32];
        SECURE_RANDOM.nextBytes(randomBytes);
        String token = HexFormat.of().formatHex(randomBytes);
        LocalDateTime expires = LocalDateTime.now().plusMinutes(RESET_TOKEN_MINUTES);

        try {
            userCrud.saveResetToken(user.getCode(), sha256(token), expires);
        } catch (UserNotFoundException e) {
            return;  // El usuario se eliminó justo en este momento
        }

        String link = resetLinkPrefix + token;
        String subject = "Recuperación de contraseña - Gestión de Emisoras";
        String textBody = "Hola, " + user.getName() + ".\n\n"
                + "Recibimos una solicitud para restablecer tu contraseña.\n"
                + "Abre este enlace para crear una nueva (vence en " + RESET_TOKEN_MINUTES + " minutos):\n\n"
                + link + "\n\n"
                + "Si no fuiste tú, ignora este correo: tu contraseña actual seguirá funcionando.";
        String htmlBody = "<p>Hola, " + escapeHtml(user.getName()) + ".</p>"
                + "<p>Recibimos una solicitud para restablecer tu contraseña.</p>"
                + "<p><a href=\"" + escapeHtml(link) + "\" style=\"background:#1d4e89;color:#fff;"
                + "padding:10px 16px;border-radius:4px;text-decoration:none\">Crear nueva contraseña</a></p>"
                + "<p>El enlace vence en " + RESET_TOKEN_MINUTES + " minutos. Si el botón no funciona, copia esta dirección:<br>"
                + escapeHtml(link) + "</p>"
                + "<p>Si no fuiste tú, ignora este correo: tu contraseña actual seguirá funcionando.</p>";

        EmailSender.sendEmail(user.getEmail(), subject, textBody, htmlBody);
    }

    // PASO 2: comprueba que el código del enlace exista y no haya vencido; devuelve su usuario
    public User validateResetToken(String token) throws UserNotFoundException, SQLException {
        if (isBlank(token)) {
            throw new UserNotFoundException("El enlace de recuperación no es válido o ya venció. Solicite uno nuevo.");
        }
        return userCrud.getUserByValidResetToken(sha256(token.trim()), LocalDateTime.now());
    }

    // PASO 3: guarda la clave nueva (si el código sigue vigente) y anula el código
    public void resetPassword(String token, String newPassword, String confirmPassword)
            throws UserNotFoundException, InvalidUserException, SQLException {
        User user = validateResetToken(token);

        validatePassword(newPassword);
        if (!newPassword.equals(confirmPassword)) {
            throw new InvalidUserException("Las contraseñas no coinciden.");
        }

        userCrud.updatePasswordAndClearToken(user.getCode(), sha256(newPassword));
    }

    // Escapa caracteres especiales para insertar texto dentro del HTML del correo
    private String escapeHtml(String value) {
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    // ---------------------------------------------------------------------
    // REPORTES PARAMETRIZADOS (los parámetros llegan como texto desde el formulario)
    // ---------------------------------------------------------------------

    // REPORTE 3: usuarios que tienen un rol
    public List<User> reportByRole(String role) throws InvalidUserException, SQLException {
        if (isBlank(role) || !ROLES.contains(role)) {
            throw new InvalidUserException("Seleccione un rol válido: " + String.join(", ", ROLES) + ".");
        }
        return userCrud.getUsersByRole(role);
    }

    // REPORTE 4: usuarios registrados entre dos fechas, ambas incluidas (formato AAAA-MM-DD)
    public List<User> reportByCreatedAtRange(String fromDate, String toDate)
            throws InvalidUserException, SQLException {
        LocalDate from = parseDate(fromDate, "La fecha inicial");
        LocalDate to = parseDate(toDate, "La fecha final");

        if (from.isAfter(to)) {
            throw new InvalidUserException("La fecha inicial no puede ser posterior a la fecha final.");
        }
        // Desde las 00:00 de "from" hasta antes de las 00:00 del día siguiente a "to"
        return userCrud.getUsersByCreatedAtRange(from.atStartOfDay(), to.plusDays(1).atStartOfDay());
    }

    // Convierte un texto AAAA-MM-DD (lo que envía un campo type="date") en LocalDate
    private LocalDate parseDate(String value, String fieldLabel) throws InvalidUserException {
        if (isBlank(value)) {
            throw new InvalidUserException(fieldLabel + " es obligatoria.");
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            throw new InvalidUserException(fieldLabel + " no es válida (formato AAAA-MM-DD).");
        }
    }

    // Cifra un texto (una clave o un código de recuperación) con SHA-256 y lo devuelve en
    // hexadecimal (64 caracteres). Da el mismo resultado que SHA2('texto', 256) de MySQL,
    // usado en db/02_data.sql
    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
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
