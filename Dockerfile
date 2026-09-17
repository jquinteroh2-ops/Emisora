# =====================================================================
#  Imagen para desplegar Emisora en Internet (Render u otro servicio con Docker)
#  Etapa 1: compila el proyecto con Maven y genera emisora.war
#  Etapa 2: copia el .war a Tomcat 11 (el mismo servidor que se usa en local)
# =====================================================================

# ---------- Etapa 1: compilación ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Primero solo el pom.xml: si no cambia, Docker reutiliza las dependencias ya descargadas
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src
RUN mvn -q -B package

# ---------- Etapa 2: ejecución ----------
FROM tomcat:11.0-jre21-temurin

# ROOT.war: la aplicación queda en la raíz del dominio (https://mi-app.onrender.com/)
COPY --from=build /app/target/emisora.war /usr/local/tomcat/webapps/ROOT.war

# Hora de Colombia para Java y memoria acorde al plan gratuito (512 MB)
ENV CATALINA_OPTS="-Duser.timezone=America/Bogota -XX:MaxRAMPercentage=70"

# Render indica el puerto en la variable PORT; Tomcat se ajusta a ella al iniciar (8080 por defecto)
EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/; s/port=\\\"8005\\\"/port=\\\"-1\\\"/\" conf/server.xml && exec catalina.sh run"]
