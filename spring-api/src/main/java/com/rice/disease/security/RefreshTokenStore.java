package com.rice.disease.security;

import java.time.Instant;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

@Component
public class RefreshTokenStore {

    private final ConcurrentHashMap<String, StoredToken> refreshTokens = new ConcurrentHashMap<>();

    public void save(String refreshId, String username, Instant expiresAt) {
        refreshTokens.put(refreshId, new StoredToken(username, expiresAt));
    }

    public boolean consume(String refreshId, String username, Instant now) {
        StoredToken token = refreshTokens.remove(refreshId);
        if (token == null) {
            return false;
        }
        if (!Objects.equals(token.username(), username)) {
            return false;
        }
        return token.expiresAt().isAfter(now);
    }

    private record StoredToken(String username, Instant expiresAt) {
    }
}
