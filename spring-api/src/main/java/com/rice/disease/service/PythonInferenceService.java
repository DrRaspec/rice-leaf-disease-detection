package com.rice.disease.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.rice.disease.config.InferenceProperties;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class PythonInferenceService {

    private static final Duration PROCESS_TIMEOUT = Duration.ofSeconds(120);

    private final InferenceProperties properties;
    private final ObjectMapper objectMapper;

    public PythonInferenceService(InferenceProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    public JsonNode predict(MultipartFile file) {
        Path tempImage = null;
        try {
            String suffix = resolveSuffix(file.getOriginalFilename());
            tempImage = Files.createTempFile("rice-upload-", suffix);
            file.transferTo(tempImage);

            List<String> command = new ArrayList<>();
            command.add(properties.getPythonCommand());
            command.add("-m");
            command.add(properties.getModule());
            command.add("--image");
            command.add(tempImage.toString());
            command.add("--top-k");
            command.add(String.valueOf(properties.getTopK()));

            ProcessBuilder processBuilder = new ProcessBuilder(command)
                .directory(properties.getProjectRootPath().toFile())
                .redirectErrorStream(true);

            Process process = processBuilder.start();
            String output = readOutput(process);
            boolean finished = process.waitFor(PROCESS_TIMEOUT.toMillis(), TimeUnit.MILLISECONDS);

            if (!finished) {
                process.destroyForcibly();
                throw new IllegalStateException("Inference timed out.");
            }

            if (process.exitValue() != 0) {
                throw new IllegalStateException("Inference failed: " + output.trim());
            }

            return objectMapper.readTree(output);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to run inference.", e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Inference interrupted.", e);
        } finally {
            if (tempImage != null) {
                try {
                    Files.deleteIfExists(tempImage);
                } catch (IOException ignored) {
                }
            }
        }
    }

    private String resolveSuffix(String originalName) {
        if (originalName == null) {
            return ".jpg";
        }
        int idx = originalName.lastIndexOf('.');
        if (idx < 0 || idx == originalName.length() - 1) {
            return ".jpg";
        }
        return originalName.substring(idx);
    }

    private String readOutput(Process process) throws IOException {
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line);
            }
        }
        return output.toString();
    }
}
