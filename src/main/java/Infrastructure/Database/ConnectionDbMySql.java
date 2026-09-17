package Infrastructure.Database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Conexión a MySQL con JDBC puro (DriverManager), igual que en la guía.
 *
 * Diferencia con la guía: los datos de conexión se pueden tomar de variables de
 * entorno (DB_URL, DB_USER, DB_PASSWORD). Así la contraseña real no se sube a GitHub
 * y el mismo código funciona en el computador local y en el servidor de Internet.
 * Si una variable no existe, se usa el valor local que aparece como segundo argumento.
 *
 * @author José Quintero
 */
public class ConnectionDbMySql {

    private static final String URL = getEnv("DB_URL",
            "jdbc:mysql://localhost:3306/emisora_db?useSSL=false&allowPublicKeyRetrieval=true");
    private static final String USER = getEnv("DB_USER", "root");
    private static final String PASSWORD = getEnv("DB_PASSWORD", "");
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    // Método que devuelve una conexión a la base de datos
    public static Connection getConnection() throws SQLException {
        Connection connection = null;
        try {
            Class.forName(DRIVER);
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("Error: Driver MySQL no encontrado.", e);
        } catch (SQLException e) {
            e.printStackTrace();
            var message = "Error: No se pudo establecer la conexión con la base de datos.";
            throw new SQLException(message, e);
        }
        return connection;
    }

    // Lee una variable de entorno; si no está definida, devuelve el valor por defecto
    private static String getEnv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isBlank()) ? defaultValue : value;
    }
}
