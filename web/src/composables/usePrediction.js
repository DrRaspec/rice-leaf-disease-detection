import { ref } from 'vue'
import { apiClient } from '@/services/apiClient'
import { useWebI18n } from '@/composables/useWebI18n'

const SEVERITY_COLORS = {
  none: '#2E7D32',
  low: '#2E7D32',
  medium: '#F9A825',
  high: '#C62828',
  unknown: '#F9A825',
}

function isKhmer(language) {
  return typeof language === 'string' && language.toLowerCase().startsWith('km')
}

function fallbackInfo(key, language) {
  if (isKhmer(language)) {
    return {
      label: key.replace(/_/g, ' '),
      summary: 'លទ្ធផលត្រូវការការផ្ទៀងផ្ទាត់បន្ថែម។ សូមពិនិត្យស្រែជាក់ស្តែង។',
      whatToDo: 'អនុវត្តការគ្រប់គ្រងជំងឺស្តង់ដារ ហើយពិគ្រោះអ្នកជំនាញកសិកម្មមូលដ្ឋាន។',
      prevention: 'រក្សាអនាម័យស្រែ ការដាក់ជីសមតុល្យ និងតាមដានជាប្រចាំ។',
    }
  }
  return {
    label: key.replace(/_/g, ' '),
    summary: 'Detected patterns suggest this class. Please verify with field observation.',
    whatToDo: 'Follow standard disease management while you confirm the diagnosis.',
    prevention: 'Maintain monitoring, field hygiene, and balanced fertilization.',
  }
}

export function usePrediction() {
  const { language } = useWebI18n()
  const result = ref(null)
  const loading = ref(false)
  const error = ref(null)
  const uploadProgress = ref(0)

  function shouldRetry(err) {
    if (!err) return false
    if (!err.response) return true
    return err.response.status >= 500
  }

  async function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }

  async function predict(file) {
    if (!file) return

    error.value = null
    result.value = null
    loading.value = true
    uploadProgress.value = 0

    const maxAttempts = 2
    for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        const form = new FormData()
        form.append('file', file)
        const preferredLanguage = language.value || 'en'
        const { data } = await apiClient.post('/predict', form, {
          params: { lang: preferredLanguage },
          headers: { 'Content-Type': 'multipart/form-data', 'Accept-Language': preferredLanguage },
          onUploadProgress: (event) => {
            if (!event.total) return
            uploadProgress.value = Math.min(100, Math.round((event.loaded / event.total) * 100))
          },
        })
        const key = data.predicted_class
        const language = data.language || preferredLanguage
        const apiInfo = data.disease_info ?? {}
        const severity = apiInfo.severity || 'unknown'
        const fallback = fallbackInfo(key, language)
        result.value = {
          ...data,
          language,
          info: {
            label: apiInfo.label || fallback.label,
            icon: apiInfo.icon || 'unknown',
            severity,
            color: SEVERITY_COLORS[severity] ?? SEVERITY_COLORS.unknown,
            summary: apiInfo.description || fallback.summary,
            whatToDo: apiInfo.treatment || fallback.whatToDo,
            prevention: apiInfo.prevention || fallback.prevention,
          },
          is_uncertain: Boolean(data.is_uncertain),
          possible_classes: Array.isArray(data.possible_classes) ? data.possible_classes : [],
        }
        break
      } catch (err) {
        const canRetry = attempt < maxAttempts && shouldRetry(err)
        if (canRetry) {
          await sleep(500 * attempt)
          continue
        }
        error.value =
          err.response?.data?.detail ??
          err.response?.data?.message ??
          err.response?.data?.error ??
          err.message ??
          'Prediction failed. Please try again.'
      } finally {
        if (attempt === maxAttempts || result.value) {
          loading.value = false
          uploadProgress.value = result.value ? 100 : 0
        }
      }
    }
  }

  function reset() {
    result.value = null
    error.value = null
    loading.value = false
    uploadProgress.value = 0
  }

  return { result, loading, error, uploadProgress, predict, reset }
}
