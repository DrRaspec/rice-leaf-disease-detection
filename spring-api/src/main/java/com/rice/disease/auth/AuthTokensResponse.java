package com.rice.disease.auth;

public record AuthTokensResponse(
    String tokenType,
    String accessToken,
    long expiresInSeconds,
    String refreshToken,
    long refreshExpiresInSeconds
) {
}
