package com.rice.disease.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.rice.disease.service.DiseaseInfoCatalog;
import com.rice.disease.service.PythonInferenceService;
import java.util.Locale;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping({"", "/api/v1"})
public class PredictionController {

    private static final long MAX_UPLOAD_BYTES = 6L * 1024L * 1024L;

    private final PythonInferenceService inferenceService;
    private final ObjectMapper objectMapper;

    public PredictionController(PythonInferenceService inferenceService, ObjectMapper objectMapper) {
        this.inferenceService = inferenceService;
        this.objectMapper = objectMapper;
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }

    @PostMapping(value = "/predict", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public JsonNode predict(
        @RequestParam("file") MultipartFile file,
        @RequestParam(value = "lang", required = false) String lang,
        @RequestHeader(value = "Accept-Language", required = false) String acceptLanguage
    ) {
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

        JsonNode raw = inferenceService.predict(file);
        if (!raw.isObject()) {
            throw new IllegalStateException("Inference output is invalid.");
        }

        String resolvedLanguage = resolveLanguage(lang, acceptLanguage);
        ObjectNode response = ((ObjectNode) raw).deepCopy();
        String predictedClass = response.path("predicted_class").asText("");

        DiseaseInfoCatalog.DiseaseInfo info = DiseaseInfoCatalog.lookup(predictedClass, resolvedLanguage);
        response.set("disease_info", DiseaseInfoCatalog.toJsonNode(info, objectMapper));
        response.put("language", resolvedLanguage);
        return response;
    }

    private String resolveLanguage(String langParam, String acceptLanguage) {
        String candidate = langParam;
        if (candidate == null || candidate.isBlank()) {
            candidate = acceptLanguage;
        }
        if (candidate == null || candidate.isBlank()) {
            return "en";
        }

        String normalized = candidate.trim().toLowerCase(Locale.ROOT);
        if (normalized.contains(",")) {
            normalized = normalized.substring(0, normalized.indexOf(','));
        }

        return normalized.startsWith("km") ? "km" : "en";
    }
}
