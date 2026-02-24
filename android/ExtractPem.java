import java.io.*;
import java.security.*;
import java.security.cert.Certificate;
import java.util.Base64;

/**
 * Java utility to extract PEM file from PKCS12 keystore (Java 8+ compatible)
 * Usage: java ExtractPem <p12_file> <password> <output_pem_file>
 */
public class ExtractPem {
    private static String base64Encode(byte[] data) {
        try {
            // Try Java 8+ Base64
            String base64 = Base64.getEncoder().encodeToString(data);
            // Split into 64 character lines
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < base64.length(); i += 64) {
                int end = Math.min(i + 64, base64.length());
                sb.append(base64.substring(i, end));
                if (end < base64.length()) {
                    sb.append("\n");
                }
            }
            return sb.toString();
        } catch (NoClassDefFoundError e) {
            // Fallback for older Java versions
            return base64EncodeLegacy(data);
        }
    }
    
    private static String base64EncodeLegacy(byte[] data) {
        // Simple Base64 encoder for older Java versions
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < data.length; i += 3) {
            int b1 = data[i] & 0xFF;
            int b2 = (i + 1 < data.length) ? data[i + 1] & 0xFF : 0;
            int b3 = (i + 2 < data.length) ? data[i + 2] & 0xFF : 0;
            
            int bitmap = (b1 << 16) | (b2 << 8) | b3;
            
            sb.append(chars.charAt((bitmap >> 18) & 63));
            sb.append(chars.charAt((bitmap >> 12) & 63));
            if (i + 1 < data.length) {
                sb.append(chars.charAt((bitmap >> 6) & 63));
            } else {
                sb.append('=');
            }
            if (i + 2 < data.length) {
                sb.append(chars.charAt(bitmap & 63));
            } else {
                sb.append('=');
            }
            
            if ((i / 3 + 1) % 19 == 0) {
                sb.append("\n");
            }
        }
        return sb.toString();
    }

    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: java ExtractPem <p12_file> <password> <output_pem_file>");
            System.exit(1);
        }

        String p12File = args[0];
        String password = args[1];
        String pemFile = args[2];

        try {
            // Load PKCS12 keystore
            KeyStore keystore = KeyStore.getInstance("PKCS12");
            FileInputStream fis = new FileInputStream(p12File);
            keystore.load(fis, password.toCharArray());
            fis.close();

            // Get the alias (assuming first alias)
            String alias = keystore.aliases().nextElement();

            // Get private key
            Key key = keystore.getKey(alias, password.toCharArray());
            if (key == null) {
                throw new Exception("Private key not found");
            }

            // Get certificate chain
            Certificate[] chain = keystore.getCertificateChain(alias);
            if (chain == null || chain.length == 0) {
                Certificate cert = keystore.getCertificate(alias);
                if (cert != null) {
                    chain = new Certificate[]{cert};
                }
            }

            // Write PEM file
            PrintWriter writer = new PrintWriter(new FileWriter(pemFile));

            // Write private key
            if (key instanceof java.security.PrivateKey) {
                writer.println("-----BEGIN PRIVATE KEY-----");
                writer.println(base64Encode(key.getEncoded()));
                writer.println("-----END PRIVATE KEY-----");
                writer.println();
            }

            // Write certificates
            if (chain != null) {
                for (Certificate cert : chain) {
                    writer.println("-----BEGIN CERTIFICATE-----");
                    writer.println(base64Encode(cert.getEncoded()));
                    writer.println("-----END CERTIFICATE-----");
                    writer.println();
                }
            }

            writer.close();
            System.out.println("PEM file extracted successfully: " + pemFile);

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
