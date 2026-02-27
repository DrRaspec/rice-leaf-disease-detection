package com.rice.disease.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.rice.disease.service.PythonInferenceService;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping({"", "/api/v1"})
public class PredictionController {

    private static final long MAX_UPLOAD_BYTES = 6L * 1024L * 1024L;

    private final PythonInferenceService inferenceService;

    public PredictionController(PythonInferenceService inferenceService) {
        this.inferenceService = inferenceService;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }

    @PostMapping(value = "/predict", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public JsonNode predict(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Empty file uploaded.");
        }
        if (file.getSize() > MAX_UPLOAD_BYTES) {
            throw new IllegalArgumentException("Image is too large. Please upload up to 6 MB.");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Please upload an image file.");
        }
        return inferenceService.predict(file);
    }
}
