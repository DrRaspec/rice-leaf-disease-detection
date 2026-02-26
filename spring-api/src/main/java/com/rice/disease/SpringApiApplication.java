package com.rice.disease;

import com.rice.disease.config.InferenceProperties;
import com.rice.disease.config.ApiUserProperties;
import com.rice.disease.config.CorsProperties;
import com.rice.disease.config.JwtProperties;
import com.rice.disease.config.RateLimitProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties({
    InferenceProperties.class,
    JwtProperties.class,
    ApiUserProperties.class,
    CorsProperties.class,
    RateLimitProperties.class
})
public class SpringApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringApiApplication.class, args);
    }
}
