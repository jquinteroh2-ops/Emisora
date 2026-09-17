-- =====================================================================
-- Proyecto : Emisora (Ejercicio 25) - Desarrollo Web, Unidad 1
-- Script 02: datos iniciales de prueba
-- Ejecutar DESPUÉS de 01_schema.sql
-- =====================================================================

-- Tildes y eñes correctas sin importar desde dónde se ejecute el script
SET NAMES utf8mb4;

USE emisora_db;

-- ---------------------------------------------------------------------
-- Usuarios de prueba. Las contraseñas se guardan cifradas con SHA2(...,256);
-- aquí se ve la clave original para poder probar el login:
--
--   Email                              Clave           Rol
--   jquinteroh2@unicartagena.edu.co    Admin2026*      ADMIN
--   operador.emisora@yopmail.com       Operador2026*   OPERADOR
--   carlos.emisora@yopmail.com         Operador2026*   OPERADOR
--   consulta.emisora@yopmail.com       Consulta2026*   CONSULTA
--   pedro.emisora@yopmail.com          Consulta2026*   CONSULTA
--
-- Los correos @yopmail.com son buzones públicos de prueba (www.yopmail.com),
-- útiles para ver el correo de recuperación de clave.
-- ---------------------------------------------------------------------
INSERT INTO Users (code, password, name, email, role, createdAt) VALUES
('U001', SHA2('Admin2026*', 256),    'José Quintero',  'jquinteroh2@unicartagena.edu.co', 'ADMIN',    '2026-08-01 08:00:00'),
('U002', SHA2('Operador2026*', 256), 'Laura Martínez', 'operador.emisora@yopmail.com',    'OPERADOR', '2026-08-10 09:30:00'),
('U003', SHA2('Operador2026*', 256), 'Carlos Pérez',   'carlos.emisora@yopmail.com',      'OPERADOR', '2026-08-25 14:15:00'),
('U004', SHA2('Consulta2026*', 256), 'Ana Gómez',      'consulta.emisora@yopmail.com',    'CONSULTA', '2026-09-02 11:00:00'),
('U005', SHA2('Consulta2026*', 256), 'Pedro Ramírez',  'pedro.emisora@yopmail.com',       'CONSULTA', '2026-09-10 16:45:00');

-- ---------------------------------------------------------------------
-- Emisoras de prueba (datos ficticios), variadas en país, género,
-- banda, locutores y cobertura para que los reportes muestren diferencias.
-- ---------------------------------------------------------------------
INSERT INTO Emisoras (code, nombre, canal, bandaFm, bandaAm, numLocutores, genero, horario, patrocinador, pais, descripcion, numProgramas, numCiudades) VALUES
('EM001', 'Caribe Estéreo',              'Cadena Costa Norte',        98.5, NULL, 12, 'Tropical',          '24 horas',               'Cooperativa Pesquera del Caribe', 'Colombia',  'Música tropical, vallenato y champeta para la región Caribe.',              18,  9),
('EM002', 'Ondas del Magdalena',         'Red Radial Ribereña',       NULL, 1040,  6, 'Noticias',          '5:00 a.m. - 10:00 p.m.', 'Almacenes El Puerto',             'Colombia',  'Noticias regionales, entrevistas y servicio social para los municipios ribereños.', 22, 14),
('EM003', 'Rumba Urbana',                'Cadena Costa Norte',       104.3, NULL,  8, 'Urbano',            '24 horas',               'Bebidas Tropicolor',              'Colombia',  'Reguetón, trap y música urbana para público joven.',                          15,  6),
('EM004', 'Voz Andina',                  'Sistema Andino de Radio',   91.7,  690, 20, 'Noticias',          '24 horas',               'Banco Cordillera',                'Colombia',  'Cadena informativa con corresponsales en las principales ciudades del país.',   40, 32),
('EM005', 'Radio Cultura Universitaria', 'Red de Emisoras Públicas', 107.1, NULL,  5, 'Cultural',          '6:00 a.m. - 12:00 a.m.', NULL,                              'Colombia',  'Emisora cultural y educativa con música clásica, jazz y divulgación científica.', 30,  2),
('EM006', 'Salsa y Sabor',               'Onda Latina Medios',        95.9, NULL,  7, 'Salsa',             '24 horas',               'Café Montebello',                 'Colombia',  'Salsa clásica y salsa romántica con programas de dedicatorias.',             12,  4),
('EM007', 'Mariachi Estéreo',            'Grupo Radial Azteca Sur',   89.3, NULL, 10, 'Regional mexicano', '24 horas',               'Tortillería La Esperanza',        'México',    'Rancheras, mariachi y corridos.',                                            16, 11),
('EM008', 'Noticias Metrópoli',          'Grupo Radial Azteca Sur',   NULL, 1220, 25, 'Noticias',          '24 horas',               'Seguros del Valle',               'México',    'Noticias nacionales, tráfico y análisis político en vivo.',                  45, 38),
('EM009', 'Tango Porteño',               'Radiodifusora del Plata',   92.1,  870,  9, 'Tango',             '8:00 a.m. - 2:00 a.m.',  'Bodega Los Álamos',               'Argentina', 'Tango, milonga y folclore rioplatense.',                                     20,  5),
('EM010', 'Rock del Sur',                'Radiodifusora del Plata',  101.5, NULL,  6, 'Rock',              '24 horas',               'Instrumentos Musicales Fénix',    'Argentina', 'Rock nacional e internacional, entrevistas a bandas emergentes.',            14,  3),
('EM011', 'Onda Deportiva',              'Cadena Ibérica de Radio',   99.9, NULL, 15, 'Deportes',          '24 horas',               'Deportes Olimpo',                 'España',    'Transmisiones de fútbol, baloncesto y tertulias deportivas.',                25, 17),
('EM012', 'Pop Latino FM',               'Cadena Ibérica de Radio',   88.4, NULL, 11, 'Pop',               '24 horas',               'Telefonía Horizonte',             'España',    'Éxitos del pop en español e inglés.',                                         19, 12),
('EM013', 'Radio Inti',                  'Red Peruana de Emisoras',   96.3, 1160,  8, 'Folclor',           '5:00 a.m. - 11:00 p.m.', 'Textiles Alpaca Real',            'Perú',      'Música andina, huaynos y programas en quechua.',                             17,  8),
('EM014', 'Cumbia Andina',               'Red Peruana de Emisoras',   NULL,  950,  4, 'Cumbia',            '6:00 a.m. - 10:00 p.m.', NULL,                              'Perú',      'Cumbia peruana y chicha para Lima y alrededores.',                            9,  3);
