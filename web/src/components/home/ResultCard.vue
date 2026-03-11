<template>
  <article class="surface-card min-h-[420px] p-6 sm:p-7">
    <h3 class="text-xl font-semibold" style="color: var(--rg-text)">{{ labels.title }}</h3>

    <div v-if="loading" class="mt-10 flex flex-col items-center justify-center gap-4 text-center" style="color: var(--rg-text-secondary)">
      <span class="spinner spinner-lg" aria-hidden="true" />
      <p class="text-base font-medium" style="color: var(--rg-text)">{{ labels.analyzing }}</p>
      <p class="text-sm">{{ labels.hint }}</p>
    </div>

    <div v-else-if="!result" class="mt-10 flex flex-col items-center justify-center gap-4 text-center" style="color: var(--rg-text-tertiary)">
      <div class="icon-pill" aria-hidden="true">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-5 w-5">
          <path d="M4 4h16v12H4z" stroke-linejoin="round" />
          <path d="M8 16h8M10 20h4" stroke-linecap="round" />
        </svg>
      </div>
      <p class="text-base font-medium" style="color: var(--rg-text)">{{ labels.emptyTitle }}</p>
      <p class="text-sm">{{ labels.emptyBody }}</p>
    </div>

    <div v-else class="mt-5 space-y-6">
      <div class="flex flex-wrap items-center gap-3">
        <h4 class="text-2xl font-bold" style="color: var(--rg-text)">{{ result.info.label }}</h4>
        <span class="risk-chip" :class="chipClass">{{ riskLabel }}{{ labels.riskSuffix }}</span>
      </div>

      <div>
        <div class="mb-2 flex items-center justify-between text-sm" style="color: var(--rg-text-secondary)">
          <span>{{ labels.confidence }}</span>
          <span class="font-semibold" style="color: var(--rg-text)">{{ confidenceLabel }}</span>
        </div>
        <div class="h-3 w-full overflow-hidden rounded-full" style="background: var(--rg-surface-tint)">
          <div class="h-full rounded-full transition-all duration-500" :style="barStyle" />
        </div>
      </div>

      <p class="rounded-2xl p-4 text-sm leading-relaxed" style="background: var(--rg-surface-soft); color: var(--rg-text-secondary)">
        {{ result.info.summary }}
      </p>

      <div
        v-if="showUncertain"
        class="rounded-2xl border p-4 text-sm leading-relaxed"
        style="border-color: var(--rg-warning-border); background: var(--rg-warning-bg); color: var(--rg-warning-text)"
      >
        <p class="font-semibold">{{ labels.lowConfidenceTitle }}</p>
        <p class="mt-1">
          {{ labels.lowConfidenceBody }}
          {{ candidateLabel }}.
          {{ labels.lowConfidenceTail }}
        </p>
      </div>

      <section class="space-y-3">
        <h5 class="text-sm font-semibold uppercase tracking-wide" style="color: var(--rg-primary)">{{ labels.whatToDo }}</h5>
        <p class="rounded-2xl border p-4 text-sm leading-relaxed" style="border-color: var(--rg-border); background: var(--rg-surface); color: var(--rg-text-secondary)">
          {{ result.info.whatToDo }}
        </p>
      </section>

      <section class="space-y-3">
        <h5 class="text-sm font-semibold uppercase tracking-wide" style="color: var(--rg-primary)">{{ labels.prevention }}</h5>
        <p class="rounded-2xl border p-4 text-sm leading-relaxed" style="border-color: var(--rg-border); background: var(--rg-surface); color: var(--rg-text-secondary)">
          {{ result.info.prevention }}
        </p>
      </section>

      <button type="button" class="text-sm font-medium underline-offset-4 hover:underline" style="color: var(--rg-primary)" @click="$emit('scan-another')">
        {{ labels.scanAnother }}
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

const isKhmer = computed(() => String(props.result?.language || '').toLowerCase().startsWith('km'))

const confidenceLabel = computed(() => `${confidenceValue.value.toFixed(1)}%`)

const riskLabel = computed(() => {
  const severity = props.result?.info?.severity
  if (isKhmer.value) {
    if (severity === 'high') return 'ហានិភ័យខ្ពស់'
    if (severity === 'medium') return 'ហានិភ័យមធ្យម'
    return 'ហានិភ័យទាប'
  }
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

const showUncertain = computed(
  () => Boolean(props.result?.is_uncertain) || confidenceValue.value < 45,
)

const candidateLabel = computed(() => {
  const candidates = props.result?.possible_classes
  if (!Array.isArray(candidates) || candidates.length === 0) return isKhmer.value ? 'មិនស្គាល់' : 'unknown'
  return candidates.map((item) => String(item).replace(/_/g, ' ')).join(' / ')
})

const labels = computed(() =>
  isKhmer.value
    ? {
        title: 'លទ្ធផល',
        analyzing: 'កំពុងវិភាគ...',
        hint: 'ជាទូទៅចំណាយពេលតែប៉ុន្មានវិនាទី។',
        emptyTitle: 'លទ្ធផលនឹងបង្ហាញនៅទីនេះ',
        emptyBody: 'បញ្ចូលរូបស្លឹកស្រូវ ហើយវិភាគដើម្បីមើលព័ត៌មានលម្អិត។',
        riskSuffix: '',
        confidence: 'កម្រិតជឿជាក់',
        lowConfidenceTitle: 'លទ្ធផលមានទំនុកចិត្តទាប។',
        lowConfidenceBody: 'អាចជា៖',
        lowConfidenceTail: 'សូមថតរូបជិតជាងមុន ក្នុងពន្លឺល្អ។',
        whatToDo: 'អ្វីត្រូវធ្វើបន្ត',
        prevention: 'ការការពារ',
        scanAnother: 'វិភាគម្តងទៀត',
      }
    : {
        title: 'Result',
        analyzing: 'Analyzing...',
        hint: 'This usually takes a few seconds.',
        emptyTitle: 'Results appear here',
        emptyBody: 'Upload and analyze a rice leaf to see diagnosis details.',
        riskSuffix: ' risk',
        confidence: 'Confidence',
        lowConfidenceTitle: 'Low confidence result.',
        lowConfidenceBody: 'Possible classes:',
        lowConfidenceTail: 'Please retake a closer photo in better light for stronger accuracy.',
        whatToDo: 'What to do now',
        prevention: 'Prevention',
        scanAnother: 'Scan another',
      },
)
</script>
