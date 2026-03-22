package com.he186581.school_app.util;

import java.net.URLEncoder;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * TOTP theo chuẩn RFC 6238.
 * Dùng cho Google Authenticator / Microsoft Authenticator.
 */
@Component
public class TotpUtil {

    private static final String BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    private static final int SECRET_SIZE = 20;
    private static final int DIGITS = 6;
    private static final int TIME_STEP_SECONDS = 30;

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.issuer}")
    private String issuer;

    public String generateSecret() {
        byte[] buffer = new byte[SECRET_SIZE];
        secureRandom.nextBytes(buffer);
        return base32Encode(buffer);
    }

    public String getOtpAuthUrl(String username, String secret) {
        String encodedIssuer = URLEncoder.encode(issuer, StandardCharsets.UTF_8);
        String encodedUser = URLEncoder.encode(username, StandardCharsets.UTF_8);
        return "otpauth://totp/" + encodedIssuer + ":" + encodedUser
                + "?secret=" + secret
                + "&issuer=" + encodedIssuer
                + "&algorithm=SHA1&digits=6&period=30";
    }

    public boolean verifyCode(String secret, String code) {
        long currentTimeWindow = System.currentTimeMillis() / 1000 / TIME_STEP_SECONDS;

        // Cho phép lệch 1 khoảng thời gian để giảm lỗi đồng bộ thời gian
        for (int i = -1; i <= 1; i++) {
            String generated = generateCode(secret, currentTimeWindow + i);
            if (generated.equals(code)) {
                return true;
            }
        }
        return false;
    }

    private String generateCode(String secret, long timeWindow) {
        try {
            byte[] key = base32Decode(secret);
            byte[] data = ByteBuffer.allocate(8).putLong(timeWindow).array();

            Mac mac = Mac.getInstance("HmacSHA1");
            SecretKeySpec signKey = new SecretKeySpec(key, "HmacSHA1");
            mac.init(signKey);
            byte[] hash = mac.doFinal(data);

            int offset = hash[hash.length - 1] & 0x0F;
            int binary = ((hash[offset] & 0x7F) << 24)
                    | ((hash[offset + 1] & 0xFF) << 16)
                    | ((hash[offset + 2] & 0xFF) << 8)
                    | (hash[offset + 3] & 0xFF);

            int otp = binary % (int) Math.pow(10, DIGITS);
            return String.format("%06d", otp);
        } catch (Exception ex) {
            throw new IllegalStateException("Không thể tạo mã OTP", ex);
        }
    }

    private String base32Encode(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        int buffer = bytes[0];
        int next = 1;
        int bitsLeft = 8;

        while (bitsLeft > 0 || next < bytes.length) {
            if (bitsLeft < 5) {
                if (next < bytes.length) {
                    buffer <<= 8;
                    buffer |= (bytes[next++] & 0xFF);
                    bitsLeft += 8;
                } else {
                    int pad = 5 - bitsLeft;
                    buffer <<= pad;
                    bitsLeft += pad;
                }
            }
            int index = (buffer >> (bitsLeft - 5)) & 0x1F;
            bitsLeft -= 5;
            result.append(BASE32_CHARS.charAt(index));
        }
        return result.toString();
    }

    private byte[] base32Decode(String value) {
        String input = value.replace("=", "").toUpperCase();
        int numBytes = input.length() * 5 / 8;
        byte[] result = new byte[numBytes];

        int buffer = 0;
        int bitsLeft = 0;
        int index = 0;

        for (char c : input.toCharArray()) {
            int val = BASE32_CHARS.indexOf(c);
            if (val < 0) {
                continue;
            }

            buffer <<= 5;
            buffer |= val & 0x1F;
            bitsLeft += 5;

            if (bitsLeft >= 8) {
                result[index++] = (byte) ((buffer >> (bitsLeft - 8)) & 0xFF);
                bitsLeft -= 8;
            }
        }

        return result;
    }
}
