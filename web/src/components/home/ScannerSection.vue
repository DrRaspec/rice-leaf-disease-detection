<template>
  <section id="demo" class="section-pad scanner-section">
    <div class="site-shell">
      <div class="text-center">
        <p class="eyebrow">{{ t('scanner.eyebrow') }}</p>
        <h2 class="section-title">{{ t('scanner.title') }}</h2>
        <p class="section-subtitle mx-auto max-w-2xl">
          {{ t('scanner.subtitle') }}
        </p>
      </div>

      <div class="mt-10 grid gap-6 lg:grid-cols-2 lg:gap-8">
        <div>
          <UploadCard
            :selected-file="selectedFile"
            :preview-src="previewUrl"
            :loading="loading || optimizing"
            @file-selected="handleFileSelected"
            @analyze="analyze"
            @remove="removeSelection"
          />

          <p v-if="optimizing" class="mt-4 text-sm" style="color: var(--rg-text-secondary)">{{ t('scanner.optimizing') }}</p>
          <p v-else-if="loading" class="mt-4 text-sm" style="color: var(--rg-text-secondary)">
            {{ uploadProgress > 0 && uploadProgress < 100 ? t('scanner.upload', { progress: uploadProgress }) : t('scanner.analyzing') }}
          </p>
          <p v-if="selectedFile && optimizedInfo" class="mt-2 text-xs" style="color: var(--rg-text-tertiary)">
            {{ optimizedInfo }}
          </p>

          <div
            v-if="error"
            class="mt-4 rounded-2xl border p-4 text-sm"
            style="border-color: var(--rg-error-border); background: var(--rg-error-bg); color: var(--rg-error-text)"
            role="status"
            aria-live="polite"
          >
            {{ error }}
          </div>
        </div>

        <ResultCard :result="result" :loading="loading" @scan-another="scanAnother" />
      </div>
    </div>
  </section>
</template>

<script setup>
import { onBeforeUnmount, ref } from 'vue'
import UploadCard from '@/components/home/UploadCard.vue'
import ResultCard from '@/components/home/ResultCard.vue'
import { usePrediction } from '@/composables/usePrediction'
import { optimizeImageForUpload } from '@/utils/imageOptimize'
import { useWebI18n } from '@/composables/useWebI18n'

const { result, loading, error, uploadProgress, predict, reset } = usePrediction()
const { t } = useWebI18n()

const selectedFile = ref(null)
const previewUrl = ref('')
const optimizing = ref(false)
const optimizedInfo = ref('')

function revokePreview() {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
    previewUrl.value = ''
  }
}

function formatKB(bytes) {
  return `${Math.max(1, Math.round(bytes / 1024))} KB`
}

async function handleFileSelected(file) {
  if (!file) return
  revokePreview()
  optimizing.value = true
  optimizedInfo.value = ''
  try {
    const optimized = await optimizeImageForUpload(file)
    selectedFile.value = optimized
    previewUrl.value = URL.createObjectURL(optimized)
    if (optimized.size < file.size) {
      optimizedInfo.value = t('scanner.optimized', { from: formatKB(file.size), to: formatKB(optimized.size) })
    }
  } catch {
    selectedFile.value = file
    previewUrl.value = URL.createObjectURL(file)
    optimizedInfo.value = ''
  } finally {
    optimizing.value = false
  }
  reset()
}

async function analyze() {
  if (!selectedFile.value || loading.value || optimizing.value) return
  await predict(selectedFile.value)
}

function removeSelection() {
  selectedFile.value = null
  revokePreview()
  optimizedInfo.value = ''
  optimizing.value = false
  reset()
}

function scanAnother() {
  removeSelection()
}

onBeforeUnmount(() => {
  revokePreview()
})
</script>
