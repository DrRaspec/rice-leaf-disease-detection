package com.rice.disease.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
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

    private static final Map<String, LocalizedDiseaseInfo> DISEASES_EN = Map.of(
        "healthy",
        new LocalizedDiseaseInfo(
            "healthy",
            "Healthy",
            "healthy",
            "none",
            "Leaf looks healthy. Continue normal care and weekly checks.",
            "Keep irrigation and balanced fertilization. Continue monitoring."
        ),
        "bacterial_leaf_blight",
        new LocalizedDiseaseInfo(
            "bacterial_leaf_blight",
            "Bacterial Leaf Blight",
            "bacterial_leaf_blight",
            "high",
            "Leaf edges yellow and dry quickly.",
            "Remove heavily infected leaves and improve drainage. Use approved bactericide."
        ),
        "leaf_blast",
        new LocalizedDiseaseInfo(
            "leaf_blast",
            "Leaf Blast",
            "leaf_blast",
            "high",
            "Gray-centered lesions with dark borders.",
            "Avoid excess nitrogen and apply recommended fungicide for blast."
        ),
        "brown_spot",
        new LocalizedDiseaseInfo(
            "brown_spot",
            "Brown Spot",
            "brown_spot",
            "medium",
            "Oval brown spots, sometimes with yellow halo.",
            "Improve balanced nutrition (especially potassium) and monitor spread."
        ),
        "leaf_scald",
        new LocalizedDiseaseInfo(
            "leaf_scald",
            "Leaf Scald",
            "leaf_scald",
            "medium",
            "Scald-like brown lesions often starting from tips.",
            "Improve airflow and apply suitable fungicide if symptoms progress."
        ),
        "narrow_brown_spot",
        new LocalizedDiseaseInfo(
            "narrow_brown_spot",
            "Narrow Brown Spot",
            "narrow_brown_spot",
            "low",
            "Narrow linear lesions on the leaf blade.",
            "Monitor for a few days and spray only if disease spreads rapidly."
        )
    );

    private static final Map<String, LocalizedDiseaseInfo> DISEASES_KM = Map.of(
        "healthy",
        new LocalizedDiseaseInfo(
            "healthy",
            "សុខភាពល្អ",
            "healthy",
            "none",
            "ស្លឹកមានសុខភាពល្អ។ បន្តថែទាំធម្មតា និងពិនិត្យជារៀងរាល់សប្តាហ៍។",
            "ថ្ងៃនេះ: រក្សាការស្រោចទឹកដដែល។ សប្តាហ៍នេះ: បន្តដាក់ជីសមស្រប និងតាមដានស្រែ។"
        ),
        "bacterial_leaf_blight",
        new LocalizedDiseaseInfo(
            "bacterial_leaf_blight",
            "រលាកស្លឹកបាក់តេរី",
            "bacterial_leaf_blight",
            "high",
            "សង្ស័យជំងឺរលាកស្លឹកបាក់តេរី។ គែមស្លឹកលឿង ហើយស្ងួតលឿន។",
            "ថ្ងៃនេះ: ដកស្លឹកដែលឆ្លងខ្លាំង និងកែលម្អការបង្ហូរទឹក។ បាញ់ថ្នាំប្រភេទស្ពាន់តាមការណែនាំមូលដ្ឋាន។"
        ),
        "leaf_blast",
        new LocalizedDiseaseInfo(
            "leaf_blast",
            "ជំងឺប្លាស",
            "leaf_blast",
            "high",
            "សង្ស័យជំងឺប្លាស។ ស្នាមមានកណ្ដាលប្រផេះ និងគែមងងឹត។",
            "ថ្ងៃនេះ: ជៀសវាងជីនីត្រូសែនលើស។ បន្ទាប់មកប្រើថ្នាំកម្ចាត់ផ្សិតសមស្របតាមការណែនាំអ្នកជំនាញ។"
        ),
        "brown_spot",
        new LocalizedDiseaseInfo(
            "brown_spot",
            "ចំណុចត្នោត",
            "brown_spot",
            "medium",
            "សង្ស័យជំងឺចំណុចត្នោត។ ចំណុចអូវ៉ាល់អាចរាលដាលលើដំណាំខ្សោយ។",
            "សប្តាហ៍នេះ: កែលម្អការដាក់ជីឱ្យសមតុល្យ (ជាពិសេសប៉ូតាស្យូម) ហើយប្រើថ្នាំបង្ការផ្សិតបើរាលដាលខ្លាំង។"
        ),
        "leaf_scald",
        new LocalizedDiseaseInfo(
            "leaf_scald",
            "ដំបៅស្លឹក",
            "leaf_scald",
            "medium",
            "សង្ស័យដំបៅស្លឹក។ ខូចខាតភាគច្រើនចាប់ផ្តើមពីចុងស្លឹកចុះក្រោម។",
            "ថ្ងៃនេះ: កែលម្អខ្យល់ចេញចូលរវាងដើម។ ប្រើថ្នាំសមស្រប និងជៀសវាងជីនីត្រូសែនលើស។"
        ),
        "narrow_brown_spot",
        new LocalizedDiseaseInfo(
            "narrow_brown_spot",
            "ចំណុចត្នោតចង្អៀត",
            "narrow_brown_spot",
            "low",
            "សង្ស័យចំណុចត្នោតចង្អៀត។ ជាទូទៅស្រាល ប៉ុន្តែត្រូវតាមដាន។",
            "តាមដានរយៈពេល ៣-៥ ថ្ងៃ។ រក្សាអាហារូបត្ថម្ភ និងទឹកឱ្យសមស្រប។ បាញ់ថ្នាំតែពេលរាលដាលលឿន។"
        )
    );

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

        response.set("disease_info", localizedInfoNode(predictedClass, resolvedLanguage));
        response.put("language", resolvedLanguage);
        return response;
    }

    private ObjectNode localizedInfoNode(String predictedClass, String language) {
        Map<String, LocalizedDiseaseInfo> db = "km".equals(language) ? DISEASES_KM : DISEASES_EN;
        LocalizedDiseaseInfo info = db.getOrDefault(
            predictedClass,
            new LocalizedDiseaseInfo(
                predictedClass,
                predictedClass.replace('_', ' '),
                "unknown",
                "unknown",
                "",
                ""
            )
        );

        ObjectNode node = objectMapper.createObjectNode();
        node.put("key", info.key());
        node.put("label", info.label());
        node.put("icon", info.icon());
        node.put("severity", info.severity());
        node.put("description", info.description());
        node.put("treatment", info.treatment());
        return node;
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

    private record LocalizedDiseaseInfo(
        String key,
        String label,
        String icon,
        String severity,
        String description,
        String treatment
    ) {
    }
}
