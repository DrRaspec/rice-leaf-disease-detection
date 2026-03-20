package com.rice.disease.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.rice.disease.config.InferenceProperties;
import jakarta.annotation.PreDestroy;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class PythonInferenceService {

    private static final Duration STARTUP_TIMEOUT = Duration.ofSeconds(90);
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(45);

    private final InferenceProperties properties;
    private final ObjectMapper objectMapper;

    private Process workerProcess;
    private BufferedWriter workerInput;
    private BufferedReader workerOutput;
    private BufferedReader workerError;

    public PythonInferenceService(InferenceProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    public synchronized JsonNode predict(MultipartFile file) {
        Path tempImage = null;
        try {
            ensureWorkerReady();

            String suffix = resolveSuffix(file.getOriginalFilename());
            tempImage = Files.createTempFile("rice-upload-", suffix);
            file.transferTo(tempImage);

            ObjectNode request = objectMapper.createObjectNode();
            request.put("image_path", tempImage.toString());
            request.put("top_k", properties.getTopK());

            workerInput.write(objectMapper.writeValueAsString(request));
            workerInput.newLine();
            workerInput.flush();

            JsonNode response = readWorkerJson(REQUEST_TIMEOUT);
            if (!response.path("ok").asBoolean(false)) {
                throw new IllegalStateException("Inference failed: " + response.path("error").asText("Unknown worker error."));
            }

            JsonNode result = response.get("result");
            if (result == null || !result.isObject()) {
                throw new IllegalStateException("Inference worker returned invalid JSON.");
            }
            return result;
        } catch (IOException e) {
            restartWorkerQuietly();
            throw new IllegalStateException("Failed to run inference.", e);
        } finally {
            if (tempImage != null) {
                try {
                    Files.deleteIfExists(tempImage);
                } catch (IOException ignored) {
                }
            }
        }
    }

    @PreDestroy
    synchronized void shutdown() {
        if (workerProcess == null) {
            return;
        }

        try {
            if (workerInput != null && workerProcess.isAlive()) {
                ObjectNode request = objectMapper.createObjectNode();
                request.put("command", "shutdown");
                workerInput.write(objectMapper.writeValueAsString(request));
                workerInput.newLine();
                workerInput.flush();
            }
        } catch (IOException ignored) {
        } finally {
            stopWorker();
        }
    }

    private void ensureWorkerReady() throws IOException {
        if (workerProcess != null && workerProcess.isAlive()) {
            return;
        }

        stopWorker();

        List<String> command = new ArrayList<>();
        command.add(properties.getPythonCommand());
        command.add("-m");
        command.add(properties.getModule());

        ProcessBuilder processBuilder = new ProcessBuilder(command)
            .directory(properties.getProjectRootPath().toFile());

        workerProcess = processBuilder.start();
        workerInput = new BufferedWriter(new OutputStreamWriter(workerProcess.getOutputStream(), StandardCharsets.UTF_8));
        workerOutput = new BufferedReader(new InputStreamReader(workerProcess.getInputStream(), StandardCharsets.UTF_8));
        workerError = new BufferedReader(new InputStreamReader(workerProcess.getErrorStream(), StandardCharsets.UTF_8));

        JsonNode readyMessage = readWorkerJson(STARTUP_TIMEOUT);
        if (!readyMessage.path("ready").asBoolean(false)) {
            String error = readyMessage.path("error").asText(readAvailableErrorOutput());
            stopWorker();
            throw new IllegalStateException("Python inference worker failed to start: " + error);
        }
    }

    private JsonNode readWorkerJson(Duration timeout) throws IOException {
        long deadline = System.nanoTime() + timeout.toNanos();
        StringBuilder stderr = new StringBuilder();

        while (System.nanoTime() < deadline) {
            appendAvailableError(stderr);

            if (workerOutput != null && workerOutput.ready()) {
                String line = workerOutput.readLine();
                if (line == null) {
                    throw new IllegalStateException("Inference worker stopped unexpectedly. " + stderr);
                }
                return objectMapper.readTree(line);
            }

            if (workerProcess == null || !workerProcess.isAlive()) {
                throw new IllegalStateException("Inference worker exited unexpectedly. " + stderr);
            }

            try {
                Thread.sleep(25L);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new IllegalStateException("Interrupted while waiting for inference worker.", e);
            }
        }

        throw new IllegalStateException("Inference worker timed out. " + stderr);
    }

    private void appendAvailableError(StringBuilder stderr) throws IOException {
        if (workerError == null) {
            return;
        }
        while (workerError.ready()) {
            int ch = workerError.read();
            if (ch < 0) {
                break;
            }
            stderr.append((char) ch);
        }
    }

    private String readAvailableErrorOutput() throws IOException {
        StringBuilder stderr = new StringBuilder();
        appendAvailableError(stderr);
        return stderr.toString().trim();
    }

    private void restartWorkerQuietly() {
        stopWorker();
    }

    private void stopWorker() {
        closeQuietly(workerInput);
        closeQuietly(workerOutput);
        closeQuietly(workerError);

        if (workerProcess != null) {
            workerProcess.destroy();
            try {
                if (!workerProcess.waitFor(2, java.util.concurrent.TimeUnit.SECONDS)) {
                    workerProcess.destroyForcibly();
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                workerProcess.destroyForcibly();
            }
        }

        workerProcess = null;
        workerInput = null;
        workerOutput = null;
        workerError = null;
    }

    private void closeQuietly(AutoCloseable closeable) {
        if (closeable == null) {
            return;
        }
        try {
            closeable.close();
        } catch (Exception ignored) {
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
}
