package com.rice.disease.auth;

import com.rice.disease.config.ApiUserProperties;
import com.rice.disease.security.JwtService;
import com.rice.disease.security.JwtService.RefreshTokenClaims;
import com.rice.disease.security.RefreshTokenStore;
import io.jsonwebtoken.JwtException;
import java.time.Instant;
import java.util.UUID;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final ApiUserProperties userProperties;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenStore refreshTokenStore;
    private final String encodedPassword;

    public AuthService(
        ApiUserProperties userProperties,
        PasswordEncoder passwordEncoder,
        JwtService jwtService,
        RefreshTokenStore refreshTokenStore
    ) {
        this.userProperties = userProperties;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenStore = refreshTokenStore;
        this.encodedPassword = passwordEncoder.encode(userProperties.getPassword());
    }

    public AuthTokensResponse login(LoginRequest request) {
        if (!userProperties.getUsername().equals(request.username())
            || !passwordEncoder.matches(request.password(), encodedPassword)) {
            throw new BadCredentialsException("Invalid credentials.");
        }

        return issueTokens(request.username(), Instant.now());
    }

    public AuthTokensResponse refresh(RefreshRequest request) {
        RefreshTokenClaims claims;
        try {
            claims = jwtService.parseRefreshToken(request.refreshToken());
        } catch (JwtException ex) {
            throw new BadCredentialsException("Invalid refresh token.");
        }

        Instant now = Instant.now();
        if (!refreshTokenStore.consume(claims.refreshId(), claims.username(), now)) {
            throw new BadCredentialsException("Refresh token expired or revoked.");
        }

        return issueTokens(claims.username(), now);
    }

    private AuthTokensResponse issueTokens(String username, Instant now) {
        String refreshId = UUID.randomUUID().toString();
        String accessToken = jwtService.createAccessToken(username, now);
        String refreshToken = jwtService.createRefreshToken(username, refreshId, now);
        Instant refreshExpiresAt = now.plusSeconds(jwtService.refreshTokenTtlSeconds());
        refreshTokenStore.save(refreshId, username, refreshExpiresAt);

        return new AuthTokensResponse(
            "Bearer",
            accessToken,
            jwtService.accessTokenTtlSeconds(),
            refreshToken,
            jwtService.refreshTokenTtlSeconds()
        );
    }
}
