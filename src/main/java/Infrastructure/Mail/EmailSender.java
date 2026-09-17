package Infrastructure.Mail;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Properties;

/**
 * Envío de correos. Es infraestructura, igual que ConnectionDbMySql: sabe CÓMO enviar un
 * correo, pero no decide QUÉ ni CUÁNDO enviarlo (eso lo decide UserService).
 *
 * Tiene dos formas de enviar, según las variables de entorno (ver README):
 *   1. Si existe BREVO_API_KEY: por la API de Brevo (HTTPS, puerto 443) con el cliente
 *      HTTP que ya trae Java. Útil porque algunos hospedajes bloquean los puertos SMTP.
 *   2. Si no: por SMTP con JavaMail (Jakarta Mail), usando MAIL_SMTP_*.
 * Las claves nunca están en el código: se leen de variables de entorno.
 *
 * @author José Quintero
 */
public class EmailSender {

    private static final String HOST = getEnv("MAIL_SMTP_HOST", "smtp-relay.brevo.com");
    private static final String PORT = getEnv("MAIL_SMTP_PORT", "2525");
    private static final String USER = getEnv("MAIL_SMTP_USER", "");
    private static final String PASSWORD = getEnv("MAIL_SMTP_PASSWORD", "");
    private static final String FROM = getEnv("MAIL_FROM", "");
    private static final String FROM_NAME = getEnv("MAIL_FROM_NAME", "Gestión de Emisoras");
    // STARTTLS cifra la conexión con el servidor SMTP (Brevo y Gmail lo exigen)
    private static final boolean STARTTLS = !"false".equalsIgnoreCase(getEnv("MAIL_SMTP_STARTTLS", "true"));

    // Clave de la API de Brevo. Si está definida, el correo se envía por HTTPS en vez de SMTP
    private static final String BREVO_API_KEY = getEnv("BREVO_API_KEY", "");
    private static final String BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";

    // Método que envía un correo con versión en texto plano y versión HTML
    public static void sendEmail(String to, String subject, String textBody, String htmlBody)
            throws MessagingException {
        if (FROM.isBlank()) {
            throw new MessagingException("Error: el envío de correo no está configurado (falta MAIL_FROM).");
        }

        if (!BREVO_API_KEY.isBlank()) {
            sendWithBrevoApi(to, subject, textBody, htmlBody);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);
        props.put("mail.smtp.starttls.enable", String.valueOf(STARTTLS));
        props.put("mail.smtp.starttls.required", String.valueOf(STARTTLS));
        props.put("mail.smtp.connectiontimeout", "10000");  // milisegundos
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session session;
        if (USER.isBlank()) {
            session = Session.getInstance(props);
        } else {
            props.put("mail.smtp.auth", "true");
            session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USER, PASSWORD);
                }
            });
        }

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM, FROM_NAME, "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");

            // Dos versiones del mismo contenido: el programa de correo muestra la que soporte
            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setText(textBody, "UTF-8");
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent(htmlBody, "text/html; charset=UTF-8");

            MimeMultipart content = new MimeMultipart("alternative");
            content.addBodyPart(textPart);
            content.addBodyPart(htmlPart);
            message.setContent(content);

            Transport.send(message);
        } catch (UnsupportedEncodingException e) {
            throw new MessagingException("Error: no se pudo codificar el remitente del correo.", e);
        } catch (MessagingException e) {
            e.printStackTrace();
            throw e;
        }
    }

    // Envía el correo por la API de Brevo (HTTPS). Se arma el JSON a mano con el cliente
    // HTTP incluido en Java, sin librerías externas.
    private static void sendWithBrevoApi(String to, String subject, String textBody, String htmlBody)
            throws MessagingException {
        String json = "{"
                + "\"sender\":{\"name\":\"" + jsonEscape(FROM_NAME) + "\",\"email\":\"" + jsonEscape(FROM) + "\"},"
                + "\"to\":[{\"email\":\"" + jsonEscape(to) + "\"}],"
                + "\"subject\":\"" + jsonEscape(subject) + "\","
                + "\"textContent\":\"" + jsonEscape(textBody) + "\","
                + "\"htmlContent\":\"" + jsonEscape(htmlBody) + "\""
                + "}";

        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(BREVO_API_URL))
                    .timeout(Duration.ofSeconds(15))
                    .header("api-key", BREVO_API_KEY)
                    .header("content-type", "application/json")
                    .header("accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(json, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            // 201 = aceptado para envío
            if (response.statusCode() != 201 && response.statusCode() != 200) {
                throw new MessagingException("Error: la API de correo respondió " + response.statusCode()
                        + " " + response.body());
            }
        } catch (MessagingException e) {
            throw e;
        } catch (Exception e) {
            e.printStackTrace();
            throw new MessagingException("Error: no se pudo contactar con el servicio de correo.", e);
        }
    }

    // Escapa el texto que se inserta dentro del JSON (comillas, barras y saltos de línea)
    private static String jsonEscape(String value) {
        StringBuilder result = new StringBuilder();
        for (char c : value.toCharArray()) {
            switch (c) {
                case '"' -> result.append("\\\"");
                case '\\' -> result.append("\\\\");
                case '\n' -> result.append("\\n");
                case '\r' -> result.append("\\r");
                case '\t' -> result.append("\\t");
                default -> {
                    if (c < 0x20) {
                        result.append(String.format("\\u%04x", (int) c));
                    } else {
                        result.append(c);
                    }
                }
            }
        }
        return result.toString();
    }

    // Lee una variable de entorno; si no está definida, devuelve el valor por defecto
    private static String getEnv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isBlank()) ? defaultValue : value;
    }
}
