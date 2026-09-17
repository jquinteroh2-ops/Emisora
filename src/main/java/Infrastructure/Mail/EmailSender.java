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
import java.util.Properties;

/**
 * Envío de correos por SMTP con JavaMail (Jakarta Mail). Es infraestructura, igual que
 * ConnectionDbMySql: sabe CÓMO enviar un correo, pero no decide QUÉ ni CUÁNDO enviarlo
 * (eso lo decide UserService).
 *
 * Los datos del servidor SMTP se leen de variables de entorno (ver README), así la clave
 * SMTP no se sube a GitHub. Por defecto usa Brevo por el puerto 2525, que no está
 * bloqueado en el plan gratuito de Render.
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

    // Método que envía un correo con versión en texto plano y versión HTML
    public static void sendEmail(String to, String subject, String textBody, String htmlBody)
            throws MessagingException {
        if (FROM.isBlank()) {
            throw new MessagingException("Error: el envío de correo no está configurado (falta MAIL_FROM).");
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

    // Lee una variable de entorno; si no está definida, devuelve el valor por defecto
    private static String getEnv(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value == null || value.isBlank()) ? defaultValue : value;
    }
}
