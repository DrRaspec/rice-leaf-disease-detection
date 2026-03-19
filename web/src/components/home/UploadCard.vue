<template>
  <article class="surface-card p-6 sm:p-7">
    <div class="flex flex-wrap items-start justify-between gap-4">
      <div class="max-w-lg">
        <p class="text-xs font-bold uppercase tracking-[0.18em]" style="color: var(--rg-primary)">
          {{ t('scanner.eyebrow') }}
        </p>
        <h3 class="mt-3 text-2xl sm:text-[1.9rem]" style="color: var(--rg-text); font-family: var(--rg-font-display); line-height: 1.05">
          {{ t('upload.title') }}
        </h3>
        <p class="mt-3 text-sm leading-relaxed" style="color: var(--rg-text-secondary)">
          {{ t('upload.note') }}
        </p>
      </div>

      <div class="rounded-[22px] border px-4 py-3 text-sm" style="border-color: var(--rg-border); background: var(--rg-surface-soft); color: var(--rg-text-secondary)">
        <p class="font-semibold" style="color: var(--rg-text)">{{ t('upload.tip1') }}</p>
        <p class="mt-1">{{ t('upload.tip2') }}</p>
      </div>
    </div>

    <div
      class="upload-dropzone mt-6"
      :class="{ 'is-dragging': isDragging, 'is-disabled': loading }"
      role="button"
      tabindex="0"
      aria-label="Upload rice leaf image"
      @click="openFilePicker"
      @keydown.enter.prevent="openFilePicker"
      @keydown.space.prevent="openFilePicker"
      @dragover.prevent="handleDragOver"
      @dragleave.prevent="handleDragLeave"
      @drop.prevent="handleDrop"
    >
      <input
        ref="fileInput"
        type="file"
        class="sr-only"
        accept="image/*"
        :disabled="loading"
        @change="handleFileChange"
      />

      <template v-if="previewSrc">
        <button
          class="group block w-full"
          type="button"
          :disabled="loading"
          @click.stop="openZoom"
        >
          <div class="preview-frame">
            <img :src="previewSrc" alt="Selected rice leaf preview" class="h-full w-full object-contain" />
            <div class="preview-overlay">{{ t('upload.clickZoom') }}</div>
          </div>
        </button>

        <div class="mt-4 flex flex-wrap items-center gap-x-4 gap-y-2 text-sm" style="color: var(--rg-text-secondary)">
          <span class="font-medium" style="color: var(--rg-text)">{{ selectedFile?.name }}</span>
          <span>{{ formattedSize }}</span>
        </div>
      </template>

      <template v-else>
        <div
          class="mx-auto flex h-20 w-20 items-center justify-center rounded-[28px]"
          style="background: linear-gradient(135deg, color-mix(in srgb, var(--rg-accent) 26%, var(--rg-surface)), color-mix(in srgb, var(--rg-primary) 18%, var(--rg-surface))); color: var(--rg-primary-deep)"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" class="h-8 w-8">
            <path d="M4 14.5 8.8 9.7a2 2 0 0 1 2.8 0l4.8 4.8" stroke-linecap="round" stroke-linejoin="round" />
            <path d="m14.5 12 1.7-1.7a2 2 0 0 1 2.8 0L21 12.3" stroke-linecap="round" stroke-linejoin="round" />
            <rect x="3" y="4" width="18" height="16" rx="2" />
          </svg>
        </div>

        <p class="mt-5 text-lg font-semibold" style="color: var(--rg-text)">{{ t('upload.drag') }}</p>
        <p class="mt-2 text-sm" style="color: var(--rg-text-tertiary)">{{ t('upload.note') }}</p>

        <div class="mt-5 grid gap-3 text-left sm:grid-cols-3">
          <div class="rounded-[22px] border p-4 text-sm" style="border-color: var(--rg-border); background: var(--rg-surface)">
            <p class="font-semibold" style="color: var(--rg-text)">{{ t('upload.tip1') }}</p>
          </div>
          <div class="rounded-[22px] border p-4 text-sm" style="border-color: var(--rg-border); background: var(--rg-surface)">
            <p class="font-semibold" style="color: var(--rg-text)">{{ t('upload.tip2') }}</p>
          </div>
          <div class="rounded-[22px] border p-4 text-sm" style="border-color: var(--rg-border); background: var(--rg-surface)">
            <p class="font-semibold" style="color: var(--rg-text)">{{ t('upload.tip3') }}</p>
          </div>
        </div>
      </template>
    </div>

    <div class="mt-6 flex flex-wrap items-center gap-3">
      <button type="button" class="btn-pill btn-secondary" :disabled="loading" @click="openFilePicker">
        {{ t('upload.replace') }}
      </button>
      <button
        type="button"
        class="btn-pill btn-ghost-danger"
        :disabled="!previewSrc || loading"
        @click="$emit('remove')"
      >
        {{ t('upload.remove') }}
      </button>
      <button type="button" class="btn-pill btn-primary ml-auto min-w-[180px]" :disabled="!selectedFile || loading" @click="$emit('analyze')">
        <span v-if="loading" class="inline-flex items-center gap-2">
          <span class="spinner" aria-hidden="true" />
          {{ t('upload.analyzing') }}
        </span>
        <span v-else>{{ t('upload.analyze') }}</span>
      </button>
    </div>
  </article>

  <div v-if="showZoom" class="zoom-modal" role="dialog" aria-modal="true" @click.self="showZoom = false">
    <button type="button" class="zoom-close" aria-label="Close zoomed preview" @click="showZoom = false">{{ t('upload.close') }}</button>
    <img :src="previewSrc" alt="Zoomed rice leaf preview" class="zoom-image" />
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useWebI18n } from '@/composables/useWebI18n'

const props = defineProps({
  selectedFile: {
    type: Object,
    default: null,
  },
  previewSrc: {
    type: String,
    default: '',
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

const emit = defineEmits(['file-selected', 'analyze', 'remove'])
const { t } = useWebI18n()

const fileInput = ref(null)
const isDragging = ref(false)
const showZoom = ref(false)

const formattedSize = computed(() => {
  const size = props.selectedFile?.size
  if (!size) return ''
  if (size >= 1024 * 1024) {
    return `${(size / (1024 * 1024)).toFixed(2)} MB`
  }
  return `${Math.max(1, Math.round(size / 1024))} KB`
})

function openFilePicker() {
  if (props.loading) return
  fileInput.value?.click()
}

function emitSelected(file) {
  if (!file || !file.type.startsWith('image/')) return
  showZoom.value = false
  isDragging.value = false
  fileInput.value && (fileInput.value.value = '')
  // Keep selected file state in parent so preview/result can sync cleanly.
  emit('file-selected', file)
}

function handleFileChange(event) {
  const file = event.target.files?.[0]
  emitSelected(file)
}

function handleDragOver() {
  if (props.loading) return
  isDragging.value = true
}

function handleDragLeave() {
  isDragging.value = false
}

function handleDrop(event) {
  if (props.loading) return
  const file = event.dataTransfer?.files?.[0]
  emitSelected(file)
}

function openZoom() {
  if (!props.previewSrc || props.loading) return
  showZoom.value = true
}

function onKeydown(event) {
  if (event.key === 'Escape') {
    showZoom.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
})
</script>
