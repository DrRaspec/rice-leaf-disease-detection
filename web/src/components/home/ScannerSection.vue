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
            :loading="loading"
            @file-selected="handleFileSelected"
            @analyze="analyze"
            @remove="removeSelection"
          />

          <p v-if="loading" class="mt-4 text-sm text-[#2D4535]">Analyzing...</p>

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

const { result, loading, error, predict, reset } = usePrediction()

const selectedFile = ref(null)
const previewUrl = ref('')

function revokePreview() {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
    previewUrl.value = ''
  }
}

function handleFileSelected(file) {
  if (!file) return
  revokePreview()
  selectedFile.value = file
  previewUrl.value = URL.createObjectURL(file)
  reset()
}

async function analyze() {
  if (!selectedFile.value || loading.value) return
  await predict(selectedFile.value)
}

function removeSelection() {
  selectedFile.value = null
  revokePreview()
  reset()
}

function scanAnother() {
  removeSelection()
}

onBeforeUnmount(() => {
  revokePreview()
})
</script>
