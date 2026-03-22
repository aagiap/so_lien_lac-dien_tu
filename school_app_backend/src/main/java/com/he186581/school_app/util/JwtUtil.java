package com.he186581.school_app.util;

import com.he186581.school_app.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Utility tạo và validate JWT.
 */
@Component
@Getter
public class JwtUtil {

    private static final String CLAIM_TYPE = "type";
    private static final String ACCESS = "ACCESS";
    private static final String REFRESH = "REFRESH";
    private static final String OTP = "OTP";
    private static final String RESET = "RESET";

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.access-expiration}")
    private long accessExpiration;

    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    @Value("${jwt.otp-expiration}")
    private long otpExpiration;

    @Value("${jwt.reset-expiration}")
    private long resetExpiration;

    private SecretKey key;

    @PostConstruct
    public void init() {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateAccessToken(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("roles", user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet()));
        return createToken(claims, user.getUsername(), accessExpiration, ACCESS);
    }

    public String generateRefreshToken(String username) {
        return createToken(new HashMap<>(), username, refreshExpiration, REFRESH);
    }

    public String generateOtpToken(String username) {
        return createToken(new HashMap<>(), username, otpExpiration, OTP);
    }

    public String generateResetToken(String username) {
        return createToken(new HashMap<>(), username, resetExpiration, RESET);
    }

    private String createToken(Map<String, Object> claims, String username, long expiration, String type) {
        claims.put(CLAIM_TYPE, type);

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
                .claims(claims)
                .subject(username)
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(key)
                .compact();
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractTokenType(String token) {
        return extractAllClaims(token).get(CLAIM_TYPE, String.class);
    }

    public boolean isAccessToken(String token) {
        return ACCESS.equals(extractTokenType(token));
    }

    public boolean isRefreshToken(String token) {
        return REFRESH.equals(extractTokenType(token));
    }

    public boolean isOtpToken(String token) {
        return OTP.equals(extractTokenType(token));
    }

    public boolean isResetToken(String token) {
        return RESET.equals(extractTokenType(token));
    }

    public boolean validateToken(String token, String username) {
        return username.equals(extractUsername(token));
    }

    public <T> T extractClaim(String token, Function<Claims, T> resolver) {
        Claims claims = extractAllClaims(token);
        return resolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
