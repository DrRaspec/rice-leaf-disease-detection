<template>
  <article class="surface-card min-h-[420px] p-6 sm:p-7">
    <h3 class="text-xl font-semibold text-[#102016]">Result</h3>

    <div v-if="loading" class="mt-10 flex flex-col items-center justify-center gap-4 text-center text-[#38503F]">
      <span class="spinner spinner-lg" aria-hidden="true" />
      <p class="text-base font-medium text-[#102016]">Analyzing...</p>
      <p class="text-sm">This usually takes a few seconds.</p>
    </div>

    <div v-else-if="!result" class="mt-10 flex flex-col items-center justify-center gap-4 text-center text-[#4D6653]">
      <div class="icon-pill" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-5 w-5">
          <path d="M4 4h16v12H4z" stroke-linejoin="round" />
          <path d="M8 16h8M10 20h4" stroke-linecap="round" />
        </svg>
      </div>
      <p class="text-base font-medium text-[#102016]">Results appear here</p>
      <p class="text-sm">Upload and analyze a rice leaf to see diagnosis details.</p>
    </div>

    <div v-else class="mt-5 space-y-6">
      <div class="flex flex-wrap items-center gap-3">
        <h4 class="text-2xl font-bold text-[#102016]">{{ result.info.label }}</h4>
        <span class="risk-chip" :class="chipClass">{{ riskLabel }} risk</span>
      </div>

      <div>
        <div class="mb-2 flex items-center justify-between text-sm text-[#38503F]">
          <span>Confidence</span>
          <span class="font-semibold text-[#102016]">{{ confidenceLabel }}</span>
        </div>
        <div class="h-3 w-full overflow-hidden rounded-full bg-[#E4EDE1]">
          <div class="h-full rounded-full transition-all duration-500" :style="barStyle" />
        </div>
      </div>

      <p class="rounded-2xl bg-[#EEF6EA] p-4 text-sm leading-relaxed text-[#2D4535]">
        {{ result.info.summary }}
      </p>

      <section class="space-y-3">
        <h5 class="text-sm font-semibold uppercase tracking-wide text-[#2E7D32]">What to do now</h5>
        <p class="rounded-2xl border border-[#E6EFE3] bg-white p-4 text-sm leading-relaxed text-[#2D4535]">
          {{ result.info.whatToDo }}
        </p>
      </section>

      <section class="space-y-3">
        <h5 class="text-sm font-semibold uppercase tracking-wide text-[#2E7D32]">Prevention</h5>
        <p class="rounded-2xl border border-[#E6EFE3] bg-white p-4 text-sm leading-relaxed text-[#2D4535]">
          {{ result.info.prevention }}
        </p>
      </section>

      <button type="button" class="text-sm font-medium text-[#2E7D32] underline-offset-4 hover:underline" @click="$emit('scan-another')">
        Scan another
      </button>
    </div>
  </article>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  result: {
    type: Object,
    default: null,
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['scan-another'])

const confidenceValue = computed(() => {
  const value = props.result?.confidence ?? 0
  return Math.min(100, Math.max(0, value * 100))
})

const confidenceLabel = computed(() => `${confidenceValue.value.toFixed(1)}%`)

const riskLabel = computed(() => {
  const severity = props.result?.info?.severity
  if (severity === 'high' || severity === 'medium') return severity[0].toUpperCase() + severity.slice(1)
  return 'Low'
})

const chipClass = computed(() => {
  const label = riskLabel.value.toLowerCase()
  if (label === 'high') return 'chip-risk-high'
  if (label === 'medium') return 'chip-risk-medium'
  return 'chip-risk-low'
})

const barStyle = computed(() => ({
  width: `${confidenceValue.value}%`,
  backgroundColor: props.result?.info?.color || '#2E7D32',
}))
</script>
