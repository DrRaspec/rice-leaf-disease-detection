<template>
  <section id="demo" class="section-pad scanner-section">
    <div class="site-shell">
      <div class="text-center">
        <p class="eyebrow">Scanner Demo</p>
        <h2 class="section-title">Upload and analyze a rice leaf</h2>
        <p class="section-subtitle mx-auto max-w-2xl">
          Choose a clear leaf photo to get disease name, confidence, and practical treatment guidance.
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

          <p v-if="optimizing" class="mt-4 text-sm text-[#2D4535]">Optimizing image for faster upload...</p>
          <p v-else-if="loading" class="mt-4 text-sm text-[#2D4535]">
            {{ uploadProgress > 0 && uploadProgress < 100 ? `Uploading ${uploadProgress}%...` : 'Analyzing...' }}
          </p>
          <p v-if="selectedFile && optimizedInfo" class="mt-2 text-xs text-[#4D6653]">
            {{ optimizedInfo }}
          </p>

          <div
            v-if="error"
            class="mt-4 rounded-2xl border border-[#F5C2C2] bg-[#FFF2F2] p-4 text-sm text-[#8A1F1F]"
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

const { result, loading, error, uploadProgress, predict, reset } = usePrediction()

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
      optimizedInfo.value = `Optimized from ${formatKB(file.size)} to ${formatKB(optimized.size)}`
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
