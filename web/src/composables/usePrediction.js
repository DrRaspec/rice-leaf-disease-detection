import { ref } from 'vue'
import { apiClient } from '@/services/apiClient'

const DISEASE_INFO = {
  bacterial_leaf_blight: {
    label: 'Bacterial Leaf Blight',
    icon: 'shield-alert',
    severity: 'high',
    color: '#C62828',
    summary:
      'Detected patterns suggest bacterial leaf blight, often seen as yellowing and drying from leaf edges.',
    whatToDo:
      'Start with copper-based bactericides, remove severely affected leaves, and improve field drainage.',
    prevention:
      'Use resistant varieties, avoid standing water, and sanitize tools between fields.',
  },
  brown_spot: {
    label: 'Brown Spot',
    icon: 'leaf-spot',
    severity: 'medium',
    color: '#F9A825',
    summary:
      'Detected patterns suggest brown spot, commonly linked to nutrient stress and fungal infection.',
    whatToDo:
      'Apply a suitable fungicide and improve nutrition, especially potassium and balanced NPK.',
    prevention:
      'Maintain soil fertility, use healthy seed, and monitor moisture to reduce fungal spread.',
  },
  healthy: {
    label: 'Healthy',
    icon: 'leaf-check',
    severity: 'low',
    color: '#2E7D32',
    summary: 'Detected patterns suggest a healthy leaf with no major disease indicators.',
    whatToDo:
      'Continue current field practices and monitor crop condition weekly for early warning signs.',
    prevention:
      'Keep balanced fertilization, proper spacing, and regular scouting during humid periods.',
  },
  leaf_blast: {
    label: 'Leaf Blast',
    icon: 'burst',
    severity: 'high',
    color: '#C62828',
    summary:
      'Detected patterns suggest leaf blast with lesion shapes typical of fungal infection.',
    whatToDo:
      'Apply recommended blast fungicides and avoid excess nitrogen in upcoming fertilizer doses.',
    prevention:
      'Use resistant cultivars, improve airflow, and avoid prolonged leaf wetness in dense fields.',
  },
  leaf_scald: {
    label: 'Leaf Scald',
    icon: 'flame',
    severity: 'medium',
    color: '#F9A825',
    summary:
      'Detected patterns suggest leaf scald, often seen as scalded lesions moving downward from tips.',
    whatToDo:
      'Apply a suitable fungicide and remove heavily affected leaves where practical.',
    prevention:
      'Improve airflow, avoid over-fertilization, and monitor fields after extended wet weather.',
  },
  narrow_brown_spot: {
    label: 'Narrow Brown Spot',
    icon: 'line-spot',
    severity: 'low',
    color: '#2E7D32',
    summary:
      'Detected patterns suggest narrow brown spot, usually mild but worth monitoring early.',
    whatToDo:
      'Use recommended fungicide only if spread increases and maintain consistent nutrition.',
    prevention:
      'Avoid water stress, keep balanced nutrients, and rotate field hygiene practices.',
  },
}

export function usePrediction() {
  const result = ref(null)
  const loading = ref(false)
  const error = ref(null)

  async function predict(file) {
    if (!file) return

    error.value = null
    result.value = null
    loading.value = true

    try {
      const form = new FormData()
      form.append('file', file)
      const { data } = await apiClient.post('/predict', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      const key = data.predicted_class
      result.value = {
        ...data,
        info: DISEASE_INFO[key] ?? {
          label: key.replace(/_/g, ' '),
          icon: 'leaf',
          severity: 'medium',
          color: '#F9A825',
          summary: 'Detected patterns suggest this class. Please verify with field observation.',
          whatToDo: 'Follow standard disease management while you confirm the diagnosis.',
          prevention: 'Maintain monitoring, field hygiene, and balanced fertilization.',
        },
      }
    } catch (err) {
      error.value =
        err.response?.data?.detail ??
        err.response?.data?.message ??
        err.response?.data?.error ??
        err.message ??
        'Prediction failed. Please try again.'
    } finally {
      loading.value = false
    }
  }

  function reset() {
    result.value = null
    error.value = null
    loading.value = false
  }

  return { result, loading, error, predict, reset }
}
