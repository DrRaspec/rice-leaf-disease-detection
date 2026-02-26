package com.rice.disease.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rice.disease.config.RateLimitProperties;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private static final int MAX_TRACKED_KEYS = 5000;

    private final RateLimitProperties properties;
    private final ObjectMapper objectMapper;
    private final ConcurrentHashMap<String, RateWindow> windows = new ConcurrentHashMap<>();

    public RateLimitFilter(RateLimitProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String method = request.getMethod();
        String path = request.getRequestURI();
        if (!"POST".equalsIgnoreCase(method)) {
            return true;
        }
        return !(
            "/predict".equals(path)
                || "/auth/login".equals(path)
                || "/auth/refresh".equals(path)
                || "/api/v1/predict".equals(path)
                || "/api/v1/auth/login".equals(path)
                || "/api/v1/auth/refresh".equals(path)
        );
    }

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        long now = Instant.now().getEpochSecond();
        String key = resolveClientIp(request) + ":" + request.getRequestURI();

        AtomicBoolean allowed = new AtomicBoolean(true);
        AtomicBoolean resetWindow = new AtomicBoolean(false);

        windows.compute(key, (ignored, current) -> {
            if (current == null || now - current.windowStartEpochSeconds() >= properties.getWindowSeconds()) {
                resetWindow.set(true);
                return new RateWindow(now, 1);
            }
            if (current.requestCount() >= properties.getMaxRequestsPerWindow()) {
                allowed.set(false);
                return current;
            }
            return new RateWindow(current.windowStartEpochSeconds(), current.requestCount() + 1);
        });

        if (!allowed.get()) {
            RateWindow window = windows.get(key);
            long retryAfter = 1;
            if (window != null) {
                long elapsed = now - window.windowStartEpochSeconds();
                retryAfter = Math.max(1, properties.getWindowSeconds() - elapsed);
            }
            response.setStatus(429);
            response.setHeader("Retry-After", String.valueOf(retryAfter));
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            objectMapper.writeValue(
                response.getWriter(),
                Map.of("detail", "Rate limit exceeded. Please retry later.")
            );
            return;
        }

        if (resetWindow.get() || windows.size() > MAX_TRACKED_KEYS) {
            cleanupOldWindows(now);
        }

        filterChain.doFilter(request, response);
    }

    private void cleanupOldWindows(long nowEpochSeconds) {
        long staleBefore = nowEpochSeconds - properties.getWindowSeconds();
        Iterator<Map.Entry<String, RateWindow>> iterator = windows.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, RateWindow> entry = iterator.next();
            if (entry.getValue().windowStartEpochSeconds() < staleBefore) {
                iterator.remove();
            }
        }
    }

    private String resolveClientIp(HttpServletRequest request) {
        if (!properties.isTrustForwardedFor()) {
            return request.getRemoteAddr();
        }
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded == null || forwarded.isBlank()) {
            return request.getRemoteAddr();
        }
        int comma = forwarded.indexOf(',');
        return comma >= 0 ? forwarded.substring(0, comma).trim() : forwarded.trim();
    }

    private record RateWindow(long windowStartEpochSeconds, int requestCount) {
    }
}
