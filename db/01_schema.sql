-- =====================================================================
-- Proyecto : Emisora (Ejercicio 25) - Desarrollo Web, Unidad 1
-- Script 01: creación de la base de datos y de las tablas
-- Motor    : MySQL 8.0 o superior (probado en MySQL 9.7)
--
-- ATENCIÓN: si las tablas ya existen, este script las BORRA y las crea
-- de nuevo (se pierden los datos). Luego ejecute 02_data.sql.
-- =====================================================================

-- Tildes y eñes correctas sin importar desde dónde se ejecute el script
SET NAMES utf8mb4;

-- Crear la BD
CREATE DATABASE IF NOT EXISTS emisora_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Usar la BD creada
USE emisora_db;

DROP TABLE IF EXISTS Emisoras;
DROP TABLE IF EXISTS Users;

-- ---------------------------------------------------------------------
-- Tabla Users: igual a la de la guía (code, password, name, email)
-- + role, fecha de registro y columnas para recuperar la clave.
-- Correspondencia con la actividad: id = code, clave = password,
-- nombre = name, rol = role.
-- ---------------------------------------------------------------------
CREATE TABLE Users (
    -- El código del usuario (el "id" que pide la actividad)
    code VARCHAR(50) PRIMARY KEY,
    -- La contraseña cifrada con SHA-256 (nunca se guarda en texto plano)
    password VARCHAR(255) NOT NULL,
    -- El nombre del usuario
    name VARCHAR(255) NOT NULL,
    -- El correo del usuario (se usa para iniciar sesión y recuperar la clave)
    email VARCHAR(255) NOT NULL UNIQUE,
    -- El rol: ADMIN (todo), OPERADOR (gestiona emisoras), CONSULTA (solo consulta)
    role VARCHAR(20) NOT NULL DEFAULT 'CONSULTA',
    -- Fecha en que se registró el usuario (se usa en un reporte)
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Recuperación de clave: código temporal enviado por correo y su vencimiento
    resetToken VARCHAR(64) NULL UNIQUE,
    resetTokenExpires DATETIME NULL,
    CONSTRAINT chk_users_role CHECK (role IN ('ADMIN', 'OPERADOR', 'CONSULTA'))
);

-- ---------------------------------------------------------------------
-- Tabla Emisoras: atributos del ejercicio 25 + code como clave primaria
-- (mismo patrón que Users: un código de texto que escribe el usuario).
-- ---------------------------------------------------------------------
CREATE TABLE Emisoras (
    -- El código de la emisora, ej. EM001
    code VARCHAR(20) PRIMARY KEY,
    -- El nombre de la emisora (no se puede repetir)
    nombre VARCHAR(100) NOT NULL UNIQUE,
    -- El canal o cadena radial a la que pertenece
    canal VARCHAR(100) NOT NULL,
    -- Frecuencia en FM (MHz, ej. 98.5). NULL si no transmite en FM
    bandaFm DECIMAL(4,1) NULL,
    -- Frecuencia en AM (kHz, ej. 1040). NULL si no transmite en AM
    bandaAm INT NULL,
    -- Cantidad de locutores
    numLocutores INT NOT NULL DEFAULT 0,
    -- Género musical o temático (Noticias, Tropical, Rock...)
    genero VARCHAR(50) NOT NULL,
    -- Horario de emisión, ej. "24 horas" o "5:00 a.m. - 10:00 p.m."
    horario VARCHAR(100) NOT NULL,
    -- Patrocinador principal (opcional)
    patrocinador VARCHAR(100) NULL,
    -- País de la emisora
    pais VARCHAR(60) NOT NULL,
    -- Descripción breve
    descripcion VARCHAR(500) NULL,
    -- Cantidad de programas al aire
    numProgramas INT NOT NULL DEFAULT 0,
    -- Cantidad de ciudades con cobertura
    numCiudades INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_emisoras_fm CHECK (bandaFm IS NULL OR bandaFm BETWEEN 87.5 AND 108.0),
    CONSTRAINT chk_emisoras_am CHECK (bandaAm IS NULL OR bandaAm BETWEEN 530 AND 1710),
    CONSTRAINT chk_emisoras_banda CHECK (bandaFm IS NOT NULL OR bandaAm IS NOT NULL),
    CONSTRAINT chk_emisoras_numeros CHECK (numLocutores >= 0 AND numProgramas >= 0 AND numCiudades >= 0)
);

-- Índices para los reportes parametrizados (búsquedas por país, género y rol)
CREATE INDEX idx_emisoras_pais_genero ON Emisoras (pais, genero);
CREATE INDEX idx_users_role ON Users (role);
