@echo off
REM =====================================================================
REM  Ejecuta la aplicacion Emisora en Tomcat 11 (Windows)
REM   1. Compila con Maven y genera target\emisora.war
REM   2. Copia el .war a la carpeta webapps de Tomcat
REM   3. Inicia Tomcat en esta misma ventana (Ctrl+C para detenerlo)
REM  Luego abrir en el navegador:  http://localhost:8080/emisora/
REM
REM  Variables de entorno (ver README):
REM    CATALINA_HOME  (obligatoria) carpeta de Tomcat 11
REM    DB_PASSWORD    contrasena del usuario root de MySQL
REM    DB_URL, DB_USER, JAVA_HOME (opcionales)
REM =====================================================================
setlocal
cd /d "%~dp0.."

if not defined CATALINA_HOME (
    echo [ERROR] Falta la variable CATALINA_HOME con la carpeta de Tomcat 11.
    echo Ejemplo:  set CATALINA_HOME=C:\Users\joseq\Tomcat\apache-tomcat-11.0.26
    exit /b 1
)

REM Si JAVA_HOME no esta definida, se toma la del java que este en el PATH
if defined JAVA_HOME goto java_ok
for /f "tokens=2 delims==" %%i in ('java -XshowSettings:properties -version 2^>^&1 ^| findstr /c:"java.home"') do set "JAVA_HOME=%%i"
if not defined JAVA_HOME (
    echo [ERROR] No se encontro Java. Instale el JDK 21 o defina JAVA_HOME.
    exit /b 1
)
set "JAVA_HOME=%JAVA_HOME:~1%"
:java_ok

echo Compilando con Maven...
call mvn -q -B package
if errorlevel 1 (
    echo [ERROR] Fallo la compilacion.
    exit /b 1
)

echo Desplegando target\emisora.war en Tomcat...
if exist "%CATALINA_HOME%\webapps\emisora" rmdir /s /q "%CATALINA_HOME%\webapps\emisora"
copy /y "target\emisora.war" "%CATALINA_HOME%\webapps\emisora.war" >nul

echo.
echo   Aplicacion: http://localhost:8080/emisora/
echo   Para detener Tomcat presione Ctrl+C
echo.
call "%CATALINA_HOME%\bin\catalina.bat" run
