package com.rice.disease.security;

import com.rice.disease.config.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.DecodingException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    private static final String TYPE_CLAIM = "type";
    private static final String TOKEN_TYPE_ACCESS = "access";
    private static final String TOKEN_TYPE_REFRESH = "refresh";

    private final JwtProperties properties;
    private final SecretKey signingKey;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.signingKey = resolveSigningKey(properties.getSecret());
    }

    public String createAccessToken(String username, Instant issuedAt) {
        Instant expiresAt = issuedAt.plusSeconds(properties.getAccessTokenTtlSeconds());
        return Jwts.builder()
            .issuer(properties.getIssuer())
            .subject(username)
            .issuedAt(Date.from(issuedAt))
            .expiration(Date.from(expiresAt))
            .claim(TYPE_CLAIM, TOKEN_TYPE_ACCESS)
            .signWith(signingKey)
            .compact();
    }

    public String createRefreshToken(String username, String refreshId, Instant issuedAt) {
        Instant expiresAt = issuedAt.plusSeconds(properties.getRefreshTokenTtlSeconds());
        return Jwts.builder()
            .issuer(properties.getIssuer())
            .subject(username)
            .id(refreshId)
            .issuedAt(Date.from(issuedAt))
            .expiration(Date.from(expiresAt))
            .claim(TYPE_CLAIM, TOKEN_TYPE_REFRESH)
            .signWith(signingKey)
            .compact();
    }

    public Optional<String> extractUsernameFromAccessToken(String token) {
        Claims claims = parseClaims(token);
        if (!TOKEN_TYPE_ACCESS.equals(claims.get(TYPE_CLAIM, String.class))) {
            return Optional.empty();
        }
        return Optional.ofNullable(claims.getSubject());
    }

    public RefreshTokenClaims parseRefreshToken(String token) {
        Claims claims = parseClaims(token);
        if (!TOKEN_TYPE_REFRESH.equals(claims.get(TYPE_CLAIM, String.class))) {
            throw new JwtException("Invalid refresh token.");
        }

        String subject = claims.getSubject();
        String refreshId = claims.getId();
        Date expiration = claims.getExpiration();

        if (subject == null || refreshId == null || expiration == null) {
            throw new JwtException("Malformed refresh token.");
        }

        return new RefreshTokenClaims(subject, refreshId, expiration.toInstant());
    }

    public long accessTokenTtlSeconds() {
        return properties.getAccessTokenTtlSeconds();
    }

    public long refreshTokenTtlSeconds() {
        return properties.getRefreshTokenTtlSeconds();
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
            .verifyWith(signingKey)
            .requireIssuer(properties.getIssuer())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    private SecretKey resolveSigningKey(String secret) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException("JWT secret must not be blank.");
        }

        try {
            byte[] decoded = Decoders.BASE64.decode(secret);
            if (decoded.length >= 32) {
                return Keys.hmacShaKeyFor(decoded);
            }
        } catch (IllegalArgumentException | DecodingException ignored) {
            // Not base64-encoded; fall back to raw string bytes.
        }

        byte[] raw = secret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(raw);
    }

    public record RefreshTokenClaims(String username, String refreshId, Instant expiresAt) {
    }
}



