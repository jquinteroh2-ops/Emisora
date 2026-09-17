package Domain.Model;

/**
 * Entidad Emisora (capa de dominio) - Ejercicio 25.
 * Clase plana (POJO): solo atributos, constructores, getters y setters. Sin lógica.
 * Cada objeto representa una fila de la tabla Emisoras.
 *
 * @author José Quintero
 */
public class Emisora {

    private String code;          // Clave primaria, ej. EM001
    private String nombre;
    private String canal;
    private Double bandaFm;       // Frecuencia FM en MHz; null si no transmite en FM
    private Integer bandaAm;      // Frecuencia AM en kHz; null si no transmite en AM
    private int numLocutores;
    private String genero;
    private String horario;
    private String patrocinador;
    private String pais;
    private String descripcion;
    private int numProgramas;
    private int numCiudades;

    public Emisora() {
    }

    public Emisora(String code, String nombre, String canal, Double bandaFm, Integer bandaAm,
            int numLocutores, String genero, String horario, String patrocinador, String pais,
            String descripcion, int numProgramas, int numCiudades) {
        this.code = code;
        this.nombre = nombre;
        this.canal = canal;
        this.bandaFm = bandaFm;
        this.bandaAm = bandaAm;
        this.numLocutores = numLocutores;
        this.genero = genero;
        this.horario = horario;
        this.patrocinador = patrocinador;
        this.pais = pais;
        this.descripcion = descripcion;
        this.numProgramas = numProgramas;
        this.numCiudades = numCiudades;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCanal() {
        return canal;
    }

    public void setCanal(String canal) {
        this.canal = canal;
    }

    public Double getBandaFm() {
        return bandaFm;
    }

    public void setBandaFm(Double bandaFm) {
        this.bandaFm = bandaFm;
    }

    public Integer getBandaAm() {
        return bandaAm;
    }

    public void setBandaAm(Integer bandaAm) {
        this.bandaAm = bandaAm;
    }

    public int getNumLocutores() {
        return numLocutores;
    }

    public void setNumLocutores(int numLocutores) {
        this.numLocutores = numLocutores;
    }

    public String getGenero() {
        return genero;
    }

    public void setGenero(String genero) {
        this.genero = genero;
    }

    public String getHorario() {
        return horario;
    }

    public void setHorario(String horario) {
        this.horario = horario;
    }

    public String getPatrocinador() {
        return patrocinador;
    }

    public void setPatrocinador(String patrocinador) {
        this.patrocinador = patrocinador;
    }

    public String getPais() {
        return pais;
    }

    public void setPais(String pais) {
        this.pais = pais;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public int getNumProgramas() {
        return numProgramas;
    }

    public void setNumProgramas(int numProgramas) {
        this.numProgramas = numProgramas;
    }

    public int getNumCiudades() {
        return numCiudades;
    }

    public void setNumCiudades(int numCiudades) {
        this.numCiudades = numCiudades;
    }
}
