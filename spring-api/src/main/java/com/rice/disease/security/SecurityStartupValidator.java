package com.rice.disease.security;

import com.rice.disease.config.ApiUserProperties;
import com.rice.disease.config.JwtProperties;
import jakarta.annotation.PostConstruct;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class SecurityStartupValidator {

    private static final Set<String> BANNED_USERNAMES = Set.of("admin", "root", "riceguard");
    private static final Set<String> BANNED_PASSWORDS = Set.of(
        "password",
        "changeme",
        "changeit",
        "changeThisPassword123!",
        "ChangeThisPassword123!"
    );
    private static final Set<String> BANNED_JWT_SECRETS = Set.of(
        "ReplaceWithYourOwnLongJwtSecretAtLeast32Chars",
        "secret",
        "changeme",
        "changeit"
    );

    private final ApiUserProperties apiUserProperties;
    private final JwtProperties jwtProperties;

    public SecurityStartupValidator(ApiUserProperties apiUserProperties, JwtProperties jwtProperties) {
        this.apiUserProperties = apiUserProperties;
        this.jwtProperties = jwtProperties;
    }

    @PostConstruct
    void validate() {
        String username = apiUserProperties.getUsername();
        String password = apiUserProperties.getPassword();
        String jwtSecret = jwtProperties.getSecret();

        if (username != null && BANNED_USERNAMES.contains(username.trim().toLowerCase())) {
            throw new IllegalStateException("APP_API_USERNAME uses an insecure default/common value.");
        }
        if (password != null && BANNED_PASSWORDS.contains(password.trim())) {
            throw new IllegalStateException("APP_API_PASSWORD uses an insecure default/common value.");
        }
        if (jwtSecret != null && BANNED_JWT_SECRETS.contains(jwtSecret.trim())) {
            throw new IllegalStateException("APP_SECURITY_JWT_SECRET uses an insecure default/common value.");
        }
    }
}
