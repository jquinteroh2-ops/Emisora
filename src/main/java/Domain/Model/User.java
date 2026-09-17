package Domain.Model;

import java.time.LocalDateTime;

/**
 * Entidad Usuario (capa de dominio).
 * Clase plana (POJO): solo atributos, constructores, getters y setters. Sin lógica.
 * Cada objeto representa una fila de la tabla Users.
 *
 * @author José Quintero
 */
public class User {

    private String code;      // El "id" que pide la actividad
    private String password;  // Clave cifrada con SHA-256
    private String name;
    private String email;
    private String role;      // ADMIN, OPERADOR o CONSULTA
    private LocalDateTime createdAt;

    public User() {
    }

    public User(String code, String password, String name, String email, String role) {
        this.code = code;
        this.password = password;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    public User(String code, String password, String name, String email, String role, LocalDateTime createdAt) {
        this(code, password, name, email, role);
        this.createdAt = createdAt;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
